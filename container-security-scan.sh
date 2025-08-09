#!/bin/bash
#===============================================================================
# Container Security Scanning Script
#
# Comprehensive security scanning for Docker containers in the 40docs platform.
# Integrates multiple security tools for vulnerability assessment, malware detection,
# and compliance validation.
#
# Usage: ./container-security-scan.sh [image-name] [--severity high|critical] [--format json|table]
#===============================================================================

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="${1:-}"
SEVERITY_FILTER="${2:-medium}"
OUTPUT_FORMAT="${3:-table}"
SCAN_DATE=$(date '+%Y-%m-%d-%H%M%S')
REPORTS_DIR="$SCRIPT_DIR/security-reports"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Enhanced logging function
log() {
    local level=$1
    shift
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "ERROR")   echo -e "${RED}[ERROR] [$timestamp]${NC} $*" >&2 ;;
        "WARN")    echo -e "${YELLOW}[WARN]  [$timestamp]${NC} $*" ;;
        "INFO")    echo -e "${GREEN}[INFO]  [$timestamp]${NC} $*" ;;
        "DEBUG")   echo -e "${BLUE}[DEBUG] [$timestamp]${NC} $*" ;;
        *)         echo "[$timestamp] $*" ;;
    esac
}

# Display usage information
show_usage() {
    cat << EOF
Container Security Scanning Script

Usage: $0 [IMAGE_NAME] [OPTIONS]

Arguments:
    IMAGE_NAME                  Name of the container image to scan

Options:
    --severity LEVEL           Filter results by severity (low|medium|high|critical)
    --format FORMAT            Output format (json|table|sarif)
    --skip-trivy               Skip Trivy vulnerability scanning
    --skip-grype               Skip Grype vulnerability scanning  
    --skip-syft                Skip Syft SBOM generation
    --output-dir DIR           Custom output directory for reports
    --help                     Show this help message

Examples:
    $0 mkdocs:latest                           # Scan mkdocs image with default settings
    $0 webapp:v1.0 --severity critical        # Show only critical vulnerabilities
    $0 api:latest --format json --output-dir /tmp/scans
    
Supported Images:
    - docs-builder
    - mkdocs
    - video-producer-microservice
    - pptx-extractor-microservice  
    - tts-microservices
    - webhook
    - k8s-utilities
EOF
}

# Check for required security tools
check_security_tools() {
    log "INFO" "Checking security scanning tools..."
    
    local missing_tools=()
    local available_tools=()
    
    # Required tools
    for tool in docker; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        else
            available_tools+=("$tool")
        fi
    done
    
    # Optional security tools  
    for tool in trivy grype syft cosign docker-scout; do
        if command -v "$tool" &> /dev/null; then
            available_tools+=("$tool")
            log "DEBUG" "Found security tool: $tool"
        else
            log "WARN" "Optional security tool not found: $tool"
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log "ERROR" "Missing required tools: ${missing_tools[*]}"
        log "INFO" "Install missing tools:"
        for tool in "${missing_tools[@]}"; do
            case $tool in
                docker)
                    echo "  - Install Docker: https://docs.docker.com/get-docker/"
                    ;;
                trivy)
                    echo "  - Install Trivy: curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh"
                    ;;
                grype)
                    echo "  - Install Grype: curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh"
                    ;;
            esac
        done
        exit 1
    fi
    
    log "INFO" "Available security tools: ${available_tools[*]}"
    return 0
}

# Validate container image exists
validate_image() {
    local image="$1"
    
    log "INFO" "Validating container image: $image"
    
    if ! docker image inspect "$image" &> /dev/null; then
        log "ERROR" "Container image not found: $image"
        log "INFO" "Available images:"
        docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
        return 1
    fi
    
    # Get image details
    local image_id=$(docker image inspect "$image" --format '{{.Id}}')
    local image_size=$(docker image inspect "$image" --format '{{.Size}}' | numfmt --to=iec --suffix=B)
    local created_date=$(docker image inspect "$image" --format '{{.Created}}')
    
    log "INFO" "✅ Image validated: $image"
    log "DEBUG" "Image ID: ${image_id:7:12}"
    log "DEBUG" "Size: $image_size"
    log "DEBUG" "Created: $created_date"
    
    return 0
}

