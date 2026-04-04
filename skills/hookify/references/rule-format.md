# Hookify Rule Format

## Basic Rule Structure

```markdown
---
name: rule-identifier
enabled: true
event: bash|file|stop|prompt|all
pattern: regex-pattern
action: warn|block
---

Message shown when rule triggers. Supports markdown.
```

## Fields

| Field | Required | Values | Notes |
|-------|----------|--------|-------|
| `name` | Yes | kebab-case | Start with verb: warn, block, prevent, require |
| `enabled` | Yes | true/false | Toggle without deleting |
| `event` | Yes | bash, file, stop, prompt, all | What triggers the check |
| `pattern` | For simple rules | Python regex | Matches command (bash) or new_text (file) |
| `action` | No | warn (default), block | warn = show message; block = prevent operation |
| `conditions` | For complex rules | Array | Multiple conditions (see below) |

## Event Types

- **bash**: Matches Bash tool commands
- **file**: Matches Edit, Write, MultiEdit tools
- **stop**: Matches when agent wants to stop
- **prompt**: Matches when user submits prompts
- **all**: Matches all events

## Complex Rules with Conditions

```yaml
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.env$
  - field: new_text
    operator: contains
    pattern: API_KEY
```

Operators: `regex_match`, `contains`, `equals`, `not_contains`, `starts_with`, `ends_with`

Fields for file events: `file_path`, `new_text`
Fields for bash events: `command`
Fields for stop events: `transcript`

## Pattern Examples

**Bash patterns:**
- Dangerous commands: `rm\s+-rf|chmod\s+777|dd\s+if=`
- Package installs: `npm\s+install\s+|pip\s+install`
- Force operations: `--force|--hard|-f\s`

**File patterns:**
- Code smells: `console\.log\(|eval\(|innerHTML\s*=`
- Sensitive paths: `\.env$|\.env\.|credentials|secrets`
- Debug artifacts: `debugger;|TODO.*HACK|FIXME`

## Security Rule Templates

Copy these directly into `.claude/hookify.{name}.local.md` files:

### Block dangerous rm
```markdown
---
name: block-dangerous-rm
enabled: true
event: bash
pattern: rm\s+-rf
action: block
---
Dangerous rm command detected. Verify the path is correct and consider a safer approach.
```

### Warn on sensitive files
```markdown
---
name: warn-sensitive-files
enabled: true
event: file
action: warn
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.env$|\.env\.|credentials|secrets|\.secret|_key\.
---
Editing a file that may contain sensitive data. Ensure credentials are not hardcoded, use environment variables, and verify this file is in .gitignore.
```

### Warn on security anti-patterns
```markdown
---
name: warn-security-antipatterns
enabled: true
event: file
pattern: eval\(|new\s+Function\(|innerHTML\s*=|document\.write\(|os\.system\(|pickle\.load
action: warn
---
Security anti-pattern detected. Consider safer alternatives:
- eval/new Function → use JSON.parse or structured parsing
- innerHTML/document.write → use textContent or DOM APIs
- os.system → use subprocess with shell=False
- pickle.load → use json.load for untrusted data
```

### Require tests before stop
```markdown
---
name: require-tests-before-stop
enabled: false
event: stop
action: block
conditions:
  - field: transcript
    operator: not_contains
    pattern: npm test|pytest|cargo test|vitest|pnpm test
---
No test commands found in this session. Run tests to verify changes before stopping.
```

### Block committing secrets
```markdown
---
name: block-commit-secrets
enabled: true
event: bash
pattern: git\s+add.*\.env|git\s+add\s+-A|git\s+add\s+\.
action: warn
---
Git add detected that may include sensitive files. Verify .env, credentials, and secret files are excluded. Prefer adding specific files by name over `git add .` or `git add -A`.
```
