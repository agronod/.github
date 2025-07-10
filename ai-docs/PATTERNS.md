# GitHub Actions Workflow Patterns and Conventions

## Workflow Structure Patterns

### Reusable Workflow Pattern
All workflows use the `workflow_call` trigger for reusability:
```yaml
# Pattern from: .github/workflows/node-ci.yml:1-4
name: Node CI

on:
  workflow_call:
    inputs:
      # Define inputs here
```

### Input Parameter Pattern
Standardized input structure across all workflows:
```yaml
# Pattern from: .github/workflows/node-ci.yml:5-24
inputs:
  node-version:
    default: "20.15.0"
    type: string
  rhacs-central-endpoint:
    description: "The endpoint URL of the RHACS Central server for authentication."
    type: string
    required: true
  application-name:
    required: true
    type: string
  application-folder:
    required: true
    type: string
```

### Secret Management Pattern
Consistent secret structure for container registry and authentication:
```yaml
# Pattern from: .github/workflows/node-ci.yml:25-43
secrets:
  github-user:
    description: "Github username for the container registry"
    required: true
  github-token:
    description: "Github token to be able to build inside the container"
    required: true
  registry-username:
    description: "The username for the container registry"
    required: true
  registry-password:
    description: "The password for the container registry"
    required: true
```

## Job Dependency Patterns

### Standard CI Pipeline Flow
Common job sequence across all language-specific workflows:
```yaml
# Pattern from: .github/workflows/node-ci.yml:45-100
jobs:
  test:
    uses: ./.github/workflows/node-test.yml
    
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

### Conditional Job Execution
Disable jobs using conditional expressions:
```yaml
# Pattern from: .github/workflows/node-ci.yml:73-82
scan-and-check-image:
  if: ${{ 0==1 }}  # Disabled job pattern
  needs: "build-and-push-image"
  uses: ./.github/workflows/scan-and-check-image.yml
```

## File Naming Conventions

### Workflow File Names
- Language-specific CI: `{language}-ci.yml`
- Test workflows: `{language}-test.yml`
- Pull request workflows: `{language}-pull-request.yml`
- Infrastructure workflows: `{function}-{purpose}.yml`

Examples:
- ✅ `node-ci.yml` (see .github/workflows/node-ci.yml)
- ✅ `python-test.yml` (see .github/workflows/python-test.yml)
- ✅ `build-and-push-image-v2.yml` (see .github/workflows/build-and-push-image-v2.yml)
- ❌ `nodeCI.yml` or `node_ci.yml`

## Language-Specific Patterns

### Node.js Workflow Pattern
```yaml
# Pattern from: .github/workflows/node-ci.yml:6-8
inputs:
  node-version:
    default: "20.15.0"
    type: string
```

### Python Workflow Pattern
```yaml
# Pattern from: .github/workflows/python-ci.yml:6-8
inputs:
  python-version:
    default: "3.10"
    type: string
```

### .NET Workflow Pattern
```yaml
# Pattern from: .github/workflows/dotnet-ci.yml:6-8
inputs:
  dotnet-version:
    required: true
    type: string
```

## Container Image Patterns

### Image Naming Convention
```yaml
# Pattern from: .github/workflows/build-and-push-image-v2.yml:64-67
run: |
  if [ -z "${{ inputs.image-name }}" ]; then
    echo "image=${{ inputs.image-repository }}/${{ github.repository }}:${{ inputs.tag }}" >> $GITHUB_OUTPUT
  else
    echo "image=${{ inputs.image-repository }}/agronod/${{ inputs.image-name }}:${{ inputs.tag }}" >> $GITHUB_OUTPUT
  fi
```

### Docker Build Arguments
```yaml
# Pattern from: .github/workflows/build-and-push-image-v2.yml:82-95
- name: Prepare build-args
  run: |
    echo "${{ secrets.container-build-args }}" > container-build-args.txt
    echo "IMAGE_TAG=${{ inputs.tag }}" >> container-build-args.txt

- name: Export build-args
  run: |
    echo "buildArgs<<EOF" >> $GITHUB_OUTPUT
    cat container-build-args.txt >> $GITHUB_OUTPUT
    echo "EOF" >> $GITHUB_OUTPUT
```

## Versioning and Release Patterns

### Semantic Versioning
```yaml
# Pattern from: .github/workflows/next-version.yaml:51-58
- name: Identify new semver version
  uses: mathieudutour/github-tag-action@v6.2
  with:
    fetch_all_tags: true
    github_token: ${{ secrets.github-token }}
    dry_run: ${{ inputs.is-pull-request }}
```

### Pull Request Versioning
```yaml
# Pattern from: .github/workflows/next-version.yaml:39-49
- name: Fetch all tags and get latest for PRs
  run: |
    RAW_TAG=$(git describe --tags --abbrev=0)
    TAG_WITHOUT_V=${RAW_TAG#v}
    NEW_TAG="${RAW_TAG}-${{ github.event.number }}-$(git rev-parse --short ${{ github.event.pull_request.head.sha }})"
    NEW_VERSION="${TAG_WITHOUT_V}-${{ github.event.number }}-$(git rev-parse --short ${{ github.event.pull_request.head.sha }})"
```

## Output Patterns

### Standard Output Structure
```yaml
# Pattern from: .github/workflows/python-ci.yml:53-65
outputs:
  version:
    description: Next version (ex 1.0.0)
    value: ${{ jobs.next-version.outputs.version }}
  tag:
    description: Next tag (ex v1.0.0)
    value: ${{ jobs.next-version.outputs.tag }}
  changelog:
    description: Changelog
    value: ${{ jobs.next-version.outputs.changelog }}
  image:
    description: "The output representing the built image"
    value: ${{ jobs.build-and-push-image.outputs.image }}
```

## Security Patterns

### Permission Scoping
```yaml
# Pattern from: .github/workflows/node-ci.yml:77-78
permissions:
  id-token: write
```

### Secret Handling
Never expose secrets in logs or outputs. Use environment variables:
```yaml
# Pattern from: .github/workflows/build-and-push-image-v2.yml:83-86
run: |
  echo "${{ secrets.container-build-args }}" > container-build-args.txt
  echo "IMAGE_TAG=${{ inputs.tag }}" >> container-build-args.txt
shell: bash
```

## YAML Formatting Rules

### Indentation
- Use 2 spaces for indentation (consistent across all workflows)
- No tabs allowed

### Naming Conventions
- Job names: `kebab-case` (e.g., `build-and-push-image`)
- Step names: `Sentence case` (e.g., `Build and push Docker image`)
- Input names: `kebab-case` (e.g., `node-version`)
- Output names: `camelCase` (e.g., `buildArgs`)

### String Quoting
- Always quote version numbers: `"20.15.0"`, `"3.10"`
- Quote boolean expressions: `${{ 0==1 }}`
- Quote complex expressions: `${{ github.event.pull_request.head.sha }}`

## Anti-Patterns to Avoid

### ❌ Don't use hardcoded values
```yaml
# Bad
run: docker build -t myapp:1.0.0 .

# Good
run: docker build -t ${{ steps.set-image.outputs.image }} .
```

### ❌ Don't skip job dependencies
```yaml
# Bad
jobs:
  build:
    # No dependencies specified
  deploy:
    # Should depend on build
```

### ❌ Don't use mixed naming conventions
```yaml
# Bad
inputs:
  nodeVersion:  # camelCase
  python-version:  # kebab-case
  DotnetVersion:  # PascalCase
```

### ❌ Don't expose secrets in outputs
```yaml
# Bad
outputs:
  password: ${{ secrets.registry-password }}
```