---
name: executing-plans
description: Execute an implementation plan inline in the current session. Use for small-to-medium plans when subagent-driven development is overkill, or when the user chooses inline execution after writing a plan. Also use when the user says "execute this plan", "run through the plan", or "implement this".
---

# Executing Plans

Load a plan, review it critically, execute each task sequentially in the current session. For larger plans, prefer `subagent-driven-development` instead.

## Process

### 1. Load and Review
- Read the plan file completely
- Identify any questions, gaps, or concerns
- If concerns: raise them with the user before starting
- If clear: proceed to execution

### 2. Execute Tasks
For each task in order:
1. Follow each step exactly as written
2. Run verifications as specified — do not skip
3. Mark steps complete as you go
4. Commit after each task

### 3. Complete
After all tasks pass verification:
- Run full test suite
- Use `finishing-a-development-branch` skill to handle merge/PR/cleanup

## When to Stop

Stop executing immediately and ask for help when:
- Hit a blocker (missing dependency, unclear instruction, repeated test failure)
- Plan has critical gaps
- You don't understand a step
- Verification fails after 2 attempts

Ask for clarification rather than guessing. Do not force through blockers.

## What NOT to Do

- Do not skip verifications
- Do not deviate from the plan without user approval
- Do not guess when blocked — stop and ask
- Do not start on main/master branch without explicit consent
