# Claude Code Hooks

This directory contains hooks that intercept Claude Code tool calls for safety and workflow enforcement.

## How Hooks Work

Claude Code supports two hook types:

1. **PreToolUse** - Runs before a tool executes. Can block execution by returning exit code 2.
2. **Stop** - Runs when the agent attempts to stop. Can prevent stopping to keep the agent working.

Hooks receive context via environment variables:
- `CLAUDE_TOOL_INPUT` - JSON containing the tool's parameters

## Available Hooks

### git-guard.sh

**Type**: PreToolUse (on Bash tool)

Blocks dangerous git operations before they execute:

| Pattern | Blocked Operation | Safe Alternative |
|---------|-------------------|------------------|
| `--ours/--theirs` | Merge conflict shortcuts | Manual conflict resolution |
| `git reset` | HEAD manipulation | `git stash` first |
| `git checkout .` | Discard all changes | `git stash` first |
| `git restore` | Discard working changes | `git stash` first |
| `git clean -f` | Delete untracked files | `git clean -n` dry run |
| `git stash drop/clear` | Delete stashed work | Review with `git stash list` |
| `git push origin main` | Direct push to protected | Create PR branch |
| `git rebase` | History rewriting | Use `git merge` |
| `git branch -D` | Force delete branch | Use `git branch -d` |

### verify-complete.sh

**Type**: Stop hook

Prevents the agent from stopping until verification passes. Opt-in via environment variables:

```bash
export RALPH_VERIFY=1
export RALPH_VERIFY_TYPE=all  # Options: all, tests, lint, typecheck, quick, build
```

This enables the "Ralph Wiggum Loop" - the agent keeps working until code quality gates pass.

## Configuration

Hooks are configured in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": ".claude/hooks/git-guard.sh" }]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [{ "type": "command", "command": ".claude/hooks/verify-complete.sh" }]
      }
    ]
  }
}
```

## Adding New Hooks

1. Create a new `.sh` file in this directory
2. Make it executable: `chmod +x hook-name.sh`
3. Add it to `.claude/settings.json` with the appropriate matcher
4. Document it in this README

## Exit Codes

- `0` - Allow the operation
- `2` - Block the operation (for PreToolUse) or prevent stopping (for Stop)

When blocking, output JSON to stderr:
```json
{
  "decision": "block",
  "reason": "Explanation of why this is blocked and what to do instead"
}
```
