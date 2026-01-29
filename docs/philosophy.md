# The Ralph Wiggum Philosophy

> "I'm helping!" - Ralph Wiggum

> ⚠️ **Note**: This methodology is experimental. While these patterns have been used in production at Brief, your mileage may vary. Always review AI-generated changes before committing.

## Origins

The Ralph Wiggum Loop is named after the Simpsons character known for his earnest but often misguided attempts to help. Like Ralph, AI agents are eager to assist but sometimes need multiple attempts and gentle guidance to get things right.

The pattern was popularized by [awesomeclaude.ai](https://awesomeclaude.ai/ralph-wiggum) and implemented by teams at Vercel and others.

## Core Principles

### 1. Iteration Over Perfection

The first attempt rarely succeeds. What matters is:
- Clear verification criteria
- Automatic retry on failure
- Learning from each attempt

Don't optimize for first-attempt quality. Optimize for eventual success.

### 2. Failures Are Data

When an agent fails, that failure reveals:
- Missing context
- Ambiguous instructions
- Gaps in guardrails

Each failure is an opportunity to improve the system, not a flaw in the agent.

### 3. Operator Skill Determines Success

The human writing prompts has more impact than the model:
- Clear, specific tasks succeed
- Vague, open-ended tasks fail
- Good prompts include verification criteria

### 4. Persistence Wins

Many tasks that seem to fail are actually just incomplete:
- Type errors need another pass
- Tests reveal edge cases
- Lint fixes expose more issues

The loop handles this automatically.

## The Loop Structure

```
┌─────────────────────────────────────────────────┐
│                  TASK + CONTEXT                  │
│          (Clear goal + Brief product context)    │
└─────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────┐
│               AGENT ATTEMPT N                    │
│    (Skills: TDD, debugging, patterns, etc.)     │
└─────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────┐
│              VERIFICATION                        │
│         (tests, lint, typecheck, build)         │
└─────────────────────────────────────────────────┘
                         │
              ┌──────────┴──────────┐
              │                     │
         ✅ PASS                ❌ FAIL
              │                     │
              ▼                     ▼
┌─────────────────┐     ┌─────────────────────────┐
│     SUCCESS     │     │    RETRY WITH CONTEXT   │
│                 │     │   + failure details     │
│   (or /prep)    │     │   + debugging skill     │
└─────────────────┘     └─────────────────────────┘
                                    │
                                    └──────► (back to AGENT ATTEMPT)
```

## Context Window Management

### The Smart Zone Problem

LLMs have a "smart zone" (first ~40% of context) and a "dumb zone" (remaining context). As the context fills, the model makes worse decisions.

This is why **fresh context per iteration** is essential:

| Approach | Context After 5 Iterations | Quality |
|----------|---------------------------|---------|
| Same session (plugin) | ~80% full, dumb zone | Degraded |
| Fresh session (bash loop) | ~15% full, smart zone | Optimal |

### How Ralph Maintains Fresh Context

1. Each `ralph.sh` iteration spawns a new Claude session
2. Context carries via files (`.ralph/plan.md`, `.ralph/activity.md`), not session history
3. Git history provides implicit context about what changed
4. The LLM always operates in its smart zone

This is why we removed the Stop Hook mode—it kept everything in one session, causing the exact context pollution that degrades AI performance.

## Why It Works

### Automatic Error Correction

Most coding errors are mechanical:
- Missing imports
- Type mismatches
- Syntax errors

The loop catches and fixes these without human intervention.

### Context Accumulation

Each iteration adds context:
- Failure details from previous attempt
- What was tried
- What didn't work

This mimics how humans debug.

### Escalation Path

At iteration 3, the agent is explicitly told to:
- Stop making random changes
- Question the approach itself
- Consider if the architecture is wrong

This prevents infinite loops on fundamentally broken tasks.

## When to Use the Loop

### Good Fit

- **Well-defined tasks**: "Add pagination to the API"
- **Clear verification**: Tests, lint, typecheck
- **Iterative work**: Bug fixes, feature implementation
- **Known patterns**: Following established conventions

### Poor Fit

- **Exploratory work**: "Make the app better"
- **Subjective outcomes**: "Make the UI prettier"
- **Interactive tasks**: Needing constant human feedback
- **Novel architecture**: No existing patterns to follow

## Integration with Brief

Brief Wiggum enhances the basic loop with:

### 1. Product Context

The agent knows what you're building, for whom, and why. This prevents solutions that technically work but don't fit the product.

### 2. Decision Guard

Before making architectural decisions, the agent checks against existing decisions in Brief. This maintains consistency.

### 3. Skills System

Domain-specific knowledge loaded on demand:
- TDD for test-first development
- Debugging for systematic investigation
- Security patterns for compliance
- And more...

### 4. Linear Integration

Tasks come with full context from Linear:
- Issue description
- Acceptance criteria
- Blocking relationships

## Practical Tips

### Write Good Prompts

```bash
# Good: Clear, verifiable, scoped
./ralph.sh "Add input validation to POST /api/v1/documents.
Reject empty titles (400). Reject invalid folder IDs (400).
Add tests that verify validation returns correct errors."

# Bad: Vague, unverifiable
./ralph.sh "Make the API better"
```

### Set Reasonable Limits

```bash
# Start with lower iterations
./ralph.sh --max-iterations 5 "Your task"

# Increase if needed after observing behavior
./ralph.sh --max-iterations 10 "Complex task"
```

### Use Verification Wisely

```bash
# Quick feedback for type-level changes
./ralph.sh --verify-only quick "Refactor types"

# Full verification for feature work
./ralph.sh --verify-only all "Add new endpoint"
```

### Review State Files

After each run, check `~/.claude/ralph-state/`:
- See iteration history
- Identify failure patterns
- Understand what's taking time

## References

- [Original Ralph Wiggum Loop](https://awesomeclaude.ai/ralph-wiggum)
- [Vercel Ralph Loop Agent](https://github.com/vercel-labs/ralph-loop-agent)
- [Dev Interrupted Podcast Episode](https://linearb.io/dev-interrupted/podcast/inventing-the-ralph-wiggum-loop)
