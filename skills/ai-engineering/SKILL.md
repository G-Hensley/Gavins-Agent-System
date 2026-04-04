---
name: ai-engineering
description: Build AI-powered applications — agents, chatbots, automation, pipelines, RAG systems, and LLM integrations across any provider (Claude, OpenAI, Hugging Face, local models). Use when building agentic systems, chatbots, AI features, prompt engineering, RAG, fine-tuning workflows, or integrating any LLM. Also use when the user says "build an agent", "chatbot", "AI automation", "LLM", "RAG", "embeddings", "prompt engineering", "AI pipeline", or works with any AI/ML API.
---

# AI Engineering

Build AI-powered applications across any provider or model. Covers agent frameworks, API integration, prompt engineering, RAG, chatbots, and multi-agent orchestration.

## Process

### 1. Identify the Application Type
- **Chatbot / conversational** — user-facing dialogue, context management, personality
- **Agent / autonomous** — goal-directed, tool use, multi-step reasoning
- **Multi-agent system** — agents coordinating, handing off, reviewing each other
- **RAG (Retrieval-Augmented Generation)** — search knowledge base, inject into prompt, generate
- **AI automation** — LLM integrated into a larger pipeline (data processing, content generation, classification)
- **Human-in-the-loop** — agent works, pauses for approval, continues

### 2. Select the Stack
Choose provider and framework based on requirements:

**Providers:**
- **Anthropic (Claude)** — strong reasoning, tool use, long context, agent SDK
- **OpenAI (GPT)** — broad ecosystem, function calling, assistants API, fine-tuning
- **Hugging Face** — open models, self-hosted, fine-tuning, embeddings
- **Local models** (Ollama, vLLM) — privacy, no API costs, latency control

**Frameworks:**
- **Claude Agent SDK** (Python/TS) — multi-agent orchestration with tools
- **LangChain / LlamaIndex** — chains, RAG, tool integration across providers
- **OpenAI Assistants API** — managed threads, file search, code interpreter
- **Direct API** — simple completions, structured output, maximum control

Read `references/sdk-patterns.md` for provider-specific integration patterns.

### 3. Design the Architecture
Apply the `architecture` skill with these AI-specific concerns:
- **Prompt design** — system prompts, few-shot examples, output format
- **Context management** — what goes in, token budget, summarization strategy
- **Tool definitions** — clear names, descriptions, parameter schemas
- **Model selection** — match capability to task (cheap for simple, capable for complex)
- **Guardrails** — input validation, output filtering, content safety
- **Cost optimization** — caching, model routing, context pruning

### 4. Implement and Test
Follow `writing-plans` → `subagent-driven-development` for implementation. AI-specific testing:
- Test with varied inputs (happy path, edge cases, adversarial)
- Test tool calling behavior (correct tool selected, parameters valid)
- Test error recovery (API failures, rate limits, malformed responses)
- Test across providers if multi-provider (responses differ in format/quality)
- Measure token usage, latency, and cost per request

## What NOT to Do

- Do not lock into a single provider without abstraction — wrap API calls so you can swap models
- Do not use the most expensive model for every task — route by complexity
- Do not send entire codebases/databases as context — curate what the model needs
- Do not skip error handling — every provider returns rate limits, timeouts, and validation errors
- Do not hardcode prompts — externalize for iteration and A/B testing
- Do not trust model output without validation — verify before acting on results
- Do not build custom orchestration when an SDK handles it
- Do not ignore cost — log token usage and set budget alerts

## Reference Files

- `references/sdk-patterns.md` — Provider integration patterns (Claude, OpenAI, Hugging Face), agent frameworks, tool definitions, multi-turn patterns. Read when building any AI integration.
- `references/prompt-engineering.md` — Prompt design, structured output, few-shot patterns, system prompts, context management, RAG prompting. Read when designing prompts for any provider.
- `ai-engineer` subagent (in `~/.claude/agents/`) — Subagent for reviewing AI application architecture, prompt quality, and provider integration.
