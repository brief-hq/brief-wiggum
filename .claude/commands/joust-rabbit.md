---
description: Process PR review comments from CodeRabbit, Cubic, and human reviewers
---

# Joust the Rabbit (and the Cube)

Poll for and process PR review comments from CodeRabbit, Cubic, and human reviewers. Uses `agent-reviews` CLI for all GitHub comment operations. Applies fixes locally, returns control to user for `/prep`.

**Why reply after push?** CodeRabbit re-checks when you reply. If the fix isn't pushed yet, it counter-replies disputing it. Always push first, then reply.

## Workflow

### 1. Fetch Unanswered Bot Comments

```bash
npx agent-reviews --bots-only --unanswered --json
```

If no comments found, check if bots are still analyzing:

```bash
npx agent-reviews --bots-only --json
```

If you see "Currently processing new changes" in any bot comment body, wait and poll:

```bash
# Poll every 30s until new comments appear
npx agent-reviews --watch --bots-only --interval 30 --timeout 300
```

### 2. Fetch Human Comments (if any)

```bash
npx agent-reviews --humans-only --unanswered --json
```

### 3. Categorize by Source

From the JSON output, categorize each comment:

**CodeRabbit** (`author` contains "coderabbitai"):
- Parse severity: `_🔴 Critical_`, `_⚠️ Potential issue_`, `_🟡 Minor_`, `_💡 Suggestion_`
- Extract committable suggestion from `📝 Committable suggestion` block
- Extract AI instructions from `🤖 Prompt for AI Agents` block

**Cubic** (`author` contains "cubic-dev-ai"):
- Parse priority: `P1:` (rule violation, must fix), `P2:` (suggestion, should fix)
- Higher confidence (9+) = more certain, prioritize these
- Look for `Prompt for AI agents` in `<details>` block for fix instructions

**Human reviewers**:
- Classify intent: question, approval, change request, architectural feedback

### 4. Triage Each Comment

**Default: Fix almost everything.** There's basically zero cost to addressing even minor feedback.

**Auto-fix** (apply without asking):
- ANY severity/priority level with a clear fix
- Has a committable suggestion (CodeRabbit) or code suggestion (Cubic)
- Localized changes (single file, few lines)

**Verify first** (check against codebase):
- Suggestion changes core behavior or affects multiple files
- Run `brief ask --mode check` if architectural

**Defer (needs approval)** — don't silently defer, ask user:
- Too large or cross-cutting to fix inline
- Out of scope for this PR
- Requires architectural discussion or broader refactor

**Reject** (rare - explain why):
- Directly conflicts with Brief decisions
- Based on factually incorrect assumptions
- Requires admin client intentionally (e.g., RPC calls)
- **Cubic false positives**: e.g., "hand-written SQL" when it was drizzle-kit generated

> Use `brief ask --mode check` to validate approaches against recorded architectural decisions:
> ```bash
> brief ask --mode check "We plan to [description]"
> ```

### 5. Apply Fixes Locally

For each auto-fix item:
1. Read the file at the specified path
2. Find the code matching the `diff_hunk` context
3. Apply the fix
4. Stage the file (`git add {path}`)

**Do NOT commit or push.** Leave changes staged for user review.

### 5.5. Deferral Approval

If any comments were triaged as **Defer**, present them to the user for approval. Use `AskUserQuestion` to let the user choose per-item:

```text
⏸️ Deferred Items — Approval Needed ({count}):

1. {file}:{line} - {summary of what's requested}
   Reason: {why agent wants to defer — too large, cross-cutting, etc.}
   → [Fix it] [Defer → create ticket] [Ignore]

2. ...
```

For each item the user chooses:
- **Fix it** — apply the fix now (move to auto-fix queue, go back to Step 5)
- **Defer → create ticket** — create a Linear issue and queue reply "Deferred — {issue identifier}"
- **Ignore** — skip fix, but queue a short terminal reply (e.g., "Ignored - not planned") so it is posted after push and marks the thread as answered

**Creating Linear tickets for approved deferrals:**

```bash
linearis issues create "$(cat <<'LINEARIS_TITLE'
{summary}
LINEARIS_TITLE
)" \
  --description "$(cat <<'LINEARIS_DESC'
From PR review comment on {PR}:

{comment body}

File: {file}:{line}
LINEARIS_DESC
)" \
  --team BRI \
  --labels "Improvement" \
  --priority 3
```

Extract the created issue identifier from the command output to use in the reply.

### 6. Queue Replies (Do Not Post Yet)

Note the reply for each comment. Keep replies **very short** (3-4 words max):

- "Fixed - staged"
- "Fixed - orgId added"
- "Intentional - RPC needs admin"
- "Drizzle generated DDL"
- "Deferred — BRI-XXXX" (with actual ticket identifier from Linear)

### 7. Report Results

```
🐰🧊 Jousted {n} comments ({coderabbit} CodeRabbit, {cubic} Cubic, {human} human):

✅ Fixed ({count}) - staged, not committed:
  - {file}:{line} - {description}

📝 Queued Replies ({count}) - will post after push:
  - {comment_id}: "{reply}"

⚠️ Needs Review ({count}):
  - {file}:{line} - {reason}

🎫 Deferred ({count}) - tickets created:
  - {issue identifier}: {title} (from {file}:{line})

❌ Rejected ({count}):
  - {file}:{line} - {reason}

📋 Next steps:
  1. Review staged changes: `git diff --cached`
  2. Run `/prep` to validate and push
  3. I'll automatically post queued replies once the push succeeds
```

### 8. Post Replies (After Push)

After `/prep` pushes successfully, **immediately continue in this session** and post all queued replies. Do not wait for user input — the push is the trigger:

```bash
npx agent-reviews --reply {comment_id} "Fixed - staged"
```

### 9. Check for Counter-Replies (max 3 cycles)

After replying, bots may counter-reply. Check for new unanswered comments:

```bash
npx agent-reviews --bots-only --unanswered --json
```

If new comments appear, loop back to Step 3. Track the cycle count:

- **Cycle 1-2**: Fix and reply. Bots are usually technically correct — default to trusting their counter-arguments.
- **Cycle 3**: Final attempt. If bots still dispute after this fix, stop looping.
- **After cycle 3**: Escalate to the user. Report which comments remain unresolved and why, so the user can review manually or open a follow-up ticket.

## Decision Framework

**Bias toward action.** Fix first, verify architecturally if needed.

| Source | Type | Action |
|--------|------|--------|
| CodeRabbit | Any severity | **Fix it** |
| CodeRabbit | Intentional design | Reply: "Intentional - {reason}" |
| CodeRabbit | Cross-cutting / large | **Defer (ask user)** |
| Cubic | P1 Rule violation | **Fix it** |
| Cubic | P1 False positive (drizzle-kit) | Reply: "Drizzle generated" |
| Cubic | P2 Suggestion | Fix or defer with reply |
| Cubic | P2 Cross-cutting / large | **Defer (ask user)** |
| Cubic | Low confidence (<7) | Verify first |
| Human | Change request | Attempt fix |
| Human | Change request (large scope) | **Defer (ask user)** |
| Human | Question | Reply with answer |
| Human | Architectural | Run `brief ask --mode check`, then fix |