# Run Trivy security scan
run_trivy_scan() {
    local image="$1"
    local report_file="$REPORTS_DIR/trivy-$SCAN_DATE.json"
    
    if ! command -v trivy &> /dev/null; then
        log "WARN" "Trivy not available - skipping vulnerability scan"
        return 0
    fi
    
    log "INFO" "Running Trivy vulnerability scan..."
    
    # Ensure reports directory exists
    mkdir -p "$REPORTS_DIR"
    
    # Run Trivy scan with comprehensive options
    trivy image \
        --format json \
        --output "$report_file" \
        --severity "$SEVERITY_FILTER" \
        --no-progress \
        --quiet \
        "$image"
    
    if [[ $? -eq 0 ]]; then
        log "INFO" "✅ Trivy scan completed"
        
        # Extract key metrics
        local total_vulns=$(jq -r '[.Results[]?.Vulnerabilities[]?] | length' "$report_file" 2>/dev/null || echo "0")
        local critical_vulns=$(jq -r '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' "$report_file" 2>/dev/null || echo "0")
        local high_vulns=$(jq -r '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH")] | length' "$report_file" 2>/dev/null || echo "0")
        
        log "INFO" "Vulnerabilities found: Total=$total_vulns, Critical=$critical_vulns, High=$high_vulns"
        
        # Display summary if not using JSON format
        if [[ "$OUTPUT_FORMAT" == "table" ]]; then
            echo
            echo "🔍 Trivy Vulnerability Summary:"
            trivy image --format table --severity "$SEVERITY_FILTER" --no-progress "$image" | head -20
        fi
        
        echo "📊 Report saved: $report_file"
    else
        log "ERROR" "❌ Trivy scan failed"
        return 1
    fi
    
    return 0
}

# Run Grype vulnerability scan
run_grype_scan() {
    local image="$1" 
    local report_file="$REPORTS_DIR/grype-$SCAN_DATE.json"
    
    if ! command -v grype &> /dev/null; then
        log "WARN" "Grype not available - skipping additional vulnerability scan"
        return 0
    fi
    
    log "INFO" "Running Grype vulnerability scan..."
    
    mkdir -p "$REPORTS_DIR"
    
    # Run Grype scan
    grype "$image" \
        --output json \
        --file "$report_file" \
        --quiet
    
    if [[ $? -eq 0 ]]; then
        log "INFO" "✅ Grype scan completed"
        
        # Extract metrics
        local total_vulns=$(jq -r '.matches | length' "$report_file" 2>/dev/null || echo "0")
        local critical_vulns=$(jq -r '[.matches[] | select(.vulnerability.severity == "Critical")] | length' "$report_file" 2>/dev/null || echo "0")
        
        log "INFO" "Grype found: Total=$total_vulns vulnerabilities, Critical=$critical_vulns"
        echo "📊 Grype report saved: $report_file"
    else
        log "ERROR" "❌ Grype scan failed"
        return 1
    fi
    
    return 0
}

# Generate Software Bill of Materials (SBOM)
generate_sbom() {
    local image="$1"
    local sbom_file="$REPORTS_DIR/sbom-$SCAN_DATE.json"
    
    if ! command -v syft &> /dev/null; then
        log "WARN" "Syft not available - skipping SBOM generation"
        return 0
    fi
    
    log "INFO" "Generating Software Bill of Materials (SBOM)..."
    
    mkdir -p "$REPORTS_DIR"
    
    # Generate SBOM with Syft
    syft "$image" \
        --output json \
        --file "$sbom_file"
    
    if [[ $? -eq 0 ]]; then
        log "INFO" "✅ SBOM generation completed"
        
        # Extract package statistics
        local total_packages=$(jq -r '.artifacts | length' "$sbom_file" 2>/dev/null || echo "0")
        local languages=$(jq -r '[.artifacts[].language] | unique | join(", ")' "$sbom_file" 2>/dev/null || echo "unknown")
        
        log "INFO" "SBOM contains $total_packages packages"
        log "DEBUG" "Languages detected: $languages"
        echo "📊 SBOM saved: $sbom_file"
    else
        log "ERROR" "❌ SBOM generation failed"
        return 1
    fi
    
    return 0
}

