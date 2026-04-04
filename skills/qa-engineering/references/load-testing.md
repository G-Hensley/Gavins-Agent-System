# Load Testing

## Types of Load Tests
- **Baseline**: normal expected load — establish performance metrics
- **Stress**: 2-3x normal load — find breaking points
- **Spike**: sudden burst — test auto-scaling and recovery
- **Soak**: sustained load over hours — find memory leaks, connection pool exhaustion

## Process
1. Define SLOs (acceptable latency, error rate, throughput)
2. Create realistic test scenarios (not just GET /)
3. Establish baseline metrics
4. Run incremental load increases
5. Identify bottlenecks
6. Fix and re-test

## Key Metrics
- **Latency**: p50, p95, p99 response times
- **Throughput**: requests per second
- **Error rate**: % of failed requests
- **Resource usage**: CPU, memory, connections, queue depth

## Bottleneck Identification
- **CPU-bound**: high CPU, latency scales with load → optimize code, add instances
- **Memory-bound**: growing memory, eventually OOM → fix leaks, increase memory
- **IO-bound**: low CPU, high latency → optimize queries, add caching, connection pooling
- **Connection-limited**: errors at specific concurrency → increase pool size, use connection reuse

## Test Scenarios
Design scenarios that match real user behavior:
```
Scenario: Dashboard Load
1. Login (POST /api/auth)
2. Fetch dashboard (GET /api/dashboard)
3. Fetch recent scans (GET /api/scans?limit=20)
4. View scan detail (GET /api/scans/:id)
5. Think time: 2-5 seconds between actions
```

## When to Load Test
- Before major releases
- After significant architecture changes
- When adding new infrastructure (new database, new service)
- When changing caching strategy
- Periodically (monthly) for regression detection
