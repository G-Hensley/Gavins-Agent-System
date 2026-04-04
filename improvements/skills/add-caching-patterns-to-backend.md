# Add Caching Patterns to Backend Engineering Skill

## What I Observed

The `backend-engineering` skill's reference files (`python-patterns.md`, `node-patterns.md`, `java-patterns.md`, `api-design.md`) have no coverage of caching — no Redis, no Memcached, no HTTP cache headers, no TTL strategy guidance.

Surfaced during the Tier 1 REST endpoint eval design. A typical CRUD endpoint benefits from read-through caching on GET routes, but there's nothing in the skill to guide that decision or its implementation.

## Why It Would Help

Agents implementing backend services will reach for a database on every request unless guided otherwise. Caching is a standard reliability and performance concern — not a speculative optimization. Without skill coverage:

- Agents don't know when to add a cache layer vs. optimize a query
- There's no TTL guidance, so agents either skip expiry or pick arbitrary values
- Cache invalidation on writes is never addressed

## Proposal

Add `skills/backend-engineering/references/caching-patterns.md` covering:

- **When to cache**: read-heavy vs. write-heavy workloads, acceptable staleness, idempotent vs. mutable data
- **Cache-aside pattern** (explicit read/write logic, the most common pattern for application-layer caching)
- **TTL strategy**: short (seconds) for volatile data, long (minutes/hours) for stable lookups, no TTL for static reference data
- **Cache invalidation**: invalidate on write, don't rely on expiry alone for correctness-critical data
- **Redis basics**: key naming conventions (`resource:id:field`), data types to use (string for JSON blobs, hash for partial updates), connection pooling
- **HTTP caching**: `Cache-Control` headers, ETags for conditional GET, when to use CDN vs. application cache
- **Pitfalls to avoid**: thundering herd on cold start, caching errors, unbounded key growth

Also reference this file from `SKILL.md` under the references section.
