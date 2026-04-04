# Plan: Swap SendGrid back to Resend for Contact Form Email

## Context
The contact form email was originally implemented with Resend, then switched to SendGrid due to Resend's free-tier domain limit. The user now wants to switch back to Resend.

## Changes

### Step 1: Swap packages
- Remove `@sendgrid/mail` (`^8.1.6`)
- Install `resend` (latest)

```bash
pnpm remove @sendgrid/mail && pnpm add resend
```

### Step 2: Update server action
**File:** `src/app/(site)/contact/actions.ts`

Current SendGrid pattern:
```ts
import sgMail from "@sendgrid/mail";
sgMail.setApiKey(apiKey);
await sgMail.send({ from, to, replyTo, subject, text });
```

New Resend pattern:
```ts
import { Resend } from "resend";
const resend = new Resend(apiKey);
await resend.emails.send({ from, to, replyTo, subject, text });
```

- Env var: `SENDGRID_API_KEY` → `RESEND_API_KEY`
- `from`, `to`, `replyTo`, `subject`, `text` fields are identical in both APIs
- Error handling structure stays the same

### Step 3: Update `.env.example`
- Replace `SENDGRID_API_KEY` with `RESEND_API_KEY`
- Update section header from "Email (SendGrid)" to "Email (Resend)"

### Step 4: Update `CLAUDE.md`
- Confirm Resend is listed in tech stack (it already is)

## Files Summary

| File | Action |
|------|--------|
| `package.json` | Remove @sendgrid/mail, add resend |
| `pnpm-lock.yaml` | Auto-updated |
| `src/app/(site)/contact/actions.ts` | Swap SendGrid → Resend API |
| `.env.example` | Rename env var |

3 files modified manually. 1 dependency swapped.

## Verification
1. `pnpm typecheck` passes
2. `pnpm build` succeeds
3. Dev mode contact form submission logs correctly (no API key needed in dev)
4. `@sendgrid/mail` fully removed from `package.json` and lockfile
