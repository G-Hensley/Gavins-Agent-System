# Cost Optimization and Routing

LLM cost is dominated by model tier and token volume. The two highest-leverage interventions are routing (use cheap models for easy tasks) and caching (never pay for the same tokens twice). Everything else — tracking, alerting, budget ceilings — exists to make those interventions measurable and safe.

---

## Routing Strategies

**By task type** — a rough starting cut before any input analysis:

| Task type | Model tier |
|---|---|
| Extraction, classification, summarization | Cheapest available (Haiku, GPT-4o-mini) |
| Generation, code editing, multi-step analysis | Mid-tier (Sonnet, GPT-4o) |
| Complex reasoning, ambiguous intent, high-stakes decisions | Top-tier (Opus, o3) |

**By input analysis** — apply before calling any model:

- Short inputs with simple verbs ("summarize", "extract", "classify") → cheap tier
- Long multi-part inputs, tool-use requirements, or explicit reasoning steps → mid or top
- Route on token count: inputs under ~500 tokens rarely need top-tier unless the task is hard

**By confidence (cascade)** — the single highest-leverage cost pattern: try cheap first, escalate only when confidence is below threshold. Most production traffic is easy; top-tier spend should be reserved for the tail.

```python
# confidence score comes from structured output — see ./structured-output.md
ESCALATION_THRESHOLD = 0.75

result = call_model(cheap_model, task)
if result.confidence < ESCALATION_THRESHOLD:
    result = call_model(mid_model, task)
if result.confidence < ESCALATION_THRESHOLD:
    result = call_model(top_model, task)
return result
```

Set thresholds per task type, not globally. Classification cascades differently than generation. Track escalation rate as an operational metric — if it exceeds ~15%, re-examine your cheap-tier prompt before raising the threshold.

---

## Caching

Three independent layers. They compose — all three can be active simultaneously.

**Provider prompt cache (Anthropic/OpenAI)** — the provider caches the KV state for stable prefixes. Subsequent requests that share the same prefix skip re-computation. Input token cost drops by ~90% on cached tokens.

- On Anthropic, mark cache boundaries explicitly with `cache_control` (see Prefix Stability Rules below).
- On OpenAI, caching is automatic for prompts over ~1024 tokens. No API change required.
- When it helps: system prompts with tool definitions, large static documents injected into every request, few-shot examples that never change.
- Cache TTL is ~5 minutes (Anthropic). Structure requests so the cached prefix appears in every call, not just some.

**Semantic cache (application level)** — embed the incoming query; if cosine similarity to a cached query exceeds a threshold, return the cached response without calling the model.

- When it helps: repeated or near-identical user queries (FAQ-style, canned lookups, form-fill pipelines).
- Threshold is critical: too low (< 0.90) and you return wrong answers for different-but-similar inputs; too high (> 0.98) and the cache barely hits. Start at 0.92–0.95 and tune against an eval set.
- Never skip the threshold. A semantic cache without a similarity guard is a hallucination multiplier.

**Embedding cache** — cache computed embeddings by content hash. Re-embedding is expensive at scale; documents only need re-embedding when their content changes.

- When it helps: RAG pipelines where the document corpus is stable between runs.
- Key on a SHA-256 of the chunk content. Invalidate on content change, not on time.

---

## Prompt Prefix Stability Rules

Provider caches key on an exact byte match of the prefix. A single character change busts the cache for every downstream token.

**Put in the prefix (stable content):**
- System role instructions
- Tool definitions and JSON schemas
- Static few-shot examples
- Large documents that do not change per-request

**Do NOT put in the prefix:**
- Timestamps or dates — these change every request
- User IDs, session IDs, or request IDs
- Dynamic context that varies per user (account data, preferences)
- Random tokens or nonces

**Anthropic — explicit cache markers:**
```python
messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "text",
                "text": STATIC_SYSTEM_PROMPT,
                "cache_control": {"type": "ephemeral"},  # marks end of cacheable prefix
            },
            {"type": "text", "text": user_message},  # dynamic — not cached
        ],
    }
]
```

