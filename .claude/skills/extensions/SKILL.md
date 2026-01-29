---
description: Chrome extension and MCP tool development patterns. Covers Side Panel architecture, OAuth, shared components, and MCP tool structure.
---

# Extension & MCP Development

This skill covers Chrome extension development patterns and MCP tool development for Brief.

## Chrome Extension Architecture

Brief's Chrome extension provides AI chat directly in the browser using **Side Panel** architecture.

### Key Components

- **Manifest V3**: Modern Chrome extension format
- **Side Panel**: Chrome's native side panel API (not content scripts)
- **OAuth Authentication**: `chrome.identity.launchWebAuthFlow` with PKCE
- **Shared Business Logic**: Imports from `@briefhq/chat-ui` package
- **Context Awareness**: Tracks active tab URL for contextual assistance

### Side Panel Setup

Brief uses Chrome's Side Panel API, **NOT content script injection**:

```typescript
// sidepanel.tsx - Main entry point
export default function SidePanel() {
  const [accessToken, setAccessToken] = useState<string | null>(null);
  const [contextUrl, setContextUrl] = useState<string | undefined>();

  useEffect(() => {
    const token = await getValidAccessToken();
    setAccessToken(token);
  }, []);

  useEffect(() => {
    chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
      setContextUrl(tabs[0]?.url);
    });

    chrome.tabs.onActivated.addListener(handleTabChange);
    chrome.tabs.onUpdated.addListener(handleUrlChange);
  }, []);

  return <ChatInterface accessToken={accessToken} contextUrl={contextUrl} />;
}
```

**Manifest Configuration:**
```json
{
  "manifest_version": 3,
  "permissions": ["sidePanel", "activeTab", "storage", "tabs", "identity"],
  "side_panel": {
    "default_path": "sidepanel.html"
  }
}
```

---

## Shared Code from @briefhq/chat-ui

The extension reuses business logic from the `@briefhq/chat-ui` package (monorepo sibling).

### Shared Hooks

| Hook | Purpose |
|------|---------|
| `useChatTransport` | Manages streaming, messages, conversation state |
| `useConversationHistory` | Load/save/delete conversations |
| `usePresets` | Fetch and select chat presets |
| `useContextStatus` | Track token usage in context window |
| `useMessageFeedback` | Submit thumbs up/down to Helicone |
| `useFileAttachments` | File selection, validation, removal |
| `useMentions` | Document search and @-mention selection |

### Shared UI Components

| Component | Purpose |
|-----------|---------|
| `Conversation`, `ConversationContent` | Scroll container |
| `Message`, `MessageContent` | Message bubbles |
| `Response` | Markdown rendering |
| `Tool`, `ToolHeader`, `ToolContent` | Tool call display |
| `Reasoning`, `ReasoningTrigger` | Extended thinking UI |

### Import Pattern

```typescript
// ✅ GOOD - Import from @briefhq/chat-ui
import {
  useChatTransport,
  useConversationHistory,
  Conversation,
  Message,
  Response,
} from "@briefhq/chat-ui";

// ❌ BAD - Don't recreate what exists in @briefhq/chat-ui
export function ChatInterface() {
  const [messages, setMessages] = useState([]);  // Use hook instead
}
```

---

## When to Create Extension-Specific Components

Create components in `packages/chrome-extension/components/` ONLY when:

1. **Chrome API Integration**: Component uses `chrome.tabs`, `chrome.storage`, `chrome.identity`
2. **Extension-Specific UI**: Component is unique to side panel context
3. **Extension-Specific Configuration**: Wrapper needed for extension constraints

---

## OAuth Authentication

Brief uses **chrome.identity API** with PKCE for OAuth 2.0:

```typescript
// lib/oauth.ts
export async function startOAuthFlow() {
  const codeVerifier = generateCodeVerifier();
  const codeChallenge = await generateCodeChallenge(codeVerifier);

  const redirectUrl = chrome.identity.getRedirectURL();
  const authUrl = `${BRIEF_URL}/oauth/authorize?` +
    `client_id=${CLIENT_ID}&` +
    `redirect_uri=${redirectUrl}&` +
    `response_type=code&` +
    `code_challenge=${codeChallenge}&` +
    `code_challenge_method=S256`;

  const responseUrl = await chrome.identity.launchWebAuthFlow({
    url: authUrl,
    interactive: true,
  });

  const code = extractCodeFromUrl(responseUrl);
  const tokens = await exchangeCodeForTokens(code, codeVerifier);

  await chrome.storage.local.set({
    access_token: tokens.access_token,
    refresh_token: tokens.refresh_token,
    expires_at: Date.now() + tokens.expires_in * 1000,
  });

  return tokens;
}

export async function getValidAccessToken(): Promise<string | null> {
  const { access_token, expires_at, refresh_token } =
    await chrome.storage.local.get(["access_token", "expires_at", "refresh_token"]);

  if (!access_token) return null;

  if (Date.now() >= expires_at - 60000) {
    return await refreshAccessToken(refresh_token);
  }

  return access_token;
}
```

