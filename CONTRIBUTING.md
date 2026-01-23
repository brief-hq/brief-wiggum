# Contributing to Brief Wiggum

Thank you for your interest in contributing to Brief Wiggum! This document provides guidelines for contributing.

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## How to Contribute

### Reporting Bugs

1. **Check existing issues** - Search [GitHub Issues](https://github.com/Mocksi/brief-wiggum/issues) to see if the bug has already been reported.
2. **Create a new issue** - Use the bug report template and include:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Your environment (OS, Claude Code/Cursor version, etc.)

### Suggesting Features

1. **Check existing discussions** - Your idea may already be under discussion.
2. **Open a feature request** - Use the feature request template.
3. **Be specific** - Explain the use case and how it fits with Brief Wiggum's goals.

### Submitting Changes

1. **Fork the repository**
2. **Create a branch** - Use a descriptive name like `feature/add-python-support` or `fix/git-guard-regex`
3. **Make your changes** - Follow existing patterns and conventions
4. **Test your changes** - Run the setup script and verify hooks work
5. **Submit a pull request** - Use the PR template

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/brief-wiggum.git
cd brief-wiggum

# Run setup
./.claude/scripts/setup.sh

# Test hooks work
# Try running a blocked command - it should be blocked
```

## Guidelines

### Skills

- Follow the existing SKILL.md format
- Include clear triggers and workflows
- Test with both Claude Code and Cursor if possible

### Commands

- Keep commands focused on one workflow
- Document all steps clearly
- Include usage examples

### Hooks

- Test regex patterns thoroughly
- Provide helpful error messages with alternatives
- Don't block legitimate operations

### Scripts

- Use `set -euo pipefail` for safety
- Add clear comments explaining purpose
- Make scripts portable (avoid bash-specific features when possible)

## Questions?

- Open a [Discussion](https://github.com/Mocksi/brief-wiggum/discussions)
- Check the [docs/](docs/) directory

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
