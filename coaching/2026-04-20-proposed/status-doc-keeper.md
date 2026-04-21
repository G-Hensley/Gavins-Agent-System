---
name: status-doc-keeper
description: Keep docs/STATUS.md current with structural changes. Runs as a PostToolUse hook on git commits that touch skills/, agents/, commands/, rules/, hooks/, or config/. Warns (fail-open) when STATUS.md's "Last updated:" line is older than the commit date or when a new skill/agent/command/rule/hook was added without a matching row in the Improvements Roadmap table.
last_verified: 2026-04-20
---

# Status Doc Keeper

> **Historical starter proposal from the 2026-04-20 coach report.** This skill did **not** ship as a standalone hook. The intent was rolled into [`scripts/hooks/doc-drift-check.sh`](../../scripts/hooks/doc-drift-check.sh) as a second check, which uses the correct `scripts/hooks/` path in its structural-path matcher (the draft below uses a non-existent top-level `hooks/`). Preserved here as the record of what the coach proposed, not as a template to copy.

The doc-sync skill was meant to catch STATUS.md drift. It's listed as "optional step 11" in `docs/SKILL-CHAINS.md` and fired zero times between 2026-04-16 and 2026-04-20 while 12 structural-change commits landed. This skill converts doc-sync's intent into a non-optional commit-time gate.

**Fail-open by design** — this never blocks a commit. It warns loudly so the next session sees the drift.

## Process

### 1. Detect a structural-change commit

Shell side (in `scripts/hooks/status-doc-keeper.sh`):

```bash
# Triggered from config/hooks.json PostToolUse on Bash(git commit*)
# Read the last commit's changed files via git log -1 --name-only HEAD
changed="$(git log -1 --name-only --pretty= HEAD 2>/dev/null)"
echo "$changed" | grep -qE '^(skills|agents|commands|rules|hooks|config)/' || exit 0
```

If no structural-path file changed, exit 0 silent.

### 2. Compare `docs/STATUS.md` freshness

Extract the `Last updated:` line. If it's older than the HEAD commit's author date by more than 3 days (grace period for related prep commits), emit:

```
[status-doc-keeper] WARNING: docs/STATUS.md is stale.
  Last updated: 2026-04-16
  Latest structural commit: 2026-04-20 (abc1234 feat: add codex-plan-review skill)
  Affected paths: skills/codex-plan-review/, rules/codex-plan-review.md, evals/tier-1-single-agent/codex-plan-review/
  Fix: invoke the doc-sync skill or run `/doc-sync` to backfill the Improvements table.
```

### 3. Detect unlisted structural adds

For each `A<tab>skills/<name>/SKILL.md` in `git log -1 --name-status --pretty= HEAD`: ensure `docs/STATUS.md` mentions the name at least once (case-insensitive substring). Same for new agents / rules / commands / hooks. Missing mention = warn.

### 4. Suggest the exact row to add

If `STATUS.md` has an Improvements Roadmap table, emit a pre-formatted row the user can paste:

```
| 15 | Codex Plan Review skill | Done | skills/codex-plan-review/ + rules/codex-plan-review.md + 8 tier-1 fixtures |
```

Row number = next integer after the current max.

## Install

1. Add `scripts/hooks/status-doc-keeper.sh` (script as sketched above).
2. Edit `config/hooks.json` — add to `PostToolUse`:
   ```json
   {
     "matcher": "Bash(git commit*)",
     "hooks": [
       { "type": "command", "command": "'REPO_DIR/scripts/hooks/status-doc-keeper.sh'", "timeout": 5 }
     ]
   }
   ```
3. Re-run `bash scripts/install.sh` so the hook propagates into `~/.claude/`.
4. Verify: make any test commit under `skills/`, observe the warning.

## What NOT to do

- Do not block the commit — this is advisory.
- Do not rewrite `docs/STATUS.md` automatically from a hook. Keep the human in the loop for the actual content of the Improvements row.
- Do not fire on every commit — only on commits touching `skills/|agents/|commands/|rules/|hooks/|config/`. Doc-only and eval-only commits should not trigger.
- Do not cross-check against `CLAUDE.md` / `CONTEXT.md` / `README.md` counts here — that's doc-sync's job. This skill narrowly owns `STATUS.md` freshness.

## References

- Coach report 2026-04-20 §Highest Leverage #3 — source evidence (12 commits, zero STATUS.md updates, doc-sync listed as optional).
- `docs/SKILL-CHAINS.md` line 25 — the current "optional step 11" framing that this hook upgrades.
- `scripts/hooks/doc-drift-check.sh` — existing neighbor hook to model after.

## Related

- Pair with `doc-sync` skill: this hook *detects* drift, `doc-sync` *fixes* drift.
- Pair with a future `/weekly-status` command that renders the last-7-days commit delta into a STATUS.md row suggestion.
