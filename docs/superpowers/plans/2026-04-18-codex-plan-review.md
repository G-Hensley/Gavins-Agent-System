# Codex Plan Review Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a new `codex-plan-review` skill + `codex-plan-review` rule that runs drafted plans through Codex for an adversarial second-opinion review on high-risk or irreversible changes, and appends the review as an audit trail in the plan `.md`.

**Architecture:** Two markdown artifacts. `rules/codex-plan-review.md` is an always-active rule that tells Claude WHEN to invoke the skill. `skills/codex-plan-review/SKILL.md` is the skill body — trigger detection, Codex prompt construction, invocation of `codex-companion.mjs task`, finding resolution, and plan-doc appendix. Tier-1 eval fixtures verify trigger detection. Docs are updated to reflect the new skill and rule counts.

**Tech Stack:** Markdown (skill + rule + eval fixtures), Node (Codex companion CLI — already present via the `codex` plugin), no new runtime dependencies.

---

## File Structure

| File | Responsibility |
|---|---|
| `rules/codex-plan-review.md` | Always-active rule — WHEN to invoke the skill. Trigger list. Enforcement language. |
| `skills/codex-plan-review/SKILL.md` | The skill — HOW to detect triggers, build the Codex prompt, invoke the companion, resolve findings, append review to plan `.md`. |
| `evals/tier-1-single-agent/codex-plan-review/eval-prompt.md` | Eval scenario — instructs Claude to exercise the skill against the fixtures. |
| `evals/tier-1-single-agent/codex-plan-review/eval-criteria.md` | What a correct run looks like. |
| `evals/tier-1-single-agent/codex-plan-review/fixtures/*.md` | Six fixture plans (one per trigger) + two negatives (should-not-fire baselines). |
| `README.md` | Update skill count 34→35 and rule count 10→11. Add skill to the skills inventory. |
| `CONTEXT.md` | Update if it carries counts. |
| `docs/STATUS.md` | Update if it carries counts. |

No changes to `skills/writing-plans/SKILL.md`. The rule enforces invocation separately.

---

## Task 1: Write fixture plans + eval scaffolding (the "failing test")

**Files:**
- Create: `evals/tier-1-single-agent/codex-plan-review/eval-prompt.md`
- Create: `evals/tier-1-single-agent/codex-plan-review/eval-criteria.md`
- Create: `evals/tier-1-single-agent/codex-plan-review/fixtures/01-auth-trigger.md`
- Create: `evals/tier-1-single-agent/codex-plan-review/fixtures/02-schema-trigger.md`
- Create: `evals/tier-1-single-agent/codex-plan-review/fixtures/03-api-contract-trigger.md`
- Create: `evals/tier-1-single-agent/codex-plan-review/fixtures/04-infra-trigger.md`
- Create: `evals/tier-1-single-agent/codex-plan-review/fixtures/05-data-migration-trigger.md`
- Create: `evals/tier-1-single-agent/codex-plan-review/fixtures/06-irreversible-oneshot-trigger.md`
- Create: `evals/tier-1-single-agent/codex-plan-review/fixtures/07-no-trigger-readme-edit.md`
- Create: `evals/tier-1-single-agent/codex-plan-review/fixtures/08-no-trigger-refactor.md`

- [ ] **Step 1.1: Create eval-prompt.md**

```markdown
You have a drafted implementation plan at `<fixture-path>`. Apply the `codex-plan-review` skill per `rules/codex-plan-review.md`:

1. Check the six triggers.
2. If no trigger matches, explain which triggers you considered and exit.
3. If any trigger matches, list which triggers fired and construct (but do NOT execute) the Codex prompt you would send.

Do not run Codex. Do not modify files. Report your reasoning only.
```

- [ ] **Step 1.2: Create eval-criteria.md**

