---
name: product-management
description: Create product requirements, user stories, and specifications from brainstormed ideas. Use when transitioning from brainstorming to requirements, when the user needs a PRD, user stories, acceptance criteria, user flows, prioritization, or when scoping a new product or major feature set. Also use when the user says "write a PRD", "define requirements", "user stories", or "prioritize features".
---

# Product Management

Transform brainstormed ideas into structured product requirements. Takes a decision from brainstorming and produces a complete product spec that architecture can build from.

## When to Use

- After brainstorming converges on a project-level direction
- When the user needs formal product documentation
- When multiple features need prioritization and scoping
- When user stories and acceptance criteria are needed

## Process

### 1. Capture the Decision
- Confirm the brainstormed direction with the user
- Identify target users, core problem, and success criteria
- If no brainstorm happened, run a quick scope check: who is this for, what problem does it solve, what does done look like

### 2. Define the Product
- **Problem statement**: one paragraph on what problem this solves and why it matters
- **Target users**: who uses this, what are their goals
- **Success metrics**: how do we know this worked (quantitative where possible)
- **Scope boundaries**: what this is NOT — explicit exclusions prevent creep

### 3. Break Down Features
- List features grouped by priority using MoSCoW:
  - **Must have**: product doesn't work without these
  - **Should have**: important but not blocking launch
  - **Could have**: nice to have if time allows
  - **Won't have (this iteration)**: explicitly deferred
- For each Must Have feature, write user stories with acceptance criteria

### 4. User Stories and Acceptance Criteria
Format each story as:
```
As a [user type], I want to [action] so that [outcome].

Acceptance Criteria:
- [ ] Given [context], when [action], then [result]
- [ ] Given [context], when [action], then [result]
```
Keep stories small enough to implement in a single plan cycle. Split large stories.

### 5. Map User Flows
For key workflows, describe the step-by-step user journey:
```
1. User lands on [page/screen]
2. User [action]
3. System [response]
4. User [next action]
...
```
Note decision points, error states, and edge cases at each step.

### 6. Write the PRD
Save to project docs (e.g., `docs/prd/YYYY-MM-DD-<project>-prd.md`). Include:
- Problem statement
- Target users
- Success metrics
- Scope boundaries
- Feature breakdown (MoSCoW)
- User stories with acceptance criteria
- User flows for key workflows
- Open questions (if any remain)

### 7. Review and Hand Off
- Dispatch product-reviewer agent (`product-reviewer` subagent)
- Fix issues, re-dispatch (max 3 iterations, then surface to user)
- Ask user to review the PRD before proceeding
- Hand off to `architecture` skill for technical design

## What NOT to Do

- Do not make technical decisions — that's architecture's job
- Do not write implementation plans — that's writing-plans
- Do not skip scope boundaries — undefined scope is the #1 cause of project failure
- Do not write stories so large they can't be implemented in one cycle — split them
- Do not prioritize everything as "Must Have" — force trade-offs

## Reference Files

- `references/pm-artifacts.md` — PRD template, user story format, user flow format, MoSCoW prioritization, impact/effort matrix, competitive analysis. Read when writing the PRD (Step 6).
- `product-reviewer` subagent (in `~/.claude/agents/`) — Subagent prompt for reviewing PRDs. Read when dispatching review (Step 7).
