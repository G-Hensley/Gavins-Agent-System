---
name: qa-engineering
description: Test strategy, E2E testing, load testing, and test data management. Use when planning test strategy, writing E2E tests with Playwright, setting up load tests, managing test data, or analyzing test coverage. Also use when the user says "test strategy", "E2E test", "Playwright", "load test", "test coverage", "test plan", "regression testing", or "test data".
---

# QA Engineering

Plan and execute comprehensive testing beyond unit tests. Covers test strategy, E2E testing, load testing, and test data management.

Note: For unit-level TDD (red-green-refactor), use the `test-driven-development` skill. This skill handles the broader QA concerns.

## Process

### 1. Define Test Strategy
Read `references/test-strategy.md` to determine the right testing mix:
- What's the risk profile? (user-facing = more E2E, internal API = more integration)
- What's already tested? (don't duplicate unit test coverage)
- What's the test pyramid balance? (many unit, some integration, few E2E)

### 2. Write Tests
Based on the strategy:
- **E2E tests** → `references/e2e-testing.md` (Playwright patterns)
- **Load tests** → `references/load-testing.md` (performance and stress testing)
- **Test data** → `references/test-data.md` (factories, fixtures, seeding)

### 3. Analyze Coverage
Identify gaps: untested error paths, missing edge cases, uncovered integration points. Focus on behavior coverage (what scenarios are tested) not just line coverage.

### 4. Review
Dispatch the qa-reviewer agent (`qa-engineer` subagent) to check test quality, coverage gaps, and test reliability.

## What NOT to Do

- Do not test implementation details — test behavior (what the user sees/gets)
- Do not write flaky tests — use condition-based waiting, not arbitrary timeouts
- Do not skip error path testing — happy path alone is insufficient
- Do not duplicate unit test coverage in E2E — test at the right level
- Do not use production data in tests — use generated or anonymized test data
- Do not test everything E2E — it's slow and expensive. Use the test pyramid.

## Reference Files

- `references/test-strategy.md` — Test pyramid, risk-based testing, coverage analysis, regression strategy.
- `references/e2e-testing.md` — Playwright patterns, page objects, test isolation, CI integration.
- `references/load-testing.md` — Performance testing, stress testing, baseline establishment, bottleneck identification.
- `references/test-data.md` — Factories, fixtures, seeding, anonymization, test isolation.
- `qa-engineer` subagent (in `~/.claude/agents/`) — Subagent for reviewing test quality, coverage, and reliability.
