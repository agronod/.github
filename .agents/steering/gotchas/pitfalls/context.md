# Common Gotchas and Anti-Patterns
Keywords: gotcha, antipattern, mistake, error, pitfall, troubleshooting

## Workflow Issues

### Disabled Jobs

Some workflows contain intentionally disabled jobs:
```yaml
scan-and-check-image:
  if: ${{ 0==1 }}  # This job is disabled
```

Check conditional expressions before assuming a job runs.

### Missing Job Dependencies

```yaml
# Bad: No dependency chain
jobs:
  build:
    # runs immediately
  deploy:
    # also runs immediately - may fail if build not done

# Good: Explicit dependencies
jobs:
  build:
  deploy:
    needs: "build"
```

### Secret Propagation

Secrets must be explicitly passed through each workflow level:
```yaml
# Parent workflow
jobs:
  child-job:
    uses: ./.github/workflows/child.yml
    secrets:
      github-token: ${{ secrets.github-token }}  # Must be explicit
```

## Version Workflow Issues

### Wrong PR Versioning

```yaml
# Bad: Missing is-pull-request flag
next-version:
  uses: ./.github/workflows/next-version.yaml
  # Creates real tags in PR context!

# Good: Explicit PR mode
next-version:
  uses: ./.github/workflows/next-version.yaml
  with:
    is-pull-request: true
```

### Tag Format Mismatch

Version output: `1.2.3` (no `v` prefix)
Tag output: `v1.2.3` (with `v` prefix)

Use the correct output for your use case.

## Container Build Issues

### Legacy vs V2 Workflow

Two build workflows exist:
- `build-and-push-image.yml` - Legacy, has different input interface
- `build-and-push-image-v2.yml` - Current, preferred

Check which workflow is being called and use appropriate inputs.

### Image Name Inconsistency

Different workflows use different patterns:
```yaml
# Node CI: Uses format with github.repository
image-name: quay.io/agronod/ghcr.io/${{ github.repository }}

# Python CI: Uses inputs.image-name directly
image-name: ${{ inputs.image-name }}
```

## YAML Formatting

### Unquoted Version Numbers

```yaml
# Bad: May be parsed as number
node-version: 20.15.0

# Good: Explicitly a string
node-version: "20.15.0"
```

### Mixed Naming Conventions

```yaml
# Bad: Inconsistent naming
inputs:
  nodeVersion:      # camelCase
  python-version:   # kebab-case
  DotnetVersion:    # PascalCase

# Good: Consistent kebab-case
inputs:
  node-version:
  python-version:
  dotnet-version:
```

## Deployment Issues

### Environment Override

The `environment` input overrides branch-based detection. Only use when intentionally deploying to a different environment than the branch suggests.

### Platform Deprecation

The `platform` input defaults to `elastisys`. The `ocp` platform is deprecated but still supported in some workflows.

## Rules

- MUST: Check `if:` conditions before assuming job execution
- MUST: Explicitly pass all required secrets
- MUST: Quote version number strings
- PREFER: Consistent kebab-case naming
- AVOID: Using deprecated `build-and-push-image.yml`

## References

- Related contexts: All other context files
