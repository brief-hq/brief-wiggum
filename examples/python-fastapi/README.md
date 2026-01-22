# Python FastAPI + Brief Example

This example shows how to adapt Brief Wiggum for a Python FastAPI project.

## Stack

- **Framework**: FastAPI
- **Database**: PostgreSQL
- **ORM**: SQLAlchemy 2.0
- **Migrations**: Alembic
- **Auth**: Auth0 (or similar)
- **Testing**: pytest

## Key Differences from Node.js

Brief Wiggum is designed for Node.js projects but can be adapted for Python:

1. **Build commands** - Replace pnpm with pip/poetry
2. **Test commands** - Replace vitest with pytest
3. **Lint commands** - Replace eslint with ruff/black/flake8
4. **Type checking** - Replace tsc with mypy

## Setup

1. Copy the CLAUDE.md from this directory to your project root
2. Copy the .claude/ directory from the parent brief-wiggum repo
3. Update verification commands in:
   - `.claude/hooks/verify-complete.sh`
   - `.claude/scripts/ralph-prompts.sh`
4. Connect Brief MCP (same as Node.js projects)
5. Run `/onboard`

## Customization Notes

This example demonstrates how to adapt:

- API route patterns for FastAPI
- Database patterns for SQLAlchemy
- Testing patterns for pytest
- Linting patterns for ruff

The core Brief Wiggum concepts (skills, commands, guards) remain the same.
