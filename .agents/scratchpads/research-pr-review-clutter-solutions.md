# Research: Solving Cluttered PR Reviews from AI Tools

## Summary

When AI code review tools run on every push to a PR, comments accumulate and clutter the PR discussion. The community has developed several strategies: **comment cleanup actions** that delete/resolve outdated bot comments, **incremental review approaches** that only analyze changed lines, **on-demand triggers** instead of automatic reviews, and **concurrency controls** to cancel stale review runs.

## Key Strategies

### 1. Comment Cleanup Actions

**Resolve Outdated Comments** (`Ardiannn08/resolve-outdated-comment`):
```yaml
- uses: Ardiannn08/resolve-outdated-comment@v1.1
  with:
    token: ${{ secrets.GH_TOKEN }}
    filter-user: "claude[bot]"
    mode: "delete"  # or "resolve"
```

**Other cleanup actions:**
- `maheshrayas/action-pr-comment-delete` - Deletes old bot comments before posting new
- `izhangzhihao/delete-comment` - Delete comments by username

### 2. Incremental/Diff-Only Reviews

Instead of re-reviewing the entire PR, only analyze changed lines since the last review:
- **CodeRabbit**: Reviews commit-by-commit, tracks changed files
- **AI Code & PR Review**: Uses semantic deduplication and GitHub Actions cache to track comment history

### 3. On-Demand Triggers (Instead of Automatic)

Trigger reviews via comment mention rather than on every push:
```yaml
on:
  issue_comment:
    types: [created]
jobs:
  review:
    if: |
      github.actor \!= 'claude[bot]' &&
      github.event.issue.pull_request &&
      contains(github.event.comment.body, '@claude review')
```

### 4. Concurrency Controls

Cancel in-progress reviews when new commits arrive:
```yaml
concurrency:
  group: claude-review-${{ github.event.pull_request.number }}
  cancel-in-progress: true
```

### 5. Deduplication Mechanisms

The AI Code & PR Review action implements:
- **Line-based detection**: Skips comments on lines with existing comments
- **Semantic similarity**: Identifies similar comments even on different lines
- **Resolved tracking**: Avoids re-suggesting already resolved issues
- **Proximity awareness**: Considers nearby lines

### 6. Prompt Engineering

Instruct the AI to ignore outdated context:
```yaml
prompt: |
  Focus ONLY on the current diff and unresolved concerns.
  Ignore comments addressed in subsequent commits.
  Do not re-raise issues already fixed in current code state.
```

## Known Issues & Limitations

### GitHub API Limitations
- REST API cannot resolve review comments (only GraphQL `resolveReviewThread`)
- Bots can only edit/delete their own comments
- Comments only marked "outdated" when the specific line changes

### Claude Code Action Specific (Issue #590)
- Reviews can be biased by outdated/resolved comments
- No built-in filtering for resolved comments or bot comments
- Community workarounds required

### GitHub Copilot Behavior
- Does not deduplicate based on dismissed/resolved status
- May repeat the same comments even after dismissal

## Recommended Approach

### Option A: Cleanup-Based (Your Current Automatic Review + Cleanup)
```yaml
steps:
  - uses: anthropics/claude-code-action@v1
    with:
      prompt: |
        Review this PR. Focus on current diff only.
      claude_args: |
        --max-turns 20
        --allowedTools "mcp__github_inline_comment__create_inline_comment"
  
  # Clean up after review
  - uses: Ardiannn08/resolve-outdated-comment@v1.1
    with:
      filter-user: "claude[bot]"
      mode: "delete"
```

### Option B: On-Demand (Manual Trigger via Comment)
Only review when explicitly requested with `@claude review`.

### Option C: Reviewdog Pattern
Use `github-pr-check` reporter instead of `github-pr-review` - reports to specific commit hashes, no comment cleanup needed.

## Sources

- [Resolve Outdated Comments Action](https://github.com/marketplace/actions/resolve-outdated-comments)
- [Delete PR Comment Action](https://github.com/maheshrayas/action-pr-comment-delete)
- [AI Code & PR Review Action](https://github.com/marketplace/actions/ai-code-pr-review)
- [CodeRabbit ai-pr-reviewer](https://github.com/coderabbitai/ai-pr-reviewer)
- [Claude Code Action Issue #590](https://github.com/anthropics/claude-code-action/issues/590)
- [Reviewdog Issue #568](https://github.com/reviewdog/reviewdog/issues/568)
- [GitHub Copilot Code Review Docs](https://docs.github.com/copilot/using-github-copilot/code-review/using-copilot-code-review)
- [GitHub Community Discussion #86527](https://github.com/orgs/community/discussions/86527)