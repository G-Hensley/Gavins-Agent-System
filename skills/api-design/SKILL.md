---
name: api-design
description: Design and document APIs — REST, GraphQL, OpenAPI specs, versioning, rate limiting, pagination, and error contracts. Use when designing new APIs, documenting existing ones, writing OpenAPI specs, or planning API versioning strategy. Also use when the user says "API design", "OpenAPI", "Swagger", "REST design", "API versioning", "rate limiting", or "API contract".
---

# API Design

Design APIs that are consistent, well-documented, and easy to consume. This skill covers the design — for implementation, hand off to the `backend-engineering` skill.

## Process

### 1. Define the Resource Model
Identify the resources (nouns) the API exposes:
- What entities does the consumer need to interact with?
- What are the relationships between them?
- What operations are needed per resource (CRUD, search, bulk)?

### 2. Design Endpoints
Follow REST conventions (see `references/rest-conventions.md`):
- Resource-based URLs with consistent naming
- Proper HTTP methods per operation
- Consistent request/response shapes
- Pagination, filtering, and sorting for collections

### 3. Define Contracts
For every endpoint, specify (see `references/openapi-patterns.md`):
- Input: parameters, headers, body with exact types
- Output: response shape with exact types per status code
- Errors: all possible error states with codes and messages
- Write an OpenAPI spec if the project uses one

### 4. Plan Cross-Cutting Concerns
- **Versioning**: URL path (`/v1/`) or header-based? Migration strategy?
- **Rate limiting**: per-user, per-endpoint, response headers
- **Authentication**: how consumers authenticate (API key, OAuth, JWT)
- **Pagination**: offset vs cursor, default/max page size

### 5. Review
Dispatch the `architect` or `architecture-reviewer` subagent to validate the API design for consistency, completeness, and DRY.

## What NOT to Do

- Do not use verbs in URLs (`/getUsers`) — use nouns (`/users`)
- Do not return different error formats from different endpoints — standardize
- Do not skip pagination on collection endpoints — unbounded responses break clients
- Do not expose internal IDs or implementation details in the API surface
- Do not design without listing the consumer's use cases first

## Reference Files

- `references/rest-conventions.md` — URL naming, HTTP methods, status codes, error format, pagination, filtering.
- `references/openapi-patterns.md` — OpenAPI/Swagger spec patterns, schema reuse, versioning, documentation generation.
