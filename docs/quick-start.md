# Quick Start Guide

Get Brief Wiggum running in 5 minutes.

> ⚠️ **EXPERIMENTAL SOFTWARE**: Brief Wiggum is in early development. Test thoroughly in a non-production environment first. See the [README](../README.md) for full disclaimer.

## Prerequisites

- **Brief account** with API access
- **Claude Code** or **Cursor** installed
- **Node.js** 18+ with pnpm/npm/yarn
- **jq** (for Ralph loop): `brew install jq` or `apt install jq`

## Step 1: Fork the Repo

```bash
# Fork on GitHub, then clone
git clone https://github.com/YOUR_USERNAME/brief-wiggum.git
cd brief-wiggum
```

## Step 2: Run Setup

```bash
./.claude/scripts/setup.sh
```

This verifies:
- Git hooks are executable
- Scripts are executable
- Required tools are installed

## Step 3: Connect Brief MCP

See [Brief MCP Setup](https://briefhq.ai/docs/mcp-setup/) for detailed instructions.

**Quick version for Claude Code:**

1. Get your Brief API key from the Brief dashboard
2. Add to your Claude Code MCP settings:

```json
{
  "mcpServers": {
    "brief": {
      "url": "https://app.briefhq.ai/api/mcp/sse",
      "transport": "sse",
      "headers": {
        "Authorization": "Bearer YOUR_BRIEF_API_KEY"
      }
    }
  }
}
```

## Step 4: Customize CLAUDE.md

```bash
cp CLAUDE.md.template CLAUDE.md
```

Edit `CLAUDE.md` and fill in:
- Your project name
- Your tech stack (frontend, backend, database, etc.)
- Your build commands (dev, build, test, lint)
- Your code conventions

## Step 5: Start Working

```bash
# Start Claude Code
claude

# Or open in Cursor
cursor .
```

Then type:
```
/onboard
```

The agent will:
1. Load Brief product context
2. Check your codebase structure
3. Report readiness

## Verify It's Working

### Brief MCP
```
/health
```

Should show:
```
✅ Brief MCP: Connected
```

### Git Guards
Try running a dangerous command:
```bash
git reset --hard
```

Should be blocked with an explanation.

### Ralph Loop
```bash
./.claude/scripts/ralph.sh --dry-run "Add a test file"
```

Should show the prompt that would be sent.

## Next Steps

1. **Read the philosophy**: [philosophy.md](philosophy.md)
2. **Understand skills**: Browse `.claude/skills/`
3. **Customize patterns**: Add project-specific skills
4. **Connect Linear** (optional): For issue tracking integration

## Common Issues

### "Brief MCP not connected"

- Check your API key is valid
- Verify the MCP server URL
- Restart Claude Code/Cursor

### "Permission denied" on scripts

```bash
chmod +x .claude/hooks/*.sh
chmod +x .claude/scripts/*.sh
```

### "jq: command not found"

Install jq for your platform:
- macOS: `brew install jq`
- Ubuntu: `apt install jq`
- Windows: `choco install jq`
