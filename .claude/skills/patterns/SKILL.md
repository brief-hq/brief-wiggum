---
description: Brief-specific code patterns, security requirements, and decision validation. Covers API routes, database, components, auth, RLS, and guard_approach.
---

# Brief Patterns & Security

This skill consolidates Brief's code conventions, security requirements (HIPAA/SOC-2), and architectural decision validation.

## API Route Pattern

Every API route must:
- Use Zod for request validation
- Check authentication via `authenticateApiKey()` or `auth()` from Clerk
- Return standardized error responses
- Log errors properly via `lib/logger`

```typescript
import { z } from 'zod';
import { authenticateApiKey } from '@/lib/api/auth';
import { auth } from '@clerk/nextjs/server';
import { NextResponse } from 'next/server';

const schema = z.object({ /* ... */ });

export async function POST(req: Request) {
  // API key auth
  const apiAuth = await authenticateApiKey();
  if (!apiAuth.ok) {
    return NextResponse.json({ error: apiAuth.error }, { status: 401 });
  }

  // OR session auth
  const session = await auth();
  if (!session.userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const body = schema.parse(await req.json());
  // ...
}
```

### v1 API Routes (withV1Auth Middleware)

All v1 API routes MUST use the `withV1Auth` middleware:

```typescript
import { withV1Auth, V1_ERRORS } from '@/app/api/v1/_middleware';

export const POST = withV1Auth(async (req, context) => {
  const { userId, orgId, type } = context;

  if (!orgId) {
    return V1_ERRORS.BAD_REQUEST('Organization required');
  }
  // Proceed with authenticated request
});
```

---

## Brief MCP Integration

- `folder_id` is REQUIRED for `create_document` (no default)
- ALWAYS call `get_folder_tree` first to find valid folder IDs
- Documents use soft delete (go to trash, recoverable)
- ASK before `delete_document`, `delete_folder`, `bulk_delete`

---

## Database Patterns

### Drizzle ORM + RLS

- Use `createAdminClient()` from `@/lib/supabase/admin` for server-side queries
- RLS is enforced on all tables via Supabase
- NEVER bypass RLS in application code
- Always filter by `org_id` in queries

```typescript
// GOOD - RLS handles org filtering automatically
const { data } = await supabase
  .from('documents')
  .select('*')
  .eq('organization_id', orgId);

// GOOD - Drizzle with explicit org filter
const documents = await db.query.documents.findMany({
  where: eq(documents.organization_id, orgId),
});

// BAD - no org filter (potential data leak)
const { data } = await supabase
  .from('documents')
  .select('*');
```

### Database Migrations (CRITICAL)

**⚠️ NEVER hand-write migration SQL files. ALWAYS use drizzle-kit generate.**

```bash
# 1. Edit schema.ts with your changes
vim lib/db/drizzle/schema.ts

# 2. Generate migration (REQUIRED - never skip this)
DRIZZLE_DATABASE_URL="postgresql://postgres:postgres@127.0.0.1:54322/postgres" pnpm db:drizzle:generate

# 3. For non-schema objects (functions, triggers, extensions):
DRIZZLE_DATABASE_URL="..." pnpm db:drizzle:generate --custom --name=my-functions

# 4. Review the generated SQL, then apply locally
DRIZZLE_DATABASE_URL="..." pnpm db:drizzle:migrate
```

**Migration Types:**

| Type | Use For | Command |
|------|---------|---------|
| Generated | Columns, tables, indexes, constraints | `pnpm db:drizzle:generate` |
| Custom | Functions, triggers, extensions, data migrations | `pnpm db:drizzle:generate --custom --name=description` |

---

## Authentication (Clerk Integration)

> **Compliance Target**: Brief targets HIPAA and SOC-2 compliance.

- **Always** use `getAuth()` or `currentUser()` from `@clerk/nextjs/server`
- **Never** trust client-provided user IDs
- **Check** `auth.userId` on every API route before processing

```typescript
import { auth } from '@clerk/nextjs/server';

export async function GET(req: Request) {
  const session = await auth();

  if (!session.userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  // Use session.userId, never client-provided user ID
  const data = await fetchDataForUser(session.userId);
}
```

**Common mistake:**
```typescript
// BAD - trusting client-provided user ID
const { userId } = await req.json();
const data = await fetchDataForUser(userId);

// GOOD - using authenticated session
const session = await auth();
const data = await fetchDataForUser(session.userId);
```

### API Key Authentication

For machine-to-machine API access:

- Use `verifyApiKey()` from `lib/auth/api-key`
- API keys authenticate **organizations**, not users
- Always verify `organizationId` matches the resource being accessed

---

## Input Validation (Zod)

