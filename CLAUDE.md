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

## Code Standards

- **File size:** SKILL.md and agent files under 200 lines. Reference files under 200 lines. Production code files — if it's getting long, it's doing too much.
- **Naming:** kebab-case for files/folders, camelCase for JS/TS variables, snake_case for Python. Descriptive names — `fetchCustomerScans` not `getData`.
- **Commits:** small and frequent. One logical change per commit. Message format: `type: description` (feat, fix, refactor, test, docs, chore).
- **No dead code.** Delete unused functions, imports, variables. Don't comment out code "for later."

## Stack Preferences

- **Python**: dataclasses, argparse, asyncio, typing, Pydantic. Rate limiting at 8 req/s. Shared auth via Cognito SRP.
- **TypeScript**: Zod validation, Zustand state, strict types. No `any`.
- **React**: function components, hooks, server components default. Props interfaces on every component.
- **Next.js**: App Router. Server components for data, client components pushed to leaves.
- **CSS**: Tailwind with design system values from config. No arbitrary values.
- **AWS**: Lambda, DynamoDB, S3, Cognito, Secrets Manager, EventBridge. Least-privilege IAM always.
- **Testing**: pytest (Python), Vitest (TS), Playwright (E2E).

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
| Multi-task implementation | Use `subagent-driven-development` skill with `implementer` agent per task |

## Security

- Never commit .env, credentials, API keys, or secrets
- Validate all input at system boundaries
- Parameterized queries only — never string concatenation
- Least-privilege IAM — no wildcards on actions or resources
- Check `npm audit` / `pip audit` when adding dependencies
- Dispatch security specialist agents proactively when touching auth, APIs, or infrastructure

## Self-Improvement

Actively look for ways to improve the skills and agents system. When you notice a gap, pattern, or opportunity during work, log it:

- **`~/.claude/improvements/skills/`** — suggestions for new skills or enhancements to existing ones
- **`~/.claude/improvements/agents/`** — suggestions for new agents or enhancements to existing ones

Write a short markdown file per suggestion with: what you observed, why it would help, and a concrete proposal. Name files descriptively (e.g., `add-caching-patterns-to-backend.md`, `new-agent-api-tester.md`).

Examples of what to log:
- A pattern you had to figure out that no skill covered
- A skill reference that was missing information you needed
- An agent that needed a skill it didn't have loaded
- A workflow that would benefit from a new agent or skill
- A domain area where you had to improvise without guidance

Do not create the skill/agent yourself — just log the suggestion. I'll review and decide what to build.

## Memory

Persistent memory lives at `~/.claude/projects/-Users-gavinhensley--claude/memory/`. Use it to store:
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
