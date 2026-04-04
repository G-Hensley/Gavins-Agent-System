# SDK & Provider Patterns

## Claude (Anthropic)

### Direct API
```python
from anthropic import Anthropic
client = Anthropic()
message = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    system="You are a helpful assistant.",
    messages=[{"role": "user", "content": "Task description"}],
)
```

### Agent SDK
```python
from claude_agent_sdk import Agent, tool

@tool
def search_database(query: str) -> list[dict]:
    """Search records matching the query."""
    return db.search(query)

agent = Agent(model="claude-sonnet-4-6", tools=[search_database])
result = agent.run("Find all active customers")
```

## OpenAI

### Direct API
```python
from openai import OpenAI
client = OpenAI()
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Task description"},
    ],
)
```

### Function Calling
```python
tools = [{
    "type": "function",
    "function": {
        "name": "search_database",
        "description": "Search records matching a query",
        "parameters": {
            "type": "object",
            "properties": {"query": {"type": "string"}},
            "required": ["query"],
        },
    },
}]
response = client.chat.completions.create(model="gpt-4o", messages=messages, tools=tools)
```

## Hugging Face

### Inference API
```python
from huggingface_hub import InferenceClient
client = InferenceClient(model="meta-llama/Llama-3-70b-chat-hf")
response = client.chat_completion(messages=[{"role": "user", "content": "Task"}])
```

### Local with Transformers
```python
from transformers import pipeline
generator = pipeline("text-generation", model="meta-llama/Llama-3-8b")
result = generator("Task description", max_new_tokens=512)
```

## Provider Abstraction Pattern
Wrap API calls so you can swap providers:
```python
class LLMClient:
    def __init__(self, provider: str, model: str):
        self.provider = provider
        self.model = model

    def complete(self, messages: list, **kwargs) -> str:
        if self.provider == "anthropic":
            return self._anthropic_complete(messages, **kwargs)
        elif self.provider == "openai":
            return self._openai_complete(messages, **kwargs)
        elif self.provider == "huggingface":
            return self._hf_complete(messages, **kwargs)
```

## Multi-Agent Patterns

### Sequential Pipeline
Agent A → Agent B → Agent C (each refines the previous output)

### Parallel Dispatch
Multiple agents work concurrently on independent subtasks, results aggregated.

### Orchestrator
One coordinating agent dispatches specialists, reviews results, decides next steps.

### Model Routing
Route by task complexity:
- **Simple** (classification, extraction): cheapest model (Haiku, GPT-4o-mini)
- **Standard** (generation, analysis): mid-tier (Sonnet, GPT-4o)
- **Complex** (architecture, nuanced reasoning): top-tier (Opus, GPT-4o)

## RAG Pattern
```
User query
  → Embed query (embedding model)
  → Search vector store (similarity search)
  → Retrieve top-K documents
  → Inject into prompt as context
  → Generate response with LLM
  → Return with source citations
```

## Error Handling
- **Rate limits (429)**: exponential backoff with jitter
- **Overload (529/503)**: longer backoff, consider fallback provider
- **Timeout**: set appropriate timeouts per task, retry once
- **Malformed response**: validate output format, retry with clearer instructions
- **Cost runaway**: log token usage per request, set budget alerts
