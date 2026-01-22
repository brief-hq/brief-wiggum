---
description: Validate code quality before commit
---

# /prep

Run full pre-commit validation checklist.

> **Compliance Note**: Brief targets HIPAA and SOC-2 compliance. Security checks below help maintain this posture.

## Checklist

### 1. Debug Logging Check
- Search for console.log, console.debug, debugger statements
- Remove excessive debug logging
- Keep intentional logging only

### 2. Test Coverage Check
- Verify tests exist for changed files
- Run test suite: `pnpm test` (from monorepo root - runs via Turborepo)
- Minimum 80% coverage for new code

### 3. File Size Check
- Check if any changed files exceed 1000 LOC
- Suggest code extraction if needed

### 4. Documentation Check
- Identify if changes warrant /docs updates
- API changes → update API docs
- Architecture changes → update architecture docs

### 5. Code Quality (from monorepo root)
- Run lint: `pnpm lint`
- Run typecheck: `pnpm typecheck`
- Run build: `pnpm build`

### 6. Security Checks (HIPAA/SOC-2)

**Hardcoded Secrets Scan:**
```bash
grep -rE "(sk_live|pk_live|sk_test|api_key|apikey|secret_key|password|credential)" \
  --include="*.ts" --include="*.tsx" --include="*.js" \
  --exclude-dir=node_modules --exclude-dir=.next
```
- FAIL if any matches found (except in .env.example or test mocks)
- Secrets must use environment variables, never hardcoded

**Commented-Out Auth Check:**
```bash
grep -rE "//.*with(V1)?Auth|//.*requireAuth|//.*getAuth|//.*currentUser" \
  --include="*.ts" --include="*.tsx"
```
- FAIL if any matches found
- Commented-out auth is a security vulnerability
- If auth is intentionally removed, delete the line entirely

**Sensitive Data Logging:**
```bash
grep -rE "console\.(log|debug|info).*\b(password|token|secret|key|credential|ssn|dob)\b" \
  --include="*.ts" --include="*.tsx"
```
- FAIL if any matches found
- Never log sensitive data (PHI, PII, credentials)

## Verification Requirements

**Core Rule: NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE**

Before ANY completion claim, you MUST:

1. **Run tests with visible output** - Execute the actual test command, do not assume prior results
2. **Read the output** - Actually examine what the command returned, do not assume success
3. **Check exit codes** - Verify commands completed with exit code 0
4. **Reproduce original issue** - If fixing a bug, confirm the original failure no longer occurs

### Red Flags (NEVER do these)

- Saying "Tests should pass" without running them
- Saying "I believe this works" without evidence
- Claiming success without running the actual commands
- Trusting cached or stale results from earlier in the session
- Paraphrasing output instead of showing it
- Assuming a fix worked without verification

### Evidence Required

For each check, provide:

| Check | Required Evidence |
|-------|-------------------|
| Tests | Actual command output showing pass/fail counts (e.g., "42 passed, 0 failed") |
| Lint | Exit code and any warnings/errors |
| Typecheck | Exit code and error count |
| Build | Exit code and build completion message |
| Security scans | Actual grep output (empty = pass) |

### Example of Proper Verification

**WRONG:**
> "I ran the tests and they passed. The code is ready."

**RIGHT:**
> "Test results from `pnpm test`:
> ```
> Test Files  12 passed (12)
> Tests       87 passed (87)
> Duration    4.23s
> ```
> Exit code: 0"

### 7. Design System Check (Advisory)

If staged files include `components/` or `*.tsx`:
- Suggest: "UI changes detected. Consider running `/design-audit` for design system compliance."
- This is **advisory, not blocking** - design issues don't prevent commit
- For thorough design review, run `/design-audit [file]` separately

## Branch Creation

If not already on feature branch:
- Get branch name from Linear issue using `mcp__linear-server__get_issue`
- Use the `branchName` field from the issue (Linear generates this automatically)
- Example: `git checkout -b {username}/bri-{issue_id}-{description}`
- If no Linear issue, fall back to manual branch naming: `{username}/bri-{issue_id}-{description}`

## Output

Report card:
- ✅/❌ Debug logging removed
- ✅/❌ Tests added (X% coverage)
- ✅/❌ File sizes OK
- ✅/❌ Docs updated (if needed)
- ✅/❌ Lint passed
- ✅/❌ Typecheck passed
- ✅/❌ Build succeeded
- ✅/❌ No hardcoded secrets
- ✅/❌ No commented-out auth
- ✅/❌ No sensitive data logging
- 💡 Design audit suggested (if UI changes)

**CRITICAL**: After ALL checks pass, proceed to commit and push.

**When user runs /prep, they are giving approval to commit/push if all checks pass.**
This is the ONE exception to the "require approval for git commit/push" rule.

1. Create commit with descriptive message referencing BRI-XXX
2. Push to remote branch
3. Report: "Committed and pushed to [branch-name]"

**For Cursor users**: In composer mode, show full diff summary before commit.
