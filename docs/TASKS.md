# Tasks

Tactical, in-flight work for this project. For the strategic spine — versioned phases, exit criteria, dogfood milestones — see [ROADMAP.md](./ROADMAP.md).

For format, archive policy, and TodoWrite pairing, see the `task-tracking` skill in the agent system.

## In Progress

<!-- Tasks actively being worked on. Add `assignee:` and `PR:` when known. -->

## Backlog

### Active phase: §6 Baseline (blocks v0)

The §6 baseline is the prerequisite gate to every Hexodus version — without measured starting numbers, no version's improvement claim is credible. See [ROADMAP.md §6](./ROADMAP.md#6-baseline-measurement-the-step-before-v0).

- [ ] [TASK-8] Audit existing `evals/run-eval.sh` harness against the 18 scenarios
  - notes: catalog any scenarios that fail for non-agent reasons (stale prompts, broken fixtures). Fix those first — broken scenarios pollute the baseline. Per ROADMAP §6.4 step 1.
  - estimate: 0.5–1 day

- [ ] [TASK-9] Patch `evals/run-eval.sh` with token + trace + judge metrics
  - notes: ~250 LOC under `evals/lib/`. Three modules: token+trace extractor (~100 LOC), LLM-as-judge grader (~150 LOC + prompt template), aggregator. Hook into `evals/run-eval.sh` after each scenario completes. Per ROADMAP §6.3.
  - estimate: 1–2 days
  - blocked by: TASK-8

- [ ] [TASK-10] Triple-run all 18 scenarios + write evals/BASELINE.md
  - notes: 3 runs per scenario, median + range scoring. Lock Claude model version in BASELINE.md. Tag the git SHA — v0 begins from that commit. Per ROADMAP §6.4 steps 3–5 and §6.5.
  - estimate: ~4h wall-clock + 0.5 day write-up
  - blocked by: TASK-9

### User-only actions (operator owns)

- [ ] [TASK-1] Dismiss Dependabot alert #21 manually
  - assignee: gavin
  - notes: alert references the pre-rename path `evals/review-challenges/dependency-vuln/requirements.txt`; file no longer exists at that path. Won't auto-close. Resolved in repo state by PR #11.

- [ ] [TASK-2] Live verify install on a fresh machine
  - assignee: gavin
  - notes: carried from PR #8's unchecked test items. Confirms the first-merge install path (no prior `~/.claude/settings.json`) still works end-to-end. Folds into the v0 install round-trip exit criteria once that phase begins.

## Done

<!-- Most recent at the top. When this section exceeds ~30 entries, archive the oldest to docs/TASKS.archive.md. -->

- [x] [TASK-11] Promote AI Engineering improvements bundle (13 items)
  - closed via #28 (2026-04-29)
  - notes: 10 new `skills/ai-engineering/references/` (agentic-design-patterns, context-management, tool-design, structured-output, mcp-engineering, rag-engineering, streaming-patterns, cost-optimization-and-routing, llm-security, evaluation-and-observability) + prompt-engineering basics/advanced split + `agents/llm-evaluator.md` (Sonnet) + `rules/llm-evals.md`. SKILL.md surfaces all 11 refs; 8 cross-cutting agents now load `ai-engineering`. Two cross-bundle TODOs to `websocket-security.md` resolve when Security bundle ships. Per [ROADMAP v0](./ROADMAP.md#v0--plugin-port-existing-system-repackaged) bundle plan; first of 4 bundles before §6 baseline.

- [x] [TASK-3] Stranger-fork-readiness — superseded by Hexodus v0
  - closed via #26 (2026-04-28)
  - notes: CLAUDE.md split, agent-memory exclusion, README tone, and APIsec sanitization all become exit criteria of [ROADMAP v0](./ROADMAP.md#v0--plugin-port-existing-system-repackaged). The `improvements/system/stranger-fork-readiness.md` proposal still applies as v0 source material.

- [x] [TASK-7] Refresh Tier 4 eval rubric — superseded by §6 baseline
  - closed via #26 (2026-04-28)
  - notes: Rubric refresh is now part of the LLM-as-judge grader work in [ROADMAP §6.3](./ROADMAP.md#63-harness-patches-required). The existing `eval-criteria.md` files become input to the grader prompt template — no separate refresh pass needed.

- [x] [TASK-4] Eval freshness — audit pass complete
  - closed via #24 (2026-04-26)
  - notes: audit-only — no mechanical re-runs (would have cost $50–150 against a rubric that's stale for Tier 4). Tier 2 = pass-by-inspection (LOW regression risk). Tier 4 deferred to TASK-7 (rubric refresh first). See `evals/AUDIT-2026-04-26.md` and `docs/STATUS.md` "Freshness Audit (2026-04-26)" section.

- [x] [TASK-6] `pr-check` skill references `project-orchestration` in its after-merge handoff
  - closed via #22 (2026-04-26)
  - notes: PR #21 originally authored this work but merged into its parent branch (`feat/project-scaffolding-bootstrap-tasks-md`) instead of `main` due to a stacked-PR mishap. Re-landed on `main` via #22.

- [x] [TASK-5] Have `project-scaffolding` call `task-tracking:bootstrap` on new projects
  - closed via #19 (2026-04-26)

> Note: this `docs/TASKS.md` was bootstrapped on 2026-04-26 after PRs #9–#17 shipped. Pre-bootstrap shipped work is captured in `git log` and the PR list (https://github.com/G-Hensley/hexodus/pulls?q=is%3Apr+is%3Amerged), not here.
