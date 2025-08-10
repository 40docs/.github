# 40docs Platform Summary

An enterprise-grade Documentation as Code ecosystem managing 25+ interconnected repositories through Git submodules and automation for cloud-native development, security analysis, and documentation.

## Core Repositories

**Infrastructure & Orchestration**
- **hydration**: Master orchestrator for GitHub/Azure authentication, SSH keys, secrets management, Terraform provisioning, and Kubernetes GitOps (Flux v2)
- **infrastructure**: Azure hub-spoke architecture with FortiWeb NVA, AKS deployment, cert-manager, and Lacework monitoring
- **manifests-infrastructure**: Kubernetes infrastructure manifests and GitOps configurations
- **manifests-applications**: Application deployment manifests and Helm charts

**Documentation Platform**
- **mkdocs**: Docker container system with Material theme, 40+ plugins, Playwright PDF generation, and multi-stage builds
- **docs-builder**: Automated Docker image creation for documentation websites with semantic versioning
- **theme**: Shared Material theme and styling components
- **references**: Technical documentation and reference materials

**Development Environment**
- **devcontainer-templates**: Ubuntu 22.04 with 75+ tools for cloud, security, and DevOps development
- **devcontainer-features**: 40+ custom DevContainer features for specialized development workflows
- **dotfiles**: Configuration files and development environment setup

**Security & Compliance**
- **pebcak**: FortiCNAPP OPAL educational lab with three-phase Policy as Code progression
- **docs-forticnapp-code-security**: Educational content for SCA, IaC, and SAST security practices
- **lab-forticnapp-code-security**: Hands-on security lab environments
- **container-security-demo**: Container security demonstration and testing

**Specialized Services**
- **video-as-code**, **video-producer-microservice**: Automated video content generation
- **tts-microservices**: Text-to-speech processing services
- **pptx-extractor-microservice**: PowerPoint content extraction and processing
- **webhook**: Event-driven automation and integration services

## Key Features

- **GitOps Automation**: Flux v2 continuous deployment with multi-repository orchestration
- **Security-First**: FortiWeb NVA, Lacework monitoring, RBAC, cert-manager automation
- **Documentation as Code**: Automated MkDocs builds with theme inheritance and PDF generation
- **Standardized Development**: DevContainer environments with 75+ tools and VSCode integration
- **AI-Powered Orchestration**: Claude Code orchestrator for multi-repository collaboration
- **Enterprise Infrastructure**: Azure hub-spoke architecture with Terraform IaC deployment

## Technology Stack

**Azure Cloud Platform** | **AKS + Flux v2 GitOps** | **FortiWeb NVA Security** | **MkDocs + Material Theme** | **Terraform IaC** | **DevContainers + VSCode**

Enterprise-ready Documentation as Code platform with robust security, automation, and AI-powered collaboration.