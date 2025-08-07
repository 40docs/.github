# 40docs Platform - AI Coding Instructions

## Project Overview
40docs is an enterprise **Documentation as Code** platform orchestrating 25+ interconnected repositories through Git submodules. This workspace is a **multi-repository collection** where each top-level folder represents a separate GitHub repository, not a monorepo.

## Architecture & Patterns

### Repository Ecosystem Structure
The platform operates across three distinct layers:

**Core Control System (`hydration/`)**
- Master orchestration via `infrastructure.sh` (2,127 lines) with enterprise-grade automation
- Configuration-driven design through `config.json` controlling all system behavior
- Cross-platform bash compatibility (macOS 3.2.57+ to modern versions)
- Standardized error handling with visual logging symbols (❌ ⚠️ ✅ •)

**Infrastructure Layer (`infrastructure/`)**
- Hub-spoke Azure network topology with FortiWeb NVA for traffic inspection
- Terraform configurations using snake_case variables (never kebab-case)
- Flat file structure: `spoke-k8s_application-*.tf` pattern for app deployments
- Azure Kubernetes Service with GitOps deployment via Flux

**Content & Build System**
- Documentation repositories: `references/`, `theme/`, `landing-page/`
- Build automation: `docs-builder/`, `mkdocs/`, `helm-charts/`
- Security labs: `lab-forticnapp-*/`, `container-security-demo/`

### Critical Naming Conventions
```bash
# Repository secrets (GitHub Actions)
${REPO_NAME}_SSH_PRIVATE_KEY  # Uppercase, hyphens→underscores

# Azure resources
${PROJECT_NAME}-${purpose}    # e.g., "40docs-tfstate"

# DNS patterns
${service}.${DNS_ZONE}        # e.g., "docs.40docs.com"

# Terraform variables (CRITICAL)
var.variable_name             # snake_case ONLY, never kebab-case
```

## Developer Workflow

### Shell Compatibility (Critical)
**Always use explicit bash execution** when running complex CLI commands:
```bash
# For the hydration script (requires bash-specific features)
bash ./infrastructure.sh --initialize

# For complex command sequences in zsh environments
bash -c 'command1 && command2 | command3'
```

### Multi-Repository Operations Pattern
1. **Repository Arrays**: The hydration system builds different arrays for different purposes:
   ```bash
   CONTENTREPOS=()      # Content + theme + landing-page
   DEPLOYKEYSREPOS=()   # Repos needing SSH deploy keys
   PATREPOS=()          # Repos needing PAT access
   ALLREPOS=()          # All managed repositories
   ```

2. **Cross-Repository Access**: SSH deploy keys enable GitHub Actions to clone across repositories:
   ```yaml
   # Pattern used in GitHub Actions workflows
   - name: Clone Content Repos
     run: |
       echo '${{ secrets.REFERENCES_SSH_PRIVATE_KEY }}' > ~/.ssh/id_ed25519
       git clone git@github.com:${{ github.repository_owner }}/references.git
   ```

### Terraform Development Standards
```bash
# Local testing (never run plan/apply locally)
terraform fmt                    # Format before committing
terraform validate              # Syntax validation
terraform init -backend=false   # Local testing only

# Critical: Variables must use snake_case
var.cluster_name               # ✅ Correct
var.cluster-name               # ❌ Wrong - causes validation failures
```

## Integration Points

### Azure Integration Pattern
- **Service Principal**: Created with name `${PROJECT_NAME}`, assigned "User Access Administrator" role
- **Storage Naming**: Complex algorithm for 24-char limit: `echo "rmmuap{$PROJECT_NAME}account" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z' | cut -c 1-24`
- **GitHub Secrets**: ARM_* variables for Terraform authentication

### GitHub Actions Template System
- **Template-driven**: `docs-builder.yml.tpl` generates customized workflows per environment
- **SSH Key Injection**: Automated deploy key management across repositories
- **Container Builds**: Docker-based MkDocs builds with theme inheritance

### Kubernetes GitOps Architecture
- **Flux Configuration**: Hub-spoke model with infrastructure and applications repositories
- **Application Pattern**: Each app gets `spoke-k8s_application-*.tf` file
- **Security Integration**: Lacework agents, FortiWeb traffic inspection

## Project-Specific Conventions

### Environment Detection & Fork Handling
```bash
# Automatic GitHub organization detection
GITHUB_ORG=$(git config --get remote.origin.url | sed -n 's#.*/\([^/]*\)/.*#\1#p')
if [ "$GITHUB_ORG" != "$PROJECT_NAME" ]; then
  PROJECT_NAME="${GITHUB_ORG}-${PROJECT_NAME}"  # Prefix for forks
  DNS_ZONE="${GITHUB_ORG}.${DNS_ZONE}"
fi
```

### Retry & Error Handling Pattern
```bash
# Standardized retry logic used throughout hydration script
max_retries=3
for ((attempt=1; attempt<=max_retries; attempt++)); do
  if command; then break; fi
  if [[ $attempt -lt $max_retries ]]; then
    sleep $retry_interval
  fi
done
```

### Terraform File Organization Rules
- **Application Files**: `spoke-k8s_application-<name>.tf` for each deployed application
- **Network Files**: `hub-network.tf`, `spoke-network.tf` for topology
- **Infrastructure**: `spoke-k8s_infrastructure.tf` for GitOps configuration
- **No Deep Modules**: Prefer flat, readable structure over complex nesting

### Security & Validation Standards
- **Input Validation**: 8 specialized validation functions (emails, GitHub orgs, Azure resources)
- **Secure Operations**: All temporary files use restrictive permissions
- **Secret Management**: Never commit secrets; use GitHub secrets and Azure Key Vault
- **Markdown Compliance**: `markdownlint-cli2` validation across all documentation

## Key Operational Commands

### Hydration System Operations
```bash
bash ./infrastructure.sh --initialize    # Full system setup
bash ./infrastructure.sh --sync-forks    # Sync all repository forks
bash ./infrastructure.sh --deploy-keys   # Update SSH deploy keys
bash ./infrastructure.sh --destroy       # Tear down environment
```

### Multi-Repository Guidelines
- **Treat each top-level folder as a separate GitHub repository**
- **Never assume monorepo structure or single root .git**
- **Commit changes in context of correct sub-repository**
- **Use repository-specific instructions when present**

### DevContainer & AI Integration
- **Comprehensive DevContainer support** for consistent development environments
- **AI-powered development** with GitHub Copilot integration and specialized chat modes
- **Automated workflows** for testing, building, and deployment
- **Cross-platform compatibility** with macOS and Linux support

This platform represents a sophisticated "Documentation as Code" implementation with enterprise-grade automation, security, and scalability patterns suitable for large-scale organizational deployment.
