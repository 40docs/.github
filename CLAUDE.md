# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the **40docs** platform - an enterprise-grade Documentation as Code ecosystem that manages 25+ interconnected repositories through Git submodules and automation. It's a multi-repository collection where each top-level folder represents a separate GitHub repository, not a monorepo structure.

## Common Development Commands

### Build and Validation Commands
```bash
# Azure Bicep validation (az-decompile/)
npm run validate:bicep           # Validate Bicep templates
npm run validate                 # Run all validations (lint + bicep)

# Markdown linting (az-decompile/)
npm run lint                     # Check markdown files
npm run lint:fix                 # Auto-fix markdown issues

# Terraform validation (infrastructure/)
terraform fmt                    # Format Terraform files
terraform validate              # Validate syntax (use init -backend=false for local testing)
terraform init -backend=false   # Initialize without backend for local testing

# Infrastructure orchestration (hydration/)
./infrastructure.sh              # Initialize entire platform
./infrastructure.sh --initialize # Explicit initialization
./infrastructure.sh --destroy    # Tear down environment
./infrastructure.sh --sync-forks # Synchronize repository forks
```

### Platform Management Commands
```bash
# Hydration system operations
./infrastructure.sh --deploy-keys      # Update SSH deploy keys
./infrastructure.sh --htpasswd         # Change documentation password
./infrastructure.sh --management-ip    # Update management IP
./infrastructure.sh --hub-passwd       # Change Fortiweb password
./infrastructure.sh --cloudshell-secrets # Update CloudShell secrets

# Kubernetes access (after deployment)
az aks get-credentials --resource-group 40docs --name 40docs_k8s-cluster_eastus --overwrite-existing
```

## Architecture and Repository Structure

### Multi-Repository Ecosystem
- **Control Hub**: This `.github` repository orchestrates the entire platform
- **Content Repositories**: `references/`, `theme/`, `landing-page/` for documentation
- **Infrastructure**: `infrastructure/`, `manifests-infrastructure/`, `manifests-applications/`
- **Build System**: `docs-builder/`, `mkdocs/`, `helm-charts/`
- **Security Labs**: `lab-forticnapp-*`, `container-security-demo/`
- **DevContainers**: `devcontainer-features/`, `devcontainer-templates/`
- **Specialized**: `az-decompile/`, `fortiweb-ingress/`, `video-*`, `tts-microservices/`

### Key Configuration Files
- `hydration/config.json`: Central configuration for entire platform
- `co-pilot.instructions.md`: Copilot guidance for multi-repo workspace
- Each subfolder has its own `.git` directory and should be treated as separate repository

### Infrastructure Architecture
- **Hub-Spoke Network**: Centralized FortiWeb NVA for security inspection
- **Azure Kubernetes Service**: Production AKS cluster with GitOps (Flux)
- **Multi-Environment**: Development/staging/production configurations
- **Security-First**: Lacework monitoring, cert-manager, RBAC enabled
- **Application-Specific Resources**: Each app gets dedicated public IP via FortiWeb VIP
- **DNS Integration**: Automatic CNAME record creation for application access

## Important Coding Guidelines

### Multi-Repository Considerations
- **Separate Repositories**: Each top-level folder is independent - don't assume monorepo structure
- **Individual Commits**: Make changes and commit in context of correct sub-repository
- **No Cross-Repo Dependencies**: Avoid creating dependencies unless explicitly instructed
- **Repository-Specific Rules**: Use sub-repo instructions when present

### Terraform Standards (infrastructure/)
- **Variable Naming**: Always use `snake_case` (underscores), never `kebab-case` (hyphens)
- **Resource Naming**: Use underscores for consistency with Terraform conventions
- **Template Variables**: All cloud-init template variables use lowercase `snake_case`
- **Local Testing**: Use `terraform init -backend=false` for local validation
- **Provider Versions**: All providers have specific version constraints (see terraform.tf:14-63)
- **Variable Validation**: Extensive input validation with regex patterns for IPs, subnets, and domains

### Security Best Practices
- **No Secrets in Code**: Never commit API keys, tokens, or credentials
- **Defensive Programming**: Validate inputs and handle errors gracefully
- **Secure Operations**: Use restrictive permissions (600/700) for temporary files
- **Repository Validation**: Check repository existence before setting secrets

