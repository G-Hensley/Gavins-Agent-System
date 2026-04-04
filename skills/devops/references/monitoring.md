# Monitoring & Observability

## Three Pillars
- **Logs**: structured, contextual (request ID, user, operation)
- **Metrics**: quantitative measurements (latency, error rate, throughput)
- **Traces**: request flow across services (distributed tracing)

## What to Monitor (SLIs)
Focus on user-facing indicators:
- **Availability**: % of successful requests
- **Latency**: p50, p95, p99 response times
- **Error rate**: % of 5xx responses
- **Throughput**: requests per second

## Alerting Strategy
- Alert on symptoms (user impact), not causes (CPU usage)
- Set thresholds based on SLOs, not arbitrary numbers
- Every alert should be actionable — if you can't act on it, remove it
- Use severity levels: critical (pages), warning (ticket), info (dashboard)

## Structured Logging
```json
{
  "level": "error",
  "message": "Failed to process scan",
  "requestId": "req-123",
  "customerId": "cust-456",
  "error": "ConnectionTimeout",
  "duration_ms": 5000
}
```
- JSON format for machine parsing
- Include context (request ID, user, operation)
- Never log sensitive data (passwords, tokens, PII)

## CloudWatch (AWS)
- Use metric filters on log groups for custom metrics
- Set up dashboards for key SLIs
- Use Composite Alarms to reduce noise
- Set log retention periods (don't keep everything forever)

## Runbook for Every Alert
Every alert should link to a runbook with:
1. What this alert means
2. How to investigate
3. How to remediate
4. Who to escalate to
