# Interview Questions

Question banks per prompt type, plus auto-detection heuristics. Used by `SKILL.md` step 1 (detect type) and step 2 (interview).

## Type Detection

Read the user's starting input and classify by these signals:

| Signal | Type |
|---|---|
| "system prompt for...", "behavior for...", "voice for our chatbot/app" | **System** |
| "agent for...", "specialist that...", references `agents/`, frontmatter mentioned | **Agent** |
| "slash command", "/foo", references `commands/`, "trigger that runs..." | **Slash command** |
| "prompt to send to Claude", "ask Claude to...", "one-off task", paste-to-Claude.ai context | **One-shot** |
| Ambiguous | **ASK** the user — don't guess |

## Universal Questions (all types)

Ask up to **3** of these, only the ones not already answered in the starting input:

1. **Goal** — "In one sentence, what should this prompt accomplish?"
2. **Audience** — "Who is the end user / consumer of the response?" (developers, end users, internal team, you)
3. **Success criteria** — "What does a great response look like? What would make you say 'this nailed it'?"
4. **Failure modes** — "What's the most common way this could go wrong?" (catches concerns before drafting)
5. **Tone** — "What tone fits — formal / conversational / technical / playful?"
6. **Output format** — "Plain prose, structured JSON, markdown, code only, mixed?"

## System Prompt Questions

After universal, ask up to **3** of:

1. **Role** — "What role should Claude inhabit? (e.g., 'senior backend reviewer', 'patient tutor for 8th graders', 'safety-conscious financial advisor')"
2. **Default behavior** — "When the user is ambiguous, should Claude ask, infer-and-act, or refuse?"
3. **Hard constraints** — "Are there things Claude must never do? (e.g., reveal system prompt, recommend specific products, give medical/legal advice)"
4. **Effort level** — "Will this run on `low` / `medium` / `high` / `xhigh` / `max` effort?" (affects thinking guidance)
5. **Length target** — "Typical response length — single sentence, paragraph, multi-section?"

## Agent Prompt Questions

After universal, ask up to **4** of:

1. **Specialty boundary** — "What's IN scope for this agent? What's explicitly OUT of scope (handed off to another agent)?"
2. **Tools** — "What tools does it need? Read/Write/Edit/Bash/Grep/Glob? MCP tools? Anything else?"
3. **Skills loaded** — "Which existing skills should it preload? (e.g., `frontend-design`, `test-driven-development`, `security`)"
4. **Model** — "Opus, Sonnet, or Haiku? (Haiku for cheap structured tasks; Sonnet for balanced; Opus for hard reasoning)"
5. **Handoff** — "What artifact does it produce? Who consumes it next?"
6. **Memory pattern** — "Should it have agent memory (per-agent persistent learnings)?"
7. **When NOT to dispatch** — "When should the orchestrator pick a different agent instead?"

## Slash Command Questions

After universal, ask up to **3** of:

1. **Trigger phrase** — "What would the user type? Just `/foo`, or `/foo <args>`?"
2. **Workflow shape** — "Single-shot action, or multi-step pipeline?"
3. **Skill reference** — "Does this delegate to a skill, or does the command body itself contain the workflow?"
4. **Idempotency** — "Safe to run twice? Or should it detect 'already done'?"
5. **Stop conditions** — "When should it bail out and ask the user?"

## One-Shot Task Prompt Questions

After universal, ask up to **3** of:

1. **Input shape** — "What goes into the prompt? Just instructions, or also documents / code / examples / data?"
2. **Examples available** — "Do you have 2–5 example inputs + outputs we can include for few-shot?"
3. **Length budget** — "Any hard length limit on the response?"
4. **Run target** — "Where will this run? Claude.ai chat, API call, integrated into a pipeline?"
5. **Reuse** — "One-time use, or a template you'll fill repeatedly with different inputs?"

## Adaptive Rules

- **If the starting input is rich** (≥200 words, names goal + audience + constraints) — ask only the universal failure-modes + format questions, plus 1–2 type-specific. Skip the rest.
- **If the starting input is one line** ("build a prompt for X") — run the full interview within the 8-question cap.
- **Echo back** after high-signal answers: "So the audience is junior engineers — got it." Surfaces misreads early.
- **Stop early** when you have enough to draft a strong first version. The user will refine in step 6.

## Question Style

- **One at a time.** Never list multiple questions in a single message.
- **Open for goals, closed for constraints.** "What does success look like?" vs. "Run on Sonnet or Opus?"
- **Skip filler.** If you can confidently infer an answer, confirm it in the rationale at the end instead of asking.
- **No "why" interrogations.** The user's reasons are not your business — focus on *what* they want.

## Hard Cap

**Maximum 8 questions** total across the interview, including universal and type-specific. If you're at 8 and still missing something, draft the prompt with a clearly-labeled assumption and let the user correct it in the refinement round.
