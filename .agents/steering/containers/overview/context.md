# Container Building and Registry
Keywords: docker, container, image, registry, quay, build, push, dockerfile

## Registry Configuration

All container images are pushed to Quay.io:

```yaml
registry-url: "quay.io"
image-repository: "quay.io/agronod/ghcr.io"
```

## Image Naming Convention

```yaml
# Default: repository-based naming
image: quay.io/agronod/ghcr.io/{github.repository}:{tag}

# Custom: explicit image name
image: quay.io/agronod/ghcr.io/agronod/{image-name}:{tag}
```

## Build Workflow (V2)

The current container build workflow is `build-and-push-image-v2.yml`:

```yaml
uses: ./.github/workflows/build-and-push-image-v2.yml
with:
  registry-url: "quay.io"
  tag: ${{ needs.next-version.outputs.version }}
  dockerfile: "Dockerfile"  # Optional, defaults to Dockerfile
secrets:
  registry-username: ${{ secrets.registry-username }}
  registry-password: ${{ secrets.registry-password }}
  container-build-args: ${{ secrets.container-build-args }}
```

## Build Arguments Pattern

Build arguments are passed via secret and written to a file:

```yaml
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

## Docker Build Configuration

```yaml
- name: Build and push Docker image
  uses: docker/build-push-action@v5
  with:
    context: .
    push: ${{ inputs.push }}
    tags: ${{ steps.set-image.outputs.image }}
    file: ${{ inputs.dockerfile }}
    build-args: ${{ steps.export-build-args.outputs.buildArgs }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

## Conventions

- Use GitHub Actions cache for Docker layers
- Include `IMAGE_TAG` in all build arguments
- Default Dockerfile location is repository root

## Rules

- MUST: Use Quay.io registry for all images
- MUST: Pass registry credentials via secrets
- MUST: Include submodules in checkout (`submodules: "true"`)
- PREFER: `build-and-push-image-v2.yml` over legacy `build-and-push-image.yml`
- AVOID: Exposing secrets in logs or outputs

## References

- Key files: `.github/workflows/build-and-push-image-v2.yml`
- Related contexts: `../security/context.md`, `../../versioning/overview/context.md`
