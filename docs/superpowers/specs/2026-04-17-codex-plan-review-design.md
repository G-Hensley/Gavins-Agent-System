# Codex Plan Review — Design Spec

**Date:** 2026-04-17
**Status:** Draft, awaiting approval
**Owner:** Gavin

## Problem

The `writing-plans` skill produces implementation plans that Claude then executes. For high-risk or hard-to-reverse work, there is no second-opinion gate — a flawed plan rolls straight into implementation. Flaws that a fresh reviewer would catch (missing rollback, wrong assumption, unconsidered alternative) only surface after code is written, if at all.

Adding a Codex review step before plan finalization creates that gate, but only when it earns its keep. Not every plan needs it; most don't.

## Goals

- **Catch load-bearing flaws before implementation** on plans where rework is expensive.
- **Stay out of the way on low-risk work.** Trivial plans must not pay a Codex round-trip tax.
- **Leave an audit trail.** Whoever reads the plan later sees what Codex challenged and how it was resolved.
- **Composable.** Usable from `writing-plans`, from `subagent-driven-development`, and ad-hoc.

## Non-Goals

- **Not a replacement for `codex-rescue`.** Rescue is for task execution; this is for plan review.
- **Not a code reviewer.** Code review stays with `/codex:review` and `/codex:adversarial-review`. This reviews plan documents (prose + task lists), not diffs.
- **Not automatic plan rewriting without Claude's judgment.** Codex critiques; Claude revises and defends where warranted.
- **Not a global gate on every plan.** Triggers are narrow by design.

## Artifacts

| File | Purpose |
|---|---|
| `skills/codex-plan-review/SKILL.md` | The skill — trigger detection, Codex invocation, response handling, output format. |
| `rules/codex-plan-review.md` | Always-active rule — codifies WHEN the skill must be invoked. Lives next to `rules/security.md`, `rules/testing.md`. |

No changes to `skills/writing-plans/SKILL.md`. The rule enforces invocation; the skill runs as a sub-step inside the plan flow.

## Triggers

The skill checks the drafted plan against six triggers. **Any one match fires the review.** If none match, the skill exits silently and the plan flow continues unchanged.

1. **Auth / authorization / session logic.** Login, tokens, IAM, Cognito, permissions, RBAC.
2. **Database schema changes.** Migrations, new tables, column type changes, index changes.
3. **API contract changes.** New or removed endpoints, response shape changes, breaking changes to existing contracts.
4. **Infrastructure changes.** CDK / CloudFormation / SAM / Terraform, Lambda config, VPC, S3 policies, secrets, IAM resources.
5. **Data migrations or backfills touching prod data.** One-shot scripts that modify rows in shared systems.
6. **Irreversible one-shots.** Sending emails at scale, publishing packages, pushing release tags, any external side effect that can't be unwound by `git revert`.

Detection is heuristic — Claude scans the plan for file paths, task descriptions, and keywords matching these categories. False positives are acceptable; false negatives are the failure mode to minimize.

## Codex Prompt (Structured Checklist + Adversarial Framing)

Codex is asked to answer a fixed set of questions, not freestyle. Framing: *"Assume this plan will go wrong in production. Where does it break first?"*

Required sections in Codex's response:

- **Rollback.** If this plan ships and breaks, how do we undo it? Is the rollback path tested or documented?
- **Blast radius.** What user-facing surfaces, data, or systems does this touch if it goes wrong?
- **Missing tests.** What behavior isn't covered by the tests in the plan?
- **Wrong assumptions.** What does the plan assume that might not hold?
- **Cheapest failure.** What's the single most likely thing to go wrong, and how would we catch it?
- **Alternatives.** Is there a materially better approach? If yes, describe it concretely.

Codex is instructed to **push back** where the plan is wrong, not to validate. No style feedback. No filler.

## Invocation Mechanism

The skill shells out to the shared Codex companion:

```
node "${CLAUDE_PLUGIN_ROOT}/scripts/codex-companion.mjs" task [prompt]
```

