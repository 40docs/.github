# GitHub Copilot Instructions

## Workspace: 40docs (Multi-Repository Collection)
This workspace is a collection of many independent GitHub repositories, each in its own subfolder. It is not a monorepo, but a filesystem containing multiple, separately managed git repositories.

### Copilot Guidance for This Workspace
- When iterating or searching, treat each top-level folder as a separate GitHub repository.
- Do not assume a single root `.git` or monorepo structure.
- When making code modifications, ensure changes are committed and pushed in the context of the correct sub-repository.
- When generating or updating `.github/co-pilot.instructions.md` files, place them in the `.github` folder of each sub-repo, not the workspace root.
- When automating tasks (e.g., code scanning, refactoring, or documentation), operate recursively but commit changes per-repo.
- Do not create cross-repo dependencies unless explicitly instructed.

### Coding Standards
- Respect the language, framework, and conventions of each sub-repo.
- Use repository-specific instructions if present; otherwise, fall back to general best practices.

### Special Instructions
- Do not assume global configuration applies to all sub-repos.
- When in doubt, prompt for clarification on which repository or folder to target.
