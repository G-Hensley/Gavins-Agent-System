# Quick Git Commands

Fast-action git operations. Execute immediately — no planning phase needed.

## /commit — Create a git commit

1. Read git context:
   - `git status` — what's changed
   - `git diff HEAD` — actual changes
   - `git branch --show-current` — current branch
   - `git log --oneline -10` — recent commits for style matching
2. Check for sensitive files (.env, credentials.json, .secret, API keys). Warn and exclude if found.
3. Match commit message style from recent commits in this repo.
4. Stage relevant files and create the commit.

## /commit-push-pr — Commit, push, and open a PR

1. Read git context (same as /commit above).
2. Read full branch history: `git log main..HEAD --oneline` to understand ALL changes on this branch.
3. Check for sensitive files — warn and exclude if found.
4. Create a new branch if currently on main/master.
5. Stage and commit with a message matching repo conventions.
6. Push the branch: `git push -u origin <branch>`.
7. Create PR with `gh pr create` — write PR body from full branch history. Include summary and test plan.

## /clean-gone — Remove stale local branches

1. List branches: `git branch -v`
2. List worktrees: `git worktree list`
3. For each branch marked `[gone]`:
   - Remove associated worktree if it exists (not the main worktree)
   - Delete the branch with `git branch -D`
4. Report what was removed. If nothing was `[gone]`, report no cleanup needed.
