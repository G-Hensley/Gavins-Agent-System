# Establish eval suite infrastructure pattern

## What I Observed

Once the AI engineering improvements land (especially `evaluation-and-observability.md` and the `llm-evaluator` agent), the operator's projects will need a *consistent place* for eval suites to live and a *consistent way* to run them in CI. Without that pattern, every project invents its own eval directory layout, runner, and CI integration — which defeats the point of having a shared agent and skill.

This is system-level rather than skill-level because the action is "decide on a convention" — a one-time architectural choice that everything downstream depends on.

## Why It Would Help

- The operator's existing pattern uses `docs/prd/`, `docs/TASKS.md`, `docs/STATUS.md` — clean conventions that make tools (and the `project-manager` agent) work across projects. Evals deserve the same treatment.
- Without a convention, the `llm-evaluator` agent will have to discover eval layout per-project, which slows it down and makes regression checks unreliable
- CI integration is where evals actually have teeth — if they don't run on prompt/model changes, they're documentation, not gates
- The operator's TDD rule already requires tests-first for code; the eval-first rule for LLM features is the natural extension

## Proposal

Decide on the following conventions and document in CLAUDE.md (or a dedicated `rules/llm-evals.md`):

**Directory layout (per project)**

```
docs/
  evals/
    README.md                    # what this eval suite covers
    cases/
      happy-path.jsonl           # one case per line: {"input":..., "expected":..., "criteria":[...]}
      edge-cases.jsonl
      adversarial.jsonl          # prompt injection attempts, jailbreaks
    judges/
      relevance-judge.md         # LLM-as-judge prompt template
      faithfulness-judge.md
    runners/
      run-evals.py               # consistent entry point
    results/
      YYYY-MM-DD-run.json        # historical results for drift tracking
```

**Runner contract**

- Input: case file path(s)
- Output: structured results (per-case pass/fail, scores, traces) + summary (pass rate, regression vs. last run)
- Exit code 0 if pass thresholds met, non-zero otherwise — drives CI gating

**CI integration**

- Run on every PR that touches: prompts, model versions, RAG indexes, tool definitions, or AI-pipeline code
- Block merge on regression below the project's pass threshold
- Store results as build artifacts for trend analysis

**Eval-first rule (added to CLAUDE.md)**

- New LLM features: minimum 30 hand-curated cases + criteria + thresholds before merge
- Prompt changes: require eval pass before merge (no manual override without operator approval)

## Open questions for review

- JSONL vs. YAML for case files? JSONL — easier to stream, append, and diff in PRs.
- One eval directory per project, or a shared eval repo for cross-project patterns? Per-project; cross-project patterns live as templates in the `llm-evaluator` agent's skill loads.
- Should the runner be a shared library (`@gavin/llm-evals`) or copy-pasted per project? Shared library once the pattern stabilizes; copy-paste during the first 1–2 projects to let the API settle.
- Should this also cover online eval / production tracing setup? Out of scope for this suggestion — that's a separate Langfuse/LangSmith decision (see `evaluation-and-observability.md` open questions).
