# Customization Guide

Adapt Brief Wiggum for your specific project and stack.

## Customizing CLAUDE.md

The most important customization is the `CLAUDE.md` file. Start from the template:

```bash
cp CLAUDE.md.template CLAUDE.md
```

### Architecture Section

Replace the placeholders:

```markdown
## Architecture Overview

**MyProject** uses the following stack:

- **Frontend**: Next.js 14, React 18, TailwindCSS
- **Backend**: Next.js API routes
- **Database**: PostgreSQL via Supabase
- **ORM**: Drizzle ORM
- **Auth**: Clerk
- **Build System**: Turborepo
- **Deployment**: Vercel

### Commands

```bash
pnpm dev          # Start dev server
pnpm build        # Build the project
pnpm test         # Run tests
pnpm lint         # Lint code
pnpm typecheck    # Typecheck
```
```

### Code Conventions Section

Document your patterns:

```markdown
## Code Conventions

### API Routes
- Location: app/api/v1/[resource]/route.ts
- Validation: Zod
- Auth: withAuth middleware
- Errors: NextResponse.json with status codes

### Database
- ORM: Drizzle
- Migrations: drizzle-kit generate
- Always filter by orgId

### Testing
- Framework: Vitest
- Coverage: 80% for new code
- Mock: Supabase client, Clerk auth
```

## Adding Custom Skills

Create a new skill when you find yourself repeatedly explaining a pattern.

### Skill Structure

```
.claude/skills/
  my-skill/
    SKILL.md
```

### SKILL.md Format

```markdown
---
description: Use when [specific situation]
---

# My Skill Name

## When to Apply

- Trigger 1
- Trigger 2

## The Pattern

Step-by-step instructions with code examples.

## Integration with Brief

How this connects to Brief MCP, decisions, etc.

## Common Mistakes

What to avoid.

## Verification

How to confirm correct application.
```

### Example: Custom API Pattern

```markdown
---
description: Use when creating API routes in our project
---

# Our API Patterns

## When to Apply

- Creating new API routes
- Modifying existing endpoints
- Adding validation

## The Pattern

1. Create route file: `app/api/v1/[resource]/route.ts`

2. Use this structure:

```typescript
import { z } from 'zod';
import { withAuth, AuthContext } from '@/lib/auth';
import { db } from '@/lib/db';

const inputSchema = z.object({
  // ...
});

export const POST = withAuth(async (req, ctx: AuthContext) => {
  const body = inputSchema.parse(await req.json());
  // ...
});
```

3. Add tests in `__tests__/api/v1/[resource].test.ts`

## Common Mistakes

- Forgetting withAuth wrapper
- Not validating input with Zod
- Direct database access without orgId filter
```

## Customizing Commands

### Adding a New Command

Create `.claude/commands/my-command.md`:

```markdown
---
description: What this command does
---

# /my-command

Description of what happens when you run this command.

## Steps

1. First action
2. Second action
3. Third action

## Tools Used

- Tool1
- Tool2

## Output

What the command reports when done.
```

### Modifying Existing Commands

Edit the command files in `.claude/commands/`:

- `onboard.md` - Change how context is loaded
- `prep.md` - Add/remove validation checks
- `health.md` - Add custom health checks

## Customizing Git Guards

### Adding New Patterns

Edit `.claude/hooks/git-guard.sh`:

```bash
# Add a new pattern section
# ============================================================
# PATTERN 12: Your new pattern
# ============================================================
if [[ "$COMMAND" =~ your-pattern ]]; then
  block "Why this is blocked" \
        "What to do instead"
fi
```

### Also Update Settings

Add to `.claude/settings.json` deny list:

```json
{
  "permissions": {
    "deny": [
      "Bash(your-command:*)"
    ]
  }
}
```

## Verification Commands

If your project uses different commands for verification:

### 1. Update verify-complete.sh

```bash
# In run_verification()
case $VERIFY_TYPE in
  tests)
    # Change from pnpm to your command
    if ! npm test >/dev/null 2>&1; then
      result="fail"
    fi
    ;;
  # ...
esac
```

### 2. Update ralph-prompts.sh

```bash
# In build_first_iteration_prompt()
case $verify_type in
  tests) verify_criteria="npm test";;
  lint) verify_criteria="npm run lint";;
  # ...
esac
```

### 3. Update prep.md

Change the verification commands in the checklist.

## Build System Variations

### For pnpm (default)

Works out of the box.

### For npm

Update all pnpm references:
- `.claude/settings.json` allow list
- `verify-complete.sh`
- `ralph-prompts.sh`
- `prep.md`

### For yarn

Same as npm, but with yarn commands.

### For Python projects

Major changes needed:
- Replace npm/pnpm with pip/poetry
- Update test commands (pytest, etc.)
- Update lint commands (ruff, black, etc.)
- Create Python-specific skills

See `examples/python-fastapi/` for a complete example.

## Extending for Monorepos

If using Turborepo or nx:

### Update Commands

```bash
pnpm build        # Runs turbo build
pnpm test         # Runs turbo test
pnpm --filter=web dev  # Run specific package
```

### Add Package-Specific Skills

```
.claude/skills/
  web-patterns/SKILL.md      # Web app patterns
  extension-patterns/SKILL.md # Chrome extension patterns
  shared-patterns/SKILL.md    # Shared code patterns
```

### Update File Paths

In skills and commands, reference the correct paths:
- `packages/web/src/` vs `web/`
- `apps/api/` vs `api/`

## Integration with CI/CD

### GitHub Actions

Add verification to CI:

```yaml
- name: Verify Brief Wiggum Setup
  run: |
    ./.claude/scripts/setup.sh
    # Optionally run Ralph loop on PRs
    # ./.claude/scripts/ralph.sh --verify-only all --max-iterations 1 "Verify code"
```

### Pre-commit Integration

Use Husky hooks (already configured):

```bash
# .husky/pre-commit
npx lint-staged
pnpm typecheck
```

## Tips

1. **Start minimal**: Only add customizations you need
2. **Document decisions**: Use Brief to record why patterns exist
3. **Test changes**: Run `/health` after modifying settings
4. **Share with team**: Keep CLAUDE.md in git so everyone uses the same patterns
