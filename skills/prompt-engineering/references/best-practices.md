# Anthropic Prompting Best Practices (Claude 4.x)

Condensed from Anthropic's prompt engineering guide for Claude Opus 4.7 / Opus 4.6 / Sonnet 4.6 / Haiku 4.5. Use when drafting any prompt with the `prompt-engineering` skill.

## The Golden Rule

> Show your prompt to a colleague with minimal context on the task and ask them to follow it. If they'd be confused, Claude will be too.

Specificity beats cleverness. State the goal, the output format, the constraints, and the success criteria. If you want "above and beyond" behavior, **explicitly request it** — Claude won't infer it from vague prompts.

## Core Techniques

### 1. Be clear and direct
- Sequential steps as numbered lists when order matters
- Specify the output format and constraints
- Replace vague verbs ("help me", "look at") with concrete actions ("rewrite this function", "list edge cases for")

**Less effective:** `Create an analytics dashboard`
**More effective:** `Create an analytics dashboard. Include as many relevant features and interactions as possible. Go beyond the basics to create a fully-featured implementation.`

### 2. Add context for the *why*
Claude generalizes well from the reason behind an instruction.

**Less effective:** `NEVER use ellipses`
**More effective:** `Your response will be read aloud by a TTS engine — never use ellipses since it can't pronounce them.`

### 3. Use examples (multishot)
3–5 well-crafted examples dramatically improve format/tone/structure consistency.

- **Relevant** — mirror the actual use case
- **Diverse** — vary edge cases so Claude doesn't pattern-match too narrowly
- **Structured** — wrap in `<example>` (single) or `<examples>` (multiple) tags

### 4. Structure with XML tags
For prompts mixing instructions + context + examples + input, wrap each in its own descriptive tag (`<instructions>`, `<context>`, `<input>`, `<documents>`). Nest when natural.

### 5. Anchor a role
A single role sentence shifts tone and behavior:
```
You are a helpful coding assistant specializing in Python.
```
"You are a helpful assistant" is empty — say something specific or skip the role entirely.

### 6. Long-context structure
With 20k+ tokens of input:
- Put long documents **at the top** of the prompt, query at the bottom (up to 30% better in tests)
- Wrap each document in `<document index="n">` with `<source>` + `<document_content>` subtags
- Ask Claude to **quote relevant passages first** before answering — cuts hallucination

## Output Control

### Verbosity
Claude 4.7 calibrates length to perceived complexity. To shorten: `Provide concise, focused responses. Skip non-essential context, and keep examples minimal.` Positive examples of the desired voice beat negative "don't do X" instructions.

### Format
- **Tell it what to do, not what not to do.** "Write in flowing prose paragraphs" beats "don't use markdown."
- **Match the prompt's own format to the desired output.** Markdown-heavy prompts produce markdown-heavy outputs.
- **Use XML format indicators:** `Write the prose in <smoothly_flowing_prose> tags.`
- For minimal markdown: explicit prose-first instruction in `<avoid_excessive_markdown_and_bullet_points>` block

### LaTeX
Claude 4.6+ defaults to LaTeX for math. To force plain text: `Format math in plain text only. No LaTeX, MathJax, or markup. Use "/" for division, "*" for multiplication, "^" for exponents.`

### Prefilled responses (DEPRECATED)
Prefilled assistant messages on the last turn are not supported on 4.6+ and will return 400 on Mythos Preview. Replace with:
- **Format control** → ask for it directly + Structured Outputs feature
- **Skip preamble** → `Respond directly without preamble. Do not start with "Here is..." or "Based on...".`
- **Continuations** → restart in user message: `Your previous response was interrupted at: "[last text]". Continue from there.`

## Tool Use

### Be explicit about action
"Can you suggest changes" → Claude suggests. "Make these changes" / "Edit this function" → Claude acts.

System-prompt anchors:
- **Proactive:** `<default_to_action>By default, implement changes rather than only suggesting them. If intent is unclear, infer the most useful likely action and proceed.</default_to_action>`
- **Conservative:** `<do_not_act_before_instructions>Do not jump into implementation. Default to research, recommendations, and clarifying questions until the user explicitly asks for action.</do_not_act_before_instructions>`

### Parallel tool calls
Claude 4.x parallelizes well by default. To boost to ~100%:
```
<use_parallel_tool_calls>
If you intend to call multiple tools and there are no dependencies between them, make all independent calls in parallel. Maximize parallel calls for speed. If a call depends on a prior result, call sequentially — never use placeholders or guess parameters.
</use_parallel_tool_calls>
```

### Don't over-prompt
4.5/4.6/4.7 are responsive to system prompts. Drop "CRITICAL: You MUST" language — it overtriggers. Use plain "Use this tool when..." phrasing.

## Thinking & Effort

### Adaptive thinking (4.6+)
`thinking: {type: "adaptive"}` + `output_config.effort` controls depth. Effort levels:

- **`max`** — diminishing returns; sometimes overthinks
- **`xhigh`** (4.7) — best for most coding/agentic
- **`high`** — minimum for intelligence-sensitive work
- **`medium`** — cost-sensitive
- **`low`** — short, scoped, latency-critical only

`budget_tokens` is deprecated on 4.6+. Use effort instead.

### Steering thinking
Reduce thinking: `Thinking adds latency and should only be used when it meaningfully improves answer quality — typically multi-step reasoning. When in doubt, respond directly.`

Increase thinking at low effort: `This task involves multi-step reasoning. Think carefully before responding.`

When thinking is OFF, on Opus 4.5 the word "think" is sensitive — use "consider", "evaluate", "reason through".

## Agentic Patterns

### Long-horizon state tracking
- **Structured formats** (`tests.json`) for test/task status
- **Unstructured progress notes** (`progress.txt`) for general state
- **Git** as the durable checkpoint — Claude 4.x uses it well across sessions
- Encourage incremental progress; commit completed components

### Context awareness
Claude 4.6+ tracks remaining context. For long agentic loops in compacting harnesses:
```
Your context window will be automatically compacted as it approaches its limit. Do not stop tasks early due to token budget concerns. As you approach the limit, save progress and state to memory before context refreshes. Never artificially stop early.
```

### Reversibility / safety
Without guidance, the model may take destructive actions. For confirmation gates:
```
For local, reversible actions (editing files, running tests), proceed. For destructive or hard-to-reverse actions (deleting files, force-push, modifying shared infrastructure, posting publicly), ask the user before acting.
```

### Subagents
4.7 spawns fewer by default. Steer with explicit when-to-spawn rules. 4.5/4.6 can over-spawn — steer with explicit when-NOT-to-spawn rules.

### Anti-overengineering
For coding agents prone to scope creep:
```
Avoid over-engineering. Only make changes directly requested or clearly necessary. Don't add features, refactor unrelated code, or "improve" beyond what was asked. Don't add docstrings/comments to code you didn't change. Don't add error handling for scenarios that can't happen.
```

### Anti-hallucination (coding)
```
<investigate_before_answering>
Never speculate about code you haven't opened. If the user references a specific file, READ it before answering. Investigate relevant files BEFORE making claims about the codebase.
</investigate_before_answering>
```

## Model Identity

When the prompt needs Claude to identify itself:
```
The assistant is Claude, created by Anthropic. The current model is Claude Opus 4.7.
```

For LLM-powered apps that pick a model:
```
When an LLM is needed, default to Claude Opus 4.7 unless the user requests otherwise. The exact model string is claude-opus-4-7.
```
