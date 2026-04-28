# Proposed: router-eval (Tier-0 eval suite)

A new `evals/router/` directory testing only the dispatch decision — does the right skill activate for a given one-line task description? With 39 skills + 25 agents + 12 rules + 8 commands + plugin skills layered on top, the router IS the system; an untested router is the single point of failure for the whole stack.

## Why this beats the current setup

Current evals (Tier 1–4) test downstream output quality after the router has chosen a skill/agent. They don't tell you whether the *choice* was correct, only whether the *execution* was OK once chosen. When `skill-router/SKILL.md` is edited, when a new skill claims overlapping triggers, or when CLAUDE.md dispatch table changes, you have no fast feedback loop until a real task surfaces a misroute.

Tier-0 router eval is cheap (no agent dispatch, no LLM tool-use cycle beyond the routing decision), fast (5-10 fixtures runnable in <60 seconds), and exact-fit for the failure mode that matters most as the skill count grows.

## Files to add

### `evals/router/README.md`

```markdown
# Router Evals (Tier 0)

Tests dispatch-only decisions. Each fixture is `(task_description, expected_dispatch)`.
A pass = the model picks the expected skill (or skill-chain root) as its first action
when shown only the task description and the global CLAUDE.md / skill-router context.

Run: `bash evals/run-eval.sh --tier 0`

Add a fixture when:
- A new skill ships with overlapping triggers vs. an existing skill (likely router collision).
- A real task gets misrouted in a session — capture it as a regression fixture.
- A new plugin adds skills that compete with local skills for the same trigger phrases.
```

### `evals/router/fixtures/build-cli.json`

```json
{
  "id": "router-001-build-cli",
  "task": "build me an email parser CLI",
  "expected_first_dispatch": "project-orchestration",
  "rationale": "End-to-end 'build me X' triggers the master pipeline per skill-router routing table; project-orchestration in turn calls brainstorming as its first phase."
}
```

### `evals/router/fixtures/git-corruption.json`

```json
{
  "id": "router-002-git-corruption",
  "task": "I'm getting 'No commits yet' on a repo that obviously has commits",
  "expected_first_dispatch": "git-health-check",
  "rationale": "Direct trigger phrase from skills/git-health-check/SKILL.md description. Should not route to systematic-debugging — git-health-check is the more specific match."
}
```

### `evals/router/fixtures/legal-contract.json`

```json
{
  "id": "router-003-legal-contract",
  "task": "review this MSA from a vendor — should we sign?",
  "expected_first_dispatch": "legal:review-contract",
  "rationale": "Plugin-namespaced skill should win over any local 'review' skill (commands/review.md, code-review skill). Tests that plugin skills are visible to the router and beat local matches when domain-specific."
}
```

### `evals/router/fixtures/task-status.json`

```json
{
  "id": "router-004-task-status",
  "task": "what's still on my plate for this project",
  "expected_first_dispatch": "task-tracking",
  "rationale": "Direct trigger phrase from task-tracking SKILL.md description ('what's next', 'where are we'). Should not route to productivity:task-management (that one is for personal TASKS.md across all work, not project-scoped TASKS.md)."
}
```

### `evals/router/fixtures/scaffold-ts.json`

```json
{
  "id": "router-005-scaffold-ts",
  "task": "scaffold a new TypeScript project for me",
  "expected_first_dispatch": "project-scaffolding",
  "rationale": "Direct match. project-scaffolding in turn calls task-tracking:bootstrap. Should not route to project-orchestration (that's for the full pipeline; scaffolding is a phase within it)."
}
```

### `evals/run-eval.sh` (edit — add Tier 0 handler)

Extend the existing `--tier` flag to accept `0` and route to `evals/router/`. Implementation sketch:

```bash
case "$TIER" in
  0)
    # Router-only — no agent dispatch, no full execution.
    # Execute by piping task description into a router-only Claude invocation
    # and parsing the first chosen skill/agent from the response.
    for fixture in evals/router/fixtures/*.json; do
      task=$(jq -r .task "$fixture")
      expected=$(jq -r .expected_first_dispatch "$fixture")
      # Capture only the first skill/agent name from a router-prompted invocation.
      # Use a constrained system prompt: "You will be given a task. Respond with ONLY the
      # name of the FIRST skill or agent you would dispatch. No prose. Format: name only."
      actual=$(claude -p --system-prompt "You will be given a task. Respond with ONLY the name of the first skill or agent you would dispatch. No prose. Format: skill_or_agent_name only, lowercase, kebab-case." -- "$task")
      if [ "$actual" = "$expected" ]; then
        echo "PASS: $(basename $fixture .json) → $actual"
      else
        echo "FAIL: $(basename $fixture .json) → got '$actual', expected '$expected'"
      fi
    done
    ;;
esac
```

## Run cost

Each fixture is one short Claude invocation, no tool dispatch. ~$0.001 per fixture (Haiku 3.5) or ~$0.005 (Sonnet 4). 5-10 fixtures = under $0.05/run. Cheap enough to run on every commit that touches `skills/`, `agents/`, `rules/`, or `CLAUDE.md`.

## Wire into hooks

After this lands, add to `config/hooks.json` PostToolUse `Bash(git commit *)`: if the commit touches `skills/|agents/|rules/|CLAUDE.md|skills/skill-router/`, run `bash evals/run-eval.sh --tier 0` and warn-open on any FAIL. Same fail-warn-don't-block pattern as the doc-drift hook.

## Followup

When the skill count crosses ~50, or when the first router regression is caught by this suite, expand fixture count. Don't over-build at first — 5 seed fixtures cover the load-bearing dispatches; add fixtures only when a real misroute happens.
