# Eval Prompt

Give the backend-security-reviewer agent this prompt:

---

Review the Express.js application at `evals/review-challenges/sql-injection/app.js` for SQL injection vulnerabilities. Check every database query for proper parameterization and identify any endpoints where user input could be used to manipulate SQL execution. Rate each finding by severity.

---

## Expected Agent Behavior

The agent should:

1. Read `app.js` and `package.json.fixture` to understand the stack (Express + better-sqlite3)
2. Trace user input from each request handler into database queries
3. Identify injection vectors with severity ratings and remediation advice
4. NOT flag properly parameterized queries as vulnerable
