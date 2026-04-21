# Announce New Product Tier via Email

**Goal:** Send a one-time product launch email to all active customers (est. 14,000 recipients).

## Task 1: Send campaign

- Create `scripts/send_launch_email.py` using SendGrid API
- Query active customers from `customers` table where `status='active'`
- Send email with subject "Introducing Pro Tier" and launch copy
- Log sends to `email_campaign_log` table
