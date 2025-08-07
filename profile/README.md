# 40Docs 📚

> **Enterprise-Grade Documentation as Code Platform**

[![GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/40docs/.github)
[![Azure](https://img.shields.io/badge/Azure-Infrastructure-blue)](https://portal.azure.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-AKS-326ce5)](https://kubernetes.io/)

Welcome to **40Docs** - a comprehensive Documentation as Code ecosystem that demonstrates modern enterprise practices for managing documentation, infrastructure, and security at scale.

## 🎯 What We Do

**40Docs** showcases how organizations can implement **Documentation as Code** with full infrastructure automation, security-first design, and developer experience optimization.

### 🏗️ Platform Architecture

- **📚 Documentation as Code**: Version-controlled content with automated site generation
- **☁️ Cloud-Native Infrastructure**: Azure Kubernetes Service with hub-spoke network topology
- **🛡️ Security-First Design**: FortiWeb NVA, Lacework monitoring, zero-trust architecture
- **🔄 GitOps Workflows**: Automated deployments with Flux v2
- **🧑‍💻 Developer Experience**: Comprehensive DevContainer support and AI-powered development

## 🚀 Featured Projects

### Core Platform
- **[.github](https://github.com/40docs/.github)** - Central orchestration hub and platform documentation
- **[infrastructure](https://github.com/40docs/infrastructure)** - Terraform-based Azure infrastructure with AKS
- **[hydration](https://github.com/40docs/hydration)** - Master automation script for platform lifecycle management

### Documentation & Content
- **[references](https://github.com/40docs/references)** - Technical documentation and best practices
- **[theme](https://github.com/40docs/theme)** - Custom MkDocs themes with advanced features
- **[landing-page](https://github.com/40docs/landing-page)** - Marketing and navigation hub

### Security & Labs
- **[lab-forticnapp-code-security](https://github.com/40docs/lab-forticnapp-code-security)** - Hands-on security training with FortiCNAPP
- **[container-security-demo](https://github.com/40docs/container-security-demo)** - Container security best practices
- **[fortiweb-ingress](https://github.com/40docs/fortiweb-ingress)** - Kubernetes ingress controller for FortiWeb

### Developer Tools
- **[devcontainer-features](https://github.com/40docs/devcontainer-features)** - Reusable DevContainer features
- **[devcontainer-templates](https://github.com/40docs/devcontainer-templates)** - Complete development environment templates
- **[dotfiles](https://github.com/40docs/dotfiles)** - Consistent development environment configuration

## 📈 Key Statistics

- **25+ Repositories** - Complete ecosystem management
- **2,100+ Lines** - Enterprise-grade automation script
- **Multi-Cloud Ready** - Azure-native with extensible architecture
- **Security Focused** - Comprehensive scanning and monitoring
- **Production Ready** - High availability and scalability built-in

## 🛡️ Security & Compliance

- **🔒 Zero-Trust Architecture** - All traffic inspected through FortiWeb NVA
- **🔍 Continuous Monitoring** - Lacework security agent deployment
- **📜 Policy as Code** - Automated compliance and governance
- **🔐 Secrets Management** - Azure Key Vault and GitHub Secrets integration

## 🌟 Getting Started

### Quick Deploy
```bash
# Open in GitHub Codespaces (Recommended)
# Click the "Open in GitHub Codespaces" badge above

# Or clone locally
git clone --recurse-submodules https://github.com/40docs/.github.git ~/40docs
cd ~/40docs/hydration
./infrastructure.sh --initialize
```

### For Organizations
```bash
# Fork the entire ecosystem
gh repo fork 40docs/.github --clone
cd .github/hydration
# Edit config.json with your settings
./infrastructure.sh --initialize
```

## 🤝 Community & Learning

### 📚 Educational Resources
- **[Documentation as Code Guide](https://github.com/40docs/references)** - Complete implementation guide
- **[Security Best Practices](https://github.com/40docs/lab-forticnapp-code-security)** - Hands-on security labs
- **[Infrastructure Patterns](https://github.com/40docs/infrastructure)** - Terraform and Kubernetes patterns

### 🎓 Training Labs
- **Code Security Scanning** - SAST/DAST with FortiCNAPP
- **Container Security** - Runtime protection and vulnerability management
- **Infrastructure as Code** - Terraform best practices and automation

## 💡 Use Cases

- **Enterprise Documentation** - Scale documentation across multiple teams
- **DevOps Training** - Learn modern infrastructure and security practices  
- **Security Demonstrations** - Showcase security scanning and monitoring
- **Platform Engineering** - Reference architecture for developer platforms

## 🌐 Live Demos

Visit our deployed applications to see the platform in action:
- **Documentation Site** - Live MkDocs deployment with custom theming
- **Security Labs** - Interactive security training environments
- **Infrastructure Monitoring** - Real-time cluster and application monitoring

---

**Ready to transform your documentation workflow?** Explore our repositories and join the Documentation as Code revolution! 🚀

*Built with ❤️ by the 40Docs team - Empowering organizations with modern documentation practices*