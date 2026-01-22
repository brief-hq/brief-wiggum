# Brief Wiggum

**Open Source AI Agent Harness for Brief Users**

> ⚠️ **EXPERIMENTAL**: This project is in early development and provided "as-is" without warranty. Use at your own risk. The configuration patterns, hooks, and scripts may change significantly between releases. We recommend testing thoroughly in a non-production environment before adopting for critical workflows.

Brief Wiggum provides an AI agent configuration for Claude Code and Cursor that integrates with [Brief](https://briefhq.ai) - the product management tool for AI-native teams.

## Quick Start

> **Prerequisite**: You need Brief MCP connected to your AI editor. See [docs/brief-mcp-setup.md](docs/brief-mcp-setup.md) for setup.

1. Fork this repository
2. Connect Brief MCP in your Claude Code or Cursor settings
3. Customize `CLAUDE.md.template` → `CLAUDE.md` for your project
4. Run `/onboard` to load Brief context and start working

## Features

### Ralph Wiggum Loop

Keep your agent working until verification passes:

```bash
# External loop
./.claude/scripts/ralph.sh "Implement feature X with tests"
./.claude/scripts/ralph.sh --linear BRI-123 "Fix the bug"

# Or enable Stop hook for interactive sessions
export RALPH_VERIFY=1
export RALPH_VERIFY_TYPE=all  # tests|lint|typecheck|quick|all
claude
```

### Git Safety Guards

PreToolUse hooks block dangerous git operations before they execute:

- History rewriting (`--amend`, `rebase`, `reset`)
- Conflict resolution shortcuts (`--ours`, `--theirs`)
- Protected branch pushes (main, master, production)
- Untracked file deletion (`clean -f`)

### Skills System

Modular skills in `.claude/skills/` loaded on demand:

| Skill | Purpose |
|-------|---------|
| `brief-context` | Load Brief business context |
| `brief-patterns` | API routes, database, components |
| `brief-design` | Design system, typography, colors |
| `decision-guard` | Validate against Brief decisions |
| `tdd` | Test-driven development workflow |
| `debugging` | Systematic root cause analysis |
| `testing-strategy` | Coverage requirements |
| `security-patterns` | Auth, RLS, validation |
| `visual-testing` | Playwright-based UI verification |
| `mcp-development` | MCP tool development patterns |
| `chrome-extension` | Extension development |
| `writing-skills` | Meta-skill for creating skills |

### Commands

Slash commands for common workflows:

| Command | Purpose |
|---------|---------|
| `/onboard` | Load Brief + Linear context |
| `/onboard BRI-XXX` | Load specific Linear issue |
| `/prep` | Pre-commit validation |
| `/health` | Check environment |
| `/ralph` | Run iterative loop |
| `/todo-all` | Execute all pending todos |
| `/design-audit` | Audit for design system compliance |
| `/design-polish` | Refine component to use Brief tokens |
| `/joust-rabbit` | Process PR review comments |

### Agent Personas

Specialized agents for complex tasks:

| Agent | Purpose |
|-------|---------|
| `context-loader` | Load all context layers |
| `task-planner` | Plan implementation with Brief context |
| `implementation` | Autonomous coding with permission gates |
| `pr-preparer` | Pre-commit validation |
| `code-explorer` | Codebase navigation |

## Requirements

- **Brief MCP**: Connect to your Brief workspace ([setup guide](docs/brief-mcp-setup.md))
- **Claude Code** or **Cursor**: AI-assisted development environment
- **pnpm/npm/yarn**: For running build commands

## Documentation

| Doc | Description |
|-----|-------------|
| [Quick Start](docs/quick-start.md) | 5-minute setup guide |
| [Brief MCP Setup](docs/brief-mcp-setup.md) | Connect Brief to your editor |
| [Philosophy](docs/philosophy.md) | Ralph Wiggum methodology |
| [Platform Support](docs/platform-support.md) | Claude Code vs Cursor |
| [Customization](docs/customization.md) | Adapt for your stack |

## Examples

See the `examples/` directory for stack-specific configurations:

- [Next.js + Brief](examples/nextjs/)
- [Python FastAPI + Brief](examples/python-fastapi/)

## Disclaimer

**This software is experimental and provided "as-is" without any warranty, express or implied.** By using Brief Wiggum, you acknowledge that:

- AI agents may produce incorrect, incomplete, or unexpected results
- Git guards and hooks are safety measures but cannot guarantee prevention of all data loss
- You are responsible for reviewing all changes before committing
- The maintainers are not liable for any damages arising from use of this software
- Configuration patterns may change significantly between versions

Always maintain proper backups and test in isolated environments before using with important projects.

## License

MIT License - see [LICENSE](LICENSE)

---

Named after the [Ralph Wiggum Loop](https://awesomeclaude.ai/ralph-wiggum) pattern for iterative AI agent execution.
