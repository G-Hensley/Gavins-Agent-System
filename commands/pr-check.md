Run the `pr-check` skill against the active PR.

Full cycle:

1. **Detect PR** from current branch (or use passed `$0` if provided)
2. **Fetch** inline + review-level comments, CI check status, merge state, Dependabot alerts
3. **Triage** each comment — FIX / SKIP-STALE / DEFER / ASK-USER (stale-detection verifies the problem still reproduces at the cited line before fixing)
4. **Fix** in thematic clusters (one commit per theme, not one mega-commit)
5. **Verify** each cluster with the appropriate gate (tests, lints, `validate.sh`, hook simulation) before committing
6. **Commit + push** per theme
7. **Retrigger** Copilot review (best-effort `gh api` call)
8. **Report** — fixed / skipped-stale / deferred / awaiting-user / CI status / merge state

Stops early if any check run is failing or any comment needs user input.

Full process: `skills/pr-check/SKILL.md`.
