# Reference Reading Rule (Always Active)

Before proposing any **design, spec, integration path, or implementation approach**, you MUST enumerate and read the relevant research / reference material in the repo. Do not skip this because the answer feels obvious or because you think you know the tool.

## When this applies

- Drafting a spec, architecture doc, or spec map
- Choosing an external integration (GitHub Actions, SDKs, third-party APIs, CI/CD tools, Docker images)
- Picking a library or framework pattern
- Responding to "how should I approach X", "let's design Y", or "which tool should we use"

## What to do

1. **Enumerate candidate docs.** Sources depend on the project — check whichever of these exist:
   - `research/` (if present — used by intel-feed, Mothership, and other planning-heavy projects)
   - `docs/`, `docs/specs/`, `docs/plans/`
   - `references/` at the repo root **OR** `skills/*/references/` when working inside the agent-system itself (this repo's reference layout)
   - Project-level `CONTEXT.md`
   - Adjacent project's `CLAUDE.md` (for cross-project work)
2. **Read them** — not just filenames. If there are more than 5, read titles + opening paragraphs first, then full-read the ones that match the current problem.
3. **Cite what you read** in the proposal. Quote the key constraint or decision that shaped your approach.
4. **If no research / reference exists**, say so explicitly — don't wing it from training data.

## External-tool freshness check

Before proposing a specific GitHub Action, SDK version, API shape, or Docker image:

- Use Context7 MCP to look up current docs (per the Stack Preferences rule).
- Confirm the referenced tool's upstream repo is not archived (`gh repo view <owner>/<repo> --json isArchived`) and last commit is < 12 months old. Flag stale tools before proposing them.
- Confirm any referenced Docker images, action versions, or API endpoints actually resolve — not just that they "sound right."

## Why this rule exists

Two sessions in the week of 2026-04-14 → 2026-04-20 lost significant time to "design first, read later":

- **Mothership spec map** was drafted without reading the `research/` folder; required a full re-read and rework before useful progress.
- **APIsec scan integration** picked a stale GitHub Action with a private Docker image and a ghost hostname input because the reference docs weren't read upfront — blocked the entire tenant demo.

This rule exists to prevent that failure mode from recurring.
