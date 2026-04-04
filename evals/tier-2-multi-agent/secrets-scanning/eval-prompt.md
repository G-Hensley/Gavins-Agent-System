Set up a secrets scanning pipeline for this repository. I want any accidental commit of API keys, tokens, or credentials to be caught automatically before it can merge.

Use open-source tools — gitleaks and trufflehog are both options. Pick the one (or both) that gives the best coverage for a mixed Python/TypeScript codebase. Whatever you choose, explain why.

The scanning should run on every pull request and on every push to `main`. If a secret is detected, the workflow should fail the check and leave a comment on the PR (if applicable) that tells the developer what type of secret was found and where, without echoing the secret value itself.

The pipeline should also be runnable locally so developers can scan before pushing. Provide a `Makefile` target or shell script for that.

Configuration:
- The scanner config should allow baseline exceptions for known test fixtures that use fake credentials (e.g., `tests/fixtures/`)
- No secrets from production systems should be required to run the scan

Deliverables:
- `.github/workflows/secrets-scan.yml` — the GitHub Actions workflow
- Scanner config file (`.gitleaks.toml`, `.trufflehog.yml`, or equivalent)
- `scripts/scan-secrets.sh` — local scan script
- Brief explanation of tool choice and any known limitations
