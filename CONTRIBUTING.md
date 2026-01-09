# Contributing to Agronod Shared Workflows

Thank you for your interest in contributing to Agronod's shared workflows repository. This guide will help you get started.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Commit Conventions](#commit-conventions)
- [Pull Request Process](#pull-request-process)
- [Workflow Development Guidelines](#workflow-development-guidelines)
- [Adding New Language Support](#adding-new-language-support)

## Getting Started

### Prerequisites

- Git
- GitHub account with access to the Agronod organization
- Familiarity with GitHub Actions workflow syntax

### Setup

```bash
git clone https://github.com/agronod/.github.git
cd .github
```

### Before You Start

1. **Review existing workflows** to understand current patterns
2. **Check with the team** if someone is already working on similar changes
3. **Open an issue** for significant changes to discuss the approach first

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feat/your-feature-name
```

Branch naming conventions:

- `feat/` - New features or capabilities
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code restructuring

### 2. Make Your Changes

- Follow the [Workflow Development Guidelines](#workflow-development-guidelines)
- Test your changes using pull requests (workflows run on PR)
- Keep changes focused and atomic

### 3. Commit Your Changes

We use [Conventional Commits](https://www.conventionalcommits.org/) for automatic versioning.

### 4. Submit a Pull Request

- Push your branch and open a PR against `main`
- Fill out the PR template with a clear description
- Request review from team members

## Commit Conventions

Commit messages determine version bumps automatically:

| Prefix | Version Bump | Use When |
| ------ | ------------ | -------- |
| `feat:` | Minor (0.X.0) | Adding new functionality |
| `fix:` | Patch (0.0.X) | Fixing bugs |
| `docs:` | No release | Documentation only |
| `refactor:` | No release | Code restructuring |
| `chore:` | No release | Maintenance tasks |
| `ci:` | No release | CI/CD changes |
| `feat!:` or `BREAKING CHANGE:` | Major (X.0.0) | Breaking changes |

### Examples

```bash
# New feature
git commit -m "feat: add Python 3.12 support to python-ci workflow"

# Bug fix
git commit -m "fix: correct permissions for artifact upload"

# Breaking change
git commit -m "feat!: require node-version input parameter

BREAKING CHANGE: node-version is now required instead of defaulting to 18"
```

## Pull Request Process

1. **Automated checks** run on all PRs
2. **Request review** from at least one team member
3. **Address feedback** and update your branch as needed
4. **Squash and merge** is preferred for clean history
5. **Delete your branch** after merging

### What We Look For

- Clear description of changes and motivation
- Adherence to existing patterns and conventions
- No secrets or sensitive data exposed
- Proper input/output documentation in workflows

## Workflow Development Guidelines

### Principles

- **Modularity**: Keep workflows focused on a single responsibility
- **Reusability**: Design workflows to be called by other workflows
- **Security**: Never expose secrets in logs or outputs
- **Documentation**: Add clear descriptions to inputs and outputs
- **Backwards Compatibility**: Avoid breaking changes when possible

### Naming Conventions

- Workflow files: `{language}-{purpose}.yml` (e.g., `node-ci.yml`, `python-test.yml`)
- Jobs: Use descriptive names in kebab-case
- Inputs/outputs: Use kebab-case with clear descriptions

### Required Elements

Every reusable workflow should include:

```yaml
# Header comment explaining:
# - Purpose of the workflow
# - Usage example
# - Required inputs/secrets

name: Descriptive Name

on:
  workflow_call:
    inputs:
      example-input:
        description: "Clear description of what this input does"
        required: true
        type: string
    secrets:
      example-secret:
        description: "Clear description of what this secret is for"
        required: true
```

## Adding New Language Support

To add support for a new programming language:

1. **Create three workflow files:**
   - `{language}-ci.yml` - Main CI workflow (build, test, release)
   - `{language}-test.yml` - Test runner workflow
   - `{language}-pull-request.yml` - PR validation workflow

2. **Follow existing patterns** from similar language workflows

3. **Update documentation:**
   - Add the language to the Supported Technologies list in README.md

4. **Test thoroughly** using pull requests before merging

## Questions?

- **Confluence**: [Agronod Development Best Practices](https://agronod.atlassian.net/wiki/spaces/Utveckling)
- **Team Support**: Reach out to the development team for questions or assistance
