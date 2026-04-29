# LLM Eval Suite Convention (Always Active)

> Scope: this rule governs eval suites for LLM features inside operator's user-facing projects. It does NOT govern the agent system's own §6 baseline harness — that lives in `evals/` at the root of this repo and is governed separately by ROADMAP §6.

## Directory Layout

Every project with LLM features keeps its eval suite under `docs/evals/`:

```
docs/
  evals/
    README.md                    # what this eval suite covers, pass thresholds, last run date
    cases/
      happy-path.jsonl           # core user flows
      edge-cases.jsonl           # boundary inputs, empty/malformed, long context
      adversarial.jsonl          # prompt injection attempts, jailbreaks, data exfiltration probes
    judges/
      relevance-judge.md         # LLM-as-judge prompt template for relevance scoring
      faithfulness-judge.md      # LLM-as-judge prompt template for grounded-output scoring
    runners/
      run-evals.py               # consistent CLI entry point (see Runner Contract below)
    results/
      YYYY-MM-DD-run.json        # historical results for drift tracking
```

Create `docs/evals/` at project scaffold time, not retroactively. An empty `README.md` + `cases/` directory is the minimum viable state before any LLM feature is built.

## Case File Format

Case files are JSONL — one case per line, easy to stream, append, and diff in PRs.

Each line:

```jsonl
{"input": "...", "expected": "...", "criteria": ["relevance", "no_hallucination", "citation_present"]}
```

- `input`: the full prompt or user message sent to the feature
- `expected`: the ground-truth response or a description of acceptable output
- `criteria`: list of judge dimensions to evaluate (matches judge files in `judges/`)

JSONL over YAML: simpler to append, no indentation ambiguity, grep-friendly.

## Runner Contract

`docs/evals/runners/run-evals.py` is the canonical entry point for every project's eval suite.

**Input**

```
python run-evals.py --cases ../cases/happy-path.jsonl [--cases ../cases/edge-cases.jsonl ...]
                    [--threshold 0.85]
```

**Output**

- Per-case result: `pass | fail`, score(s), model response, judge rationale
- Summary: pass rate, regression delta vs. last run (read from `results/` most recent file), threshold comparison
- Written to `results/YYYY-MM-DD-run.json` automatically

**Exit codes**

- `0` — pass rate meets or exceeds threshold
- `1` — pass rate below threshold (CI gating fails the build)
- `2` — runner error (missing cases file, bad config, model unreachable)

The `llm-evaluator` agent (`../agents/llm-evaluator.md`) is the primary consumer of this contract — it calls the runner and acts on the exit code.

## CI Integration

Add an eval step to every PR pipeline that touches:

- Prompt templates or system prompts
- Model versions or model configuration
- RAG indexes, retrieval logic, or embedding models
- Tool definitions or function-calling schemas
- AI pipeline orchestration code

**Block merge** when the runner exits non-zero (`1` = pass rate below threshold, `2` = runner error). Store `results/YYYY-MM-DD-run.json` as a build artifact for trend analysis.

Do not add the eval step only to main merges — eval failures caught post-merge are already regressions.

## Eval-First Rule

This is the LLM equivalent of TDD. Apply it without exception.

- **New LLM feature**: write a minimum of 30 hand-curated cases covering happy-path, edge, and adversarial inputs, define criteria and pass thresholds, and get eval passing before merging any feature code.
- **Prompt changes**: run the full eval suite before merge. A passing eval is required — no manual override without explicit operator approval.
- **Model version bumps**: treat as a prompt change — full eval run required.

If 30 cases feel like too many, the feature's scope is probably too large. Break it down.

## Cross-References

- `../agents/llm-evaluator.md` — the agent that runs evals, interprets results, and blocks on regression
- `../skills/ai-engineering/references/evaluation-and-observability.md` — deeper patterns: LLM-as-judge prompting, scoring rubrics, online eval / production tracing setup
