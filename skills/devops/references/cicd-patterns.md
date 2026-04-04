# CI/CD Patterns

## Pipeline Stage Order (cheapest first)
1. **Lint** — seconds, catches style/syntax
2. **Type check** — seconds, catches type errors
3. **Unit tests** — seconds to minutes, catches logic bugs
4. **Build** — minutes, catches compilation/bundling issues
5. **Integration tests** — minutes, catches cross-component issues
6. **Security scan** — minutes, catches vulnerabilities
7. **E2E tests** — minutes, catches user-facing bugs
8. **Deploy to staging** — minutes
9. **Smoke tests on staging** — minutes
10. **Deploy to production** — minutes

Fail fast: if lint fails, don't run expensive E2E tests.

## GitHub Actions Patterns
```yaml
jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: 'pnpm' }
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint
      - run: pnpm test

  deploy:
    needs: lint-and-test
    if: github.ref == 'refs/heads/main'
    # ...
```

## Caching
- Cache dependencies (`node_modules`, `.venv`, `~/.m2`)
- Cache build outputs when possible
- Use lock file hash as cache key: `hashFiles('pnpm-lock.yaml')`

## Deployment Strategies
- **Rolling**: replace instances gradually (default, simple)
- **Blue-green**: run two environments, switch traffic (zero downtime, instant rollback)
- **Canary**: route small % of traffic to new version, monitor, expand
- Choose based on risk tolerance and infrastructure

## Secrets in CI
- Use GitHub Secrets or AWS Secrets Manager
- Never echo secrets in logs
- Rotate secrets on schedule
- Use OIDC for cloud provider authentication (no static keys)
