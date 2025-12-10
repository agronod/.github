# Pull Request Validation Workflows
Keywords: pr, pull-request, validation, review, merge, pre-release

## Purpose

PR validation workflows run pre-merge checks without creating releases or promoting applications. They generate pre-release versions for testing container images.

## PR Workflow Structure

```yaml
name: {Language} Pull Request

on:
  workflow_call:
    inputs:
      {language}-version:
        default: "{default-version}"
        type: string
      test:
        default: true
        type: boolean
      check-image:
        default: true
        type: boolean

jobs:
  test:
    uses: ./.github/workflows/{language}-test.yml

  next-version:
    needs: "test"
    uses: ./.github/workflows/next-version.yaml
    with:
      is-pull-request: true  # Key difference from CI workflow

  build-and-push-image:
    needs: "next-version"
    uses: ./.github/workflows/build-and-push-image.yml

  scan-and-check-image:
    needs: "build-and-push-image"
    uses: ./.github/workflows/scan-and-check-image.yml
```

## Key Differences from CI Workflows

| Aspect | CI Workflow | PR Workflow |
|--------|-------------|-------------|
| Versioning | Semantic (v1.2.3) | Pre-release (v1.2.3-123-abc1234) |
| Release | Creates GitHub release | No release created |
| Promotion | Deploys to environment | No deployment |
| Tag creation | Creates git tag | No tag created |

## Pre-release Version Format

```
{base-tag}-{pr-number}-{commit-hash}
Example: v1.2.3-123-abc1234
```

## Conventions

- PR workflows omit `create-release` and `promote-application` jobs
- Version workflow is called with `is-pull-request: true`
- Container images are built and scanned but not deployed

## Rules

- MUST: Set `is-pull-request: true` when calling `next-version.yaml`
- MUST: Include image scanning in PR validation
- PREFER: Keep PR workflows fast by skipping optional steps
- AVOID: Creating releases or promotions in PR workflows

## References

- Key files: `.github/workflows/node-pull-request.yml`, `.github/workflows/python-pull-request.yml`
- Related contexts: `../ci-pipelines/context.md`, `../../versioning/overview/context.md`