**OpenAI — automatic:** prompts over ~1024 tokens are cached automatically. Keep the static system prompt and tool definitions at the top; append dynamic user content at the bottom. No API change required.

---

## Cost Tracking — Per-Request Log Fields

Log these fields on every LLM call. Everything else (aggregations, alerts, dashboards) is derived from this log.

| Field | Source | Notes |
|---|---|---|
| `model` | API response | Full model ID, not alias |
| `input_tokens` | `usage.input_tokens` | Includes cached tokens |
| `output_tokens` | `usage.output_tokens` | — |
| `cache_read_tokens` | `usage.cache_read_input_tokens` | Anthropic only; 0 if miss |
| `cost_usd` | Computed | `(input × in_price + output × out_price) - cache_discount` |
| `cache_hit` | Boolean | True if `cache_read_tokens > 0` |
| `latency_ms` | Wall clock | Full request duration |
| `feature` | Application | Caller-provided tag: "chat", "extraction", "summarize" |
| `user_segment` | Application | Optional: "free", "pro", "enterprise" |

Compute `cost_usd` at log time using current per-token prices for the model. Do not rely on the provider invoice for per-request cost — that aggregation is too coarse for debugging.

---

## Aggregation and Alerting

**Daily and weekly rollups** by `feature`, `model`, and `user_segment`. These three cuts answer the most common cost questions:
- Which feature is the most expensive?
- Did a model upgrade change our spend?
- Are enterprise users subsidizing free-tier usage?

**Cost-spike alerts** — compare the trailing 7-day average to the current day. Alert at 2× the average. Spikes almost always trace to one of: a new prompt template that busts the cache, a routing regression that escalates too many requests to top-tier, or an unexpected traffic burst.

**Per-feature and per-user budget ceilings** — set a hard ceiling in USD per day or per rolling 30 minutes. Enforce at the call site before the model call, not after.

---

## Budget Ceilings and Graceful Degradation

When a budget ceiling is hit, degrade in order of increasing user impact:

1. **Return cached** — if a semantically similar response exists in the cache at any similarity threshold, return it. Cost: zero.
2. **Return truncated** — call a cheaper model with a shorter max-token limit. Cost: reduced.
3. **Return error** — return a structured error with a `retry_after` hint. Reserve for absolute ceiling breaches.

```python
def call_with_budget(task, feature, user_id):
    if budget_exceeded(feature=feature, user_id=user_id):
        cached = semantic_cache.get(task, threshold=0.85)  # relaxed threshold
        if cached:
            return cached
        return BudgetError(retry_after=budget_reset_seconds(feature))
    return call_model(route(task), task)
```

Never silently degrade to a worse model without logging it. The degradation itself is a metric — high degradation rates mean the ceiling is too low or the routing is misconfigured.

---

## Anti-Patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| Top-tier model for every request | 5–10× cost for tasks a cheap model handles correctly | Route by task type; use cascade for ambiguous cases |
| Semantic cache without similarity threshold | Similar-but-different queries return wrong cached responses | Threshold at 0.92–0.95; tune against an eval set before enabling |
| Untracked LLM spend | Cost spikes diagnosed from the monthly invoice, not in real time | Log per-request cost at call time; alert on daily 2× spikes |
| Timestamps or user IDs in prompt prefix | Cache busted on every request; provider cache is useless | Move dynamic fields below the cached prefix boundary |
| Same escalation threshold for all task types | Classification and generation have different confidence distributions | Set thresholds per feature; measure escalation rate independently |
| Budget ceiling enforced after the call | Request completes and is charged before the ceiling is checked | Check budget before the model call, not after |

For confidence scores used in cascade routing, see `./structured-output.md`.

For cost tracking as part of broader observability pipelines, see `./evaluation-and-observability.md`.
