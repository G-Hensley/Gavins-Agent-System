---
name: hookify
description: Create and manage Claude Code hooks that warn or block unwanted behaviors. Use when the user wants to prevent dangerous commands, protect sensitive files, enforce coding patterns, or create automated safety checks. Also use when the user says "create a hook", "block this", "warn me when", "don't let me", or "add a safety rule".
---

# Hookify

Create hook rules that automatically warn or block unwanted behaviors during Claude Code sessions.

## Process

### 1. Identify the Behavior
Either from explicit user instructions ("block rm -rf") or by analyzing conversation for:
- Corrections or reversions (user fixing Claude's actions)
- Frustrated reactions ("why did you do X?")
- Repeated issues (same problem multiple times)
- Explicit requests ("don't do X", "stop doing Y")

### 2. Determine Action
Ask the user: "Should this **warn** (show message, allow operation) or **block** (prevent operation)?"

### 3. Create the Rule File
Write to `.claude/hookify.{rule-name}.local.md` in the current project directory. See `references/rule-format.md` for syntax and patterns.

Naming convention: kebab-case, start with action verb — `block-dangerous-rm`, `warn-sensitive-files`, `require-tests-before-stop`.

### 4. Confirm and Test
- Verify the file was created in the correct project `.claude/` directory (NOT the plugin directory)
- Rules are active immediately — no restart needed
- Test by triggering the pattern

## What NOT to Do

- Do not create rule files in the plugin's `.claude/` directory — use the project's `.claude/`
- Do not default to `block` — use `warn` unless the user explicitly wants blocking
- Do not write overly broad patterns that trigger on false positives
- Do not skip asking the user whether to warn or block

## Reference Files

- `references/rule-format.md` — Rule file syntax, event types, pattern examples, conditions, and ready-to-use security templates. Read when creating any rule.
