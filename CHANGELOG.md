# Changelog

All notable changes to Brief Wiggum will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of Brief Wiggum
- Git safety guards (11 dangerous patterns blocked)
- Ralph Wiggum iterative execution loop
- 12 skills for AI agent guidance
- 11 slash commands for common workflows
- 5 agent personas for specialized tasks
- Platform support for Claude Code and Cursor
- Example configurations for Next.js and Python FastAPI
- Multi-model peer review (`/peer-review` command)
- Comprehensive documentation

### Security
- PreToolUse hooks block destructive git operations
- Stop hooks prevent premature task completion
- Protected branch push prevention

## [0.1.0] - 2025-01-22

### Added
- Initial public release
- Core infrastructure (hooks, scripts, skills, commands, agents)
- Brief MCP integration
- Linear integration support
- Documentation and examples

---

## Version Guidelines

- **MAJOR**: Breaking changes to hook behavior or command interfaces
- **MINOR**: New skills, commands, or features
- **PATCH**: Bug fixes, documentation updates, minor improvements
