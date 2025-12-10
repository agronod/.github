# Container Security Scanning
Keywords: trivy, scan, vulnerability, security, rhacs, image-check

## Trivy Scanning

Container images are scanned using Trivy for vulnerabilities:

```yaml
uses: ./.github/workflows/scan-and-check-image.yml
with:
  image: ${{ needs.build-and-push-image.outputs.image }}
  check-image: true
  enforce-scanning: false  # Set true to fail on vulnerabilities
secrets:
  registry-username: ${{ secrets.registry-username }}
  registry-password: ${{ secrets.registry-password }}
  github-token: ${{ secrets.github-token }}
```

## Severity Levels

Trivy scans for `CRITICAL` and `HIGH` severity vulnerabilities:

```yaml
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@0.28.0
  with:
    image-ref: '${{ inputs.image }}'
    format: 'table'
    exit-code: ${{ inputs.enforce && '1' || '0' }}
    severity: 'CRITICAL,HIGH'
```

## Ignore Files

Repository-specific vulnerabilities can be ignored via the `agronod/trivyignore` repository:

```
trivyignore/
├── {repo-name}/
│   └── .trivyignore.yaml
```

## Input Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `check-image` | true | Whether to run vulnerability scan |
| `enforce-scanning` | false | Whether to fail build on vulnerabilities |

## Disabled Scanning Pattern

Some workflows disable scanning using a conditional:

```yaml
scan-and-check-image:
  if: ${{ 0==1 }}  # Disabled
  needs: "build-and-push-image"
```

## Rules

- MUST: Include scanning in all CI pipelines
- MUST: Use Quay.io credentials for image access
- PREFER: Enable `enforce-scanning` for production deployments
- AVOID: Disabling scanning without explicit approval

## References

- Key files: `.github/workflows/scan-and-check-image.yml`
- External: `agronod/trivyignore` repository for ignore files
