# Prompt Anti-Patterns

Common failure modes the self-review (SKILL.md step 4) checks for. If you see these in your draft, fix before presenting.

## Vague Verbs

`help me with`, `look at`, `improve`, `make it better`, `optimize`. Claude will guess what you mean and the guess is rarely what you wanted.

**Fix:** concrete verb + concrete target. `Rewrite the function to use async/await.` `List the SQL injection risks in this query.` `Cut the response to under 200 words.`

## Negation-Only Instructions

`Never use markdown.` `Don't be verbose.` `Avoid X.` Negation tells Claude what NOT to do but leaves the positive direction undefined. The result drifts to other unwanted patterns.

**Fix:** pair every "don't" with the desired alternative.
- ❌ `Don't use bullet points.`
- ✅ `Write in flowing prose paragraphs.`
- ❌ `Don't be verbose.`
- ✅ `Provide concise responses — typically 2–4 sentences. Skip non-essential context.`

## Empty Role Anchoring

`You are a helpful assistant.` `You are an AI.` These add nothing.

**Fix:** specific role with domain + posture. `You are a senior backend reviewer specializing in Python and AWS, focused on security and performance.`

## Format Mismatch Between Prompt and Output

If your prompt is heavy on bullet lists and headers, Claude will mirror that style. If you ask for prose in a markdown-heavy prompt, you'll often get markdown anyway.

**Fix:** match the prompt's own format to the desired output style. Want flowing prose? Write the prompt as flowing prose. Want JSON? Use a code-block schema in the prompt.

## Examples That Over-Fit

A single example becomes a template Claude copies too literally. Two examples are a coin flip — Claude picks the closer one and ignores the other.

**Fix:** **3–5 diverse examples**, deliberately covering edge cases. Don't make all examples the same shape.

## Conflicting Instructions

`Be thorough but concise.` `Use markdown but keep it minimal.` `Always cite sources but don't be repetitive.`

**Fix:** pick a side, or specify when each applies. `Concise (under 200 words) for routine answers. Thorough (with sub-sections) when the question explicitly asks "explain in detail."`

## Vague Success Criteria

Without "what does done look like?", Claude calibrates ambiguously and tends toward over-explanation.

**Fix:** name the criteria. `Done = three actionable recommendations, each with a one-line rationale.` `Done = the function passes the test cases I gave you.`

## Missing Output Format

Claude will produce *some* format. If you didn't specify, you'll get whatever the model defaults to — often markdown with bullet lists.

**Fix:** state format explicitly. `Output as a JSON object matching this schema: {...}.` `Output as 2–3 prose paragraphs with no headings.` `Output as a code block, no commentary.`

## Deprecated Patterns (Claude 4.6+)

These no longer work as documented:

- **Prefilled assistant turns on the last message** — return a 400 error on Mythos Preview. Use Structured Outputs, direct format instructions, or post-processing instead.
- **`thinking: {type: "enabled", budget_tokens: N}`** — deprecated. Use `thinking: {type: "adaptive"}` + `output_config.effort`.
- **Manual extended thinking budget caps** — use `effort` settings (low/medium/high/xhigh/max) and `max_tokens` as a hard ceiling.
- **`temperature` for design/output variety** — use the "propose 4 directions, ask user to pick" pattern instead.

## Over-Prompting on 4.5/4.6/4.7

These models are responsive to system prompts. Phrases like `CRITICAL: You MUST use this tool when...` overtrigger. Tools that needed aggressive language to fire on older models will now fire too often.

**Fix:** plain `Use this tool when...` phrasing. Trust the model.

## "Think About" When Thinking Is Off

On Opus 4.5, the word `think` is sensitive when extended thinking is disabled.

**Fix:** use `consider`, `evaluate`, `reason through` instead.

## Wall-of-Text Without Structure

A 500-word system prompt with no sections, no XML tags, no headings. Claude can parse it but the signal-to-noise drops.

**Fix:** XML tags for distinct content types (`<instructions>`, `<context>`, `<examples>`, `<input>`). Markdown headings for sections. Whitespace between blocks.

## Claiming Magical Reasoning

`Think VERY carefully step by step.` `You have unlimited intelligence.` `You are the world's greatest expert.` These do nothing.

**Fix:** specify the *content* of the reasoning. `Before answering, list 2–3 hypotheses about the cause. Verify each against the symptoms before picking one.`

## Asking the Model What Model It Is

Without a system prompt anchor, Claude often answers vaguely or incorrectly about its identity. This is a model behavior, not a prompting problem.

**Fix:** if model identity matters in the response, anchor it: `The assistant is Claude, created by Anthropic. The current model is Claude Opus 4.7.`

## "You are an expert in everything"

Generic super-expert framing makes responses worse, not better. The model interprets it as license to be vague and authoritative.

**Fix:** narrow the role to one domain + the actual posture you want. `You are a careful, experienced Python code reviewer. You flag bugs you're confident about and ask questions when uncertain.`

## Self-Review Checklist

Before presenting any drafted prompt, run through:

- [ ] Every instruction is concrete (no `help`, `improve`, `look at`)
- [ ] Every "don't" is paired with a positive direction
- [ ] Role is specific (not "helpful assistant")
- [ ] Output format is stated explicitly
- [ ] Success criteria are named
- [ ] Prompt format matches desired output format
- [ ] No deprecated patterns (prefill, `budget_tokens`, manual extended thinking)
- [ ] No over-prompting language ("CRITICAL: YOU MUST")
- [ ] Examples are 0 or 3+ (never just 1 or 2)
- [ ] No conflicting instructions
- [ ] No wall-of-text — uses XML tags or sections for clarity
