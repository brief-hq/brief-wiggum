---
description: Process PR review comments from CodeRabbit, Cubic, and human reviewers
---

# Joust the Rabbit (and the Cube)

Poll for and process PR review comments from CodeRabbit, Cubic, and human reviewers. Applies fixes locally but does NOT commit - returns control to user for `/prep`.

## Architecture

This is a **skill document** - instructions for an AI agent (Claude), not executable code. The agent follows these instructions during PR review sessions.

This skill runs as a **subagent loop**:

1. **Subagent** polls for comments, applies fixes, and **notes replies to post** (in memory/context)
2. **Subagent emits** code changes back to main agent
3. **Main agent** validates the work and prompts user to `/prep`
4. **After `/prep` pushes**, agent posts the noted replies via `gh api`
5. **Loop continues** if CodeRabbit/Cubic counter-replies need action

**Why reply after push?** CodeRabbit re-checks the code when you reply. If your fix isn't pushed yet, CodeRabbit counter-replies disputing it. Always push first, then reply.

## Workflow

### 1. Get PR Context
```bash
gh pr view --json number,headRefName,url
```

### 2. Wait for Bot Analysis

Both CodeRabbit and Cubic take 1-3 minutes to analyze new commits. **You MUST wait for analysis to complete before processing comments.**

#### 2a. Check Processing Status

Check if bots are still analyzing:

```bash
# Get the latest CodeRabbit and Cubic issue comments
gh api /repos/brief-hq/brief/issues/{number}/comments | \
  jq '[.[] | select(.user.login == "coderabbitai[bot]" or .user.login == "cubic-dev-ai[bot]")] | last | .body' | head -5
```

If you see "Currently processing new changes in this PR" - **WAIT**. Poll every 30 seconds until this clears.

#### 2b. Compare Against Latest Commit

Get the latest commit SHA and timestamp:
```bash
gh pr view {number} --json commits --jq '.commits[-1] | "\(.oid) \(.committedDate)"'
```

Then check if the bots' latest reviews are AFTER this commit:
```bash
# Get CodeRabbit's walkthrough comment timestamp
gh api /repos/brief-hq/brief/issues/{number}/comments | \
  jq '[.[] | select(.user.login == "coderabbitai[bot]" and (.body | contains("Walkthrough")))] | last | .updated_at'

# Get Cubic's latest review comment timestamp
gh api /repos/brief-hq/brief/issues/{number}/comments | \
  jq '[.[] | select(.user.login == "cubic-dev-ai[bot]")] | last | .updated_at'
```

**Only proceed when BOTH bot review timestamps are AFTER the latest commit timestamp.**

#### 2c. Poll Until Ready

```bash
# Poll every 30 seconds, timeout after 5 minutes
gh api /repos/brief-hq/brief/pulls/{number}/comments | \
  jq '[.[] | select(.user.login == "coderabbitai[bot]" or .user.login == "cubic-dev-ai[bot]")]'
```

**CodeRabbit Rate Limit Handling**: If CodeRabbit posts "Rate limit exceeded":
1. Parse wait time from message (e.g., "wait 16 minutes and 56 seconds")
2. Report: "CodeRabbit rate limited. Waiting ~17 minutes..."
3. Sleep for wait time + 1-minute buffer
4. Trigger re-review: `gh api /repos/brief-hq/brief/issues/{number}/comments -f body="@coderabbitai review"`
5. Resume polling

**Cubic Rate Limit Handling**: Cubic has different limits:
- **Free plan**: 20 PR reviews/month quota
- **Paid plans**: Unlimited reviews (but GitHub API limits still apply)
- **Per-PR limit**: 150 eligible files processed per review

If Cubic posts "quota exceeded" or similar:
1. Check current plan status in Cubic's PR summary comment
2. Report: "Cubic quota exhausted for this billing period."
3. For free plans: Alert user to consider upgrading or wait for quota reset
4. For file limits: Cubic may skip some files - check its summary for "X of Y files reviewed"
5. **Note**: Cubic quota status visible in PR comments under "cubic analysis" header

