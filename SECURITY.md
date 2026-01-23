# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.x.x   | :white_check_mark: |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

If you discover a security vulnerability in Brief Wiggum, please report it by emailing security@briefhq.ai.

Please include:

1. **Description** of the vulnerability
2. **Steps to reproduce** the issue
3. **Potential impact** assessment
4. **Suggested fix** (if you have one)

## What to Expect

- **Acknowledgment**: We'll acknowledge receipt within 48 hours
- **Assessment**: We'll assess the vulnerability and determine severity
- **Fix timeline**: Critical issues will be addressed as quickly as possible
- **Disclosure**: We'll coordinate disclosure timing with you

## Scope

This security policy covers:

- Git guard hooks (`.claude/hooks/git-guard.sh`)
- Scripts that execute commands (`.claude/scripts/`)
- Any code that could be used to bypass safety measures

## Out of Scope

- Vulnerabilities in Claude Code or Cursor themselves
- Vulnerabilities in Brief MCP (report to Brief directly)
- Issues that require physical access to a machine

## Recognition

We appreciate responsible disclosure and will acknowledge security researchers who report valid vulnerabilities (unless you prefer to remain anonymous).
