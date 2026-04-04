# CLI Tool Patterns

## Argument Parsing (Python)
```python
import argparse

def main():
    parser = argparse.ArgumentParser(description="Scan customer environments")
    parser.add_argument("--customer", required=True, help="Customer ID")
    parser.add_argument("--environment", default="production", choices=["production", "staging"])
    parser.add_argument("--dry-run", action="store_true", help="Validate without executing")
    parser.add_argument("--verbose", "-v", action="store_true")
    parser.add_argument("--output", choices=["json", "csv", "table"], default="table")
    args = parser.parse_args()
```

## Output Formatting
- **Table** (default for humans): aligned columns, headers
- **JSON** (for piping/automation): structured, parseable
- **CSV** (for spreadsheets): standard format with headers

```python
if args.output == "json":
    print(json.dumps(results, indent=2))
elif args.output == "csv":
    writer = csv.DictWriter(sys.stdout, fieldnames=results[0].keys())
    writer.writeheader()
    writer.writerows(results)
else:
    # Table format with aligned columns
    for row in results:
        print(f"{row['name']:<30} {row['status']:<15} {row['count']:>5}")
```

## Exit Codes
- `0` — success
- `1` — general error
- `2` — usage/argument error
- Use `sys.exit(code)` — don't just print errors and exit 0

## Progress Reporting
For long-running operations:
```python
for i, item in enumerate(items, 1):
    if i % 100 == 0:
        print(f"Processing {i}/{len(items)}...", file=sys.stderr)
    process(item)
```
Print progress to stderr (not stdout) so output can be piped.

## Dry-Run Pattern
```python
if args.dry_run:
    print(f"[DRY RUN] Would delete {len(items)} items")
    for item in items:
        print(f"  - {item['name']}")
    return
# Actual execution
for item in items:
    delete(item)
```
