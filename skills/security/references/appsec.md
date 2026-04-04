# Application Security

## Authentication Flows
- Use proven libraries (NextAuth, Passport, AWS Cognito SDK) — don't roll your own
- Implement proper token lifecycle: issue → validate → refresh → revoke
- Hash passwords with bcrypt (cost factor ≥12) or argon2
- Never compare passwords with `===` — use constant-time comparison to prevent timing attacks

## Session Management
- Generate cryptographically random session IDs
- Invalidate sessions on logout, password change, and privilege escalation
- Set appropriate session timeouts (idle + absolute)
- Store session state server-side — client only gets the session ID

## Secrets Handling
- Never log secrets, tokens, or passwords — even in debug mode
- Never include secrets in error messages or API responses
- Use environment variables or secret managers, not config files in version control
- Rotate secrets when team members leave or credentials may be compromised

## Error Handling and Disclosure
- Return generic error messages to clients: "Request failed" not "PostgreSQL error: relation users does not exist"
- Log detailed errors server-side for debugging
- Never expose stack traces, file paths, or internal service names in responses
- Use error codes that don't reveal system internals

## Logging Sensitive Data
- Never log: passwords, tokens, credit card numbers, SSNs, full API keys
- Mask PII in logs: `user_***@***.com`, `card_****1234`
- Log security events: failed logins, permission denials, unusual patterns
- Ensure log storage is access-controlled and encrypted

## Common Anti-Patterns
| Anti-Pattern | Fix |
|---|---|
| Rolling own auth | Use proven auth library |
| Logging full request bodies | Redact sensitive fields |
| Secrets in code/config | Use env vars or secret manager |
| Generic catch-all error handler exposing details | Log internally, return generic message |
| No session invalidation on logout | Invalidate server-side on logout |