### 3. Fetch All Review Comments
```bash
# Code-level review comments (both bots + humans)
gh api /repos/brief-hq/brief/pulls/{number}/comments

# PR-level issue comments
gh api /repos/brief-hq/brief/issues/{number}/comments
```

### 4. Categorize by Source

**CodeRabbit** (`user.login == "coderabbitai[bot]"`):
- Parse severity: `_🔴 Critical_`, `_⚠️ Potential issue_`, `_🟡 Minor_`, `_💡 Suggestion_`
- Extract committable suggestion from `📝 Committable suggestion` block
- Extract AI instructions from `🤖 Prompt for AI Agents` block

**Cubic** (`user.login == "cubic-dev-ai[bot]"`):
- Parse priority: `P1:` (rule violation, must fix), `P2:` (suggestion, should fix)
- Parse metadata from HTML comment: `<!-- metadata:{"confidence":N,"steps":[...]} -->`
- Higher confidence (9+) = more certain, prioritize these
- Extract rule name from `Rule violated: **Rule Name**` pattern
- Look for `Prompt for AI agents` in `<details>` block for fix instructions
- Cubic references team learnings/feedback - these inform context but don't always require changes

**Human reviewers** (`user.type == "User"`):
- Classify intent: question, approval, change request, architectural feedback
- No structured format - interpret natural language

### 5. Triage Each Comment

**Default: Fix almost everything.** There's basically zero cost to addressing even minor feedback. Be aggressive about applying fixes rather than pushing back.

**Auto-fix** (apply without asking):
- ANY severity/priority level with a clear fix
- Has a committable suggestion (CodeRabbit) or code suggestion (Cubic)
- Localized changes (single file, few lines)
- Even "suggestions" - just do them

**Verify first** (check against codebase):
- Suggestion changes core behavior
- Affects multiple files significantly
- Run `guard_approach` if architectural

**Reject** (rare - explain why):
- Directly conflicts with Brief decisions
- Would break existing functionality
- Based on factually incorrect assumptions
- Requires admin client intentionally (e.g., RPC calls)
- **Cubic rule violations that don't apply**: e.g., "hand-written SQL" when it was actually drizzle-kit generated

> **Note:** `guard_approach` is a Brief MCP operation that validates approaches against recorded architectural decisions:
> ```
> mcp__brief__brief_execute_operation(operation: "guard_approach", parameters: { approach: "description" })
> ```

#### Cubic-Specific Triage

Cubic focuses on **rule enforcement** based on team learnings. Common patterns:

| Cubic Comment Pattern | Action |
|-----------------------|--------|
| `P1: Rule violated: **Database Migration...**` + "hand-written SQL" | **Check if drizzle-kit generated**. If DDL file or `--custom` migration, reply "Drizzle generated" |
| `P1: Rule violated:` + clear code issue | Fix it |
| `P2:` + suggestion with code | Fix it |
| `P2:` + architectural suggestion | Defer with reply if complex |
| References "team feedback" | Context only, fix if actionable |
| Low confidence (<7) | Verify before acting |

### 6. Apply Fixes Locally

For auto-fix items:
1. Read the file at the specified path
2. Find the code matching the `diff_hunk` context
3. Apply the committable/code suggestion
4. Stage the file (`git add {path}`)

**IMPORTANT: Do NOT commit or push.** Leave changes staged for user review.

### 7. Reply to Comments

**⚠️ CRITICAL: Reply AFTER pushing, not before.**

CodeRabbit re-checks the code when you reply. If changes are only staged (not pushed), CodeRabbit counter-replies disputing your fix because it can't see it yet. This creates unnecessary back-and-forth.

**Correct order:**
1. Apply fixes and stage changes (Section 6)
2. Return control to user for `/prep` (commits and pushes)
3. **AFTER push completes**, reply to comments

If running in a loop, note the replies and post them only after `git push` succeeds.

