# Agent Handoff Protocols

Formal contracts for knowledge and artifact transfer between agents in the multi-agent system. Each handoff is producer → consumer, with defined expectations on both ends.

---

## Overview

When agents hand off work, the contract is now explicit:

- **What the producer MUST deliver** — specific artifact location, format, completeness checklist
- **What the consumer EXPECTS to find** — required sections, depth, quality signals
- **Where to find it** — canonical directory and filename pattern
- **How to verify handoff success** — checklist before consumer proceeds

---

## Handoff Matrix

| Producer | Artifact | Location | Consumers | Status |
|---|---|---|---|---|
| **product-manager** | PRD with requirements, user stories, acceptance criteria | `docs/prd/YYYY-MM-DD-<project>-prd.md` | architect, product-reviewer | Active |
| **architect** | Design doc with components, data model, API contracts, diagrams | `docs/architecture/YYYY-MM-DD-<topic>-design.md` | architecture-reviewer, threat-modeler, implementers | Active |
| **threat-modeler** | VAST threat model with boundaries, threats, mitigations | `docs/security/YYYY-MM-DD-<topic>-threat-model.md` | implementers, security-reviewers | Active |
| **writing-plans** | Implementation plan with tasks, order, dependencies, file structure | `docs/plans/YYYY-MM-DD-<project>-plan.md` | plan-reviewer, implementers | Active |
| **uiux-designer** | Design system with tokens, components, layout specs | `docs/design/design-system.md` | frontend-engineer | Active |
| **implementer** | Working code with passing tests, commits per task | `src/` (code + tests) | spec-reviewer, code-quality-reviewer | Active |
| **spec-reviewer** | Compliance report: requirement ID, status (pass/fail), feedback | (inline in PR/message) | implementer (iteration) | Active |
| **code-quality-reviewer** | Quality report: findings with severity, examples, remediation | (inline in PR/message) | implementer (iteration) | Active |
| **security-reviewers** | Security findings: threat, severity, CVSS, remediation steps | (inline in PR/message) | implementer (iteration) | Active |
| **doc-writer** | Project documentation: README, API docs, runbooks, CHANGELOG | `docs/`, `README.md`, project root | developers, users | Active |

---

## Detailed Handoff Contracts

### 1. Product Manager → Architect

**Producer: product-manager**  
**Consumer: architect**  
**Artifact: PRD (`docs/prd/YYYY-MM-DD-<project>-prd.md`)**

#### Product Manager MUST Include

