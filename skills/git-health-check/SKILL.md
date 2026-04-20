---
name: git-health-check
description: Detect and optionally repair common `.git/` corruption patterns — truncated HEAD refs, stale `.corrupt.backup` artifacts, dangling `.lock` files, and stranded dependabot branches. Use when git commands start misbehaving ("No commits yet" on a repo that clearly has commits, "your current branch appears to be broken", commits that refuse to land) or as a weekly hygiene pass.
last_verified: 2026-04-20
---

# Git Health Check

Proactively check for and repair the git-level corruption patterns observed in `gavins-agent-system` on 2026-04-17 (`.corrupt.backup` artifacts from crashed writers) and 2026-04-18 (truncated HEAD).

**Announce at start:** "Running git-health-check on this repo."

## Process

### 1. HEAD integrity

Read `.git/HEAD`. It must match one of:

- `ref: refs/heads/<name>\n` where the file at `.git/refs/heads/<name>` exists and contains a valid sha, **OR**
- a single 40-char hex sha followed by newline (detached HEAD).

Failure modes to detect:

- **Trailing-slash truncation**: matches `^ref: refs/heads/.*/$` (the observed 2026-04-18 bug).
- **Missing newline**: content does not end with `\n`.
- **Ref target missing**: `ref: refs/heads/<name>` points to a file that doesn't exist under `.git/refs/heads/<name>` AND the ref doesn't appear in `.git/packed-refs`.
- **Detached-but-invalid**: HEAD is a 40-char hex sha that `git cat-file -e` can't resolve.

If any fail: report the exact failure, offer to repair. Repair logic for the trailing-slash truncation: walk `.git/logs/HEAD` bottom-up looking for the most recent `checkout:` line, extract the branch name after "to ", and rewrite HEAD.

### 2. Corruption artifacts

`ls .git/*.corrupt* .git/*.bak .git/*.orig 2>/dev/null`. Any match = noise from a prior recovery. Report filenames + dates. Offer to delete after confirming live equivalents are valid (byte-compare live vs `.corrupt.backup`; the live file must be intact).

### 3. Dangling locks

`find .git -maxdepth 2 -name "*.lock" -type f`. Any `.lock` file older than 5 minutes is almost certainly a crashed writer. Check `fuser` / `lsof` to confirm no live process holds it, then offer to delete.

### 4. Stranded dependabot branches

`ls -la .git/refs/heads/dependabot/**/` (if dir exists). Report the count + dates. Do not auto-delete — dependabot branches may have legitimate PRs associated. Instead, link to `https://github.com/<owner>/<repo>/network/updates` so the user can close them in the UI.

### 5. Remote vs. local divergence sanity

Run `git fetch --dry-run origin 2>&1 | head` (safe, no side effects) and surface any "would fetch ...rejected..." lines — they indicate force-pushes or branch deletions that can destabilize local refs.

### 6. External writer presence

Report presence and last-modified time of:

- `.git/gk/` (GitKraken — implicated in 2026-04-17/18 corruption on this repo)
- `.git/filter-repo/` (residual state from prior `git filter-repo` runs)

These are not fatal; they're signal that a third-party tool is writing to `.git/`. If corruption is recurring, recommend closing the external tool before terminal git work.

## Output

Single table. Columns: Check | Status (OK / WARN / FAIL) | Details | Suggested fix.

If any FAIL, end with: "Run `/git-health-check --fix` to apply the safe repairs."

## What NOT to Do

- Do not run `git fsck --full` unprompted — it's slow and noisy.
- Do not delete `.git/*.corrupt.backup` files before confirming the live equivalents are valid via byte-compare.
- Do not auto-delete branches under `.git/refs/heads/dependabot/` — they may have open PRs.
- Do not rewrite HEAD if `.git/logs/HEAD` has zero `checkout:` entries (fresh repo or reflog was pruned). In that case, fail loud and ask the user.
- Do not delete `.git/gk/` while GitKraken is running — triggers the exact mid-write corruption this skill protects against.

## References

- Coach report 2026-04-20 §Highest Leverage #1 and #2 — source evidence for this skill.
- `scripts/install.sh` lines 156-173 — pattern for a fail-fast preflight check.
