---
description: Use when creating new skills or commands for Brief agents. Guides skill structure, TDD approach, and Brief integrations.
---

# Writing Skills

> "Skills are TDD for processes. Watch agents fail first."

## Core Principle

Skills encode learned patterns from agent failures. Before writing a skill, observe agents struggling with a task. The skill captures the missing context that would have prevented failure.

## The TDD Approach

### RED: Baseline Without Skill

1. Give an agent a task that requires the skill
2. Watch it fail or produce suboptimal output
3. Document what went wrong:
   - Missing context?
   - Wrong patterns used?
   - Violated constraints?
   - Missed integration points?

**Example observation:**
```text
Task: "Create a Brief MCP tool for document tagging"
Failure: Agent created tool without Zod validation, skipped authentication,
         didn't update brief-guidelines.md, used wrong file structure
```

### GREEN: Write Minimal Skill

Create the smallest skill that fixes the observed failures:

1. Create `/.claude/skills/[skill-name]/SKILL.md`
2. Add YAML frontmatter with description
3. Document only what the agent needed
4. Don't over-engineer or anticipate future needs

### REFACTOR: Test and Iterate

1. Run the same task with skill loaded
2. If agent still fails, identify the gap
3. Add minimal content to address the gap
4. Repeat until agent succeeds consistently

## Skill Structure

### File Location

```
.claude/skills/
  [skill-name]/
    SKILL.md          # Main skill file (required)
    reference/        # Optional supporting docs
      patterns.md
      examples.md
```

### YAML Frontmatter (Required)

```yaml
---
description: One-line description starting with "Use when..." or action verb
---
```

The description determines when the skill is suggested to agents. Be specific:

**Good descriptions:**
- `Use when implementing new features, fixing bugs, or making behavior changes`
- `Validate implementation approaches against Brief decisions`
- `Brief-specific code patterns and conventions`

**Bad descriptions:**
- `General development skill` (too vague)
- `Helpful patterns` (doesn't say when to use)

### Content Structure

```markdown
---
description: Use when [specific trigger condition]
---

# Skill Name

> "Core principle in one memorable line" (optional)

## When to Apply

- Specific triggers
- Context indicators
- Task patterns

## The Pattern / Process / Workflow

Step-by-step guidance with code examples.

## Integration with Brief

How this skill connects to other Brief systems.

## Common Mistakes / Red Flags

What to avoid. Quick reference for agents.

## Verification Checklist (optional)

How to confirm the skill was applied correctly.
```

## Command vs Skill Distinction

| Aspect | Skill | Command |
|--------|-------|---------|
| Location | `.claude/skills/[name]/SKILL.md` | `.claude/commands/[name].md` |
| Purpose | Knowledge/patterns to apply | Action to execute |
| Invocation | Auto-loaded by context or explicitly | User types `/command` |
| Examples | `tdd`, `brief-patterns`, `security-patterns` | `/onboard`, `/prep`, `/health` |
| Returns | Context for agent to use | Completed action with output |

**Rule of thumb:**
- If it's "how to do X" -> Skill
- If it's "do X now" -> Command

Commands often reference skills for their implementation:
```markdown
# /prep command
...
Uses: `testing-strategy` skill, `security-patterns` skill
```

## Brief-Specific Integration Points

Every Brief skill should consider these integration points:

### 1. guard_approach (Decision Validation)

For skills involving architectural or process decisions:
```typescript
// Check approach against existing decisions
mcp__brief__brief_execute_operation({
  operation: "guard_approach",
  parameters: { approach: "Description of approach" }
})
```

### 2. Brief MCP Context

For skills needing product context:
```typescript
// Get onboarding context
mcp__brief__brief_get_onboarding_context()

// Get specific context
mcp__brief__brief_prepare_context({
  preparation_type: "get_context",
  keys: ["product", "personas", "decisions"]
})
```

### 3. Testing Requirements

Reference the `testing-strategy` skill:
- 80% coverage for new features
- Test error paths, not just happy paths
- Mock Supabase and Clerk appropriately

### 4. Code Patterns

Reference the `brief-patterns` skill:
- API route structure (Zod, withV1Auth, error handling)
- Database patterns (RLS, Drizzle, migrations)
- Component organization (TailStack, chat-ui sharing)

### 5. Security Patterns

Reference the `security-patterns` skill:
- Authentication requirements
- RLS enforcement
- Input validation

### 6. Documentation Updates

Skills should note when docs need updating:
- `/docs` for API changes
- `brief-guidelines.md` for MCP tool changes
- README for setup changes

## Example: Creating a New Skill

### Observed Failure

Agent asked to "add analytics tracking to Button component" produces:
- Hardcoded PostHog calls scattered in component
- No abstraction for analytics provider
- Missing user consent check
- No documentation

### Minimal Skill

```markdown
---
description: Use when adding analytics, tracking, or telemetry to Brief components
---

# Analytics Patterns

## When to Apply

- Adding event tracking to components
- Implementing user analytics
- Adding performance monitoring

## The Pattern

1. Use `useAnalytics` hook from `@/hooks/use-analytics`
2. Events must include: `event_name`, `properties`, `timestamp`
3. Check consent before tracking: `if (analyticsConsent.granted)`
4. Document new events in `/docs/analytics-events.md`

## Integration with Brief

- Check `guard_approach` before adding new analytics provider
- Follow `security-patterns` for PII handling
- Update docs per `brief-patterns` documentation requirements

## Common Mistakes

- Direct PostHog calls (use hook instead)
- Tracking without consent check
- Undocumented event names
- PII in event properties
```

## Verification Checklist

Before finalizing a new skill:

- [ ] Observed agent failure without skill (RED phase)
- [ ] Skill addresses specific observed failure
- [ ] Description starts with "Use when..." or action verb
- [ ] Content is minimal (no speculative additions)
- [ ] Brief integration points documented where relevant
- [ ] Tested with agent on original task (GREEN phase)
- [ ] Iterated based on remaining failures (REFACTOR phase)

## References

- `tdd` skill for the TDD approach applied to code
- `brief-patterns` skill for code pattern documentation style
- `decision-guard` skill for architectural validation
- `testing-strategy` skill for test requirements
