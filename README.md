# Agronod .github Repository

This special `.github` repository serves multiple purposes for the Agronod organization:

1. **Organization Profile**: Contains the public-facing README displayed on [github.com/agronod](https://github.com/agronod)
2. **Default Community Health Files**: Provides fallback templates and guidelines for all Agronod repositories
3. **Reusable Workflows**: Standardized GitHub Actions workflows for CI/CD pipelines across all repositories

## Overview

This internal repository helps maintain consistency across Agronod's development practices. It acts as a centralized configuration point, providing default community health files that apply to all repositories unless overridden, as well as reusable GitHub Actions workflows for standardized CI/CD processes.

### How the Fallback Mechanism Works

Files in this `.github` repository serve as defaults for all Agronod repositories. If a repository doesn't have its own `.github` directory with specific files, it will use the templates from this repository. For example:
- If a repository lacks issue templates, it will use the ones defined here
- Repositories with their own `.github/ISSUE_TEMPLATE/` will override these defaults
- This ensures consistency while allowing repository-specific customization

### Supported Technologies

- **Node.js** (default: v20.15.0)
- **Python** (default: v3.10)
- **.NET** (configurable version)
- **Go** (configurable version)

### Key Features

- 🔄 **Reusable Workflows**: Modular design for easy integration
- 📦 **Semantic Versioning**: Automated version management with conventional commits
- 🐳 **Container Support**: Docker image building and registry management
- 🚀 **Release Automation**: GitHub release creation with changelogs
- 🔒 **Security First**: Minimal permissions and secure secret handling
- 📊 **Multi-Platform**: Support for different deployment targets

## Repository Structure

### Organization Profile
- `profile/README.md` - The README displayed on Agronod's GitHub organization page

### Community Health Files (Potential)
This repository can contain default community health files that act as fallbacks for all Agronod repositories:
- `ISSUE_TEMPLATE/` - Default issue templates
- `PULL_REQUEST_TEMPLATE.md` - Default PR template
- `CODE_OF_CONDUCT.md` - Organization-wide code of conduct
- `CONTRIBUTING.md` - Default contribution guidelines
- `FUNDING.yml` - Sponsorship information

*Note: When added, these files will apply to all repositories that don't have their own `.github/` directory with these files.*

### Reusable Workflows
- `.github/workflows/` - Centralized CI/CD workflows used across Agronod repositories

### Documentation
- `ai-docs/` - Technical documentation for workflow development and AI-assisted contributions

## Using Reusable Workflows

To use these workflows in an Agronod repository, reference them in your workflow files:

```yaml
name: CI

on:
  push:
    branches: [main]

jobs:
  ci:
    uses: agronod/.github/.github/workflows/node-ci.yml@main
    with:
      node-version: "20.15.0"
      application-name: "my-app"
      application-folder: "deployments/my-app"
    secrets:
      github-user: ${{ secrets.GITHUB_USER }}
      github-token: ${{ secrets.GITHUB_TOKEN }}
      registry-username: ${{ secrets.REGISTRY_USERNAME }}
      registry-password: ${{ secrets.REGISTRY_PASSWORD }}
```

## Contributing

This is an internal Agronod repository. All team members are encouraged to contribute improvements to our workflows and documentation.

### Before You Start

1. **Read the Documentation**: Check the `ai-docs/` folder for detailed patterns and guidelines
2. **Review Existing Workflows**: Understand current patterns before proposing changes
3. **Coordinate with Team**: Check with the development team if someone is already working on similar changes

### Development Process

1. **Clone the Repository**
   ```bash
   git clone https://github.com/agronod/.github.git
   cd .github
   ```

2. **Create a Feature Branch**
   ```bash
   git checkout -b feat/your-feature-name
   ```

3. **Follow Our Conventions**
   - Use semantic commit messages (`feat:`, `fix:`, `docs:`)
   - Follow established naming patterns (see `ai-docs/PATTERNS.md`)
   - Test your changes with pull requests
   - Update relevant documentation in `ai-docs/`

4. **Submit a Pull Request**
   - Clearly describe your changes
   - Request review from team members
   - Ensure all workflow checks pass

### Adding New Language Support

To add support for a new programming language:

1. Create three workflow files:
   - `{language}-ci.yml` - Main CI workflow
   - `{language}-test.yml` - Test runner workflow
   - `{language}-pull-request.yml` - PR validation workflow

2. Follow the established patterns (see `ai-docs/WORKFLOWS.md` for templates)

3. Update this README with the new language in the supported technologies list

### Workflow Development Guidelines

- **Modularity**: Keep workflows focused on a single responsibility
- **Reusability**: Design workflows to be called by other workflows
- **Security**: Never expose secrets in logs or outputs
- **Documentation**: Add clear descriptions to inputs and outputs
- **Testing**: Test workflows using pull requests before merging

## Documentation Structure

- `README.md` - This file, providing overview and quick start
- `ai-docs/` - Detailed technical documentation
  - `CONTEXT.md` - AI agent context and documentation protocol
  - `ARCHITECTURE.md` - System design and component relationships
  - `PATTERNS.md` - Code patterns and conventions
  - `WORKFLOWS.md` - Step-by-step development guides

## Release Pipeline

This repository uses an automated release pipeline that creates releases based on conventional commits.

### How It Works

```
Push to main/release/* → Calculate Version → Create Release → Update Changelog
                                                    ↓
                                          Update floating tag (v1 → v1.2.3)
```

### Version Bumping

| Commit Prefix | Version Bump | Example |
|---------------|--------------|---------|
| `feat:` | Minor (0.X.0) | `feat: add new workflow` |
| `fix:` | Patch (0.0.X) | `fix: correct permissions` |
| `BREAKING CHANGE:` or `feat!:` | Major (X.0.0) | `feat!: redesign API` |
| `docs:`, `chore:`, etc. | No release | `docs: update README` |

### Referencing Workflows

Users reference workflows using the **floating major version tag**:

```yaml
# Recommended: Use floating major tag for automatic patch/minor updates
uses: agronod/.github/.github/workflows/node-ci.yml@v1

# Alternative: Pin to exact version
uses: agronod/.github/.github/workflows/node-ci.yml@v1.2.3
```

When `v1.2.3` is released, the `v1` tag is automatically updated to point to it.

### Hotfixes for Previous Major Versions

When a new major version (e.g., `v2.0.0`) is released:
1. A `release/v1` maintenance branch is automatically created
2. Hotfixes can be committed to `release/v1`
3. Pushing to `release/v1` triggers the release pipeline → creates `v1.x.y`
4. Both the exact tag and floating `v1` tag are updated

```
main ─────────────────────────────► v2.x development
         │
         └── release/v1 ──────────► v1.x hotfixes only
```

To manually create a release branch before a major bump:
```bash
git checkout -b release/v1 v1.2.0 && git push origin release/v1
```

## Workflow Components

### Core Workflows
- **Release Pipeline**: `release.yml` - Orchestrates versioning, release creation, and changelog
- **Version Management**: `next-version.yaml` - Calculates semantic version from commits
- **Container Building**: `build-and-push-image-v2.yml`
- **Release Creation**: `create-release.yml` - Creates GitHub release and updates floating tags
- **Application Promotion**: `promote-application.yml`

### Language-Specific Workflows
Each supported language has three workflows:
- `{language}-ci.yml` - Complete CI pipeline
- `{language}-test.yml` - Test execution
- `{language}-pull-request.yml` - PR validation

## Internal Resources

- **Documentation**: Detailed guides in the `ai-docs/` directory
- **Confluence**: [Agronod Development Best Practices](https://agronod.atlassian.net/wiki/spaces/Utveckling)
- **Team Support**: Reach out to the development team for questions or assistance

## Workflow Components

For a complete list of available workflows and their purposes, see the [Workflow Components](#workflow-components) section above or refer to `ai-docs/ARCHITECTURE.md` for detailed technical information.