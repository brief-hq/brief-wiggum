# Brief MCP Setup

Connect Brief to your AI editor to get product context, decisions, and customer insights.

## What is Brief MCP?

Brief exposes an MCP (Model Context Protocol) server that provides:

- **Product context**: What you're building, for whom, why
- **User personas**: Top user types with needs and pain points
- **Recent decisions**: Architectural and business decisions with rationale
- **Customer insights**: Themes and sentiment from user feedback
- **Current work**: What's being built and committed to

## Getting Your API Key

1. Log into [Brief](https://app.briefhq.ai)
2. Go to Settings → API Keys
3. Create a new API key
4. Copy the key (starts with `sk_`)

## Claude Code Setup

### Option 1: Project-level config

Create `.claude/mcp.json` in your project:

```json
{
  "mcpServers": {
    "brief": {
      "url": "https://app.briefhq.ai/api/mcp/sse",
      "transport": "sse",
      "headers": {
        "Authorization": "Bearer sk_YOUR_API_KEY_HERE"
      }
    }
  }
}
```

### Option 2: Global config

Add to `~/.claude/mcp.json`:

```json
{
  "mcpServers": {
    "brief": {
      "url": "https://app.briefhq.ai/api/mcp/sse",
      "transport": "sse",
      "headers": {
        "Authorization": "Bearer sk_YOUR_API_KEY_HERE"
      }
    }
  }
}
```

## Cursor Setup

Add to your Cursor settings (`.cursor/settings.json`):

```json
{
  "mcp": {
    "servers": {
      "brief": {
        "url": "https://app.briefhq.ai/api/mcp/sse",
        "transport": "sse",
        "headers": {
          "Authorization": "Bearer sk_YOUR_API_KEY_HERE"
        }
      }
    }
  }
}
```

## Verify Connection

After setup, restart your editor and run:

```
/health
```

You should see:
```
✅ Brief MCP: Connected (your-workspace)
```

Or test directly:
```
Use mcp__brief__brief_get_onboarding_context to get my product context
```

## Available Tools

Once connected, these Brief MCP tools are available:

| Tool | Purpose |
|------|---------|
| `brief_get_onboarding_context` | Load comprehensive product context |
| `brief_discover_capabilities` | Explore what Brief can do |
| `brief_plan_operation` | Get operation schemas |
| `brief_prepare_context` | Search documents, browse folders |
| `brief_execute_operation` | Create/update documents, record decisions |

## Common Operations

### Load product context
```
mcp__brief__brief_get_onboarding_context
```

### Search documents
```
mcp__brief__brief_prepare_context({
  "preparation_type": "search",
  "query": "auth requirements"
})
```

### Check approach against decisions
```
mcp__brief__brief_execute_operation({
  "operation": "guard_approach",
  "parameters": { "approach": "Use JWT for auth" }
})
```

### Record a decision
```
mcp__brief__brief_execute_operation({
  "operation": "record_decision",
  "parameters": {
    "decision": "Use Drizzle ORM for database access",
    "rationale": "Type safety, good DX, active maintenance",
    "tags": ["database", "orm"]
  }
})
```

## Troubleshooting

### "Connection refused"

- Check your internet connection
- Verify the URL is correct: `https://app.briefhq.ai/api/mcp/sse`
- Check if Brief is having downtime

### "Unauthorized"

- Verify your API key is correct
- Check the key hasn't expired
- Make sure the Authorization header format is `Bearer sk_...`

### "MCP server not found"

- Restart Claude Code/Cursor after adding config
- Check the config file is valid JSON
- Verify the file is in the correct location

## Security Notes

- Never commit API keys to git
- Use environment variables in CI/CD
- Rotate keys periodically
- Use project-level config to avoid key leakage across projects
