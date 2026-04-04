# Failure Modes & Escalation Paths

When multi-agent workflows encounter problems, this document defines the escalation path, decision criteria, and resolution steps. Each scenario identifies who decides, what information is required, and what happens next.

---

## Quick Reference Table

| Failure Mode | Trigger | Decision Maker | Escalate To | Resolution |
|---|---|---|---|---|
| **BLOCKED** | Implementer can't proceed | Orchestrator | Upstream agent or user | Blocker removed, retry |
| **Spec Rejection (3+)** | Repeated compliance failures | Orchestrator | User | Spec revision, implementer assistance, or deviation acceptance |
| **Design Conflict** | Architecture contradicts codebase | architecture-reviewer | User | Revised architecture with migration notes |
| **Security Critical** | High/Critical issue mid-implementation | security reviewer | Orchestrator | HALT, implementer fixes, re-review before merge |
| **Out-of-Scope Task** | Agent receives incompatible work | Agent | Orchestrator | Reroute to correct agent |
| **Circular Review** | Same issue bounces 2+ cycles | spec-reviewer | User | User judgment call |
| **No Output** | Agent completes but returns empty | Orchestrator | User (first retry with tighter brief) | Log improvement, assess skill gap |

---

## 1. Implementer Reports BLOCKED

**Symptom**: Implementer stops work and reports one of:
- Missing context (unclear requirement, no architecture doc)
- Conflicting requirements (spec says X, architecture says Y)
- External dependency unavailable (service down, third-party API offline)
- Architectural gap (task requires design decision not in architecture)

**Diagnosis**:
1. Read the implementer's BLOCKED report — they should have stated the specific blocker, not just "unclear"
2. Identify which upstream phase produced the blocker:
   - Missing or ambiguous spec → escalate to product-manager
   - Design gap or contradiction → escalate to architect
   - External dependency → escalate to user (they own external systems)

**Escalation Path**:
1. Orchestrator routes blocker report to appropriate upstream agent
2. Upstream agent consumes the blocker and produces a fix (revised spec, new architecture section, etc.)
3. Implementer retries with updated context
4. If retries exceed 2, escalate to user — may indicate systemic issue (bad handoff, incomplete spec)

**Resolution**:
- Implementer reports BLOCKED with specific blocker
- Upstream agent produces artifact addressing blocker
- Implementer resumes and completes task

---

## 2. Spec-Reviewer Rejects Implementation (3+ times)

**Symptom**: Spec-reviewer reports issues found. Implementer fixes. Spec-reviewer finds issues again. Cycle repeats after 3+ rounds without convergence.

**Diagnosis**:
1. Collect all rejection reports from spec-reviewer — what changed between attempts?
2. Identify pattern:
   - **Misunderstanding**: Implementer and spec-reviewer interpret requirements differently (e.g., "must handle X" → implementer handles X, reviewer expected X + Y)
   - **Ambiguous spec**: Spec itself is unclear and multiple interpretations are valid
   - **Scope creep**: Spec changed mid-review, implementer can't keep up
   - **Implementer skill gap**: Task is beyond implementer's capability for this domain

**Escalation Path**:
1. After 3rd rejection, spec-reviewer flags "convergence failure" and stops iterating
2. Orchestrator logs pattern and escalates to user
3. User decides one of:
   - **Clarify spec**: Provide a revised, unambiguous spec and restart from implementer
   - **Assist implementer**: User provides implementation guidance or code review to help implementer understand intent
   - **Accept deviation**: Acknowledge that perfect spec compliance is impossible and decide which deviations to accept
   - **Change implementer**: Swap in a different implementer agent or human developer

**Resolution**:
- User makes judgment call and commits decision
- Work resumes under new guidance
- Track in agent memory: what made this spec hard? (useful signal for architecture or spec writing process)

---

## 3. Architect's Design Conflicts with Existing Codebase

**Symptom**: Architecture-reviewer or code-explorer flags that proposed design contradicts existing patterns, violates infrastructure constraints, or requires breaking changes to working code.

**Example**: Architecture proposes moving auth from Cognito SRP to JWT tokens, but existing API endpoints expect Cognito tokens. Changing breaks production.

