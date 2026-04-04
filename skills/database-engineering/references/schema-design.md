# Schema Design

## Entity Modeling
1. Identify entities (nouns: User, Project, Scan, Report)
2. Define attributes for each entity
3. Map relationships (1:1, 1:many, many:many)
4. Choose primary keys (natural vs surrogate)
5. Define constraints (NOT NULL, UNIQUE, CHECK, FOREIGN KEY)

## SQL Normalization
- **1NF**: No repeating groups, atomic values
- **2NF**: No partial dependencies (every non-key depends on full key)
- **3NF**: No transitive dependencies (non-key depends only on key)
- Denormalize intentionally for read performance — document why

## DynamoDB Patterns
- **Single-table design**: store multiple entity types in one table
- **Partition key**: high cardinality, even distribution (e.g., customerId)
- **Sort key**: enables range queries within a partition (e.g., timestamp, status#name)
- **GSI**: for alternate access patterns (max 20 per table)
- **Access patterns first**: list all queries before designing the table

```
PK: CUSTOMER#123    SK: SCAN#2024-01-15    (scan record)
PK: CUSTOMER#123    SK: PROFILE#auth-basic  (auth profile)
PK: CUSTOMER#123    SK: META               (customer metadata)
```

## Indexing Strategy
- Index columns used in WHERE, JOIN, ORDER BY
- Composite indexes: leftmost prefix rule (order matters)
- Don't over-index: each index slows writes
- Cover queries with indexes when possible (index-only scans)
- Monitor unused indexes and remove them

## Data Types
- Use appropriate types (not everything is VARCHAR)
- Use TIMESTAMP WITH TIME ZONE for dates
- Use UUID or ULID for distributed IDs
- Use JSONB (Postgres) sparingly — for truly flexible schemas, not to avoid modeling
