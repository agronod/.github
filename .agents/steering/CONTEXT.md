# AI Context Documentation
Generated: 2026-01-08 09:15
Commit: 698f7c3
Mode: incremental

## Last Updated
- Updated: workflows/ci-pipelines (added .NET-specific features documentation)
- Fixed: broken cross-reference in workflows/claude-assistant
- Structure: kept as-is
- Files analyzed: 3

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
