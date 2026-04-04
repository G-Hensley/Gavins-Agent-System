---
name: APIsec Toolkit — Programmatic Tool Interface
description: Minimal interface to invoke any tool programmatically — inputs, outputs, and the collector function contract
type: project
---

Every tool follows the same 3-argument collector function signature:

```python
results = collector_fn(
    client=APIsecClient(tenant=str, token=str, verbose=bool),
    config=<ToolConfig dataclass>,
    verbose=bool,
    dry_run=bool,
    # some tools add: skip_confirm=bool
)
```

**Inputs to run a tool programmatically:**
1. `tenant` (str) — lowercase tenant name
2. Credentials from `.env`: `APISEC_EMAIL`, `APISEC_PASSWORD`
3. A `ScheduleConfig` / `DiscoveryConfig` / etc. dataclass — can be built directly, no YAML required
4. `verbose` and `dry_run` booleans
5. Optionally `skip_confirm=True` to bypass the `input()` confirmation gate

**Token acquisition:**
```python
token = get_bearer_token(tenant, email, password)  # from auth.py at repo root
```

**Client construction:**
```python
client = APIsecClient(tenant=tenant, token=token, verbose=verbose)
# Tool-specific subclass: from client import APIsecClient
```

**Collector return types:**
- `schedule_scans()` → `list[ScheduleResult]` (fields: app_name, app_id, instance_id, instance_url, already_scheduled, created, error)
- `discover_instances()` → `dict[str, dict]` keyed by app name (fields: applicationId, instanceId, instanceUrl)
- `apply_auth_profiles()` → dataclass with `.created`, `.failed`, `.auth_ids`
- `export_scan_profiles()` → list of profile dicts

**Output side effects are in main(), not collectors:**
- JSON file write: done in entry point after collector returns
- CSV/JSON write: done in entry point using `generate_csv()` / `generate_json()` helpers
- Collectors only print progress to stdout; they do NOT write files

**Confirmation gate:** `schedule_scans()` calls `input()` unless `skip_confirm=True` or `dry_run=True`. Pass `skip_confirm=True` for programmatic use.

**Why:** Understanding this separates "what the CLI does" from "what can be called programmatically" — the collector functions are the stable interface.
**How to apply:** When building an agent or automation layer on top of these tools, import the tool's `client.py`, `config.py`, and `collector.py` directly. Instantiate the config dataclass directly rather than loading YAML.