**Error handling:**
- If `/prep` validation fails: fix issues, re-run `/prep` before posting replies
- If `git push` fails: resolve conflicts/errors, re-push, then post replies
- If reply posting fails: retry via `gh api`, or notify user to post manually

**IMPORTANT: Reply to ALL comments** - even already-fixed ones need confirmation replies.

**Keep replies VERY short** (3-4 words max). Both bots ignore longer messages.

Good examples:
- "Fixed - staged"
- "Fixed - orgId added"
- "Intentional - RPC needs admin"
- "Drizzle generated DDL"
- "Drizzle --custom generated"
- "Deferred - separate ticket"
- "Already escaped"

Bad examples (too long):
- "I've fixed this issue by adding the orgId parameter to the function"
- "This was intentionally designed this way because..."

```bash
# Reply to a review comment
gh api /repos/brief-hq/brief/pulls/{number}/comments/{comment_id}/replies \
  -f body="Fixed - staged"
```

### 7.1 Check for Bot Counter-Replies

After replying, bots may respond with corrections or follow-up questions. Check for these:

```bash
# Fetch replies to find bot counter-replies
gh api /repos/brief-hq/brief/pulls/{number}/comments | \
  jq '[.[] | select(.in_reply_to_id != null and (.user.login == "coderabbitai[bot]" or .user.login == "cubic-dev-ai[bot]"))]'
```

If a bot disagrees with your reply (e.g., "that's not parameterized" or "this still needs X"):
1. **Re-read the code** - bots are often right about technical details
2. **Apply the fix** if the correction is valid
3. **Reply acknowledging** the fix: "Fixed - encodeURIComponent added"

Bots are usually technically correct. Default to trusting their counter-arguments.

### 8. Report Results

```
🐰🧊 Jousted {n} comments ({coderabbit} CodeRabbit, {cubic} Cubic, {human} human):

✅ Fixed ({count}) - staged, not committed:
  - {file}:{line} - {description}

📝 Queued Replies ({count}) - will post after push:
  - {comment_id}: "{reply}"

⚠️ Needs Review ({count}):
  - {file}:{line} - {reason}

❌ Rejected ({count}):
  - {file}:{line} - {reason}

👍 Acknowledged ({count}):
  - @{user}: approval noted

---
📋 Next steps:
  1. Review staged changes: `git diff --cached`
  2. Run `/prep` to validate and push
  3. After push succeeds, replies will be posted automatically
```

## Decision Framework

**Bias toward action.** Fix first, verify architecturally if needed (guard_approach is automated, not a question).

| Source | Type | Severity/Intent | Action |
|--------|------|-----------------|--------|
| CodeRabbit | Code | Any | **Fix it** |
| CodeRabbit | Refactor | Major | Fix or defer with reply |
| CodeRabbit | Code | Intentional design | Reply: "Intentional - {reason}" |
| Cubic | P1 Rule violation | Code issue | **Fix it** |
| Cubic | P1 Rule violation | False positive (e.g., drizzle-kit) | Reply: "Drizzle generated" |
| Cubic | P2 Suggestion | Any | Fix or defer with reply |
| Cubic | Low confidence | Any | Verify first |
| Human | Question | - | Reply with answer |
| Human | Approval | - | Acknowledge |
| Human | Change request | Any | Attempt fix |
| Human | Architectural | - | Run guard_approach (automated), then fix |

## Severity Mapping

### CodeRabbit Severities
All severities should be addressed:

- `_🔴 Critical_` → Fix immediately
- `_⚠️ Potential issue_` → Fix it
- `_🟡 Minor_` → Fix it
- `_💡 Suggestion_` → Fix it (low cost, why not?)
- `_🛠️ Refactor suggestion_` → Fix or defer with short reply

### Cubic Priorities
- `P1:` → Must address (rule violation or critical issue)
- `P2:` → Should address (suggestion, improvement)
- Confidence 9+ → High certainty, prioritize
- Confidence <7 → Lower certainty, verify before acting
