# Codex Plan Review Rule (Always Active)

When a written plan document is drafted (by `writing-plans`, `subagent-driven-development`, or any other flow that produces a plan `.md` file), you MUST run it through the `codex-plan-review` skill BEFORE presenting the plan to the user or executing any task from it. Inline conversational plans (no backing file) are out of scope for this rule.

## When to invoke

Invoke `codex-plan-review` if the drafted plan touches any of:

1. **Auth / authorization / session logic** — login, tokens, IAM, Cognito, permissions, RBAC
2. **Database schema changes** — migrations, new tables, column type changes, index changes
3. **API contract changes** — new or removed endpoints, response shape changes, breaking changes
4. **Infrastructure changes** — CDK / CloudFormation / SAM / Terraform, Lambda config, VPC, S3 policies, secrets
5. **Data migrations or backfills** touching prod data
6. **Irreversible one-shots** — sending emails at scale, publishing packages, pushing release tags, external side effects

Categories overlap intentionally (e.g., IAM policies can be both auth and infra). Any single match fires — do not try to pick the "right" category.

Any one match fires the skill. If none match, skip the review and continue the plan flow.

## What the skill does

- Runs Codex with a structured adversarial-review checklist on the plan content
- Claude reads Codex's findings, pushes back where warranted, revises the plan
- Appends `## Codex Review` section to the plan `.md` (findings + Claude's resolution)
- Presents revised plan + one-paragraph summary to the user

## Enforcement

- Do not skip the review because it feels redundant or slow. The triggers above are the explicit criteria.
- If Codex fails or is unavailable, note the reason in the plan appendix (transient error vs. missing installation / `CLAUDE_PLUGIN_ROOT` unset) and continue — do not block the plan. Missing-installation cases should also be flagged to the user in the summary so they can remediate.
- False positives are acceptable; false negatives are the failure mode to minimize.
