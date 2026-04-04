# Improvements Backlog

Suggestions for evolving the agent system. Each suggestion is a standalone markdown file in one of three subdirectories.

## Subdirectories

### `skills/`

Improvements to existing skills or proposals for new skills. Use this when:
- A skill is missing guidance you needed during real work
- A reference file was incomplete or wrong
- A new pattern emerged that no skill covers
- A skill's reference files are stale or need updating

### `agents/`

Improvements to existing agents or proposals for new agents. Use this when:
- An agent lacked a skill it clearly needed
- An agent's scope or dispatch conditions are wrong
- A new specialist role is needed that no current agent fills
- An agent's instructions produced consistently bad behavior

### `system/`

Cross-cutting improvements to workflow, tooling, config, or the eval infrastructure. Use this when:
- A workflow step has no documentation
- A build/validation tool is missing
- The eval suite needs structural changes
- CLAUDE.md, CONTEXT.md, or the dispatch table needs revision

## File Format

Each suggestion is a markdown file with this structure:

```markdown
# Title

## What I Observed
Concrete description of the gap, problem, or opportunity. Reference the task or eval where it surfaced.

## Why It Would Help
What breaks or degrades without this? What would improve?

## Proposal
Specific, actionable change. Name files, functions, fields, or steps by name. If it's a new file, sketch the structure.
```

## Naming Convention

Descriptive kebab-case. Lead with the action verb:

- `add-caching-patterns-to-backend.md`
- `add-threat-modeler-to-tier2-evals.md`
- `fix-skill-router-missing-security-entry.md`
- `new-agent-threat-modeler.md`

## Promotion Process

1. Suggestions accumulate here during eval runs and real project work
2. Review the backlog weekly (or after a system change)
3. Promote a suggestion: implement the change, then delete the suggestion file
4. If a suggestion is rejected or superseded, delete it with a note in the commit message

Do not implement changes directly from this directory. Log here, review, then implement.
