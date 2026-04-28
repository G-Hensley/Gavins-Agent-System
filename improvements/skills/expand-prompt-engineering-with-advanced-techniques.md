# Expand prompt-engineering ref with advanced techniques

## What I Observed

`skills/ai-engineering/references/prompt-engineering.md` covers basics (system prompts, few-shot, role assignment, basic structured output). The production-essential advanced techniques are missing — and these are exactly the techniques that move accuracy on hard tasks.

Missing techniques:

**Chain of Thought (CoT)**

- Instruct the model to show reasoning before answering
- For structured output, place the reasoning field *before* the answer field (cross-link to structured-output ref)
- "Think through this step by step" is the canonical phrasing; provider-specific variants (Anthropic `<thinking>` tags, OpenAI o-series intrinsic reasoning) differ

**Prompt decomposition**

- Replace one complex prompt with a sequence of simpler prompts
- Extract → Analyze → Synthesize is a common shape
- Each prompt is simpler, more debuggable, and individually evaluable

**Context positioning**

- Models attend most to start and end of the context (lost in the middle)
- Repeat critical instructions at start and end of the system prompt
- For RAG: place the most relevant chunks first AND last, not in the middle

**Negative examples**

- "Do NOT" guidance is more effective than people expect
- Pair "do" with "do not" for ambiguous tasks (summarization style, tone, formatting)

**Temperature and sampling**

- Temperature 0 — deterministic; for extraction, classification, structured output
- Temperature 0.3–0.7 — controlled creativity; generation, summarization, analysis
- Temperature 0.8–1.0 — high creativity; brainstorming, creative writing
- Top-P 0.9 as a reasonable default; lower = focused, higher = diverse
- Never combine high temperature with prompt-only structured output (Gen 1) — schema violation rate spikes

## Why It Would Help

- CoT plus reasoning-before-decision schema ordering is the single highest-leverage accuracy improvement on hard tasks; the operator's agents currently invent the structure ad-hoc
- "Lost in the middle" is the most-cited LLM context phenomenon and the easiest to apply (just reorder); without explicit guidance, prompts and RAG context are arranged by author convenience
- Negative examples are systematically under-used; agents tend to write "do this" without "do not that" and the model chooses some unwanted variant
- Temperature is often left at the provider default, which is rarely correct for the task at hand

## Proposal

Append sections to `skills/ai-engineering/references/prompt-engineering.md` (or split into a new `prompt-engineering-advanced.md` if the file grows past ~200 lines):

- Chain of Thought — phrasing, structured-output integration, provider variants
- Prompt decomposition — when to split, common shapes (Extract/Analyze/Synthesize), debugging payoff
- Context positioning — start and end attention, repeat critical instructions, RAG ordering rule
- Negative examples — when "do not" pairs help; canonical examples
- Temperature and sampling — selection by task, the never-combine rule with Gen 1 structured output
- Anti-pattern list — CoT requested but no `<thinking>` allowance, unbroken complex prompts, default temperature for everything

Cross-link from structured-output and rag-engineering refs.

## Open questions for review

- Is the file going to exceed 200 lines after this expansion? Probably — split into `prompt-engineering-basics.md` and `prompt-engineering-advanced.md` with the SKILL.md updated to load both.
- Anthropic-specific extended thinking (`thinking` parameter) deserves a callout — it's a managed CoT mode the operator should know to reach for.
- Should provider-default temperature be documented per provider? Yes — defaults change and quietly affect output.
