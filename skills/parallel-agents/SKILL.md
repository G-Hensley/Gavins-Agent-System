---
name: parallel-agents
description: Dispatch multiple independent subagents concurrently for research or investigation. Use when facing 2+ independent problems, exploring a codebase from multiple angles, or when multiple unrelated failures need investigation simultaneously. Do NOT use for implementation tasks that could conflict — use subagent-driven-development for sequential implementation.
---

# Parallel Agents

Dispatch one agent per independent problem domain. Let them work concurrently. Review and integrate results.

## When to Use

- Multiple test files failing with different root causes
- Multiple independent subsystems broken
- Codebase exploration from different angles
- Research tasks that don't share state

## When NOT to Use

- Failures might be related (fix one might fix others) — investigate together first
- Agents would edit the same files or resources
- You don't yet know what's broken (explore first, then parallelize)
- Implementation tasks with ordering dependencies — use subagent-driven-development

## Process

### 1. Identify Independent Domains
Group problems by what's broken. Each domain must be solvable without context from the others.

### 2. Craft Focused Agent Prompts
Each agent gets:
- **Specific scope**: one file, subsystem, or question
- **Clear goal**: what to find or fix
- **Constraints**: what NOT to change
- **Expected output**: what to report back

### 3. Dispatch All in Parallel
Launch all agents in a single turn so they run concurrently.

### 4. Review and Integrate
- Read each summary
- Verify no conflicts between agents' changes
- Run full test suite
- Spot check — agents can make systematic errors

## Writing Good Agent Prompts

**Focused**: "Fix agent-tool-abort.test.ts" not "fix all the tests"
**Context-rich**: paste error messages and test names, don't just say "fix the race condition"
**Constrained**: "do NOT change production code" or "fix tests only"
**Specific output**: "return summary of root cause and changes" not "fix it"

## What NOT to Do

- Do not dispatch agents for related failures — they'll duplicate work or conflict
- Do not give agents vague scope — they get lost
- Do not skip the integration review — agents can introduce conflicts
- Do not skip the full test suite after integration
