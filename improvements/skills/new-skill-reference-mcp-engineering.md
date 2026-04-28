# New skill reference: Model Context Protocol (MCP) engineering

## What I Observed

MCP is the de facto standard for connecting AI agents to external tools and data as of 2026. Donated to the Agentic AI Foundation (Linux Foundation) in December 2025, co-governed by Anthropic, OpenAI, Block, Google, Microsoft, AWS. There is no MCP coverage in the operator's AI engineering references at all.

The operator already builds and uses MCP-adjacent systems (this very Cowork session is an MCP host with multiple servers connected). The absence of a reference means agents and reviewers have no shared vocabulary for MCP architecture, primitives, or security model.

Missing topics:

- **What MCP is** — JSON-RPC 2.0 protocol, "USB-C for AI"
- **Architecture** — Host (the LLM app), Client (1:1 connection per server), Server (wraps one external system)
- **Transport** — stdio (locally-spawned) vs. Streamable HTTP (remote)
- **Three primitives** — Tools (functions the model invokes), Resources (URI-addressable data the model reads), Prompts (reusable templates the host can present)
- **MCP vs. function calling** — complementary, not competing. Function calling is the model API; MCP is the integration layer above it.
- **Security** — tool poisoning (malicious server exposing harmful tools), indirect prompt injection via tool outputs, over-permissioned tools, least-privilege server connection

## Why It Would Help

- The operator builds in this space; not having a reference means MCP shows up only in tribal knowledge
- The security model is different from REST tools — the indirect-prompt-injection-via-tool-outputs vector is specific to MCP and similar tool-calling architectures
- Tools-vs-Resources-vs-Prompts is an under-known distinction; many developers conflate them and ship "everything as a tool" which leads to bloated prompts and poor selection
- The operator already has the `mcp-builder` skill (anthropic-skills); this reference complements it on the consumer side (what to know when *using* MCP, not just *building* a server)

## Proposal

Create `skills/ai-engineering/references/mcp-engineering.md` with sections:

- What MCP is — protocol summary, governance, "USB-C for AI" framing
- Architecture — Host / Client / Server with a diagram or ASCII sketch
- Transport — stdio vs. Streamable HTTP, when to use each
- Three primitives — Tools, Resources, Prompts; concrete example of each; when to model something as a tool vs. a resource
- MCP vs. function calling — they pair; MCP discovers and connects, function calling invokes
- Security — tool poisoning, indirect injection via tool outputs (link to llm-security ref), over-permissioning, server trust model
- When to use MCP vs. building tools directly — MCP is right for cross-app and reusable; direct function calling is right for app-internal tools

Update `agents/ai-engineer.md` and `agents/backend-engineer.md` to load this when MCP-related code is detected (`@modelcontextprotocol/*`, `mcp` Python package, JSON-RPC over stdio).

## Open questions for review

- Should this ref reference or duplicate the `mcp-builder` skill? Reference, don't duplicate. `mcp-builder` is server-author-facing; this ref is host/integrator-facing.
- Is there value in a list of common MCP servers worth knowing about (filesystem, web search, GitHub, etc.)? Yes, brief catalog at the bottom — it grounds the abstract concepts.
- Streamable HTTP transport implications for production (CORS, auth, scaling) — depth here or punt to a future ref? Brief mention now, depth later if usage grows.
