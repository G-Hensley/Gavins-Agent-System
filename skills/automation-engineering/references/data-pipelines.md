# Data Pipeline Patterns

## ETL Structure
```
Extract (fetch from source)
  → Transform (clean, enrich, reshape)
    → Load (write to destination)
```
Keep each phase separate — don't mix fetching with transformation.

## Rate Limiting
```python
import asyncio
import time

class RateLimiter:
    def __init__(self, calls_per_second: int = 8):
        self.semaphore = asyncio.Semaphore(calls_per_second)
        self.min_interval = 1.0 / calls_per_second

    async def acquire(self):
        await self.semaphore.acquire()
        asyncio.get_event_loop().call_later(self.min_interval, self.semaphore.release)
```

## Pagination
```python
def fetch_all_pages(client, endpoint, params=None):
    results = []
    next_token = None
    while True:
        response = client.get(endpoint, params={**(params or {}), "nextToken": next_token})
        results.extend(response["items"])
        next_token = response.get("nextToken")
        if not next_token:
            break
    return results
```

## Batch Processing
```python
def process_in_batches(items, batch_size=100, processor=None):
    for i in range(0, len(items), batch_size):
        batch = items[i:i + batch_size]
        results = processor(batch)
        logger.info(f"Processed batch {i//batch_size + 1}: {len(batch)} items")
        yield results
```

## Checkpointing
For long-running pipelines, save progress to resume after failure:
```python
def process_with_checkpoint(items, checkpoint_file):
    processed = load_checkpoint(checkpoint_file)
    for item in items:
        if item["id"] in processed:
            continue
        process(item)
        save_checkpoint(checkpoint_file, item["id"])
```

## Retry with Backoff
```python
import time

def retry_with_backoff(fn, max_retries=3, base_delay=1):
    for attempt in range(max_retries):
        try:
            return fn()
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            delay = base_delay * (2 ** attempt)
            logger.warning(f"Attempt {attempt+1} failed: {e}. Retrying in {delay}s")
            time.sleep(delay)
```

## Output Formats
- **JSON**: `json.dumps(results, indent=2)` — for API consumption
- **CSV**: `csv.DictWriter` — for spreadsheets and analysis
- **Markdown**: formatted tables — for reports and documentation
- Support multiple output formats via `--output` flag
