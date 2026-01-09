# CI Pipeline Workflows
Keywords: ci, pipeline, test, build, release, node, python, dotnet, go, language, nuget, package

## Architecture

Language-specific CI workflows compose shared infrastructure workflows in a standard job dependency chain:

```mermaid
flowchart LR
    A[test] --> B[next-version]
    B --> C[build-and-push-image]
    C --> D[scan-and-check-image]
    D --> E[create-release]
    E --> F[promote-application]
```

## Supported Languages

| Language | CI Workflow | Test Workflow | Default Version |
|----------|-------------|---------------|-----------------|
| Node.js | `node-ci.yml` | `node-test.yml` | 20.15.0 |
| Node.js (npm) | `node-packages-ci.yml` | `node-test.yml` | **required** |
| Python | `python-ci.yml` | `python-test.yml` | 3.10 |
| .NET | `dotnet-ci.yml` | `dotnet-test.yml` | **required** |
| .NET (NuGet) | `dotnet-packages-ci.yml` | `dotnet-test.yml` | **required** |
| Go | `go-ci.yml` | `go-test.yml` | 1.21 |

## .NET-Specific Features

.NET workflows have additional inputs not present in other languages:

```yaml
inputs:
  dotnet-version:
    required: true           # No default - must be specified
    type: string
  working-directory:
    default: "."             # Path to .NET solution/project
    type: string
  test-filter:
    default: "Category!=e2e" # Excludes e2e tests by default
    type: string
```

## .NET NuGet Package Workflows

For .NET libraries that publish NuGet packages (not container images), use the package-specific workflows:

```mermaid
flowchart LR
    A[test] --> B[next-version]
    B --> C[dotnet-pack-nuget]
    C --> D[create-release]
    D --> E[update-changelog]
```

### Available Workflows

| Workflow | Purpose |
|----------|---------|
| `dotnet-packages-ci.yml` | Main CI for NuGet libraries (push to main) |
| `dotnet-packages-pull-request.yml` | PR validation with prerelease packages |
| `dotnet-pack-nuget.yml` | Build, pack, and publish NuGet packages |
| `comment-nuget-package.yml` | Post PR comment with installation instructions |
| `update-changelog.yml` | Update CHANGELOG.md after release |

### NuGet CI Inputs

```yaml
inputs:
  dotnet-version:
    required: true           # No default - must be specified
    type: string
  working-directory:
    default: "."             # Path to .NET solution/project
    type: string
  package-name:
    required: true           # NuGet package name
    type: string
  test:
    default: true            # Run tests before packaging
    type: boolean
  test-filter:
    default: "Category!=e2e" # Excludes e2e tests by default
    type: string
```

### Usage Example

```yaml
# .github/workflows/ci.yml
name: CI
on:
  push:
    branches: [main]

jobs:
  ci:
    uses: agronod/.github/.github/workflows/dotnet-packages-ci.yml@main
    with:
      dotnet-version: "8.0"
      working-directory: "src/MyLibrary"
      package-name: "MyLibrary"
    secrets:
      github-user: ${{ secrets.GH_USER }}
      github-token: ${{ secrets.GH_TOKEN }}
```

### Key Differences from Container Workflows

- Publishes NuGet packages to GitHub Packages instead of container images
- No image scanning (Trivy) step
- No GitOps promotion step
- PR workflow posts installation instructions as comment
- Auto-updates CHANGELOG.md after each release

## Standard CI Workflow Structure

```yaml
name: {Language} CI

on:
  workflow_call:
    inputs:
      {language}-version:
        default: "{default-version}"
        type: string
      application-name:
        required: true
        type: string
      application-folder:
        required: true
        type: string
      test:
        default: true
        type: boolean
    secrets:
      github-user:
        required: true
      github-token:
        required: true
      registry-username:
        required: true
      registry-password:
        required: true

jobs:
  test:
    uses: ./.github/workflows/{language}-test.yml
  next-version:
    needs: "test"
    uses: ./.github/workflows/next-version.yaml
  build-and-push-image:
    needs: "next-version"
    uses: ./.github/workflows/build-and-push-image.yml
  create-release:
    needs: ["build-and-push-image", "next-version"]
    uses: ./.github/workflows/create-release.yml
  promote-application:
    needs: ["create-release", "build-and-push-image"]
    uses: ./.github/workflows/promote-application.yml
```

## Conventions

- All workflows use `workflow_call` trigger for reusability
- Job names use `kebab-case`
- Input names use `kebab-case`
- Version numbers must be quoted: `"20.15.0"`

## Rules

- MUST: Follow the standard job dependency chain
- MUST: Pass secrets through explicit `secrets:` block
- MUST: Include `github-token` secret for all workflows
- PREFER: Use existing infrastructure workflows over custom implementations
- AVOID: Hardcoded version numbers - use inputs with defaults

## References

- Key files: `.github/workflows/node-ci.yml`, `.github/workflows/python-ci.yml`
- NuGet files: `.github/workflows/dotnet-packages-ci.yml`, `.github/workflows/dotnet-pack-nuget.yml`, `.github/workflows/update-changelog.yml`
- Related contexts: `../pr-validation/context.md`, `../../versioning/semver/context.md`
