---
name: architecture
description: Create technical designs from product requirements or feature specs. Use when transitioning from product-management to implementation, when designing system architecture, component boundaries, data models, API contracts, or infrastructure. Also use when the user says "design this", "how should we architect", "system design", "technical spec", or when a feature needs technical planning before coding.
---

# Architecture

Transform product requirements into a technical design that implementation can follow without ambiguity. Takes a PRD or feature description and produces a technical spec.

## When to Use

- After product-management produces a PRD (project-level work)
- After brainstorming converges on a feature or component direction
- When the user needs technical design before implementation
- When system boundaries, data models, or API contracts need definition

## Process

### 1. Understand Requirements
- Read the PRD or feature spec completely
- For existing codebases: dispatch 2-3 `code-explorer` subagents in parallel to understand patterns, architecture, and similar features. Read the essential files they identify before designing.
- Identify: what components exist, what's new, what changes

### 2. Define System Boundaries
- List every component/module the system needs
- For each component: what it does (one sentence), what it depends on, what depends on it
- Draw clear boundaries — each component has one responsibility
- Identify integration points with external systems (APIs, databases, third-party services)

### 3. Design Data Model
- Define entities, their attributes, and relationships
- Specify data storage (database tables, file structures, in-memory state)
- Document data flow: where data enters, how it transforms, where it ends up
- Note validation rules at each boundary

### 4. Define API Contracts
For each interface between components:
```
Endpoint/Function: [name]
Input: [parameters with types]
Output: [return type]
Errors: [possible error states]
```
Be specific — vague contracts cause integration bugs.

### 5. Address Cross-Cutting Concerns
- **Auth/authz**: who can access what, how is it enforced
- **Error handling**: what fails, how does it recover, what does the user see
- **Performance**: expected load, bottlenecks, caching strategy
- **Security**: input validation, data protection, OWASP considerations
- Only address concerns relevant to this design — skip what doesn't apply

### 6. Write Technical Design Doc
Save to project docs (e.g., `docs/architecture/YYYY-MM-DD-<topic>-design.md`). Include:
- Overview (one paragraph: what this is and why)
- System boundaries and component diagram (text description)
- Data model
- API contracts
- Key technical decisions with rationale
- Error handling and failure modes
- Open questions (if any)

### 7. Review and Hand Off
- Dispatch the `architecture-reviewer` subagent
- Fix issues, re-dispatch (max 3 iterations, then surface to user)
- Ask user to review the technical design before proceeding
- Hand off to `writing-plans` skill to create implementation tasks

## Design Principles

### DRY — Don't Repeat Yourself
Apply DRY at every level of the architecture, not just code:

- **Data**: single source of truth for every piece of data. If two components need the same data, one owns it and the other reads from it — never duplicate storage.
- **Logic**: shared business rules live in one place (shared module, service, or library). If the same validation, transformation, or calculation appears in multiple components, extract it.
- **Configuration**: one config source, referenced everywhere. No copy-pasted environment variables, connection strings, or feature flags across services.
- **Contracts**: define shared types/interfaces once and import them. No parallel type definitions that drift out of sync.
- **Infrastructure**: reuse existing patterns (auth middleware, API clients, error handlers) before creating new ones. Check what the codebase already provides.

When reviewing a design, ask: "If this rule/data/logic changes, how many places need updating?" If the answer is more than one, the design has a DRY violation.

### YAGNI — You Aren't Gonna Need It
Design for current requirements. Do not add abstractions, configurability, or extension points for hypothetical future needs.

### Single Responsibility
Each component does one thing. If you can't describe what a component does in one sentence, it's doing too much — split it.

## What NOT to Do

- Do not duplicate data, logic, or configuration across components — extract shared concerns
- Do not make product decisions — that's product-management's job
- Do not start implementing — that's writing-plans → execution
- Do not over-engineer — design for current requirements, not hypothetical future ones
- Do not ignore existing codebase patterns — follow conventions already in place
- Do not leave interfaces vague — "it sends data to the other service" is not a contract
- Do not skip failure modes — every external call can fail, every input can be invalid
- Do not create parallel type definitions — define shared types once and import them

## Working in Existing Codebases

- Read existing architecture before proposing new patterns
- Identify existing shared modules, utilities, and patterns — reuse before creating
- Prefer extending existing patterns over introducing new ones
- Where existing patterns are problematic, include targeted improvements in the design with rationale
- Note which files/modules will be modified vs. created

## Reference Files

- `references/diagram-patterns.md` — System context, component, data flow, ERD, sequence, and API contract diagram templates. Read when writing the technical design doc (Step 6).
- `code-explorer` subagent — deep codebase exploration. Dispatch 2-3 in parallel during Step 1.
- `architecture-reviewer` subagent — validates technical designs. Dispatch during Step 7.
