# Documentation Templates

## CLAUDE.md
Project instructions for Claude Code sessions. Keep actionable and current.
```markdown
# Project Name

## Quick Start
[Commands to get running: install, build, test]

## Architecture
[Key directories, main entry points, how things connect]

## Conventions
[Naming, patterns, imports, error handling — what Claude should follow]

## Common Tasks
[How to add a feature, run tests, deploy]

## What NOT to Do
[Anti-patterns, files to avoid editing, known gotchas]
```

## README
```markdown
# Project Name
[One-line description]

## Setup
[Prerequisites, install, configure]

## Usage
[How to use it — commands, API, UI]

## Development
[How to contribute — build, test, lint]

## Deployment
[How to deploy — environments, commands, CI/CD]
```

## Architecture Decision Record (ADR)
```markdown
# ADR-NNN: [Title]
**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Deprecated | Superseded

## Context
[What situation led to this decision?]

## Decision
[What was decided and why?]

## Consequences
[What are the trade-offs? What becomes easier/harder?]
```

## Runbook
```markdown
# [Procedure Name]

## When to Use
[What triggers this procedure]

## Prerequisites
[Access, tools, permissions needed]

## Steps
1. [Exact step with command]
2. [Exact step with expected output]
3. [Exact step with verification]

## Rollback
[How to undo if something goes wrong]

## Contacts
[Who to escalate to]
```

## API Documentation
```markdown
## [Endpoint Name]
**Method:** GET | POST | PUT | DELETE
**Path:** /api/v1/resource

### Request
[Parameters, headers, body with types]

### Response
[Status codes, body shape, error format]

### Example
[Curl or code example with actual values]
```

## Changelog
```markdown
# Changelog

## [Version] - YYYY-MM-DD
### Added
- [New feature]
### Changed
- [Modified behavior]
### Fixed
- [Bug fix]
### Removed
- [Removed feature]
```