# Check for secrets and sensitive data
scan_secrets() {
    local image="$1"
    
    log "INFO" "Scanning for secrets and sensitive data..."
    
    # Use Trivy's secret scanning capability
    if command -v trivy &> /dev/null; then
        local secrets_file="$REPORTS_DIR/secrets-$SCAN_DATE.json"
        
        trivy image \
            --scanners secret \
            --format json \
            --output "$secrets_file" \
            --quiet \
            "$image"
        
        if [[ $? -eq 0 ]]; then
            local secret_count=$(jq -r '[.Results[]?.Secrets[]?] | length' "$secrets_file" 2>/dev/null || echo "0")
            
            if [[ "$secret_count" -gt 0 ]]; then
                log "WARN" "⚠️  Found $secret_count potential secrets in image"
                echo "📊 Secrets report saved: $secrets_file"
            else
                log "INFO" "✅ No secrets detected"
            fi
        fi
    fi
    
    return 0
}

# Validate image signing and provenance
check_image_signing() {
    local image="$1"
    
    if ! command -v cosign &> /dev/null; then
        log "DEBUG" "Cosign not available - skipping signature verification"
        return 0
    fi
    
    log "INFO" "Checking image signatures..."
    
    # Verify image signature with Cosign
    if cosign verify "$image" &> /dev/null; then
        log "INFO" "✅ Image signature verified"
    else
        log "WARN" "⚠️  Image signature not found or invalid"
    fi
    
    return 0
}

