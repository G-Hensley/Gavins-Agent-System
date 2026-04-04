---
name: test-driven-development
description: Enforce red-green-refactor cycle for all implementation work. Use when implementing any feature, bugfix, refactoring, or behavior change — before writing any production code. Also use when the user mentions TDD, testing strategy, or asks to add tests.
---

# Test-Driven Development

Write the test first. Watch it fail. Write minimal code to pass. Refactor.

**If you didn't watch the test fail, you don't know if it tests the right thing.**

## Process

### The Cycle

Use always for: new features, bug fixes, refactoring, behavior changes.

Exceptions (confirm with user first): throwaway prototypes, generated code, config files.

### RED — Write one failing test

- One behavior per test, clear name describing that behavior
- Test real code, not mocks (mocks only when unavoidable — see `references/testing-anti-patterns.md`)
- Run the test. Confirm it **fails for the right reason** (missing feature, not typos/errors)
- If the test passes immediately, you're testing existing behavior — rewrite the test

### GREEN — Write minimal code to pass

- Simplest implementation that makes the test green
- Do not add features, options, or abstractions beyond what the test requires
- Run the test. Confirm it passes. Confirm all other tests still pass.
- If the test fails, fix the code — not the test

### REFACTOR — Clean up while green

- Remove duplication, improve names, extract helpers
- Run tests after each change — stay green
- Do not add new behavior during refactor

### Repeat with the next behavior.

## What NOT to Do

- Do not write production code before its test exists and has failed
- Do not keep code written before tests as "reference" — delete it, implement fresh from tests
- Do not write tests after implementation and call it TDD — tests-after verify what you built, tests-first verify what's required
- Do not skip the verify-fail step — a test you never saw fail might test nothing
- Do not add test-only methods to production classes — put test utilities in test files
- Do not mock without understanding what the test depends on — see `references/testing-anti-patterns.md`

## Bug Fixes

Write a failing test that reproduces the bug first. Then fix it. The test proves the fix works and prevents regression.

## When Stuck

| Problem | Solution |
|---------|----------|
| Don't know how to test | Write the API you wish existed. Assert on that. |
| Test too complicated | Design too complicated — simplify the interface |
| Must mock everything | Code too coupled — use dependency injection |
| Test setup is huge | Extract helpers. Still complex? Simplify design. |

## Verification Checklist

Before marking work complete:
- [ ] Every new function/method has a test
- [ ] Watched each test fail before implementing
- [ ] Each test failed for the expected reason
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass with clean output
- [ ] Edge cases and error paths covered

## Reference Files

- `references/testing-anti-patterns.md` — Mock pitfalls, test-only production methods, incomplete mocks. Read when adding mocks or test utilities.
