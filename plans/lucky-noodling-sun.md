# Plan: Build Toph Health Check Pipeline

## Context

Toph automates APIsec's weekly customer health check process (currently 30+ min manual work per customer). An existing working prototype lives at `/Users/gavinhensley/Desktop/Projects/APIsec/automated-health-checks`. This project (`islamabad`) has thorough architecture docs but no code. We're porting the existing code into the better structure defined by `SYSTEM_DOC.md` and `CLAUDE.md`, with these key upgrades:

- **SheepDog (DynamoDB) as primary data source** (APIsec API for gap-fill only)
- **Graph + Workflows dual orchestration** (original only uses Graph)
- **Full Slack approval flow** with reject → feedback → regeneration loop
- **Correct model assignments**: Haiku 3 / Sonnet 3.7 / Haiku 3
- **Lambda + CLI dual entry points**
- **Async state persistence** for Lambda approval flow (save state to S3, resume from callback)

---

## File Mapping (Source → Target)

| Source | Target | Action |
|--------|--------|--------|
| `src/config.py` | `src/config/settings.py` | Rewrite as module |
| `src/models.py` | `src/models/{context,health_check,tasks,pipeline}.py` | Split + extend |
| `src/orchestrator.py` | `src/workflows/graph.py` | Rewrite with conditional edges |
| `src/nodes.py` | `src/workflows/nodes.py` | Rewrite, add approval gate |
| `src/agents/*.py` | `src/agents/*.py` | Port, add feedback injection |
| `src/apisec/*` | `src/tools/apisec/*` | Port as-is (5 files) |
| `src/tools/*.py` | `src/tools/*_tool.py` | Port, update imports |
| `src/integrations/notion.py` | `src/tools/notion/client.py` | Port |
| `src/integrations/slack.py` | `src/approval/slack_client.py` | Port + extend |
| `src/integrations/asana.py` | `src/tools/asana/client.py` | Port stub |
| `src/integrations/hubspot.py` | `src/tools/hubspot/client.py` | Port stub |
| `prompts/*.md` | `prompts/*.md` | Port as-is |
| `scripts/test_agent*.py` | `scripts/test_agent*.py` | Port, update imports |
| — | `src/tools/sheepdog/` | **New** - DynamoDB interface |
| — | `src/approval/handler.py` | **New** - approval gate logic |
| — | `src/workflows/state.py` | **New** - typed state manager |
| — | `src/workflows/tasks.py` | **New** - task specifications |
| — | `src/handlers/` | **New** - Lambda + CLI entry points |

---

## Implementation Chunks

### Chunk 1: Foundation (Config + Models + Prompts)

**Files to create:**

1. `pyproject.toml` — deps: `strands-agents>=1.26.0`, `strands-agents-tools>=0.2.20`, `pydantic>=2.12`, `slack_sdk>=3.40`, `slack_bolt>=1.27`, `boto3`, `pycognito`, `requests`, `python-dotenv`, `pytest`
2. `.env.example` — all env vars
3. `.gitignore`
4. `src/__init__.py`
5. `src/config/__init__.py` — re-exports
6. `src/config/settings.py` — port from source `config.py`, add SheepDog/Slack vars, hardcode model IDs per SYSTEM_DOC
7. `src/config/customers.py` — customer name → tenant mapping
8. `src/models/__init__.py` — re-exports all models
9. `src/models/context.py` — port `CustomerSegment`, `AdoptionPhase`, `ApplicationInfo`, `CustomerContext`
10. `src/models/health_check.py` — port `SectionStatus`, `HealthCheckSection`, `HealthCheckReport`
11. `src/models/tasks.py` — port `AsanaTask`, `TaskList`
12. `src/models/pipeline.py` — port `PipelineResult`, **new**: `ApprovalDecision` enum, `ReviewFeedback`, `FeedbackRecord`, `PipelineState`
13. `prompts/context_builder.md` — port as-is
14. `prompts/health_check_generator.md` — port as-is
15. `prompts/ticket_generator.md` — port as-is

**Verify:** `python -c "from src.models import CustomerContext, HealthCheckReport, TaskList, PipelineResult"`

### Chunk 2: Data Layer (Tools + Clients)

**Port APIsec client (5 files, as-is with import fixes):**

16. `src/tools/__init__.py`
17. `src/tools/apisec/__init__.py`
18. `src/tools/apisec/auth.py` — port from `src/apisec/auth.py`
19. `src/tools/apisec/base_client.py` — port from `src/apisec/base_client.py`
20. `src/tools/apisec/client.py` — port, fix imports
21. `src/tools/apisec/collector.py` — port, fix imports
22. `src/tools/apisec/summarizer.py` — port as-is

**Port integration clients:**

