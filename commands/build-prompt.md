Build a high-quality Claude prompt through a guided interview. Pass a starting input as the argument: `/build-prompt <starting prompt or description>`. Auto-detects whether the target is a system prompt, agent definition, slash command, or one-shot task prompt and tailors the interview + template accordingly.

Run the `prompt-engineering` skill:

1. **Detect type** — system prompt, agent prompt, slash command, or one-shot task prompt. Heuristics in `skills/prompt-engineering/references/interview-questions.md`. If ambiguous, ask the user.

2. **Interview** — load the question bank for the detected type. Ask one question at a time. Hard cap: 8 questions. Adapt depth to how rich the starting input is.

3. **Draft** — apply Anthropic's Claude 4.x best practices (`references/best-practices.md`) using the matching template (`references/prompt-templates.md`). Anchor a specific role, use XML structure where it helps, include 3–5 examples or none, write positive instructions.

4. **Self-review** — check the draft against `references/anti-patterns.md`. Fix silently before presenting.

5. **Present + save** — show a 2–4 sentence rationale, the full prompt in a fenced block, and save to `prompts/<name>.md` in the current working directory (or `agents/<name>.md` / `commands/<name>.md` if the type warrants it).

6. **Offer one refinement round** — tighten voice, length, examples, or structure. Then suggest the user run the prompt and iterate empirically.

Full process: `skills/prompt-engineering/SKILL.md`.
