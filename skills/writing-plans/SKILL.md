---
name: writing-plans
description: Create detailed implementation plans from technical designs or specs. Use when you have a spec, architecture doc, or requirements for a multi-step task — before writing any code. Also use when the user says "write a plan", "break this down", "implementation plan", or when transitioning from architecture to coding.
---

# Writing Plans

Break a technical design into bite-sized, executable tasks. Assume the implementer has zero context for the codebase. Document exact files, complete code, exact commands, and expected output for every step.

## Scope Check

If the spec covers multiple independent subsystems, suggest breaking into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## Process

### 1. Map File Structure
Before defining tasks, declare which files will be created or modified and what each is responsible for.
- Each file has one clear responsibility
- Files that change together live together — split by responsibility, not by layer
- In existing codebases, follow established patterns
- Prefer smaller, focused files over large ones

### 2. Write Tasks
Each task produces self-contained, committable changes. Follow TDD within every task.

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**
```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test — verify it fails**
Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**
```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test — verify it passes**
Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**
```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

Each step is one action (2-5 minutes). "Write test", "run test", "implement", "run test", "commit" — each is its own step.

### 3. Save the Plan
Save to project docs (e.g., `docs/plans/YYYY-MM-DD-<feature-name>.md`). Include a header:
```markdown
# [Feature Name] Implementation Plan
**Goal:** [One sentence]
**Architecture:** [2-3 sentences]
**Tech Stack:** [Key technologies]
```

### 4. Review
- Dispatch plan-reviewer subagent (`plan-reviewer` subagent)
- Fix issues, re-dispatch (max 3 iterations, then surface to user)

### 5. Hand Off for Execution
Offer the user a choice:
- **Subagent-driven** (recommended for larger plans) — fresh subagent per task with review between tasks. Use `subagent-driven-development` skill.
- **Inline execution** (for smaller plans) — execute tasks sequentially in current session. Use `executing-plans` skill.

## What NOT to Do

- Do not write vague steps like "add validation" — include the actual code
- Do not skip file paths — every step names exact files
- Do not skip expected output — every test run states what to expect
- Do not create large tasks — if a task takes more than 15 minutes, split it
- Do not skip the TDD cycle within tasks — test first, implement, verify, commit

## Reference Files

- `plan-reviewer` subagent (in `~/.claude/agents/`) — Subagent prompt for reviewing implementation plans
