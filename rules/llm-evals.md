# LLM Eval Suite Convention (Always Active)

> Scope: per-project eval suites for LLM features. Does NOT govern the agent system's own §6 baseline harness (that lives in `evals/` at repo root, see ROADMAP §6).

## Directory Layout

Every project with LLM features keeps its suite under `docs/evals/`:

```
docs/evals/
  README.md, cases/{happy-path,edge-cases,adversarial}.jsonl
  judges/*.md, runners/run-evals.py, results/YYYY-MM-DD-run.json
```

Create at scaffold time, not retroactively.

## Case Format

JSONL — one case per line: `{"input": ..., "expected": ..., "criteria": [...]}`. JSONL over YAML for streaming, append, and PR diff friendliness.

## Runner Contract

`run-evals.py` accepts `--cases <path>` (repeatable) and `--threshold <float>`, writes `results/YYYY-MM-DD-run.json`. Exit codes:

- `0` — pass rate meets threshold
- `1` — pass rate below threshold
- `2` — runner error (missing config, model unreachable)

The `llm-evaluator` agent is the primary consumer.

## CI Integration

Run on every PR touching prompts, models, RAG, tool definitions, or AI-pipeline code. Block merge on any non-zero exit. Store `results/*.json` as a build artifact.

## Eval-First Rule

LLM equivalent of TDD — no exceptions:

- **New feature**: ≥30 hand-curated cases (happy + edge + adversarial), criteria and thresholds defined, eval passing before merging feature code.
- **Prompt or model change**: full eval pass required — no manual override without explicit operator approval.

If 30 cases feel like too many, the scope is too large. Break it down.

## Cross-References

- `../agents/llm-evaluator.md` — runs evals, interprets results, blocks on regression
- `../skills/ai-engineering/references/evaluation-and-observability.md` — judge prompting, scoring, tracing
