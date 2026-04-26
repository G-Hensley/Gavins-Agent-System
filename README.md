# Claude Code Agent System

A portable, version-controlled configuration of Claude Code skills, agents, commands, and settings. Clone it, run the install script, and deploy your full AI assistant infrastructure to any machine.

## What This Is

This repository packages Gavin Hensley's complete Claude Code environment — 37 reusable skills, 24 specialist agents, 12 path-scoped rules, 8 enforcement hooks, 7 slash commands, persistent agent memory, and global Claude instructions. Everything is designed for API security, CLI tooling, backend/frontend development, and multi-agent automation.

Instead of scattering configuration across machines, this system is:
- **Version-controlled** — Every skill, agent, and setting is in git. Review changes, rollback mistakes, share improvements.
- **Portable** — Run `./scripts/install.sh` on any machine with the claude CLI installed. Symlinks everything into `~/.claude/`.
- **Extensible** — Add new skills and agents. Log suggestions in `improvements/` to improve the system over time.
- **Separate from code** — Your actual project work lives elsewhere. This is your AI assistant's "brain."

## Repository Structure

```
skills/              # 37 reusable skills (each with SKILL.md and optional references/)
agents/              # 24 specialist agents (prompts + configuration)
commands/            # 7 slash commands (/git-health-check, /improve, /plan, /pr-check, /review, /setup, /status)
rules/               # 12 path-scoped rules (glob-activated domain instructions)
agent-memory/        # Persistent learnings per agent (loaded per session)
improvements/        # Backlog for skill/agent enhancements
coaching/            # Dated Claude-authored coaching notes on the system (not synced)
config/              # Settings, plugin list, hooks template
  plugins/           #   plugins.json (20+ tracked plugins)
  hooks.json         #   Hook definitions (merged into settings.json on install)
  settings.json      #   Template permissions and configuration
  settings.local.json #  Local overrides
scripts/             # Tooling and automation
  install.sh         #   Deploy script — symlinks everything to ~/.claude/
  validate.sh        #   Validates repo structure (288 checks)
  hooks/             #   8 enforcement hooks (lint, destructive cmd block, doc drift, pr-push nudge, file-size cap, gh-account guard, etc.)
templates/           # Reusable project templates
  github-actions/    #   CI and Claude review workflow templates
docs/                # Project documentation and roadmaps
  IMPROVEMENTS.md    #   Consolidated improvement plan
  STATUS.md          #   Current status tracker with eval results
evals/               # 17-eval test suite across 4 tiers + 6 review challenges
CLAUDE.md            # Global instructions for Claude Code sessions
CONTEXT.md           # Ambient context (pipeline, parallelism, architecture)
README.md            # This file
.gitignore           # Excludes credentials, caches, ephemeral state
```

## Quick Start

### Prerequisites

Required (install before running install.sh):
- `bash` 3.2+
- `python3` (used by install.sh and several hooks)
- `git`
- `gh` (GitHub CLI)
- `jq`
- `claude` (Claude Code CLI — `brew install anthropics-ai/claude/claude` on macOS)

Optional (hooks degrade silently if missing):
- `ruff` (used by `lint-on-save` hook — `uv tool install ruff`)
- `uv` (referenced by Python skills)
- `pnpm` (referenced by TS skills)

Run `./scripts/install.sh --check-prereqs` to probe for these without installing anything.

### Install

```bash
# Clone your fork (replace <your-username> with your GitHub username)
git clone https://github.com/<your-username>/gavins-agent-system.git
cd gavins-agent-system
./scripts/install.sh
```

The script will:
1. Run a prerequisite check (aborts if required tools are missing)
2. Create `~/.claude/` if it doesn't exist
3. Symlink `skills/`, `agents/`, `commands/`, `rules/`, `improvements/`, `agent-memory/` to `~/.claude/`
4. Symlink `CLAUDE.md` and `settings.local.json`
5. Copy `settings.json` as a template (so you can customize machine-specific permissions)
6. Copy `gh-account-guard.conf.example` to `~/.claude/` (rename + edit to enable the account-guard hook)
7. Install plugins listed in `plugins/plugins.json` (if claude CLI is available)

Backups are created as `.bak` files if existing files are replaced.

### Enable gh-account-guard (optional)

If you have multiple GitHub accounts and want to prevent pushing with the wrong one:

```bash
mv ~/.claude/gh-account-guard.conf.example ~/.claude/gh-account-guard.conf
# edit ~/.claude/gh-account-guard.conf and set USERNAME=<your-github-username>
```

The hook then blocks `git push` to repos owned by USERNAME if the active gh CLI account is different. Without this file, the hook is a no-op.

### Verify

After install, your Claude Code sessions will load these skills and agents automatically. Check:

```bash
ls -la ~/.claude/skills      # Should see 36 skill directories
ls -la ~/.claude/agents      # Should see 24 agent definitions
claude skill list            # See available skills
```

## Skill & Agent Overview

