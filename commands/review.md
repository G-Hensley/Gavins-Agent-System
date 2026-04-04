Run a security review on the current changes. Determine which files have been modified using `git diff --name-only HEAD~1` (or unstaged changes if nothing is committed).

Based on the files changed, dispatch the RIGHT security specialist agents:

- React/Next.js components, CSS, client-side code → `frontend-security-reviewer`
- API endpoints, handlers, services, auth logic, database queries → `backend-security-reviewer`
- CloudFormation, CDK, Terraform, IAM policies, S3 configs, Lambda configs → `cloud-security-reviewer`
- package.json/lock changes, new dependencies, auth flow changes, CI/CD configs → `appsec-reviewer`

Dispatch multiple specialists in parallel if changes span domains. After all reviews complete, summarize findings by severity (Critical → Important) with specific file:line references and fixes.

If no high-confidence issues found, confirm which domains were checked and that the changes look clean.
