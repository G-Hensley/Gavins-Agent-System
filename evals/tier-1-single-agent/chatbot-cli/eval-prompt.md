Build a CLI chatbot that talks to Claude using the Anthropic Python SDK.

Requirements:
- Runs in the terminal as an interactive loop — user types a message, Claude responds, repeat
- Streaming responses: print tokens as they arrive, not all at once after the full response
- Conversation history: each message includes the full prior context so Claude remembers the conversation
- Graceful exit: typing `exit` or `quit` (or pressing Ctrl+C) ends the session cleanly
- The API key should be read from the `ANTHROPIC_API_KEY` environment variable — error clearly if it's missing
- Include pytest tests covering: history accumulation, graceful exit detection, missing API key handling
- Write tests first
