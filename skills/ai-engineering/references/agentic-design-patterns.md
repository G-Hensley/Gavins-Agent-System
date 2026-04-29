# Agentic Design Patterns

## Pattern Selection Ladder

Pick the lowest level that solves the problem. Don't skip levels.

| Level | Pattern | Use when |
|-------|---------|---------|
| 0 | Direct call | Single LLM call; output is the answer |
| 1 | Tool use | Need to fetch data or take an action, path is known |
| 2 | ReAct | Path unknown; agent must reason about which tools to call |
| 3 | Plan + Execute | Task has ≥ 3 dependent steps; upfront decomposition reduces entropy |
| 4 | Multi-agent | Task has parallel independent workstreams or requires specialist models |

---

## ReAct (Reason + Act)

Loop: **Thought → Action → Observation → repeat → Answer**

Use when the agent doesn't know the sequence of steps ahead of time.

```python
MAX_ITER = 10  # hard cap; default 5–15 depending on task complexity

for i in range(MAX_ITER):
    response = llm.call(messages=history)
    if response.is_final_answer:
        return response.answer
    tool_result = tools[response.tool_name](response.tool_args)
    history.append({"role": "tool", "content": tool_result})
    log.info("iter=%d tool=%s", i, response.tool_name)

raise AgentGiveUpError("max iterations reached")
```

**System prompt clause (required):**
> If you cannot complete the task within the allowed steps, respond with `GIVE_UP:` followed by the reason — do not loop indefinitely.

**Logging:** log every (iteration, tool, args, result) — without this, debugging loops is blind.

---

## Reflection

Use when quality matters more than speed. Apply after an initial draft exists.

**Self-reflection** — one model critiques its own output:
```python
draft = generator.call(task_prompt)
critique = generator.call(f"Critique this output:\n{draft}\nBe specific.")
revised = generator.call(f"Revise based on:\n{critique}\nOriginal:\n{draft}")
```

**External critic** — separate prompt, optionally a cheaper model:
```python
draft = big_model.call(task_prompt)
critique = cheap_model.call(f"Evaluate: {draft}\nCriteria: {criteria}")
if critique.score < threshold:
    revised = big_model.call(f"Revise: {draft}\nFeedback: {critique.feedback}")
```

**Rules:**
- Revision cap: 2–3 rounds; more rarely helps and adds cost
- Criteria must be specific: "Is the function under 20 lines and does it handle None?" — not "Is it good?"
- Vague criteria → empty critiques → wasted tokens (see Anti-patterns)

---

## Planning (Plan-then-Execute)

Use over ReAct when the task has clear multi-step structure and requirements are stable.

```python
plan = planner_model.call(f"Create a numbered step-by-step plan for:\n{task}")
# planner_model should be >= executor_model in capability
results = []
for step in parse_steps(plan):
    result = executor_model.call(f"Execute:\n{step}\nContext so far:\n{results}")
    results.append(result)
    if result.requires_plan_revision:
        plan = planner_model.call(f"Revise plan:\n{plan}\nBlocker:\n{result.error}")
```

**When to use Planning over ReAct:**
- You can enumerate the steps before starting
- Steps have explicit dependencies (step 3 needs output of step 2)
- Failure in one step should halt or revise — not blindly continue

**Model split:** planner should be the same capability or higher than the executor. Don't use Haiku to plan and Opus to execute.

**Dependency tracking:** if steps are independent, run them in parallel (see `sdk-patterns.md` Parallel Dispatch).

---

## Human-in-the-Loop

Don't treat human approval as an afterthought. Design as a state machine.

```python
def maybe_escalate(action, confidence):
    if action.is_destructive or confidence < CONFIDENCE_THRESHOLD:
        approval = human_queue.request_approval(action, timeout=300)
        if not approval.approved:
            raise HumanRejectedError(approval.reason)
    return execute(action)
```

**Gates:**
- **Destructive actions** (delete, send, publish, deploy): always confirm — no confidence bypass
- **Low confidence** (< threshold you set): escalate before acting, not after
- **High-cost actions** (bulk writes, external API calls): confirm count + cost estimate

**State machine note:** store approval state externally (DB, queue) — never in memory. The agent may restart between the request and the approval.

---

## Evaluator-Optimizer

Wraps any other pattern with retry-on-fail. Use when output quality is measurable.

```python
MAX_RETRIES = 3
COST_CEILING = 0.50  # USD; adjust per task

total_cost = 0.0
for attempt in range(MAX_RETRIES):
    result = generate(prompt)
    total_cost += result.cost
    eval_result = evaluate(result.output, criteria)
    log.info("attempt=%d score=%.2f cost=$%.4f", attempt, eval_result.score, result.cost)
    if eval_result.passed or total_cost >= COST_CEILING:
        break
    prompt = refine_prompt(prompt, eval_result.feedback)

return result
```

**Rules:**
- Retry cap: 3 is usually the ceiling; beyond that, escalate or fail loudly
- Cost ceiling: set one; see `./cost-optimization-and-routing.md`
- Criteria specificity: same as Reflection — specific and measurable
- Log every eval: score, attempt, cost — required for debugging and cost attribution
- See `./evaluation-and-observability.md` for eval harness patterns

---

## Anti-Patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| Unbounded loop | Agent runs until timeout or OOM | Set `MAX_ITER` and a GIVE_UP clause |
| Vague critic prompt | "Is this good?" returns useless feedback | Specify exact criteria, format, and scale |
| Planning with unclear requirements | Plan is immediately wrong; replanning loops | Use ReAct until requirements stabilize |
| Reflection without criteria | Critique is generic; revision is random | Define evaluation rubric before calling critic |
| Human gate in memory | Approval lost on agent restart | Persist gate state in DB or queue |
| Skipping iteration logs | Loops impossible to debug | Log every (iter, tool, score, cost) |
| Multi-agent for a single-thread task | Coordination overhead > task complexity | Apply the selection ladder; start at Level 0 |
