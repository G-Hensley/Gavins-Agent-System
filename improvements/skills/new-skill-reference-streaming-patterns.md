# New skill reference: streaming patterns for LLM applications

## What I Observed

Streaming is absent from the AI engineering references entirely. Most user-facing AI applications stream responses, and the implementation has subtleties — server-side transport, tool-use mid-stream, structured output mid-stream — that are not obvious without prior exposure.

Missing topics:

**Why stream**

- Time-to-first-token (TTFT) is the critical UX metric, not total generation time
- 3-second total response feels instant if the first token arrives in 200ms

**Implementation**

- Provider streaming APIs (Anthropic `messages.stream`, OpenAI `stream=True`)
- Server-Sent Events (SSE) as the standard web transport
- WebSocket as an alternative for bidirectional needs

**Streaming with tool use**

- Stream pauses when a tool is invoked
- Tool executes
- Stream resumes with the tool result incorporated
- UI must show "Searching..." / "Looking that up..." indicator during the pause

**Streaming structured output**

- Partial JSON can't be parsed until complete — three options:
  - Buffer server-side before parsing (defeats streaming for structured output)
  - Streaming JSON parser (`partial-json-parser`) — handles incomplete tokens
  - Stream prose portion, then send structured output as a single final chunk (recommended default)

## Why It Would Help

- Any user-facing AI feature in the operator's stack ships without streaming today; even if the model returns in 2 seconds, it feels slow
- Tool-use-during-stream is the biggest UX trap — without explicit handling, the UI just freezes during the tool call and the user assumes the system is broken
- Streaming structured output is genuinely tricky and the recommended default ("stream prose, send JSON whole") is non-obvious
- SSE is the right transport for most web apps; WebSocket is over-engineered for one-way streaming and frequently picked anyway

## Proposal

Create `skills/ai-engineering/references/streaming-patterns.md` with sections:

- Why stream — TTFT framing, when streaming isn't worth the complexity
- Provider APIs — Anthropic and OpenAI streaming snippets, common shape
- SSE for web — minimal handler example, event types (`text_delta`, `tool_use_start`, `tool_use_result`, `message_stop`)
- WebSocket alternative — when bidirectional matters; cross-link to security ref websocket-security (auth, message validation)
- Tool use mid-stream — UX pattern, indicator messaging, server-side state handling
- Streaming structured output — three options with the prose-then-JSON-whole default
- Anti-pattern list — buffer and stream (no point), top-tier model with no streaming (TTFT will be terrible), no error handling on stream interruption

Update `agents/ai-engineer.md` and `agents/frontend-engineer.md` to load this when streaming code is detected (`stream=True`, SSE handlers, `EventSource`).

## Open questions for review

- The operator's stack is Next.js / React; should the ref include a minimal client-side streaming component (using `EventSource` or `fetch` ReadableStream)? Yes, both — `EventSource` is simpler, `fetch` ReadableStream gives more control.
- Anthropic's `MessageStream` includes events for tool use; should the ref enumerate the full event taxonomy? Brief enumeration with a link to current docs — taxonomy may evolve.
- Is the websocket-security ref (proposed in the security improvements set) a hard prerequisite when WebSocket transport is used here? Yes — cross-link both ways.
