---
name: prompt-engineering
description: Build high-quality prompts through a guided interview. Use when the user runs `/build-prompt`, asks "help me write a prompt", or pastes a rough prompt and wants to refine it. Auto-detects whether the target is a system prompt, agent definition, slash command, or one-shot task prompt and tailors the interview + template accordingly. Output follows Anthropic's latest prompting best practices for Opus/Sonnet/Haiku 4.x models.
last_verified: 2026-04-26
---

# Prompt Engineering

Build production-quality Claude prompts through a guided interview. Output is a finished, ready-to-paste prompt saved to `prompts/<name>.md` and printed in the conversation.

## Activation

- User runs `/build-prompt <starting input>` (the slash command)
- User says "help me write a prompt", "let's craft a prompt for X", or pastes a rough draft and asks to improve it
- User opens an existing prompt file and asks to upgrade it for Claude 4.x

## Process

### 1. Detect prompt type

Auto-detect from the user's starting input. Use the heuristics in `references/interview-questions.md` (section "Type detection"). The four types:

- **System prompt** — voice, behavior, defaults baked into a Claude API call or harness CLAUDE.md
- **Agent prompt** — a specialist `.claude/agents/<name>.md` definition (frontmatter + role + process + handoff)
- **Slash command** — a short `commands/<name>.md` that triggers a multi-step workflow
- **One-shot task prompt** — a single message you'll paste into Claude.ai or send via API

If detection is ambiguous, **ask** which type. Don't guess on the type — it shapes everything downstream.

### 2. Run the interview

Load `references/interview-questions.md` and ask only the questions relevant to:
- The detected prompt type
- Information not already in the user's starting input

**Adaptive rule:** if the starting input is rich (≥200 words, names goal + audience + constraints), ask fewer questions. If it's a one-line "build a prompt for X", ask the full interview.

Hard cap: **8 questions**, asked one at a time, never as a numbered list. Wait for each answer before continuing.

### 3. Draft

Once the interview is done, draft the prompt using `references/prompt-templates.md` for the matching type. Apply the techniques in `references/best-practices.md`:

- Clear, direct, specific instructions (Anthropic's "golden rule")
- Role / system message anchoring tone and behavior
- Examples wrapped in `<example>` / `<examples>` tags when helpful (3–5)
- XML structure for complex prompts mixing instructions, context, examples, input
- Concrete success criteria — "what does done look like?"
- Output-format guidance that matches the desired output style
- For 4.x models: rely on adaptive thinking + effort, not extended-thinking budgets; no prefilled responses

### 4. Self-review

Before showing the draft to the user, run it through `references/anti-patterns.md` mentally:

- Is every instruction concrete (no vague verbs like "help" or "improve")?
- Is the desired output described positively (not just "don't do X")?
- Does the prompt's own format match the desired output format?
- Does it anchor a role and tone?
- For agent/slash-command prompts: is the trigger description (frontmatter `description` field) specific enough that the harness will route to it?
- Does it avoid deprecated patterns (prefilled assistant turns, `budget_tokens`, etc.)?

Fix any issues silently before presenting.

### 5. Present and save

Show the user:
1. **A short rationale** (2–4 sentences) — what type was detected, what techniques were applied, what to tune if it under/over-performs
2. **The full prompt** in a fenced code block
3. **The save path** — propose `prompts/<name>.md` in the current working directory

Save the file (creating `prompts/` if needed). Confirm with the path. If the user is on a system where the working directory is read-only or there's a clear better destination (e.g., the user said "this is for an agent definition"), propose `agents/<name>.md` or `commands/<name>.md` instead.

### 6. Iterate (optional)

After saving, offer one round of refinement: "Want me to tighten anything — voice, length, examples, structure?" Apply edits in place and re-save. Don't ping-pong indefinitely; suggest the user run the prompt and iterate empirically after 1–2 refinement rounds.

## Interview Discipline

- **One question at a time.** Multi-question batches make the user skim and skip.
- **Open-ended for goals, closed for constraints.** "What does success look like?" vs. "Should this run on Sonnet or Opus?"
- **Echo back before moving on** when an answer reveals a key constraint. ("So the audience is junior engineers — got it. Next…") This catches misreads early.
- **No filler questions.** If you can infer the answer with high confidence, skip the question and confirm in the rationale instead.

## What NOT to Do

- Don't write the prompt before the interview — premature drafts anchor on missing info
- Don't pad with boilerplate disclaimers or scaffolding the user didn't ask for
- Don't recommend deprecated patterns (prefilled assistant turns, manual `budget_tokens` thinking, `temperature` for design variety)
- Don't include "You are a helpful assistant" — empty role anchoring is worse than none
- Don't generate prompts with negation-only instruction blocks ("never X, never Y") — pair every "don't" with a positive direction
- Don't ask 10+ questions to draft a one-shot task prompt; cap interviews at 8 questions

## Reference Files

- `references/best-practices.md` — Anthropic's prompting guide for Claude 4.x condensed (clarity, examples, XML, role, output controls, tool use, thinking, agentic patterns)
- `references/interview-questions.md` — Question banks per prompt type + auto-detection heuristics
- `references/prompt-templates.md` — Ready-to-fill templates for system / agent / slash / one-shot prompts
- `references/anti-patterns.md` — Common prompt failure modes the self-review checks for

## Output Contract

Every successful run produces:
- One fenced prompt block in the conversation
- One saved file at the path agreed with the user
- A short rationale (2–4 sentences) noting type, techniques applied, and tuning levers

If the user re-runs `/build-prompt` on the same starting input later, the skill should produce a substantively similar prompt — determinism matters. Keep the interview consistent.
