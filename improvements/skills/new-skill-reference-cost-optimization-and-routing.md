# New skill reference: model routing and cost optimization

## What I Observed

Cost guidance in the existing AI engineering material is a brief table ("cheap for simple, expensive for hard"). Production cost management is more nuanced — routing strategies, caching layers, and per-request cost tracking are distinct disciplines and currently get figured out per-project rather than from a shared reference.

Missing topics:

**Routing strategies**

- By task type — extraction/classification → cheapest; generation/analysis → mid; reasoning/ambiguity → top-tier
- By input analysis — short and simple vs. long and multi-part; tool-use requirements; classifier-based scoring
- By confidence (cascade) — try cheap first, escalate if confidence below threshold. The single highest-leverage cost pattern.

**Caching**

- Prompt caching (provider-level) — Anthropic and OpenAI cache stable prefixes; design system prompts and tool definitions to be stable across requests
- Semantic caching (application-level) — embed incoming queries; if similar to a cached one, return cached response. Threshold tuning critical.
- Embedding caching — cache embeddings by content hash; only re-embed changed documents

**Cost tracking — per-request log**

- Model used
- Input/output tokens
- Computed cost (in × in_price + out × out_price)
- Cache hit/miss
- Total latency

**Aggregation and alerting**

- Daily/weekly by feature, model, user segment
- Cost-spike alerts
- Per-user/feature budget ceilings with graceful degradation

## Why It Would Help

- The cascade pattern (cheap-first, escalate-on-low-confidence) is the single most effective cost optimization and currently lives in nobody's playbook
- Prompt caching is free money on Anthropic and OpenAI but requires *intentional* prefix stability — easy to accidentally invalidate by templating in a timestamp or user ID
- Semantic caching is risky without an explicit threshold discussion — too low and you serve wrong answers, too high and the cache never hits
- Per-request cost logging is the only way to diagnose "why did our LLM bill triple this month" — and most projects discover the gap only after the surprise

## Proposal

Create `skills/ai-engineering/references/cost-optimization-and-routing.md` with sections:

- Routing strategies — by task type, by input analysis, by confidence (cascade) with code skeleton
- Caching — three layers (provider prompt cache, app semantic cache, embedding cache); when each helps
- Prompt prefix stability rules — what to put in the prefix, what *not* to (no timestamps, no user IDs, no random tokens)
- Cost tracking — required log fields and aggregation cuts
- Budget ceilings and graceful degradation — return-cached, return-truncated, return-error patterns
- Anti-pattern list — top-tier model for every request, cache without similarity threshold, untracked LLM spend

Update `agents/ai-engineer.md` and `agents/devops-engineer.md` (cost monitoring is operational) to load this.

## Open questions for review

- Should the operator define default cost ceilings per feature in CLAUDE.md? Yes once measured — but the ref shouldn't dictate numbers, just the practice.
- Cascade requires structured-output confidence scores; should that be cross-linked to structured-output ref? Yes.
- Anthropic prompt caching has explicit cache-control markers; OpenAI is automatic. Should the ref show both? Yes — with a note that the operator's stack is provider-pluralistic.
