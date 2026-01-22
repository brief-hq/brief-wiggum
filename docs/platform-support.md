# Platform Support

Brief Wiggum works with both **Claude Code** and **Cursor**. This guide explains the differences and how to use each.

## Feature Comparison

| Feature | Claude Code | Cursor |
|---------|-------------|--------|
| **Config file** | CLAUDE.md | .cursorrules |
| **Settings** | .claude/settings.json | .cursor/settings.json |
| **Runtime hooks** | PreToolUse, Stop | Not available |
| **Static blocking** | Not used | permissions.deny |
| **Todo tracking** | Native TodoWrite | Manual |
| **Agent spawning** | Task tool | Composer mode |
| **Skill loading** | Automatic | Manual @-mentions |
| **MCP support** | Native | Via settings |

## Claude Code

### Configuration

Settings are in `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [...],
    "deny": [...],
    "require_approval": [...]
  },
  "hooks": {
    "PreToolUse": [...],
    "Stop": [...]
  }
}
```

### Hooks

Claude Code supports runtime hooks:

- **PreToolUse**: Intercept commands before execution
- **Stop**: Gate agent completion

This enables:
- Git safety guards (git-guard.sh)
- Ralph loop stop hook (verify-complete.sh)

### Skills

Skills are automatically detected and loaded based on context. Use:

```
/skills
```

To see available skills.

### Commands

Slash commands work natively:

```
/onboard
/prep
/health
```

## Cursor

### Configuration

Settings are in `.cursor/settings.json` (linked from `.claude/settings.json`).

Cursor uses `.cursorrules` for project instructions - this can be symlinked to `CLAUDE.md`.

### Permissions

Cursor uses `permissions.deny` for static blocking (no runtime hooks). Add dangerous commands here:

```json
{
  "permissions": {
    "deny": [
      "git reset --hard",
      "git push --force",
      ...
    ]
  }
}
```

### Skills

Skills must be loaded manually via @-mentions in Composer mode:

```
@.claude/skills/tdd/SKILL.md
@.claude/skills/debugging/SKILL.md

Implement the search feature
```

Or use the symlinked path:

```
@.cursor/skills/tdd/SKILL.md
```

### Commands

Commands work via Composer. Type the command and press Enter:

```
/onboard
```

Cursor will read the command file and execute.

## Shared Components

These work identically on both platforms:

### Husky Git Hooks

`.husky/pre-commit` and `.husky/pre-push` run on both:

```bash
# .husky/pre-commit
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"
npx lint-staged
pnpm typecheck
```

### Skills Content

All skills are in `.claude/skills/`. Cursor accesses them via symlink:

```
.cursor/skills -> ../.claude/skills
```

### Commands Content

All commands are in `.claude/commands/`. Both platforms read from here.

### Scripts

The Ralph loop scripts work on both:

```bash
./.claude/scripts/ralph.sh "Your task"
```

## Setup for Cursor

1. Create symlinks:

```bash
cd .cursor
ln -s ../.claude/skills skills
```

2. Add to `.cursor/settings.json`:

```json
{
  "mcp": {
    "servers": {
      "brief": {
        "url": "https://app.briefhq.ai/api/mcp/sse",
        "transport": "sse",
        "headers": {
          "Authorization": "Bearer YOUR_API_KEY"
        }
      }
    }
  }
}
```

3. Optionally link `.cursorrules`:

```bash
ln -s CLAUDE.md .cursorrules
```

## Limitations by Platform

### Claude Code Limitations

- No `permissions.deny` file (use hooks instead)
- Hooks must be shell scripts

### Cursor Limitations

- No runtime hooks (PreToolUse, Stop)
- No native TodoWrite (use text-based tracking)
- Skills not auto-loaded (need @-mentions)
- Ralph stop hook doesn't work (use external loop only)

## Recommendations

### For Claude Code Users

- Use the full hook system
- Rely on automatic skill detection
- Use native TodoWrite for task tracking
- Use both external Ralph loop and stop hook

### For Cursor Users

- Configure `permissions.deny` for static blocking
- Use @-mentions to load skills explicitly
- Use Composer mode for complex tasks
- Use external Ralph loop only (stop hook won't work)
- Keep instructions in `.cursorrules` (link to CLAUDE.md)