**Diagnosis**:
1. code-explorer (or architecture-reviewer) produces a conflict report with specific details:
   - What existing pattern/constraint is violated?
   - What is the architectural proposal that conflicts?
   - What's the blast radius if we break the existing pattern?
2. Classify conflict type:
   - **Design pattern conflict**: New design uses patterns that contradict existing code (e.g., monolith vs. microservices)
   - **Infrastructure conflict**: Design assumes infra that doesn't exist or requires breaking changes (e.g., moving databases)
   - **API contract conflict**: Design changes contracts that external systems depend on

**Escalation Path**:
1. architecture-reviewer flags conflict in their review
2. Architect receives feedback and must choose:
   - **Option A**: Revise design to work within existing constraints
   - **Option B**: Document a migration plan explaining why the existing pattern must change, phased rollout, compatibility layer, or deprecation timeline
3. If architect can't decide, escalate to user — it's a trade-off decision (stability vs. technical debt)
4. User decides: accept new design + migration cost, keep existing pattern, or hybrid approach

**Resolution**:
- Revised architecture doc that either:
  - Respects existing patterns and constraints, OR
  - Explicitly documents migration steps, phasing, and why the change is worth the cost
- architecture-reviewer re-reviews revised design
- Proceed to implementation with clear migration guidance

---

## 4. Security Reviewer Finds Critical/High Issue Mid-Implementation

**Symptom**: During code review, a security reviewer (backend-security-reviewer, frontend-security-reviewer, cloud-security-reviewer, appsec-reviewer) identifies a vulnerability rated **Critical** or **High**.

**Examples**:
- SQL injection in a data access layer
- Overpermissive IAM policy allowing resource hijack
- XSS vulnerability in a component that processes user input
- Hardcoded credentials in configuration

**Diagnosis**:
1. Security reviewer produces detailed finding with:
   - Specific file:line location
   - Vulnerability type and CVSS rating
   - Proof of concept showing how it could be exploited
   - Recommended fix with effort estimate
2. Assess impact: Does this vulnerability affect:
   - Critical user data? (PII, auth tokens, credentials)
   - System availability? (DoS vectors)
   - System integrity? (can attacker modify data)

**Escalation Path**:
1. **HALT implementation** — do not merge code with Critical/High security issues
2. Security reviewer reports finding to orchestrator with detailed context
3. Implementer receives detailed remediation steps (not just "fix the vuln")
4. Implementer fixes the issue, commits, and requests re-review
5. Security reviewer re-reviews — must verify fix is complete and doesn't introduce new issues
6. Only after clean security review can code proceed to merge/deployment

**Resolution**:
- Implementer fixes vulnerability
- Security reviewer confirms fix is correct and complete
- Code is then eligible for merge
- Log finding in project memory: pattern to avoid in future

**No Shortcuts**: Critical/High findings block merge unconditionally. This is not negotiable. Medium/Low findings can be tracked as tech debt after merge if necessary, but Critical/High must be resolved first.

---

## 5. Agent Dispatched Outside Its Competency

**Symptom**: Orchestrator dispatches an agent to a task outside its skills. Agent recognizes the mismatch and produces low-quality output, or completes but the result doesn't fit the task domain.

**Examples**:
- backend-engineer asked to design a React component
- frontend-engineer asked to optimize database queries
- database-engineer asked to write Kubernetes manifests
- doc-writer asked to make architectural decisions

**Diagnosis**:
1. Agent reads the task and identifies it doesn't match their loaded skills
2. Agent should report immediately: "Out of scope — this task requires [skill] which I don't have"
3. Agent should NOT try to muddle through — that wastes tokens and produces poor output

**Escalation Path**:
1. Agent reports "Out of scope" with specific missing skills to orchestrator
2. Orchestrator re-routes task to correct agent:
   - React component design → frontend-engineer (with design-first guidance) OR uiux-designer
   - Database optimization → database-engineer
   - Kubernetes → devops-engineer or cloud-security-reviewer (if security-relevant)
   - Architecture advice → architect
3. New agent receives the task with full context

**Resolution**:
- Original agent doesn't spend tokens trying to solve outside their domain
- Task routed to agent with correct skills loaded
- Work completes with higher quality

---

## 6. Circular Review Loop

**Symptom**: Implementer and reviewer disagree on requirements. Implementer makes a change. Reviewer still thinks it's wrong (for different reason, or same reason with different interpretation). Cycle repeats for 2+ rounds without progress.

