# Evaluation and Observability

Shipping an LLM feature without an eval suite is the equivalent of deploying backend code with no tests and no logging. Every prompt change, model upgrade, or RAG pipeline edit can silently degrade quality — and without evals you will not know until users complain. Evals are not a post-launch activity. They are a precondition for deployment.

---

## Offline Eval Types

Run offline evals before every deployment. Four types, chosen by what you can measure.

### Assertion-Based

Deterministic checks against the model output. Zero subjectivity, zero cost, instant feedback.

```python
assert "account_id" in response.json()           # field presence
assert re.search(r"\d{4}-\d{2}-\d{2}", response.text)  # date format
assert response.json()["status"] in {"open", "closed"}  # enum membership
```

Use for: structured output contracts, required fields, format enforcement, schema conformance.
**Decision rule:** write assertions first. If the output is deterministically checkable, an assertion is faster and cheaper than LLM-as-judge.

### LLM-as-Judge

Use a separate LLM call to score the model's output against a rubric. Non-deterministic — run each case 3 times and average. Criteria specificity is everything: vague rubrics produce noisy scores.

```
SYSTEM:
You are an evaluation judge. Score the RESPONSE on the criterion below.
Return a JSON object: {"score": <1-5>, "reason": "<one sentence>"}.

CRITERION: Relevance — does the response directly answer the user's question
using only information present in the CONTEXT? Penalize answers that
introduce facts not in the context, even if those facts are correct.

Scores:
5 — fully answers the question from the context, no hallucination
4 — mostly answers, minor gap or minor unsupported claim
3 — partially answers; missing key information or one unsupported claim
2 — poor answer; mostly off-topic or multiple unsupported claims
1 — does not answer the question or the response is incoherent

USER:
QUESTION: {question}
CONTEXT: {context}
RESPONSE: {response}
```

Use structured output for the judge response — see `./structured-output.md`. Aggregate: flag any case where mean score < 4 or where individual run scores span > 1 point (the rubric is ambiguous if runs diverge).

### Human Evaluation

Use when LLM-as-judge cannot capture the criterion (tone, brand voice, legal accuracy, sensitive domains) or for calibrating whether your judge scores correlate with human judgment.

Sample sizes: 30–50 cases for an initial calibration; 10–20 cases for targeted spot-checks after a change. Full human eval on every deployment is not practical — use it to validate that your automated evals track human preference, then rely on automated evals for CI.

### Reference-Based

Compare model output against a known-good reference answer using a similarity metric.

| Metric | What it measures | When to use |
|---|---|---|
| Exact match | Identical string | Classification labels, structured IDs |
| BLEU | N-gram overlap | Translation, rigid templated output |
| ROUGE-L | Longest common subsequence | Summarization with a reference summary |
| Cosine similarity (embeddings) | Semantic closeness | Open-ended generation where paraphrase is acceptable |

**Decision rule:** exact match or BLEU/ROUGE only when the reference is authoritative and paraphrase is unacceptable (e.g., a required legal phrase). Cosine similarity is more forgiving but requires a threshold — 0.85+ is a reasonable starting point; tune against your human-labeled calibration set.

---

## Online Eval

Production LLM systems require ongoing eval, not just pre-deployment gates.

**Trace-level scoring** — run a lightweight judge or assertion suite on a sample of production traces (1–5% is typical). Log scores alongside traces so you can correlate quality degradation with specific inputs, time windows, or model versions.

**Sampling-based LLM-as-judge** — full judge runs on every production request are too expensive. Sample systematically: random 1–5%, plus 100% of any trace that triggered a tool error, exceeded latency thresholds, or hit a max-retry. Do not sample uniformly — over-sample the edges.

**Drift detection** — two signals to monitor:

- *Embedding distribution shift*: embed user queries and track their centroid and variance over time. A shift means the user population is asking different things — your eval suite may no longer cover the real distribution. Re-sample your eval set when drift exceeds 1 standard deviation from baseline.
- *Output pattern shift*: track output-level statistics — average response length, refusal rate, tool-call rate, structured-output parse failures. Sudden changes in any of these indicate a model behavior change (even without a model upgrade — provider silent updates happen).

**User feedback signals** — thumbs up/down, correction submissions, escalation rates. These are lagging indicators (users see problems before you do) but they are real-world ground truth. Log feedback against the trace ID so you can replay the exact input that triggered it.

---

## Eval Suite Anatomy

A production eval suite is a curated dataset plus a pass/fail contract, not just a collection of test inputs.

**Case count:** 50–200 input/expected-output pairs minimum. Below 50, edge cases are underrepresented and your pass rates have high variance. Above 200, focus on coverage quality over quantity.

