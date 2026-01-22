---
description: Use when investigating bugs, errors, or unexpected behavior. Enforces systematic root cause analysis before any fix attempt.
---

# Systematic Debugging

> "NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST"

Rushed fixes create technical debt. A bug that takes 30 minutes to understand properly takes 5 minutes to fix correctly. A bug that gets "fixed" in 5 minutes often returns 3 more times.

## When to Apply

- **Always:** Production bugs, test failures, unexpected behavior, errors in logs
- **Ask first:** Minor typos, obvious one-liner fixes, configuration issues

## The Four Phases

### Phase 1: Root Cause Investigation

**STOP. Do not write any fix code yet.**

1. **Reproduce the bug reliably**
   ```bash
   # Run the specific failing test
   pnpm test path/to/failing.test.ts

   # Or reproduce via API
   curl -X POST http://localhost:3000/api/v1/documents \
     -H "Authorization: Bearer $API_KEY" \
     -d '{"title": "test", "folder_id": "invalid"}'
   ```

2. **Collect evidence**
   - Error message (exact text)
   - Stack trace (full, not truncated)
   - Request/response data
   - Database state at time of error
   - Environment (local, preview, production)

3. **Trace the execution path**
   ```typescript
   // Add temporary logging to trace flow
   console.log('[DEBUG] createDocument called with:', { title, folderId });
   console.log('[DEBUG] Auth context:', { userId, orgId });
   console.log('[DEBUG] Query result:', result);
   ```

4. **Identify the actual vs expected behavior**
   | Aspect | Expected | Actual |
   |--------|----------|--------|
   | Response status | 201 Created | 500 Internal Error |
   | Database row | Created in documents table | No row created |
   | Error message | None | "violates foreign key constraint" |

### Phase 2: Pattern Analysis

Check if this bug matches known patterns:

1. **Query Brief for similar issues**
   ```typescript
   mcp__brief__brief_prepare_context({
     preparation_type: "search",
     query: "foreign key constraint error documents"
   })
   ```

2. **Check existing decisions**
   ```typescript
   mcp__brief__brief_execute_operation({
     operation: "search_decisions",
     parameters: { query: "database constraints", limit: 5 }
   })
   ```

3. **Review related code**
   ```bash
   # Find similar patterns in codebase
   grep -r "folder_id" app/api/v1/documents/
   grep -r "foreign key" supabase/migrations/
   ```

4. **Common Brief bug patterns**

   | Pattern | Symptom | Root Cause |
   |---------|---------|------------|
   | RLS bypass | 403 or empty results | Missing org_id filter |
   | Auth race | Intermittent 401 | Session not awaited |
   | Zod mismatch | 400 on valid data | Schema doesn't match API contract |
   | Supabase timeout | 504 Gateway Timeout | Missing index or N+1 query |
   | Drizzle fallback | Inconsistent behavior | DRIZZLE_STRICT not set |

### Phase 3: Hypothesis Testing

**Form a specific, testable hypothesis before changing code.**

1. **Write the hypothesis**
   ```
   Hypothesis: The document creation fails because folder_id validation
   passes an empty string, which violates the foreign key constraint
   when the database expects a valid UUID.
   ```

2. **Design a minimal test**
   ```typescript
   // Test the hypothesis specifically
   it('rejects empty folder_id', async () => {
     const req = new Request('http://localhost/api/v1/documents', {
       method: 'POST',
       body: JSON.stringify({ title: 'Test', folder_id: '' })
     });
     const res = await POST(req);
     expect(res.status).toBe(400);  // Should fail validation, not hit DB
   });
   ```

3. **Validate or invalidate**
   - If test confirms hypothesis: proceed to fix
   - If test fails differently: revise hypothesis, return to Phase 1

### Phase 4: Implementation

**Only now do you write the fix.**

1. **Check for conflicts with existing decisions**
   ```typescript
   mcp__brief__brief_execute_operation({
     operation: "guard_approach",
     parameters: {
       approach: "Add UUID validation to folder_id in document creation schema"
     }
   })
   ```

2. **Write the minimal fix**
   ```typescript
   // Before: allows empty strings
   const schema = z.object({
     title: z.string().min(1),
     folder_id: z.string(),
   });

   // After: validates UUID format
   const schema = z.object({
     title: z.string().min(1),
     folder_id: z.string().uuid(),
   });
   ```