# Generate comprehensive security report
generate_security_report() {
    local image="$1"
    local report_file="$REPORTS_DIR/security-summary-$SCAN_DATE.md"
    
    log "INFO" "Generating comprehensive security report..."
    
    cat > "$report_file" << EOF
# Container Security Report

**Image**: \`$image\`
**Scan Date**: $(date '+%Y-%m-%d %H:%M:%S UTC')
**Scanner Version**: $(trivy version 2>/dev/null | head -1 || echo "N/A")

## Executive Summary

$(if [[ -f "$REPORTS_DIR/trivy-$SCAN_DATE.json" ]]; then
    local total=$(jq -r '[.Results[]?.Vulnerabilities[]?] | length' "$REPORTS_DIR/trivy-$SCAN_DATE.json" 2>/dev/null || echo "0")
    local critical=$(jq -r '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' "$REPORTS_DIR/trivy-$SCAN_DATE.json" 2>/dev/null || echo "0")
    local high=$(jq -r '[.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH")] | length' "$REPORTS_DIR/trivy-$SCAN_DATE.json" 2>/dev/null || echo "0")
    
    echo "- **Total Vulnerabilities**: $total"
    echo "- **Critical Severity**: $critical"
    echo "- **High Severity**: $high"
fi)

## Risk Assessment

$(if [[ -f "$REPORTS_DIR/trivy-$SCAN_DATE.json" ]]; then
    local critical=$(jq -r '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL")] | length' "$REPORTS_DIR/trivy-$SCAN_DATE.json" 2>/dev/null || echo "0")
    
    if [[ "$critical" -gt 0 ]]; then
        echo "🔴 **HIGH RISK**: Critical vulnerabilities detected"
    elif [[ "$high" -gt 0 ]]; then
        echo "🟡 **MEDIUM RISK**: High severity vulnerabilities found"
    else
        echo "🟢 **LOW RISK**: No critical or high severity issues detected"
    fi
fi)

## Detailed Findings

### Vulnerability Analysis
$(if [[ -f "$REPORTS_DIR/trivy-$SCAN_DATE.json" ]]; then
    echo "- Trivy scan results: [trivy-$SCAN_DATE.json](./trivy-$SCAN_DATE.json)"
fi)
$(if [[ -f "$REPORTS_DIR/grype-$SCAN_DATE.json" ]]; then
    echo "- Grype scan results: [grype-$SCAN_DATE.json](./grype-$SCAN_DATE.json)"
fi)

### Software Bill of Materials
$(if [[ -f "$REPORTS_DIR/sbom-$SCAN_DATE.json" ]]; then
    local packages=$(jq -r '.artifacts | length' "$REPORTS_DIR/sbom-$SCAN_DATE.json" 2>/dev/null || echo "0")
    echo "- **Total Packages**: $packages"
    echo "- SBOM file: [sbom-$SCAN_DATE.json](./sbom-$SCAN_DATE.json)"
fi)

### Secret Detection
$(if [[ -f "$REPORTS_DIR/secrets-$SCAN_DATE.json" ]]; then
    local secrets=$(jq -r '[.Results[]?.Secrets[]?] | length' "$REPORTS_DIR/secrets-$SCAN_DATE.json" 2>/dev/null || echo "0")
    if [[ "$secrets" -gt 0 ]]; then
        echo "⚠️  **Potential secrets detected**: $secrets"
        echo "- Secrets report: [secrets-$SCAN_DATE.json](./secrets-$SCAN_DATE.json)"
    else
        echo "✅ No secrets detected"
    fi
fi)

## Recommendations

1. **Immediate Actions**:
   - Review and address all CRITICAL severity vulnerabilities
   - Validate any detected secrets and rotate if necessary
   - Update base images to latest security patches

2. **Medium-term Actions**:
   - Implement automated security scanning in CI/CD pipeline
   - Set up vulnerability monitoring and alerting
   - Establish image signing and verification process

3. **Long-term Actions**:
   - Regular security audits and penetration testing
   - Implement supply chain security measures
   - Container runtime security monitoring

## Compliance

- [ ] CIS Docker Benchmark compliance check
- [ ] NIST Cybersecurity Framework alignment
- [ ] SOC 2 Type II compliance validation

---
*Generated by 40docs Container Security Scanner*
EOF

    log "INFO" "✅ Security report generated: $report_file"
    echo "📋 Complete security report: $report_file"
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --severity)
                SEVERITY_FILTER="$2"
                shift 2
                ;;
            --format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            --output-dir)
                REPORTS_DIR="$2"
                shift 2
                ;;
            --help)
                show_usage
                exit 0
                ;;
            --*)
                log "WARN" "Unknown option: $1"
                shift
                ;;
            *)
                if [[ -z "$IMAGE_NAME" ]]; then
                    IMAGE_NAME="$1"
                fi
                shift
                ;;
        esac
    done
}

# Main execution function
main() {
    log "INFO" "Starting container security scan..."
    
    # Parse arguments
    parse_arguments "$@"
    
    # Validate input
    if [[ -z "$IMAGE_NAME" ]]; then
        log "ERROR" "Image name required"
        show_usage
        exit 1
    fi
    
    local start_time=$(date +%s)
    local scan_failed=false
    
    # Run security scans
    check_security_tools || exit 1
    validate_image "$IMAGE_NAME" || exit 1
    
    # Execute scans
    run_trivy_scan "$IMAGE_NAME" || scan_failed=true
    run_grype_scan "$IMAGE_NAME" || scan_failed=true
    generate_sbom "$IMAGE_NAME" || scan_failed=true
    scan_secrets "$IMAGE_NAME" || scan_failed=true
    check_image_signing "$IMAGE_NAME" || scan_failed=true
    
    # Generate report
    generate_security_report "$IMAGE_NAME"
    
    # Calculate execution time
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Summary
    log "INFO" "Security scan completed in ${duration}s"
    
    if [[ $scan_failed == true ]]; then
        log "WARN" "⚠️  Some security scans encountered issues"
        exit 1
    else
        log "INFO" "✅ All security scans completed successfully"
        exit 0
    fi
}

# Execute main function with all arguments
main "$@"