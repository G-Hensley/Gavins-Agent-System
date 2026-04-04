# Agent System — Improvement Plan

Consolidated feedback from system reviews. Work through these with Claude Code to iterate toward a self-improving, fully-tested agent system.

---

## 1. Eval Suite — Test Every Agent

The system has 23 agents but zero tests. Build an `evals/` directory that exercises every agent through graded prompts and seeded review challenges.

### Structure

```
evals/
├── README.md                    # How to run evals, what to check
├── tier-1-single-agent/         # Simple tasks, one agent each
├── tier-2-multi-agent/          # Tasks requiring agent handoffs
├── tier-3-architecture-first/   # Complex enough for full pipeline
├── tier-4-full-workflow/        # End-to-end subagent-driven-development
├── review-challenges/           # Pre-built code with planted issues
│   ├── sql-injection/           # backend-security-reviewer target
│   ├── overpermissive-iam/      # cloud-security-reviewer target
│   ├── xss-vulnerability/       # frontend-security-reviewer target
│   ├── dependency-vuln/         # appsec-reviewer target
│   ├── spec-deviation/          # spec-reviewer target
│   └── code-quality-issues/     # code-quality-reviewer target
└── agent-coverage.md            # Matrix showing which test hits which agent
```

### Agent Coverage Matrix

Every agent must be exercised by at least one eval. The matrix below maps agents to test tiers.

| Agent | Tier 1 | Tier 2 | Tier 3 | Tier 4 | Review Challenge |
|---|---|---|---|---|---|
| **ai-engineer** | ChatBot CLI with LLM API | — | RAG system | Full-stack AI app | — |
| **automation-engineer** | CLI calculator | File watcher script | — | — | — |
| **backend-engineer** | REST endpoint | — | Game server API | Full-stack app | — |
| **database-engineer** | Schema + migrations | — | Multi-table design | Full-stack app | — |
| **devops-engineer** | Dockerfile | CI pipeline | — | Full-stack app | — |
| **devsecops-engineer** | — | Secrets scanning setup | Security pipeline | — | — |
| **doc-writer** | README for calculator | API docs | Architecture docs | Full-stack app | — |
| **frontend-engineer** | — | Tic-tac-toe UI | Three.js scene | Full-stack app | — |
| **implementer** | — | — | — | Full-stack app (per-task) | — |
| **qa-engineer** | Unit test suite | E2E test plan | Load test strategy | Full-stack app | — |
| **architect** | — | — | Game architecture | Full-stack app | — |
| **product-manager** | — | — | Game PRD | Full-stack app | — |
| **uiux-designer** | — | Tic-tac-toe design system | — | Full-stack app | — |
| **appsec-reviewer** | — | — | — | — | dependency-vuln |
| **architecture-reviewer** | — | — | Review game design doc | — | — |
| **backend-security-reviewer** | — | — | — | — | sql-injection |
| **cloud-security-reviewer** | — | — | — | — | overpermissive-iam |
| **code-explorer** | — | Explore tic-tac-toe codebase | Explore game codebase | — | — |
| **code-quality-reviewer** | — | — | — | — | code-quality-issues |
| **frontend-security-reviewer** | — | — | — | — | xss-vulnerability |
| **plan-reviewer** | — | — | Review game impl plan | — | — |
| **product-reviewer** | — | — | Review game PRD | — | — |
| **spec-reviewer** | — | — | — | — | spec-deviation |

### Tier 1 — Single Agent, Simple Task

Each prompt tests one agent in isolation. Eval criteria: correct agent dispatched, TDD followed, output works.

- **CLI Calculator** (Python) → `automation-engineer`, `qa-engineer`, `doc-writer`
- **REST Endpoint** (single CRUD resource) → `backend-engineer`, `database-engineer`
- **Dockerfile** for a Python app → `devops-engineer`
- **ChatBot CLI** with Claude API → `ai-engineer`

### Tier 2 — Multi-Agent Handoff

Tasks require coordination between 2-3 agents. Eval criteria: correct dispatch sequence, artifacts passed between agents, design before implementation.

- **Tic-Tac-Toe** (terminal + web UI) → `uiux-designer` → `frontend-engineer`, `code-explorer`
- **File Watcher Script** with CI integration → `automation-engineer` → `devops-engineer`
- **Secrets Scanning Pipeline** → `devsecops-engineer` → `devops-engineer`

### Tier 3 — Architecture-First

