# Python Backend Patterns

## Project Structure
```
src/
├── handlers/       # Request handlers (FastAPI routes, Lambda handlers)
├── services/       # Business logic (no framework dependencies)
├── repositories/   # Data access (DB queries, API clients)
├── models/         # Dataclasses, Pydantic models
├── utils/          # Shared utilities
└── config.py       # Configuration from env vars
```

## Layered Architecture
- **Handlers**: parse request, validate input, call service, format response
- **Services**: business logic, orchestration, no HTTP/framework awareness
- **Repositories**: data access, API clients, caching — services don't know storage details

## Dataclasses for Configuration and Results
```python
@dataclass
class ScanConfig:
    customer_id: str
    environment: str
    dry_run: bool = False
```
Use dataclasses over raw dicts for structured data. Type-safe, IDE-friendly, self-documenting.

## Error Handling
```python
class AppError(Exception):
    def __init__(self, message: str, code: str, status: int = 500):
        self.message = message
        self.code = code
        self.status = status

# In handler
try:
    result = service.process(request)
except AppError as e:
    return {"error": e.code, "message": e.message}, e.status
except Exception:
    logger.exception("Unexpected error")
    return {"error": "internal", "message": "Internal error"}, 500
```

## Async Patterns
```python
# Rate-limited API client
async def fetch_with_rate_limit(urls: list[str], rate: int = 8):
    semaphore = asyncio.Semaphore(rate)
    async with semaphore:
        return await asyncio.gather(*[fetch(url) for url in urls])
```

## AWS Lambda Handlers
```python
def handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))
        validated = InputModel(**body)  # Pydantic validation
        result = service.process(validated)
        return {"statusCode": 200, "body": json.dumps(result)}
    except ValidationError as e:
        return {"statusCode": 400, "body": json.dumps({"errors": e.errors()})}
```

## CLI Tools
```python
import argparse

def main():
    parser = argparse.ArgumentParser(description="Tool description")
    parser.add_argument("--customer", required=True)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    # Call service layer, not inline logic
```

## Logging
```python
import logging
logger = logging.getLogger(__name__)

# Structured context
logger.info("Processing scan", extra={"customer": customer_id, "env": env})
```
