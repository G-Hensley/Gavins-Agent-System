# Eval Criteria: CLI Calculator

## 1. Dispatch Correctness

- [ ] `automation-engineer` agent was dispatched (primary — owns CLI tools and scripts)
- [ ] `qa-engineer` agent was dispatched or TDD cycle was followed in-thread
- [ ] `doc-writer` agent was dispatched for the README (or README was produced inline)
- [ ] No specialist agent was skipped without justification

**Fail condition:** Main thread implemented the full tool without dispatching any agents, OR the wrong agent (e.g., `backend-engineer`) was dispatched for a pure CLI script.

---

## 2. TDD Compliance

- [ ] Test file was created before `calc.py` was written
- [ ] Tests were run and confirmed failing before implementation
- [ ] Each test failure was for the expected reason (missing function, not import error)
- [ ] Implementation written to make tests pass — not the other way around
- [ ] All tests pass with clean output after implementation

**Fail condition:** Implementation written first and tests added afterward. Any "tests pass immediately on first run" without a documented RED phase.

---

## 3. Output Quality

- [ ] Tool is runnable: `python calc.py 10 / 2` returns `5.0`
- [ ] All four operators work: `+`, `-`, `*`, `/`
- [ ] Division by zero returns a clear error message to stderr
- [ ] Division by zero exits with a non-zero exit code (e.g., `sys.exit(1)`)
- [ ] `--json` flag outputs valid JSON: `{"result": 5.0}` or similar
- [ ] `--help` output is present and readable
- [ ] pytest suite passes with zero failures

**Fail condition:** Division by zero crashes with an unhandled exception. `--json` flag missing or outputs malformed JSON. Tests fail.

---

## 4. Agent-Specific Rules (automation-engineer)

- [ ] argparse is used — not manual `sys.argv` parsing
- [ ] No hardcoded values (paths, credentials, magic numbers)
- [ ] Exit codes are explicit: `0` for success, non-zero for errors
- [ ] Error messages go to stderr, not stdout
- [ ] Concerns are separated: parsing, calculation logic, and output formatting are distinct functions or modules
- [ ] No dead code — no unused imports or commented-out blocks
- [ ] File naming follows kebab-case convention where applicable

**Fail condition:** `sys.argv` used instead of argparse. Errors printed to stdout and exit code is always 0. All logic in one monolithic function with no separation of concerns.

---

## Scoring

| Category | Weight | Pass |
|---|---|---|
| Dispatch correctness | 25% | All primary agents dispatched |
| TDD compliance | 25% | RED phase documented, tests written first |
| Output quality | 30% | All features work, tests green |
| Agent-specific rules | 20% | Separation of concerns, correct exit codes |

**Overall pass threshold: 80%**
