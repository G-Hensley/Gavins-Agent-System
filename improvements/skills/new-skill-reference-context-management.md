# New skill reference: context window management

## What I Observed

Context window management is mentioned in passing ("curate what the model needs") but not given systematic treatment. Context is the highest-leverage and most expensive resource in LLM applications, and the failure modes are subtle — a system that "works in dev" can fail in production simply because conversation history grew.

Missing topics:

**Token budget allocation** — for a 128K context, you don't have 128K useful tokens. Budget by category:

- System prompt: 500–2,000
- Conversation history: variable (managed)
- Retrieved context (RAG): 2,000–8,000 — more isn't always better
- Tool definitions: 200–500 per tool, scales linearly
- Output reserve: don't fill the window completely

**Conversation history strategies**

- Sliding window — last N messages; loses early context
- Summarization — compress older messages; LLM-call cost
- Hierarchical memory — short-term (recent, full) + long-term (summarized facts/decisions/preferences)
- Selective inclusion — relevance over recency

**RAG context optimization**

- Lost in the middle — models attend to start and end, ignore middle
- Irrelevant context degrades answers more than missing relevant context
- 3–5 high-quality chunks beats 10–15 mixed
- Context compression — LLM extracts only relevant sentences from each chunk before injection

## Why It Would Help

- Most "the agent forgot what we were doing" bugs are context-management bugs — sliding window dropped the relevant message, or summarization lost the key fact
- Reviewers and the `ai-engineer` agent currently have no token-budget defaults to recommend; "use a 128K window" gets repeated as if the whole window is usable
- Lost-in-the-middle is the highest-impact, lowest-known result in LLM context research; reordering RAG context (best chunks at start and end) is a free quality improvement
- Hierarchical memory is the right pattern for any agent with persistent memory across sessions — Cowork itself, the operator's `productivity:memory-management` setup, and any task-tracking agent

## Proposal

Create `skills/ai-engineering/references/context-management.md` with sections:

- Token budget allocation table — per category with defaults
- Conversation history strategies — 4 strategies with selection criteria
- RAG context optimization — lost-in-the-middle explained, ordering rule (best at edges), context compression pattern
- Tool definition cost — count tools, count tokens, decision rule for when to introduce a tool dispatcher
- Anti-pattern list — fill-the-window-because-you-can, summarize-everything (loses nuance), pure-recency selection

Update `agents/ai-engineer.md` and `agents/architect.md` to load when designing memory or context-heavy systems.

## Open questions for review

- Should the operator standardize a default conversation-history strategy across his agents? Hierarchical memory is the strongest default; sliding window is acceptable for short tasks.
- Is there value in a token-budget calculator (small script) shipped with the skill? Maybe — a script that takes (model, system_prompt_tokens, tool_count) and outputs recommended budget per category.
- Lost-in-the-middle changes per model and per version; should the ref be version-tagged? Mention it as a class of phenomenon, point to current research, don't pretend any one ordering is universal.
