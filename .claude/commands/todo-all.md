---
description: Execute all pending todos autonomously
---

# /todo-all

Execute all tasks in the TodoWrite list autonomously with permission gates.

## Behavior

1. Check TodoWrite for pending tasks
2. If empty, report: "No pending tasks. Run /onboard BRI-XXX first."
3. For each pending task:
   - Mark as in_progress
   - Execute the task
   - Update status in real-time
   - **Pause at permission gates**:
     - git commit
     - git push
     - mcp__brief delete operations
     - Destructive bash operations
   - **For complex tasks (>50 LOC changed)**: Run two-stage review before marking complete
   - Mark as completed when done
4. When all tasks complete, run `/prep` automatically
5. Report: "All tasks complete. Prep check: [results]. Ready for commit approval."

## Permission Gates

When hitting a permission gate:
- Stop execution
- Show what needs approval: "Need approval to: [action]"
- Wait for user response
- Resume on approval

## Review Gates

After implementing each complex task (>50 lines of code changed), perform a two-stage review before marking the task complete:

### Stage 1: Spec Compliance

Verify the implementation matches requirements:

- **Acceptance criteria met?** Check each criterion from the todo/Linear issue
- **No missing requirements?** All specified functionality implemented
- **No scope creep?** No unrelated changes or gold-plating
- **Edge cases handled?** Error states, empty states, boundary conditions

If Stage 1 fails:
- Document what's missing or incorrect
- Fix the implementation
- Re-run Stage 1

### Stage 2: Code Quality

Verify the implementation follows Brief standards:

- **brief-patterns compliance?** API routes, database access, component architecture
- **security-patterns checks?** Input validation, auth, RLS, no secrets exposed
- **testing-strategy coverage?** Tests written per requirements (80% minimum)
- **No excessive logging?** Debug statements removed
- **File size check?** No file exceeds 1000 LOC

If Stage 2 fails:
- Document the quality issues
- Fix and refactor as needed
- Re-run Stage 2

### Review Gate Example

```text
Task: Implement document search API

Implementation complete. Running review gates...

Stage 1: Spec Compliance
  [x] GET /api/v1/documents/search returns paginated results
  [x] Supports query, folder_id, limit parameters
  [x] Returns document metadata (id, title, updated_at)
  [ ] MISSING: Does not return snippet/preview text

Stage 1 FAILED - Fixing missing snippet field...

[After fix]

Stage 1: Spec Compliance - PASSED
Stage 2: Code Quality
  [x] Uses withV1Auth middleware
  [x] Zod validation on all inputs
  [x] Drizzle query with RLS
  [x] Test coverage: 87%
  [x] No debug logging

Stage 2: PASSED

Task marked complete.
```

## Subagent Mode

For large feature work spanning multiple files or domains, use `--subagents` flag to parallelize implementation across focused subagents.

### Usage

```text
/todo-all --subagents
```

### How It Works

1. **Task Analysis**: Identify which tasks can be parallelized vs. sequential
2. **Subagent Assignment**: Spawn focused subagents for independent workstreams:
   - `api-subagent`: Backend routes, database queries
   - `ui-subagent`: Components, hooks, styling
   - `test-subagent`: Test coverage, fixtures, mocks
3. **Coordination**: Main agent coordinates, resolves conflicts, merges work
4. **Integration Review**: After subagents complete, run integration review

### Subagent Boundaries

Each subagent operates within defined boundaries:

| Subagent | Scope | Can Modify | Cannot Modify |
|----------|-------|------------|---------------|
| api | Backend | `app/api/`, `lib/db/` | Components, hooks |
| ui | Frontend | `components/`, `hooks/` | API routes, DB |
| test | Testing | `**/*.test.ts`, `test/` | Production code |
| mcp | MCP Tools | `mcp/`, `lib/mcp/` | Web app code |

### Subagent Review Protocol

1. Each subagent runs its own two-stage review
2. Main agent runs cross-cutting integration review:
   - API contracts match UI expectations
   - Types consistent across boundaries
   - No circular dependencies introduced
3. Conflicts resolved by main agent before merge

### When to Use Subagents

Use `--subagents` when:
- Feature touches 3+ domains (API, UI, tests, docs)
- Estimated >200 LOC total changes
- Clear separation of concerns exists
- Tasks have minimal interdependencies

Avoid `--subagents` when:
- Small, focused changes
- Highly interdependent work
- Refactoring that touches shared code

### Subagent Example

```text
/todo-all --subagents

Analyzing 8 tasks for parallelization...

Parallel workstreams identified:
  Stream A (api-subagent): Tasks 1, 3, 5 - Document CRUD endpoints
  Stream B (ui-subagent): Tasks 2, 4 - DocumentList, DocumentDetail components
  Stream C (test-subagent): Tasks 6, 7, 8 - API and component tests

Spawning subagents...

[api-subagent] Starting tasks 1, 3, 5...
[ui-subagent] Starting tasks 2, 4...
[test-subagent] Waiting for api/ui completion...

[api-subagent] Task 1 complete. Review gates passed.
[ui-subagent] Task 2 complete. Review gates passed.
...

All subagents complete. Running integration review...

Integration Review:
  [x] API response types match UI expectations
  [x] No type mismatches found
  [x] Test coverage meets threshold

All tasks complete. Ready for /prep.
```

## Example Flow

```text
/todo-all

Executing 5 tasks...

[x] Task 1: Create AGENTS.md - Completed
[x] Task 2: Set up guardrails - Completed
[x] Task 3: Create agents/ directory - Completed
[PAUSE] Task 4: Commit changes - REQUIRES APPROVAL
  Ready to commit: "feat: Add agent infrastructure (BRI-766)"

Waiting for approval to continue...
```

## Tools Used

- TodoWrite (read status, update status)
- All implementation tools (Read, Edit, Write, etc.)
- Bash (with permission gate for commits)
- mcp__brief (read-only, write requires approval)

**For Cursor users**:
- Use composer mode for multi-file tasks
- Show cumulative diff at permission gates
- Allow review before proceeding
