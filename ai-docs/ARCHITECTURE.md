# GitHub Actions Workflow Architecture

## System Overview

This repository contains reusable GitHub Actions workflows that provide standardized CI/CD pipelines for multiple technology stacks. The architecture follows a modular design where language-specific workflows compose lower-level utility workflows.

## Component Boundaries

### Language-Specific CI Workflows
Primary entry points for different technology stacks:

```
node-ci.yml        → Node.js applications
python-ci.yml      → Python applications  
dotnet-ci.yml      → .NET applications
```

### Core Infrastructure Workflows
Shared utility workflows used by language-specific workflows:

```
next-version.yaml          → Semantic versioning and release management
build-and-push-image.yml   → Docker image building (legacy)
build-and-push-image-v2.yml → Docker image building (current)
create-release.yml         → GitHub release creation
promote-application.yml    → Application deployment promotion
scan-and-check-image.yml   → Security scanning (disabled)
```

### Testing Workflows
Language-specific testing components:

```
node-test.yml     → Node.js testing
python-test.yml   → Python testing
dotnet-test.yml   → .NET testing
```

### Pull Request Workflows
Pre-merge validation workflows:

```
node-pull-request.yml     → Node.js PR validation
python-pull-request.yml   → Python PR validation
dotnet-pull-request.yml   → .NET PR validation
```

## Data Flow Architecture

### Standard CI Pipeline Flow
```
┌─────────────────┐
│   Source Code   │
│   Push/PR       │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│  Language-      │
│  Specific CI    │
│  (node-ci.yml)  │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│  Test Stage     │
│  (node-test.yml)│
└─────────────────┘
         │
         ▼
┌─────────────────┐
│  Version Stage  │
│(next-version.yml)│
└─────────────────┘
         │
         ▼
┌─────────────────┐
│  Build Stage    │
│(build-and-push)│
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Release Stage   │
│(create-release) │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Deploy Stage    │
│(promote-app)    │
└─────────────────┘
```

### Job Dependencies
Based on analysis of workflow files:

```yaml
# From: .github/workflows/node-ci.yml:45-100
test → next-version → build-and-push-image → create-release → promote-application
                  ↘                      ↗
                   scan-and-check-image (disabled)
```

## Integration Points

### Container Registry Integration
All workflows integrate with Quay.io container registry:

```yaml
# Pattern from: .github/workflows/build-and-push-image-v2.yml:64-67
registry-url: "quay.io"
image-repository: "quay.io/agronod/ghcr.io"
image-name: "quay.io/agronod/ghcr.io/${{ github.repository }}"
```

### GitHub Integration Points
- **Releases**: Automated GitHub release creation
- **Tags**: Semantic versioning with git tags
- **Pull Requests**: PR-specific versioning and validation
- **Packages**: Container image publishing

### External Service Integration
- **RHACS (Red Hat Advanced Cluster Security)**: Security scanning (currently disabled)
- **Docker Hub**: Container image building and caching
- **Semantic Release**: Version management and changelog generation

## Workflow Composition Patterns

### Reusable Workflow Architecture
All workflows use `workflow_call` for composition:

```yaml
# Parent workflow calls child workflows
jobs:
  test:
    uses: ./.github/workflows/node-test.yml
    with:
      node-version: ${{ inputs.node-version }}
```

### Input/Output Chain
Data flows through the pipeline via workflow outputs:

```yaml
# From: .github/workflows/node-ci.yml:84-100
create-release:
  needs: ["build-and-push-image", "next-version"]
  with:
    tag: ${{ needs.next-version.outputs.tag }}      # From versioning
    version: ${{ needs.next-version.outputs.version }} # From versioning
    changelog: ${{ needs.next-version.outputs.changelog }} # From versioning
```

## Extension Points

### Adding New Language Support
To add a new language (e.g., Go):

1. **Create language-specific CI workflow**: `go-ci.yml`
2. **Create language-specific test workflow**: `go-test.yml`
3. **Create language-specific PR workflow**: `go-pull-request.yml`
4. **Follow the standard job dependency pattern**:
   ```yaml
   jobs:
     test: → next-version: → build-and-push-image: → create-release: → promote-application:
   ```

### Adding New Infrastructure Components
New infrastructure workflows should:

1. **Use `workflow_call` trigger**
2. **Follow standard input/output patterns**
3. **Integrate with existing job dependency chains**
4. **Include proper error handling and conditional logic**

## Security Architecture

### Secret Management
Centralized secret management pattern:

```yaml
# From: .github/workflows/node-ci.yml:25-43
secrets:
  github-user: # GitHub authentication
  github-token: # Repository access
  registry-username: # Container registry
  registry-password: # Container registry
  container-build-args: # Build-time secrets
  container-secrets: # Runtime secrets
```

### Permission Model
Minimal permission principle:

```yaml
# From: .github/workflows/node-ci.yml:77-78
permissions:
  id-token: write  # Only for OIDC authentication
```

## Conditional Logic Architecture

### Feature Flags
Workflows support conditional execution:

```yaml
# From: .github/workflows/node-ci.yml:73-74
scan-and-check-image:
  if: ${{ 0==1 }}  # Disabled via condition
```

### Environment-Specific Logic
Pull request vs. main branch handling:

```yaml
# From: .github/workflows/next-version.yaml:30-37
- name: Checkout code for pull request
  if: ${{ inputs.is-pull-request }}
  uses: actions/checkout@v2
  with:
    ref: ${{ github.event.pull_request.base.ref }}
```

## Versioning Architecture

### Semantic Versioning Strategy
- **Main branch**: Automatic semantic versioning
- **Pull requests**: Pre-release versioning with PR number and commit hash
- **Tags**: Follow `v{major}.{minor}.{patch}` format

### Version Flow
```
Git Commit → Tag Detection → Version Calculation → Image Tagging → Release Creation
```

## Deployment Architecture

### Multi-Platform Support
Applications can be deployed to different platforms:

```yaml
# From: .github/workflows/dotnet-ci.yml:25-27
platform:
  default: "ocp"  # OpenShift Container Platform
  type: string
```

### Promotion Strategy
Applications follow a promotion-based deployment:

```yaml
# From: .github/workflows/promote-application.yml (referenced)
promote-application:
  needs: ["create-release", "build-and-push-image"]
  with:
    tag: ${{ needs.build-and-push-image.outputs.tag }}
    application-name: ${{ inputs.application-name }}
    application-folder: ${{ inputs.application-folder }}
```

## Directory Structure

### Workflow Organization
```
.github/
├── workflows/
│   ├── {language}-ci.yml         # Main CI pipelines
│   ├── {language}-test.yml       # Testing workflows
│   ├── {language}-pull-request.yml # PR validation
│   ├── build-and-push-image*.yml # Container building
│   ├── next-version.yaml         # Versioning
│   ├── create-release.yml        # Release management
│   ├── promote-application.yml   # Deployment
│   └── scan-and-check-image.yml  # Security (disabled)
└── ai-docs/                      # AI documentation
    ├── CONTEXT.md
    ├── PATTERNS.md
    ├── ARCHITECTURE.md
    └── WORKFLOWS.md
```

## Technology Stack Integration

### Supported Platforms
- **Node.js**: Version 20.15.0 (default)
- **Python**: Version 3.10 (default)
- **.NET**: Version specified per project
- **Docker**: Multi-stage builds with caching
- **GitHub Actions**: Ubuntu latest runners

### Container Strategy
- **Registry**: Quay.io
- **Namespace**: `quay.io/agronod/ghcr.io`
- **Caching**: GitHub Actions cache for Docker layers
- **Multi-architecture**: Support for different platforms