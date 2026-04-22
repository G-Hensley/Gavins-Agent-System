# Global Claude Code Instructions

## About Me

Full-stack engineer at APIsec (API security platform). Python, TypeScript, Java. AWS infrastructure. I build CLI tooling, web apps, multi-agent automation, and API security tools.

## Rules

- **Use my skills and agents.** I have a full skill library at `~/.claude/skills/` and agents at `~/.claude/agents/`. Check the `skill-router` skill to find the right one. Do not reinvent what a skill already covers.
- **Dispatch specialist agents** for domain work. Don't do everything in the main conversation — use the `backend-engineer`, `frontend-engineer`, `database-engineer`, `uiux-designer`, etc. They have the right skills loaded and persistent memory.
- **TDD is not optional.** Write tests first. Watch them fail. Implement. Verify. No exceptions without my explicit permission.
- **DRY at every level.** Data, logic, configuration, contracts, infrastructure. If it changes, it should only need to change in one place.
- **YAGNI.** Build for what's needed now. No speculative abstractions, configurability, or "future-proofing."
- **Verify before claiming.** Run the command that proves it works. "Should work" is not evidence.

## Git Workflow

- Always commit and push changes after completing PR review fixes without waiting to be asked
- Verify the active GitHub account before pushing (`gh auth status` — use `G-Hensley`, not `Gavin-Hensley`)
- Never include SQL keywords like `DROP TABLE` in PR/commit bodies (triggers security hooks)

## Quality Gates

- Run `ruff check` as part of the TDD green gate for Python projects, not just tests
- Verify dev server starts cleanly before declaring frontend work complete

## Windows Environment

This workstation runs Windows with Git Bash (MINGW64). These quirks bite repeatedly — don't rediscover them each session:

- **Encoding:** cp1252 is the default. Python / CLI tools emitting Unicode need `PYTHONIOENCODING=utf-8` (or equivalent). When writing files programmatically, open them with `encoding="utf-8"` explicitly.
- **Symlinks:** Git Bash symlink creation silently falls back to file copies unless Developer Mode or an admin shell is active. After any install that creates symlinks, verify with `ls -la` that they're real links, not copies.
- **Missing utilities:** `zip` is not installed by default. Use PowerShell `Compress-Archive -Path ... -DestinationPath ...` or `tar -czf`.
- **Line endings:** CRLF is the default. `warning: LF will be replaced by CRLF the next time Git touches it` during `git add` is normal, not an error — don't "fix" it.
- **Paths:** Forward slashes work in Git Bash. Prefer `/dev/null` over Windows `NUL` inside shell scripts.
- **Shell:** Claude Code runs bash on this machine, not PowerShell. Assume bash syntax unless told otherwise.

## Planning

- When the user asks to plan or brainstorm, do NOT launch autonomous Task/Agent exploration first — ask clarifying questions or proceed directly

## Code Standards

- **File size:** SKILL.md and agent files under 200 lines. Reference files under 200 lines. Production code files — if it's getting long, it's doing too much.
- **Naming:** kebab-case for files/folders, camelCase for JS/TS variables, snake_case for Python. Descriptive names — `fetchCustomerScans` not `getData`.
- **Commits:** small and frequent. One logical change per commit. Message format: `type: description` (feat, fix, refactor, test, docs, chore).
- **No dead code.** Delete unused functions, imports, variables. Don't comment out code "for later."

## Stack Preferences

- **TypeScript only — never JavaScript.** All frontend and Node.js code must be TypeScript. No `.js` files, no `allowJs`, no exceptions.
- **pnpm only** for TypeScript/Node.js projects. Never use npm or yarn. Use `pnpm install`, `pnpm add`, `pnpm audit`.
- **uv only** for Python projects. Never use pip, poetry, or pipenv directly. Use `uv init`, `uv add`, `uv run`, `uv sync`.
- **Python**: dataclasses, argparse, asyncio, typing, Pydantic. Rate limiting at 8 req/s. Shared auth via Cognito SRP.
- **TypeScript**: Zod validation, Zustand state, strict types. No `any`.
- **React**: function components, hooks, server components default. Props interfaces on every component.
- **Next.js**: App Router. Server components for data, client components pushed to leaves.
- **CSS**: Tailwind with design system values from config. No arbitrary values.
- **AWS**: Lambda, DynamoDB, S3, Cognito, Secrets Manager, EventBridge. Least-privilege IAM always.
- **Testing**: pytest via `uv run pytest` (Python), Vitest (TS), Playwright (E2E).
- **Context7**: Always use Context7 MCP to look up library/framework docs before using any third-party API. Do not rely on training data for package APIs — check the current docs first.

