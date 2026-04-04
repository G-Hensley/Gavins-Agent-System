# Eval Criteria: ChatBot CLI

## 1. Dispatch Correctness

- [ ] `ai-engineer` agent was dispatched (primary — owns LLM integrations and Anthropic SDK usage)
- [ ] `automation-engineer` agent dispatched or consulted for the CLI loop and input handling
- [ ] Agent was not skipped in favor of inline implementation

**Fail condition:** Full chatbot implemented in main thread without dispatching `ai-engineer`. A backend or automation agent used alone for an LLM integration task.

---

## 2. TDD Compliance

- [ ] Test file created before chatbot implementation
- [ ] Tests for history accumulation written before the history feature was implemented
- [ ] Tests for exit-command detection written before the input loop
- [ ] Tests for missing API key handling written before the env-var check
- [ ] Anthropic SDK calls are mocked in tests — tests do not make live API calls
- [ ] Tests were run and confirmed failing before each implementation step
- [ ] All tests pass with clean output after implementation

**Fail condition:** Tests written after implementation. Tests make live API calls (flaky, requires real key). Exit detection or history tests missing entirely.

---

## 3. Output Quality

- [ ] Interactive loop works: program waits for input and responds
- [ ] Responses stream to the terminal token-by-token (not printed all at once)
- [ ] After two exchanges, Claude's response reflects context from earlier in the conversation
- [ ] Typing `exit` ends the session without a stack trace
- [ ] Typing `quit` ends the session without a stack trace
- [ ] Ctrl+C (KeyboardInterrupt) is caught and exits cleanly
- [ ] Running without `ANTHROPIC_API_KEY` set prints a clear error and exits with code 1
- [ ] pytest suite passes with zero failures

**Fail condition:** Streaming not implemented — full response printed after delay. KeyboardInterrupt produces a traceback. History not maintained — Claude has no memory of previous messages. Missing API key causes an unhandled exception.

---

## 4. Agent-Specific Rules (ai-engineer)

- [ ] Anthropic `client.messages.stream()` or equivalent streaming API used (not `messages.create` with blocking call)
- [ ] Conversation history maintained as a list of `{"role": ..., "content": ...}` dicts passed to each API call
- [ ] API key sourced from environment — not hardcoded, not prompted at runtime
- [ ] Model name is configurable or clearly documented — not buried as a magic string
- [ ] Token/response errors from the API are caught and reported, not allowed to crash the loop
- [ ] Code is separated: API interaction, history management, and input/output loop are distinct concerns

**Fail condition:** `messages.create` used without streaming. History list not passed to subsequent calls. Model name hardcoded with no comment or config. API errors crash the loop with a raw exception traceback.

---

## Scoring

| Category | Weight | Pass |
|---|---|---|
| Dispatch correctness | 25% | ai-engineer dispatched |
| TDD compliance | 25% | Tests first, SDK mocked, RED phase documented |
| Output quality | 30% | Streaming works, history maintained, clean exits |
| Agent-specific rules | 20% | Streaming API used, history passed per call, errors handled |

**Overall pass threshold: 80%**
