# Query Optimization

## N+1 Problem
```sql
-- BAD: 1 query for users + N queries for their projects
SELECT * FROM users;
-- then for each user:
SELECT * FROM projects WHERE user_id = ?;

-- GOOD: 1 query with JOIN or IN
SELECT u.*, p.* FROM users u
JOIN projects p ON p.user_id = u.id;

-- Or batch:
SELECT * FROM projects WHERE user_id IN (1, 2, 3, ...);
```

## EXPLAIN Analysis
Run EXPLAIN (or EXPLAIN ANALYZE in Postgres) on slow queries:
- **Seq Scan**: no index used — add one or restructure query
- **Index Scan**: good — using an index
- **Nested Loop**: check if inner table has appropriate index
- **Hash Join**: fine for large tables, check if expected
- **Sort**: check if an index could provide ordering

## Index Usage
- Check if WHERE columns have indexes
- Check if JOIN columns have indexes on both sides
- Composite index order matters: `(status, created_at)` helps `WHERE status = 'active' ORDER BY created_at` but not `WHERE created_at > X`

## Pagination
```sql
-- Offset pagination (simple, but slow for large offsets)
SELECT * FROM scans ORDER BY id LIMIT 20 OFFSET 100;

-- Cursor pagination (consistent, performant)
SELECT * FROM scans WHERE id > :last_id ORDER BY id LIMIT 20;
```
Use cursor-based for large datasets. Offset-based is fine for small tables.

## Common Pitfalls
- `SELECT *` fetches unnecessary columns — specify what you need
- Functions on indexed columns prevent index use: `WHERE YEAR(created_at) = 2024` → `WHERE created_at >= '2024-01-01'`
- Implicit type conversion prevents index use — match types
- `OR` conditions often prevent index use — consider UNION
- Missing LIMIT on queries that could return millions of rows

## DynamoDB Query Patterns
- Use Query (not Scan) whenever possible — Scan reads entire table
- Use FilterExpression for post-query filtering (still reads all items)
- Batch reads with BatchGetItem (max 100 items)
- Use pagination with LastEvaluatedKey for large result sets