Every API endpoint MUST validate input with Zod:

```typescript
import { z } from 'zod';

const createDocumentSchema = z.object({
  title: z.string().min(1).max(255),
  content: z.string().optional(),
  folder_id: z.string().uuid(),
}).strict(); // Reject unknown fields

export async function POST(req: Request) {
  const session = await auth();
  if (!session.userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const parseResult = createDocumentSchema.safeParse(await req.json());

  if (!parseResult.success) {
    return NextResponse.json(
      { error: 'Validation failed', details: parseResult.error.issues },
      { status: 400 }
    );
  }

  const { title, content, folder_id } = parseResult.data;
}
```

**Common validation patterns:**
```typescript
z.string().email()           // Email
z.string().uuid()            // UUID
z.enum(['draft', 'published', 'archived'])  // Enum
z.array(z.string()).max(100) // Array with max length
z.string().optional().default('')  // Optional with default
z.string().trim().toLowerCase()    // Transform and sanitize
```

---

## Common Vulnerabilities

### XSS (Cross-Site Scripting)

```typescript
// BAD - potential XSS
<div dangerouslySetInnerHTML={{ __html: userContent }} />

// GOOD - React auto-escapes
<div>{userContent}</div>

// If HTML required, sanitize first
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userContent) }} />
```

### IDOR (Insecure Direct Object Reference)

Always verify resource ownership:

```typescript
export async function GET(req: Request, { params }: { params: { id: string } }) {
  const session = await auth();
  if (!session.userId || !session.orgId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const document = await getDocument(params.id);

  // Always verify resource belongs to user's organization
  if (document.organization_id !== session.orgId) {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
  }

  return NextResponse.json(document);
}
```

### Secrets Management

- **Never** commit secrets to git
- **Never** log secrets (even in development)
- **Never** include secrets in error messages
- Use `.env.local` for local development
- Use Render environment variables for production

---

## Decision Guard

Automatically checks proposed approaches against existing architectural and business decisions.

### Usage Pattern

Before implementing significant changes:

```typescript
mcp__brief__brief_execute_operation({
  operation: "guard_approach",
  parameters: {
    approach: "Refactor authentication to use OAuth2 instead of API keys"
  }
})
```

Returns:
- ✅ **Proceed**: No conflicts with existing decisions
- ⚠️ **Review**: Potential conflicts with D-123, D-456
- ❌ **Blocked**: Direct conflict with D-789

### When to Use guard_approach

Call before:
- Architectural changes (auth, database, API design)
- Dependency changes (switching libraries)
- Breaking changes to public APIs
- Changes to core workflows

### Example Workflow

```text
User: "Refactor auth to use OAuth2"

Agent:
1. Calls guard_approach("Switch from API keys to OAuth2 for authentication")
2. Response: "⚠️ Conflicts with D-234: Keep API keys for MCP server compatibility"
3. Asks user: "Existing decision D-234 requires API keys for MCP. Proceed anyway?"
4. User decides: proceed, modify approach, or cancel
```

---

## Component Reuse & Design System

> **Deep Dive**: For typography, colors, motion, and anti-patterns, see the `brief-design` skill.

### TailStack Components (`@/components/ui/*`)

- Button, Input, Card, Dialog, Select, Textarea, etc.
- ALWAYS use these over custom implementations
- Extend via composition, not duplication

```typescript
// GOOD - Compose from design system
import { Button } from '@/components/ui/button';

export function SubmitButton({ children, ...props }) {
  return (
    <Button variant="primary" size="lg" {...props}>
      {children}
    </Button>
  );
}

// BAD - Create custom button
export function MyButton() {
  return <button className="px-4 py-2 bg-blue-500">Submit</button>;
}
```

### Component Organization

- `chat-ui/` - Shared components (web app + Chrome extension)
- `components/` - Web-specific components
- `chrome-extension/` - Extension-specific components

**Before creating a component**: Search existing components first. Reuse or compose when possible.

---

## File Organization

- API routes: `app/api/v1/[resource]/route.ts`
- Hooks: `hooks/use-[resource].ts`
- Shared components: `chat-ui/` (web + extension)
- Web components: `components/[feature]/[component].tsx`
- Utilities: `lib/[utility].ts`
- Types: `types/[domain].ts`

---

## Security Checklist

Before merging any PR:

- [ ] Authentication checked on all API routes
- [ ] Authorization verified (user can access resource)
- [ ] Input validated with Zod
- [ ] No secrets in code or logs
- [ ] RLS filters applied to database queries
- [ ] Error messages don't leak sensitive info
- [ ] Tests verify unauthorized access is blocked
- [ ] `guard_approach` called for architectural changes
