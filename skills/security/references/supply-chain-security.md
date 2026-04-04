# Supply Chain Security

## Dependency Auditing
- Run `npm audit` / `pip audit` / `cargo audit` before merging dependency changes
- Review new dependencies before adding: check maintainer reputation, download count, last update date
- Prefer well-maintained packages with many contributors over single-maintainer packages

## Lock Files
- Always commit lock files (package-lock.json, pnpm-lock.yaml, poetry.lock, Cargo.lock)
- Use `--frozen-lockfile` in CI to prevent surprise updates
- Review lock file changes in PRs — large diffs may indicate unexpected transitive updates

## Version Pinning
- Pin exact versions for production dependencies
- Use ranges only for development dependencies where flexibility is acceptable
- Update dependencies intentionally, not automatically in production

## Known Vulnerability Scanning
- Integrate vulnerability scanning in CI (Dependabot, Snyk, npm audit)
- Set severity thresholds — block merges on critical/high vulnerabilities
- Have a process for evaluating and patching flagged vulnerabilities
- Don't ignore vulnerabilities without documenting the reason

## Common Anti-Patterns
| Anti-Pattern | Fix |
|---|---|
| No lock file committed | Commit and enforce lock file |
| `npm install` in CI | Use `npm ci --frozen-lockfile` |
| Ignoring audit warnings | Review and patch or document exceptions |
| Adding deps without review | Check maintainer, age, download count first |
| Running postinstall scripts blindly | Review what scripts do before running |
