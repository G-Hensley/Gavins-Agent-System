# New skill reference: agentic design patterns

## What I Observed

`skills/ai-engineering/references/sdk-patterns.md` covers multi-agent shapes (sequential, parallel, orchestrator) but the foundational single-agent patterns are missing. Multi-agent is built on top of single-agent — ReAct, Reflection, Planning, Human-in-the-Loop, and Evaluator-Optimizer are the primitives. Without them, the operator's `ai-engineer` agent has no shared vocabulary for "what shape should this loop be."

Missing patterns:

- **ReAct (Reason + Act)** — alternating thought/action/observation loop with iteration cap and graceful give-up. The default for tasks where the path isn't known upfront.
- **Reflection** — self-critique-revise (one model) or critic/generator (separate prompts). Quality-over-speed pattern.
- **Planning (plan-then-execute)** — explicit plan up front, then sequential execution. For complex multi-step tasks; reduces "cognitive entropy."
- **Human-in-the-Loop** — approval gates, confidence-based escalation, destructive-action confirmation. State machine, not in-memory.
- **Evaluator-Optimizer loop** — wraps any pattern with retry-on-fail, with retry cap and cost ceiling.
- **Pattern selection ladder** — Level 0 direct → Level 1 tool use → Level 2 ReAct → Level 3 plan+execute → Level 4 multi-agent. Don't skip levels.

## Why It Would Help

- The operator's `subagent-driven-development` workflow currently dispatches multi-agent without explicit guidance on whether ReAct or planning is the right shape per subagent
- "Maximum iteration count" and "cost ceiling" should be defaults the operator's agents inherit, not afterthoughts — multiple sources have hit infinite-loop bugs because the default was unbounded
- The pattern-selection ladder is the single most important decision in agent design and currently lives nowhere
- New agents the operator builds (or generates with `create-agent`) can declare which pattern they implement, making them more debuggable and composable

## Proposal

Create `skills/ai-engineering/references/agentic-design-patterns.md` with sections:

- Pattern selection ladder (Level 0–4) at the top, with one-line decision criterion per level
- ReAct — loop structure, iteration cap default (5–15), give-up clause for system prompts, logging requirements
- Reflection — self vs. external, evaluation criteria specificity, revision cap (2–3), cheaper-model-for-critic pattern
- Planning — when to use vs. ReAct, plan revision, dependency tracking, model split (planner ≥ executor)
- Human-in-the-Loop — approval gates, escalation thresholds, confirmation for destructive actions, state machine implementation note
- Evaluator-Optimizer — retry cap, cost ceiling, criteria specificity, log-every-eval requirement
- Anti-pattern list — unbounded loops, vague critic prompts, planning when requirements are unclear

Update `agents/ai-engineer.md` and `agents/architect.md` to load this when designing agentic systems.

## Open questions for review

- Should this live under ai-engineering or as its own top-level skill (`agentic-patterns/`)? Lean toward ai-engineering ref — the operator's stack already groups AI work there.
- Should each pattern have a code skeleton (Python or TS)? Yes, short. The operator's agents will reach for a template; better that the template come from a vetted reference than be invented per-task.
