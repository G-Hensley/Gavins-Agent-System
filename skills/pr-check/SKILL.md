---
name: pr-check
description: Full PR review cycle — fetch comments (including Copilot bot reviews), check CI status and merge state, verify each flagged issue still reproduces before fixing, commit in thematic clusters, push, and optionally retrigger Copilot. Use when the user says "pr check", "review pr comments", "address review feedback", or after Copilot / a human reviewer has posted on a PR.
last_verified: 2026-04-21
disable-model-invocation: true
argument-hint: "[pr-number]"
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

# PR Check

Close the loop on a PR: surface all open review comments, failing checks, merge issues — then resolve, verify, commit, and push in one pass.

**Announce at start:** "Running pr-check on PR #<N>."

## Process

### 1. Identify the PR

- If `$0` is provided, use it as the PR number.
- Otherwise: `gh pr view --json number -q .number` on the active branch.
- If no PR is found, ask the user which PR (or whether to create one).

### 2. Fetch PR state in parallel

Single batch. All read-only, no side effects.

- Inline review comments: `gh api repos/{owner}/{repo}/pulls/{pr}/comments` — includes author, path, line, body, commit_id, created_at.
- Review-level summary comments: `gh api repos/{owner}/{repo}/pulls/{pr}/reviews` — top-level "Copilot reviewed N of M files" summaries that inline comments miss.
- Check runs: `gh pr checks {pr} --json name,state,conclusion,link`.
- Mergeable state: `gh pr view {pr} --json mergeable,mergeStateStatus`.
- Dependabot alerts touching PR files (**best-effort**): try `gh api repos/{owner}/{repo}/dependabot/alerts` filtered to PR's changed manifests. If the call returns 403/404 (alerts disabled on the repo, or token lacks `security_events` scope), record Dependabot status as "unavailable" in the final report and continue — do not fail the check.

### 3. Triage comments

For each comment, assign one of four dispositions:

1. **Valid + reproduces** — verify the cited file at the cited line still has the flagged problem. Use `sed -n '<line>p' <file>` or grep. If the problem is genuinely present, mark **FIX**.
2. **Stale re-flag** — the problem was already addressed in a later commit. Current file state does NOT reproduce the issue. Mark **SKIP-STALE** with a one-line note.
3. **Nitpick / aesthetic** — style preference with no substantive impact (trailing whitespace in prose, bikeshed variable names, etc.). Mark **DEFER** with a short rationale. Do not blindly accept every suggestion.
4. **Ambiguous** — reviewer's intent unclear, or multiple valid interpretations. Mark **ASK-USER** and pause for input before touching the file.

Do NOT auto-skip bot comments. Copilot's bot output is the primary signal for this workflow.

### 4. Fix the FIX cluster

- Group FIX items by theme (e.g., all hook changes, all docs, all skill content). Themes map to commits.
- For each theme, make the edits.
- After each theme, run the relevant verification:
  - Shell scripts: `bash -n <file>` + behavioral test with a mock stdin payload.
  - Python/TS: run tests + linter (`uv run pytest` / `pnpm test`, `ruff check` / `pnpm lint`).
  - Docs: `bash scripts/validate.sh`.
  - Hooks: simulate the trigger with a synthetic tool-result JSON and confirm the output.
- If any verification fails, fix the verification failure before committing.

### 5. Commit and push

- Verify active GitHub account: `gh auth status` must show the account configured in `~/.claude/gh-account-guard.conf` (USERNAME=...). The `gh-account-guard` PreToolUse hook will block the push otherwise.
- Stage only files changed to resolve this cluster.
- Commit per theme with `type(scope): description` format. One logical change per commit, per the repo's commit rule.
- Never include SQL keywords like DROP TABLE in commit messages (security hook blocks it).
- Push to the PR branch.

### 6. Retrigger Copilot review (best-effort)

GitHub Copilot PR review usually fires once per push but can miss re-reviews. Attempt a retrigger:

```
gh api -X POST repos/{owner}/{repo}/pulls/{pr}/requested_reviewers \
  -f 'reviewers[]=copilot-pull-request-reviewer[bot]' 2>/dev/null || true
```

**Important:** the slug is `copilot-pull-request-reviewer[bot]` with the literal `[bot]` suffix. Plain `copilot-pull-request-reviewer` (no suffix) returns `422 not a collaborator`. Verified working on G-Hensley/gavins-agent-system PR #4 on 2026-04-21.

If the API call fails (account doesn't have Copilot PR review enabled, slug changed, org policy blocks it), skip silently and tell the user they may need to click "Ask Copilot" in the PR UI.

### 7. Report

Single summary block covering inline review comments AND review-level summary items in the same table. Columns: comment id | path:line | disposition | action taken.

For inline comments, use the normal `path:line` value. For review-level summary items (from `/pulls/{pr}/reviews` — they have no file/line), use `review:<id>` in the `path:line` column where `<id>` is the GitHub review id.

End with:

- **Fixed:** N across M commits (list commit shas)
- **Skipped stale:** K (short list of why)
- **Deferred nitpicks:** J (short list of why)
- **Awaiting user:** P (itemized questions)
- **CI status:** list of any failing / pending check runs
- **Merge state:** CLEAN / BEHIND / DIRTY / CONFLICTING / UNKNOWN

If anything is in **Awaiting user** or **CI status is red**, stop there — do not declare success.

## What NOT to Do

- Do not skip comments from bot authors. Copilot and Dependabot bot output are in scope.
- Do not blindly apply every Copilot suggestion — the DEFER path exists for a reason.
- Do not bundle unrelated fixes into one commit. Thematic groups only.
- Do not `--force` push unless explicitly requested and warned.
- Do not continue to commit/push if verification fails — fix the test/lint first.
- Do not declare the PR ready if any check run is failing or the merge state is DIRTY/CONFLICTING.

## Output format

Short, scannable. No narration of every file read. Report the table + summary block described in step 7; skip the play-by-play.

## References

- `validation-and-verification` skill — the "evidence before assertions" gate that step 4's verification pass implements.
- `git-workflow` skill — references/quick-commands.md has the commit / push patterns.
- `commit-push-pr` from the `commit-commands` plugin — overlapping territory for the happy-path "commit and open PR" flow. This skill is about the *post-PR review* cycle, not PR creation. (Note: `commit-commands` is a plugin, not a local `skills/` entry — don't look for it under `skills/commit-commands/`.)
