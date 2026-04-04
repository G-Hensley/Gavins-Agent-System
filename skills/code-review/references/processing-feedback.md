# Processing Code Review Feedback

## Response Pattern

1. **Read** complete feedback without reacting
2. **Understand** — restate the requirement in your own words
3. **Verify** — check against codebase reality
4. **Evaluate** — technically sound for THIS codebase?
5. **Respond** — technical acknowledgment or reasoned pushback
6. **Implement** — one item at a time, test each

## When to Push Back

- Suggestion breaks existing functionality
- Reviewer lacks full context
- Feature isn't used (YAGNI)
- Technically incorrect for this stack
- Conflicts with user's architectural decisions

## Acknowledging Correct Feedback

```
GOOD: "Fixed. [brief description]"
GOOD: [just fix it and show in the code]

BAD: "You're absolutely right!"
BAD: "Thanks for catching that!"
```

## Implementation Order

1. Clarify anything unclear first
2. Blocking issues (breaks, security)
3. Simple fixes (typos, imports)
4. Complex fixes (refactoring, logic)
5. Test each fix individually
