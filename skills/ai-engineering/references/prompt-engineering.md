# Prompt Engineering

## Core Principles
- Be specific about the task, format, and constraints
- Show examples of desired output (few-shot) when format matters
- Put the most important instructions first — models attend more to the beginning
- Explain *why* when giving constraints — models follow reasoning better than rules

## System Prompts
Define the agent's role, capabilities, and boundaries upfront.
```
You are a [role] that [does what].
You have access to [tools/data].
Always [key behavior]. Never [anti-behavior].
When uncertain, [fallback behavior].
```

## Structured Output
Request specific formats for reliable parsing:
```
Respond with JSON matching this schema:
{
  "analysis": "string — your assessment",
  "confidence": "number 0-100",
  "action": "string — recommended next step"
}
```

## Few-Shot Examples
Show 2-3 examples of input → output when the task format isn't obvious:
```
Example 1:
Input: "Add user authentication"
Output: {"category": "feature", "priority": "high", "effort": "large"}

Example 2:
Input: "Fix typo in README"
Output: {"category": "docs", "priority": "low", "effort": "small"}
```

## Context Management
- Curate context — don't dump everything. Include only what the task needs.
- For code tasks: relevant files, not the whole repo
- For analysis: specific data, not raw dumps
- Summarize long contexts before passing to the next agent

## Prompt Anti-Patterns
- Vague instructions ("do it well") → specify what "well" means
- Contradictory constraints → resolve conflicts before prompting
- Too many instructions at once → prioritize and sequence
- No examples when format matters → add 2-3 few-shot examples
- Entire codebase as context → curate relevant files only
