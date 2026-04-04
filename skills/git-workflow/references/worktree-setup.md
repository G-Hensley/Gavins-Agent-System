# Worktree Setup

Create isolated workspaces sharing the same repository.

## Directory Selection (Priority Order)

1. **Check existing**: `.worktrees/` or `worktrees/` — use if found (`.worktrees/` wins if both exist)
2. **Check CLAUDE.md**: `grep -i "worktree" CLAUDE.md` — use preference if specified
3. **Ask user**: offer project-local (`.worktrees/`) or global location

## Creation Process

### 1. Safety Verification (project-local only)
```bash
git check-ignore -q .worktrees 2>/dev/null
```
If NOT ignored: add to `.gitignore` and commit before proceeding.

### 2. Create Worktree
```bash
git worktree add <path>/<branch-name> -b <branch-name>
cd <path>/<branch-name>
```

### 3. Run Project Setup
Auto-detect from project files:
- `package.json` → `npm install` (or `pnpm install`)
- `Cargo.toml` → `cargo build`
- `requirements.txt` → `pip install -r requirements.txt`
- `pyproject.toml` → `poetry install` or `pip install -e .`
- `go.mod` → `go mod download`

### 4. Verify Clean Baseline
Run the project's test suite. If tests fail: report failures, ask whether to proceed. If tests pass: report ready.

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```
