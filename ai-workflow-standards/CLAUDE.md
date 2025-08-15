# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the **ai-workflow-standards** repository within the 40docs platform ecosystem. It defines standardized AI development workflows, best practices, and guidelines for AI-assisted software development across the entire 40docs platform.

## Repository Purpose

The ai-workflow-standards repository serves as:
- **AI Development Standards**: Defines best practices for AI-assisted development workflows
- **Claude Integration Guidelines**: Standards for Claude Code usage across all 40docs repositories
- **Workflow Templates**: Reusable AI workflow patterns for common development tasks
- **Quality Assurance**: AI-driven code review and quality checking standards
- **Documentation Standards**: AI-assisted documentation generation guidelines

## Repository Structure

```
ai-workflow-standards/
├── workflows/              # Standardized AI workflow definitions
├── templates/             # Reusable workflow templates
├── guidelines/            # Best practice guidelines
├── examples/              # Example implementations
└── scripts/               # Automation scripts for AI workflows
```

## Common Development Commands

### Workflow Validation
```bash
# Validate workflow definitions
./scripts/validate-workflows.sh

# Test workflow templates
./scripts/test-templates.sh

# Check guideline compliance
./scripts/check-compliance.sh
```

### Documentation Generation
```bash
# Generate workflow documentation
./scripts/generate-docs.sh

# Update example implementations
./scripts/update-examples.sh
```

## Integration with 40docs Platform

### Multi-Repository Coordination
This repository provides standards that are applied across all 40docs submodules:
- Infrastructure repositories follow AI-assisted Terraform development workflows
- Documentation repositories use AI-driven content generation standards
- Application repositories implement AI code review processes

### Claude Orchestrator Integration
When used with the 40docs Claude orchestrator system:
- Standards are automatically applied to all sub-instances
- Workflow templates are accessible from any repository context
- Guidelines are enforced during multi-repository operations

## AI Workflow Standards

### Code Development Workflows
- **Feature Implementation**: Structured approach for AI-assisted feature development
- **Bug Fixing**: Systematic AI-driven debugging and resolution
- **Refactoring**: AI-guided code improvement and optimization
- **Testing**: AI-generated test cases and validation

### Documentation Workflows
- **API Documentation**: Automated API documentation generation
- **User Guides**: AI-assisted user documentation creation
- **Technical Specifications**: AI-driven technical documentation
- **Change Logs**: Automated change log generation from commits

### Review and Quality Workflows
- **Code Review**: AI-powered code review checklists
- **Security Review**: AI-assisted security vulnerability detection
- **Performance Analysis**: AI-driven performance optimization
- **Compliance Checking**: Automated compliance verification

## Best Practices

### AI-Assisted Development
- Always validate AI-generated code before committing
- Use AI for initial implementation, human review for critical logic
- Maintain clear separation between AI-generated and human-written code
- Document AI assistance in commit messages when significant

### Workflow Implementation
- Start with template workflows and customize as needed
- Validate workflows in development environment before production use
- Maintain version control for all workflow definitions
- Document workflow modifications and rationale

### Quality Assurance
- Implement automated testing for AI-generated code
- Use multiple AI review passes for critical components
- Maintain human oversight for security-critical code
- Regular audits of AI-assisted development patterns

## Common Patterns

### Multi-Repository Workflow Pattern
```bash
# Apply standardized workflow across multiple repositories
for repo in $(cat repos.txt); do
    ./scripts/apply-workflow.sh "$repo" "feature-implementation"
done
```

### AI Review Pipeline
```bash
# Run comprehensive AI review
./scripts/ai-review.sh --security --performance --quality --compliance
```

### Documentation Generation Pipeline
```bash
# Generate complete documentation suite
./scripts/generate-all-docs.sh --api --user --technical --changelog
```

## Integration Points

### GitHub Actions
- Workflow templates integrate with GitHub Actions
- Automated workflow execution on PR creation
- AI review comments posted directly to PRs

### Claude Code
- Standards designed for Claude Code integration
- Optimized for Claude's context window and capabilities
- Leverages Claude's multi-file understanding

### 40docs Infrastructure
- Workflows compatible with Terraform automation
- Integration with Kubernetes deployment pipelines
- Support for Azure cloud resources

## Troubleshooting

### Workflow Issues
```bash
# Debug workflow execution
./scripts/debug-workflow.sh <workflow-name>

# Validate workflow syntax
./scripts/validate-syntax.sh <workflow-file>
```

### Integration Issues
```bash
# Test Claude integration
./scripts/test-claude-integration.sh

# Verify GitHub Actions compatibility
./scripts/verify-actions.sh
```

## Security Considerations

- Never include credentials or secrets in workflow definitions
- AI-generated code must pass security scanning before deployment
- Maintain audit logs of all AI-assisted operations
- Regular security reviews of workflow templates

## Contributing

### Adding New Workflows
1. Create workflow definition in `workflows/`
2. Add corresponding template in `templates/`
3. Document in `guidelines/`
4. Provide example in `examples/`
5. Update validation scripts

### Modifying Standards
1. Propose changes via pull request
2. Include rationale and impact analysis
3. Update all affected templates and examples
4. Ensure backward compatibility where possible

## Notes

- This repository is part of the 40docs multi-repository ecosystem
- Standards defined here apply to all 40docs submodules
- Regular updates based on AI technology improvements
- Coordination with platform-wide orchestrator system