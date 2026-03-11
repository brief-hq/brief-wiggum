---
description: Generate a handoff prompt for a new Claude session when context is degraded
---

# /transfer-context

Generate a handoff prompt for a new Claude session when context is degraded or task needs fresh start.

## When to Use

- Context is running low (check with `/context`)
- After multiple compactions, quality is degrading
- Task pivot - new work unrelated to current context
- Want a fresh perspective on stuck problem
- Handing off to a different model (Codex, Gemini)

## Instructions

### 1. Assess Current State

Determine what's worth transferring:
- What task is in progress?
- What files are relevant?
- What has been tried (if debugging)?
- What decisions have been made?
- What gotchas were discovered?

### 2. Get Product Context from Brief (if available)

If the `brief` CLI is installed and configured, call it to generate a rich "state of the world" for the handoff:

```bash
brief ask --context "Generating a handoff prompt for a new session working on [task area]" \
  "I'm handing off work on [task description]. Summarize the relevant product context: recent decisions that affect this area, related customer insights, current work in progress that might interact, and any constraints the next agent should know about."
```

Include the response in the handoff prompt under a **Product Context** section. This gives the receiving session decisions, customer signals, and strategic context that would otherwise be lost.

If the CLI is not available, skip this step and note "Brief CLI not available — product context not included" in the handoff.

### 3. Generate Handoff Prompt

Create a self-contained prompt that gives the new session everything it needs:

```markdown
## Task: [Brief description]

### Context
[1-2 sentences on what we're building/fixing]

### Current State
- [x] Completed step 1
- [x] Completed step 2
- [ ] In progress: step 3
- [ ] Remaining: step 4

### Key Files
- `path/to/main/file` - [what it does]
- `path/to/related/file` - [what it does]

### Product Context (from Brief)
[Paste key insights from brief ask: relevant decisions, customer signals, strategic context]
Do not persist or commit product context to this repo. Reference the product workspace for source of truth.

### Decisions Made
- Using [approach A] because [reason]
- NOT using [approach B] because [reason]

### Gotchas Discovered
- [Thing that didn't work and why]
- [Unexpected behavior to watch for]

### What to Do Next
[Specific instruction for continuing the work]
```

### 4. Include File Contents (If Critical)

For small, critical files, include the content directly:

```markdown
### Current Implementation

\`\`\`
// path/to/file
[paste relevant code]
\`\`\`
```

For larger codebases, just list paths - the new session can read them.

### 5. Output the Prompt

Present the handoff prompt in a copyable format:

```
---
Copy the following into a new Claude session:
---

[Generated handoff prompt]

---
End of handoff prompt
---
```

## Templates

### For Debugging

```markdown
## Task: Fix [error/bug description]

### Error
\`\`\`
[Exact error message]
\`\`\`

### Reproduction
\`\`\`bash
[Command to reproduce]
\`\`\`

### What We've Tried
1. [Attempt 1] - Result: [what happened]
2. [Attempt 2] - Result: [what happened]

### Current Hypothesis
[What we think is wrong]

### Key Files
- `path/to/file:123` - Where error occurs

### Next Step
[What to try next]
```

### For Feature Work

```markdown
## Task: Implement [feature]

### Requirements
- [Requirement 1]
- [Requirement 2]

### Architecture Decision
Using [approach] because [reason].
Checked with `brief ask --mode check` - no conflicts.

### Progress
- [x] Schema changes
- [x] API route skeleton
- [ ] Business logic (in progress)
- [ ] Tests
- [ ] Documentation

### Key Files
- `[PATH_TO_SCHEMA]` - Added [table/columns]
- `[PATH_TO_ROUTE]` - New endpoint

### Current Blocker (if any)
[What's blocking progress]

### Next Step
Continue implementing [specific thing]
```

### For Code Review Handoff

```markdown
## Task: Review PR #[number]

### PR Summary
[What the PR does]

### Files Changed
- `path/to/file1` - [change summary]
- `path/to/file2` - [change summary]

### Review Progress
- [x] Security check
- [ ] Logic review
- [ ] Test coverage

### Concerns Found
- [Concern 1 with file:line]

### Next Step
Continue reviewing [remaining files]
```

## Tips

1. **Be specific** - "Fix the auth bug" is useless. "Fix 401 on POST /api/endpoint when input is empty" is useful.

2. **Include error messages verbatim** - Don't paraphrase errors, copy them exactly.

3. **List what DIDN'T work** - Prevents the new session from repeating failed attempts.

4. **Reference files by path** - The new session can read them, don't dump entire files unless small.

5. **State the immediate next action** - "Continue from step 3" not "finish the feature."
