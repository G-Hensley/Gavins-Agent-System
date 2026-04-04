# Skill Chains — Named Workflows

Skills can be dispatched individually or composed into named chains for complex work. This document defines the common skill chains and their composition rules.

---

## 1. Full Feature Pipeline

**Use when:** Building a new feature or product from concept to shipped, tested, documented code.

**Skill Sequence:**
1. **brainstorming** — Explore the feature idea and converge on a direction
2. **product-management** — Create PRD, user stories, and acceptance criteria
3. **architecture** — Design the system, data model, and API contracts
4. **threat-modeling** — Assess security at the design stage (optional but recommended)
5. **writing-plans** — Break architecture into executable implementation tasks
6. **[implementation skills]** — Execute tasks using test-driven-development:
   - **test-driven-development** — Write test, verify red, implement, verify green, refactor
   - **backend-engineering** or **frontend-engineering** or **database-engineering** or **ai-engineering** — Build the feature
   - Repeat for each task
7. **code-review** — Request review after task completion
8. **refactoring** (if needed) — Clean up code structure before merge
9. **validation-and-verification** — Confirm all tests pass, requirements met, code works
10. **doc-writing** — Update README, API docs, architecture docs as needed

**Parallelism:**
- **brainstorming → product-management → architecture** — Must be sequential
- **architecture → threat-modeling** — Can happen in parallel if architects and security owner both review
- **threat-modeling → writing-plans** — Threat mitigations inform implementation tasks
- **Multiple architecture concerns** (e.g., backend + frontend + database design) — Can design in parallel after system boundaries are defined
- **Multiple implementation tasks** — Each task uses test-driven-development independently; multiple implementers can work on different tasks in parallel (use subagent-driven-development)
- **code-review → refactoring** — Sequential if review identifies structural issues; optional if code is clean
- **refactoring → validation-and-verification** — Sequential
- **validation-and-verification and doc-writing** — Can happen in parallel (docs don't block validation, validation doesn't block docs)

**Triggers:**
- User says: "I want to build a feature", "Let's add...", "How should we approach..."
- Brainstorming converges on a specific feature direction
- Product-level scope requires formal requirements

**Output:**
- Implementation complete, tested, documented
- Architecture documented in `docs/architecture/`
- Implementation plan in `docs/plans/`
- PRD in `docs/prd/`
- Feature code merged to main with full test coverage
- Updated README/API docs as appropriate

---

## 2. Implementation Cycle

**Use when:** Building a specific feature or fix once the design and plan exist.

**Skill Sequence:**
1. **writing-plans** — Start with a plan (or verify existing plan is clear)
2. **test-driven-development** — For each task:
   - Write failing test
   - Implement minimal code to pass
   - Refactor while green
   - Commit
3. **[implementation skills]** — Execute the implementation:
   - **backend-engineering** for backend
   - **frontend-engineering** for frontend
   - **database-engineering** for schema/queries
   - **ai-engineering** for AI/LLM features
   - **automation-engineering** for scripts/tooling
4. **code-review** — Request review after task or feature completion
5. **refactoring** — If reviewer identifies structural issues or tech debt
6. **validation-and-verification** — Confirm tests pass, requirements met, works as intended

**Parallelism:**
- **test-driven-development** is embedded in each **implementation skill** — not a separate dispatch
- **Multiple implementation tasks** — Can run in parallel if tasks don't depend on each other (use subagent-driven-development)
- **code-review + refactoring** — Sequential (review identifies issues, refactoring fixes them)
- **refactoring + validation-and-verification** — Sequential (validate after refactoring completes)

**Triggers:**
- Implementation plan exists and is ready for execution
- User says: "Build this", "Implement the plan", "Let's code"
- A design doc is available and reviewed

**Output:**
- Feature code, fully tested
- Passing test suite
- Clean code with no review blockers
- Commits following project conventions
- Ready to merge to main

---

## 3. Security Pipeline

**Use when:** Assessing security in a system design or code, or performing threat modeling before implementation.

**Skill Sequence:**
1. **threat-modeling** — Build threat model from architecture or requirements
   - Identify trust boundaries
   - Apply STRIDE to each boundary crossing
   - Assign severity to threats
   - Propose mitigations
2. **[implementation or refactoring]** — Implement mitigations identified in threat model
3. **security** (review) — Dispatch specialized security reviewers:
   - **backend-security-reviewer** — API, backend, database security
   - **frontend-security-reviewer** — DOM, XSS, CSRF, client-side risks
   - **cloud-security-reviewer** — IAM, infrastructure, cloud-native risks
   - **appsec-reviewer** — Auth, sessions, supply chain, dependency vulnerabilities

**Parallelism:**
- **threat-modeling → implementation** — Sequential (threats inform implementation)
- **Multiple security reviewers** — Can run in parallel after implementation completes (each reviews their domain)
- **threat-modeling + architecture-reviewer** — Can happen in parallel (reviewer checks design from different angle)

