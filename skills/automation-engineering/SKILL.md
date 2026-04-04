---
name: automation-engineering
description: Build CLI tools, automation scripts, data pipelines, and batch processing systems. Use when building command-line tools, writing automation scripts, creating cron jobs, building data pipelines, or processing data in bulk. Also use when the user says "script", "CLI tool", "automate", "batch process", "pipeline", "cron", "ETL", or "bulk operation".
---

# Automation Engineering

Build reliable, maintainable automation — CLI tools, scripts, data pipelines, and batch processors.

## Process

### 1. Identify the Pattern
- **CLI tool** — user-facing command with args, help, output → `references/cli-patterns.md`
- **Automation script** — scheduled or triggered, runs unattended → `references/scripting-patterns.md`
- **Data pipeline** — extract, transform, load (ETL) or data processing → `references/data-pipelines.md`

### 2. Design for Reliability
- Idempotent: safe to re-run without side effects
- Dry-run mode: validate without mutating
- Structured logging: what happened, when, to what
- Error handling: fail gracefully, report clearly, exit with correct codes
- Configuration: env vars or config files, not hardcoded values

### 3. Implement
Follow the language-specific patterns from `backend-engineering` for the implementation language. Apply TDD for logic-heavy components.

### 4. Review
Dispatch the automation-reviewer agent (`automation-engineer` subagent) to check reliability, error handling, and operational readiness.

## What NOT to Do

- Do not hardcode paths, credentials, or configuration — parameterize everything
- Do not write scripts without error handling — every external call can fail
- Do not skip dry-run mode for destructive operations
- Do not write monolithic scripts — separate concerns (fetch, transform, output)
- Do not skip logging — unattended scripts must report what they did
- Do not ignore exit codes — return 0 for success, non-zero for failure

## Reference Files

- `references/cli-patterns.md` — Argument parsing, help text, output formatting, exit codes, progress reporting.
- `references/scripting-patterns.md` — Bash and Python scripting patterns, error handling, idempotency, cron integration.
- `references/data-pipelines.md` — ETL patterns, batch processing, rate limiting, pagination, checkpointing, retry logic.
- `automation-engineer` subagent (in `~/.claude/agents/`) — Subagent for reviewing automation code for reliability and operational readiness.
