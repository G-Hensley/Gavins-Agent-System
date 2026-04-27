# Split `scripts/install.sh` into focused units

## Observed
While adding `--backup-local` (delegating to `scripts/backup-local.sh`),
the install.sh file-size hook fired: 519 lines, well over the 200-line cap
in CLAUDE.md. The file was already 493 lines before the change, so the cap
violation predates this work.

## Why this matters
- The hook fires on every edit, training us to ignore size warnings rather
  than fix them. Once one production file is "grandfathered in," the rule
  loses force everywhere else.
- A 500-line install script mixes prereq checks, preflight symlink probing,
  symlink/backup orchestration, plugin install, and hooks JSON merging. A
  bug in any one block makes the whole script harder to reason about.
- Adding the next install-time concern (e.g., a `--restore` companion to
  `--backup-local`, MCP-server wiring, etc.) will push it further out of
  spec.

## Proposal
Refactor `scripts/install.sh` into a thin orchestrator (~80 lines) that
sources focused helpers from `scripts/install/`:

- `scripts/install/prereqs.sh` — `check_prereqs`, optional-tool list
- `scripts/install/symlinks.sh` — `DIRS=(...)`, `check_symlink`, the link/backup
  loop, the symlink-capability preflight
- `scripts/install/config.sh` — CONFIG_FILES, plugins/installed_plugins.json,
  settings.json template copy, gh-account-guard.conf.example
- `scripts/install/hooks.sh` — the inline Python that merges
  `config/hooks.json` into `~/.claude/settings.json`
- `scripts/install/plugins.sh` — `claude plugin install` loop driven by
  `config/plugins/plugins.json`

`install.sh` itself stays as the user-facing entrypoint: argument parsing,
mode dispatch (`--verify`, `--check-prereqs`, `--backup-local`, `--dry-run`,
default install), and final "Done!" output.

`scripts/backup-local.sh` (just added) is already a sibling helper and
fits the same pattern — keep it parallel rather than collapsing it back
into install.sh.

## Out of scope
- Behavior changes — pure refactor, same flags, same outputs.
- `backup-local.sh` itself (97 lines, well under cap).

## Effort
Half-day. No new tests required if we add a smoke `bats` (or shell-based)
harness that runs `install.sh --dry-run` and snapshots the output before
and after the split — guarantees zero behavior drift.
