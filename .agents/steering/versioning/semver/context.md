# Semantic Versioning
Keywords: version, semver, tag, release, changelog, conventional-commits

## Versioning Strategy

Uses [Conventional Commits](https://www.conventionalcommits.org/) to automatically determine version bumps:

| Commit Prefix | Version Bump | Example |
|---------------|--------------|---------|
| `feat:` | Minor (0.X.0) | feat: add new API endpoint |
| `fix:` | Patch (0.0.X) | fix: resolve null pointer |
| `BREAKING CHANGE:` | Major (X.0.0) | feat!: redesign auth flow |

## Version Workflow

```yaml
uses: ./.github/workflows/next-version.yaml
with:
  is-pull-request: false  # true for PR validation
secrets:
  github-token: ${{ secrets.github-token }}
```

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `version` | Semantic version | `1.2.3` |
| `tag` | Git tag | `v1.2.3` |
| `changelog` | Generated changelog | Markdown content |

## Main Branch vs Pull Request

**Main Branch (release):**
```
v1.2.3 → v1.2.4 (patch)
       → v1.3.0 (minor)
       → v2.0.0 (major)
```

**Pull Request (pre-release):**
```
v1.2.3-123-abc1234
  │     │    └── Short commit SHA
  │     └── PR number
  └── Base version from latest tag
```

## Implementation Details

```yaml
# Main branch: Create real tag
- name: Identify new semver version
  if: ${{ !inputs.is-pull-request }}
  uses: mathieudutour/github-tag-action@v6.2
  with:
    fetch_all_tags: true
    github_token: ${{ secrets.github-token }}

# PR: Generate pre-release version
- name: Fetch all tags and get latest for PRs
  if: ${{ inputs.is-pull-request }}
  run: |
    RAW_TAG=$(git describe --tags --abbrev=0)
    TAG_WITHOUT_V=${RAW_TAG#v}
    NEW_TAG="${RAW_TAG}-${{ github.event.number }}-$(git rev-parse --short ${{ github.event.pull_request.head.sha }})"
```

## Release Creation

```yaml
uses: ./.github/workflows/create-release.yml
with:
  tag: ${{ needs.next-version.outputs.tag }}
  version: ${{ needs.next-version.outputs.version }}
  changelog: ${{ needs.next-version.outputs.changelog }}
```

Releases on `main` and `release/v*` branches are marked as stable; other branches create pre-releases.

## Floating Major Version Tags

GitHub does NOT automatically resolve `@v1` to latest `v1.x.x`. We maintain floating tags:

```
v1 (floating) ────────────────► points to v1.3.2
                                │
v1.0.0 ── v1.1.0 ── v1.2.0 ── v1.3.2
```

Users reference `@v1` to get automatic patch/minor updates. The floating tag is updated automatically when a new release is created.

## Release Branch Strategy

```
main ──────────────────────────────────► (v2.x development)
         │
         └── release/v1 ───────────────► (v1.x maintenance)
```

**Branch lifecycle:**
1. All development happens on `main` (current major)
2. When `v2.0.0` releases, `release/v1` branch is auto-created from latest `v1.x.x`
3. Hotfixes for v1 are committed to `release/v1` → triggers release pipeline
4. Both `v1.x.y` tag and floating `v1` tag are updated

**Creating release branches:**
- **Automatic:** Created when a new major version (X.0.0) is released
- **Manual:** Create branch from tag if needed before major bump

## Rules

- MUST: Use conventional commit messages for automatic versioning
- MUST: Pass `is-pull-request: true` for PR workflows
- MUST: Include changelog in release notes
- PREFER: Let the action create tags automatically
- AVOID: Manual version bumps or tag creation

## References

- Key files: `.github/workflows/next-version.yaml`, `.github/workflows/create-release.yml`, `.github/workflows/release.yml`
- Related contexts: `../../workflows/ci-pipelines/context.md`
