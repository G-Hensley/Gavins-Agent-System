# Database Security

## SQL Injection Prevention
- Always use parameterized queries — never string concatenation
- Use ORM query builders (Prisma, SQLAlchemy, Knex) which parameterize by default
- If raw SQL is needed, use prepared statements with bound parameters

```typescript
// BAD: SQL injection vulnerable
db.query(`SELECT * FROM users WHERE id = '${userId}'`)

// GOOD: Parameterized
db.query('SELECT * FROM users WHERE id = $1', [userId])
```

## Access Control
- Use database roles with minimum necessary permissions
- Application user should not have DDL permissions (CREATE, DROP, ALTER)
- Separate read-only and read-write connection pools where possible
- Never use database root/admin credentials in application code

## Encryption
- Encrypt sensitive data at rest (PII, financial data, health records)
- Use application-level encryption for sensitive columns, not just disk encryption
- Encrypt backups — treat them with the same security as live data
- Use TLS for all database connections (especially cross-network)

## Data Handling
- Never log full query results containing sensitive data
- Mask PII in logs: show `user_***@***.com` not full email
- Implement soft deletes for audit trails where required
- Set appropriate data retention policies

## Common Anti-Patterns
| Anti-Pattern | Fix |
|---|---|
| String concatenation in queries | Parameterized queries |
| Storing passwords in plaintext | bcrypt/argon2 hashing |
| SELECT * returning sensitive columns | Explicit column selection |
| App running as DB admin | Least-privilege DB user |
| Unencrypted backups | Encrypt backups at rest |