```markdown
# Codex Plan Review Eval Criteria

## Fixtures and expected behavior

| Fixture | Expected triggers | Expected action |
|---|---|---|
| 01-auth-trigger.md | Auth / authorization / session | Fire review, construct prompt |
| 02-schema-trigger.md | Database schema changes | Fire review, construct prompt |
| 03-api-contract-trigger.md | API contract changes | Fire review, construct prompt |
| 04-infra-trigger.md | Infrastructure changes | Fire review, construct prompt |
| 05-data-migration-trigger.md | Data migrations / backfills | Fire review, construct prompt |
| 06-irreversible-oneshot-trigger.md | Irreversible one-shots | Fire review, construct prompt |
| 07-no-trigger-readme-edit.md | — | Exit silently, do not fire |
| 08-no-trigger-refactor.md | — | Exit silently, do not fire |

## Pass bar

- All 6 positive fixtures correctly fire the review.
- Both negatives correctly exit without firing.
- For positives, the constructed prompt contains: plan text, six-section checklist, adversarial framing.
- No fixture causes a false attempt to execute Codex (this eval is detection-only).

## Fail modes to watch for

- False negative on a positive fixture (most dangerous — the whole point of the skill is not to miss these).
- False positive on a negative (annoying but recoverable).
- Skill attempts to execute `codex-companion.mjs` during the eval (the eval is detection-only).
- Constructed prompt is freestyle instead of the structured checklist.
```

- [ ] **Step 1.3: Create fixture 01 — auth trigger**

```markdown
# Add MFA to Login Flow

**Goal:** Require TOTP-based MFA on all Cognito logins.

## Task 1: Extend Cognito user pool

- Modify `infra/cognito-stack.ts` to enable MFA
- Update IAM role `LoginHandlerRole` to allow `cognito-idp:AdminSetUserMFAPreference`
- Add TOTP setup endpoint `POST /auth/mfa/setup` returning the shared secret
- Modify `api/src/handlers/login.ts` to enforce MFA challenge response before issuing session token
```

- [ ] **Step 1.4: Create fixture 02 — schema trigger**

```markdown
# Add Customer Tier Field

**Goal:** Track customer tier (free/pro/enterprise) in the database.

## Task 1: DB migration

- Create `db/migrations/20260418_add_customer_tier.sql`:
  - `ALTER TABLE customers ADD COLUMN tier VARCHAR(32) NOT NULL DEFAULT 'free'`
  - `CREATE INDEX idx_customers_tier ON customers (tier)`
- Backfill existing rows to `free`
- Update `db/models/customer.py` to include `tier` field
```

- [ ] **Step 1.5: Create fixture 03 — API contract trigger**

```markdown
# Breaking: Change /customers/{id} Response Shape

**Goal:** Move nested `contact` object to top-level fields on the customer response.

## Task 1: Update API response

- Modify `api/src/schemas/customer.ts` to flatten the response shape
- Remove `contact` nested object; add `email`, `phone`, `name` at top level
- Bump OpenAPI spec version in `docs/openapi.yaml`
- Mark this as a breaking change in `CHANGELOG.md`
```

- [ ] **Step 1.6: Create fixture 04 — infra trigger**

```markdown
# Add S3 Event-Driven Lambda

**Goal:** Process uploaded files via Lambda triggered by S3 PutObject.

## Task 1: Wire up infra

- Add S3 bucket `uploads-bucket` with event notification in `infra/lib/upload-stack.ts` (CDK)
- Add Lambda `processUploadFn` with S3 read permission
- Add VPC config so Lambda can reach internal database
- Update bucket policy to restrict uploads to authenticated users
```

- [ ] **Step 1.7: Create fixture 05 — data migration trigger**

```markdown
# Backfill Email Verification Status

**Goal:** Set `email_verified=true` for all customers created before 2026-01-01 (grandfathered in).

## Task 1: Run backfill script

- Create `scripts/backfill_email_verified.py`
- Script runs `UPDATE customers SET email_verified = true WHERE created_at < '2026-01-01' AND email_verified = false`
- Log affected row count
- Run against prod on 2026-04-20
```