### Core Reasoning Skills
- **brainstorming** — Idea generation, design thinking, problem analysis
- **product-management** — Feature scoping, roadmaps, customer prioritization
- **architecture** — System design, scalability, trade-off analysis

### Development Skills
- **backend-engineering** — Python, Node.js, Java APIs and services
- **frontend-engineering** — React, Next.js, TypeScript, CSS patterns
- **frontend-design** — UI/UX, design systems, component libraries
- **database-engineering** — Schema design, queries, performance, migrations
- **ai-engineering** — LLM integration, prompt design, embeddings, agents
- **automation-engineering** — Scripts, CLI tools, deployment automation
- **devops** — Infrastructure, Docker, Kubernetes, AWS, CI/CD

### Quality & Review Skills
- **test-driven-development** — TDD workflow, pytest, Vitest, test patterns
- **qa-engineering** — Test strategy, E2E testing, load testing, coverage
- **code-review** — Architecture review, style, patterns, maintainability
- **codex-plan-review** — Adversarial Codex review on drafted plans before implementation
- **refactoring** — Code cleanup, performance, tech debt, DRY principles
- **validation-and-verification** — Testing strategy, correctness proofs

### Operations & Security
- **systematic-debugging** — Root cause analysis, debugging workflows
- **git-workflow** — Commits, branching, rebasing, conflict resolution
- **security** — Input validation, authentication, authorization, secrets management
- **threat-modeling** — Attack surfaces, risk analysis, mitigation strategies

### Writing & Documentation
- **doc-writing** — README, API docs, ADRs, runbooks, changelogs
- **writing-plans** — Planning features, organizing thoughts, specifications

### System & Meta Skills
- **skill-router** — Route incoming tasks to the right skill
- **parallel-agents** — Run multiple agents in parallel
- **subagent-driven-development** — Dispatch agents for multi-task implementation
- **execution-plans** — Execute complex multi-step workflows
- **hookify** — Add pre-commit hooks, linters, test integrations

### Specialist Agents

Each agent is a Claude Opus session with a specific domain and persistent memory:

| Agent | Domain | Use When |
|-------|--------|----------|
| `backend-engineer` | Backend services | Building APIs, services, server-side logic |
| `frontend-engineer` | Frontend code | Building React, Next.js, component libraries |
| `database-engineer` | Schema, queries | Designing databases, writing SQL, migrations |
| `ai-engineer` | LLM, embeddings | Integrating AI, prompt engineering, agents |
| `automation-engineer` | Scripts, tooling | Writing CLI tools, scripts, deployment code |
| `devops-engineer` | Infrastructure | AWS, Docker, Kubernetes, CI/CD pipelines |
| `devsecops-engineer` | Security pipelines | Adding security checks, vulnerability scanning |
| `implementer` | Multi-task work | Coordinating feature implementation across areas |
| `uiux-designer` | Design systems | Creating design systems, wireframes, component specs |
| `architect` | System design | Large-scale architecture, trade-offs, scalability |
| `product-manager` | Product work | Roadmaps, requirements, prioritization |
| `backend-security-reviewer` | Backend security | Reviewing auth, input validation, APIs |
| `frontend-security-reviewer` | Frontend security | Reviewing CSP, XSS, state management |
| `cloud-security-reviewer` | Cloud infrastructure | Reviewing IAM, networking, data protection |
| `appsec-reviewer` | Application security | Top-level security review |
| `architecture-reviewer` | Architecture review | Design patterns, maintainability, trade-offs |
| `product-reviewer` | Product review | Requirements coverage, scope creep, roadmap alignment |
| `plan-reviewer` | Plan review | Reviewing execution plans for completeness |
| `spec-reviewer` | Specification review | Technical specifications, contracts |
| `code-quality-reviewer` | Code quality | Style, complexity, maintainability |
| `code-explorer` | Code research | Understanding codebases, finding patterns |
| `qa-engineer` | QA & testing | Test strategy, E2E, load tests |
| `doc-writer` | Documentation | Writing and maintaining docs |

## Configuration

### CLAUDE.md (Global Instructions)

The `CLAUDE.md` file contains your global Claude Code instructions:
- **About you** — Background, stack, company
- **Rules** — DRY, YAGNI, TDD, verification-first
- **Code standards** — File size, naming conventions, commit style
- **Stack preferences** — Languages, frameworks, testing, AWS patterns
- **Agent dispatch guide** — When to use each specialist agent
- **Security guidelines** — Secrets, validation, IAM principles
- **Self-improvement** — How to log and improve the system
- **Memory** — Where and how to store learnings
- **Response style** — Conciseness, no filler, action-first

This file is symlinked to `~/.claude/CLAUDE.md` and loaded automatically.

### settings.json (Template)

The `settings.json` file contains safe defaults:
```json
{
  "permissions": {
    "allow": [
      "Bash(git ...)",
      "Bash(pnpm ...)",
      "Bash(uv ...)",
      "Bash(gh ...)"
    ],
    "additionalDirectories": []
  }
}
```

