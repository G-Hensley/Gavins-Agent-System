# Streaming Patterns

Streaming delivers tokens to the client as they are generated rather than buffering the full response. The critical metric is **time-to-first-token (TTFT)**, not total generation time.

A 4-second response that streams feels fast. A 4-second response that appears all at once feels broken.

## Why Stream

**Stream when:** response is user-facing and latency is noticeable (>500ms), or you need to show tool-use progress mid-reasoning.

**Skip when:** output feeds an automated pipeline, the full output is needed before any action, or the response is short enough that buffering adds no perceptible delay.

---

## Provider APIs

Both major providers follow the same shape: open a stream, iterate over events, close.

**Anthropic**
```python
with client.messages.stream(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    messages=[{"role": "user", "content": prompt}],
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)
    final = stream.get_final_message()
```

**OpenAI**
```python
stream = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": prompt}],
    stream=True,
)
for chunk in stream:
    delta = chunk.choices[0].delta.content or ""
    print(delta, end="", flush=True)
```

Drop to raw events (lower-level API) when handling tools or stop-reason information; use the text iterator above for simple prose.

---

## SSE for Web

Server-Sent Events (SSE) is the standard transport for one-way LLM streaming over HTTP. The server pushes newline-delimited `data:` frames; the client reads them as a stream.

**App-level SSE event types** (what your server emits to the browser — defined by you, not Anthropic's transport):

| Event | When |
|---|---|
| `text_delta` | Token chunk ready — append to display |
| `tool_use_start` | Tool invocation begins — show progress indicator |
| `tool_use_result` | Tool result ready — result returned to model |
| `message_stop` | Response complete — clean up UI state |

These map from Anthropic's transport events: `content_block_delta`→`text_delta`, `content_block_start(tool_use)`→`tool_use_start`, `content_block_stop(tool)`→`tool_use_result`, `message_stop`→`message_stop`.

**Minimal FastAPI SSE handler**
```python
from fastapi.responses import StreamingResponse

async def generate():
    with client.messages.stream(model="claude-sonnet-4-6",
                                max_tokens=1024,
                                messages=messages) as stream:
        for text in stream.text_stream:
            yield f"data: {json.dumps({'type': 'text_delta', 'text': text})}\n\n"
        yield f"data: {json.dumps({'type': 'message_stop'})}\n\n"

@app.get("/chat")
async def chat(message: str):
    return StreamingResponse(generate(), media_type="text/event-stream")
```

---

## WebSocket Alternative

Use WebSocket when the connection is genuinely bidirectional — client sends multiple messages in one session, or you need server-push outside of request/response (live collaboration, voice pipelines with interruptions). For standard chat (one request, one streamed response), SSE is simpler and sufficient; WebSocket adds connection lifecycle overhead for no benefit.

<!-- TODO(security-bundle): link to skills/security/references/websocket-security.md when Security bundle ships -->

---

## Tool Use Mid-Stream

When a tool call occurs mid-stream, the model pauses token generation, requests tool execution, and resumes after the result is returned. Without explicit UI handling, the user sees the stream freeze silently.

On `content_block_start` with `type: tool_use`, emit a UI indicator event ("Searching...", "Running..."), execute the tool, inject the result, then emit `tool_done` to clear the indicator before resuming the stream.

**Server-side state handling** — key buffers by `content_block.index` so deltas/stops match the right block (handles concurrent tool calls correctly):
```python
tool_blocks = {}  # index -> {"name": ..., "input": ""}

for event in stream:
    if event.type == "content_block_start" and event.content_block.type == "tool_use":
        tool_blocks[event.content_block.index] = {
            "name": event.content_block.name, "input": ""
        }
        yield sse({"type": "tool_indicator", "text": indicator_for(event.content_block.name)})
    elif event.type == "content_block_delta" and event.delta.type == "input_json_delta":
        if event.index in tool_blocks:
            tool_blocks[event.index]["input"] += event.delta.partial_json
    elif event.type == "content_block_stop" and event.index in tool_blocks:
        block = tool_blocks.pop(event.index)
        result = execute_tool(block["name"], json.loads(block["input"]))
        yield sse({"type": "tool_done"})
```

Common indicator text: "Searching...", "Running...", "Looking that up...", "Fetching records...".

For indirect prompt injection risks in tool-use pipelines, see `./llm-security.md`.

---

## Streaming Structured Output

Partial JSON cannot be parsed until the full token sequence is received. Three options:

**Option A — Buffer server-side before parsing**
Accumulate the entire stream, then parse. Correct and simple. Defeats streaming for structured content — the user waits for full generation before seeing anything.

**Option B — Streaming JSON parser**
Libraries like `partial-json-parser` (npm) can parse incomplete JSON incrementally. Handles missing closing braces/brackets. Adds a dependency and edge-case complexity; use only if you need live UI updates on a JSON payload (e.g., form fields populating as they generate).

**Option C — Stream prose, send JSON whole at end (recommended default)**

Design the response so the model streams a prose explanation first, then emits the structured payload as the final chunk. The user sees readable output in real time; the structured data arrives complete and parseable.

```python
# System prompt pattern:
# "First explain your reasoning in plain text.
#  Then output a JSON block on its own line: <json>{...}</json>"

for text in stream.text_stream:
    if "<json>" in text:
        # switch to buffer mode — collect until </json>
        structured_buffer += text
    else:
        yield sse({"type": "text_delta", "text": text})

payload = extract_between_tags(structured_buffer, "<json>", "</json>")
yield sse({"type": "structured_result", "data": json.loads(payload)})
```

---

## Client Snippets

**EventSource (simpler — read-only, automatic reconnect)**
```typescript
const source = new EventSource("/chat");
source.onmessage = (e) => {
  const event = JSON.parse(e.data);
  if (event.type === "text_delta") appendText(event.text);
  if (event.type === "tool_indicator") showIndicator(event.text);
  if (event.type === "structured_result") handleResult(event.data);
  if (e.data === "[DONE]") source.close();
};
source.onerror = () => source.close();
```

`EventSource` only supports GET requests. If you need to send a POST body (e.g., a chat message), use the `fetch` ReadableStream approach below.

**fetch ReadableStream (more control — supports POST, custom headers)**
```typescript
const res = await fetch("/chat", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ message }),
});
const reader = res.body!.getReader();
const decoder = new TextDecoder();
while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  for (const line of decoder.decode(value).split("\n")) {
    if (!line.startsWith("data: ")) continue;
    const raw = line.slice(6);
    if (raw === "[DONE]") break;
    const event = JSON.parse(raw);
    handleEvent(event);
  }
}
```

---

## Anti-Patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| Buffer the full stream, then send to client | Zero UX benefit — user still waits for full generation | Stream tokens directly; don't accumulate before forwarding |
| Top-tier model with no streaming | TTFT on Opus/GPT-4 can exceed 3–5s; buffered delivery feels broken | Always stream user-facing calls to large models |
| No error handling on stream interruption | Network drops mid-stream leave the UI frozen or partially rendered | Wrap stream reads in try/finally; emit an error event and close cleanly |
| Using WebSocket for one-way chat responses | Unnecessary complexity — connection lifecycle, heartbeats, reconnection | Use SSE for unidirectional streaming; WebSocket only when bidirectional |
| Streaming into a structured-output parser without fallback | Partial JSON parser edge cases surface in production | Default to Option C (prose stream + JSON whole); fall back to buffer if parse fails |