---
description: Check agent environment health
---

# /health

Validate the agent setup and environment.

## Checks

### 1. Brief CLI Connection
- Try: `brief status --json`
- ✅ Connected / ❌ Not available

### 2. Linear Integration
- Try: `linearis teams list`
- ✅ Connected / ❌ Not available

### 3. Guardrails
- Check: AGENTS.md exists (source of truth); CLAUDE.md and .cursorrules are stubs pointing to it
- Verify: .claude/settings.local.json exists with permission rules
- ✅ Configured / ❌ Missing

### 4. Codebase Access
- Try: Read package.json
- ✅ Accessible / ❌ Permission denied

### 5. Build Tools
- Check: pnpm run lint works
- Check: pnpm test works
- Check: pnpm run typecheck works
- Check: pnpm run build works
- ✅ All working / ❌ [list failures]

### 6. Platform Detection
- Detect if running in Claude Code or Cursor
- Report platform-specific features available

## Output

Health report:
```
Environment Health Check:
Platform: Claude Code
✅ Brief CLI: Connected (org_xxx)
✅ Linear: Connected (brief-hq workspace)
✅ Guardrails: Configured (10 deny rules, 5 approval rules)
✅ Codebase: Accessible
✅ Build tools: All passing

Status: READY
```

If any failures, suggest fixes:
```
Environment Health Check:
Platform: Cursor
❌ Brief CLI: Not authenticated
   Fix: Run `brief login` to authenticate
✅ Linear: Connected
✅ Composer mode: Available
...

Status: NEEDS SETUP
```
