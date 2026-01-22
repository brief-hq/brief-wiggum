---
description: Use when implementing new features, fixing bugs, or making behavior changes. Enforces RED-GREEN-REFACTOR cycle.
---

# Test-Driven Development

> "If you didn't watch the test fail, you don't know if it tests the right thing."

## When to Apply

- **Always:** New features, bug fixes, refactoring, behavior changes
- **Ask first:** Throwaway prototypes, config files, generated code

## The Cycle

### RED: Write Failing Test First

Write ONE minimal test demonstrating desired behavior:

```typescript
// Example: Testing new API route
describe('POST /api/v1/documents', () => {
  it('creates document with valid data', async () => {
    mockAuth({ userId: 'test-user', orgId: 'test-org' });
    const req = new Request('http://localhost/api/v1/documents', {
      method: 'POST',
      body: JSON.stringify({ title: 'Test', folder_id: 'abc-123' })
    });
    const res = await POST(req);
    expect(res.status).toBe(201);  // Will fail - route doesn't exist yet
  });
});
```

**Test naming:** Be specific. `'creates document with valid data'` not `'works'`.

### VERIFY RED

```bash
pnpm test path/to/test.ts
```

**STOP** if test passes immediately - you're testing existing behavior, not new functionality. This means:
- The feature already exists, OR
- Your test is wrong (testing the wrong thing)

Verify the failure message reflects the missing feature, not a syntax error.

### GREEN: Implement Minimal Code

Write ONLY what makes the test pass:
- No extra features
- No "while I'm here" improvements
- No over-engineering
- Follow patterns from `brief-patterns` skill

```typescript
// Minimal implementation
export async function POST(req: Request) {
  const session = await auth();
  if (!session.userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const body = schema.parse(await req.json());
  const doc = await createDocument(body);
  return NextResponse.json(doc, { status: 201 });
}
```

### VERIFY GREEN

```bash
pnpm test
```

- All tests must pass
- No regressions (run full suite, not just new test)
- Clean output - no warnings treated as acceptable

### REFACTOR: Clean While Green

Improve code quality while keeping tests green:
- Remove duplication
- Improve naming
- Extract helpers
- Simplify logic

**Run tests after each refactor change.**

## Integration with Brief

Before implementing, check:

1. **`guard_approach`** - Does this conflict with existing decisions?
   ```
   mcp__brief__brief_execute_operation({
     operation: "guard_approach",
     parameters: { approach: "Add document creation endpoint" }
   })
   ```

2. **`testing-strategy`** - What coverage is required? (80% for new features)

3. **`brief-patterns`** - What patterns should be followed? (Zod validation, withV1Auth, etc.)

4. **`security-patterns`** - Auth, RLS, input validation requirements

## Red Flags (STOP Immediately)

- Writing code before tests
- Tests passing immediately without implementation
- "Just this once" exceptions to TDD
- Keeping pre-written code "as reference"
- Testing implementation details rather than behavior
- Mocking everything instead of testing real interactions

## Common Rationalizations (All Invalid)

| Excuse | Reality |
|--------|---------|
| "Tests after work equivalently" | Tests-after verify what exists; tests-first define requirements |
| "I'll add tests later" | Later never comes; untested code ships |
| "This is too simple to test" | Simple code has simple tests; no excuse |
| "Manual testing is enough" | Manual testing doesn't prevent regressions |
| "TDD slows me down" | Debugging production issues takes longer |

## Verification Checklist

Before marking implementation complete:

- [ ] Every function has a failing test written first
- [ ] Each test failed for the expected reason (not syntax error)
- [ ] Minimal code implemented to pass tests
- [ ] All tests pass with clean output
- [ ] Tests use real code paths (minimal mocking)
- [ ] Edge cases covered (errors, empty states, boundaries)
- [ ] Security tests included (auth failures, forbidden access)

## Example: Bug Fix with TDD

```typescript
// 1. RED: Write test reproducing the bug
it('handles empty folder_id gracefully', async () => {
  mockAuth({ userId: 'test-user', orgId: 'test-org' });
  const req = new Request('http://localhost/api/v1/documents', {
    method: 'POST',
    body: JSON.stringify({ title: 'Test', folder_id: '' })
  });
  const res = await POST(req);
  expect(res.status).toBe(400);
  expect(await res.json()).toEqual({
    error: 'Validation failed',
    details: expect.arrayContaining([
      expect.objectContaining({ path: ['folder_id'] })
    ])
  });
});

// 2. VERIFY RED: Run test, confirm it fails
// 3. GREEN: Add validation
const schema = z.object({
  title: z.string().min(1),
  folder_id: z.string().uuid(), // Now validates UUID format
});

// 4. VERIFY GREEN: All tests pass
// 5. REFACTOR: Clean up if needed
```

## References

- `testing-strategy` skill for coverage requirements and test patterns
- `brief-patterns` skill for API route structure
- `security-patterns` skill for auth testing
