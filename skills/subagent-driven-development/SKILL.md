---
name: subagent-driven-development
description: Execute implementation plans by dispatching fresh subagents per task with two-stage review and per-task PR rhythm. Use when executing multi-task plans, when the user chooses subagent-driven execution, or when tasks are independent enough for isolated implementation. Prefer this over executing-plans for any plan with more than 2-3 tasks.
last_verified: 2026-04-26
---

# Subagent-Driven Development

Dispatch a fresh subagent per task from a plan. After each task: spec review, quality review, then commit/push/PR. Default is one PR per task, not one PR per plan — small focused PRs over a single giant one.

## Process

### 1. Extract All Tasks
- Read the plan file once
- Extract every task with its full text and context
- Create a todo list tracking all tasks
- If `docs/TASKS.md` exists, load it; otherwise call the `task-tracking` skill to bootstrap

### 2. Per Task Loop

For each task:

**a) Dispatch implementer** (`implementer` subagent)
- Provide full task text — do not make the subagent read the plan file
- Include scene-setting context: where this fits, dependencies, architectural notes
- Let them ask questions before starting

**b) Handle implementer status:**
- **DONE** → proceed to review
- **DONE_WITH_CONCERNS** → read concerns, address if about correctness, then review
- **NEEDS_CONTEXT** → provide missing context, re-dispatch
- **BLOCKED** → assess: provide more context, use a more capable model, split the task, or escalate to user

**c) Spec compliance review** (`spec-reviewer` subagent)
- Did they build what was requested? Nothing missing, nothing extra.
- If issues: implementer fixes, reviewer re-reviews. Repeat until approved.

**d) Code quality review** (`code-quality-reviewer` subagent)
- Only after spec compliance passes
- Clean, tested, maintainable, follows existing patterns?
- If issues: implementer fixes, reviewer re-reviews. Repeat until approved.

**e) Per-task git rhythm** (orchestrator — main conversation, not the implementer subagent)
- Stage only files touched by this task
- Commit with `type(scope): description` per CLAUDE.md format
- Push to the task's branch (one branch per task by default — see PR Modes)
- Open a PR via `gh pr create` (uses `git-workflow` Phase 3 templates)
- Update `docs/TASKS.md` to move the task from `In Progress` to `Done` (linked to the new PR number); see the `task-tracking` skill for the exact format
- **Do not wait for review** before starting the next task unless the next task depends on this one's branch

**f) Mark task complete in the in-session todo list, move to next.**

### 3. Final Review
After all tasks: dispatch a final code reviewer for the entire plan if a final-pass review is needed. Optional — most plans don't need it because per-task review already covered every change.

### 4. Finish
Most plans are already shipped at this point (per-task PRs merge as they're approved). For tightly-coupled refactors using Single-PR mode, use `git-workflow` Phase 3 (`finishing-a-development-branch`) for the final merge.

## PR Modes

### Default: per-task PR
One PR per task. Small, focused, independently reviewable. Bisect/rollback granularity is the task. This is the default — do not deviate without a reason.

### Stack-PRs mode (opt-in)
When task N+1 depends on N's branch and review wait would block, base N+1 on N's branch and note the stack in N+1's PR description (e.g., `Stacked on #<n>`). Merge N first, then N+1 rebases onto main automatically when N's PR closes.

### Single-PR mode (opt-in, request up front)
For tightly-coupled refactors where task-level review adds no value, the operator can request "single PR" before execution. All tasks land on one branch, one PR opens at the end via `git-workflow` Phase 3. Justify the choice in the PR description.

## Model Selection

Use the least powerful model that handles each role:
- **Mechanical tasks** (1-2 files, clear spec): fast/cheap model
- **Integration tasks** (multi-file, coordination): standard model
- **Design/review tasks** (judgment, broad understanding): most capable model

## What NOT to Do

- Do not dispatch multiple implementers in parallel — they'll conflict
- Do not make subagents read the plan file — provide full task text directly
- Do not skip either review stage
- Do not proceed with unfixed review issues
- Do not start code quality review before spec compliance passes
- Do not ignore subagent questions or force retry without changes
- Do not start on main/master without user consent
- Do not let subagent self-review replace actual review — both are needed
- **Do not batch all tasks into one PR by default** — Single-PR mode is opt-in, requested up front, and justified in the PR description
- **Do not skip updating `docs/TASKS.md` between tasks** — the canonical state is the file, not the agent's memory
- Do not have the implementer subagent open the PR — git rhythm is the orchestrator's job (the implementer is single-task scoped)

## Agent Prompts

- `implementer` subagent (in `~/.claude/agents/`) — Dispatch per task. Owns: code changes, tests, self-review. Does NOT own: commit/push/PR.
- `spec-reviewer` subagent — Verify implementation matches spec (nothing more, nothing less)
- `code-quality-reviewer` subagent — Verify implementation quality after spec passes
- The **orchestrator** (main conversation) owns workflow control between tasks: dispatch order, per-task git rhythm, TASKS.md updates

## References

- `task-tracking` skill — `docs/TASKS.md` substrate, format, and status-move semantics referenced in step 2e
- `git-workflow` skill — Phase 2 (commit/push) and Phase 3 (PR creation, finishing-branch) for the mechanics inside step 2e
- `parallel-agents` skill — for tasks that are genuinely independent and worth dispatching concurrently (rare; default is sequential because most "independent" tasks share at least one file)