3. **Write regression test first (TDD)**
   ```typescript
   // This test must fail before fix, pass after
   it('rejects empty folder_id with validation error', async () => {
     mockAuth({ userId: 'test-user', orgId: 'test-org' });
     const req = new Request('http://localhost/api/v1/documents', {
       method: 'POST',
       body: JSON.stringify({ title: 'Test', folder_id: '' })
     });
     const res = await POST(req);
     expect(res.status).toBe(400);
     const body = await res.json();
     expect(body.error).toContain('folder_id');
   });
   ```

4. **Verify the fix**
   ```bash
   # Run specific test
   pnpm test app/api/v1/documents/route.test.ts

   # Run full suite for regressions
   pnpm test

   # Verify original bug is resolved
   curl -X POST http://localhost:3000/api/v1/documents \
     -H "Authorization: Bearer $API_KEY" \
     -d '{"title": "test", "folder_id": ""}'
   # Should now return 400, not 500
   ```

5. **Remove debug logging**
   ```bash
   # Find and remove temporary console.log statements
   grep -rn "console.log.*DEBUG" app/ lib/
   ```

## Integration with Brief

Before implementing any fix:

1. **`guard_approach`** - Does this fix conflict with existing decisions?
2. **`brief-patterns`** - Follow API route, database, and testing patterns
3. **`security-patterns`** - Auth, RLS, input validation requirements
4. **`testing-strategy`** - Bug fixes MUST include regression tests

## Red Flags (STOP Immediately)

- Changing code without reproducing the bug first
- "Trying things" without a hypothesis
- Fixing symptoms instead of root cause
- Removing error handling to make errors disappear
- Adding try/catch that swallows errors silently
- Commenting out failing tests
- "Works on my machine" without investigating environment differences

## Escalation Rule

**If 3+ fixes fail, question the architecture.**

After three failed fix attempts:

1. **Stop coding immediately**
2. **Document what you've tried**
   ```
   Attempt 1: Added UUID validation - still fails on valid UUIDs
   Attempt 2: Added null check - still fails with empty string
   Attempt 3: Added database constraint - now fails earlier but still wrong
   ```

3. **Query Brief for architectural context**
   ```typescript
   mcp__brief__brief_prepare_context({
     preparation_type: "search",
     query: "document creation architecture folder validation"
   })
   ```

4. **Check if the design is fundamentally flawed**
   ```typescript
   mcp__brief__brief_execute_operation({
     operation: "guard_approach",
     parameters: {
       approach: "Redesign document-folder relationship to use optional folder_id"
     }
   })
   ```

5. **Escalate to user**
   ```
   "I've attempted 3 fixes without success. The root issue appears to be
   [architectural problem]. This may require a design decision. Options:

   A) Refactor folder validation layer (estimated: 2-4 hours)
   B) Add backward-compatible workaround (technical debt)
   C) Investigate further before deciding

   Which approach should I take?"
   ```

## Example: Full Debugging Session

```text
BUG: POST /api/v1/documents returns 500 when folder_id is empty string

PHASE 1: Investigation
- Reproduced: curl returns 500 Internal Server Error
- Stack trace shows: PostgreSQL foreign key violation
- Expected: 400 Bad Request with validation error
- Actual: 500 with database error leaking to response

PHASE 2: Pattern Analysis
- Similar to BRI-234 (fixed similar issue in /api/v1/folders)
- Pattern: Zod schema allows empty string, DB rejects it
- No conflicting decisions found

PHASE 3: Hypothesis Testing
- Hypothesis: Missing UUID validation in Zod schema
- Test: Send empty string, expect 400
- Result: Test confirms - Zod accepts empty string, DB rejects

PHASE 4: Implementation
- guard_approach: No conflicts
- Fix: Add .uuid() to folder_id schema
- Regression test: Written and passing
- Full suite: All tests pass
- Manual verification: Now returns 400 with proper error message
```

## Verification Checklist

Before marking bug as fixed:

- [ ] Bug reproduced reliably before fix
- [ ] Root cause identified and documented
- [ ] Hypothesis tested, not assumed
- [ ] guard_approach called for significant changes
- [ ] Regression test written and passing
- [ ] Full test suite passes
- [ ] Debug logging removed
- [ ] Fix addresses root cause, not symptom
- [ ] Related code reviewed for same pattern

## References

- `tdd` skill for RED-GREEN-REFACTOR cycle
- `testing-strategy` skill for coverage requirements
- `brief-patterns` skill for API and database patterns
- `security-patterns` skill for auth and RLS requirements
