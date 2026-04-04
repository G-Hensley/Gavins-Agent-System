---
name: code-review
description: Complete code review workflow — requesting reviews, processing feedback, and acting on results. Use when completing tasks, implementing features, before merging, when receiving feedback, or when stuck and wanting a fresh perspective. Also use when the user says "review this", "code review", "check my work", or when processing review comments.
---

# Code Review

Two phases: requesting a review, then processing the feedback. Both phases can be used independently.

## Process

### Phase 1: Request a Review

Use when work is ready for review. See `references/requesting-review.md`.

**When to request:**
- After each task in subagent-driven development
- After completing a major feature
- Before merging to main
- When stuck and wanting a fresh perspective

### Phase 2: Process Feedback

Use when review feedback arrives. See `references/processing-feedback.md`.

**How to process:**
1. Read complete feedback without reacting
2. Verify each item against codebase reality
3. Fix or push back with technical reasoning
4. Test each fix individually

## What NOT to Do

- Do not skip review because "it's simple"
- Do not ignore Critical issues or proceed with unfixed Important issues
- Do not say "You're absolutely right!" or "Great point!" — performative agreement
- Do not implement before verifying against the codebase
- Do not implement partial feedback — clarify ALL unclear items first
- Do not avoid pushing back when feedback is wrong — technical correctness over social comfort

## Reference Files

- `references/requesting-review.md` — How to dispatch a reviewer subagent with correct context and act on severity levels. Read when work is ready for review.
- `references/processing-feedback.md` — How to evaluate, verify, push back on, and implement review feedback. Read when feedback arrives from any source.
