---
description: Run task in iterative Ralph Wiggum Loop until verification passes
---

# /ralph

> "I'm helping!" - Ralph Wiggum

Run a task in an iterative loop until completion criteria are met. Named after the [Ralph Wiggum Loop](https://awesomeclaude.ai/ralph-wiggum) pattern.

**This is an INTELLIGENT loop** - it leverages the entire Brief infrastructure:
- **Skills**: development (TDD + debugging), patterns (API + security), brief-design, extensions
- **Commands**: TodoWrite, guard_approach, Brief MCP
- **Methodology**: TDD (RED-GREEN-REFACTOR), systematic debugging
- **Guards**: Escalation at iteration 3, decision validation

## How It Works

1. **Skill Detection**: Analyzes task to load relevant skills (API, UI, security, etc.)
2. **First Iteration**: Agent receives task with full skill context and TDD instructions
3. **Verification**: Runs tests, lint, typecheck (configurable)
4. **Retry with Context**: If failed, agent gets debugging methodology + failure details
5. **Escalation**: At iteration 3, agent is warned to question the approach
6. **Success**: When verification passes, optionally runs full /prep

## Automatic Skill Detection

The loop analyzes your task and loads relevant skills:

| Task Contains | Skills Loaded |
|---------------|---------------|
| api, route, endpoint, database | patterns |
| component, ui, page, button, form | brief-design, patterns |
| bug, fix, error, broken, test, coverage | development |
| add, implement, create, new, feature | development |
| extension, chrome, mcp, tool | extensions |

**Always loaded**: development, patterns

## Usage

Run from terminal outside Claude Code:

```bash
# Basic usage
./.claude/scripts/ralph.sh "Implement the document search feature with tests"

# With Linear issue for context
./.claude/scripts/ralph.sh --linear BRI-123 "Fix the bug described in the issue"

# With full /prep on success
./.claude/scripts/ralph.sh --full-prep "Add pagination to the API"
```

**Options:**
- `--max-iterations N` - Maximum attempts (default: 10)
- `--verify-only TYPE` - tests, lint, typecheck, build, quick, all (default: all)
- `--linear ID` - Load Linear issue or project for context
- `--brief TITLE` - Load Brief document (PRD, spec, etc.) for context
- `--budget USD` - Max spend per iteration (default: 2.00)
- `--full-prep` - Run full /prep checklist on success
- `--no-resume` - Start fresh each iteration
- `--verbose` - Show full claude output
- `--dry-run` - Preview without executing

## Core Philosophy

From the [Ralph Wiggum methodology](https://awesomeclaude.ai/ralph-wiggum):

1. **Iteration over perfection** - Refinement matters more than first-attempt quality
2. **Failures as data** - Predictable failures reveal what guardrails to add
3. **Operator skill determines success** - Prompt quality matters more than model capability
4. **Persistence wins** - The loop handles retry logic automatically

## Best Practices

### Good Tasks for Ralph Loop

- Well-defined scope with clear acceptance criteria
- Automatic verification (tests, lint, type checks)
- Iterative refinement (bug fixes, feature implementation)
- Tasks that benefit from persistence

### Not Ideal for Ralph Loop

- Exploratory research without clear completion criteria
- Tasks requiring human judgment for completion
- Highly interactive workflows needing constant feedback
- Open-ended creative tasks

### Writing Effective Prompts

```bash
# Good: Clear task with verifiable outcome
./.claude/scripts/ralph.sh "Add input validation to POST /api/v1/documents.
Validation should reject empty titles and invalid folder IDs.
Add tests that verify the validation returns 400 errors."

# Bad: Vague task without clear completion
./.claude/scripts/ralph.sh "Make the API better"
```

### Safety: Always Set Max Iterations

```bash
# Recommended
./.claude/scripts/ralph.sh --max-iterations 5 "Your task"

# Not recommended (uses default of 10)
./.claude/scripts/ralph.sh "Your task"
```

## State Tracking

Each run creates state files in `~/.claude/ralph-state/`:

- `{run-id}.json` - Iteration history, status, timestamps
- `{run-id}.log` - Full output log

View run history:
```bash
ls -la ~/.claude/ralph-state/
cat ~/.claude/ralph-state/*.json | jq .
```

## Integration with Brief Infrastructure

The intelligent Ralph Loop uses the FULL Brief harness:

### Skills Applied Per Iteration

| Skill | First Iteration | Retry Iterations |
|-------|-----------------|------------------|
| `development` | TDD + debugging methodology | Continue cycle, escalate at iteration 3 |
| `patterns` | API/DB/security patterns | Pattern + security compliance check |
| `brief-design` | Design system tokens | Design system validation |
| `extensions` | Chrome/MCP patterns | Extension-specific fixes |

### Commands Used

| Command/Tool | When Used |
|--------------|-----------|
| `TodoWrite` | Break task into trackable steps |
| `guard_approach` | Before architectural decisions |
| `Brief MCP` | Product context when needed |

### Escalation Protocol

At **iteration 3**, the agent receives explicit instructions to:
1. STOP making random changes
2. Question the approach itself
3. Consider if the architecture is wrong
4. Potentially ask for help

## Examples

### Bug Fix with Linear Context

```bash
# Load issue context, apply debugging methodology
./.claude/scripts/ralph.sh --linear BRI-456 --verify-only tests \
  "Fix the foreign key constraint error described in the issue"

# The agent will:
# 1. Load BRI-456 from Linear for context
# 2. Apply debugging skill (4-phase investigation)
# 3. Write regression test FIRST (TDD)
# 4. Implement minimal fix
# 5. Loop until tests pass
```

### Feature Implementation with Full Prep

```bash
# Implement with TDD, run full /prep on success
./.claude/scripts/ralph.sh --full-prep \
  "Add pagination to GET /api/v1/documents/search"

# The agent will:
# 1. Create TodoWrite plan
# 2. Apply development skill (TDD RED-GREEN-REFACTOR)
# 3. Apply patterns skill (Zod, withV1Auth, security)
# 4. Run tests/lint/typecheck until pass
# 5. Run full /prep checklist before done
```

### Quick Iteration for Refactoring

```bash
# Fast feedback with just type checks
./.claude/scripts/ralph.sh --verify-only quick --max-iterations 3 \
  "Refactor the auth middleware to use the new session types"

# Uses 'quick' verification: lint + typecheck only (no tests)
# Good for type-level refactoring
```

### Dry Run to Preview

```bash
# See what prompts would be sent without executing
./.claude/scripts/ralph.sh --dry-run --max-iterations 2 \
  "Fix the auth bug in middleware"

# Shows:
# - Detected skills
# - First iteration prompt (with TDD instructions)
# - Retry prompt (with debugging methodology)
```

## Troubleshooting

### Loop Never Completes

- Check if tests have pre-existing failures
- Reduce scope of the task
- Add `--verbose` to see what's happening
- Try `--verify-only quick` for faster feedback

### Too Many Iterations

- Task may be too complex - break it down
- Prompt may be ambiguous - be more specific
- May need human guidance - reduce max iterations and review

## References

- [Ralph Wiggum Loop origin](https://awesomeclaude.ai/ralph-wiggum)
- [Vercel Ralph Loop Agent](https://github.com/vercel-labs/ralph-loop-agent)
- [Dev Interrupted Podcast](https://linearb.io/dev-interrupted/podcast/inventing-the-ralph-wiggum-loop)