- [ ] **Step 1.8: Create fixture 06 — irreversible one-shot trigger**

```markdown
# Announce New Product Tier via Email

**Goal:** Send a one-time product launch email to all active customers (est. 14,000 recipients).

## Task 1: Send campaign

- Create `scripts/send_launch_email.py` using SendGrid API
- Query active customers from `customers` table where `status='active'`
- Send email with subject "Introducing Pro Tier" and launch copy
- Log sends to `email_campaign_log` table
```

- [ ] **Step 1.9: Create fixture 07 — no-trigger README edit**

```markdown
# Update README for New Features

**Goal:** Document the new `--json` flag and clarify install instructions.

## Task 1: Rewrite install section

- Modify `README.md` to use pnpm commands instead of npm
- Add `--json` flag example to the Usage section
- Fix a broken link to the contributing guide
```

- [ ] **Step 1.10: Create fixture 08 — no-trigger refactor**

```markdown
# Extract CSV Parsing to a Utility Module

**Goal:** Move duplicated CSV parsing logic from three handlers into a shared utility.

## Task 1: Create utility module

- Create `src/utils/csv.ts` with `parseCsv(input: string): Row[]`
- Update `src/handlers/reportA.ts`, `src/handlers/reportB.ts`, `src/handlers/reportC.ts` to import from the new util
- Add unit tests for the utility
- Delete the inlined parse functions
```

- [ ] **Step 1.11: Commit**

```bash
git add evals/tier-1-single-agent/codex-plan-review/
git commit -m "test(evals): add codex-plan-review tier-1 fixtures and criteria"
```

---

## Task 2: Write the rule file

**Files:**
- Create: `rules/codex-plan-review.md`

- [ ] **Step 2.1: Create the rule file**

```markdown
# Codex Plan Review Rule (Always Active)

When a plan is drafted (by `writing-plans`, `subagent-driven-development`, or any other flow), you MUST run it through the `codex-plan-review` skill BEFORE presenting the plan to the user or executing any task from it.

## When to invoke

Invoke `codex-plan-review` if the drafted plan touches any of:

1. **Auth / authorization / session logic** — login, tokens, IAM, Cognito, permissions, RBAC
2. **Database schema changes** — migrations, new tables, column type changes, index changes
3. **API contract changes** — new or removed endpoints, response shape changes, breaking changes
4. **Infrastructure changes** — CDK / CloudFormation / SAM / Terraform, Lambda config, VPC, S3 policies, secrets
5. **Data migrations or backfills** touching prod data
6. **Irreversible one-shots** — sending emails at scale, publishing packages, pushing release tags, external side effects

Any one match fires the skill. If none match, skip the review and continue the plan flow.

## What the skill does

- Runs Codex with a structured adversarial-review checklist on the plan content
- Claude reads Codex's findings, pushes back where warranted, revises the plan
- Appends `## Codex Review` section to the plan `.md` (findings + Claude's resolution)
- Presents revised plan + one-paragraph summary to the user

## Enforcement

- Do not skip the review because it feels redundant or slow. The triggers above are the explicit criteria.
- If Codex is unavailable, note it in the plan appendix and continue — do not block the plan.
- False positives are acceptable; false negatives are the failure mode to minimize.
```

- [ ] **Step 2.2: Verify rule file is under 200 lines and well-formed**

Run:
```bash
wc -l rules/codex-plan-review.md
```

Expected: under 40 lines.

- [ ] **Step 2.3: Commit**

```bash
git add rules/codex-plan-review.md
git commit -m "feat(rules): add codex-plan-review rule for adversarial plan review"
```

---

## Task 3: Write the skill file

**Files:**
- Create: `skills/codex-plan-review/SKILL.md`

- [ ] **Step 3.1: Create the skill directory and SKILL.md**

```markdown
---
name: codex-plan-review
description: Run an adversarial Codex review on a drafted plan to catch load-bearing flaws before implementation. Use when a plan touches auth, DB schema, API contracts, infrastructure, data migrations, or irreversible one-shots — triggers defined in rules/codex-plan-review.md.
last_verified: 2026-04-18
---

