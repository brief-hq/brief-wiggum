---
description: Use when implementing features, fixing bugs, or writing tests. Covers TDD workflow, debugging methodology, and coverage requirements.
---

# Development Practices

This skill consolidates test-driven development, systematic debugging, and testing requirements into a unified development workflow.

## Test-Driven Development

> "If you didn't watch the test fail, you don't know if it tests the right thing."

### When to Apply TDD

- **Always:** New features, bug fixes, refactoring, behavior changes
- **Ask first:** Throwaway prototypes, config files, generated code

### The RED-GREEN-REFACTOR Cycle

#### RED: Write Failing Test First

Write ONE minimal test demonstrating desired behavior:

```typescript
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

#### VERIFY RED

```bash
pnpm test path/to/test.ts
```

**STOP** if test passes immediately - you're testing existing behavior, not new functionality. Verify the failure message reflects the missing feature, not a syntax error.

#### GREEN: Implement Minimal Code

Write ONLY what makes the test pass:
- No extra features
- No "while I'm here" improvements
- No over-engineering
- Follow patterns from `patterns` skill

#### VERIFY GREEN

```bash
pnpm test
```

- All tests must pass
- No regressions (run full suite, not just new test)
- Clean output - no warnings treated as acceptable

#### REFACTOR: Clean While Green

Improve code quality while keeping tests green:
- Remove duplication
- Improve naming
- Extract helpers
- Simplify logic

**Run tests after each refactor change.**

### TDD Red Flags

- Writing code before tests
- Tests passing immediately without implementation
- "Just this once" exceptions to TDD
- Keeping pre-written code "as reference"
- Testing implementation details rather than behavior
- Mocking everything instead of testing real interactions

---

## Systematic Debugging

> "NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST"

Rushed fixes create technical debt. A bug that takes 30 minutes to understand properly takes 5 minutes to fix correctly.

### When to Apply

- **Always:** Production bugs, test failures, unexpected behavior, errors in logs
- **Ask first:** Minor typos, obvious one-liner fixes, configuration issues

### The Four Phases

#### Phase 1: Root Cause Investigation

**STOP. Do not write any fix code yet.**

1. **Reproduce the bug reliably**
   ```bash
   pnpm test path/to/failing.test.ts
   ```

2. **Collect evidence**
   - Error message (exact text)
   - Stack trace (full, not truncated)
   - Request/response data
   - Database state at time of error
   - Environment (local, preview, production)

3. **Trace the execution path**
   ```typescript
   console.log('[DEBUG] createDocument called with:', { title, folderId });
   console.log('[DEBUG] Auth context:', { userId, orgId });
   ```

4. **Identify actual vs expected behavior**

| Aspect | Expected | Actual |
|--------|----------|--------|
| Response status | 201 Created | 500 Internal Error |
| Database row | Created in documents table | No row created |
| Error message | None | "violates foreign key constraint" |

#### Phase 2: Pattern Analysis

Check if this bug matches known patterns:

**Common Brief bug patterns:**

| Pattern | Symptom | Root Cause |
|---------|---------|------------|
| RLS bypass | 403 or empty results | Missing org_id filter |
| Auth race | Intermittent 401 | Session not awaited |
| Zod mismatch | 400 on valid data | Schema doesn't match API contract |
| Supabase timeout | 504 Gateway Timeout | Missing index or N+1 query |
| Drizzle fallback | Inconsistent behavior | DRIZZLE_STRICT not set |

#### Phase 3: Hypothesis Testing

**Form a specific, testable hypothesis before changing code.**

```text
Hypothesis: The document creation fails because folder_id validation
passes an empty string, which violates the foreign key constraint.
```

Design and run a minimal test to validate or invalidate.

#### Phase 4: Implementation

**Only now do you write the fix.**

1. Check for conflicts with existing decisions via `guard_approach`
2. Write the minimal fix
3. Write regression test first (TDD)
4. Verify the fix
5. **Remove debug logging** before committing

### Escalation Rule

**If 3+ fixes fail, question the architecture.**

After three failed fix attempts:
1. Stop coding immediately
2. Document what you've tried
3. Query Brief for architectural context
4. Check if the design is fundamentally flawed
5. Escalate to user with options

### Debugging Red Flags

- Changing code without reproducing the bug first
- "Trying things" without a hypothesis
- Fixing symptoms instead of root cause
- Removing error handling to make errors disappear
- Adding try/catch that swallows errors silently
- Commenting out failing tests

---

## Testing Requirements

### Coverage Requirements

- **New features**: Minimum 80% coverage
- **Bug fixes**: MUST include regression test
- **Refactors**: Maintain or improve existing coverage

### What MUST Have Tests

1. All API routes (`app/api/v1/**/route.ts`)
2. All custom hooks (`hooks/use-*.ts`)
3. Complex business logic
4. MCP tool implementations
5. Utility functions with branching logic

### Test Patterns

#### API Route Tests

```typescript
import { POST } from './route';
import { mockAuth } from '@/test/helpers';

describe('POST /api/v1/documents', () => {
  it('creates document with valid data', async () => {
    mockAuth({ userId: 'test-user' });
    const req = new Request('http://localhost', {
      method: 'POST',
      body: JSON.stringify({ title: 'Test', folder_id: 'abc' })
    });
    const res = await POST(req);
    expect(res.status).toBe(201);
  });

  it('returns 400 for missing folder_id', async () => {
    // Test error path
  });

  it('returns 401 for unauthenticated request', async () => {
    // Test auth error
  });
});
```

#### Hook Tests

```typescript
import { renderHook, waitFor } from '@testing-library/react';
import { useDocuments } from './use-documents';

describe('useDocuments', () => {
  it('fetches documents successfully', async () => {
    const { result } = renderHook(() => useDocuments('folder-id'));
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toHaveLength(3);
  });

  it('handles loading state', () => {
    const { result } = renderHook(() => useDocuments('folder-id'));
    expect(result.current.isLoading).toBe(true);
  });

  it('handles error state', async () => {
    mockApiError('Failed to fetch');
    const { result } = renderHook(() => useDocuments('folder-id'));
    await waitFor(() => expect(result.current.isError).toBe(true));
  });
});
```

### Running Tests

- `pnpm test` - Run all tests
- `pnpm run test:watch` - Watch mode for development
- `pnpm run test:coverage` - Coverage report

### Before Requesting Commit

- ✅ All tests pass
- ✅ New code has tests (written BEFORE implementation per TDD)
- ✅ Coverage meets thresholds
- ✅ No `test.only` or `test.skip` left in code
- ✅ Tests verify behavior, not implementation details

---

## Verification Checklist

Before marking implementation complete:

- [ ] Every function has a failing test written first
- [ ] Each test failed for the expected reason (not syntax error)
- [ ] Minimal code implemented to pass tests
- [ ] All tests pass with clean output
- [ ] Tests use real code paths (minimal mocking)
- [ ] Edge cases covered (errors, empty states, boundaries)
- [ ] Security tests included (auth failures, forbidden access)
- [ ] Debug logging removed
- [ ] Coverage meets 80% threshold for new features
