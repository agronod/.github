# AI Context Documentation
Generated: 2025-12-10 10:25
Commit: 7ce0351
Mode: incremental (restructure)

## Last Updated
- Restructured: Renamed generic folders to specific names for better searchability
- Added: workflows/claude-assistant (Claude AI review and interaction patterns)
- Changes: overview→building, security→scanning, overview→gitops, overview→semver, common→pitfalls

## Structure

```
.agents/steering/
├── containers/
│   ├── building/    → Docker build, registry, image naming
│   └── scanning/    → Trivy vulnerability scanning
├── deployment/
│   └── gitops/      → ArgoCD, environment mapping, promotion
├── gotchas/
│   └── pitfalls/    → Anti-patterns, common mistakes
├── versioning/
│   └── semver/      → Conventional commits, tags, releases
└── workflows/
    ├── ci-pipelines/      → Language CI patterns (Node, Python, .NET, Go)
    ├── pr-validation/     → PR checks, pre-release versioning
    └── claude-assistant/  → Claude AI review configuration
```

## Selective Reading Guide

| Task | Read these contexts |
|------|---------------------|
| CI/CD work | `workflows/ci-pipelines/` + `versioning/semver/` |
| PR workflows | `workflows/pr-validation/` + `versioning/semver/` |
| Container builds | `containers/building/` + `containers/scanning/` |
| Deployments | `deployment/gitops/` + `versioning/semver/` |
| Claude config | `workflows/claude-assistant/` |
| Troubleshooting | `gotchas/pitfalls/` |

## Usage
Load with context-prime skill for task-specific context.
