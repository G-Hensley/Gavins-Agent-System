---
name: ai-engineering
description: Build AI-powered applications — agents, chatbots, automation, pipelines, RAG systems, and LLM integrations across any provider (Claude, OpenAI, Hugging Face, local models). Use when building agentic systems, chatbots, AI features, prompt engineering, RAG, fine-tuning workflows, or integrating any LLM. Also use when the user says "build an agent", "chatbot", "AI automation", "LLM", "RAG", "embeddings", "prompt engineering", "AI pipeline", or works with any AI/ML API.
last_verified: 2026-04-28
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
- See `references/agentic-design-patterns.md` for pattern selection ladder (ReAct, Reflection, Planning, HITL, Evaluator-Optimizer).
- See `references/context-management.md` for token-budget defaults and conversation-history strategies.

### 4. Implement and Test
Follow `writing-plans` → `subagent-driven-development` for implementation. AI-specific testing:
- Test with varied inputs (happy path, edge cases, adversarial)
- Test tool calling behavior (correct tool selected, parameters valid)
- Test error recovery (API failures, rate limits, malformed responses)
- Test across providers if multi-provider (responses differ in format/quality)
- Measure token usage, latency, and cost per request
- See `references/evaluation-and-observability.md` for eval suite design (offline + online eval, tracing, drift detection).

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
- `references/project-structure.md` — AI project layout (agents, chains, prompts, tools, embeddings, retrieval, tests). Read when scaffolding a new AI/LLM project.
- `references/prompt-engineering.md` — Prompt design basics, system prompts, few-shot, structured output overview. Read when designing prompts.
- `references/prompt-engineering-advanced.md` — Chain of Thought, decomposition, context positioning, negative examples, temperature selection. Read after `prompt-engineering.md` for production prompts.
- `references/agentic-design-patterns.md` — ReAct, Reflection, Planning, Human-in-the-Loop, Evaluator-Optimizer; pattern selection ladder. Read when designing any agent loop.
- `references/context-management.md` — Token budget allocation, conversation-history strategies, lost-in-the-middle. Read when designing memory or context-heavy systems.
- `references/tool-design.md` — Tool naming, descriptions, parameter design, dispatcher pattern. Read when authoring tools for any agent.
- `references/structured-output.md` — Four generations of structured output, schema design rules, reasoning-before-decision ordering. Read when designing structured output.
- `references/mcp-engineering.md` — MCP architecture, transport, primitives, security model. Read when consuming or integrating MCP servers.
- `references/rag-engineering.md` — Chunking, hybrid retrieval, reranking, RAG eval split. Read when building RAG.
- `references/streaming-patterns.md` — TTFT framing, SSE, tool-use mid-stream, structured output streaming. Read when building user-facing AI features.
- `references/cost-optimization-and-routing.md` — Routing strategies (cascade), caching, cost tracking, budget ceilings. Read when running LLM features in production.
- `references/llm-security.md` — Prompt injection, OWASP LLM Top 10, defense layers, privilege separation. Read when reviewing or building LLM features.
- `references/evaluation-and-observability.md` — Offline + online eval, tracing, drift detection, eval suite anatomy. Read when shipping any LLM feature to production.
- `ai-engineer` subagent (in `~/.claude/agents/`) — Subagent for reviewing AI application architecture, prompt quality, and provider integration.
