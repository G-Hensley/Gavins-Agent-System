# API Security

## OWASP API Top 10 (Key Items)
1. **Broken Object-Level Authorization** — verify the user owns the resource, not just that they're authenticated
2. **Broken Authentication** — use proven auth libraries, enforce strong tokens, implement rate limiting on auth endpoints
3. **Excessive Data Exposure** — return only the fields the client needs, never dump full database objects
4. **Lack of Rate Limiting** — implement per-user and per-endpoint rate limits
5. **Broken Function-Level Authorization** — check permissions on every endpoint, not just at the UI layer
6. **Mass Assignment** — whitelist allowed fields, never bind raw request body to models
7. **Security Misconfiguration** — disable debug in production, remove default credentials, set security headers
8. **Injection** — parameterize all queries, validate all input

## Input Validation
- Validate type, length, format, and range on every input
- Reject invalid input — don't try to sanitize and use it
- Validate at the API boundary, not deep in business logic
- Use schema validation (Zod, Joi, Pydantic) for structured input

## Authentication
- Use short-lived JWTs or session tokens
- Implement token refresh with rotation
- Hash passwords with bcrypt/argon2 (never SHA/MD5)
- Rate limit login attempts (5 failures → temporary lockout)

## Authorization
- Check permissions on every request, not just UI visibility
- Use role-based or attribute-based access control
- Verify resource ownership: `WHERE id = :id AND owner_id = :userId`
- Log authorization failures for monitoring

## Response Security
- Set `X-Content-Type-Options: nosniff`
- Set `X-Frame-Options: DENY` or use CSP frame-ancestors
- Never expose stack traces, internal paths, or SQL errors in responses
- Use generic error messages: "Invalid credentials" not "User not found"

## Rate Limiting
- Per-user limits on sensitive endpoints (login, signup, password reset)
- Per-IP limits for unauthenticated endpoints
- Return `429 Too Many Requests` with `Retry-After` header