**Coverage required (all four):**
- Happy path — representative queries the system should handle well
- Edge cases — unusual phrasing, boundary conditions, empty or minimal inputs
- Adversarial — prompt injection attempts, jailbreak probes, off-topic inputs (see `./llm-security.md`)
- Known failures — cases where an earlier version failed; regression guard

**Criteria must be measurable.** "Quality" is not a criterion. "Relevance: response directly addresses the user question using only the provided context" is a criterion.

**Pass thresholds must be explicit.** Examples: "95% of cases score ≥ 4/5 on relevance," "0 assertion failures on format checks," "100% refusal on adversarial injection probes." Document the threshold in the eval suite, not in someone's memory.

**Regression triggers** — run the full suite on every:
- Prompt template change (including whitespace or punctuation)
- Model version or provider change
- RAG pipeline change (chunking, embedding model, retrieval strategy — see `./rag-engineering.md`)
- Tool schema or behavior change
- Dependency update that touches the LLM call path

---

## Required Tracing Fields Per LLM Call

Every LLM call in production must emit a structured log record. These fields are non-negotiable.

| Field | Why it matters |
|---|---|
| Full input (system + user + context) | Without the exact prompt, you cannot reproduce a failure |
| Full output | You need the raw response, not just your parse of it |
| Model and version | Silent provider updates change behavior; version pinning is not enough without logging |
| Input tokens, output tokens, cached tokens | Cost attribution and cache hit-rate monitoring — see `./cost-optimization-and-routing.md` |
| Computed cost (USD) | Per-request cost at log time; invoice aggregations are too coarse |
| Latency: TTFT and total | TTFT (time to first token) tracks streaming UX; total latency tracks pipeline health |
| Tool calls: name, params, return value | Tool failures are the most common source of agent regression |
| Trace ID | A single identifier shared across all LLM calls in one agent run; without it you cannot reconstruct multi-call sequences |

The trace ID is the most commonly omitted field and the most painful to retrofit. Generate it at the entry point of every agent run and thread it through every downstream call.

---

## Tool Selection

No single tool is best for all teams. Pick by your actual constraints.

| Tool | Best fit | Notes |
|---|---|---|
| Langfuse | Self-host required; OSS-first; cost-sensitive | Trace + eval + prompt management; integrates with LangChain, LlamaIndex, raw SDKs |
| LangSmith | Already in the LangChain ecosystem | Tightly integrated with LangChain; weaker if you're not using it |
| Arize | ML platform already in the stack | Strong drift detection and embedding visualization; heavier operational footprint |
| Braintrust | Eval-first workflow; teams iterating fast on prompts | Prompt playground + eval harness in one; newer, less battle-tested at scale |
| OpenTelemetry + custom spans | Existing OTel infrastructure; multi-system tracing | Most flexible; most manual; no LLM-specific eval UI out of the box |

**Decision rule:** if you have no existing tracing infrastructure, start with Langfuse (self-host) or LangSmith (if you use LangChain). Do not add a tool for marketing reasons — add it because it fills a gap your current stack cannot.

The evaluator-optimizer pattern (an agent that scores its own outputs and self-corrects) is a use case for LLM-as-judge inside the pipeline itself — see `./agentic-design-patterns.md`.

---

## Anti-Patterns

| Anti-pattern | Problem |
|---|---|
| "We test it manually before shipping" | Manual testing is not repeatable; you cannot run it on every prompt change |
| "Users will tell us if something breaks" | Users are a lagging signal; by the time they report, the damage is done |
| "We'll add evals later" | Retrofitting eval infrastructure into a live production system is expensive; later never comes |
| "Our eval suite passes so the model is correct" | Passing assertions proves structural correctness, not semantic quality; both layers are required |
| Vague judge criteria ("rate the quality 1–5") | LLM judges on vague rubrics produce noisy, uncorrelated scores; define specific, measurable criteria |
| Single judge run per case | LLM-as-judge is non-deterministic; one run produces an unreliable score; average across 3+ runs |

---

## MVP Eval Bar to Ship

Below this bar, the feature is not production-ready:

- 30 or more hand-curated test cases (happy path + edge + at least 5 adversarial)
- Criteria defined in writing for every eval dimension
- Pass thresholds set explicitly (not implicitly "whatever it scores")
- Traces enabled from day one — full input, full output, model version, token usage, trace ID

This is the minimum. A mature eval suite is 50–200 cases with online sampling, drift monitoring, and human calibration. But 30 curated cases with explicit criteria and traces is the gate that separates a demo from a deployment.
