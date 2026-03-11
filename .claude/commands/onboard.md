---
description: Load context and prepare for work
---

# /onboard [BRI-XXX]

Onboard to the Brief repository with full context loading.

## Without Issue ID

`/onboard`

1. Load Brief context via CLI
   ```bash
   brief context --json
   ```
   - Product: customers, service definition, goals
   - Personas: top user personas with needs
   - Work: current building, committed items
   - Velocity: throughput, cycle time, release frequency
   - Decisions: recent architectural/business decisions
   - Insights: customer themes, sentiment
2. Review Brief guidelines (.brief/brief-guidelines.md)
3. Check repo rules (AGENTS.md is the source of truth; CLAUDE.md and .cursorrules are stubs)
4. Report: "Onboarded. Product: [summary]. Recent work: [summary]. Ready."

## With Issue ID

`/onboard BRI-766`

1. Load Brief context (as above)
2. Fetch Linear issue (title, description, acceptance criteria, relations)
3. Load linked Brief documents if any
4. **Targeted briefing via `brief ask`**: After loading the issue, call `brief ask` with the issue title and description as context:
   ```bash
   brief ask --context "Onboarding to work on BRI-XXX" "What product context, decisions, and customer insights are relevant to: [issue title]? The issue description is: [issue description]"
   ```
   This connects product knowledge to the specific task — surfacing relevant decisions, customer signals, and persona needs that the structured onboarding context alone won't link.
5. Create TodoWrite list from acceptance criteria
6. Report: "Loaded BRI-766: [title]. Context: [brief summary]. Brief says: [key insight from brief ask]. Created [N] todos. Ready to start."

**For Cursor users**: Report also includes @-mentions for key files to include in context window.

## Tools Used

- `brief context --json` (product context)
- `brief ask` (targeted briefing, if issue provided)
- `linearis issues read` (if issue provided)
- Read (for guidelines)
- TodoWrite (if issue provided)

## Available Commands

After onboarding, these commands are available:

| Command | Purpose |
|---------|---------|
| `/prep` | Pre-commit validation (lint, test, security) |
| `/ralph` | Run task in iterative loop until verification passes |
| `/tdd` | Test-driven development workflow |
| `/todo-all` | Execute all pending todos |
| `/health` | Check agent environment health |
| `/peer-review` | Review code changes with AI peer |
| `/joust-rabbit` | Adversarial code review game |
| `/design audit` | Audit UI for design system compliance |
| `/design polish` | Refine component to use Brief tokens |
| `/design simplify` | Reduce complexity while preserving brand |
| `/design animate` | Add purposeful motion to components |
| `/design a11y` | Accessibility audit (WCAG 2.2 AA) |
| `/brief` | Query Brief product context |
| `/debug` | Systematic debugging workflow |
| `/refactor` | Guided code refactoring |
| `/review` | Review PR or diff |
| `/linear` | Interact with Linear issues |
