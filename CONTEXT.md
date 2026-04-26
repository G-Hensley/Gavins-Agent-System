# Gavins-Agent-System Context

Ambient context loaded alongside CLAUDE.md. This is what a new team member needs to know on day one.

## What This Repository Is

This is the complete Claude Code environment for Gavin Hensley — 37 reusable skills, 24 specialist agents, 12 path-scoped rules, 8 enforcement hooks, 7 slash commands, and persistent agent memory. It packages an entire AI assistant "brain" as portable, version-controlled infrastructure.

The system separates cleanly:
- **This repo** — Skills, agents, commands, configuration (your AI assistant's rules and knowledge)
- **Project repos** — Your actual code (Python, TypeScript, Java backends and frontends)

Install once with `./scripts/install.sh`, and symlinks propagate changes immediately to `~/.claude/`.

## Agent System Architecture

### Skills Define Knowledge
Each skill is a domain of expertise: `architecture/SKILL.md` defines *how* to design systems, `references/` provide patterns and checklists. Skills are reusable across agents.

### Agents Are Specialist Sessions
Each agent is a Claude session loaded with specific skills and persistent memory. `architect.md` says "you are a senior architect" and loads the `architecture` and `security` skills. Agent memory (`agent-memory/architect/learnings.md`) persists learnings across sessions.

### Dispatch Routes Work
The main conversation uses the `skill-router` skill to find the right skill. Dispatch an agent when domain work is needed — don't do everything in the main conversation.

## Standard Workflow Pipeline

Implement features top-to-bottom in this order:

```
brainstorming
  → product-manager (PRD)
    → architect (design)
      → threat-modeler (security analysis)
        → writing-plans (execution plan)
          → project-scaffolding (CLAUDE.md + CONTEXT.md for the project)
            → implementer(s) (code)
              → spec-reviewer (contract check)
                → code-quality-reviewer (style/complexity)
                  → security-reviewer(s) (backend/frontend/cloud)
                    → doc-writer (README, API docs)
```

Each arrow is a handoff. The receiving agent loads its memory and receives the artifact from the previous agent.

## Agent Parallelism Rules

Only run agents in parallel when there is **zero dependency** between them.

### Sequential (Must Wait)
- `product-manager` → `architect` → `writing-plans` → `implementer(s)`
- `uiux-designer` → `frontend-engineer`
- `architect` → `backend-engineer`, `frontend-engineer`, `database-engineer`
- `architect` → `threat-modeler`
- `implementer` → `spec-reviewer` → `code-quality-reviewer`

### Safe to Parallelize
- Multiple `code-explorer` agents (different aspects of codebase)
- `backend-engineer` || `frontend-engineer` || `database-engineer` (after architecture finalized)
- `backend-security-reviewer` || `frontend-security-reviewer` || `cloud-security-reviewer` || `appsec-reviewer` (all review artifacts in parallel)
- `spec-reviewer` || `doc-writer` (spec review and docs are independent)
- `threat-modeler` || `plan-reviewer` || `architecture-reviewer` (peer reviews in parallel)
- Multiple `implementer` agents on different tasks (coordinated by `subagent-driven-development`)

### Never Parallelize
- Both `backend-engineer` and `database-engineer` on shared data layer — coordinate through `architect`
- `frontend-engineer` with `uiux-designer` — designer finishes first
- Any reviewer before the artifact exists

## Eval System

`evals/` directory tests the system through graded prompts and seeded defect challenges.

### Four Tiers
- **Tier 1** — Single agent, focused task (e.g., "write a Python CLI tool")
- **Tier 2** — Multi-agent handoff (e.g., "design then implement a form")
- **Tier 3** — Architecture-first (e.g., "build a multi-service API")
- **Tier 4** — Full workflow with `subagent-driven-development` (e.g., "ship a feature end-to-end")

### Review Challenges
Six code artifacts with planted defects:
- SQL injection (target: `backend-security-reviewer`)
- Overpermissive IAM (target: `cloud-security-reviewer`)
- XSS vulnerability (target: `frontend-security-reviewer`)
- Vulnerable dependency (target: `appsec-reviewer`)
- Spec deviation (target: `spec-reviewer`)
- Code quality issues (target: `code-quality-reviewer`)

Reviewer passes if it identifies the specific defect, location, and fix.

### Running Evals
```bash
cd /path/to/Gavins-Agent-System
./evals/run-eval.sh all              # Run all tiers and challenges
./evals/run-eval.sh tier-1           # Run tier 1 only
./evals/run-eval.sh review-challenges/sql-injection
```

Results go to `evals/results/<timestamp>/`. Tier passes at 80% aggregate score.

## Key Design Decisions

### Skills and References Separation
`SKILL.md` defines behavior and process. `references/` hold domain knowledge (patterns, templates, checklists). This keeps skills concise and references queryable.

### Symlink-Based Installation
The install script symlinks `skills/`, `agents/`, `commands/` into `~/.claude/`. Edits in this repo take effect immediately — no reinstall needed.

### Per-Agent Memory, Not Shared
Each agent has its own memory file (`agent-memory/agent-name/learnings.md`). Cross-agent memory is deferred until proven needed. This prevents memory pollution and keeps each agent focused.

### settings.json Not Symlinked
`config/settings.json` is a template. The install script copies it; machine-specific overrides (local paths, tool permissions) go in `~/.claude/settings.json`. This stays local for security and flexibility.

### Skill Router First
When dispatching, check if a skill covers it before creating a new agent session. Use `skill-router` skill to find the right skill.

## Directory Layout

```
skills/              # 36 domains (each: SKILL.md + optional references/)
agents/              # 24 specialist agents (Markdown prompt format)
commands/            # 7 slash commands (/git-health-check, /improve, /plan, /pr-check, /review, /setup, /status)
rules/               # 12 path-scoped rules (glob-activated domain instructions)
agent-memory/        # Persistent learnings per agent
evals/               # Test suite (4 tiers, 6 review challenges, orchestration script)
improvements/        # Suggestions log for system enhancements (system/ subdir + README)
coaching/            # Dated output from the weekly-claude-code-coach Cowork task
templates/           # Starter templates for new skills / agents / commands
config/              # settings.json (template), settings.local.json, hooks.json, plugins/plugins.json (21 tracked)
scripts/             # install.sh, validate.sh, hooks/ (8 hooks: block-destructive, doc-drift-check, file-size-cap, gh-account-guard, lint-on-save, pr-push-nudge, verify-tests, warn-no-tests)
docs/                # FAILURE-MODES, HANDOFF-PROTOCOLS, IMPROVEMENTS, PROJECT-IDEAS, REFERENCE-GAPS, SKILL-CHAINS, STATUS, claude-code-cowork-reference
CLAUDE.md            # Global instructions (symlinked to ~/.claude/CLAUDE.md)
CONTEXT.md           # This file
README.md            # Project overview
claude-code-cowork-research.md  # Research snapshot used for system design (mirrored at Projects/Research/)
.gitignore           # Excludes secrets, caches, machine-specific state
```

## Security Notes

- **Secrets** — Use `~/.claude/credentials.json` (not tracked in git). Load via Cognito SRP or AWS_PROFILE.
- **Symlinks** — Everything in this repo except `config/settings.json` is symlinked. Settings stay local for machine-specific permissions.
- **IAM** — Follow least-privilege: no wildcards on actions or resources.
- **Input validation** — Always validate at system boundaries (API endpoints, CLI args).
- **Parameterized queries** — Never string-concatenate SQL or shell commands.

Dispatch security specialist agents (`backend-security-reviewer`, `frontend-security-reviewer`, `cloud-security-reviewer`, `appsec-reviewer`) proactively when touching auth, APIs, or infrastructure.

## Extending the System

### Add a Skill
1. Create `skills/skill-name/SKILL.md` (under 200 lines, process-focused)
2. Add reference files to `skills/skill-name/references/`
3. Commit and push — next `./install.sh` symlinks it

### Add an Agent
1. Create `agents/agent-name.md` (Markdown format, see architect.md as template)
2. Create `agent-memory/agent-name/learnings.md` for persistent memory
3. Commit and push — next `./install.sh` symlinks it

### Log Improvements
Found a gap? Don't build it — log it in `improvements/`:
```
improvements/skills/add-caching-patterns.md
improvements/agents/new-api-tester-agent.md
```

Write: what you observed, why it helps, concrete proposal. The maintainer reviews and decides.

## Agents at a Glance

| Agent | Role | Dispatch When |
|-------|------|---------------|
| `architect` | System design | Designing components, data models, APIs |
| `product-manager` | Requirements | Writing PRDs, roadmaps, scoping |
| `backend-engineer` | Server logic | Building APIs, services, databases |
| `frontend-engineer` | UI code | Building React, Next.js, components |
| `database-engineer` | Schema/queries | Designing schemas, writing SQL |
| `ai-engineer` | LLM/embeddings | Integrating AI, prompt engineering |
| `uiux-designer` | Design system | Creating design systems, wireframes |
| `automation-engineer` | Scripting | Building CLI tools, deployment code |
| `devops-engineer` | Infrastructure | AWS, Docker, Kubernetes, CI/CD |
| `threat-modeler` | Security design | Attack surface analysis, mitigations |
| `qa-engineer` | Testing | Test strategy, E2E, load tests |
| `implementer` | Coordination | Multi-task feature work (via subagent-driven-development) |
| `spec-reviewer` | Contract check | Verify implementation vs. spec |
| `code-quality-reviewer` | Style/complexity | Code cleanliness, maintainability |
| `backend-security-reviewer` | Backend security | Auth, input validation, APIs |
| `frontend-security-reviewer` | Frontend security | CSP, XSS, state management |
| `cloud-security-reviewer` | Cloud security | IAM, networking, data protection |
| `appsec-reviewer` | Top-level security | Application security overview |
| `doc-writer` | Documentation | README, API docs, ADRs, runbooks |
| `code-explorer` | Codebase research | Understanding patterns, dependencies |

Others: `architecture-reviewer`, `product-reviewer`, `plan-reviewer`, `devsecops-engineer`.
