# Brief MCP Setup

> **Canonical documentation**: [briefhq.ai/docs/mcp-setup](https://briefhq.ai/docs/mcp-setup/)

Connect Brief to your AI editor (Cursor, Claude Code, Windsurf, VS Code) to get product context, decisions, and customer insights.

## Quick Start

The recommended setup uses OAuth authentication:

### Claude Code

```bash
claude mcp add --transport http brief https://app.briefhq.ai/mcp
```

### Cursor

Add to `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "brief": {
      "type": "sse",
      "url": "https://app.briefhq.ai/api/mcp/sse"
    }
  }
}
```

### Other Editors

See the [full setup guide](https://briefhq.ai/docs/mcp-setup/) for:
- Claude Desktop
- Windsurf
- VS Code
- Codex CLI
- API key authentication (alternative)
- Troubleshooting

## Verify Connection

After setup, restart your editor and run:

```
/health
```

Or test directly:

```
Use mcp__brief__brief_get_onboarding_context to get my product context
```

## Available Tools

| Tool | Purpose |
|------|---------|
| `brief_get_onboarding_context` | Load comprehensive product context |
| `brief_prepare_context` | Search documents, browse folders |
| `brief_execute_operation` | Create/update documents, record decisions, guard_approach |

For full tool documentation and examples, see [briefhq.ai/docs/mcp-setup](https://briefhq.ai/docs/mcp-setup/).