## Agent Dispatch Guide

Use these agents proactively — don't wait for me to ask:

| Situation | Dispatch |
|---|---|
| New project/feature ideation | Use `brainstorming` skill, then `product-manager` agent |
| System design needed | `architect` agent (Opus) + `code-explorer` agents for research |
| UI/UX work before coding | `uiux-designer` agent (Opus) — creates design system FIRST |
| Building backend code | `backend-engineer` agent (Opus) |
| Building frontend code | `frontend-engineer` agent (Opus) — implements FROM design system |
| Database schema/queries | `database-engineer` agent (Opus) |
| AI/LLM integration | `ai-engineer` agent (Opus) |
| CI/CD, Docker, AWS infra | `devops-engineer` agent |
| Security integration in pipelines | `devsecops-engineer` agent |
| Scripts, CLI tools, automation | `automation-engineer` agent |
| Test strategy, E2E, load tests | `qa-engineer` agent |
| Documentation | `doc-writer` agent (Haiku) |
| Security review | Dispatch the RIGHT specialist: `frontend-security-reviewer`, `backend-security-reviewer`, `cloud-security-reviewer`, or `appsec-reviewer` |
| Security assessment needed before implementation | `threat-modeler` agent (Opus) |
| Multi-task implementation | Use `subagent-driven-development` skill with `implementer` agent per task |

## Security

- Never commit .env, credentials, API keys, or secrets
- Validate all input at system boundaries
- Parameterized queries only — never string concatenation
- Least-privilege IAM — no wildcards on actions or resources
- Check `pnpm audit` / `uv pip audit` when adding dependencies
- Dispatch security specialist agents proactively when touching auth, APIs, or infrastructure

## Self-Improvement

Actively look for ways to improve the skills and agents system. When you notice a gap, pattern, or opportunity during work, log it:

Log to `~/.claude/improvements/<kind>/` where `<kind>` classifies the suggestion:
- `skills/` — new skills or enhancements to existing ones
- `agents/` — new agents or enhancements to existing ones
- `system/` — cross-cutting improvements (tooling, scripts, rules, docs, evals)

Create the subdirectory if it doesn't exist yet. Write a short markdown file per suggestion with: what you observed, why it would help, and a concrete proposal. Name files descriptively (e.g., `add-caching-patterns-to-backend.md`, `new-agent-api-tester.md`).

Examples of what to log:
- A pattern you had to figure out that no skill covered
- A skill reference that was missing information you needed
- An agent that needed a skill it didn't have loaded
- A workflow that would benefit from a new agent or skill
- A domain area where you had to improvise without guidance

Do not create the skill/agent yourself — just log the suggestion. I'll review and decide what to build.

## Memory

Persistent memory lives under `~/.claude/projects/<encoded-working-dir>/memory/` — Claude Code auto-encodes the current working directory into a folder name. Primary on Windows right now: `C:\Users\Gavin Hensley\.claude\projects\C--Users-Gavin-Hensley-Projects\memory\` (for the `Projects/` workspace). Mac workstation used `~/.claude/projects/-Users-gavinhensley--claude/memory/` when active. Use this memory to store:
- Learnings about my preferences and work patterns
- Feedback I give about how to approach work
- Project context that's useful across conversations

Read memory at the start of conversations when it seems relevant. Update it when you learn something new about how I work.

## Response Style

- Be concise. Lead with action, skip filler.
- Don't summarize what you just did — I read the diff.
- Don't add docstrings/comments to code you didn't change.
- Don't add features beyond what was asked.
- Don't ask "would you like me to..." — just do it if it's within scope.
