# Testing Anti-Patterns

Read when: writing or changing tests, adding mocks, or tempted to add test-only methods to production code.

## Anti-Pattern 1: Testing Mock Behavior

```typescript
// BAD: Testing that the mock exists
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});

// GOOD: Test real component behavior
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});
```

Before asserting on any mock element, ask: "Am I testing real behavior or mock existence?" If mock existence — delete the assertion or unmock the component.

## Anti-Pattern 2: Test-Only Methods in Production

```typescript
// BAD: destroy() only used in tests
class Session {
  async destroy() { /* cleanup */ }
}

// GOOD: Test utilities handle cleanup
// In test-utils/
export async function cleanupSession(session: Session) { /* cleanup */ }
```

Before adding a method to a production class, ask: "Is this only used by tests?" If yes — put it in test utilities instead.

## Anti-Pattern 3: Mocking Without Understanding Dependencies

```typescript
// BAD: Mock prevents side effect the test depends on
vi.mock('ToolCatalog', () => ({
  discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
}));
// Test now can't detect duplicates because config was never written

// GOOD: Mock at the right level — preserve behavior the test needs
vi.mock('MCPServerManager'); // Just mock the slow server startup
```

Before mocking: understand what side effects the real method has, whether the test depends on any of them, and mock at the lowest level necessary.

## Anti-Pattern 4: Incomplete Mocks

```typescript
// BAD: Only fields you know about
const mockResponse = { status: 'success', data: { userId: '123' } };
// Breaks when code accesses response.metadata.requestId

// GOOD: Mirror real API completely
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-789', timestamp: 1234567890 }
};
```

Mock the complete data structure as it exists in reality, not just fields your immediate test uses.

## Red Flags

- Assertions check for `*-mock` test IDs
- Methods only called in test files
- Mock setup is >50% of the test
- Test fails when you remove the mock
- Can't explain why the mock is needed
- Mocking "just to be safe"

When mock complexity is high, consider integration tests with real components — often simpler and more reliable.
