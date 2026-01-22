---
description: Load context and prepare for work
---

# /onboard [BRI-XXX]

Onboard to the Brief repository with full context loading.

## Without Issue ID

`/onboard`

1. Load Brief MCP context (onboarding_context)
   - Product: customers, service definition, goals
   - Personas: top user personas with needs
   - Work: current building, committed items
   - Velocity: throughput, cycle time, release frequency
   - Decisions: recent architectural/business decisions
   - Insights: customer themes, sentiment
2. Review Brief guidelines (.brief/brief-guidelines.md)
3. Check repo rules (.cursor/commands/prep.md or .claude/commands/prep.md)
4. Report: "Onboarded. Product: [summary]. Recent work: [summary]. Ready."

## With Issue ID

`/onboard BRI-766`

1. Load Brief MCP context (as above)
2. Fetch Linear issue (title, description, acceptance criteria, relations)
3. Load linked Brief documents if any
4. Create TodoWrite list from acceptance criteria
5. Report: "Loaded BRI-766: [title]. Context: [brief summary]. Created [N] todos. Ready to start."

**For Cursor users**: Report also includes @-mentions for key files to include in context window.

## Tools Used

- mcp__brief__brief_get_onboarding_context
- mcp__linear-server__get_issue (if issue provided)
- Read (for guidelines)
- TodoWrite (if issue provided)

## Available Commands

After onboarding, these commands are available:

| Command | Purpose |
|---------|---------|
| `/prep` | Pre-commit validation (lint, test, security) |
| `/todo-all` | Execute all pending todos |
| `/health` | Check agent environment health |
| `/design-audit` | Audit UI for design system compliance |
| `/design-polish` | Refine component to use Brief tokens |
| `/design-simplify` | Reduce complexity while preserving brand |
| `/design-animate` | Add purposeful motion to components |
