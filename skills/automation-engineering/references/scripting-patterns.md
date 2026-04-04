# Scripting Patterns

## Bash Script Template
```bash
#!/usr/bin/env bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/logs/$(date +%Y%m%d_%H%M%S).log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
error() { log "ERROR: $*" >&2; exit 1; }

# Validate requirements
command -v jq >/dev/null 2>&1 || error "jq is required"
[[ -n "${API_KEY:-}" ]] || error "API_KEY environment variable required"

log "Starting process..."
# ... your logic
log "Complete."
```

## Python Script Template
```python
#!/usr/bin/env python3
import sys
import logging
from pathlib import Path

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
logger = logging.getLogger(__name__)

def main():
    try:
        # ... your logic
        logger.info("Process complete")
    except KeyboardInterrupt:
        logger.info("Interrupted by user")
        sys.exit(130)
    except Exception:
        logger.exception("Unexpected error")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

## Idempotency
Design scripts to be safe to re-run:
- Check if work is already done before doing it
- Use upsert instead of insert
- Use `mkdir -p` (not `mkdir`)
- Use `CREATE TABLE IF NOT EXISTS`

## Cron Integration
```bash
# crontab -e
# Run every day at 2 AM
0 2 * * * /path/to/script.sh >> /path/to/cron.log 2>&1
```
- Redirect output to log file
- Use absolute paths (cron has minimal PATH)
- Use lock files to prevent overlapping runs
- Send notifications on failure (email, Slack webhook)

## Error Handling in Bash
```bash
# Trap errors for cleanup
cleanup() { rm -f "$TEMP_FILE"; }
trap cleanup EXIT

# Check command success
if ! result=$(curl -sf "$URL"); then
    error "Failed to fetch $URL"
fi
```
