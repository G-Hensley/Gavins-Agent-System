# Requesting a Code Review

## How to Request

1. Get git SHAs:
```bash
BASE_SHA=$(git merge-base HEAD main)
HEAD_SHA=$(git rev-parse HEAD)
```

2. Dispatch the `code-quality-reviewer` subagent with:
   - What was implemented (summary)
   - Requirements it should satisfy
   - BASE_SHA and HEAD_SHA (commit range)
   - Instruct to use confidence scoring: only report 80+

3. Act on feedback:
   - **Critical (90-100)**: fix immediately — blocks merge
   - **Important (80-89)**: fix before proceeding
   - **Below 80**: should not be reported

Push back with technical reasoning if the reviewer is wrong.

## When to Request

**Mandatory:** after each task in subagent-driven development, after major features, before merge.
**Valuable:** when stuck, before refactoring, after complex bug fixes.
