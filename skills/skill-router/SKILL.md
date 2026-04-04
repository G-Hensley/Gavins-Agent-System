---
name: skill-router
description: Ensure the right skills activate for every task. Use when starting any conversation, beginning a new task, or switching between tasks. Check which skills apply and invoke them before responding. If there is even a small chance a skill is relevant, invoke it.
---

# Skill Router

Before responding to any task, check which skills apply and invoke them.

## Process

### Step 1: Check Priority Order

1. **User instructions** (CLAUDE.md, direct requests) — highest priority
2. **Skills** — override default behavior where they apply
3. **Default system behavior** — lowest priority

### Step 2: Select Skills

For each task, check this routing:

**Ideation / "I want to build..."** → `brainstorming`
**Requirements / PRDs / user stories** → `product-management`
**Technical design / system design** → `architecture`
**Implementation planning** → `writing-plans`
**Executing plans (small)** → `executing-plans`
**Executing plans (large, multi-task)** → `subagent-driven-development`
**Multiple independent problems** → `parallel-agents`
**Bug / test failure / unexpected behavior** → `systematic-debugging`
**Writing code** → `test-driven-development`
**Claiming work is done** → `validation-and-verification`
**Code review (request or receive)** → `code-review`
**Git operations (commit, push, PR, worktree, branch cleanup)** → `git-workflow`
**Backend (Python, Node, Java, APIs, services)** → `backend-engineering`
**Database (schema, queries, migrations, DynamoDB)** → `database-engineering`
**Frontend code (React, Next.js, components, state)** → `frontend-engineering`
**UI/UX design (colors, typography, spacing, hierarchy)** → `frontend-design`
**DevOps (CI/CD, Docker, AWS infra, monitoring)** → `devops`
**Automation (CLI tools, scripts, pipelines, batch)** → `automation-engineering`
**QA (test strategy, E2E, load testing, test data)** → `qa-engineering`
**Refactoring / cleaning up / technical debt** → `refactoring`
**API design / OpenAPI / REST conventions** → `api-design`
**Threat modeling / attack surface / VAST** → `threat-modeling`
**Security (frontend, API, DB, AWS, supply chain, appsec)** → `security`
**Documentation (CLAUDE.md, README, ADR, runbook, API docs)** → `doc-writing`
**AI agents / chatbots / LLM / RAG / prompt engineering** → `ai-engineering`
**Safety rules / hooks / "block this" / "warn me when"** → `hookify`
**Creating or improving skills** → `skill-creator`

### Step 3: Skills vs Agents

**Skills** provide knowledge and process — they guide HOW to work.
**Agents** do the work — dispatch them for actual implementation, review, or design.

When a task needs both knowledge AND execution:
1. Invoke the skill (loads domain knowledge)
2. Dispatch the appropriate agent (does the work using that knowledge)

Example: "Build an API endpoint" → invoke `backend-engineering` skill + dispatch `backend-engineer` agent.

### Step 4: Apply Rules

- If a skill might apply, invoke it — do not rationalize skipping it
- Multiple skills can apply to one task (e.g., TDD + backend-engineering for an API)
- Skills that apply to process (TDD, verification) apply alongside domain skills
- When in doubt, invoke the skill — it's cheaper than missing it