# Codex Plan Review

Adversarial second-opinion on drafted plans where rework is expensive.

**Announce at start:** "I'm using the codex-plan-review skill to review this plan with Codex."

## Process

### 1. Check triggers

Scan the drafted plan for any of these (full detail in `rules/codex-plan-review.md`):

1. Auth / authorization / session logic
2. Database schema changes
3. API contract changes
4. Infrastructure changes (IaC, Lambda config, VPC, S3, secrets)
5. Data migrations / backfills touching prod data
6. Irreversible one-shots (mass emails, package publishes, release tags, external side effects)

**No match → exit silently.** The plan continues unchanged. Note which triggers you considered so the user can see your reasoning if asked.

**Match →** note which triggers fired. Proceed to step 2.

### 2. Construct the Codex prompt

Build a prompt that includes the full plan document text, the structured six-section checklist, and adversarial framing.

Template:

    You are reviewing a drafted implementation plan. Assume it will go wrong in production. Find the strongest reasons this plan should not ship as-is.

    Answer each section concretely. Push back hard where the plan is wrong. No style feedback. No filler.

    **Rollback.** If this plan ships and breaks, how do we undo it? Is the rollback path tested or documented?

    **Blast radius.** What user-facing surfaces, data, or systems does this touch if it goes wrong?

    **Missing tests.** What behavior is not covered by the tests in this plan?

    **Wrong assumptions.** What does the plan assume that might not hold?

    **Cheapest failure.** What is the single most likely thing to go wrong, and how would we catch it?

    **Alternatives.** Is there a materially better approach? If yes, describe it concretely.

    ---

    PLAN DOCUMENT:

    <paste plan text here>

### 3. Invoke Codex

Run the shared companion in read-only mode (no `--write`):

    node "${CLAUDE_PLUGIN_ROOT}/scripts/codex-companion.mjs" task "<prompt>"

For large plans (>500 lines or >10 tasks), run in background:

    node "${CLAUDE_PLUGIN_ROOT}/scripts/codex-companion.mjs" task --background "<prompt>"

If Codex fails or is unavailable, proceed to step 5 with `Codex review attempted but failed` noted in the appendix. Do NOT block the plan.

### 4. Resolve findings

For each of Codex's six sections:
- **Accept** and revise the plan, OR
- **Push back** with concrete reasoning (Codex missed context, wrong assumption about the codebase, alternative is worse for reasons X/Y).

Do not rubber-stamp. Do not blindly reject. Use judgment.

### 5. Append review to the plan `.md`

Add a `## Codex Review` section at the bottom:

    ## Codex Review

    **Triggers matched:** <list>
    **Codex effort:** default
    **Reviewed:** YYYY-MM-DD

    ### Codex findings

    <Codex's raw response>

    ### Claude's resolution

    - **Rollback finding:** Accepted — <summary of plan change>
    - **Blast radius finding:** Pushed back — <reasoning>
    - **Missing tests finding:** Accepted — <summary of plan change>
    - **Wrong assumptions finding:** Accepted — <summary of plan change>
    - **Cheapest failure finding:** Accepted — <summary of plan change>
    - **Alternatives finding:** Considered and rejected — <reasoning>

    ### Summary

    <One paragraph: what changed in the plan and why.>

### 6. Present to the user

Show:
- (a) the revised plan, and
- (b) a one-paragraph "what changed and why" summary.

User approves or requests further changes.

## Composition

- Called from `writing-plans` after plan draft, before handoff to execution.
- Called from `subagent-driven-development` if plans are drafted mid-flow.
- Callable ad-hoc by the user: "review this plan with Codex".

