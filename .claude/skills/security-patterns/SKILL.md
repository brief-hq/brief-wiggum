---
description: Brief-specific security patterns and guidelines
---

# Security Patterns

> **Compliance Target**: Brief targets HIPAA and SOC-2 compliance. These patterns help maintain that posture. When in doubt, err on the side of more security.

## Authentication (Clerk Integration)

Brief uses Clerk for authentication. Follow these rules:

- **Always** use `getAuth()` or `currentUser()` from `@clerk/nextjs/server`
- **Never** trust client-provided user IDs
- **Check** `auth.userId` on every API route before processing

```typescript
import { auth } from '@clerk/nextjs/server';

export async function GET(req: Request) {
  const session = await auth();

  // Always check authentication first
  if (!session.userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  // Use session.userId, never client-provided user ID
  const data = await fetchDataForUser(session.userId);
}
```

**Common mistakes to avoid:**
```typescript
// BAD - trusting client-provided user ID
const { userId } = await req.json();
const data = await fetchDataForUser(userId);

// GOOD - using authenticated session
const session = await auth();
const data = await fetchDataForUser(session.userId);
```

## API Key Authentication

For machine-to-machine API access, Brief uses API keys:

- Use `verifyApiKey()` from `lib/auth/api-key`
- API keys authenticate **organizations**, not users
- Always verify `organizationId` matches the resource being accessed

```typescript
import { verifyApiKey } from '@/lib/auth/api-key';

export async function POST(req: Request) {
  const apiKeyAuth = await verifyApiKey(req);

  if (!apiKeyAuth.valid) {
    return NextResponse.json({ error: 'Invalid API key' }, { status: 401 });
  }

  // API key provides organizationId, not userId
  const { organizationId } = apiKeyAuth;

  // Verify resource belongs to this organization
  const document = await getDocument(documentId);
  if (document.organization_id !== organizationId) {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
  }
}
```

## v1 API Routes (withV1Auth Middleware)

All v1 API routes MUST use the `withV1Auth` middleware:

```typescript
import { withV1Auth, V1_ERRORS } from '@/app/api/v1/_middleware';

export const POST = withV1Auth(async (req, context) => {
  // context provides: userId, orgId, type (session/api_key)
  const { userId, orgId, type } = context;

  // Use V1_ERRORS for standardized responses
  if (!orgId) {
    return V1_ERRORS.BAD_REQUEST('Organization required');
  }

  // Proceed with authenticated request
});
```

## Database Security (RLS)

Brief uses Supabase with Row Level Security (RLS):

- **Every table** has RLS policies enabled
- **Always** filter by `organization_id` in queries
- **Never** bypass RLS in application code
- **Test** that users cannot access other organizations' data

```typescript
// GOOD - RLS handles org filtering automatically via Supabase client
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

### Testing RLS

Write tests that verify users cannot access other orgs' data:

```typescript
it('returns 403 when accessing another org document', async () => {
  mockAuth({ userId: 'user-1', orgId: 'org-1' });

  // Document belongs to org-2
  const res = await GET(req, { params: { id: 'doc-in-org-2' } });

  expect(res.status).toBe(403);
});
```

## Input Validation (Zod)

Every API endpoint MUST validate input with Zod:

- **Never** trust client input
- Use `.strict()` to reject unknown fields
- **Sanitize** before storing in database

```typescript
import { z } from 'zod';

// Define schema with strict validation
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

  // Parse and validate input
  const parseResult = createDocumentSchema.safeParse(await req.json());

  if (!parseResult.success) {
    return NextResponse.json(
      { error: 'Validation failed', details: parseResult.error.issues },
      { status: 400 }
    );
  }

  const { title, content, folder_id } = parseResult.data;
  // Now safe to use validated data
}
```

**Common validation patterns:**
```typescript
// Email validation
z.string().email()

// UUID validation
z.string().uuid()

// Enum validation
z.enum(['draft', 'published', 'archived'])

// Array with max length
z.array(z.string()).max(100)

// Optional with default
z.string().optional().default('')

// Transform and sanitize
z.string().trim().toLowerCase()
```

## Secrets Management

### What Counts as a Secret

- API keys (Clerk, Anthropic, Linear, Slack, GitHub)
- Database URLs and credentials
- JWT signing keys
- OAuth client secrets
- Webhook signing secrets
- Encryption keys

### Rules

- **Never** commit secrets to git
- **Never** log secrets (even in development)
- **Never** include secrets in error messages
- Use `.env.local` for local development
- Use Render environment variables for production

```bash
# .env.local (never committed)
CLERK_SECRET_KEY=sk_test_...
ANTHROPIC_API_KEY=sk-ant-...
DATABASE_URL=postgres://...
```

### Checking for Secrets

Before committing, verify no secrets are exposed:
```bash
# Check for potential secrets in staged files
git diff --cached | grep -iE "(api_key|secret|password|token|credential)"
```

## Common Vulnerabilities

### XSS (Cross-Site Scripting)

React escapes content by default. Avoid bypassing this:

```typescript
// BAD - potential XSS
<div dangerouslySetInnerHTML={{ __html: userContent }} />

// GOOD - React auto-escapes
<div>{userContent}</div>

// If HTML is required, sanitize first
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userContent) }} />
```

### CSRF (Cross-Site Request Forgery)

Next.js API routes check origin by default. Additional protections:

- Use `SameSite=Lax` or `SameSite=Strict` cookies (Clerk handles this)
- Verify `Origin` or `Referer` headers for sensitive operations
- Use CSRF tokens for form submissions if needed

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

## Security Checklist

Before merging any PR:

- [ ] Authentication checked on all API routes
- [ ] Authorization verified (user can access resource)
- [ ] Input validated with Zod
- [ ] No secrets in code or logs
- [ ] RLS filters applied to database queries
- [ ] Error messages don't leak sensitive info
- [ ] Tests verify unauthorized access is blocked
