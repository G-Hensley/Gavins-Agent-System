# Eval Criteria: Full-Stack Task Manager App

Score each item: **pass** / **fail** / **partial** / **n/a**

A passing run requires all required items to pass and no more than two partials. Any fail on a security item is an automatic overall fail.

---

## Stage 1 — Brainstorm

- [ ] `brainstorming` skill was used before any planning began
- [ ] Output identifies at least 5 meaningful open questions or edge cases
- [ ] Scope boundaries are explicitly defined (what is in MVP vs. out)

---

## Stage 2 — Product Requirements (product-manager agent)

- [ ] PRD document produced and written to the working directory
- [ ] PRD contains user stories with acceptance criteria
- [ ] User roles (`admin` / `member`) are defined with explicit permission boundaries
- [ ] MVP feature set is distinguished from future scope
- [ ] PRD references the brainstorm output

---

## Stage 3 — Architecture (architect agent)

- [ ] Architecture Decision Record (ADR) produced
- [ ] DynamoDB single-table design with named access patterns documented
- [ ] Auth flow (Cognito) described end-to-end
- [ ] API surface defined (routes, methods, auth requirements)
- [ ] Deployment topology described (Lambda, Next.js hosting, Cognito User Pool, DynamoDB table)
- [ ] Component boundaries are clear — frontend / API / storage layers separated

---

## Stage 4 — Threat Model (threat-modeler agent)

- [ ] Threat model document produced
- [ ] Auth bypass threats identified and mitigated
- [ ] Privilege escalation threats identified and mitigated (admin/member boundary)
- [ ] Data exposure threats identified and mitigated (e.g., users reading others' tasks)
- [ ] Injection threats identified (NoSQL injection, input sanitization)
- [ ] Rate limiting gaps called out
- [ ] Each threat has a stated mitigation or accepted risk with rationale

---

## Stage 5 — Implementation Plan

- [ ] Implementation plan produced from PRD + ADR
- [ ] Work broken into independently testable units
- [ ] Each unit has a clear scope boundary (what it does and does not include)
- [ ] Units ordered to respect dependencies (auth before task endpoints, schema before queries)

---

## Stage 6 — Spec Review (spec-reviewer agent)

- [ ] `spec-reviewer` agent dispatched against the implementation plan
- [ ] Review explicitly references the PRD acceptance criteria
- [ ] Any gaps between plan and PRD are logged
- [ ] Gaps are resolved or explicitly accepted before implementation begins
- [ ] Sign-off documented before Stage 7 starts

---

## Stage 7 — Implementation (implementer agents)

- [ ] Separate `implementer` agent dispatched per implementation unit
- [ ] Each implementer writes the test first (RED step documented)
- [ ] Each implementer confirms the test fails before implementing (failure output shown)
- [ ] Each implementer implements the minimal code to pass the test
- [ ] Each implementer confirms all tests pass (GREEN step documented)
- [ ] Auth is implemented before task endpoints (dependency ordering respected)
- [ ] DynamoDB access layer is implemented and tested in isolation
- [ ] Input validation present on every API route
- [ ] Role enforcement tested: admin-only actions blocked for members
- [ ] Cognito JWT verification present on all protected routes
- [ ] No hardcoded values — environment variables used throughout
- [ ] No dead code, no commented-out blocks

---

## Stage 8 — Code Quality Review (code-quality-reviewer agent)

- [ ] `code-quality-reviewer` agent dispatched across all implemented code
- [ ] Review covers naming conventions, file size, DRY, YAGNI
- [ ] All raised issues addressed before security review begins
- [ ] Re-review performed after fixes (or reviewer signs off that changes are acceptable)

---

## Stage 9 — Security Review (all four reviewers)

All four reviewers must be dispatched. A single unaddressed finding in any category is an overall fail.

### Frontend Security (frontend-security-reviewer)
- [ ] Reviewer dispatched
- [ ] XSS vectors identified and mitigated
- [ ] CSP headers present or absence is justified
- [ ] No sensitive data (tokens, user data) stored in localStorage without encryption
- [ ] Auth state not exposed to untrusted client-side code
- [ ] All findings addressed

### Backend Security (backend-security-reviewer)
- [ ] Reviewer dispatched
- [ ] All inputs validated at API boundary (Zod)
- [ ] Error responses do not leak stack traces or internal state
- [ ] Auth token verification happens on every protected route (not just some)
- [ ] Role check happens server-side, not client-side
- [ ] No string-concatenated queries or commands
- [ ] All findings addressed

### Cloud Security (cloud-security-reviewer)
- [ ] Reviewer dispatched
- [ ] IAM policies are least-privilege — no wildcard actions or resources
- [ ] DynamoDB permissions scoped to specific table and required actions only
- [ ] Cognito User Pool has MFA option and secure password policy
- [ ] No credentials in environment variable definitions or IaC templates
- [ ] Secrets Manager or Parameter Store used for any secrets (not env vars in code)
- [ ] All findings addressed

### AppSec Review (appsec-reviewer)
- [ ] Reviewer dispatched
- [ ] End-to-end auth flow reviewed (token issuance → API verification → role enforcement)
- [ ] Threat model coverage verified — each threat has corresponding code-level mitigation
- [ ] Privilege escalation path tested (member attempting admin action returns 403)
- [ ] Data isolation verified (user A cannot access user B's tasks)
- [ ] All findings addressed

---

## Stage 10 — Documentation (doc-writer agent)

- [ ] `doc-writer` agent dispatched
- [ ] README produced with: setup steps, required environment variables, how to run locally, how to run tests
- [ ] API reference produced: each endpoint documented with method, path, auth requirement, request shape, response shape, error codes
- [ ] Architecture overview produced: prose summary of the ADR suitable for a new team member
- [ ] Documentation matches the implemented code (no stale references)

---

## Overall Pass/Fail

| Category | Weight | Result |
|---|---|---|
| Brainstorm | Required | |
| Product Requirements | Required | |
| Architecture | Required | |
| Threat Model | Required | |
| Implementation Plan | Required | |
| Spec Review | Required | |
| TDD by implementers | Required | |
| Code Quality Review | Required | |
| Frontend Security | **Blocking** | |
| Backend Security | **Blocking** | |
| Cloud Security | **Blocking** | |
| AppSec Review | **Blocking** | |
| Documentation | Required | |

**Final result:** pass / fail / partial

**Notes:**
