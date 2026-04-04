# REST API Conventions

## URL Structure
- Use nouns: `/users`, `/projects`, `/scans` (not `/getUsers`)
- Plural: `/users` not `/user`
- Nested for relationships: `/users/{id}/projects`
- Kebab-case: `/health-checks`, `/scan-results`
- Max 2 levels of nesting — deeper means a new top-level resource

## HTTP Methods
| Method | Purpose | Idempotent | Success Code |
|--------|---------|------------|-------------|
| GET | Read resource(s) | Yes | 200 |
| POST | Create resource | No | 201 + Location |
| PUT | Full replace | Yes | 200 |
| PATCH | Partial update | No | 200 |
| DELETE | Remove | Yes | 204 |

## Standard Error Format
Every error response uses the same shape:
```json
{
  "error": {
    "code": "validation_error",
    "message": "Invalid request parameters",
    "details": [
      { "field": "email", "message": "Must be a valid email address" }
    ]
  }
}
```

## Status Codes
| Code | When to Use |
|------|------------|
| 200 | Successful read/update |
| 201 | Resource created |
| 204 | Successful delete (no body) |
| 400 | Validation error (client's fault) |
| 401 | Not authenticated |
| 403 | Authenticated but not authorized |
| 404 | Resource not found |
| 409 | Conflict (duplicate, state conflict) |
| 429 | Rate limited |
| 500 | Internal error (server's fault) |

## Pagination
```
GET /api/v1/users?page=1&limit=20
GET /api/v1/users?cursor=abc123&limit=20  (cursor-based)

Response includes:
{
  "data": [...],
  "pagination": { "page": 1, "limit": 20, "total": 150, "hasMore": true }
}
```

## Filtering and Sorting
```
GET /api/v1/scans?status=completed&customer=acme&sort=-createdAt
```
- Filter by field names as query params
- Sort with `-` prefix for descending
- Document all supported filters per endpoint

## Rate Limiting Headers
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1620000000
Retry-After: 30  (on 429 responses)
```
