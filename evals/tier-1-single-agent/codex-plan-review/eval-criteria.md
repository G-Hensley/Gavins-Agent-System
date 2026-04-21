# Codex Plan Review Eval Criteria

## Fixtures and expected behavior

| Fixture | Expected triggers | Expected action |
|---|---|---|
| 01-auth-trigger.md | Auth / authorization / session, Infrastructure changes | Fire review, construct prompt |
| 02-schema-trigger.md | Database schema changes, Data migrations / backfills | Fire review, construct prompt |
| 03-api-contract-trigger.md | API contract changes | Fire review, construct prompt |
| 04-infra-trigger.md | Infrastructure changes | Fire review, construct prompt |
| 05-data-migration-trigger.md | Data migrations / backfills | Fire review, construct prompt |
| 06-irreversible-oneshot-trigger.md | Irreversible one-shots | Fire review, construct prompt |
| 07-no-trigger-readme-edit.md | — | Exit silently, do not fire |
| 08-no-trigger-refactor.md | — | Exit silently, do not fire |

## Pass bar

- All 6 positive fixtures correctly fire the review AND cite every expected trigger for that fixture (partial matches do not pass — a skill that short-circuits after the first match is a regression).
- Both negatives correctly exit without firing.
- For positives, the constructed prompt contains: plan text, six-section checklist, adversarial framing.
- No fixture causes a false attempt to execute Codex (this eval is detection-only).

## Fail modes to watch for

- False negative on a positive fixture (most dangerous — the whole point of the skill is not to miss these).
- False positive on a negative (annoying but recoverable).
- Skill attempts to execute `codex-companion.mjs` during the eval (the eval is detection-only).
- Constructed prompt is freestyle instead of the structured checklist.
- Partial trigger detection on a multi-trigger fixture (e.g., fires on auth but misses the infra co-trigger). The review still happens, but the skill isn't reading the full trigger surface.
