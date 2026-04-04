---
name: git-workflow
description: Complete git workflow — worktree setup, commits, pushing, PRs, branch cleanup, and finishing development branches. Use when doing any git operation including committing, pushing, creating PRs, setting up worktrees, cleaning up branches, or finishing implementation work. Also use when the user says "commit", "push", "create a PR", "set up a worktree", "clean up branches", "I'm done", or "ready to merge".
---

# Git Workflow

All git operations from workspace setup through branch completion.

## Process

### Phase 1: Setup — Create Worktree
Use when starting work that needs isolation. See `references/worktree-setup.md`.

### Phase 2: Quick Actions — Commit, Push, Clean
Use for fast git operations during development. See `references/quick-commands.md`.

### Phase 3: Finish — Merge, PR, Cleanup
Use when implementation is complete and ready to integrate. See `references/finishing-branch.md`.

Choose the phase that matches where you are in the workflow. Phases are independent — you don't need to go through all three sequentially.

## What NOT to Do

- Do not commit files that likely contain secrets (.env, credentials.json, .secret, *_key, *_token)
- Do not force-push without explicit user request
- Do not commit on main/master without explicit consent — create a branch first
- Do not create project-local worktrees without verifying gitignore
- Do not proceed with failing tests when finishing a branch
- Do not merge without verifying tests on the merged result
- Do not delete work without typed confirmation
- Do not skip baseline test verification when creating worktrees

## Reference Files

- `references/worktree-setup.md` — Create isolated worktrees with directory selection, safety verification, project setup, and baseline testing. Read when starting isolated feature work.
- `references/quick-commands.md` — Commit, commit-push-PR, and clean-gone-branches commands. Read for fast git operations during development.
- `references/finishing-branch.md` — Test verification, 4 structured completion options (merge/PR/keep/discard), and worktree cleanup. Read when implementation is done.