**Triggers:**
- Before major releases
- After significant architecture changes
- Before shipping features touching auth, payments, or user data
- User says: "Security review", "Threat assessment", "Is this secure?"

**Output:**
- Threat model document in `docs/architecture/`
- Mitigations identified with severity and owner
- Security review sign-off from each domain
- Code changes addressing all high/critical findings

---

## 4. DevOps Pipeline

**Use when:** Setting up or improving deployment infrastructure, CI/CD, or operational tooling.

**Skill Sequence:**
1. **devops** — Design infrastructure, Docker, CI/CD setup
2. **automation-engineering** — Build scripts, build pipelines, deployment automation
3. **qa-engineering** — Test infrastructure reliability, stress testing, failure scenarios
4. **validation-and-verification** — Confirm deployment works end-to-end

**Parallelism:**
- **devops → automation-engineering** — Sequential (design first, then build)
- **automation-engineering + qa-engineering** — Parallel: QA can build tests while automation builds scripts
- **Any of these + doc-writing** — Parallel (docs don't block infra work)

**Triggers:**
- Need to set up CI/CD pipeline
- Containerizing an application
- User says: "Set up deployment", "Create Docker setup", "Build a CI pipeline"

**Output:**
- Dockerfile or infrastructure-as-code (CloudFormation, Terraform)
- CI/CD pipeline configuration
- Deployment scripts
- Infrastructure tests
- Operational documentation

---

## 5. Documentation Pipeline

**Use when:** Creating or updating any project documentation.

**Skill Sequence:**
1. **[Any implementation, architecture, or design work completes]**
2. **doc-writing** — Identify doc type (README, ADR, API docs, runbook, changelog)
   - Read existing docs to follow conventions
   - Write concisely following appropriate template
   - Dispatch doc-reviewer agent for accuracy check
3. **[Optional] Revision** — Address reviewer feedback

**Parallelism:**
- **doc-writing** can start once the thing being documented is final (code merged, architecture approved, etc.)
- **doc-writing + implementation** — Can happen in parallel (documentation doesn't block code work)
- **Multiple doc-writers** — Can write different docs in parallel (README, API docs, architecture docs on the same system)

**Triggers:**
- After code merges to main
- After architecture is finalized
- After major features ship
- User says: "Document this", "Write a README", "Update the ADR"

**Output:**
- Updated project documentation
- Follows project conventions
- Accurate against current codebase

---

## How to Compose Chains

### At the Skill Level

When dispatching a single skill, the dispatcher (or user) provides context for what comes before and after:

```
You have the architecture from earlier. Now use writing-plans to break 
it into tasks. Then we'll use subagent-driven-development to execute.
```

### At the Conversation Level

The main conversation can invoke multiple chains sequentially:

1. Brainstorm feature
2. Product-management creates PRD
3. Architecture creates design
4. writing-plans creates tasks
5. subagent-driven-development executes (which uses test-driven-development + implementation skills internally)
6. code-review on completed work
7. doc-writing for final documentation

### Using Subagent-Driven Development

The `subagent-driven-development` skill orchestrates multi-agent work. When you invoke it with a plan, it:

1. Reads the implementation plan
2. Dispatches one implementer per task
3. Handles code-review after each task
4. Manages sequential dependencies between tasks
5. Tracks progress and collects artifacts

Internally, subagent-driven-development uses the **Implementation Cycle** chain for each task.

---

## Dependency Rules

**Hard sequential dependencies** (downstream needs upstream output):
- brainstorming → product-management → architecture → threat-modeling → writing-plans
- architecture → backend-engineering / frontend-engineering / database-engineering (can diverge and parallelize)
- writing-plans → [implementation]
- [implementation] → code-review → refactoring
- refactoring → validation-and-verification

**Safe to parallelize:**
- Multiple code-explorers (different aspects of codebase)
- backend-engineering ‖ frontend-engineering ‖ database-engineering (after architecture boundaries defined)
- Multiple implementation tasks (different tasks in same project)
- Multiple security reviewers (after threat modeling complete)
- doc-writing with any other work (orthogonal concern)

**Never parallelize:**
- Brainstorm with product-management (need brainstorm output)
- Product-management with architecture (need PRD first)
- Architecture with writing-plans (need design first)
- Implementation with code-review of the same code
- Designer with implementer writing UI (designer first, then implementer)

---

## Suggested Reading Order

For understanding the full system:

1. Read this file to understand chains exist and why
2. Read individual SKILL.md files (linked from chains) to understand each skill's process
3. Read agent definitions in `agents/` to see which agents load which skills
4. Refer back to CONTEXT.md or SYSTEM.md for orchestration patterns

For working with a specific chain:

1. Identify which chain fits your work
2. Follow the skill sequence
3. Use parallelism rules to optimize human time (multiple agents can work in parallel)
4. Pass output between skills using the patterns documented in each skill's "Hand Off" section
