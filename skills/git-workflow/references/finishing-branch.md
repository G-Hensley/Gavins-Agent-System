# Finishing a Development Branch

Structured completion: verify tests → present options → execute → clean up.

## Step 1: Verify Tests
Run the project's test suite. If tests fail: stop, report failures, do not proceed.

## Step 2: Determine Base Branch
```bash
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

## Step 3: Present Options
```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work
```

## Step 4: Execute Choice

**Option 1 — Merge locally**: checkout base, pull latest, merge feature branch, verify tests on merged result, delete feature branch, cleanup worktree.

**Option 2 — Create PR**: push branch with `-u`, create PR via `gh pr create` with summary and test plan, keep worktree until PR merges.

**Option 3 — Keep as-is**: report branch name and worktree path. Do not cleanup.

**Option 4 — Discard**: require typed "discard" confirmation. Show what will be deleted (branch, commits, worktree). If confirmed: checkout base, force-delete branch, cleanup worktree.

## Step 5: Cleanup Worktree
For options 1 and 4: `git worktree remove <path>`. For option 2: keep worktree. For option 3: keep everything.
