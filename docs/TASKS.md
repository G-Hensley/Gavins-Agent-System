# Tasks

Cross-session task state for this project. Update as work moves.

For format, archive policy, and TodoWrite pairing, see the `task-tracking` skill in the agent system.

## In Progress

<!-- Tasks actively being worked on. Add `assignee:` and `PR:` when known. -->

## Backlog

<!-- Tasks queued but not started. Order roughly by priority; top is next. -->

### User-only actions (operator owns)

- [ ] [TASK-1] Dismiss Dependabot alert #21 manually
  - assignee: gavin
  - notes: alert references the pre-rename path `evals/review-challenges/dependency-vuln/requirements.txt`; file no longer exists at that path. Won't auto-close. Resolved in repo state by PR #11.

- [ ] [TASK-2] Live verify install on a fresh machine
  - assignee: gavin
  - notes: carried from PR #8's unchecked test items. Confirms the first-merge install path (no prior `~/.claude/settings.json`) still works end-to-end. Waits for opportunity — fresh box not currently available.

### Buildable

- [ ] [TASK-3] Stranger-fork-readiness — CLAUDE.md split, agent-memory exclusion, README tone
  - notes: multi-PR effort. See `improvements/system/stranger-fork-readiness.md` for the full proposal. Touches CLAUDE.md, README, agent-memory/ tracking, possibly install.sh. Probably 3–4 PRs.

- [ ] [TASK-4] Eval freshness — re-run Tier 2 + Tier 4
  - notes: evals dated 2026-04-03/04. Lots has shipped since: rules, hooks (JSON channel), genericization, orchestration skills, project-manager agent. Re-run before claiming system-stable. See `evals/run-eval.sh`.

- [ ] [TASK-5] Have `project-scaffolding` call `task-tracking:bootstrap` on new projects
  - notes: small follow-up to PR #14. Currently TASKS.md bootstrap is documented in the skill but `project-scaffolding` doesn't trigger it. Edit `skills/project-scaffolding/SKILL.md` to add the call.

- [ ] [TASK-6] `pr-check` skill should reference `project-orchestration` in its after-merge handoff
  - notes: small follow-up to PR #17. After merging, the natural next move depends on whether more tasks remain in the plan — point at `project-orchestration` for that decision.

## Done

<!-- Most recent at the top. When this section exceeds ~30 entries, archive the oldest to docs/TASKS.archive.md. -->

> Note: this `docs/TASKS.md` was bootstrapped on 2026-04-26 after PRs #9–#17 shipped. Pre-bootstrap shipped work is captured in `git log` and the PR list (https://github.com/G-Hensley/gavins-agent-system/pulls?q=is%3Apr+is%3Amerged), not here.
