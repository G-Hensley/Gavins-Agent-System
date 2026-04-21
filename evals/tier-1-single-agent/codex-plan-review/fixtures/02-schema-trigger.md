# Add Customer Tier Field

**Goal:** Track customer tier (free/pro/enterprise) in the database.

## Task 1: DB migration

- Create `db/migrations/20260418_add_customer_tier.sql`:
  - `ALTER TABLE customers ADD COLUMN tier VARCHAR(32) NOT NULL DEFAULT 'free'`
  - `CREATE INDEX idx_customers_tier ON customers (tier)`
- Backfill existing rows to `free`
- Update `db/models/customer.py` to include `tier` field
