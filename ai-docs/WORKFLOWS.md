# GitHub Actions Workflow Development Guide

## Common Development Tasks

### Adding a New Language-Specific CI Workflow

Follow these steps to add support for a new programming language:

#### 1. Create the Main CI Workflow
Create `{language}-ci.yml` in `.github/workflows/`:

```yaml
name: {Language} CI

on:
  workflow_call:
    inputs:
      {language}-version:
        default: "{default-version}"
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
      test:
        default: true
        type: boolean
      check-image:
        default: true
        type: boolean
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
      container-build-args:
        description: "Container build args"
        required: false
      container-secrets:
        description: "Container secrets"
        required: false

jobs:
  test:
    uses: ./.github/workflows/{language}-test.yml
    with:
      {language}-version: ${{ inputs.{language}-version }}
      enabled: ${{ inputs.test }}
    secrets:
      github-token: ${{ secrets.github-token }}

  next-version:
    needs: "test"
    uses: ./.github/workflows/next-version.yaml
    secrets:
      github-token: ${{ secrets.github-token }}

  build-and-push-image:
    needs: "next-version"
    uses: ./.github/workflows/build-and-push-image.yml
    with:
      registry-url: "quay.io"
      image-name: "quay.io/agronod/ghcr.io/${{ github.repository }}"
      tag: ${{ needs.next-version.outputs.version }}
    secrets:
      registry-username: ${{ secrets.registry-username }}
      registry-password: ${{ secrets.registry-password }}
      container-build-args: ${{ secrets.container-build-args }}
      container-secrets: ${{ secrets.container-secrets }}

  create-release:
    needs: ["build-and-push-image", "next-version"]
    uses: ./.github/workflows/create-release.yml
    with:
      tag: ${{ needs.next-version.outputs.tag }}
      version: ${{ needs.next-version.outputs.version }}
      changelog: ${{ needs.next-version.outputs.changelog }}

  promote-application:
    needs: ["create-release", "build-and-push-image"]
    uses: ./.github/workflows/promote-application.yml
    with:
      tag: ${{ needs.build-and-push-image.outputs.tag }}
      application-name: ${{ inputs.application-name }}
      application-folder: ${{ inputs.application-folder }}
    secrets:
      github-token: ${{ secrets.github-token }}
```

#### 2. Create the Test Workflow
Create `{language}-test.yml` in `.github/workflows/`:

```yaml
name: {Language} Test

on:
  workflow_call:
    inputs:
      {language}-version:
        default: "{default-version}"
        type: string
      enabled:
        default: true
        type: boolean
    secrets:
      github-token:
        description: "Github token to be able to build inside the container"
        required: true

jobs:
  test:
    if: ${{ inputs.enabled }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        with:
          submodules: "true"

      - name: Setup {Language}
        uses: {language-setup-action}
        with:
          {language}-version: ${{ inputs.{language}-version }}

      - name: Install dependencies
        run: |
          # Add language-specific dependency installation

      - name: Run tests
        run: |
          # Add language-specific test commands
```

#### 3. Create the Pull Request Workflow
Create `{language}-pull-request.yml` in `.github/workflows/`:

```yaml
name: {Language} Pull Request

on:
  workflow_call:
    inputs:
      {language}-version:
        default: "{default-version}"
        type: string
      # Include other inputs as needed
    secrets:
      github-token:
        description: "Github token to be able to build inside the container"
        required: true

jobs:
  test:
    uses: ./.github/workflows/{language}-test.yml
    with:
      {language}-version: ${{ inputs.{language}-version }}
    secrets:
      github-token: ${{ secrets.github-token }}

  next-version:
    needs: "test"
    uses: ./.github/workflows/next-version.yaml
    with:
      is-pull-request: true
    secrets:
      github-token: ${{ secrets.github-token }}
```

### Modifying Existing Workflows

#### Adding New Input Parameters
1. **Add to the inputs section**:
   ```yaml
   inputs:
     new-parameter:
       description: "Description of the new parameter"
       type: string
       required: false
       default: "default-value"
   ```

2. **Use in job calls**:
   ```yaml
   jobs:
     job-name:
       uses: ./.github/workflows/target-workflow.yml
       with:
         new-parameter: ${{ inputs.new-parameter }}
   ```

#### Adding New Job Dependencies
1. **Add the new job**:
   ```yaml
   new-job:
     needs: ["prerequisite-job"]
     uses: ./.github/workflows/new-workflow.yml
   ```

2. **Update dependent jobs**:
   ```yaml
   existing-job:
     needs: ["existing-dependency", "new-job"]
   ```

#### Modifying Job Outputs
1. **Add output to job**:
   ```yaml
   jobs:
     job-name:
       outputs:
         new-output:
           description: "Description of new output"
           value: ${{ jobs.internal-job.outputs.new-value }}
   ```

2. **Reference in dependent jobs**:
   ```yaml
   dependent-job:
     needs: "job-name"
     with:
       parameter: ${{ needs.job-name.outputs.new-output }}
   ```

### Testing Workflows

#### Local Testing with Act
1. **Install Act**:
   ```bash
   # macOS
   brew install act
   
   # Linux
   curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
   ```

2. **Test workflow locally**:
   ```bash
   act workflow_call -W .github/workflows/node-ci.yml
   ```

#### Testing with Pull Requests
1. **Create a test branch**:
   ```bash
   git checkout -b test-workflow-changes
   ```

