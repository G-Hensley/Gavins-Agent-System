---
name: backend-engineering
description: Backend development patterns for Python, Node.js, and Java — APIs, services, error handling, logging, and server-side architecture. Use when building API endpoints, services, server-side logic, or working with backend frameworks. Also use when the user says "build an API", "backend", "endpoint", "service layer", "server-side", or when writing Python/Node/Java server code.
---

# Backend Engineering

Build reliable, maintainable backend services. Read the relevant language reference for framework-specific patterns.

## Process

### 1. Identify the Stack
Determine which backend technology applies:
- **Python** — FastAPI, Flask, Django, AWS Lambda handlers → `references/python-patterns.md`
- **Node.js** — Express, Next.js API routes, serverless → `references/node-patterns.md`
- **Java** — Spring Boot, microservices → `references/java-patterns.md`

### 2. Design the API
Follow `references/api-design.md` for endpoint design, regardless of language:
- RESTful resource naming
- Request/response contracts
- Pagination, filtering, sorting
- Error response format
- Versioning strategy

### 3. Implement with Patterns
Read the language-specific reference. Apply:
- Layered architecture (controller → service → repository)
- Input validation at boundaries
- Structured error handling
- Logging with context (request ID, user, operation)
- Configuration management (env vars, not hardcoded)

### 4. Review
Dispatch the `backend-engineer` subagent for implementation or `backend-reviewer` is no longer needed — the `code-quality-reviewer` in the subagent pipeline handles review.

## What NOT to Do

- Do not mix business logic with request handling — separate into service layer
- Do not swallow errors silently — log with context and return meaningful responses
- Do not hardcode configuration — use environment variables or config files
- Do not skip input validation at API boundaries — validate type, length, format
- Do not return internal error details to clients — log internally, return generic messages
- Do not write monolithic handlers — keep functions focused, extract shared logic

## Reference Files

- `references/python-patterns.md` — Python backend patterns (FastAPI, Flask, AWS Lambda, dataclasses, async). Read when writing Python services.
- `references/node-patterns.md` — Node.js backend patterns (Express, Next.js API routes, TypeScript, async/await). Read when writing Node services.
- `references/java-patterns.md` — Java backend patterns (Spring Boot, dependency injection, services, repositories). Read when writing Java services.
- `references/api-design.md` — REST API design patterns (naming, contracts, pagination, errors, versioning). Read when designing any API regardless of language.
**Subagent:** `backend-engineer` — builds APIs, services, server-side logic. Located at `~/.claude/agents/backend-engineer.md`.