23. `src/tools/notion/__init__.py`
24. `src/tools/notion/client.py` — port from `src/integrations/notion.py`
25. `src/tools/hubspot/__init__.py`
26. `src/tools/hubspot/client.py` — port stub from `src/integrations/hubspot.py`
27. `src/tools/asana/__init__.py`
28. `src/tools/asana/client.py` — port stub from `src/integrations/asana.py`

**Create SheepDog interface (new):**

29. `src/tools/sheepdog/__init__.py`
30. `src/tools/sheepdog/client.py` — `SheepDogClient` class with methods: `get_scan_data()`, `get_auth_configs()`, `get_app_metadata()`. All raise `NotImplementedError` with docstrings defining expected return shapes. Wired later when schemas are provided.

**Create Strands tool wrappers:**

31. `src/tools/apisec_tool.py` — port, update imports
32. `src/tools/notion_tool.py` — port, update imports
33. `src/tools/hubspot_tool.py` — port stub
34. `src/tools/asana_tool.py` — new stub
35. `src/tools/sheepdog_tool.py` — new, calls `SheepDogClient`, returns stub JSON for now

**Verify:** `python -c "from src.tools.apisec_tool import fetch_apisec_tenant_data"`

### Chunk 3: Agents

36. `src/agents/__init__.py`
37. `src/agents/context_builder.py` — port, update imports, add `fetch_sheepdog_data` tool, use Haiku 3 model ID
38. `src/agents/health_check_generator.py` — port, add `feedback: str | None = None` param to `generate_health_check()`. If feedback provided, append to prompt. Use Sonnet 3.7 model ID
39. `src/agents/ticket_generator.py` — port, add `feedback: str | None = None` param. Use Haiku 3 model ID

**Verify:** Port `scripts/test_agent{1,2,3}.py` with updated imports. Run each independently.

### Chunk 4: Approval Flow (New)

40. `src/approval/__init__.py`
41. `src/approval/slack_client.py` — port Block Kit formatting from source `integrations/slack.py`. Add `SlackApprovalClient` class using `slack_sdk` for interactive buttons. Methods: `post_review_message()`, `parse_action_payload()`, `update_message_with_result()`
42. `src/approval/handler.py` — `ApprovalHandler` class: `submit_for_review()`, `handle_approval()`, `handle_feedback()`, `execute_approval_actions()`, `save_feedback_record()`. Handles both Lambda (async, state to S3) and CLI (sync, stdin) modes.

**Verify:** Unit test with mocked Slack SDK.

### Chunk 5: Orchestration (Graph + Workflows)

43. `src/workflows/__init__.py`
44. `src/workflows/state.py` — `PipelineStateManager`: typed accessors for invocation_state dict, iteration tracking, MAX_ITERATIONS=3, serialization to/from S3 for Lambda async flow
45. `src/workflows/tasks.py` — formal task specs as dataclasses: `DataCollectionTask`, `ContextEnrichmentTask`, `HealthCheckTask`, `TicketGenerationTask`, `ReviewTask`. Factory: `build_task_specs(customer_name)`
46. `src/workflows/nodes.py` — rewrite from source `nodes.py`:
    - `DataCollectionNode` — Phase 2: pure code, calls APIsec collector + Notion + SheepDog
    - `ContextBuilderNode` — Phase 3: runs Agent 1
    - `HealthCheckNode` — Phase 4: runs Agent 2, reads feedback from state
    - `TicketGeneratorNode` — Phase 5: runs Agent 3, reads feedback from state
    - `ApprovalGateNode` — Phase 6: posts to Slack (Lambda) or prompts stdin (CLI), sets approval decision in state
47. `src/workflows/graph.py` — rewrite from source `orchestrator.py`:
    - `build_health_check_graph(mode)`: 5 nodes + conditional edge from approval_gate back to health_check on rejection
    - Condition function reads `invocation_state["approval_decision"]` and `iteration_count`
    - `run_pipeline_for_customer(customer_name, mode)` → `PipelineResult`
    - `run_pipeline_for_customers(names)` → `list[PipelineResult]`

**Key architectural note:** The Strands `workflow` tool is designed to be called BY an agent. Our orchestration is deterministic — the Workflows "pattern" is implemented as custom code (state.py, tasks.py) layering on top of Graph, not using the Strands workflow tool directly.

**Verify:** Build graph, run with mock auto-approve. Run with mock rejection to test feedback loop (max 3 iterations).

### Chunk 6: Entry Points

48. `src/handlers/__init__.py`
49. `src/handlers/lambda_handler.py` — `handler(event, context)` for EventBridge trigger, `approval_callback_handler(event, context)` for Slack callback via API Gateway
50. `src/handlers/cli.py` — argparse CLI: `--customer`, `--tenant`, `--all`, `--skip-approval`, `--from-context`, `--from-report`
51. `src/utils/__init__.py`
52. `src/utils/logging.py` — consistent log formatting
53. `src/utils/serialization.py` — save/load pipeline artifacts to files

