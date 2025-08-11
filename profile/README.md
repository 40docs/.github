# 40Docs Platform 📚

> **Enterprise-Grade Documentation as Code Ecosystem**

[![GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/40docs/.github)
[![Azure](https://img.shields.io/badge/Azure-Infrastructure-blue)](https://portal.azure.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-AKS-326ce5)](https://kubernetes.io/)
[![GitOps](https://img.shields.io/badge/GitOps-Flux_v2-purple)](https://fluxcd.io/)

The **40docs platform** is a comprehensive multi-repository ecosystem that manages 25+ interconnected repositories through Git submodules and automation. It provides a secure, scalable infrastructure for documentation, security labs, and cloud-native applications using Azure Kubernetes Service (AKS) with GitOps workflows.

## 🎯 What We Do

**40Docs** demonstrates how organizations can implement **Documentation as Code** with full infrastructure automation, security-first design, and developer experience optimization at enterprise scale.

### 🏗️ Platform Architecture

- **📚 Documentation as Code**: Version-controlled content with automated MkDocs builds, theme inheritance, and PDF generation
- **☁️ Cloud-Native Infrastructure**: Azure hub-spoke network with FortiWeb NVA and AKS cluster
- **🛡️ Security-First Design**: Zero-trust architecture with Lacework monitoring and cert-manager automation
- **🔄 GitOps Workflows**: Flux v2 continuous deployment with multi-repository orchestration
- **🧑‍💻 Developer Experience**: Comprehensive DevContainer support with 75+ tools and AI-powered collaboration
- **⚡ AI-Powered Orchestration**: Claude Code orchestrator for intelligent multi-repository management

## 🚀 Core Repositories

### Infrastructure & Orchestration
- **[hydration](https://github.com/40docs/hydration)** - Master orchestrator for GitHub/Azure authentication, SSH keys, secrets management, Terraform provisioning, and Kubernetes GitOps
- **[infrastructure](https://github.com/40docs/infrastructure)** - Azure hub-spoke architecture with FortiWeb NVA, AKS deployment, cert-manager, and Lacework monitoring
- **[manifests-infrastructure](https://github.com/40docs/manifests-infrastructure)** - Kubernetes infrastructure manifests and GitOps configurations
- **[manifests-applications](https://github.com/40docs/manifests-applications)** - Application deployment manifests and Helm charts

### Documentation Platform
- **[mkdocs](https://github.com/40docs/mkdocs)** - Docker container system with Material theme, 40+ plugins, and Playwright PDF generation
- **[docs-builder](https://github.com/40docs/docs-builder)** - Automated Docker image creation for documentation websites with semantic versioning
- **[theme](https://github.com/40docs/theme)** - Shared Material theme and styling components with advanced features
- **[references](https://github.com/40docs/references)** - Technical documentation and reference materials
- **[landing-page](https://github.com/40docs/landing-page)** - Marketing and navigation hub

### Development Environment
- **[devcontainer-templates](https://github.com/40docs/devcontainer-templates)** - Ubuntu 22.04 with 75+ tools for cloud, security, and DevOps development
- **[devcontainer-features](https://github.com/40docs/devcontainer-features)** - 40+ custom DevContainer features for specialized development workflows
- **[dotfiles](https://github.com/40docs/dotfiles)** - Configuration files and development environment setup

### Security & Labs
- **[pebcak](https://github.com/40docs/pebcak)** - FortiCNAPP OPAL educational lab with three-phase Policy as Code progression
- **[docs-forticnapp-code-security](https://github.com/40docs/docs-forticnapp-code-security)** - Educational content for SCA, IaC, and SAST security practices
- **[lab-forticnapp-code-security](https://github.com/40docs/lab-forticnapp-code-security)** - Hands-on security lab environments
- **[container-security-demo](https://github.com/40docs/container-security-demo)** - Container security demonstration and testing
- **[fortiweb-ingress](https://github.com/40docs/fortiweb-ingress)** - Kubernetes ingress controller for FortiWeb

### Specialized Services
- **[video-as-code](https://github.com/40docs/video-as-code)** & **[video-producer-microservice](https://github.com/40docs/video-producer-microservice)** - Automated video content generation
- **[tts-microservices](https://github.com/40docs/tts-microservices)** - Text-to-speech processing services
- **[pptx-extractor-microservice](https://github.com/40docs/pptx-extractor-microservice)** - PowerPoint content extraction and processing
- **[webhook](https://github.com/40docs/webhook)** - Event-driven automation and integration services

## 📈 Key Statistics

- **25+ Repositories** - Complete ecosystem management with Git submodules
- **2,100+ Lines** - Enterprise-grade automation in hydration orchestrator
- **75+ Development Tools** - Comprehensive DevContainer environment
- **40+ MkDocs Plugins** - Advanced documentation generation capabilities
- **Multi-Cloud Ready** - Azure-native with extensible architecture
- **Production Ready** - High availability and scalability built-in

## 🛡️ Security & Compliance

- **🔒 Zero-Trust Architecture** - All traffic inspected through FortiWeb NVA with hub-spoke topology
- **🔍 Continuous Monitoring** - Lacework security agent deployment and runtime protection
- **📜 Policy as Code** - Automated compliance and governance with FortiCNAPP OPAL
- **🔐 Secrets Management** - Azure Key Vault and GitHub Secrets integration with automated rotation
- **🛠️ RBAC Integration** - Azure AD authentication with Kubernetes RBAC
- **📋 Certificate Automation** - cert-manager with Let's Encrypt integration

## 🌟 Getting Started

### Quick Deploy (Recommended)
```bash
# Open in GitHub Codespaces - includes all tools and authentication
# Click the "Open in GitHub Codespaces" badge above

# Or clone and initialize locally
git clone --recurse-submodules https://github.com/40docs/.github.git ~/40docs
cd ~/40docs

# Authenticate with GitHub and Azure
gh auth login
az login --use-device-code

# Initialize the entire platform
cd hydration && ./install.sh --initialize
```

### For Organizations
```bash
# Fork the entire ecosystem
gh repo fork 40docs/.github --clone
cd .github/hydration

# Edit config.json with your organization settings
# Configure DNS zone, project name, and repository list
./install.sh --initialize
```

## 🔧 Live Applications

Visit our deployed applications to see the platform in action:

| Application | Purpose | Status | Public URL |
|-------------|---------|--------|-----------|
| **Documentation** | Live MkDocs deployment with custom theming | ✅ Running | docs.40docs.com |
| **Security Labs** | Interactive DVWA security environment | ✅ Running | dvwa.40docs.com |
| **Data Processing** | PowerPoint extraction microservice | ✅ Running | extractor.40docs.com |
| **AI/ML Workloads** | Ollama language models | ⏸️ Available | N/A |
| **Build Artifacts** | CI/CD artifact storage | ⏸️ Available | N/A |
| **Media Streaming** | Video processing services | ⏸️ Available | N/A |

## 💡 Use Cases & Learning

### 🎓 Enterprise Applications
- **Documentation as Code** - Scale documentation across multiple teams and repositories
- **Platform Engineering** - Reference architecture for developer platforms and self-service infrastructure
- **Security Operations** - Comprehensive scanning, monitoring, and vulnerability management
- **GitOps Implementation** - Modern continuous deployment with Flux v2 and Kubernetes

### 📚 Educational Resources
- **[Infrastructure Patterns](https://github.com/40docs/infrastructure)** - Terraform and Kubernetes best practices with Azure integration
- **[Security Best Practices](https://github.com/40docs/lab-forticnapp-code-security)** - Hands-on security labs with FortiCNAPP
- **[Documentation Guide](https://github.com/40docs/references)** - Complete Documentation as Code implementation guide
- **[DevOps Workflows](https://github.com/40docs/hydration)** - Multi-repository automation and orchestration patterns

### 🔬 Training Labs
- **Code Security Scanning** - SAST/DAST with FortiCNAPP integration and Policy as Code
- **Container Security** - Runtime protection, vulnerability management, and compliance
- **Infrastructure as Code** - Terraform automation, Azure best practices, and GitOps workflows
- **Documentation Automation** - MkDocs theming, PDF generation, and multi-repository builds

## 🌐 Technology Stack

**Azure Cloud Platform** | **AKS + Flux v2 GitOps** | **FortiWeb NVA Security** | **MkDocs + Material Theme** | **Terraform IaC** | **DevContainers + VSCode** | **Claude Code AI**

## 🤝 Community & Contributing

### Development Workflow
1. **Fork** the repository you want to contribute to
2. **Create** a feature branch following naming conventions
3. **Develop** using provided DevContainer environments
4. **Test** your changes locally with validation scripts
5. **Submit** pull request with detailed description

### Auto-Approval Features
- Documentation-only PRs are auto-approved for repository owners
- Comprehensive CI/CD with Terraform validation, security scanning, and automated testing
- GitOps deployment with automatic rollback on failures

---

**Ready to revolutionize your documentation and infrastructure workflow?** 

🚀 **[Get Started Now](https://github.com/40docs/.github)** | 📚 **[View Documentation](https://docs.40docs.com)** | 🔒 **[Try Security Labs](https://dvwa.40docs.com)**

*Built with ❤️ by the 40docs team - Empowering organizations with enterprise-grade Documentation as Code practices and AI-powered development workflows*