---
description: Systematic debugging workflow with enforced discipline
---

# /debug

Systematic debugging workflow. Invokes the `debugging` skill with enforced discipline.

> **"NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST"**

## Usage

```
/debug                     # Debug issue from current context
/debug "error message"     # Debug specific error
/debug path/to/file        # Debug issues in specific file
```

## The Protocol

### Step 1: STOP

Do not write any fix code yet. Rushed fixes create technical debt.

A bug that takes 30 minutes to understand properly takes 5 minutes to fix correctly.
A bug that gets "fixed" in 5 minutes often returns 3 more times.

### Step 2: Reproduce

Make the bug happen reliably:

```bash
# Run specific failing test
pnpm test path/to/failing.test.ts

# Or reproduce via the dev environment
# Check server output, logs, or test runner
```

**If you can't reproduce it, you can't fix it.**

### Step 3: Collect Evidence

Document what you observe:

| Aspect | Expected | Actual |
|--------|----------|--------|
| Response | 201 Created | 500 Internal Error |
| Database | Row created | No row |
| Logs | None | "foreign key violation" |

### Step 4: Form Hypothesis

Write a specific, testable hypothesis:

```
HYPOTHESIS: The creation fails because input validation
passes empty strings, which violate the constraint.

TEST: Send empty value, expect 400 (validation error), not 500.
```

### Step 5: Test Hypothesis

Add strategic logging or write a minimal test:

```typescript
it('rejects empty input', async () => {
  const res = await handler({ value: '' });
  expect(res.status).toBe(400);  // Not 500
});
```

**If hypothesis is wrong, return to Step 3 with new evidence.**

### Step 6: Implement Fix

Only now do you write the fix. Make it minimal.

```bash
brief ask --mode check "We plan to [describe the fix approach]"
```

### Step 7: Verify Fix

```bash
# Run specific test
pnpm test path/to/test.ts

# Run full suite for regressions
pnpm test

# Remove debug logging
grep -rn "console.log.*DEBUG" src/
```

### Step 8: Prevent Recurrence

Ask: "What pattern would prevent this class of bug?"

- Add validation if input gap
- Add to test suite if coverage gap
- Add to AGENTS.md if convention gap

## Escalation Rule

**After 3 failed fix attempts, STOP and escalate.**

```
I've attempted 3 fixes without success:

Attempt 1: [what was tried] - [result]
Attempt 2: [what was tried] - [result]
Attempt 3: [what was tried] - [result]

The root issue appears to be [architectural problem].

Options:
A) Refactor [component] (larger change)
B) Add workaround (technical debt)
C) Investigate further

Which approach?
```

## Integration

This command automatically invokes:
- `debugging` skill - Full 4-phase protocol
- `development` skill - TDD and debugging methodology

## Output

```
## Debug Report

### Issue
[Description of the issue]

### Root Cause
[What was actually wrong and why]

### Fix
[What was changed]

### Verification
- Regression test: PASS
- Full suite: N passed, 0 failed
- Manual test: [result]

### Prevention
[Pattern or convention added to prevent recurrence]
```
