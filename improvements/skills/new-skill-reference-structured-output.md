# New skill reference: structured output (Gen 1–4 + schema design)

## What I Observed

Structured output guidance currently lives implicitly in `prompt-engineering.md` at the "put a JSON schema in your prompt" level. That's Gen 1 of four generations of structured-output techniques and is the *least* reliable. The other three are missing entirely, and schema-design rules tailored for LLMs are nowhere.

Missing topics:

**Four generations of structured output**

- Gen 1 — prompt-only (5–20% failure rate in production: trailing commas, markdown wrappers, malformed strings)
- Gen 2 — JSON Mode (provider guarantees valid JSON syntax, NOT schema conformance)
- Gen 3 — Structured Outputs (provider guarantees schema conformance — OpenAI `response_format: json_schema`, Anthropic strict tool inputs). The production default for hosted models.
- Gen 4 — constrained decoding (token-level masking; vLLM, llama.cpp, Outlines, Guidance). For self-hosted models.

**The critical distinction**

- Syntactic vs. semantic correctness. Constrained decoding guarantees the JSON is valid; it does not guarantee values are correct. `{"sentiment":"positive"}` on a negative review is valid output and wrong. Schema enforcement does not replace evals.

**Schema design for LLMs**

- Keep schemas flat — deeply nested schemas confuse models
- Descriptive key names (`first_name` over `fn`)
- `description` field is the most important guidance to the model
- Enums for constrained values (don't hope, enforce)
- **Reasoning before decision in the schema order** — if the model needs to think before deciding, put `reasoning` before `decision` in the schema. The opposite forces commitment before reasoning.

## Why It Would Help

- Production code in the operator's stack likely still uses Gen 1 (prompt-only) for structured output — the easiest upgrade is to flip to Gen 3, often a 2-line change
- The reasoning-before-decision schema rule is the single highest-leverage prompt-engineering trick for any task that requires thought, and it's invisible without explicit guidance
- The "syntactic correctness ≠ semantic correctness" point is what stops people from skipping evals on constrained-decoded output
- Schema design rules are not obvious — flat-not-nested, enum-not-string, description-as-guidance — and they compound

## Proposal

Create `skills/ai-engineering/references/structured-output.md` with sections:

- Four generations table — name, what it guarantees, when to use, providers/libraries
- The syntactic vs. semantic distinction — constrained output still needs evals
- Schema design rules — flat structure, descriptive names, descriptions as guidance, enums, reasoning-before-decision
- Worked example — same task, four different implementations (Gen 1 prompt-only, Gen 2 JSON mode, Gen 3 schema-enforced, Gen 4 constrained decoding via Outlines)
- Anti-pattern list — `decision` before `reasoning`, free-text where enums fit, deeply nested schemas, `additionalProperties` forgotten

Update `agents/ai-engineer.md` and `agents/backend-engineer.md` to load this when structured output is being designed.

## Open questions for review

- Should this ref be its own file or absorbed into `prompt-engineering.md`? Its own file — it's large enough and conceptually distinct.
- Is the operator already on Gen 3 in production, or still Gen 1? If unknown, that's exactly why the ref needs to exist.
- The reasoning-field-first rule applies to any model thinking-style output (CoT). Cross-link to the prompt-engineering advanced techniques expansion.
