---
description: Check agent environment health
---

# /health

Validate the agent setup and environment.

## Checks

### 1. Brief MCP Connection
- Try: mcp__brief__brief_get_onboarding_context
- ✅ Connected / ❌ Not available

### 2. Linear Integration
- Try: mcp__linear-server__list_teams
- ✅ Connected / ❌ Not available

### 3. Guardrails
- Check: .claude/settings.json or .cursor/settings.json exists
- Verify: deny and require_approval rules present
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
✅ Brief MCP: Connected (user context)
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
❌ Brief MCP: Not connected
   Fix: Run /brief to set up MCP server
✅ Linear: Connected
✅ Composer mode: Available
...

Status: NEEDS SETUP
```
