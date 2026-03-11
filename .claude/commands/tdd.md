---
description: Apply TDD methodology - RED-GREEN-REFACTOR cycle for new features and bug fixes
---

# /tdd

Apply Test-Driven Development methodology to the current task.

## The Cycle

1. **RED** - Write a failing test first
2. **VERIFY RED** - Run it, confirm it fails for the right reason
3. **GREEN** - Write minimal code to make it pass
4. **VERIFY GREEN** - Run tests, all pass
5. **REFACTOR** - Clean up while tests stay green

## Usage

```bash
/tdd                    # Start TDD for current task
/tdd "feature desc"     # Start TDD for specific feature
```

## When Invoked

Load the `development` skill from `.claude/skills/development/SKILL.md` and follow the TDD workflow:

1. **Understand the requirement** - What behavior needs to exist?
2. **Write ONE test** - Minimal test demonstrating the desired behavior
3. **Watch it fail** - If it passes immediately, you're testing existing behavior
4. **Implement minimally** - Only code that makes the test pass
5. **Refactor** - Clean up while keeping tests green
6. **Repeat** - Next behavior, next test

## Key Rules

- **Never skip RED** - If you didn't see it fail, you don't know it tests the right thing
- **Minimal GREEN** - No "while I'm here" improvements
- **Tests are documentation** - Name them specifically: `'creates document with valid data'` not `'works'`

## For Bug Fixes

Write a regression test that reproduces the bug FIRST:

```bash
1. Write test that fails due to the bug
2. Verify test fails
3. Fix the bug
4. Verify test passes
5. Commit both test and fix together
```

## Integration with Ralph

When running `ralph.sh`, include "tdd" or "test-driven" in your task description to ensure the development skill is loaded:

```bash
./ralph.sh "Implement user search with TDD"
./ralph.sh --linear [TEAM_PREFIX]-123 "Add validation using TDD approach"
```
