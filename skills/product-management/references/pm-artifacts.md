# Product Management Artifacts

Reference for creating PM documentation. Read when writing the PRD (Step 6) or when the user needs specific PM deliverables.

## PRD Template

```markdown
# [Product Name] — Product Requirements Document

## Problem Statement
[One paragraph: what problem, who has it, why it matters]

## Target Users
[Who uses this, what are their goals, what's their context]

## Success Metrics
[How we know this worked — quantitative where possible]
- Metric 1: [measurable outcome]
- Metric 2: [measurable outcome]

## Scope
**In scope:** [what this covers]
**Out of scope:** [what this explicitly does NOT cover]

## Features
### Must Have
- [Feature]: [one-line description]
### Should Have
- [Feature]: [one-line description]
### Could Have
- [Feature]: [one-line description]
### Won't Have (this iteration)
- [Feature]: [why deferred]

## User Stories
[See user story format below]

## User Flows
[See user flow format below]

## Open Questions
- [Unresolved question]
```

## User Story Format

```
As a [user type], I want to [action] so that [outcome].

Acceptance Criteria:
- [ ] Given [context], when [action], then [result]
- [ ] Given [context], when [action], then [result]
- [ ] Given [edge case], when [action], then [result]
```

Keep stories small enough to implement in one plan cycle. If a story has more than 5 acceptance criteria, split it.

## User Flow Format

Map step-by-step journeys for key workflows:

```
1. User lands on [entry point]
2. User sees [what's displayed]
3. User [action] → System [response]
4. IF [condition]:
   a. [path A]
   b. [path B — error/edge case]
5. User [next action]
6. System [final response]
```

Note at each step: what the user sees, what they can do, what errors can occur, what the system does behind the scenes.

## Feature Prioritization — MoSCoW

| Priority | Meaning | Guideline |
|----------|---------|-----------|
| **Must** | Product doesn't work without it | Core value proposition — no launch without these |
| **Should** | Important but not blocking | High value, plan for v1 but can slip to v1.1 |
| **Could** | Nice to have | Build if time allows, cut first when scope tightens |
| **Won't** | Explicitly deferred | Document WHY deferred so it's not re-discussed |

Force trade-offs: if everything is "Must Have", nothing is prioritized.

## Impact/Effort Matrix

For comparing features when MoSCoW isn't granular enough:

```
         High Impact
              │
  Quick Wins  │  Big Bets
  (do first)  │  (plan carefully)
──────────────┼──────────────
  Fill-ins    │  Money Pits
  (do if idle)│  (avoid)
              │
         Low Impact

  Low Effort ←──→ High Effort
```

## Competitive / Alternative Analysis

When the user needs to justify approach vs alternatives:

```
| Criteria        | Our Approach | Alternative A | Alternative B |
|-----------------|-------------|---------------|---------------|
| [criterion 1]   | [rating]    | [rating]      | [rating]      |
| [criterion 2]   | [rating]    | [rating]      | [rating]      |
| Effort          | [estimate]  | [estimate]    | [estimate]    |
| Risk            | [level]     | [level]       | [level]       |
```
