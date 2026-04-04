# Test Data Management

## Factories
Generate test data programmatically with sensible defaults:
```typescript
function createUser(overrides: Partial<User> = {}): User {
  return {
    id: crypto.randomUUID(),
    name: `Test User ${Date.now()}`,
    email: `test-${Date.now()}@example.com`,
    role: 'user',
    createdAt: new Date().toISOString(),
    ...overrides,
  };
}

// Usage
const admin = createUser({ role: 'admin' });
const user = createUser({ name: 'Specific Name' });
```

## Fixtures
Pre-defined data sets for common scenarios:
```typescript
const fixtures = {
  emptyWorkspace: { users: [], projects: [] },
  singleProject: { users: [adminUser], projects: [sampleProject] },
  fullWorkspace: { users: [admin, user1, user2], projects: [p1, p2], scans: [...] },
};
```

## Test Database Strategy
- **Per-test isolation**: each test gets a clean database (safest, slowest)
- **Per-suite isolation**: each test file gets a clean database (balanced)
- **Transaction rollback**: wrap each test in a transaction, rollback after (fast, some limitations)

## Seeding
```typescript
async function seedDatabase(scenario: keyof typeof fixtures) {
  const data = fixtures[scenario];
  await db.users.insertMany(data.users);
  await db.projects.insertMany(data.projects);
  return data;
}
```

## Rules
- Never use production data in tests (privacy, compliance)
- Generate unique IDs per test run to avoid collisions
- Clean up test data after test suites complete
- Use realistic but anonymized data shapes
- Keep factory defaults simple — override only what the test cares about
