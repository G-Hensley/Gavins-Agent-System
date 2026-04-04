# Condition-Based Waiting

Flaky tests often guess at timing with arbitrary delays. This creates race conditions where tests pass on fast machines but fail under load or in CI.

**Wait for the actual condition you care about, not a guess about how long it takes.**

## When to Use

- Tests have arbitrary delays (`setTimeout`, `sleep`, `time.sleep()`)
- Tests are flaky (pass sometimes, fail under load)
- Tests timeout when run in parallel
- Waiting for async operations to complete

Do NOT use when testing actual timing behavior (debounce, throttle). Document WHY if using an arbitrary timeout.

## Core Pattern

```typescript
// BAD: Guessing at timing
await new Promise(r => setTimeout(r, 50));
const result = getResult();

// GOOD: Waiting for condition
await waitFor(() => getResult() !== undefined);
const result = getResult();
```

## Quick Patterns

| Scenario | Pattern |
|----------|---------|
| Wait for event | `waitFor(() => events.find(e => e.type === 'DONE'))` |
| Wait for state | `waitFor(() => machine.state === 'ready')` |
| Wait for count | `waitFor(() => items.length >= 5)` |
| Wait for file | `waitFor(() => fs.existsSync(path))` |

## Implementation

```typescript
async function waitFor<T>(
  condition: () => T | undefined | null | false,
  description: string,
  timeoutMs = 5000
): Promise<T> {
  const startTime = Date.now();
  while (true) {
    const result = condition();
    if (result) return result;
    if (Date.now() - startTime > timeoutMs) {
      throw new Error(`Timeout waiting for ${description} after ${timeoutMs}ms`);
    }
    await new Promise(r => setTimeout(r, 10));
  }
}
```

## Common Mistakes

- Polling too fast (`setTimeout(check, 1)`) — wastes CPU. Poll every 10ms.
- No timeout — loop forever if condition never met. Always include timeout with clear error.
- Stale data — caching state before loop. Call getter inside loop for fresh data.

## When Arbitrary Timeout IS Correct

```typescript
await waitForEvent(manager, 'TOOL_STARTED'); // First: wait for condition
await new Promise(r => setTimeout(r, 200));   // Then: wait for timed behavior
// 200ms = 2 ticks at 100ms intervals — documented and justified
```

Requirements: first wait for triggering condition, based on known timing (not guessing), comment explaining why.
