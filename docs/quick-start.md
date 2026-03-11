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

## Step 3: Install Brief CLI

See [Brief CLI Setup](https://briefhq.ai/docs/cli-setup/) for detailed instructions.

**Quick version:**

1. Install the Brief CLI
2. Authenticate with your Brief account:

```bash
brief login
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

### Brief CLI
```
/health
```

Should show:
```
✅ Brief CLI: Connected
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

### "Brief CLI not installed"

- Check your API key is valid
- Verify Brief CLI is installed and authenticated
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