---

## Extension Component Organization

```text
packages/chrome-extension/
├── sidepanel.tsx          # Main entry (auth + ChatInterface)
├── background.ts          # Service worker (keyboard shortcuts)
├── lib/
│   ├── oauth.ts           # OAuth 2.0 with PKCE
│   └── utils.ts           # Utility functions
├── components/chat/
│   ├── ChatInterface.tsx  # Main orchestrator
│   ├── hooks/
│   │   └── use-extension-api.ts  # Extension-specific API wrapper
│   └── views/             # Extension-specific UI
└── __tests__/             # Vitest unit tests
```

**Rule:** Extension components ONLY in `components/chat/`. Shared components come from `@briefhq/chat-ui`.

---

## Development Workflow

### Local Setup

```bash
cd packages/chrome-extension
pnpm install
cp .env.dev.example .env.dev
pnpm run dev  # Hot reload
```

### Load Extension in Chrome

1. Open `chrome://extensions/`
2. Enable "Developer mode"
3. Click "Load unpacked"
4. Select `packages/chrome-extension/build/chrome-mv3-dev`

### Build Environments

| Environment | Command | Target |
|-------------|---------|--------|
| Dev | `pnpm run build` | localhost:3000 |
| Staging | `pnpm run build:staging` | staging.briefhq.ai |
| Production | `pnpm run build:production` | app.briefhq.ai |

---

## Extension Testing

```typescript
import { describe, it, expect, vi } from "vitest";
import { render } from "@testing-library/react";
import { ChatInterface } from "./ChatInterface";

// Mock Chrome APIs
vi.mock("chrome", () => ({
  tabs: {
    query: vi.fn(),
    onActivated: { addListener: vi.fn(), removeListener: vi.fn() },
  },
  storage: {
    local: { get: vi.fn(), set: vi.fn() },
  },
}));

describe("ChatInterface", () => {
  it("renders chat UI when authenticated", () => {
    const { getByRole } = render(
      <ChatInterface accessToken="test-token" contextUrl="https://example.com" />
    );
    expect(getByRole("textbox")).toBeInTheDocument();
  });
});
```

---

## Key Differences: Web App vs Extension

| Feature | Web App | Extension |
|---------|---------|-----------|
| **Architecture** | Next.js pages | Side Panel |
| **Authentication** | Clerk session cookies | OAuth Bearer tokens |
| **API URL** | Relative (`/api/...`) | Absolute (`https://app.briefhq.ai/api/...`) |
| **Context** | Current page (server-side) | Active tab URL (chrome.tabs API) |
| **Storage** | Supabase + Clerk | chrome.storage.local |

---

## MCP Tool Development

### Adding New MCP Tools

1. **Define tool** in `mcp-server/src/tools/[domain]/[tool-name].ts`
2. **Add to registry** in `mcp-server/src/tools/index.ts`
3. **Update types** in `mcp-server/src/types.ts`
4. **Test with Claude Code** MCP inspector
5. **Document** in `.brief/brief-guidelines.md`
6. **Add to allowlist** in `.claude/settings.local.json` if needs preapproval

### Tool Structure

```typescript
export const myTool: Tool = {
  name: 'brief_my_operation',
  description: 'Clear description of what it does',
  inputSchema: {
    type: 'object',
    properties: {
      // Zod-like schema
    },
    required: ['field1']
  },
  handler: async (args, context) => {
    return { success: true, data: result };
  }
};
```

### Testing MCP Tools

- Use MCP inspector: `npx @modelcontextprotocol/inspector`
- Test error cases (missing params, invalid auth, not found)
- Validate against OpenAPI spec if API-backed
- Test from Claude Code with actual workflows

### Documentation Pattern

Update `.brief/brief-guidelines.md`:

```markdown
### New Operation Category
- `operation_name` - Description of operation
  - Required params: param1, param2
  - Optional params: param3
  - Returns: what it returns
```

### MCP Common Mistakes

- ❌ Not validating input schema
- ❌ Not handling authentication errors
- ❌ Not documenting in guidelines
- ❌ Not adding to allowlist if needed
- ✅ Test happy path AND error paths

---

## Troubleshooting

### OAuth Issues

**Problem:** "Authentication failed" error
- **Check:** Extension ID in OAuth client redirect URIs
- **Fix:** Add `https://{extension-id}.chromiumapp.org/` to allowed redirect URIs

### API Issues

**Problem:** CORS errors
- **Check:** `host_permissions` in manifest.json
- **Fix:** Add API domain to `host_permissions`

### Build Issues

**Problem:** Hot reload not working
- **Check:** Plasmo dev server running
- **Fix:** Run `pnpm run dev` and reload extension
