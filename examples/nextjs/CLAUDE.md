# Brief AI Agent Setup - Next.js Example

## Quick Start

- Run `/onboard` to load Brief context and report readiness
- Run `/onboard BRI-XXX` for specific Linear task with auto-generated todos
- All agents have access to Brief MCP for business context

## Context Loading Order

When `/onboard [BRI-XXX]` runs, context is loaded in this order:

### 1. Brief MCP (mcp__brief__brief_get_onboarding_context)
- **Product**: customers, service definition, competitive advantages
- **Personas**: top user types with needs and pain points
- **Strategic context**: 6-month goal, top metrics
- **Current work**: building, committed items
- **Velocity & team**: release frequency, decision speed, technical sophistication
- **Recent decisions**: last 10 architectural/business decisions
- **Customer insights**: themes, sentiment

### 2. Linear Task Context (if BRI-XXX provided)
- **Issue**: title, description, acceptance criteria
- **Relations**: blocks, blocked by, related issues
- **Linked Brief documents** (if any)
- **Project context**

### 3. Repository Rules
- Hard rules (never commit --amend, etc.)
- Code conventions
- Testing requirements

### 4. Domain Skills (.claude/skills/)
- **brief-patterns**: API routes, database, components
- **testing-strategy**: Coverage requirements
- **decision-guard**: Check approaches against Brief decisions
- **security-patterns**: Auth, RLS, validation

### 5. Codebase Structure
- File organization
- Existing patterns
- Dependencies and relationships

## Hard Rules

### Blocked Operations

**Git History Modification (Destructive)**
- ❌ `git commit --amend` - Rewrites commit history
- ❌ `git push --force` / `git push -f` - Overwrites remote history
- ❌ `git rebase` - Rewrites commit history
- ❌ `git reset` (any form) - Moves HEAD, can lose commits

**Git Work Destruction**
- ❌ `git checkout --ours` / `git checkout --theirs` - Discards conflict options
- ❌ `git checkout .` - Discards all unstaged changes
- ❌ `git clean -f` / `git clean -fd` - Deletes untracked files

**Git Branch Operations**
- ❌ `git push` to main/master/production directly - Use PRs
- ❌ `git branch -D` - Force deletes regardless of merge status

**Database Operations**
- ❌ `drizzle-kit drop` - Drops migrations
- ❌ `drizzle-kit push --force` - Force pushes schema

**Required Behaviors**
- ✅ **ALWAYS**: Run lint, test, typecheck, build before commit/push
- ✅ **ALWAYS**: Use Brief MCP for context before architectural decisions
- ✅ **ALWAYS**: Check Brief decisions with guard_approach before changes
- ❌ **NEVER**: commit/push without explicit approval (EXCEPTION: /prep)

## Architecture Overview

**MyNextJSApp** uses the following stack:

- **Frontend**: Next.js 14 (App Router), React 18, TailwindCSS, shadcn/ui
- **Backend**: Next.js API routes (app/api/)
- **Database**: PostgreSQL via Supabase
- **ORM**: Drizzle ORM
- **Auth**: Clerk (sessions + API keys)
- **Build System**: Turborepo with pnpm workspaces
- **Deployment**: Vercel

### Commands

```bash
pnpm dev          # Start dev server at localhost:3000
pnpm build        # Build for production
pnpm test         # Run tests with Vitest
pnpm lint         # Run ESLint
pnpm typecheck    # Run TypeScript type checking
```

## Code Conventions

### API Routes

Location: `app/api/v1/[resource]/route.ts`

```typescript
import { z } from 'zod';
import { auth } from '@clerk/nextjs/server';
import { db } from '@/lib/db';
import { NextResponse } from 'next/server';

const InputSchema = z.object({
  title: z.string().min(1),
  content: z.string().optional(),
});

export async function POST(req: Request) {
  const { userId, orgId } = await auth();
  if (!userId || !orgId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const body = InputSchema.parse(await req.json());

  const result = await db.insert(documents).values({
    ...body,
    orgId,
    createdBy: userId,
  });

  return NextResponse.json(result);
}
```

### Database

- **ORM**: Drizzle ORM via `lib/db/`
- **Migrations**: `drizzle-kit generate` (never hand-write SQL)
- **RLS**: Enforced via Supabase, always filter by orgId
- **Schema**: `lib/db/schema.ts`

### Testing

- **Framework**: Vitest
- **Coverage**: 80% minimum for new code
- **Mocking**: Mock Supabase client, Clerk auth
- **Location**: `__tests__/` or `*.test.ts` files

### Components

- **UI Library**: shadcn/ui (`components/ui/`)
- **Custom**: `components/[feature]/`
- **Styling**: TailwindCSS utilities
- **Icons**: Lucide React

### File Organization

```
app/
  api/v1/[resource]/route.ts  # API routes
  (authenticated)/            # Protected pages
  (public)/                   # Public pages
components/
  ui/                         # shadcn/ui components
  [feature]/                  # Feature-specific components
lib/
  db/                         # Database (Drizzle)
  utils/                      # Utilities
hooks/
  use-[resource].ts          # React hooks
types/
  [domain].ts                # TypeScript types
```

## Agent Capabilities

### context-loader
Brief + Linear + codebase discovery. Loads all context layers.

### task-planner
Implementation planning with Brief context. Uses guard_approach.

### implementation
Autonomous coding with permission gates. Follows patterns, writes tests.

### pr-preparer
Pre-commit validation. Full checklist.

### code-explorer
Codebase navigation. Answers "where is X?" efficiently.

## Brief MCP Integration

- **Product context**: Auto-loaded on /onboard
- **Recent decisions**: Checked via guard_approach
- **Active work**: Synced from Linear
- **Decision conflicts**: Validated before architectural changes

## Workflow Commands

- `/onboard` - Load context and prepare
- `/onboard BRI-XXX` - Load specific Linear task
- `/todo-all` - Execute all pending todos
- `/prep` - Validate and commit/push
- `/health` - Check environment

## Platform Support

Works with both Claude Code and Cursor via shared skills and commands.