Complex enough that `architect` must produce a design doc before implementation. Eval criteria: architecture doc produced, reviewed by `architecture-reviewer`, plan reviewed by `plan-reviewer`, TDD throughout.

- **Snake/Pong Game** → `product-manager` → `architect` → `backend-engineer` + `frontend-engineer` + `qa-engineer`
- **Three.js Interactive Scene** → `uiux-designer` → `architect` → `frontend-engineer`
- **RAG System** → `architect` → `ai-engineer` + `database-engineer`

### Tier 4 — Full Workflow (Subagent-Driven Development)

End-to-end: brainstorm → product-manager → architect → writing-plans → implementer agents → spec-reviewer → code-quality-reviewer → security reviewers → doc-writer.

- **Full-Stack Task Manager App** (Next.js + API + DynamoDB + auth) — exercises nearly every agent in the system

### Review Challenges — Seeded Defects

Pre-built mini-projects with known issues. Each targets a specific reviewer agent. Score: did the reviewer find the planted defect?

- **sql-injection/**: Express endpoint with string-concatenated SQL → `backend-security-reviewer`
- **overpermissive-iam/**: CloudFormation template with `Resource: "*"` and `Action: "*"` → `cloud-security-reviewer`
- **xss-vulnerability/**: React component with `dangerouslySetInnerHTML` from user input → `frontend-security-reviewer`
- **dependency-vuln/**: package.json with known vulnerable dependency versions → `appsec-reviewer`
- **spec-deviation/**: Implementation that's missing 2 requirements from the spec → `spec-reviewer`
- **code-quality-issues/**: Working code with duplicated logic, missing error handling, magic numbers → `code-quality-reviewer`

### Eval Criteria Per Test

Each eval prompt should include a checklist:

1. **Dispatch correctness** — Was the right agent(s) dispatched?
2. **Workflow compliance** — Did TDD happen? Was architecture produced before implementation?
3. **Output quality** — Does the code work? Are tests passing?
4. **Agent-specific rules** — Did the agent follow its own SKILL.md/agent definition?
5. **Handoff quality** — Were artifacts properly passed between agents?
6. **Review thoroughness** — Did reviewers catch what they should have caught?

---

## 2. System Validation (CI/Linting)

Add automated checks that prevent the system from silently breaking.

### install.sh Improvements

- Add `--dry-run` flag that shows what would be symlinked without doing it
- Add `--verify` flag that checks all symlinks are intact and targets exist
- Test in a clean container to catch assumptions about existing state

### Validation Script (`validate.sh`)

Create a script that checks:

- [ ] Every agent referenced in CLAUDE.md dispatch table exists in `agents/`
- [ ] Every skill referenced in `skill-router/SKILL.md` exists in `skills/`
- [ ] All SKILL.md files are under 200 lines
- [ ] All agent .md files are under 200 lines
- [ ] All reference files are under 200 lines
- [ ] All agent .md files have required frontmatter (name, description, tools, model)
- [ ] All SKILL.md files have valid structure
- [ ] No dead cross-references (agent references a skill that doesn't exist)
- [ ] `plugins/plugins.json` is valid JSON

---

## 3. Agent Memory Gap

Only `code-explorer` (12 files) and `architecture-reviewer` (3 files) have accumulated learnings. `backend-engineer` and `frontend-engineer` have empty memory directories. The remaining 19 agents don't even have memory directories yet.

### Actions

- [ ] Create `agent-memory/<name>/` directories for all 23 agents
- [ ] After each real project, review what the agent learned and seed its memory
- [ ] Consider a post-session hook that prompts: "What did this agent learn that's worth remembering?"

---

## 4. Improvements Backlog Bootstrap

The `improvements/skills/` and `improvements/agents/` directories are empty. The self-improvement feedback loop exists structurally but hasn't been activated.

### Actions

- [ ] After each eval run, log at least one improvement suggestion per agent that underperformed
- [ ] Review improvements weekly and promote the best ones to actual skill/agent changes
- [ ] Consider adding `improvements/system/` for cross-cutting improvements (workflow, config, tooling)

---

## 5. Architecture & Config Separation + CONTEXT.md

CLAUDE.md is doing double duty — personal preferences AND system operating manual. As the system grows, this will get unwieldy.

### Proposed Split

```
CLAUDE.md              → Personal preferences, response style, stack choices
SYSTEM.md              → Agent dispatch table, skill routing rules, workflow definitions
CODE_STANDARDS.md      → File size limits, naming conventions, commit format
SECURITY.md            → Security principles, reviewer dispatch rules
```

Evaluate whether this split actually helps or just adds indirection. The current single-file approach works fine at 97 lines — revisit when it approaches 200.

### CONTEXT.md — Supplementary Project Context

Add a `CONTEXT.md` file that provides ambient context Claude Code loads alongside CLAUDE.md. Where CLAUDE.md is rules and preferences, CONTEXT.md is situational awareness — the kind of context a new team member would need on day one.

Potential contents:

- **Project landscape**: What repos exist, what they do, how they relate to each other
- **Current state**: What's actively being worked on, what's stable, what's in flux
- **Domain terminology**: APIsec-specific terms, internal naming conventions, acronyms
- **Infrastructure map**: Which AWS accounts, what's deployed where, environment topology
- **Key decisions**: Why certain tech choices were made (e.g., why DynamoDB over Postgres, why Cognito SRP)
- **Team context**: Who works on what, who to check with for certain domains (useful when agents need to know who the human authority is for a decision)

This could also be the right place for the agent parallelism rules (see #13) since that's operational context about how the system works, not a preference or code standard.

CONTEXT.md should be loaded by agents that need project awareness (architect, product-manager, code-explorer) but can be skipped by narrow specialists (doc-writer, implementer) to keep their context windows lean.

---

## 6. Plans Directory Hygiene

The `plans/` directory accumulates session-specific plans that are ephemeral. Two options:

- **Option A**: Curate the best plans as templates in `plans/templates/` and gitignore the rest
- **Option B**: Gitignore `plans/` entirely and treat plans as conversation artifacts

Either way, old session plans shouldn't accumulate in version control.

---

## 7. Skill Composition & Dependencies

Skills are currently flat — the skill-router dispatches to one skill at a time. Real work often needs skill chains: `architecture` → `writing-plans` → `test-driven-development` → `backend-engineering` → `code-review`.

### Actions

- [ ] Document common skill chains as "workflows" (the `/plan` command does this implicitly — make it explicit)
- [ ] Consider adding a `depends_on` or `follows` field to SKILL.md frontmatter
- [ ] The skill-router could suggest chains, not just individual skills

---

## 8. Agent Handoff Protocol

When `architect` produces a design doc and `implementer` picks it up, the contract is implicit. Formalizing this would reduce dropped context.

### Actions

- [ ] Define standard output locations per agent (e.g., architect → `docs/architecture/`, product-manager → `docs/prd/`)
- [ ] Define what the receiving agent should expect as input
- [ ] Document handoff contracts in each agent's .md file

---

## 9. Failure Mode Documentation

No guidance exists for when things go wrong in multi-agent workflows.

### Scenarios to Document

- [ ] Implementer reports BLOCKED — what's the escalation path?
- [ ] Spec-reviewer rejects 3+ times — when to escalate vs. iterate?
- [ ] Architect's design conflicts with existing codebase — who decides?
- [ ] Security reviewer finds critical issue mid-implementation — halt or continue?
- [ ] Agent dispatched for a task outside its competency — how to reroute?

---

## 10. Skill Staleness Detection

Reference files can drift from reality over time. SDK patterns change, best practices evolve.

### Actions

- [ ] Add `last_verified: YYYY-MM-DD` to SKILL.md frontmatter
- [ ] Flag anything older than 90 days for review
- [ ] Could be automated with a scheduled task or a `validate.sh` check

---

## 11. Cross-Agent Memory

Agent memory is per-agent, but agents working on the same project don't share context. The `backend-engineer` might learn something about the API design that `frontend-engineer` needs.

### Actions

- [ ] Consider a shared `project-memory/` space for per-project learnings
- [ ] Alternatively, the orchestrator (main conversation) could summarize and pass context between agents
- [ ] Start lightweight — see if this is actually a problem in practice before building infrastructure

---

## 12. Agent Parallelism Map

There's no documentation of which agents can safely run in parallel and which must be sequential. This matters for both performance (don't serialize work that could overlap) and correctness (don't run two agents that write to the same files simultaneously).

### Sequential Dependencies (Must Wait)

These have hard ordering constraints — the downstream agent needs the upstream agent's output:

```
product-manager → architect → writing-plans → implementer(s)
uiux-designer → frontend-engineer
architect → backend-engineer / frontend-engineer / database-engineer
implementer → spec-reviewer → code-quality-reviewer
```

### Safe to Parallelize

These agents work on independent concerns and don't write to overlapping files:

```
# Multiple code-explorers (different aspects of the same codebase)
code-explorer (architecture) ‖ code-explorer (data flow) ‖ code-explorer (similar features)

# Independent domain implementation (after architecture is done)
backend-engineer ‖ frontend-engineer ‖ database-engineer

# Independent reviewers (after implementation is done)
backend-security-reviewer ‖ frontend-security-reviewer ‖ cloud-security-reviewer ‖ appsec-reviewer

# Review + documentation (documentation can start from the design doc)
spec-reviewer ‖ doc-writer

# Multiple implementers on different tasks (subagent-driven-development already does this)
implementer (task-1) ‖ implementer (task-2) ‖ implementer (task-3)
```

### Never Parallelize

These will conflict or produce inconsistent results:

```
# Two agents writing to the same files
backend-engineer ‖ database-engineer (if both touch the data layer)
frontend-engineer ‖ uiux-designer (designer must finish first)

# Review before the thing being reviewed exists
architecture-reviewer before architect finishes
plan-reviewer before writing-plans finishes
product-reviewer before product-manager finishes
spec-reviewer before implementer finishes
```

### Actions

- [ ] Document parallelism rules in CONTEXT.md or SYSTEM.md (wherever the config split lands)
- [ ] Add parallelism hints to each agent's .md frontmatter (e.g., `parallel_safe_with: [doc-writer, qa-engineer]`)
- [ ] The subagent-driven-development skill should reference these rules when dispatching

---

## 13. Metric Collection & Token Tracking

If running evals, track data to measure improvement over time. Token usage is especially important — it's both a cost signal and a quality signal (an agent burning 50k tokens on a simple task is a red flag).

### What to Log Per Eval Run

- Date and system version (git SHA)
- Which agents were dispatched
- Whether TDD was followed (yes/no)
- Number of review cycles before acceptance
- Defects caught (for review challenges)
- Wall-clock time (rough)
- Any unexpected behaviors or failures

### Token Tracking (Per Agent, Every Run)

Track token usage at the agent level, not just the session level. This gives you:

- **Cost visibility**: Which agents are expensive? Is `architect` (Opus) worth 10x the tokens of `implementer` (Sonnet)?
- **Efficiency signal**: If `backend-engineer` uses 30k tokens for a simple endpoint, the skill or prompt may need tightening
- **Regression detection**: If an agent's token usage spikes between system versions, something changed
- **Model selection validation**: Are Opus agents actually producing better output than Sonnet, or just burning more tokens?

What to capture per agent dispatch:

```json
{
  "agent": "backend-engineer",
  "model": "opus",
  "task": "REST endpoint for /api/users",
  "tokens": {
    "input": 12450,
    "output": 8320,
    "total": 20770
  },
  "duration_seconds": 45,
  "status": "DONE",
  "review_cycles": 1
}
```

### Token Budgets (Future)

Once you have baseline data, set per-agent token budgets:

- Tier 1 tasks: expect < 20k tokens per agent
- Tier 2 tasks: expect < 50k tokens per agent
- Tier 3 tasks: expect < 100k tokens per agent
- Tier 4 tasks: track total across all agents, flag if > 500k

Flag agents that consistently exceed budget — either the task is underscoped or the agent needs optimization.

### Storage

Store as JSON in `evals/results/YYYY-MM-DD/`. One file per eval run with nested agent metrics. Aggregate trends over time to spot regressions.

---

## Priority Order

Suggested sequence for working through these:

1. **Validation script** (#2) — quick win, prevents silent breakage
2. **Agent memory directories** (#3) — 5-minute task, removes friction
3. **CONTEXT.md** (#5) — foundational context that other improvements reference
4. **Agent parallelism map** (#12) — document before building evals so dispatch is correct
5. **Eval suite structure** (#1) — biggest impact, start with Tier 1
6. **Token tracking** (#13) — wire up before running evals so you capture data from day one
7. **Review challenges** (#1) — seed the security reviewer tests
8. **Handoff protocol** (#8) — document as you build evals
9. **Failure modes** (#9) — document as you encounter them in evals
10. **Improvements backlog** (#4) — flows naturally from running evals
11. **Everything else** — tackle as the system matures
