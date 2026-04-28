# New agent: llm-evaluator

## What I Observed

Eval is the single biggest gap between demo-quality and production-quality LLM features (see `improvements/skills/new-skill-reference-llm-evaluation-and-observability.md`). It is also a distinct discipline — designing eval suites, calibrating LLM-as-judge prompts, interpreting drift, and deciding pass thresholds is not the same skill as building the LLM feature itself.

Today, the closest agent is `qa-engineer`, which is general-purpose testing. There is no specialist that thinks in eval terms (offline vs. online, LLM-as-judge calibration, regression triggers on prompt change, drift detection). When the operator builds an LLM feature, eval will get tacked on as an afterthought rather than designed alongside the feature.

## Why It Would Help

- Building a real eval suite (50–200 cases, criteria specificity, threshold tuning) is the kind of work that benefits from a focused agent persona — the same way `database-engineer` is sharper at schema work than a generalist
- LLM-as-judge prompt calibration is its own minor specialty; getting it wrong (vague criteria, low temperature on the judge, no inter-rater check) silently corrupts your eval signal
- Drift detection and online eval are operational concerns the regular AI agent isn't shaped to think about
- A separate agent enforces the discipline that eval design happens alongside feature design, not after — the operator can dispatch `llm-evaluator` in parallel with `ai-engineer` during build

## Proposal

Create `agents/llm-evaluator.md`. Model: Sonnet — eval design is reasoning-shaped but not Opus-required for most tasks. Skills loaded:

- `skills/ai-engineering/references/evaluation-and-observability.md` (when built)
- `skills/ai-engineering/references/structured-output.md` (eval outputs are structured; LLM-as-judge prompts use structured output)
- `skills/ai-engineering/references/llm-security.md` (adversarial test cases need awareness of injection patterns)
- `skills/ai-engineering/references/rag-engineering.md` (RAG eval is different from generation eval — separate retrieval and generation metrics)
- `skills/qa-engineering/SKILL.md` (general testing discipline)

Tools: Read, Write, Edit, Bash (for running eval scripts), Grep (for surveying existing prompts/cases).

Dispatch conditions:

- After `ai-engineer` produces a new LLM feature — design the eval suite alongside
- "Build evals for this feature" / "are our prompt changes regressing" / "design an LLM-as-judge for X"
- During incident review — "did our evals catch this? if not, why?"
- Periodically — drift checks, threshold review

Coexistence with `qa-engineer`:

- `qa-engineer` owns deterministic testing (assertions, integration tests, E2E)
- `llm-evaluator` owns probabilistic testing (LLM-as-judge, drift, online eval, regression on prompt change)
- They overlap on test-case design and should hand off explicitly

## Open questions for review

- Should `llm-evaluator` have authority to *block* prompt/model changes if evals regress? Lean yes — same as `qa-engineer` blocks on test failures. Make it explicit in CLAUDE.md.
- Model choice: Sonnet vs. Haiku for routine work, Opus for complex cases? Start Sonnet, escalate on operator command. LLM-as-judge calibration occasionally wants Opus.
- Should this agent maintain a per-project eval suite registry, or does that belong with the project itself? With the project (`docs/evals/` per project), but the agent owns the patterns.
