---
name: validation-and-verification
description: Require evidence before any success claims. Use before claiming work is complete, fixed, passing, or ready — before committing, creating PRs, or moving to the next task. Also use when reviewing agent output, when about to express satisfaction with results, or when the user asks "does it work" or "is it done".
---

# Validation and Verification

Evidence before claims, always. Run the command that proves it before claiming it works.

## Process

### The Gate

Before any success claim:
1. **Identify**: What command proves this claim?
2. **Run**: Execute the full command fresh
3. **Read**: Full output, check exit code
4. **Verify**: Does the output confirm the claim?
5. **Only then**: Make the claim with evidence

## Validation — Does It Meet Requirements?

- Re-read the spec/plan/requirements
- Create a checklist of every requirement
- Verify each one against the actual implementation
- Report gaps or confirm completion with specific evidence

## Verification — Does It Actually Work?

| Claim | Requires | NOT Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Build succeeds | Build command: exit 0 | Linter passing |
| Bug fixed | Test original symptom: passes | "Code changed, should be fixed" |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows actual changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | "Tests pass" |

## What NOT to Do

- Do not use "should", "probably", "seems to" — run the verification
- Do not express satisfaction before verification ("Great!", "Done!")
- Do not trust agent success reports — verify independently
- Do not rely on partial verification (linter passing does not mean build works)
- Do not commit or create PRs without verification
- Do not skip verification because you're confident or tired
- Do not claim success with different words to avoid the rule — spirit over letter

## When to Apply

Before ANY of these:
- Claiming completion, success, or correctness
- Committing, pushing, creating PRs
- Moving to the next task
- Reporting to the user that something works
- Delegating based on assumed completion
