# Brief Wiggum

[![Validate](https://github.com/brief-hq/brief-wiggum/actions/workflows/validate.yml/badge.svg)](https://github.com/brief-hq/brief-wiggum/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Status: Experimental](https://img.shields.io/badge/Status-Experimental-orange.svg)](#disclaimer)

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
./.claude/scripts/ralph.sh "Implement feature X with tests"
./.claude/scripts/ralph.sh --linear BRI-123 "Fix the bug"
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
| `development` | TDD, debugging, testing |
| `patterns` | API, database, security |
| `brief-design` | Design system |
| `extensions` | Chrome, MCP |
| `visual-testing` | Playwright |

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
| `/design` | Design system compliance and polish |
| `/joust-rabbit` | Process PR review comments |
| `/peer-review` | Multi-model code review (OpenAI, Gemini) |

### Agent Personas

Specialized agents for complex tasks:

| Agent | Purpose |
|-------|---------|
| `context-loader` | Load all context layers |
| `task-planner` | Plan implementation with Brief context |
| `implementation` | Autonomous coding with permission gates |
| `pr-preparer` | Pre-commit validation |
| `code-explorer` | Codebase navigation |

## Philosophy

Brief Wiggum follows these principles:

1. **Fresh context per iteration** - Each Ralph loop iteration starts with empty context. State carries via files, not session history. This keeps the AI in its "smart zone" ([why this matters](https://www.aihero.dev/blog/posts/why-the-anthropic-ralph-plugin-sucks)).

2. **Simplicity over configuration** - Four principles in CLAUDE.md, not 200 lines of rules.

3. **Goal-driven execution** - Define success criteria (tests pass, types check), let the agent loop until verified.

4. **Business context injection** - Brief MCP provides product strategy, decisions, and customer insights so AI doesn't just write code—it writes the right code.

## Requirements

- **Brief MCP**: Connect to your Brief workspace ([setup guide](docs/brief-mcp-setup.md))
- **Claude Code** or **Cursor**: AI-assisted development environment
- **pnpm/npm/yarn**: For running build commands
- **Optional**: `OPENAI_API_KEY` and/or `GEMINI_API_KEY` for `/peer-review`

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

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE)

---

Named after the [Ralph Wiggum Loop](https://awesomeclaude.ai/ralph-wiggum) pattern for iterative AI agent execution.