Machine-specific overrides (absolute paths, local tools) go in your `~/.claude/settings.json` after install.

### plugins.json

List of installed plugins (20+ tracked):
```json
{
  "plugins": [
    "plugin-name-1",
    "plugin-name-2"
  ]
}
```

Install new plugins with `claude plugin install <name>` and add them to this file to version-control them.

## Development Workflow

### Adding a New Skill

1. Create a new skill directory under `skills/skill-name/`
2. Write `SKILL.md` (describe what the skill does, when to use it, process steps)
3. Create `references/` subdirectory with reference files (e.g., `python-patterns.md`)
4. Commit and push
5. Next `./scripts/install.sh` will symlink it to `~/.claude/skills/`

Example structure:
```
skills/my-skill/
  SKILL.md                     # 100-200 lines, process + references
  references/
    pattern-1.md
    pattern-2.md
```

### Adding a New Agent

1. Create a new JSON file under `agents/agent-name/`
2. Define the agent configuration (model, system prompt, tools, skills)
3. Create `agent-memory/agent-name/` for persistent learnings
4. Commit and push
5. Next `./scripts/install.sh` will symlink it

Example:
```
agents/my-agent/
  config.json                # Agent definition
agent-memory/my-agent/
  learnings.md             # Persistent notes
```

### Adding a New Slash Command

1. Create a command definition under `commands/command-name.md`
2. Write the command prompt and trigger description
3. Commit and push

### Logging Improvements

Found a gap in skills, agents, or workflows? Log it:

```
improvements/
  skills/
    add-caching-patterns.md
    fix-async-reference.md
  agents/
    new-api-tester-agent.md
```

Write a short markdown file with:
- **What you observed** — What was missing or unclear
- **Why it would help** — How this improves the system
- **Proposal** — Specific skill/agent/reference to create

Example:
```markdown
# Add Caching Patterns to Backend Engineering Skill

## Observation
While implementing a cached API, I needed redis patterns but the backend-engineering skill didn't cover caching.

## Why It Would Help
Many backend services need caching (Redis, Memcached). This is a common pattern that should be documented.

## Proposal
Add `references/caching-patterns.md` to backend-engineering skill with:
- Redis client setup (Python, Node)
- Cache invalidation strategies
- TTL, eviction policies
- Distributed caching (multiple servers)
```

Do not create the skill/agent yourself — log the suggestion and let the maintainer review.

## Updating Your System

To pull updates from the remote repository:

```bash
cd /path/to/claude-agent-system
git pull origin main
# Already symlinked, so changes take effect immediately
```

To share improvements:

```bash
git add improvements/
git commit -m "docs: improve backend-engineering caching patterns"
git push origin feature-branch
# Open a pull request
```

## Directory Details

### agent-memory/

Persistent learnings per agent. Each agent loads its memory at session start.

```
agent-memory/
  backend-engineer/
    learnings.md
  frontend-engineer/
    learnings.md
```

Format: Markdown with sections like "Preferences", "Common Pitfalls", "Stack Notes".

### coaching/

Dated markdown notes written by Claude (e.g. `2026-04-16.md`) critiquing the state of the agent system. Git-tracked for history. Not symlinked into `~/.claude/` — these are meta-analysis, not runtime config.

### improvements/

Backlog for enhancements. Not acted on by Claude automatically — it's a suggestion log for the maintainer.

## What NOT to Commit

The `.gitignore` excludes:
- **Secrets** — `.credentials.json`, API keys, tokens
- **Session state** — `history.jsonl`, `sessions/`, `chrome/`
- **Caches** — `cache/`, `plugins/cache/`, `downloads/`
- **Machine-specific** — `.claude/` (use symlinks instead)

Never commit credentials, API keys, or machine-specific paths.

## Security

- **Secrets**: Use `~/.claude/credentials.json` (not tracked). Load via `Cognito SRP` or `AWS_PROFILE`.
- **IAM**: Follow least-privilege — no wildcards on actions or resources.
- **Input validation**: Always validate at system boundaries (API endpoints, CLI args).
- **Parameterized queries**: Never string-concatenate SQL or shell commands.

Dispatch `backend-security-reviewer`, `frontend-security-reviewer`, `cloud-security-reviewer`, or `appsec-reviewer` for security work.

## Feedback & Improvements

This is a living system. If you use it:
- Find gaps? Log an improvement in `improvements/`
- See redundancy? Refactor and push
- Built something useful? Share it as a new skill or agent
- Want a different convention? Document it in CLAUDE.md and align with the maintainer

## License

All configuration, prompts, and instructions are owned by Gavin Hensley. Skills and agents are custom-built for this workflow. Do not distribute without permission.

## Questions?

Refer to:
- **CLAUDE.md** — How this system works, when to use each agent
- **Individual SKILL.md files** — How to use each skill
- **Agent definitions** — Prompts, models, tool bindings for each agent
- **improvements/** — Ideas being considered for the system

For Claude Code documentation, see the official [Claude Code documentation](https://claude.com/claude-code).
