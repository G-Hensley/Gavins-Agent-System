# New skill reference: LLM evaluation and observability

## What I Observed

Evaluation in the existing AI engineering material amounts to "test with varied inputs" and "measure token usage." That's not an evaluation strategy — that's a vibe. Production AI requires systematic eval suites, LLM-as-judge, tracing, and drift detection. The single biggest gap between "demo" and "production" AI applications.

Missing topics:

**Eval types**

- Offline (pre-deployment): assertion-based, LLM-as-judge, human evaluation, reference-based (BLEU/ROUGE/exact match/cosine)
- Online (production): trace-level scoring, sampling-based LLM-as-judge, drift detection (embedding distributions, output patterns), user feedback signals

**Eval suite anatomy**

- 50–200 input/expected-output pairs covering happy path + edge + adversarial + failure modes
- Specific measurable criteria (not "quality")
- Pass thresholds (e.g., "95% score ≥4/5 on relevance")
- Regression triggers — run on every prompt change, model upgrade, AI-pipeline code change

**Observability / tracing — required fields per LLM call**

- Full input (system + user + context)
- Full output
- Model and version
- Token usage (in, out) and computed cost
- Latency (TTFT and total)
- Tool calls (which, params, returns)
- Trace ID correlating multi-call agent runs

**Tools** — Langfuse (OSS), Arize, LangSmith, Braintrust, OpenTelemetry with custom spans

## Why It Would Help

- Without eval suites, every prompt or model change is unvalidated — regressions land in production unseen
- "User reports the chatbot gave a wrong answer" is unanswerable without traces — the operator should not ship LLM features without traces from day one
- LLM-as-judge produces non-deterministic scores; the eval framework should treat this explicitly (multiple runs, averaging, criteria specificity) rather than letting agents invent it per project
- Drift detection is the production safety net — embedding distribution shifts mean the model's behavior is changing, and that signal exists nowhere today

## Proposal

Create `skills/ai-engineering/references/evaluation-and-observability.md` with sections:

- Why eval is non-optional (a one-paragraph framing)
- Offline eval types (4 types, when each fits, including LLM-as-judge prompt template)
- Online eval (trace-level, drift, feedback) — required for any production LLM feature
- Eval suite anatomy — concrete checklist (50–200 cases, criteria, thresholds, regression triggers)
- Required tracing fields — list with rationale per field
- Tool selection — Langfuse / Arize / LangSmith / Braintrust / OTel; pick-by-need, not pick-by-marketing
- Anti-pattern list — "we test it manually," "users will tell us," "we'll add evals later"

Update `agents/ai-engineer.md` and `agents/qa-engineer.md` to load this when LLM-feature work is detected.

## Open questions for review

- Should there be a paired eval-engineer agent? Yes — see `improvements/agents/new-agent-llm-evaluator.md`. Eval is a distinct discipline.
- Should the operator standardize on one tracing tool? Lean Langfuse for self-host or LangSmith if already in the ecosystem; document the choice in CLAUDE.md once made.
- What's the minimum viable eval bar to ship an LLM feature? Suggest: ≥30 hand-curated test cases, criteria defined, traces enabled. Below that = not production-ready.
