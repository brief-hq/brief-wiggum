---
description: Update AGENTS.md with recent learnings from this session
---

# /update-docs

Update AGENTS.md (the source of truth) with recent learnings from this session. CLAUDE.md and .cursorrules are stubs that point to it for tool compatibility.

## When to Use

Run after:
- Adding new patterns or conventions
- Discovering gotchas or footguns
- Changing project structure
- Adding new commands, skills, or agents
- Learning something that would help future sessions

## Instructions

### 1. Read Current State

```bash
wc -l AGENTS.md CLAUDE.md .cursorrules 2>/dev/null
cat AGENTS.md
```

### 2. Review Session Context

Identify what's worth documenting:
- New commands or skills added
- Patterns established during this session
- Gotchas discovered (things that broke unexpectedly)
- Structure changes (new directories, file organization)
- Integration patterns (Brief CLI, Linear, external APIs)

### 3. Update Conservatively

**Add only genuinely useful information:**
- New commands with brief description
- Established conventions (not one-off decisions)
- Discovered gotchas that will recur
- Structure changes that affect navigation

**Do NOT add:**
- Temporary fixes or workarounds
- One-off decisions specific to a single task
- Obvious code details
- Verbose explanations (keep it scannable)

**Line limit: Keep under 350 lines total.**
If adding content pushes over limit, remove stale or less useful sections.

### 4. Report

Output:
```
## Documentation Updated

### Added
- [Item 1]
- [Item 2]

### Removed (if any)
- [Stale item removed to make room]

### Line count
- Before: X lines
- After: Y lines
```

## Principles

1. **Lean over comprehensive** - Future Claude instances scan this quickly
2. **Patterns over instances** - Document recurring things, not one-offs
3. **Actionable over explanatory** - "Do X" not "X works because..."
4. **Current over historical** - Remove outdated info, don't keep for posterity
