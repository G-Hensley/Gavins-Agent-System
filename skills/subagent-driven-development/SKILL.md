---
name: subagent-driven-development
description: Execute implementation plans by dispatching fresh subagents per task with two-stage review. Use when executing multi-task plans, when the user chooses subagent-driven execution, or when tasks are independent enough for isolated implementation. Prefer this over executing-plans for any plan with more than 2-3 tasks.
---

# Subagent-Driven Development

Dispatch a fresh subagent per task from a plan. After each task: spec compliance review, then code quality review. This keeps context clean and catches issues early.

## Process

### 1. Extract All Tasks
- Read the plan file once
- Extract every task with its full text and context
- Create a todo list tracking all tasks

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

**e) Mark task complete**, move to next.

### 3. Final Review
After all tasks: dispatch a final code reviewer for the entire implementation.

### 4. Finish
Use `finishing-a-development-branch` skill to handle merge/PR/cleanup.

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

## Agent Prompts

- `implementer` subagent (in `~/.claude/agents/`) — Dispatch implementer subagent per task
- `spec-reviewer` subagent (in `~/.claude/agents/`) — Verify implementation matches spec (nothing more, nothing less)
- `code-quality-reviewer` subagent (in `~/.claude/agents/`) — Verify implementation quality after spec passes
