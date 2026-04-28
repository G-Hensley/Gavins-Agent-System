# Structured Output

Structured output is the practice of constraining an LLM's response to a schema instead of free text. There are four generations of technique, each guaranteeing progressively more. Pick the highest generation your infrastructure supports.

---

## Four Generations

| Generation | Name | What it guarantees | When to use | Providers / libraries |
|---|---|---|---|---|
| Gen 1 | Prompt-only | Nothing. 5–20% failure rate in production: trailing commas, markdown wrappers, malformed strings. | Prototyping only — never production | Any model |
| Gen 2 | JSON Mode | Valid JSON syntax. Does NOT guarantee schema conformance — fields may be missing, extra, or wrong type. | When Gen 3 is unavailable; add Pydantic validation layer on top | OpenAI `response_format: {"type": "json_object"}`, Anthropic system prompt + prefill |
| Gen 3 | Structured Outputs | Schema conformance. Provider enforces your schema at generation time. | **Production default for hosted models** | OpenAI `response_format: {"type": "json_schema", "json_schema": {...}}`, Anthropic strict tool inputs |
| Gen 4 | Constrained decoding | Token-level masking — physically impossible to generate tokens that violate the schema. | Self-hosted models where output correctness is critical | vLLM, llama.cpp, Outlines, Guidance |

**Decision rule:** use Gen 3 for hosted models. Use Gen 4 for self-hosted. Never ship Gen 1 to production.

---

## Syntactic vs. Semantic Correctness

Constrained decoding and schema enforcement guarantee that the JSON is *valid*. They do not guarantee that the values are *correct*.

```python
# Gen 4 constrained decoding — schema is enforced, value is wrong
{"sentiment": "positive"}   # on a clearly negative review

# Both are structurally valid. Only one is semantically correct.
{"sentiment": "negative"}
```

Schema enforcement eliminates parse errors. It does not eliminate model errors. Evals are still required. The value of Gen 3/4 is that you can trust the shape and focus your evals on correctness rather than parsing.

---

## Schema Design Rules

**Keep schemas flat.** Deeply nested schemas confuse models. If you have `address.city.zip`, flatten to `city` and `zip` at the top level.

**Descriptive key names.** `first_name` over `fn`, `confidence_score` over `conf`. The model reads key names as guidance.

**`description` is the most important field.** The model uses descriptions to understand what you want. A key with no description gets a guess.

```python
class ReviewAnalysis(BaseModel):
    reasoning: str = Field(description="Step-by-step analysis of the review tone and evidence")
    sentiment: Literal["positive", "negative", "neutral"] = Field(
        description="Overall sentiment based on the reasoning above"
    )
    confidence: float = Field(description="Confidence score 0.0–1.0 for the sentiment label")
```

**Enums for constrained values.** If there are valid values, enumerate them. A free-text `sentiment` field accepts `"mostly positive"`, `"unclear"`, `"POS"` — all wrong. An enum accepts exactly what you declared.

**Reasoning before decision.** If the model needs to think before deciding, put `reasoning` before `decision` in the schema. Schema fields are filled in order. Placing `decision` first forces commitment before the model has reasoned through the problem.

```python
# Good — model reasons before deciding
class Triage(BaseModel):
    reasoning: str   # model thinks here first
    action: Literal["approve", "escalate", "reject"]

# Bad — model commits to action, then justifies
class Triage(BaseModel):
    action: Literal["approve", "escalate", "reject"]   # decided before reasoning
    reasoning: str
```

For chain-of-thought integration and extended reasoning patterns, see `./prompt-engineering-advanced.md`.

---

## Worked Example: Sentiment Classification

Same task — classify a review — implemented at each generation.

**Gen 1 — prompt-only**
```python
response = llm.call(
    "Classify this review as positive, negative, or neutral. "
    "Return JSON: {\"sentiment\": \"...\"}\n\n" + review_text
)
result = json.loads(response.content)  # raises ~15% of the time
```

**Gen 2 — JSON Mode**
```python
response = client.chat.completions.create(
    model="gpt-4o-mini",
    response_format={"type": "json_object"},
    messages=[{"role": "user", "content": f"Classify sentiment. Return {{\"sentiment\": \"...\"}}. Review: {review_text}"}],
)
result = json.loads(response.choices[0].message.content)
# Valid JSON guaranteed; schema not enforced — add Pydantic validation
output = SentimentResult.model_validate(result)
```

**Gen 3 — schema-enforced (OpenAI Structured Outputs)**
```python
response = client.beta.chat.completions.parse(
    model="gpt-4o",
    response_format=SentimentResult,  # Pydantic model — schema enforced by provider
    messages=[{"role": "user", "content": f"Classify sentiment. Review: {review_text}"}],
)
output = response.choices[0].message.parsed  # typed SentimentResult; never None
```

**Gen 4 — constrained decoding (Outlines, self-hosted)**
```python
import outlines

model = outlines.models.transformers("mistralai/Mistral-7B-v0.1")
generator = outlines.generate.json(model, SentimentResult)
output = generator(f"Classify sentiment. Review: {review_text}")
# Token-level masking; schema violation is physically impossible
```

---

## Anti-Patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| `decision` before `reasoning` in schema | Model commits before reasoning; quality degrades | Put `reasoning` first in every schema that requires thought |
| Free-text where enums fit | Model generates creative but invalid values | Enumerate with `Literal` or `Enum` types |
| Deeply nested schemas | Models lose track of context inside nesting | Flatten to one level where possible |
| Missing `additionalProperties: false` | Extra fields sneak through; downstream code breaks on unexpected keys | Set `additionalProperties: false` in JSON Schema; Pydantic enforces by default |
| Skipping evals after switching to Gen 3/4 | Structured output ≠ correct output; schema conformance masks semantic errors | Evals are still required — schema enforcement only removes parse failures |
| Gen 1 in production | 5–20% parse failure rate; silent data loss | Upgrade to Gen 3 — often a two-line change |
