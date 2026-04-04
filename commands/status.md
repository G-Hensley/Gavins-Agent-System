Show the current state of the skills, agents, and plugins system.

Run these checks and report:

1. **Skills** — List all skills in `~/.claude/skills/`, count total, check if any SKILL.md exceeds 200 lines
2. **Agents** — List all agents in `~/.claude/agents/`, count total, group by type (engineers, reviewers, security, pipeline)
3. **Plugins** — List enabled plugins from `~/.claude/settings.json`
4. **Improvements backlog** — Count pending suggestions in `~/.claude/improvements/skills/` and `~/.claude/improvements/agents/`
5. **Memory** — List memory files in the current project's memory directory
6. **Health check** — Run `python3 /private/tmp/evaluate-skills.py` if the evaluator exists, otherwise just report file counts

Present as a clean summary table. Flag any issues (oversized files, missing references, empty directories).