2. **Make changes and push**:
   ```bash
   git add .github/workflows/
   git commit -m "feat: add new workflow functionality"
   git push origin test-workflow-changes
   ```

3. **Create pull request to trigger PR workflows**

### Debugging Common Issues

#### Workflow Not Triggering
1. **Check trigger conditions**:
   - Verify `on:` section is correct
   - Ensure `workflow_call` is used for reusable workflows
   - Check if conditions (`if:`) are blocking execution

2. **Verify file paths**:
   - Ensure workflow files are in `.github/workflows/`
   - Check that referenced workflows exist

#### Job Failures
1. **Check job dependencies**:
   ```yaml
   # Ensure all dependencies are listed
   job-name:
     needs: ["dependency1", "dependency2"]
   ```

2. **Verify input/output mapping**:
   ```yaml
   # Check that outputs match inputs
   with:
     parameter: ${{ needs.source-job.outputs.parameter }}
   ```

3. **Review secret availability**:
   ```yaml
   # Ensure secrets are passed through
   secrets:
     required-secret: ${{ secrets.required-secret }}
   ```

#### Version/Tag Issues
1. **Check version workflow**:
   - Verify `next-version.yaml` is called correctly
   - Ensure GitHub token has proper permissions

2. **Tag format validation**:
   - Confirm tags follow `v{major}.{minor}.{patch}` format
   - Check for duplicate tags

### Managing Workflow State

#### Enabling/Disabling Jobs
Use conditional expressions to control job execution:

```yaml
# Disable a job completely
disabled-job:
  if: ${{ 0==1 }}  # Never runs

# Enable based on input
conditional-job:
  if: ${{ inputs.enable-feature }}

# Enable based on branch
main-only-job:
  if: ${{ github.ref == 'refs/heads/main' }}
```

#### Handling Different Environments
Use inputs to handle different deployment targets:

```yaml
# From: .github/workflows/dotnet-ci.yml:25-27
inputs:
  platform:
    default: "ocp"
    type: string
```

### Security Best Practices

#### Secret Management
1. **Never expose secrets in logs**:
   ```yaml
   # Bad
   run: echo "Secret: ${{ secrets.my-secret }}"
   
   # Good
   run: echo "Secret configured"
   env:
     MY_SECRET: ${{ secrets.my-secret }}
   ```

2. **Use minimal permissions**:
   ```yaml
   permissions:
     id-token: write  # Only what's needed
   ```

#### Input Validation
1. **Set appropriate defaults**:
   ```yaml
   inputs:
     version:
       default: "latest"
       type: string
   ```

2. **Use required flags**:
   ```yaml
   inputs:
     application-name:
       required: true
       type: string
   ```

### Performance Optimization

#### Caching Strategies
1. **Docker layer caching**:
   ```yaml
   # From: .github/workflows/build-and-push-image-v2.yml:105-106
   cache-from: type=gha
   cache-to: type=gha,mode=max
   ```

2. **Dependency caching**:
   ```yaml
   - name: Cache dependencies
     uses: actions/cache@v2
     with:
       path: ~/.cache
       key: ${{ runner.os }}-deps-${{ hashFiles('**/package-lock.json') }}
   ```

#### Parallel Job Execution
Structure jobs to run in parallel when possible:

```yaml
jobs:
  test-unit:
    runs-on: ubuntu-latest
    # Independent job
    
  test-integration:
    runs-on: ubuntu-latest
    # Independent job
    
  build:
    needs: ["test-unit", "test-integration"]
    # Depends on both tests
```

### Version Management

#### Semantic Versioning Process
1. **Conventional commits trigger appropriate version bumps**:
   - `feat:` → minor version bump
   - `fix:` → patch version bump
   - `BREAKING CHANGE:` → major version bump

2. **Version workflow handles**:
   - Tag creation
   - Changelog generation
   - Release notes

#### Pull Request Versioning
Pull requests get special versioning:
```
{base-tag}-{pr-number}-{commit-hash}
Example: v1.2.3-123-abc1234
```

### Deployment Procedures

#### Application Promotion
1. **Build and tag image**
2. **Create GitHub release**
3. **Promote to deployment environment**

#### Rollback Procedures
1. **Identify last known good version**
2. **Promote previous image tag**
3. **Verify deployment health**

### Troubleshooting Commands

#### GitHub CLI Commands
```bash
# View workflow runs
gh run list

# View specific run
gh run view <run-id>

# Download artifacts
gh run download <run-id>

# Re-run workflow
gh run rerun <run-id>
```

#### Common Git Commands
```bash
# View recent tags
git tag -l --sort=-version:refname | head -10

# Check current branch
git branch --show-current

# View commit history
git log --oneline -10
```

## Workflow Development Checklist

### Before Creating New Workflows
- [ ] Review existing workflows for similar patterns
- [ ] Identify reusable components
- [ ] Plan input/output structure
- [ ] Consider security implications

### During Development
- [ ] Follow naming conventions
- [ ] Add proper descriptions to inputs/outputs
- [ ] Include error handling
- [ ] Test with pull requests

### After Implementation
- [ ] Update documentation
- [ ] Add to CI/CD pipeline
- [ ] Monitor for issues
- [ ] Update team on changes

### Code Review Checklist
- [ ] Workflow follows established patterns
- [ ] Proper secret management
- [ ] Conditional logic is correct
- [ ] Job dependencies are appropriate
- [ ] Outputs are properly defined
- [ ] Documentation is updated