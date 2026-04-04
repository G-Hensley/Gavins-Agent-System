---
name: doc-writing
description: Write and maintain project documentation — CLAUDE.md files, READMEs, ADRs, runbooks, API docs, and changelogs. Use when creating or updating any project documentation, when the user says "write docs", "update README", "document this", "write a runbook", "update CLAUDE.md", or when capturing session learnings into project files.
---

# Doc Writing

Create and maintain project documentation. Select the doc type, follow its template, and dispatch the doc-reviewer agent.

## Process

### 1. Identify Doc Type
Determine which type of documentation is needed:
- **CLAUDE.md** — project instructions for Claude Code sessions
- **README** — project overview, setup, usage for humans
- **ADR** — Architecture Decision Record for significant technical choices
- **Runbook** — operational procedures for deployment, incidents, maintenance
- **API docs** — endpoint documentation for consumers
- **Changelog** — version history of changes

### 2. Read Existing Docs
Check what documentation already exists in the project. Follow existing conventions for format, location, and style.

### 3. Write or Update
Read the relevant reference for the doc type and follow its template. Write concisely — documentation that isn't read is wasted effort.

### 4. Review
Dispatch the doc-reviewer agent (`doc-writer` subagent) to check completeness and accuracy against the codebase.

## What NOT to Do

- Do not write documentation that duplicates what the code already says — document the *why*, not the *what*
- Do not create documentation the user didn't ask for
- Do not write overly long docs — concise and accurate beats comprehensive and ignored
- Do not document implementation details that change frequently — document interfaces and contracts
- Do not leave placeholder sections ("TODO: fill in later") — either write it or remove the section

## Reference Files

- `references/doc-templates.md` — Templates for CLAUDE.md, README, ADR, runbook, API docs, and changelog. Read when creating any doc type.
- `doc-writer` subagent (in `~/.claude/agents/`) — Subagent prompt for reviewing documentation accuracy and completeness.
