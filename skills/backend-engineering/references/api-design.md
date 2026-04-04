# REST API Design

## Resource Naming
- Use nouns, not verbs: `/users` not `/getUsers`
- Plural: `/users`, `/projects`, `/scans`
- Nested for relationships: `/users/{id}/projects`
- Kebab-case for multi-word: `/health-checks`, `/scan-results`

## HTTP Methods
| Method | Purpose | Idempotent | Response |
|--------|---------|------------|----------|
| GET | Read | Yes | 200 + body |
| POST | Create | No | 201 + body + Location header |
| PUT | Full replace | Yes | 200 + body |
| PATCH | Partial update | No | 200 + body |
| DELETE | Remove | Yes | 204 No Content |

## Request/Response Contracts
Define explicitly for every endpoint:
```
POST /api/v1/users
Request:  { name: string, email: string }
Response: { id: string, name: string, email: string, createdAt: string }
Errors:   400 (validation), 409 (duplicate email), 500 (internal)
```

## Pagination
```
GET /api/v1/users?page=1&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```
Use cursor-based pagination for large datasets: `?cursor=abc123&limit=20`

## Filtering and Sorting
```
GET /api/v1/scans?status=completed&sort=-createdAt&customer=acme
```
- Filter by query params matching field names
- Sort with `-` prefix for descending

## Error Response Format
Consistent across all endpoints:
```json
{
  "error": "validation_error",
  "message": "Invalid request",
  "details": [
    { "field": "email", "message": "Invalid email format" }
  ]
}
```

## Versioning
- URL path versioning: `/api/v1/users` (simplest, most explicit)
- Increment major version only for breaking changes
- Support previous version for a deprecation period

## Rate Limiting
- Return `429 Too Many Requests` with `Retry-After` header
- Include rate limit headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`
