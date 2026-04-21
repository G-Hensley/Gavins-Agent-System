---
name: git-health-check
description: Detect and optionally repair common .git/ corruption patterns — truncated HEAD refs, stale .corrupt.backup artifacts, dangling .lock files, and stranded dependabot branches. Use when git commands start misbehaving ("No commits yet" on a repo that clearly has commits, "your current branch appears to be broken", commits that refuse to land) or as a weekly hygiene pass.
last_verified: 2026-04-20
---

# Git Health Check

> **Historical starter proposal from the 2026-04-20 coach report.** See the shipped version at [`skills/git-health-check/SKILL.md`](../../skills/git-health-check/SKILL.md) for the production pattern — it fixes the known bugs in this draft (`-maxdepth 2` misses deep lock files; the `**` glob for dependabot branches requires `shopt -s globstar`) and adds an explicit `--fix` scope section. Preserved here as the record of what the coach proposed, not as a template to copy.

Proactively check for and repair the git-level corruption patterns that have surfaced in `gavins-agent-system` (2026-04-17 `.corrupt.backup` incident, 2026-04-19 truncated HEAD).

**Announce at start:** "Running git-health-check on this repo."

## Process

### 1. HEAD integrity

Read `.git/HEAD`. It must match one of:

- `ref: refs/heads/<name>\n` where the file at `.git/refs/heads/<name>` exists and contains a valid sha, **OR**
- a single 40-char hex sha followed by newline (detached HEAD).

Failure modes to detect:

- **Trailing-slash truncation**: matches `^ref: refs/heads/.*/$` (the observed 2026-04-19 bug).
- **Missing newline**: content does not end with `\n`.
- **Ref target missing**: `ref: refs/heads/<name>` points to a file that doesn't exist under `.git/refs/heads/<name>` AND the ref doesn't appear in `.git/packed-refs`.
- **Detached-but-invalid**: HEAD is a 40-char hex sha that `git cat-file -e` can't resolve.

If any fail: report the exact failure, offer to repair. Repair logic for the trailing-slash truncation: walk `.git/logs/HEAD` bottom-up looking for the most recent `checkout:` line, extract the branch name after "to ", and rewrite HEAD.

### 2. Corruption artifacts

`ls .git/*.corrupt* .git/*.bak .git/*.orig 2>/dev/null`. Any match = noise from a prior recovery. Report filenames + dates. Offer to delete after confirming live equivalents are valid.

### 3. Dangling locks

`find .git -maxdepth 2 -name "*.lock" -type f`. Any `.lock` file older than 5 minutes is almost certainly a crashed writer. Check `fuser` / `lsof` to confirm no live process holds it, then offer to delete.

### 4. Stranded dependabot branches

`ls -la .git/refs/heads/dependabot/**/` (if dir exists). Report the count + dates. Do not auto-delete — dependabot branches may have legitimate PRs associated. Instead, link to `https://github.com/<owner>/<repo>/network/updates` so the user can close them in the UI.

### 5. Remote vs. local divergence sanity

Run `git fetch --dry-run origin 2>&1 | head` (safe, no side effects) and surface any "would fetch ...rejected..." lines — they indicate force-pushes or branch deletions that can destabilize local refs.

## Output

Single table. Columns: Check | Status (OK / WARN / FAIL) | Details | Suggested fix.

If any FAIL, end with: "Run `/git-health-check --fix` to apply the safe repairs."

## What NOT to do

- Do not run `git fsck --full` unprompted — it's slow and noisy.
- Do not delete `.git/*.corrupt.backup` files before confirming the live equivalents are valid.
- Do not auto-delete branches under `.git/refs/heads/dependabot/` — they may have open PRs.
- Do not rewrite HEAD if `.git/logs/HEAD` has zero `checkout:` entries (fresh repo or reflog was pruned). In that case, fail loud and ask the user.

## References

- Coach report 2026-04-20 §Highest Leverage #1 and #2 — source evidence for this skill.
- `scripts/install.sh` lines 156-173 — pattern for a fail-fast preflight check this skill should mirror.

## Suggested install location

`skills/git-health-check/SKILL.md` + paired slash command at `commands/git-health-check.md`. Wire a one-shot PreToolUse hook on `Bash(git commit*)` / `Bash(git push*)` that runs just Check #1 (HEAD integrity) silently and warns if broken — minimal overhead, catches the known failure before it corrupts any new commits.