- [ ] Problem statement (what, who, why in 2-3 sentences)
- [ ] Success metrics (measurable outcomes, not "improve X")
- [ ] User personas or roles with concrete goals
- [ ] Feature breakdown (MoSCoW: Must/Should/Could/Won't)
- [ ] User stories with acceptance criteria (Gherkin format)
- [ ] Out-of-scope statement (what IS NOT included)
- [ ] Known constraints (budget, timeline, dependencies)
- [ ] Non-functional requirements (performance, scalability, compliance targets)

#### Architect EXPECTS to Find

- Unambiguous feature list (no "nice to have" in Must Have column)
- Clear acceptance criteria per user story (testable conditions, not aspirations)
- Risk areas flagged (e.g., "integration point with legacy system" or "new vendor")
- No technical decisions in the PRD (e.g., "use Postgres" — that's architecture's job)

#### If Missing or Incomplete

Architect pauses and asks product-manager:
- Which Must Haves are actually critical? (Often everything is marked Must Have; force prioritization)
- What's the user's actual goal here? (Vague user stories = impossible acceptance criteria)
- Are there hidden constraints? (Budget, timeline, team size)

**Handoff Success**: Architect can write a design doc for each Must Have story without asking clarifying questions.

---

### 2. Architect → Implementation Team (Backend/Frontend/Database Engineers)

**Producer: architect**  
**Consumer: backend-engineer, frontend-engineer, database-engineer**  
**Artifact: Design Doc (`docs/architecture/YYYY-MM-DD-<topic>-design.md`)**

#### Architect MUST Include

- [ ] System decomposition: named components, responsibilities (one sentence each)
- [ ] Data model: entities, attributes, relationships, why this structure
- [ ] Data flow diagram: entry points, transformations, exit points (text or ASCII)
- [ ] API contracts: for every integration point
  - Endpoint/function name, method, path
  - Request body shape (with types)
  - Response shape (success + error states)
  - Authentication/authorization rules
- [ ] Technology decisions with rationale (why this choice, what alternatives were considered)
- [ ] Cross-cutting concerns: error handling, logging, validation, caching strategy
- [ ] Scalability notes: known limits, bottlenecks, migration path if exceeded
- [ ] File structure / directory layout for implementation

#### Engineers EXPECT to Find

- Clear component boundaries (no ambiguity about what code goes where)
- API contracts specific enough to code to (not "REST endpoint for users" — which fields, which validations)
- Data model that's already normalized / denormalized with reasoning
- Trade-offs documented (why denormalization, why caching, why not full text search)
- No implementation details (the architect doesn't prescribe the algorithm, just the interface)

#### If Missing or Incomplete

Engineers pause and ask architect:
- Can two components make conflicting assumptions about this API? (Contract too vague)
- Is this data model designed for the access patterns we need? (Need to trace through the plan)
- What happens when this number grows from 1,000 to 1M? (Need scalability notes)

**Handoff Success**: Backend/Frontend/Database engineers can build from this design without architectural decisions left unresolved. Plan-reviewer can create a concrete task breakdown from it.

---

### 3. Architect → Threat-Modeler

**Producer: architect**  
**Consumer: threat-modeler**  
**Artifact: Design Doc (same location as above)**

#### Architect MUST Include (for threat-modeler readability)

- [ ] System boundaries clearly marked (what's in scope, what's external)
- [ ] Data flows showing trust boundaries (especially where trust changes)
- [ ] External integrations listed (which APIs, which services, which networks)
- [ ] Authentication/authorization strategy described
- [ ] Sensitive data classification (what's PII, what's credentials, what's business data)

#### Threat-Modeler EXPECTS to Find

- Enough detail to map STRIDE threats at each component and flow
- Clear trust boundaries (threat-modeler identifies threats at boundary crossings)
- All entry points documented (APIs, webhooks, file uploads, user input forms)

#### If Missing or Incomplete

Threat-modeler pauses and asks architect:
- Can external service X call component Y directly, or does it go through component Z? (Trust boundary ambiguity)
- Which data fields are PII vs. business data vs. secrets? (Sensitivity classification needed)
- What happens if component A gets compromised? What can attacker access? (Blast radius unclear)

**Handoff Success**: Threat-modeler can produce a STRIDE analysis per component without requesting architectural clarification.

---

### 4. Threat-Modeler → Implementation Team

**Producer: threat-modeler**  
**Consumer: implementers (backend-engineer, frontend-engineer, database-engineer)**  
**Artifact: Threat Model (`docs/security/YYYY-MM-DD-<topic>-threat-model.md`)**

#### Threat-Modeler MUST Include

- [ ] System decomposition (copy from architect's doc, include data sensitivity)
- [ ] STRIDE threat list with IDs: THREAT-001, THREAT-002, etc.
- [ ] For each threat: category, component, description, severity, mitigations
- [ ] Priority-ordered mitigations (what blocks launch vs. incremental)
- [ ] Which mitigations are architectural (need architect to revise design) vs. implementation-level
- [ ] Existing mitigations from design vs. recommended new ones

#### Engineers EXPECT to Find

- Specific mitigations that can become implementation tasks (not vague advice)
- Severity score that guides priority (what's launch-blocking vs. acceptable risk)
- Clear separation of "architect must change design" vs. "implementer must add code"
- No implementation prescriptions (what library to use, which algorithm) — just "SQL injection possible here, must use parameterized queries"

#### If Missing or Incomplete

Implementer pauses and asks threat-modeler:
- Is this mitigation a design change or an implementation task? (Can't be blocked on architectural changes mid-sprint)
- What specific vulnerability are we mitigating? (Need to know what to test for)
- Is this a breaking change or backward-compatible? (Affects rollout strategy)

**Handoff Success**: Implementers can add threat mitigations to their task list without asking "but how do I actually fix this?"

---

### 5. Writing-Plans Agent → Plan-Reviewer → Implementers

**Producer: writing-plans**  
**Consumer: implementers (via plan-reviewer)**  
**Artifact: Implementation Plan (`docs/plans/YYYY-MM-DD-<project>-plan.md`)**

#### Writing-Plans MUST Include

- [ ] Task list with clear titles and descriptions
- [ ] For each task: acceptance criteria (testable), file structure, dependencies
- [ ] Order: which tasks must run sequentially, which can parallel
- [ ] Risk mitigation: known hard parts, testing strategy, rollback plan
- [ ] File changes: which files will be created/modified (helps spot conflicts)
- [ ] Testing approach: unit tests, integration tests, E2E tests per task

#### Plan-Reviewer EXPECTS to Find

- Tasks small enough to complete in one session (typically 2-4 hours work)
- Clear acceptance criteria that trace back to PRD (can verify against spec-reviewer)
- Dependencies documented (if task 3 depends on task 1, say so)
- No ambiguity: every task says "implement X" not "figure out how to do X"

#### Implementers EXPECT to Find

- Exact file paths where code should live (no "somewhere in src/")
- Clear entry/exit points (what functions/APIs to call, what they should return)
- Tests to write first (reference implementation doesn't exist, only test specs)
- Rollback strategy (if this task fails, here's how to undo)

#### If Missing or Incomplete

Implementer pauses and says NEEDS_CONTEXT:
- Can task 2 start before task 1 is done? (Dependencies unclear)
- Am I supposed to create a new module or modify existing code? (Scope ambiguity)
- What should this endpoint return if the input is invalid? (Acceptance criteria too vague)

**Handoff Success**: Each implementer can start on task N and complete it without asking for architectural guidance or re-scoping.

---

### 6. UI/UX Designer → Frontend-Engineer

**Producer: uiux-designer**  
**Consumer: frontend-engineer**  
**Artifact: Design System (`docs/design/design-system.md`)**

#### UI/UX Designer MUST Include

- [ ] Color palette: named colors (primary, secondary, success, error, etc.) with hex values
- [ ] Typography: font family, scale (sizes and weights), line height rules
- [ ] Spacing system: base unit (4px, 8px, etc.) and scale (tight, base, relaxed, spacious)
- [ ] Component specs: buttons, inputs, cards, modals, etc. with states (default, hover, active, disabled, focus, error)
- [ ] Layout guidelines: grid, responsive breakpoints, alignment rules
- [ ] Accessibility notes: color contrast ratios, focus indicators, heading hierarchy
- [ ] Figma link or design tokens as code (for reference)

#### Frontend-Engineer EXPECTS to Find

- Design tokens ready to use (either from Tailwind config or as CSS variables)
- Component states clearly shown (what does a disabled button look like?)
- Responsive behavior specified (how does this layout adapt from mobile to desktop?)
- Rationale for choices (why this color, why this spacing — not just the what)

#### If Missing or Incomplete

Frontend-engineer pauses and asks UI/UX:
- What's the hover state for this button? (States incomplete)
- Does this card wrap or scroll on mobile? (Responsive behavior unclear)
- What's the maximum width for body text? (Readability constraint missing)

**Handoff Success**: Frontend-engineer can build components that match the design system without asking "does this look right?"

---

### 7. Implementer → Spec-Reviewer

**Producer: implementer**  
**Consumer: spec-reviewer**  
**Artifact: Working Code + Tests (`src/`, passing test suite)**

#### Implementer MUST Include

- [ ] Code that passes all tests
- [ ] Test files covering acceptance criteria from task spec
- [ ] Commit message(s) describing what was built and why
- [ ] No unrelated changes (one logical commit per task)
- [ ] If modifying existing files: clear what changed and why

#### Spec-Reviewer EXPECTS to Find

- Tests that verify each acceptance criterion (not just happy path)
- Code that's clean and follows project patterns (no temporary hacks)
- Implementation of everything in the task description (no "we'll add that later")
- Tests passing before handoff (spec-reviewer reviews code, not fixing failing tests)

#### If Missing or Incomplete

Spec-reviewer rejects with FAIL:
- Missing acceptance criteria (PR claims task is done but tests don't verify it)
- Unclear which code implements which requirement (need comments)
- Breaking changes to existing APIs (need migration strategy documented)

**Handoff Success**: Spec-reviewer can check each acceptance criterion against the code without needing to re-run tests or ask clarifying questions.

---

### 8. Spec-Reviewer → Code-Quality-Reviewer (if spec passes)

**Producer: spec-reviewer (or implementer directly if no spec)**  
**Consumer: code-quality-reviewer**  
**Artifact: Same working code**

#### Spec-Reviewer Hands Off With

- [ ] PASS: Confirms all requirements met
- [ ] Summary of what was implemented
- [ ] Any quality notes that need attention

#### Code-Quality-Reviewer EXPECTS to Find

- Code that's functionally correct (spec-reviewer already verified this)
- Clean, maintainable code following project conventions
- No duplicate logic, magic numbers, or obvious improvements
- Error handling and edge cases covered

#### If Issues Found

Code-quality-reviewer provides feedback:
- Specific line or pattern to refactor
- Why it matters (maintainability, performance, readability)
- Example of the improved approach

**Handoff Success**: Implementer can iterate on feedback with clear, actionable direction.

---

### 9. Code-Quality-Reviewer → Security Reviewers

**Producer: code-quality-reviewer (or implementer if quality passes)**  
**Consumer: backend-security-reviewer, frontend-security-reviewer, cloud-security-reviewer, appsec-reviewer**  
**Artifact: Same working code**

#### Code-Quality-Reviewer Hands Off With

- [ ] PASS: Code is clean, maintainable, follows conventions
- [ ] Files and changes summary
- [ ] Any known complexity or risk areas

#### Security Reviewers EXPECT to Find

- Code that's already verified correct (spec-reviewer + code-quality already passed)
- Clear code paths to analyze (no obfuscation, reasonable naming)
- Security-relevant code clearly marked or documented
- Dependencies listed (requirements.txt, package.json, etc.)

#### If Vulnerabilities Found

Security reviewer provides:
- Specific threat or vulnerability
- Severity and exploitability assessment
- Concrete remediation (not vague advice)
- Reference (CVE, OWASP, internal policy, etc.)

**Handoff Success**: Implementer knows exactly what to fix to pass security review.

---

### 10. Implementer → Doc-Writer

**Producer: implementer**  
**Consumer: doc-writer**  
**Artifact: Working code, PRD, design docs, implementation notes**

#### Implementer Provides

- [ ] Link to source code (repo + branch)
- [ ] Link to design doc (from architect)
- [ ] Link to PRD (from product-manager)
- [ ] Implementation notes: what's non-obvious, what was a trade-off, what's left for later
- [ ] CLI commands or API endpoint examples
- [ ] Configuration or environment setup instructions

#### Doc-Writer EXPECTS to Find

- Clear code structure (can skim and understand)
- Design decisions documented in code or design doc (why this approach?)
- Working examples or test code to reference
- Known limitations or caveats

#### If Missing or Incomplete

Doc-writer pauses and asks implementer:
- Why does this function take 5 parameters? (Interface seems odd)
- Is this feature complete or is there a follow-up? (Need to mark as incomplete if so)
- What's the most important thing users need to know about this? (Helps prioritize docs)

**Handoff Success**: Doc-writer can produce accurate, complete documentation without needing deep code investigation.

---

## Handoff Checklist Template

Use this when handing off between agents:

```markdown
## Handoff from [PRODUCER] to [CONSUMER]

### Producer Checklist
- [ ] Artifact complete and in canonical location
- [ ] All required sections included (see protocol)
- [ ] No ambiguities or TODO items left
- [ ] Links to upstream artifacts (if applicable)
- [ ] Formatted consistently with project style

### Consumer Checklist (Before Starting)
- [ ] Artifact found in expected location
- [ ] All required sections present
- [ ] Can I proceed without asking clarifying questions?
- [ ] Are there conflicts with parallel work?
- [ ] Do I need to load any additional context?

### If Handoff Fails
Reason: [describe what's missing]
Blocking On: [who needs to act and what do they need to do]
Time to Unblock: [estimate for producer to complete missing work]
```

---

## Common Failures & Recovery

| Failure | Symptom | Recovery |
|---|---|---|
| **Incomplete PRD** | Architect can't design because requirements are vague | Product-manager adds missing acceptance criteria; architect waits |
| **Vague API contract** | Backend + frontend implement different interfaces | Architect clarifies contract; both implementers revert and re-implement |
| **Missing threat model** | Security issues found post-launch | Write threat model for v2; start next feature with threat-modeler |
| **Task too large** | Implementer reports BLOCKED mid-task | Plan-reviewer breaks task into subtasks; implementer starts next subtask |
| **Duplicate logic in code** | Code-quality-reviewer flags refactoring needed | Implementer extracts shared function; tests still pass |
| **Security vulnerability missed** | Security reviewer finds issue after code passes quality | Implementer fixes vulnerability; document why code-quality didn't catch it; improve quality checklist |

---

## Implementation Notes

- **Handoff artifacts live in `docs/` hierarchy** — version controlled, reviewed, searchable
- **Inline feedback (spec-review, code-quality, security) lives in PR/branch comments** — but summarized in commit messages
- **Directory structure must exist before handoff** — e.g., `docs/architecture/`, `docs/security/`, `docs/plans/` should be created when project starts
- **Filenames include timestamps** — `YYYY-MM-DD-<topic>` ensures chronological ordering and makes version history clear
- **Every handoff is a checkpoint** — if upstream work is incomplete, downstream agent says NEEDS_CONTEXT and pauses (rather than guessing)

---

## Diagram: Agent Handoff Flow

```
product-manager
    ↓ (PRD)
product-reviewer
    ↓ (approved PRD)
architect
    ├→ architecture-reviewer (parallel review)
    ├→ threat-modeler (parallel analysis)
    └→ writing-plans → plan-reviewer
         ↓ (approved plan)
      implementer(s)
         ↓ (working code + tests)
      spec-reviewer
         ↓ (approved spec)
      code-quality-reviewer
         ↓ (approved quality)
      security-reviewers (parallel)
         ↓ (approved security)
      doc-writer
         ↓
      Final artifact (merged + documented)
```

Each arrow is a handoff point. Each parallel reviewer can start immediately after their input is available. No downstream agent blocks waiting for upstream work.
