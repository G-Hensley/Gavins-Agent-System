# Context Management

Context is the highest-leverage and most expensive resource in LLM applications. A 128K-token window does not mean 128K usable tokens — budget by category or you will hit silent failure modes in production.

---

## Token Budget Allocation

Default targets for a 128K-context model. Adjust proportionally for smaller windows.

| Category | Default range | Notes |
|---|---|---|
| System prompt | 500–2,000 | Fixed; review when adding capabilities |
| Conversation history | Variable (managed) | Never let this grow unbounded — see strategies below |
| Retrieved context (RAG) | 2,000–8,000 | More is not better; see RAG section |
| Tool definitions | 200–500 per tool | Scales linearly with tool count |
| Output reserve | 1,000–4,000 | Leave room; filling the window truncates generation |

**Rule:** sum your fixed costs (system prompt + tools), subtract the output reserve, then split the remainder between history and retrieved context based on which matters more for the task.

---

## Conversation History Strategies

| Strategy | How it works | Use when |
|---|---|---|
| Sliding window | Keep last N messages; drop older ones | Short tasks; early context doesn't matter |
| Summarization | Compress older messages with an LLM call; keep summary + recent | Sessions where key decisions were made early |
| Hierarchical memory | Short-term (recent, full) + long-term (summarized facts, preferences, decisions) | Persistent agents across sessions |
| Selective inclusion | Score messages by relevance to current query; include top K | Long conversations with topic shifts |

**Selection criteria:**
- If the agent has no persistent state across sessions, sliding window is acceptable.
- If early decisions constrain later ones (e.g., architecture choices, user preferences), use summarization or hierarchical memory.
- If the conversation spans many topics, selective inclusion prevents irrelevant history from crowding out relevant context.
- Pure recency (last N) is the most common default — and the most dangerous. A message from 20 turns ago that set a hard constraint is invisible under a sliding window.

```python
def build_history(messages: list[dict], budget: int, strategy: str, current_query: str) -> list[dict]:
    if strategy == "sliding":
        return messages[-MAX_TURNS:]
    if strategy == "summarize":
        recent = messages[-RECENT_TURNS:]
        older = messages[:-RECENT_TURNS]
        summary = llm.call(f"Summarize key facts and decisions:\n{older}")
        return [{"role": "system", "content": f"Earlier context: {summary}"}] + recent
    if strategy == "selective":
        scored = [(score_relevance(m, current_query), m) for m in messages]
        return [m for _, m in sorted(scored, reverse=True)[:TOP_K]]
```

---

## RAG Context Optimization

**Lost in the middle:** models attend most to the beginning and end of the context window. Content placed in the middle receives systematically less attention, regardless of relevance. This is a structural property of attention, not a prompt quality issue.

**Ordering rule:** place the highest-relevance chunks at the start and end of the injected context block, not in the middle. If you have 5 chunks, put ranks 1 and 2 at positions 1 and 5, ranks 3–5 in between.

**Fewer, higher-quality chunks beat many mixed chunks.** 3–5 high-quality retrieved chunks consistently outperform 10–15 mixed ones. Irrelevant context degrades answers more than missing relevant context.

**Context compression pattern:** before injecting a retrieved chunk, run it through an extraction step to pull only the sentences relevant to the query. Reduces token cost and sharpens signal.

```python
def compress_chunk(chunk: str, query: str) -> str:
    return llm.call(
        f"Extract only the sentences relevant to: {query}\n\nDocument:\n{chunk}\n"
        "Return only the relevant sentences, preserving their original wording."
    )

def build_rag_context(chunks: list[str], query: str, budget: int) -> str:
    compressed = [compress_chunk(c, query) for c in chunks[:5]]
    # Place best chunks at edges, not the middle
    ordered = [compressed[0]] + compressed[2:] + [compressed[1]]
    return "\n\n".join(ordered)
```

For deep RAG patterns (chunking strategy, embedding selection, hybrid search), see `./rag-engineering.md`.

---

## Tool Definition Cost

Each tool definition consumes 200–500 tokens before a single user message is sent. With 10 tools, you spend 2,000–5,000 tokens on definitions alone — before history, RAG, or output reserve.

**Decision rule:**
- 1–5 tools: include all definitions per call
- 6–10 tools: evaluate whether all are needed for this task; consider task-scoped subsets
- 10+ tools: introduce a tool dispatcher agent that receives the intent and routes to the appropriate specialized agent with a smaller tool set

```python
def select_tools(task: str, all_tools: list) -> list:
    # Let a cheap model pick the relevant subset
    relevant = classifier.call(
        f"Which tools are needed for this task: {task}\n"
        f"Available: {[t.name for t in all_tools]}"
    )
    return [t for t in all_tools if t.name in relevant]
```

For dispatcher architecture and tool design principles, see `./tool-design.md`.

---

## Anti-Patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| Fill the window because you can | Output gets truncated; inference slows; cost rises | Budget explicitly; leave an output reserve |
| Summarize everything | Nuance and specific facts lost in the summary | Preserve recent messages verbatim; summarize only older segments |
| Pure recency selection | Drops critical context from earlier in the session | Score by relevance, not only position |
| Uniform chunk ordering | Lost-in-the-middle degrades answer quality silently | Place best chunks at start and end |
| All tools always loaded | Fixed overhead grows linearly; context crowded | Load task-relevant tool subsets; use a dispatcher at 10+ tools |
| Growing history without a strategy | Works in dev; hits limits in production when sessions are long | Pick a history strategy at design time, not when things break |
