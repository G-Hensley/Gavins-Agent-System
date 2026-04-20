Run the `git-health-check` skill against the current repo.

Detects and optionally repairs:

1. **HEAD integrity** — trailing-slash truncation, missing newline, missing ref target, invalid detached sha
2. **Corruption artifacts** — `.git/*.corrupt*`, `*.bak`, `*.orig` left from prior recoveries
3. **Dangling locks** — `.git/*.lock` files older than 5 minutes (crashed writers)
4. **Stranded dependabot branches** — report count + dates, don't auto-delete
5. **Remote divergence** — `git fetch --dry-run` to surface rejected pushes / forced updates
6. **External writer presence** — flag `.git/gk/` (GitKraken) and `.git/filter-repo/` activity

Invoke with `--fix` to apply the safe repairs (HEAD restore, `.corrupt.backup` cleanup, stale lock removal).

Invoke with no flag for read-only diagnostic output.

Full process: `skills/git-health-check/SKILL.md`.
