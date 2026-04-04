Check the self-improvement backlog and help build the most valuable suggestion.

1. Read all files in `~/.claude/improvements/skills/` and `~/.claude/improvements/agents/`
2. If empty, say "No improvement suggestions logged yet. I'll log suggestions as I notice gaps during work."
3. If files exist, present them ranked by impact:
   - Summarize each suggestion in one line
   - Recommend which to build first and why
4. When the user picks one, use the `skill-creator` skill to build it following all standards (under 200 lines, proper frontmatter, has Process and What NOT to Do sections, references linked)
5. After building, delete the suggestion file from `improvements/`
6. Run the skill evaluator to verify: `python3 /private/tmp/evaluate-skills.py`
