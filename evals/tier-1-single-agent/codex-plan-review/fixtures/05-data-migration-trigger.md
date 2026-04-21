# Backfill Email Verification Status

**Goal:** Set `email_verified=true` for all customers created before 2026-01-01 (grandfathered in).

## Task 1: Run backfill script

- Create `scripts/backfill_email_verified.py`
- Script runs `UPDATE customers SET email_verified = true WHERE created_at < '2026-01-01' AND email_verified = false`
- Log affected row count
- Run against prod on 2026-04-20
