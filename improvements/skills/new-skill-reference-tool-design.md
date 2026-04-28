# New skill reference: tool design for LLM agents

## What I Observed

`skills/ai-engineering/references/sdk-patterns.md` likely shows tool-definition syntax (decorator, schema) but does not cover tool *design* — how to name, describe, parameterize, and structure tools so the model selects them correctly and uses them well. Tool quality is the single biggest determinant of agent performance after the model itself, and the operator's existing references skip it.

Missing topics:

**Naming and descriptions**

- The model selects tools by name and description. Poor names → wrong selection.
- Concrete examples and "do NOT use for X — use Y instead" callouts in descriptions
- Description should answer: when to use this, what it returns, what it does *not* do

**Parameter design**

- Typed parameters with constraints (enums for constrained values, not free-text)
- Required vs. optional with sensible defaults
- One tool per action (`search_orders`, `cancel_order` — not `do_orders(mode=...)`)
- Return structured data, not prose

**Error handling**

- Tools must return structured errors, not raise exceptions to the model
- `{"status": "error", "message": "..."}` lets the model decide what to do (retry, alternative, inform user)

**Tool count and complexity**

- 5–10 tools is a comfortable agent
- 20+ tools needs categorization or a dispatcher pattern
- Each tool consumes context window space (200–500 tokens per definition)
- Test tool selection accuracy explicitly — present scenarios, verify the agent picks the right tool with right params

## Why It Would Help

- "The model isn't using the tool I gave it" is almost always a tool-design bug, not a model bug — and the operator has no reference to point at when debugging this
- Multi-tool agents in the operator's stack (and any new ones built by `subagent-driven-development`) consistently grow past the comfortable 5–10 range without anyone catching it
- Returning prose from tools is a frequent mistake — the model then has to re-parse its own tool output, which wastes tokens and introduces errors
- The dispatcher pattern (categorized tool routing) is the right answer to tool sprawl and is non-obvious

## Proposal

Create `skills/ai-engineering/references/tool-design.md` with sections:

- Naming and descriptions — bad/good examples (the research doc's `search` vs. `search_customer_orders` example as a template)
- Parameter design — typed, enumerated, defaults, single-action discipline
- Return shapes — structured data, not prose; standard error envelope
- Tool count limits — comfortable range, dispatcher pattern when exceeded
- Selection accuracy testing — eval pattern for "given this input, did the agent pick the right tool with the right params"
- Anti-pattern list — `do_everything(mode=...)`, prose returns, exceptions instead of structured errors, undocumented "do NOT use for"

Update `agents/ai-engineer.md`, `agents/backend-engineer.md`, and `agents/automation-engineer.md` (CLI tool authors hit the same design issues) to load this.

## Open questions for review

- Should this be a standalone ref or expand `sdk-patterns.md`? Standalone — sdk-patterns is provider-integration-shaped; tool design is an authoring discipline of its own.
- Is there a worked dispatcher-pattern example worth including? Yes, ~30 lines, showing route-by-category.
- The operator's `mcp-builder` skill overlaps slightly. Cross-link, don't duplicate — `mcp-builder` is MCP-server-author-facing; this ref is general (works for native function calling and MCP both).