## Constraints

- Keep this file under 200 lines.
- Read-only — never add `--write` to the Codex invocation.
- Never skip the review silently when a trigger matches — exit only on no-match.
- Fail open on Codex unavailability — log it in the appendix, do not block the plan.
```

- [ ] **Step 3.2: Verify skill file is under 200 lines**

Run:
```bash
wc -l skills/codex-plan-review/SKILL.md
```

Expected: under 200 lines.

- [ ] **Step 3.3: Verify frontmatter is valid YAML**

Run (PowerShell, since the host is Windows):
```bash
node -e "const fs=require('fs'); const m=fs.readFileSync('skills/codex-plan-review/SKILL.md','utf8').match(/^---\n([\s\S]*?)\n---/); if(!m){process.exit(1)} console.log(m[1])"
```

Expected: prints the frontmatter block (name, description, last_verified).

- [ ] **Step 3.4: Commit**

```bash
git add skills/codex-plan-review/SKILL.md
git commit -m "feat(skills): add codex-plan-review skill for adversarial plan review"
```

---

## Task 4: Verify trigger detection against fixtures (the "green" state)

**Files:**
- No file changes. Verification only.

- [ ] **Step 4.1: Run mental trigger detection on each fixture**

For each fixture `evals/tier-1-single-agent/codex-plan-review/fixtures/01-*.md` through `08-*.md`:
- Read the fixture
- Apply the trigger list from `rules/codex-plan-review.md`
- Record which triggers fire
- Compare against `eval-criteria.md`

Expected:
| Fixture | Triggers fired | Matches criteria? |
|---|---|---|
| 01-auth | Auth, Infra | ✓ |
| 02-schema | Schema, Data migration | ✓ |
| 03-api-contract | API contract | ✓ |
| 04-infra | Infra | ✓ |
| 05-data-migration | Data migration | ✓ |
| 06-irreversible | Irreversible one-shot | ✓ |
| 07-no-trigger-readme | none | ✓ |
| 08-no-trigger-refactor | none | ✓ |

All positive fixtures must cite every expected trigger listed. A skill that fires on only one trigger for a multi-trigger fixture is a short-circuit regression — treat it as a fail, not a pass.

If any row disagrees with the criteria, stop and fix the skill or the criteria (whichever is wrong) before proceeding.

- [ ] **Step 4.2: Verify Codex companion is reachable**

Run:
```bash
node "${CLAUDE_PLUGIN_ROOT}/scripts/codex-companion.mjs" 2>&1 | head -10
```

Expected: prints the usage help (the `Usage:` block showing the `task`, `review`, `adversarial-review` subcommands).

If the command errors with "MODULE_NOT_FOUND" or `CLAUDE_PLUGIN_ROOT` is empty, the Codex plugin isn't installed or the env var isn't exported. Document the remediation in the plan appendix when this happens in real use, but the skill still ships — it fails open on unavailability.

---

## Task 5: Update docs for new skill + rule counts

**Files:**
- Modify: `README.md`
- Modify: `CONTEXT.md` (if it carries counts)
- Modify: `docs/STATUS.md` (if it carries counts)

- [ ] **Step 5.1: Identify all count references**

Run:
```bash
grep -nE "\\b(34|10) (reusable skills|path-scoped rules|skills|rules)\\b|Should see (34|10)" README.md CLAUDE.md CONTEXT.md docs/STATUS.md 2>/dev/null
```

Expected: a small set of lines referencing `34 reusable skills`, `10 path-scoped rules`, and `Should see 34` in README.md at minimum. Any matches in the other files need updating too.

- [ ] **Step 5.2: Update README.md**

In `README.md`, replace:
- `34 reusable skills` → `35 reusable skills`
- `10 path-scoped rules` → `11 path-scoped rules`
- `34 reusable skills (each with SKILL.md + references/)` → `35 reusable skills (each with SKILL.md + references/)`
- `10 path-scoped rules (glob-activated domain instructions)` → `11 path-scoped rules (glob-activated domain instructions)`
- `Should see 34 skill directories` → `Should see 35 skill directories`

Also add `codex-plan-review` to any skills inventory list in the README (check the skills section — if it enumerates skills, add this one in alphabetical order).

- [ ] **Step 5.3: Update CONTEXT.md and docs/STATUS.md if they carry counts**

If `grep` in step 5.1 showed hits in these files, update them to the same new counts (35 skills, 11 rules).

If they don't carry counts, no change.

- [ ] **Step 5.4: Verify no count drift remains**

Run:
```bash
grep -nE "\\b(34 skills|34 reusable skills|10 path-scoped rules|Should see 34)\\b" README.md CLAUDE.md CONTEXT.md docs/STATUS.md 2>/dev/null
```

Expected: no matches. If any remain, update them.

- [ ] **Step 5.5: Commit**

```bash
git add README.md
# Also stage CONTEXT.md / docs/STATUS.md if changed
git add CONTEXT.md docs/STATUS.md 2>/dev/null || true
git commit -m "docs: update skill and rule counts for codex-plan-review"
```

---

## Task 6: Final verification and push

**Files:**
- No file changes.

- [ ] **Step 6.1: Verify working tree is clean**

Run:
```bash
git status
```

Expected: `working tree clean` (all changes committed).

- [ ] **Step 6.2: Verify all new files exist and are sensible**

Run:
```bash
ls -la rules/codex-plan-review.md skills/codex-plan-review/SKILL.md evals/tier-1-single-agent/codex-plan-review/
```

Expected: all three paths resolve; the evals dir lists `eval-prompt.md`, `eval-criteria.md`, `fixtures/`.

- [ ] **Step 6.3: Confirm active GitHub account before pushing**

Run:
```bash
gh auth status
```

Expected: shows `G-Hensley` as the active account. If it shows `Gavin-Hensley`, switch accounts before pushing.

- [ ] **Step 6.4: Push**

```bash
git push origin main
```

Expected: push succeeds, all three new commits land on `origin/main`.

---

## Self-Review

**Spec coverage:**
- ✓ New skill file → Task 3
- ✓ New rule file → Task 2
- ✓ Trigger list of 6 → rule in Task 2, skill in Task 3, fixtures 01–06 in Task 1
- ✓ Six-section structured checklist → skill in Task 3
- ✓ Adversarial framing → skill in Task 3 prompt template
- ✓ `codex-companion.mjs task` invocation (no `--write`) → skill in Task 3
- ✓ Read-only enforcement → skill constraints in Task 3
- ✓ Background for large plans → skill in Task 3
- ✓ Fail-open on Codex unavailability → rule in Task 2, skill in Task 3
- ✓ Plan `.md` appendix with the exact template → skill in Task 3
- ✓ Push-back / acceptance resolution pattern → skill in Task 3, rule in Task 2
- ✓ Composable from writing-plans / subagent-driven-development / ad-hoc → skill in Task 3
- ✓ Doc updates per `rules/documentation.md` → Task 5
- ✓ Eval fixtures for trigger detection → Task 1 (all six triggers + two negatives)
- ✓ Eval criteria → Task 1

No spec requirements without a task.

**Placeholder scan:**
- No "TBD", "TODO", "implement later", or vague error-handling placeholders.
- Every step includes exact commands or exact content to write.
- No "similar to Task N" back-references.

**Type consistency:**
- Skill name used consistently: `codex-plan-review` (in frontmatter, rule, docs, eval fixtures).
- Rule name used consistently: `rules/codex-plan-review.md`.
- Trigger labels consistent across rule, skill, fixtures, and eval criteria.
- Path to Codex companion consistent: `${CLAUDE_PLUGIN_ROOT}/scripts/codex-companion.mjs`.
