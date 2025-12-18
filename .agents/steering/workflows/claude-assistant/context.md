# Claude AI Assistant Workflows
Keywords: claude, ai, assistant, review, pr-review, mention, interactive, anthropic

## Overview

Two workflow modes for AI-assisted development:
1. **Interactive**: Responds to @claude mentions in issues, PRs, and comments
2. **Automatic PR Review**: Reviews all pull requests with inline comments

## Workflow Files

| File | Purpose |
|------|---------|
| `claude-assistant-ci.yml` | Current - reusable workflow_call |
| `claude-assistant.yml` | Deprecated - use ci version |

## Interactive Mode

Triggered by @claude mentions in:
- Issue comments
- PR review comments
- PR reviews
- Issue body/title

```yaml
claude-interactive:
  if: |
    (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@claude')) ||
    (github.event_name == 'pull_request_review_comment' && contains(github.event.comment.body, '@claude'))
```

Uses sticky comments to consolidate responses in a single thread.

## Automatic PR Review

Runs on all PRs except those from bots:

```yaml
claude-pr-review:
  if: |
    github.event_name == 'pull_request' &&
    github.actor != 'claude[bot]' &&
    github.actor != 'github-actions[bot]'
```

### Review Focus Areas (Priority Order)
1. **Safety** - Security vulnerabilities, data integrity risks
2. **Bugs** - Runtime errors, edge cases, logic errors
3. **Conventions** - Contradicts steering context or CLAUDE.md
4. **Scope** - Changes that don't belong in this repository
5. **Cost** - N+1 queries, unbounded loops, expensive operations

### Review Output Format

**Inline comments** with code blocks showing suggested fixes:
```markdown
**[TYPE]** Brief issue title

Why it matters.

**Suggested fix:**
```ts
corrected code
```
```

**Summary comment** after inline comments:
```markdown
### Review Summary
One sentence: scope, risk level, key concerns.

**Issues found:** N
```

## Context Loading

Claude reads project context before responding:
1. Maps `.agents/steering/` structure
2. Reads relevant `context.md` files
3. Reads `CLAUDE.md` for project guidelines

## Caller Workflow Setup

```yaml
name: Claude Assistant
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  pull_request_review:
    types: [submitted]
  issues:
    types: [opened, edited]
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  claude:
    uses: <org>/.github/.github/workflows/claude-assistant-ci.yml@main
    secrets:
      claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
```

## Rules

- MUST: Use `claude-assistant-ci.yml` (not deprecated version)
- MUST: Include all trigger event types for full coverage
- MUST: Pass OAuth token as secret
- PREFER: Enable progress tracking for automated reviews
- AVOID: Modifying review focus areas without team discussion

## References

- Key files: `.github/workflows/claude-assistant-ci.yml`
- Related contexts: `../ci-pipelines/context.md`, `../../gotchas/common/context.md`
