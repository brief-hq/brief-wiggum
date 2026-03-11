---
description: Perform comprehensive code review of staged/changed files
---

# /review

Perform comprehensive code review of staged/changed files. Be thorough but concise.

## Scope

Review files from:
1. `git diff --cached --name-only` (staged files)
2. `git diff --name-only` (unstaged changes)
3. Or specific files if provided: $ARGUMENTS

## Check For

**Error Handling** - Try-catch for async, centralized handlers, helpful messages
**TypeScript** - No `any` types, proper interfaces, no @ts-ignore
**Production Readiness** - No debug statements, no TODOs, no hardcoded secrets
**React/Hooks** - Effects have cleanup, dependencies complete, no infinite loops
**Performance** - No unnecessary re-renders, expensive calcs memoized
**Security** - Auth checked, inputs validated, access controls in place
**Architecture** - Follows existing patterns, code in correct directory

## Approach Validation

For significant changes, validate against product decisions:

```bash
brief ask --mode check "Does this change conflict with existing decisions? [describe the change]"
```

## Output Format

### Files Reviewed
- [file1.ts]
- [file2.tsx]

### Looks Good
- [Item 1]
- [Item 2]

### Issues Found
- **[Severity]** [File:line] - [Issue description]
  - Fix: [Suggested fix]

### Summary
- Files reviewed: X
- Critical issues: X
- Warnings: X

## Severity Levels

- **CRITICAL** - Security, data loss, crashes
- **HIGH** - Bugs, performance issues, bad UX
- **MEDIUM** - Code quality, maintainability
- **LOW** - Style, minor improvements