- **No `--write` flag.** Review only; Codex does not modify the repo.
- **No `--effort` override** by default. Can be tuned later if needed.
- Prompt includes the full plan document text followed by the structured checklist above.
- `--background` is used when the plan is large (rough heuristic: >500 lines or >10 tasks); otherwise foreground.

**Why `task` and not `adversarial-review`:** `adversarial-review` returns structured JSON findings tied to file/line numbers in the git working tree. That's built for code review, not prose plan review. `task` gives us an arbitrary-prompt channel that returns prose, which matches the plan-review shape.

## Flow

1. `writing-plans` drafts the plan document.
2. The rule in `rules/codex-plan-review.md` triggers invocation of the `codex-plan-review` skill.
3. The skill runs trigger detection against the drafted plan. **No match → exit silently.**
4. **Match →** skill constructs the prompt (plan + structured checklist) and invokes `codex-companion.mjs task`.
5. Claude reads Codex's response. For each finding, Claude either:
   - **Accepts** and revises the plan accordingly, or
   - **Pushes back** with concrete reasoning (Codex missed context, wrong assumption about the codebase, alternative is worse for reasons X/Y).
6. Claude appends a `## Codex Review` section to the plan `.md` file. This section contains:
   - Codex's raw structured response.
   - Claude's per-finding resolution: "Accepted — revised plan step N" or "Pushed back — reasoning here."
   - A one-line summary of what changed in the plan and why.
7. Claude presents to user:
   - (a) the revised plan,
   - (b) a one-paragraph "what changed and why" summary.
8. User approves or requests further changes.

## Output Format (Plan Appendix)

Committed alongside the plan in the same `.md` file:

```markdown
## Codex Review

**Triggers matched:** auth, database schema
**Codex effort:** default
**Reviewed:** 2026-04-17

### Codex findings

(verbatim structured response from Codex, organized by the six prompt sections)

### Claude's resolution

- **Rollback finding:** Accepted — added rollback step to task 4.
- **Blast radius finding:** Pushed back — Codex assumed multi-tenant impact, but this table is single-tenant per the schema in db/models.py:42.
- **Missing tests finding:** Accepted — added integration test to task 7.
- **Wrong assumptions finding:** Accepted — reworded task 2 to make the assumption explicit.
- **Cheapest failure finding:** Accepted — added CloudWatch alarm to task 5.
- **Alternatives finding:** Considered and rejected — alternative would require schema migration we're explicitly trying to avoid.

### Summary

Revised plan to add rollback step, integration test, and CloudWatch alarm. Pushed back on blast-radius finding (single-tenant) and rejected proposed alternative (would expand scope).
```

## Testing

- **Skill unit-level check:** invoke the skill against a small curated set of synthetic plan docs (auth-touching, schema-changing, trivial, etc.) and verify trigger detection fires correctly.
- **End-to-end:** run `writing-plans` on a real high-risk plan and confirm the skill fires, appends the review, and Claude's resolution reads coherently.
- **Rule enforcement:** verify the rule in `rules/codex-plan-review.md` is picked up as an always-active rule per `gavins-agent-system` rule-loading convention.

## Open Questions (Resolved Inline)

- **Where does the skill live?** `skills/codex-plan-review/SKILL.md`, alongside other skills in `gavins-agent-system`.
- **Does the rule file have any special format?** Follows the convention of existing files in `rules/` (plain markdown, headers, imperative statements).
- **What if Codex is unavailable or errors?** Skill logs the failure and continues without blocking plan finalization. The plan is marked `Codex review attempted but failed` in the appendix for transparency.
- **Does this apply to subagent-driven-development plans too?** Yes — the rule applies whenever a plan is drafted, regardless of the orchestrating skill.
- **Tuning threshold for triggers is a knob we might need later.** Acceptable — we'll tune based on observed false-positive/false-negative rate.

## Future Work (Out of Scope for This Spec)

- Automatic trigger tuning based on historical false-positive rate.
- Integrating the review into `subagent-driven-development` per-task (currently only at plan level).
- Running Codex review on completed implementations as a pre-merge gate (would be a separate skill).
