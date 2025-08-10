# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the **manifests-infrastructure** repository within the 40docs platform ecosystem. It contains Kubernetes infrastructure manifests managed via GitOps with Flux v2.

### Infrastructure Components

This repository manages the core infrastructure layer for the 40docs Kubernetes platform:

- **Certificate Management**: cert-manager with Azure DNS integration for automated TLS certificates
- **Ingress Control**: FortiWeb Kubernetes ingress controller for security-focused traffic routing
- **Security Monitoring**: Lacework DaemonSet for runtime security and compliance monitoring
- **Configuration Management**: Reloader for automatic config/secret updates
- **Ingress Helper**: Supporting ingress configuration utilities
- **GPU Operations**: NVIDIA GPU operator for ML/AI workloads (optional)
- **cFOS Integration**: Container-based FortiOS networking (optional)

All components use Flux v2 HelmRelease resources with targeted namespaces and system node scheduling.

## Common Development Commands

### Kubernetes Manifest Validation
```bash
# Validate Kubernetes manifests
kubectl apply --dry-run=client -k .

# Validate individual components
kubectl apply --dry-run=client -k ./cert-manager
kubectl apply --dry-run=client -k ./fortiweb-ingress
kubectl apply --dry-run=client -k ./lacework

# Check Kustomize build output
kustomize build .
kustomize build ./cert-manager
```

### GitOps Deployment Commands
```bash
# These commands are typically run by Flux, but useful for troubleshooting

# Check Flux status
flux get all
flux get helmreleases -A

# Force reconciliation
flux reconcile source git infrastructure
flux reconcile helmrelease cert-manager -n cluster-config
flux reconcile helmrelease fortiweb-ingress-controller -n cluster-config

# Suspend/resume deployments
flux suspend hr cert-manager -n cluster-config
flux resume hr cert-manager -n cluster-config
```

### Infrastructure Status Commands
```bash
# Check deployed infrastructure components
kubectl get pods -n cert-manager
kubectl get pods -n fortiweb-ingress  
kubectl get pods -n lacework-agent

# Check Helm releases
helm list -A | grep -E "(cert-manager|fortiweb|reloader)"

# Validate certificates
kubectl get certificates -A
kubectl describe certificate <cert-name> -n <namespace>
```

## Architecture and Component Structure

### GitOps Deployment Pattern
- **Kustomize Base**: Root kustomization.yaml orchestrates all infrastructure components  
- **Flux HelmReleases**: Each component uses Flux v2 HelmRelease for automated deployment
- **Namespace Strategy**: Components deploy to dedicated namespaces (cert-manager, fortiweb-ingress, lacework-agent)
- **Node Targeting**: All components use node selectors and tolerations for system pool scheduling

### Key Configuration Patterns

#### HelmRelease Structure
```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: component-name
  namespace: cluster-config
spec:
  targetNamespace: component-namespace  # Where component actually runs
  chart:
    spec:
      chart: helm-chart-name
      version: "x.y.z"              # Pinned versions for stability
      sourceRef:
        kind: HelmRepository
        name: repository-name
  values:
    # System pool scheduling (standard pattern)
    tolerations:
      - key: "CriticalAddonsOnly"
        operator: "Equal" 
        value: "true"
        effect: "NoSchedule"
    nodeSelector:
      system-pool: "true"
```

#### Security Configurations
- **cert-manager**: Uses Azure Workload Identity for DNS-01 challenges
- **Lacework**: Privileged DaemonSet with extensive host mounts for security monitoring
- **FortiWeb**: Ingress controller with security-focused traffic inspection

## Infrastructure Components

### Core Services
| Component | Purpose | Namespace | Chart Version |
|-----------|---------|-----------|---------------|
| cert-manager | TLS certificate automation | cert-manager | 1.16.1 |
| fortiweb-ingress | Security-focused ingress | fortiweb-ingress | 2.0.1 |
| lacework | Runtime security monitoring | lacework-agent | Latest |
| reloader | Config/secret auto-reload | default | Latest |
| ingress-helper | Ingress utilities | default | Latest |

### Optional Components  
| Component | Purpose | Status | Notes |
|-----------|---------|--------|-------|
| gpu-operator | NVIDIA GPU support | Available | For ML/AI workloads |
| cfos | Container FortiOS | Available | Advanced networking |

## Important Guidelines

### Manifest Standards
- **YAML Best Practices**: Use proper indentation, consistent formatting, and meaningful names
- **Version Pinning**: Always specify explicit chart versions in HelmRelease resources
- **Resource Limits**: Include resource requests/limits for production workloads
- **Security Context**: Apply appropriate security contexts and avoid privileged containers when possible
- **Documentation**: Comment complex configurations and include references to upstream docs

### System Pool Targeting
All infrastructure components should use consistent node scheduling patterns:
```yaml
tolerations:
  - key: "CriticalAddonsOnly"
    operator: "Equal"
    value: "true" 
    effect: "NoSchedule"
nodeSelector:
  system-pool: "true"
```

### Secret Management
- **Never commit secrets**: Use Flux's secret management or external secret operators
- **Reference sealed secrets**: Use SealedSecrets or External Secrets Operator for sensitive data
- **Azure Integration**: Leverage Azure Workload Identity where possible

## Troubleshooting

### Common Issues

#### Certificate Problems
```bash
# Check certificate status
kubectl get certificates -A
kubectl describe certificate <name> -n <namespace>

# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager

# Force certificate renewal
kubectl annotate certificate <name> -n <namespace> cert-manager.io/issue-temporary-certificate=true
```

#### Ingress Controller Issues
```bash
# Check FortiWeb ingress controller
kubectl get pods -n fortiweb-ingress
kubectl logs -n fortiweb-ingress deployment/fortiweb-ingress-controller

# Validate ingress configurations
kubectl get ingress -A
kubectl describe ingress <name> -n <namespace>
```

#### Flux Reconciliation Problems
```bash
# Check Flux source status
flux get sources git

# Check HelmRelease status
flux get helmreleases -A

# Debug failed reconciliation
kubectl describe helmrelease <name> -n cluster-config
```

#### Lacework Agent Issues
```bash
# Check DaemonSet status
kubectl get ds lacework -n lacework-agent

# View agent logs
kubectl logs -n lacework-agent ds/lacework

# Verify secret configuration
kubectl get secret lacework-agent-token -n lacework-agent -o yaml
```

## Development Best Practices

### Testing Changes
```bash
# Test manifest syntax before committing
kubectl apply --dry-run=client -k .

# Test individual component changes
kubectl apply --dry-run=client -f ./cert-manager/HelmRelease.yaml

# Validate Kustomize output
kustomize build . | kubectl apply --dry-run=client -f -
```

### Version Management
- Always pin specific chart versions in HelmRelease resources
- Update versions incrementally and test in development environment first
- Monitor for security updates in upstream Helm charts
- Document version upgrade reasons in commit messages

### GitOps Integration
This repository is managed by Flux v2 GitOps. Changes pushed to the main branch are automatically applied to the cluster:
- **Source Controller**: Monitors this Git repository for changes
- **Helm Controller**: Manages HelmRelease resources and chart installations
- **Kustomize Controller**: Applies Kustomized manifests

### Security Considerations
- All infrastructure components run on system node pool with appropriate tolerations
- Lacework DaemonSet requires privileged access for security monitoring
- cert-manager uses Azure Workload Identity for DNS challenge authentication
- FortiWeb provides ingress-level security inspection