## Platform Orchestration

### Hydration System
The `infrastructure.sh` script (2,100+ lines) is the master orchestrator that:
- Manages Azure service principals and storage accounts
- Generates SSH deploy keys for all repositories
- Configures GitHub secrets and variables across repositories
- Deploys complete Kubernetes infrastructure via Terraform
- Implements retry logic with exponential backoff
- Provides enhanced logging with visual symbols (❌ ⚠️ ✅ •)

### GitOps Workflow
- **Flux v2**: Automated application deployment and management
- **Multi-Repository Builds**: SSH key injection for secure cross-repo access
- **Container Builds**: MkDocs documentation builds with theme inheritance
- **Automated Deployments**: Terraform via GitHub Actions workflows

### Certificate Management
- **cert-manager**: Automated TLS certificate provisioning
- **Let's Encrypt**: Production and staging certificate issuers
- **Azure DNS**: DNS-01 challenge resolution
- **Workload Identity**: Secure Azure authentication

## Testing and Validation

### Local Development
- Never run `terraform plan/apply` locally - requires GitHub secrets
- Use `terraform init -backend=false` for syntax validation only
- Test changes in fork environment before submitting to main
- Validate all Markdown with markdownlint before committing

### CI/CD Pipeline
1. **Format/Lint**: Terraform fmt, markdownlint validation
2. **Security**: Lacework IaC scanning, dependency checks
3. **Deployment**: Automated infrastructure provisioning
4. **Verification**: Post-deployment health checks

### Auto-Approval Workflow
- Documentation-only PRs are auto-approved for repository owners
- Triggers on changes to `*.md`, `docs/`, and copilot instructions
- Waits for all status checks to pass before auto-merge

## Security and Compliance

### Network Security
- All traffic flows through FortiWeb NVA for inspection
- Hub-spoke topology with network segmentation
- Network Security Groups with granular controls
- Private endpoints for Azure services

### Kubernetes Security
- RBAC enabled with Azure AD integration
- Lacework agent for runtime protection and monitoring
- Network policies for pod-to-pod communication control
- Workload Identity for secure Azure service authentication

### Current Critical Issue
⚠️ **CRITICAL**: NVA deployment is NOT highly available - single point of failure exists
- Only one FortiWeb instance deployed
- Using availability sets instead of availability zones
- No load balancing or automated failover

## Key Applications

| Application | Purpose | Status | Namespace | Terraform File |
|-------------|---------|--------|-----------|----------------|
| docs | Documentation hosting | ✅ Running | docs | spoke-k8s_application-docs.tf |
| dvwa | Security testing | ✅ Running | dvwa | spoke-k8s_application-dvwa.tf |
| extractor | Data processing | ✅ Running | extractor | spoke-k8s_application-extractor.tf |
| ollama | AI/ML workloads | ⏸️ Disabled | N/A | spoke-k8s_application-ollama.tf |
| artifacts | Build artifacts | ⏸️ Disabled | N/A | spoke-k8s_application-artifacts.tf |
| video | Media streaming | ⏸️ Disabled | N/A | spoke-k8s_application-video.tf |

## Troubleshooting

### Authentication Issues
```bash
gh auth login                    # Re-authenticate GitHub CLI
az login --use-device-code      # Re-authenticate Azure CLI
```

### Infrastructure Issues
```bash
# Accept marketplace terms for FortiWeb
az vm image terms accept --urn "fortinet:fortinet_fortiweb-vm_v5:fortinet_fw-vm:latest"

# Check resource provider registration
az provider register --namespace Microsoft.ContainerService
```

### GitOps Issues
```bash
# Check Flux status
kubectl get pods -n flux-system
flux reconcile source git infrastructure
```

### Common Exit Codes
- `0`: Success
- `1`: General failure  
- `2`: Configuration error
- `3`: Authentication error
- `4`: Network error

## Additional Notes

- **Bash Compatibility**: Scripts work with macOS system bash (3.2.57) and modern versions
- **Cross-Platform**: Supports both macOS and Linux development environments
- **Enhanced Logging**: Visual symbols for different message types improve readability
- **Retry Logic**: Standardized retry patterns with exponential backoff throughout
- **Input Validation**: Comprehensive validation for emails, GitHub orgs, Azure resources, DNS zones