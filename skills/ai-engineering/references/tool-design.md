# Tool Design

Tool quality is the single biggest determinant of agent performance after the model itself. The model selects tools by name and description — a poorly named or described tool is invisible or misused regardless of how well it is implemented. This reference covers authoring discipline; for MCP-server-specific concerns, see `./mcp-engineering.md`.

---

## Naming and Descriptions

**Name encodes intent.** The model pattern-matches on names before reading descriptions. Use verb-noun pairs that state the action and the target resource.

| Bad | Good | Why |
|---|---|---|
| `search` | `search_customer_orders` | Disambiguates from other search tools |
| `data` | `get_invoice_by_id` | States action, resource, and lookup key |
| `handle` | `cancel_subscription` | One name, one action, zero ambiguity |
| `do_orders` | `list_orders` / `cancel_order` | Separate tools, separate actions |

**Description must answer three questions:**
1. When should the model call this tool?
2. What does it return?
3. What does it NOT do (and what tool to use instead)?

```python
search_customer_orders = Tool(
    name="search_customer_orders",
    description=(
        "Search orders for a specific customer by customer_id. "
        "Returns a list of order summaries (id, status, total, date). "
        "Does NOT return line items — use get_order_detail for that. "
        "Do NOT use for order cancellation — use cancel_order instead."
    ),
    parameters=OrderSearchParams,
)
```

The "do NOT use for" callout is not optional for tools that share a semantic neighborhood. Without it, models conflate adjacent tools under token pressure.

---

## Parameter Design

**Use enums for constrained values, not free-text.** A free-text `status` parameter generates hallucinated values. An enum generates valid ones.

```python
class OrderStatus(str, Enum):
    pending = "pending"
    shipped = "shipped"
    cancelled = "cancelled"

class OrderSearchParams(BaseModel):
    customer_id: str                          # required
    status: OrderStatus | None = None         # optional; defaults to all statuses
    limit: int = 20                           # sensible default; document the cap
    offset: int = 0
```

**One tool per action.** A `do_orders(mode="search"|"cancel"|"refund")` tool forces the model to pick both the tool and the internal mode — doubling selection surface. Split into `search_orders`, `cancel_order`, `refund_order`.

**Required vs. optional with defaults:**
- Make required only what you cannot infer or default. Every required parameter is a failure point.
- Document defaults in the description, not just the schema.

**Return structured data, not prose.** The model must re-parse prose returns. Return a typed dict the model can address directly.

```python
# Bad — model must extract the id from prose
return "Order ORD-123 was successfully cancelled."

# Good — model addresses fields directly
return {"status": "success", "order_id": "ORD-123", "new_status": "cancelled"}
```

---

## Return Shapes

**Standard error envelope.** When a tool fails, return a structured error — do not raise an exception to the model. A structured error lets the model decide: retry, use an alternative tool, or inform the user.

```python
def cancel_order(order_id: str, reason: str) -> dict:
    try:
        result = orders_client.cancel(order_id, reason)
        return {"status": "success", "order_id": order_id, "cancelled_at": result.timestamp}
    except OrderNotFound:
        return {"status": "error", "code": "not_found", "message": f"Order {order_id} not found"}
    except OrderAlreadyCancelled:
        return {"status": "error", "code": "already_cancelled", "message": "Order is already cancelled"}
    except Exception as e:
        log.exception("cancel_order failed order_id=%s", order_id)
        return {"status": "error", "code": "internal", "message": "Cancellation failed; try again"}
```

Consistent `status` fields (`"success"` / `"error"`) across all tools let you write a single error-handling clause in the agent loop instead of tool-specific branching.

---

## Tool Count Limits

Each tool definition consumes 200–500 tokens before a single user message is processed. Tool count compounds: both context cost and selection difficulty grow linearly.

| Count | Guidance |
|---|---|
| 1–5 | Load all; no categorization needed |
| 6–10 | Comfortable range; evaluate whether all are needed per task |
| 11–20 | Review for tool sprawl; consider task-scoped subsets |
| 20+ | Requires categorization or a dispatcher agent |

**Dispatcher pattern** — route by category rather than exposing all tools to one agent:

```python
CATEGORIES = {
    "orders": [search_customer_orders, get_order_detail, cancel_order, refund_order],
    "billing": [get_invoice, list_invoices, apply_credit],
    "account": [get_account, update_account, reset_password],
}

def dispatcher(intent: str, context: dict) -> dict:
    category = classifier.call(
        f"Categorize this intent into one of {list(CATEGORIES)}: {intent}"
    )
    tools = CATEGORIES.get(category, [])
    if not tools:
        return {"status": "error", "message": f"No tools found for category: {category}"}
    agent = build_agent(tools=tools, context=context)
    return agent.run(intent)
```

The classifier call is cheap (Haiku-class model). The downstream agent runs with a small, coherent tool set and a clear semantic scope.

---

## Selection Accuracy Testing

Tool selection accuracy is the first thing to measure when an agent misbehaves. The eval pattern: present scenarios, assert the agent picks the right tool with the right parameters.

```python
TOOL_SELECTION_EVALS = [
    {
        "input": "Cancel order ORD-456 because the customer changed their mind",
        "expected_tool": "cancel_order",
        "expected_params": {"order_id": "ORD-456"},
    },
    {
        "input": "Show me all pending orders for customer C-789",
        "expected_tool": "search_customer_orders",
        "expected_params": {"customer_id": "C-789", "status": "pending"},
    },
]

for case in TOOL_SELECTION_EVALS:
    response = agent.call(case["input"])
    assert response.tool_name == case["expected_tool"], f"Wrong tool: {response.tool_name}"
    for key, val in case["expected_params"].items():
        assert response.tool_args.get(key) == val, f"Wrong param {key}: {response.tool_args.get(key)}"
```

Run these evals after any tool rename, description change, or new tool addition — selection accuracy degrades silently when the tool set grows or descriptions drift. For eval harness infrastructure, see `./evaluation-and-observability.md`.

---

## Anti-Patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| `do_everything(mode=...)` | Model must select tool AND internal mode — doubles failure surface | One tool per action |
| Prose returns | Model re-parses its own output; wastes tokens; introduces extraction errors | Return typed dicts |
| Exceptions instead of structured errors | Agent loop crashes or model receives no actionable signal | Return `{"status": "error", ...}` always |
| Missing "do NOT use for" on adjacent tools | Model conflates semantically similar tools | Add a disambiguation clause to every description that has a sibling |
| Free-text parameters for constrained values | Model hallucinates valid-looking but invalid values | Enumerate with `Enum` types |
| Growing past 10 tools without a dispatcher | Context cost climbs; selection accuracy drops silently | Apply the dispatcher pattern at 10+ |
| Tool names without verb-noun structure | Model cannot infer intent from the name alone | `verb_resource` format for every tool |
