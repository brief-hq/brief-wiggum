# Peer Review (Multi-Model)

Get code review from an external AI model (OpenAI Codex by default), then critically evaluate their findings.

## Usage

```bash
/peer-review              # Review staged/working changes
/peer-review path/to/file # Review specific file
```

## Workflow

### Step 1: Get External Review

Run the external review script to get Codex's perspective:

```bash
./.claude/scripts/external-review.sh codex $ARGUMENTS
```

Capture the full output - this is Codex's review of the code.

**Model options:** `codex` (code-optimized, default), `5.2` (frontier), `gemini`, `gemini3`, `council` (all models)

### Step 2: Critically Evaluate Each Finding

For EACH finding from the external review:

**Verify it exists** - Actually read the code. Does this issue really exist?

**If it doesn't exist** - Explain why:
- Already handled elsewhere in the codebase
- Misunderstood the project's architecture (e.g., auth middleware handles this)
- Code path can't be reached
- Framework handles this (React, Next.js, etc.)

**If it does exist** - Assess severity and add to fix plan

### Step 3: Output

```markdown
## External Review (Codex)

[Paste the raw output from Step 1]

---

## Evaluation

### Valid Findings (Confirmed)

| Finding | Severity | Action |
|---------|----------|--------|
| [Issue] | CRITICAL/HIGH/MEDIUM/LOW | [Fix] |

### Invalid Findings (Rejected)

| Finding | Why Rejected |
|---------|--------------|
| [Issue] | [e.g., "Already handled by auth middleware"] |

### Action Plan

1. [Highest priority fix]
2. [Next fix]
...
```

## Notes

- External models have **no context** about your project's patterns - expect false positives
- Trust your established patterns over external suggestions
- Check `guard_approach` if finding suggests architectural changes
- If genuinely unsure about a finding, mark as "Needs Investigation"

## Requirements

- `OPENAI_API_KEY` in `.env.local` (codex / 5.2)
- `GEMINI_API_KEY` in `.env.local` (gemini / gemini3)
- `jq` installed for JSON parsing

Note: `council` mode requires both API keys to run all models.
