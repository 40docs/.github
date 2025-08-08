# 40Docs Platform

**Enterprise-Grade Documentation as Code Ecosystem**

The 40docs platform is a comprehensive multi-repository ecosystem that manages 25+ interconnected repositories through Git submodules and automation. It provides a secure, scalable infrastructure for documentation, security labs, and cloud-native applications using Azure Kubernetes Service (AKS) with GitOps workflows.

## 🚀 Quick Start

### Prerequisites

Before getting started, ensure you have the following tools installed:

- **Git** - Version control
- **GitHub CLI** (`gh`) - GitHub operations
- **Azure CLI** (`az`) - Azure resource management
- **Terraform** - Infrastructure as Code
- **kubectl** - Kubernetes cluster management
- **Bash** - Shell scripting (macOS system bash 3.2.57+ or modern Linux)

### 1. Authentication Setup

First, authenticate with both GitHub and Azure:

```bash
# Authenticate with GitHub CLI
gh auth login
# Follow the prompts to authenticate via web browser

# Authenticate with Azure CLI using device code
az login --use-device-code
# Follow the prompts to authenticate via web browser
```

### 2. Repository Setup

Clone the main repository and initialize all submodules:

```bash
# Clone the repository with all submodules
git clone --recurse-submodules https://github.com/40docs/.github.git ~/40docs

# Navigate to the project directory
cd ~/40docs

# Configure submodule branches (if needed)
git config -f .gitmodules submodule.infrastructure.branch main
git config -f .gitmodules submodule.dotfiles.branch main
git config -f .gitmodules submodule.hydration.branch main

# Sync and update all submodules
git submodule sync
git submodule update --init --recursive
```

### 3. Platform Initialization

Initialize the entire platform infrastructure:

```bash
# Navigate to the hydration directory
cd ~/40docs/hydration

# Run the infrastructure orchestration script
./install.sh
```

This script will:
- Generate SSH deploy keys for all repositories
- Configure GitHub secrets and variables
- Deploy Azure infrastructure via Terraform
- Set up Kubernetes cluster with GitOps (Flux)
- Configure certificate management and security monitoring

## 🏗️ Architecture Overview

### Multi-Repository Structure

The platform consists of specialized repositories, each serving specific functions:

```
40docs/
├── 🏠 Control Hub
│   └── .github/                    # Main orchestration repository (this one)
├── 📚 Content & Documentation
│   ├── references/                 # Technical reference documentation
│   ├── theme/                      # MkDocs theme and branding
│   ├── landing-page/               # Platform landing page
│   └── docs-*/                     # Domain-specific documentation
├── 🛠️ Infrastructure & DevOps
│   ├── infrastructure/             # Terraform infrastructure code
│   ├── manifests-infrastructure/   # Kubernetes infrastructure manifests
│   ├── manifests-applications/     # Application deployment manifests
│   ├── helm-charts/               # Custom Helm charts
│   └── hydration/                 # Platform orchestration scripts
├── 🔨 Build & Development
│   ├── docs-builder/              # Documentation build system
│   ├── mkdocs/                    # MkDocs configuration
│   ├── devcontainer-features/     # Development container features
│   └── devcontainer-templates/    # Development container templates
├── 🔒 Security & Labs
│   ├── lab-forticnapp-*/          # Security hands-on labs
│   ├── container-security-demo/   # Container security demonstrations
│   └── fortiweb-ingress/          # FortiWeb Kubernetes ingress controller
└── 🎥 Media & Specialized Services
    ├── video-*/                   # Video processing services
    ├── tts-microservices/         # Text-to-speech services
    └── pptx-extractor-*/          # PowerPoint processing services
```

### Infrastructure Architecture

- **Hub-Spoke Network**: Centralized FortiWeb Network Virtual Appliance (NVA) for security inspection
- **Azure Kubernetes Service**: Production AKS cluster with GitOps automation via Flux v2
- **Multi-Environment Support**: Development, staging, and production configurations
- **Security-First Design**: 
  - Lacework monitoring for runtime protection
  - cert-manager for automated TLS certificate provisioning
  - RBAC enabled with Azure AD integration
  - Network Security Groups with granular controls
- **Application-Specific Resources**: Each application gets dedicated public IP via FortiWeb VIP
- **DNS Integration**: Automatic CNAME record creation for application access

## 🛠️ Development Commands

### Build and Validation

```bash
# Azure Bicep validation (az-decompile/)
npm run validate:bicep           # Validate Bicep templates
npm run validate                 # Run all validations (lint + bicep)

# Markdown linting (az-decompile/)
npm run lint                     # Check markdown files
npm run lint:fix                 # Auto-fix markdown issues

# Terraform validation (infrastructure/)
cd infrastructure/
terraform fmt                    # Format Terraform files
terraform validate              # Validate syntax
terraform init -backend=false   # Initialize for local testing (no remote state)
```

### Platform Management

```bash
# Core infrastructure operations
cd hydration/
./install.sh                     # Initialize entire platform
./install.sh --initialize        # Explicit initialization
./install.sh --destroy           # Tear down environment
./install.sh --sync-forks        # Synchronize repository forks

# Advanced operations
./install.sh --deploy-keys       # Update SSH deploy keys
./install.sh --htpasswd          # Change documentation password
./install.sh --management-ip     # Update management IP
./install.sh --hub-passwd        # Change FortiWeb password
./install.sh --cloudshell-secrets # Update CloudShell secrets
```

