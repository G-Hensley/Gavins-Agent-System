# Prompt Engineering — Advanced Techniques

Advanced techniques for accuracy on complex tasks. Basics (system prompts, few-shot, structured output) are in [prompt-engineering.md](./prompt-engineering.md).

---

## Chain of Thought (CoT)

Instruct the model to reason before answering. Accuracy improves measurably on multi-step tasks when the model externalizes its reasoning.

**Canonical phrasings:**
- "Think step by step before answering."
- "Show your reasoning before giving a final answer."
- "Work through this carefully, then provide your conclusion."

**Structured-output integration:**

Place `reasoning` before `decision` in the schema. Schema fields are filled in order — committing to a decision before reasoning is complete degrades quality. See [structured-output.md](./structured-output.md) for the full reasoning-before-decision rule.

```python
class Triage(BaseModel):
    reasoning: str = Field(description="Step-by-step analysis before deciding")
    action: Literal["approve", "escalate", "reject"]
```

**Provider variants — these are distinct mechanisms:**

| Provider | Mechanism | How to use |
|---|---|---|
| Anthropic (standard) | `<thinking>` tags in prompt | Add `"Think inside <thinking> tags before responding."` to system prompt |
| Anthropic (extended thinking) | `thinking` parameter in API | Set `thinking: {"type": "enabled", "budget_tokens": N}` — managed CoT; tokens billed separately |
| OpenAI o-series | Intrinsic reasoning | Model reasons internally before responding; no special prompt needed; reasoning tokens are billed but not shown by default |

Do not request `<thinking>` tags and also set the `thinking` parameter — they are different modes. Extended thinking via the `thinking` parameter disables streaming changes and has its own token budget.

---

## Prompt Decomposition

Replace one complex prompt with a sequence of simpler, chained prompts. Each step is easier to reason about, test, and debug.

**When to split:**
- The task has multiple distinct goals that can succeed or fail independently
- A single prompt's output is used in different ways by different downstream steps
- A prompt is failing and you cannot isolate which part is responsible

**Common shapes:**

| Shape | Steps | Use when |
|---|---|---|
| Extract → Analyze → Synthesize | 3 sequential prompts | Complex analysis where raw input needs structured extraction first |
| Fan-out → Merge | N parallel prompts + 1 aggregation | Same analysis on N items; results combined at the end |
| Draft → Critique → Revise | 3 sequential prompts | Quality-sensitive generation where self-critique improves output |

```python
# Extract → Analyze → Synthesize example
entities = llm.call(extract_prompt, document)      # Step 1: extract facts
analysis = llm.call(analyze_prompt, entities)       # Step 2: reason over facts
summary = llm.call(synthesize_prompt, analysis)     # Step 3: produce output
```

**Debugging payoff:** each link in the chain is individually evaluable. When the final output is wrong, you can pinpoint which step failed instead of treating the full prompt as a black box.

---

## Context Positioning

Models attend most to the **start** and **end** of the context window. Content in the middle receives systematically less attention — this is the "lost in the middle" effect.

**Decision rules:**

- Repeat critical instructions at **both** the start and end of the system prompt. A single occurrence mid-prompt is frequently under-weighted.
- For RAG: place the highest-relevance chunks at positions 1 and N, not in the middle. See [rag-engineering.md](./rag-engineering.md) for the full context injection pattern.
- For long documents: put the task description before the document AND restate the key constraint after the document ends.

```
[SYSTEM PROMPT START]
You are a contract analyst. Extract only termination clauses.

<document>
... long contract text ...
</document>

Task reminder: extract only termination clauses. Ignore all other content.
[SYSTEM PROMPT END]
```

---

## Negative Examples

"Do NOT" instructions are more effective than most practitioners expect. Models generalize from negative constraints, not just positive examples.

**When to use:**
- Ambiguous tasks where the model picks an unwanted variant (summarization style, tone, response length, formatting)
- When few-shot examples alone fail to constrain the format
- When a previous version of the prompt produced a specific wrong behavior you want to prevent

**Pattern — pair every "do" with a "do not":**

```
Summarize in plain language suitable for a non-technical reader.
Do NOT use bullet points or numbered lists.
Do NOT include implementation details.
Do NOT exceed three sentences.
```

**Canonical negative example pairs:**

| Task | Positive | Negative |
|---|---|---|
| Summarization | "Write 2–3 sentences" | "Do NOT write more than 3 sentences" |
| Tone | "Use a professional, neutral tone" | "Do NOT use casual language or contractions" |
| Format | "Return JSON only" | "Do NOT wrap JSON in markdown code blocks" |
| Scope | "Describe only the bug fix" | "Do NOT summarize unrelated changes" |

---

## Temperature and Sampling

**Temperature selection by task:**

| Task type | Temperature | Rationale |
|---|---|---|
| Extraction, classification, structured output | 0 | Deterministic; highest schema conformance rate |
| Summarization, analysis, translation | 0.3–0.7 | Controlled variation; coherent output |
| Generation, drafting, explanation | 0.3–0.7 | Fluent without being erratic |
| Brainstorming, creative writing, ideation | 0.8–1.0 | Diversity valued over precision |

**Top-P:** 0.9 is a reasonable default across providers. Lower (0.7–0.8) focuses output; higher (0.95–1.0) increases diversity. Adjust temperature first; adjust Top-P only if temperature alone isn't achieving the desired result.

**Critical rule — never combine high temperature with Gen 1 structured output:**

High temperature + prompt-only JSON (Gen 1) causes schema violation rates to spike. The model is simultaneously asked to be creative and to conform to a strict format — the two objectives conflict.

- If you need structured output: use Gen 3 (provider-enforced schema) and set temperature 0.
- If you need creative output: drop structured output or run creativity at high temp then extract structure in a second pass at temperature 0.

**Provider default temperatures** (as of 2025 — check current docs before relying on defaults):

| Provider | Default |
|---|---|
| Anthropic Claude | 1.0 |
| OpenAI GPT-4o | 1.0 |
| OpenAI o-series | Fixed internally; `temperature` parameter ignored |
| Google Gemini | 1.0 |

Never leave temperature at the provider default for extraction or classification tasks. The default is tuned for conversational output, not deterministic structured processing.

---

## Anti-Patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| CoT requested but no `<thinking>` allowance in response format | Model is told to think but the structured schema has no field for it — reasoning is suppressed | Add `reasoning` field before the decision field in schema |
| Extended thinking `thinking` parameter + streaming | Extended thinking changes streaming behavior; not all SDK versions support it cleanly | Disable streaming when using extended thinking unless using a streaming-capable SDK version |
| Unbroken complex prompt when decomposition would help | Cannot isolate which step is failing; quality ceiling is lower | Split into Extract → Analyze → Synthesize (or appropriate shape) |
| Default provider temperature for extraction tasks | Provider defaults (~1.0) increase variance in structured output; schema violation rate rises | Set temperature 0 for all extraction, classification, and structured output calls |
| Instructions stated once in the middle of a long system prompt | Lost-in-the-middle effect; model under-weights instructions not at start or end | Repeat critical instructions at both start and end |