**Verify:** `python -m src.handlers.cli --customer ceteam --skip-approval`

### Chunk 7: Scripts + Tests

54. `scripts/test_agent1.py` — port, update imports
55. `scripts/test_agent2.py` — port, update imports
56. `scripts/test_agent3.py` — port, update imports
57. `scripts/run_pipeline.py` — convenience wrapper for CLI
58. `tests/__init__.py`
59. `tests/conftest.py` — shared fixtures (sample CustomerContext, HealthCheckReport, TaskList)
60. `tests/test_models.py` — model serialization/deserialization
61. `tests/test_agents.py` — mock Bedrock, verify structured output
62. `tests/test_nodes.py` — node invocation with mocked agents
63. `tests/test_graph.py` — graph construction, conditional edges, feedback loop limits
64. `tests/test_approval.py` — Slack formatting, approval handler with mocked SDK
65. `tests/test_notion.py` — port from source
66. `tests/test_slack.py` — port + extend from source

### Chunk 8: Infrastructure

67. `infra/template.yaml` — CloudFormation: Lambda (pipeline + callback), EventBridge, API Gateway for Slack callbacks, IAM roles, Secrets Manager refs

---

## Target Directory Structure

```
islamabad/
├── docs/SYSTEM_DOC.md                 # exists
├── reference/APIsec_Customer_Team_SOP.xml  # exists
├── CLAUDE.md                          # exists
├── README.md                          # exists
├── pyproject.toml
├── .env.example
├── .gitignore
├── prompts/
│   ├── context_builder.md
│   ├── health_check_generator.md
│   └── ticket_generator.md
├── src/
│   ├── __init__.py
│   ├── config/
│   │   ├── __init__.py
│   │   ├── settings.py
│   │   └── customers.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── context.py
│   │   ├── health_check.py
│   │   ├── tasks.py
│   │   └── pipeline.py
│   ├── agents/
│   │   ├── __init__.py
│   │   ├── context_builder.py
│   │   ├── health_check_generator.py
│   │   └── ticket_generator.py
│   ├── tools/
│   │   ├── __init__.py
│   │   ├── apisec_tool.py
│   │   ├── notion_tool.py
│   │   ├── hubspot_tool.py
│   │   ├── asana_tool.py
│   │   ├── sheepdog_tool.py
│   │   ├── apisec/
│   │   │   ├── __init__.py
│   │   │   ├── auth.py
│   │   │   ├── base_client.py
│   │   │   ├── client.py
│   │   │   ├── collector.py
│   │   │   └── summarizer.py
│   │   ├── notion/
│   │   │   ├── __init__.py
│   │   │   └── client.py
│   │   ├── hubspot/
│   │   │   ├── __init__.py
│   │   │   └── client.py
│   │   ├── asana/
│   │   │   ├── __init__.py
│   │   │   └── client.py
│   │   └── sheepdog/
│   │       ├── __init__.py
│   │       └── client.py
│   ├── approval/
│   │   ├── __init__.py
│   │   ├── slack_client.py
│   │   └── handler.py
│   ├── workflows/
│   │   ├── __init__.py
│   │   ├── state.py
│   │   ├── tasks.py
│   │   ├── nodes.py
│   │   └── graph.py
│   ├── handlers/
│   │   ├── __init__.py
│   │   ├── lambda_handler.py
│   │   └── cli.py
│   └── utils/
│       ├── __init__.py
│       ├── logging.py
│       └── serialization.py
├── scripts/
│   ├── test_agent1.py
│   ├── test_agent2.py
│   ├── test_agent3.py
│   └── run_pipeline.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   ├── test_models.py
│   ├── test_agents.py
│   ├── test_nodes.py
│   ├── test_graph.py
│   ├── test_approval.py
│   ├── test_slack.py
│   └── test_notion.py
└── infra/
    └── template.yaml
```

---

## Verification Plan

After each chunk:
1. Run imports to verify module structure
2. Run `pytest` on any new tests
3. After Chunk 3: run individual agent test scripts against fixture data
4. After Chunk 5: run full pipeline with `--skip-approval` flag
5. After Chunk 6: run CLI end-to-end with real APIsec credentials
6. After Chunk 7: `pytest tests/ -v` — all pass

End-to-end: `python -m src.handlers.cli --customer <test-customer> --skip-approval` should produce a `PipelineResult` with valid health check and task list.

---

## Known Deferred Items

- **SheepDog DynamoDB queries** — interface built, wired when schemas are provided
- **Asana task creation** — stub, not wired to real API for V1
- **HubSpot updates** — stub
- **Notion page updates** — stub (read-only for V1)
- **V2 confidence routing** — not in scope
