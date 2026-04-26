---
name: task-tracking
description: Track work-in-progress and shipped tasks via `docs/TASKS.md` across sessions. Pairs with `TodoWrite` for in-session sub-steps. Use when starting work in a project, completing tasks that need to persist across sessions, picking up where an earlier session left off, or when the user says "what's next", "where are we", "track this", or "add a task".
last_verified: 2026-04-26
---

# Task Tracking

Cross-session task state for any project. Markdown by default — version-controlled, diff-friendly, no setup.

## Substrate decision

Default to `docs/TASKS.md`. Do not negotiate this on every project.

| Store | When | Why |
|---|---|---|
| `docs/TASKS.md` | Default — every project | Free, native to Read/Edit/Grep, version-controlled, PR diffs show task state changes |
| `docs/tasks.db` (SQLite) | Only when `wc -l docs/TASKS.md` exceeds ~600 lines AND queries become a bottleneck | Real queries on large data; opt-in escape hatch |
| Vector DB | Never for this | Tasks are structured; semantic search solves a problem you don't have |

## Process

### Phase 1: Bootstrap (once per project)

When a project doesn't yet have `docs/TASKS.md`, create it from the template at `references/tasks-template.md`. This is a one-time copy — `mkdir -p docs && cp <skill-root>/references/tasks-template.md docs/TASKS.md`. After bootstrap, make `docs/TASKS.md` a tracked file in the project's first commit.

`project-scaffolding` should call this skill during new-project setup.

### Phase 2: Load at session start

At the start of any session that does real work, read `docs/TASKS.md`:

- Surface the `## In Progress` section verbatim — these are the tasks the previous session left mid-flight
- Note any `Awaiting` or `Blocked` entries from `## Backlog`
- Pin in-progress task IDs to the current conversation context

If the file doesn't exist, ask the user whether to bootstrap.

### Phase 3: Add a task

Adding a task is two operations:

1. Determine the next ID. Grep `docs/TASKS.md` and `docs/TASKS.archive.md` (if present) for `TASK-` and take `max + 1`. IDs are repo-scoped (`TASK-12`), not project-namespaced.
2. Append the task to the appropriate section. New work → `## Backlog`. Work starting now → `## In Progress`.

Task entry format:

```
- [ ] [TASK-N] Short description
  - assignee: claude | gavin | <name>
  - PR: #<n> (when one exists)
  - depends-on: [TASK-M] (optional)
```

Keep fields minimal. Add fields only when the task needs them.

### Phase 4: Move status

A task's status is its section. Moving status = moving the bullet from one section to another:

- `Backlog` → `In Progress` — when work starts. Add `assignee:` if not present.
- `In Progress` → `Done` — when the PR merges, OR when the task ships. Strike out `[ ]` → `[x]` and append the close-line: `closed via #<pr>` or `shipped <date>`.
- Any → `Backlog` — when work is paused without resolution. Note the reason inline.

A task moves once. Don't bounce tasks back and forth — that signals scope creep that should be split into a new task.

### Phase 5: Archive

When `## Done` exceeds ~30 entries, prune the oldest into `docs/TASKS.archive.md`:

1. Append the rows being moved to `docs/TASKS.archive.md` (create the file if it doesn't exist; bootstrap the file with the same `# Tasks` header but only `## Done` section)
2. Delete the moved rows from `docs/TASKS.md`'s `## Done`
3. Commit as `chore(tasks): archive N done tasks`

Archive is **explicit** — Claude runs it when prompted or when the file gets noisy. Do NOT wire it to a hook on Edit of TASKS.md; hooks should not silently rewrite operator files.

## Pairing with TodoWrite

Two layers, different lifetimes:

| Layer | Scope | Persistence | Tool |
|---|---|---|---|
| `docs/TASKS.md` | Cross-session canonical state | Persistent (in git) | Read / Edit |
| `TodoWrite` | In-session sub-steps under the active TASK | Session only | TodoWrite |

When working on a task: load TASKS.md, pin the active task ID, then dispatch `TodoWrite` for the sub-steps that don't deserve their own TASK entry. Don't duplicate TodoWrite content back into TASKS.md.

## What NOT to Do

- Do not negotiate the substrate per project — markdown unless `wc -l` says otherwise
- Do not auto-archive via hook — keep archive explicit
- Do not bounce tasks between sections; one move per task lifecycle
- Do not duplicate TodoWrite sub-steps into TASKS.md
- Do not invent fields beyond `assignee` / `PR` / `depends-on` without first checking whether the new field is really task-scoped or project-scoped (project-scoped → CONTEXT.md, not TASKS.md)
- Do not commit `docs/tasks.db` or any binary task store unless the substrate decision was deliberately escalated
- Do not put PR titles or commit messages in TASKS.md — task descriptions stay short; the PR diff is the source of truth for what shipped

## References

- `references/tasks-template.md` — the markdown template for `docs/TASKS.md` bootstrap
- `TodoWrite` — Claude Code's built-in in-session task tool, used for sub-steps under an active TASK
- `project-scaffolding` skill — should call Phase 1 (Bootstrap) when scaffolding a new project
- `subagent-driven-development` skill — moves task status between phases as it executes a plan (per the per-task PR rhythm extension, when that ships)