**Examples**:
- Reviewer says "missing error handling" → Implementer adds error handler → Reviewer says "that's not comprehensive enough"
- Reviewer says "API response format wrong" → Implementer changes format → Reviewer says "should have included X field too"

**Diagnosis**:
1. Track which findings are being raised repeatedly:
   - If the same file/function is flagged in round 1, then again (after fix) in round 2, pattern is circular
   - If the reviewer's feedback changes between rounds ("first I wanted X, now I want Y"), the spec is ambiguous
2. Determine root cause:
   - Ambiguous spec (multiple valid interpretations)
   - Reviewer moving goalposts (new requirements each time)
   - Implementer not understanding feedback (skill gap, language barrier)

**Escalation Path**:
1. After round 2 with same finding being raised again, escalate to user
2. Provide user with:
   - Rounds 1 and 2 of feedback from reviewer
   - Implementer's changes between rounds
   - What's still disagreed on
3. User decides:
   - **Accept the implementation**: Sometimes "good enough" beats perfect iteration
   - **Revise the spec**: Make requirements unambiguous so reviewer and implementer agree
   - **Provide implementation guidance**: User explains intent to implementer to break the loop
   - **Swap reviewer**: Different reviewer might have different expectations; try a fresh set of eyes

**Resolution**:
- User makes judgment call
- Work resumes with new direction
- If spec was ambiguous, update it for next task

---

## 7. Agent Produces No Output

**Symptom**: Agent completes execution, reports "done," but returns no meaningful artifacts or output is empty/gibberish.

**Examples**:
- Architect completes but doesn't produce a design doc
- Implementer reports DONE but no code was written
- Doc-writer produces a 3-line README with no content

**Diagnosis**:
1. Orchestrator asks agent directly: "What did you produce? Where are the files?"
2. Identify the issue:
   - Agent hallucinated completion (thought it was done when it wasn't)
   - Agent lacked skills to do the task (should have reported out-of-scope)
   - Agent received unclear requirements (should have asked for clarification)
   - System-level issue (agent crashed, output wasn't captured)

**Escalation Path**:
1. Orchestrator retries the same task with **more specific instructions**:
   - Instead of "write a design doc", specify: "write a design doc with sections: System Overview, Data Model, API Contracts, Deployment Strategy. Save to `docs/architecture/2026-04-03-task-design.md`"
   - This helps if the issue was vagueness
2. If second attempt still produces no output, escalate to user
3. User decides:
   - **Clarify instructions**: Provide more context or examples
   - **Check agent skill alignment**: Does this agent have the right skills loaded for this task?
   - **Log improvement**: This is a signal that the agent's prompt, skill, or routing needs refinement

**Resolution**:
1. First retry with tighter brief
2. If still empty, escalate to user
3. Log finding in improvements/agents/ for later review

---

## Guidelines for Orchestrators

When orchestrating multi-agent workflows, follow these principles:

1. **Ask before deciding** — If a blocker or failure is ambiguous, ask the relevant agent (implementer, reviewer, architect) to clarify before escalating to user
2. **Provide full context when escalating** — User decisions should never be made on incomplete information. Include the original task, all relevant reports, and what options exist
3. **Track patterns** — If the same failure type recurs (e.g., spec rejections keep happening), log it. This is an improvement signal
4. **No silent failures** — If work stalls and you're not sure why, ask. Don't assume
5. **Respect agent boundaries** — If an agent reports BLOCKED or out-of-scope, trust their judgment. Don't push them to try anyway

---

## When to Escalate to User

**Default**: Try to resolve within the agent system first. Escalate to user when:

- Implementer is BLOCKED and can't be unblocked by upstream agent alone
- Spec-reviewer has rejected 3+ times and no convergence
- Architect's design conflicts with existing patterns and requires trade-off decision
- Security reviewer finds Critical/High issue (always halt; user decides merge policy)
- Agent reports out-of-scope and you're unsure of correct routing
- Circular review loop after 2 rounds
- Any agent produces no output twice

**Always provide**:
- What happened (specific symptom)
- Why it happened (diagnosis)
- What options exist (path forward)
- What context is needed to decide (any links to docs, reports, code)

User decides the path forward. Your job is to present options clearly.
