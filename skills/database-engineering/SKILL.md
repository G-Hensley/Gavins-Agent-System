---
name: database-engineering
description: Database design, query optimization, migrations, and data modeling for SQL and NoSQL databases. Use when designing schemas, writing queries, optimizing performance, planning migrations, or working with DynamoDB, PostgreSQL, MySQL, or any database. Also use when the user says "database", "schema", "query", "migration", "index", "data model", or "DynamoDB".
---

# Database Engineering

Design reliable, performant data layers. Read the relevant reference for the database type and concern.

## Process

### 1. Identify the Data Needs
- What data entities exist and how do they relate?
- Read vs. write heavy? What are the access patterns?
- SQL (relational, joins, ACID) or NoSQL (key-value, document, eventual consistency)?

### 2. Design the Schema
Read `references/schema-design.md` for entity modeling, normalization, and index strategy.

### 3. Write Queries
Read `references/query-optimization.md` for writing efficient queries, avoiding N+1, and using indexes effectively.

### 4. Plan Migrations
Read `references/migrations.md` for safe schema changes, zero-downtime migrations, and rollback strategies.

### 5. Review
Dispatch the `database-engineer` subagent for schema design and migration work.

## What NOT to Do

- Do not design schemas without understanding access patterns first
- Do not add indexes blindly — each index slows writes and uses storage
- Do not run destructive migrations without a rollback plan
- Do not use `SELECT *` in production queries — specify columns
- Do not skip parameterized queries — always prevent SQL injection
- Do not store derived data that can be computed — unless proven performance need

## Reference Files

- `references/schema-design.md` — Entity modeling, normalization, denormalization, indexing strategy, DynamoDB vs SQL patterns.
- `references/query-optimization.md` — Query performance, N+1 prevention, index usage, EXPLAIN analysis, pagination.
- `references/migrations.md` — Safe schema changes, zero-downtime migrations, rollback strategies, data backfills.
**Subagent:** `database-engineer` — designs schemas, writes migrations, optimizes queries. Located at `~/.claude/agents/database-engineer.md`.
