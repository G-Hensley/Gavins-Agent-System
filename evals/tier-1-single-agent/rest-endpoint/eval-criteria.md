# Eval Criteria: REST Endpoint

## 1. Dispatch Correctness

- [ ] `backend-engineer` agent was dispatched (primary — owns Express APIs)
- [ ] `database-engineer` agent was dispatched for schema design and SQLite integration
- [ ] Agents were not skipped in favor of inline implementation for a task this size

**Fail condition:** Full API implemented in main thread without dispatching `backend-engineer`. Database schema designed without `database-engineer` involvement.

---

## 2. TDD Compliance

- [ ] Test file(s) created before route handlers were written
- [ ] Tests were run and confirmed failing before implementation
- [ ] Each route has at least one test covering the happy path
- [ ] Validation error cases (400) are covered by tests
- [ ] Not-found cases (404) are covered by tests
- [ ] Tests use an isolated test database — not the production `.db` file
- [ ] All tests pass with clean output

**Fail condition:** Tests written after route implementation. Tests share state with production database. Any test that passes immediately without a RED phase.

---

## 3. Output Quality

- [ ] All 5 routes exist and respond correctly
- [ ] `POST` with a missing or invalid `url` returns 400 with an error message
- [ ] `POST` with an empty `title` returns 400 with an error message
- [ ] `GET /api/bookmarks/:id` with a non-existent ID returns 404
- [ ] `DELETE /api/bookmarks/:id` with a non-existent ID returns 404
- [ ] Schema is created on startup — server starts cleanly on a fresh database
- [ ] Response bodies are consistent JSON (e.g., `{ "data": {...} }` or `{ "error": "..." }`)
- [ ] Test suite passes with zero failures

**Fail condition:** Any route returns 500 for a predictable error. Validation absent — malformed URL accepted. Database file must be pre-created manually before server starts.

---

## 4. Agent-Specific Rules (backend-engineer + database-engineer)

- [ ] Database access is separated from route handlers (repository or service pattern)
- [ ] No raw SQL string concatenation — parameterized queries only
- [ ] Schema migration (CREATE TABLE IF NOT EXISTS) runs at startup
- [ ] Input validation uses a library (Zod, Joi, express-validator) or explicit checks — not ad-hoc `if` chains on raw body fields
- [ ] HTTP status codes are semantically correct (201 for create, 204 for delete if no body, etc.)
- [ ] No hardcoded database file paths — configurable via env var

**Fail condition:** SQL injection possible via string concatenation. Database file path hardcoded with no env override. Route handler directly contains SQL queries with no separation layer.

---

## Scoring

| Category | Weight | Pass |
|---|---|---|
| Dispatch correctness | 25% | backend-engineer + database-engineer dispatched |
| TDD compliance | 25% | Tests written first, isolated test DB used |
| Output quality | 30% | All routes work, validation and 404 handling correct |
| Agent-specific rules | 20% | Parameterized queries, separation of concerns |

**Overall pass threshold: 80%**
