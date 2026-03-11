---
description: Focused code quality cleanup session with duplication, dead code, and complexity analysis
---

# /refactor

Focused code quality cleanup session. Run after large features or when Claude is making repeated mistakes due to code complexity.

> **Philosophy**: Refactoring is a distinct phase, not continuous. Doing it constantly kills momentum. Budget ~20% of dev time for focused cleanup sessions.

## When to Use

- After completing a large feature
- When Claude keeps making mistakes in a module
- Before starting work on a complex area
- When you feel "code smell" pain

## Tools

### 1. Code Duplication (jscpd)

Finds copy-pasted code blocks that should be extracted.

```bash
# Install if needed
pnpm add -D jscpd

# Run detection (adjust paths to your project structure)
npx jscpd ./src --min-lines 5 --min-tokens 50 --reporters console
```

**Output shows:**
- Duplicate blocks with file locations
- Percentage of duplicated code
- Specific line ranges to consolidate

### 2. Dead Code (knip)

Finds unused exports, dependencies, and files.

```bash
# Install if needed
pnpm add -D knip

# Run detection
npx knip
```

**Output shows:**
- Unused files (safe to delete)
- Unused exports (remove or they'll confuse future work)
- Unused dependencies (bloat)
- Unlisted dependencies (missing from package.json)

### 3. Complexity Analysis

Find overly complex functions:

```bash
# Files over 300 lines (candidates for splitting)
find src -name "*.ts" -o -name "*.tsx" | xargs wc -l | sort -rn | head -20

# Functions with high cyclomatic complexity (many branches)
grep -rn "if\|else\|switch\|?" --include="*.ts" --include="*.tsx" src/ | cut -d: -f1 | sort | uniq -c | sort -rn | head -20
```

## Workflow

### Phase 1: Assess

Run all three tools and create a hit list:

```markdown
## Refactor Targets

### Duplicates (jscpd)
- [ ] [file_a]:45-67 duplicates [file_b]:32-54
- [ ] [shared_logic]:12-30 duplicates 3 places

### Dead Code (knip)
- [ ] [unused_file] (unused file)
- [ ] [component]:exportedButNeverUsed

### Complexity
- [ ] [large_file] (450 lines - split)
```

### Phase 2: Fix

For each item:

1. **Duplicates** - Extract to shared utility
2. **Dead code** - Delete entirely (don't comment out)
3. **Complex files** - Split into focused modules

**Check approach for significant changes:**
```bash
brief ask --mode check "We plan to [describe refactor approach]"
```

**Run tests after each change:**
```bash
pnpm test
```

### Phase 3: Verify

```bash
# Re-run tools to confirm fixes
npx jscpd ./src --min-lines 5 --min-tokens 50
npx knip

# Full validation
pnpm lint && pnpm typecheck && pnpm test
```

### Phase 4: Commit

Single atomic commit for the refactor:

```bash
git add -A
git commit -m "refactor: code quality cleanup

- [list specific changes]

No functional changes."
```

## Anti-Patterns to Fix

| Pattern | Problem | Fix |
|---------|---------|-----|
| Copy-pasted handlers | Changes need N updates | Extract to shared handler |
| Unused exports | Confuses tooling and humans | Delete them |
| God files (500+ lines) | Hard to navigate, test | Split by responsibility |
| Commented-out code | Noise, never gets deleted | Delete (git has history) |
| `any` types | Defeats TypeScript | Add proper types |
| `@ts-ignore` | Hides real issues | Fix the underlying problem |

## Code Quality Checks

```bash
# Find any types
grep -rn ": any" --include="*.ts" --include="*.tsx" src/ | grep -v node_modules

# Find ts-ignore
grep -rn "@ts-ignore\|@ts-expect-error" --include="*.ts" --include="*.tsx" src/
```

## Output

```
## Refactor Complete

### Fixed
- [list of changes made]

### Metrics
- Duplication: X% -> Y%
- Unused exports: X -> Y
- Files over 300 lines: X -> Y

### Verification
- Tests: N passed
- Lint: 0 errors
- Typecheck: 0 errors
```
