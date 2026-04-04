---
name: APIsec Toolkit Shared Infrastructure
description: auth.py and shared/client.py contracts, env vars, and dependencies — key for any FastAPI backend that wraps these tools
type: project
---

## Auth Layer (auth.py)

`get_bearer_token(tenant: str, email: str, password: str) -> str`
- Step 1: GET https://api.apisecapps.com/v1/auth-config with Origin/Referer headers set to `https://{tenant}.apisecapps.com` — returns `{userPoolId, applicationClientId}`
- Step 2: pycognito SRP authenticate with those values, returns Cognito `id_token`
- Raises `AuthenticationError` (subclass of Exception) with human-readable message on all failure modes (bad password, user not found, new password required, etc.)
- `get_api_base_url()` returns the hardcoded `"https://api.apisecapps.com/v1"`

## Client Layer (shared/client.py)

`APIsecClient(tenant, token, rate_limit=8, verbose=False)`
- Sets Authorization Bearer header on a `requests.Session`
- `RateLimiter`: 8 req/s default, simple token-bucket via `time.sleep`
- Retry: 3 attempts, exponential backoff on 5xx; respects `Retry-After` on 429
- `get(endpoint, params)` / `post(endpoint, json_body, params)` / `put(...)` / `delete(...)`
- `get_paginated(endpoint, params, items_key)` — yields items across nextToken pages; auto-detects key from ['applications','scans','agents','detections','items']
- `get_applications(include_metadata=True)` — paginated list of all apps
- `APIError(message, status_code, response)` — raised on HTTP/network failure

## Tool-specific client pattern
Each tool subclasses APIsecClient and re-exports APIError:
```python
from shared.client import APIsecClient as _BaseClient, APIError  # noqa: F401
class APIsecClient(_BaseClient):
    def domain_method(self, ...): ...
```

## Environment Variables
- `APISEC_EMAIL` — user email for auth
- `APISEC_PASSWORD` — user password for auth
Loaded via python-dotenv from `.env` at repo root.

## Dependencies (requirements.txt)
- requests>=2.28.0
- python-dotenv>=1.0.0
- pycognito>=2024.1.0
- pyyaml>=6.0
- jinja2>=3.1.0

## Key notes for FastAPI backend
- `get_bearer_token` is synchronous and blocking (SRP crypto + 2 HTTP calls) — run in threadpool (`asyncio.to_thread`)
- Token is per-user-per-tenant; cache with TTL (Cognito ID tokens expire in 1hr by default)
- sys.path trick is not needed if FastAPI backend is at repo root — just `from auth import get_bearer_token`
- All API calls are synchronous (requests, not httpx) — same threadpool pattern applies

**Why:** User is planning a FastAPI backend that authenticates and runs these tools.
**How to apply:** Use these contracts directly when designing auth endpoints and API client wrappers.
