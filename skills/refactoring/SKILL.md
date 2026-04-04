---
name: refactoring
description: Systematic approach to refactoring code — identify smells, plan changes, execute safely, verify behavior preserved. Use when improving code structure, reducing complexity, extracting modules, consolidating duplicated logic, or cleaning up technical debt. Also use when the user says "refactor", "clean this up", "simplify", "extract", "consolidate", "technical debt", or "code smells".
---

# Refactoring

Improve code structure without changing behavior. Every refactoring preserves existing tests — if tests break, the refactoring introduced a bug.

## Process

### 1. Identify What to Refactor
Read `references/code-smells.md` to identify problems:
- Duplicated logic across files
- Functions/files doing too much (>200 lines)
- Deep nesting or complex conditionals
- Unclear naming that requires reading implementation to understand
- Tight coupling between modules that should be independent

### 2. Verify Test Coverage
Before changing anything, run the full test suite and confirm it passes. If there's no test coverage for the code being refactored, write tests FIRST (use TDD skill) to establish a behavioral baseline.

### 3. Plan the Refactoring
Decide which refactoring pattern to apply (see `references/refactoring-patterns.md`). Plan small, incremental steps — each step should be committable and all tests should pass after each step.

### 4. Execute in Small Steps
For each step:
1. Make one structural change (extract, rename, move, inline)
2. Run tests — they must all pass
3. Commit with a descriptive message
4. Repeat

Do NOT combine multiple refactoring steps into one commit.

### 5. Verify
Run the full test suite after all refactoring is complete. Compare behavior — the system should work identically to before.

## What NOT to Do

- Do not refactor without test coverage — write tests first
- Do not change behavior during refactoring — that's a feature change, not a refactoring
- Do not make large changes in one step — small increments with tests passing between each
- Do not refactor code you're not working on — stay focused on the task at hand
- Do not refactor and add features in the same commit — separate concerns
- Do not skip the verification step — run the full suite at the end

## Reference Files

- `references/code-smells.md` — How to identify code that needs refactoring. Read during Step 1.
- `references/refactoring-patterns.md` — Common refactoring patterns with before/after examples. Read during Step 3.
