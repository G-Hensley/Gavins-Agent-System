---
name: systematic-debugging
description: Systematic root-cause debugging process. Use when encountering any bug, test failure, unexpected behavior, performance problem, or build failure — before proposing fixes. Also use when a previous fix didn't work, when under time pressure, or when the issue seems "simple" but persists.
---

# Systematic Debugging

Find root cause before attempting fixes. Random fixes waste time and create new bugs.

**Do not propose fixes until you've completed Phase 1.**

## Process

### The Four Phases

### Phase 1: Root Cause Investigation

1. **Read error messages completely** — stack traces, line numbers, error codes. They often contain the answer.
2. **Reproduce consistently** — exact steps, every time. If not reproducible, gather more data — do not guess.
3. **Check recent changes** — git diff, recent commits, new dependencies, config changes, environmental differences.
4. **Gather evidence at component boundaries** — for multi-component systems (API → service → database, CI → build → deploy), log what enters and exits each layer. Run once to find WHERE it breaks before investigating WHY.
5. **Trace data flow** — for bugs deep in the call stack, trace backward to find the original trigger. See `references/root-cause-tracing.md` for the full technique.

### Phase 2: Pattern Analysis

1. Find working examples of similar code in the same codebase
2. Compare working vs. broken — list every difference, however small
3. Read reference implementations completely (don't skim)
4. Understand dependencies, config, and assumptions

### Phase 3: Hypothesis and Testing

1. Form a single, specific hypothesis: "X is the root cause because Y"
2. Make the smallest possible change to test it — one variable at a time
3. Did it work? → Phase 4. Didn't work? → new hypothesis. Do not stack fixes.

### Phase 4: Implementation

1. Write a failing test that reproduces the bug (use `test-driven-development` skill)
2. Implement a single fix addressing the root cause — no "while I'm here" changes
3. Verify: test passes, no other tests broken, issue resolved
4. **If 3+ fixes have failed:** stop fixing. This is likely an architectural problem, not a code bug. Discuss fundamentals with the user before attempting more fixes.

## What NOT to Do

- Do not propose fixes before completing Phase 1
- Do not attempt multiple fixes at once — can't isolate what worked
- Do not treat symptoms instead of root causes
- Do not skip reproduction — "it's probably X" is not investigation
- Do not keep trying fixes after 3 failures — question the architecture instead
- Do not skim reference implementations — partial understanding guarantees bugs

## When Investigation Reveals No Root Cause

If the issue is truly environmental, timing-dependent, or external:
1. Document what was investigated
2. Implement handling (retry, timeout, error message)
3. Add monitoring/logging for future investigation

95% of "no root cause" conclusions come from incomplete investigation.

## Reference Files

- `references/root-cause-tracing.md` — Trace bugs backward through call stack to the original trigger. Use during Phase 1 Step 5.
- `references/defense-in-depth.md` — Add validation at multiple layers after finding root cause. Use during Phase 4 to make bugs structurally impossible.
- `references/condition-based-waiting.md` — Replace arbitrary timeouts with condition polling. Use when debugging flaky/timing-dependent tests.
