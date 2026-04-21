---
name: codex-plan-review
description: Run an adversarial Codex review on a drafted plan to catch load-bearing flaws before implementation. Use when a plan touches auth, DB schema, API contracts, infrastructure, data migrations, or irreversible one-shots — triggers defined in rules/codex-plan-review.md.
last_verified: 2026-04-18
---

# Codex Plan Review

Adversarial second-opinion on drafted plans where rework is expensive.

**Announce at start:** "I'm using the codex-plan-review skill to review this plan with Codex."

## Process

### 0. Scope check

This skill operates on **written plan documents** — a `.md` file you can read and append to. Confirm the plan has a backing file before proceeding.

- If there is no backing plan `.md`, exit immediately with: "Inline plan — out of scope for codex-plan-review per `rules/codex-plan-review.md`."
- Otherwise proceed to step 1.

### 1. Check triggers

Scan the drafted plan for any of these (full detail in `rules/codex-plan-review.md`):

1. Auth / authorization / session logic
2. Database schema changes
3. API contract changes
4. Infrastructure changes (IaC, Lambda config, VPC, S3, secrets)
5. Data migrations / backfills touching prod data
6. Irreversible one-shots (mass emails, package publishes, release tags, external side effects)

**No match → exit silently.** The plan continues unchanged and there is no user-facing output for this step.

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

### 3. Invoke Codex via the rescue subagent

Dispatch the `codex:rescue` subagent using the Agent tool. Frame the task as **review only** so the rescue runtime does not add `--write` to the underlying Codex invocation.

Agent tool invocation:
- `subagent_type`: `codex:rescue`
- `description`: `Adversarial plan review`
- `prompt`: the full structured-checklist prompt from step 2, with a leading sentence: "REVIEW ONLY. Do not edit any files. Return your findings as prose grouped by the six section headings."

Why the rescue agent: it wraps the shared Codex runtime (`codex-companion.mjs`), handles `CLAUDE_PLUGIN_ROOT` resolution internally, and is the documented integration path for "second opinion" work.

For large plans (>500 lines or >10 tasks), append to the prompt: "Run this in the background via `--background` and return when complete."

**If the `codex:rescue` agent is unavailable** (the Codex plugin is not installed, or dispatch errors with a missing-subagent message):
- Treat this as a **missing-installation** failure.
- Proceed to step 5 and note `Codex rescue agent not available — plugin likely not installed` in the appendix.
- In the user-facing summary (step 6), flag this explicitly so the user can remediate (install the `codex` Claude Code plugin).

**If the agent is available but the review itself errors** (transient runtime failure, timeout, malformed response):
- Treat this as a **transient failure**.
- Proceed to step 5 and note `Codex review attempted but failed: <short reason>` in the appendix.
- No user notification needed in the summary — the appendix is enough.

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

This skill is invoked by the always-active rule in `rules/codex-plan-review.md`, not called directly by other skills. In practice that means it fires during:

- `writing-plans` flows that produce a plan `.md` file.
- `subagent-driven-development` flows that draft a new plan mid-flow.
- Ad-hoc user requests like "review this plan with Codex" (only if the plan has a backing `.md`).

If the task is an inline conversational plan with no backing file, the scope check in step 0 exits before any review runs.

## Constraints

- Keep this file under 200 lines.
- Read-only — never add `--write` to the Codex invocation.
- Never skip the review silently when a trigger matches — exit only on no-match.
- Fail open on Codex unavailability — log it in the appendix, do not block the plan.
- Prefer the `codex:rescue` subagent for invocation over direct shell-out to `codex-companion.mjs`. The rescue agent handles env var resolution (`CLAUDE_PLUGIN_ROOT`) and the runtime contract. Only shell out directly if you know exactly where the companion lives and you have a reason to bypass the rescue path.
