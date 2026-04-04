# Test Strategy

## Test Pyramid
```
     /  E2E  \        Few: critical user journeys
    / Integr. \       Some: API contracts, cross-component
   /   Unit    \      Many: business logic, utilities, pure functions
```

- **Unit**: fast, isolated, test one thing. Bulk of your tests.
- **Integration**: test component boundaries (API → service → DB). Moderate count.
- **E2E**: test full user journeys through UI. Few, focused on critical paths.

## Risk-Based Testing
Focus testing effort on highest-risk areas:

| Risk Factor | Testing Approach |
|---|---|
| User-facing feature | More E2E, visual regression |
| Payment/financial | Integration + E2E + edge cases |
| Auth/security | Unit + integration + security-specific |
| Data processing | Unit with edge cases + integration |
| Internal tooling | Unit + manual smoke test |

## Coverage Strategy
Line coverage is a proxy, not a goal. Focus on:
- **Behavior coverage**: are all user scenarios tested?
- **Error path coverage**: what happens when things fail?
- **Edge case coverage**: empty inputs, boundaries, concurrency?
- **Integration coverage**: do components work together?

Aim for: 80%+ line coverage as a floor, but measure behavior coverage manually.

## Regression Strategy
- Every bug fix gets a regression test (TDD skill handles this)
- Run full suite on every PR
- Run E2E on every merge to main
- Run load tests before major releases
- Maintain a "smoke test" suite for quick post-deploy verification

## When to Add Tests
- New feature → unit + integration + E2E for critical path
- Bug fix → regression test proving the fix (TDD skill)
- Refactoring → verify existing tests still pass, add missing ones
- Performance issue → load test establishing baseline + improvement