### Kubernetes Operations

```bash
# Get AKS cluster credentials
az aks get-credentials --resource-group 40docs --name 40docs_k8s-cluster_eastus --overwrite-existing

# Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces

# GitOps operations with Flux
flux reconcile source git infrastructure
flux get all
```

## 🔧 Configuration

### Central Configuration

The platform is configured through `hydration/config.json`:

```json
{
  "REPOS": ["references"],
  "THEME_REPO_NAME": "theme",
  "LANDING_PAGE_REPO_NAME": "landing-page",
  "DOCS_BUILDER_REPO_NAME": "docs-builder",
  "INFRASTRUCTURE_REPO_NAME": "infrastructure",
  "MANIFESTS_INFRASTRUCTURE_REPO_NAME": "manifests-infrastructure",
  "MANIFESTS_APPLICATIONS_REPO_NAME": "manifests-applications",
  "MKDOCS_REPO_NAME": "mkdocs",
  "HELM_CHARTS_REPO_NAME": "helm-charts",
  "DEPLOYED": "true",
  "PROJECT_NAME": "40docs",
  "LOCATION": "eastus",
  "DNS_ZONE": "40docs.com",
  "CLOUDSHELL": "false"
}
```

### Key Applications

| Application | Purpose | Status | Namespace | Public URL |
|-------------|---------|--------|-----------|-----------|
| docs | Documentation hosting | ✅ Running | docs | docs.40docs.com |
| dvwa | Security testing | ✅ Running | dvwa | dvwa.40docs.com |
| extractor | Data processing | ✅ Running | extractor | extractor.40docs.com |
| ollama | AI/ML workloads | ⏸️ Disabled | N/A | N/A |
| artifacts | Build artifacts | ⏸️ Disabled | N/A | N/A |
| video | Media streaming | ⏸️ Disabled | N/A | N/A |

## 🔒 Security & Compliance

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

### Development Security
- Never commit API keys, tokens, or credentials to repositories
- All secrets are managed through GitHub Secrets and Azure Key Vault
- SSH deploy keys are automatically rotated
- Repository access is controlled through GitHub organization membership

## 📋 Important Guidelines

### Multi-Repository Considerations
- **Separate Repositories**: Each top-level folder is independent - avoid monorepo assumptions
- **Individual Commits**: Make changes and commit within the context of the correct sub-repository
- **No Cross-Repo Dependencies**: Avoid creating dependencies unless explicitly required
- **Repository-Specific Rules**: Follow sub-repository instructions when present

### Code Standards

#### Terraform (infrastructure/)
- **Variable Naming**: Always use `snake_case` (underscores), never `kebab-case` (hyphens)
- **Resource Naming**: Use underscores for consistency with Terraform conventions
- **Template Variables**: All cloud-init template variables use lowercase `snake_case`
- **Local Testing**: Use `terraform init -backend=false` for local validation
- **Provider Versions**: All providers have specific version constraints

#### Documentation
- Follow Markdown linting rules
- Use MkDocs Material theme conventions
- Include proper frontmatter for navigation
- Test locally before committing

## 🚨 Troubleshooting

### Authentication Issues
```bash
# Re-authenticate if tokens expire
gh auth login
az login --use-device-code

# Check current authentication status
gh auth status
az account show
```

### Infrastructure Issues
```bash
# Accept Azure Marketplace terms for FortiWeb
az vm image terms accept --urn "fortinet:fortinet_fortiweb-vm_v5:fortinet_fw-vm:latest"

# Check resource provider registration
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.Network
```

### GitOps Issues
```bash
# Check Flux status
kubectl get pods -n flux-system
flux reconcile source git infrastructure
flux get all --all-namespaces

# Force reconciliation
flux suspend source git infrastructure
flux resume source git infrastructure
```

### Common Exit Codes
- `0`: Success
- `1`: General failure
- `2`: Configuration error
- `3`: Authentication error
- `4`: Network error

### Known Issues
⚠️ **CRITICAL**: NVA deployment is NOT highly available - single point of failure exists
- Only one FortiWeb instance deployed
- Using availability sets instead of availability zones
- No load balancing or automated failover

## 🤝 Contributing

### Development Workflow
1. Fork the repository you want to contribute to
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes following the coding guidelines
4. Test your changes locally
5. Commit with a descriptive message
6. Push to your fork and create a pull request

### Auto-Approval Workflow
- Documentation-only PRs are auto-approved for repository owners
- Triggers on changes to `*.md`, `docs/`, and copilot instructions
- Waits for all status checks to pass before auto-merge

## 📞 Support

For support and questions:
- Review the `CLAUDE.md` file for Claude Code specific guidance
- Check existing issues in the relevant repository
- Create new issues with detailed descriptions and reproduction steps
- Use the appropriate repository for issue reporting

## 📄 License

This project is licensed under the terms specified in each individual repository. Please refer to the LICENSE file in the specific repository you're working with.

---

**Built with ❤️ by the 40docs team using Documentation as Code principles**

