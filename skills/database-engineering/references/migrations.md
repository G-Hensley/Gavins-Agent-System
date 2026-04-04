# Database Migrations

## Safe Migration Principles
1. **Always reversible** — every migration has a rollback plan
2. **Additive first** — add new columns/tables before removing old ones
3. **Zero-downtime** — no locking operations on large tables during peak hours
4. **Test on staging** — run migration against production-size data first
5. **Backup before** — snapshot or dump before destructive changes

## Safe Operations (no downtime)
- Add a new table
- Add a nullable column
- Add an index CONCURRENTLY (Postgres)
- Add a new column with default (Postgres 11+)

## Dangerous Operations (plan carefully)
- Rename column → add new, migrate data, drop old (3 deploys)
- Change column type → add new column, backfill, swap (3 deploys)
- Drop column → remove code references first, then drop column
- Add NOT NULL constraint → add constraint as CHECK first, then validate
- Large table operations → do in batches during off-peak

## Three-Deploy Pattern for Breaking Changes
```
Deploy 1: Add new column (nullable), start writing to both
Deploy 2: Backfill data, switch reads to new column
Deploy 3: Drop old column, add NOT NULL if needed
```

## Backfill Patterns
```sql
-- Batch backfill (don't update millions at once)
UPDATE users SET new_column = old_column
WHERE new_column IS NULL
LIMIT 1000;
-- Repeat until no rows affected
```

## Rollback Strategy
- Keep the previous migration's rollback script ready
- Test rollback on staging before applying to production
- For data migrations: keep old data until confirmed (soft delete)

## DynamoDB Migrations
- No schema migrations needed (schemaless) — but access pattern changes require GSI changes
- Adding GSI: backfills automatically, takes time on large tables
- Removing GSI: immediate, but irreversible — ensure nothing reads from it
