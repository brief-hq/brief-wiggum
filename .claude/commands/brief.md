---
description: Access Brief CLI tools for product context, decisions, and document management
---

# /brief - Brief CLI Tools

Use /brief to set up or invoke Brief tools.

If the CLI is not installed, run:

```bash
npx @briefhq/cli@latest status
```

Or install globally:

```bash
npm i -g @briefhq/cli && brief login
```

## `brief ask` — Your PM Teammate

The primary way to interact with Brief. Think of it as a PM sitting next to you while you code — it has full access to decisions, personas, research signals, documents, product strategy, and connected tools (Linear, GitHub, Notion, Slack, etc.).

### Modes

- **`advise`** (default): Open-ended — ask anything, get a grounded answer
- **`check`**: Validate an approach against existing decisions before you build

### Examples

```bash
brief ask "Why did we build auth this way?"
brief ask "What do our customers care about?"
brief ask "What's in the current sprint?"
brief ask "Draft a PRD for this feature"
brief ask --mode check "Does this approach conflict with anything?"
brief ask --context "refactoring auth" "what decisions apply here?"
```

Supports `-c <conversation-id>` for multi-turn conversations.

## CRUD Commands (Deterministic Operations)

For precise operations where you know exactly what you want.

### Content Operations

- **Search documents:**
  ```bash
  brief docs search "authentication"
  ```

- **Show folder tree:**
  ```bash
  brief docs browse
  ```

- **Get document content:**
  ```bash
  brief docs read <document-id>
  ```

### Document Operations

- **Create document:**
  ```bash
  brief docs create --title "API Design Guide" --folder <folder-id> --content "# Heading\n\nContent here"
  ```

  Note: Always run `brief docs browse` first to find valid folder IDs.

### Decision Operations

Use `brief ask --mode check` to validate decisions, and `brief decisions create` for structured decision capture:

```bash
brief ask --mode check "Does switching to OAuth2 conflict with anything?"
brief decisions create --decision "Use OAuth2 instead of API keys" --rationale "API keys don't support scoping"
```

- **Record a decision:**
  ```bash
  brief decisions create --decision "Use PostgreSQL for main database" --rationale "Better for our relational data needs" --tags technical,database
  ```

- **Search decisions:**
  ```bash
  brief decisions search "database"
  ```

### Other Commands

```bash
brief features list              # Product features
brief personas list              # User personas
brief signals list               # Research signals
brief pipeline                   # Work pipeline
brief context                    # Product context
brief conversations list         # Recent conversations
```

## Best Practices

- Use `brief ask` for anything that benefits from judgment — context, decisions, validation, drafting
- Use specific subcommands for precise operations — creating documents, searching decisions
- Always call `brief docs browse` before creating documents to get valid folder IDs
- Use `--json` for structured output in scripts and agent workflows
- Tag decisions with relevant keywords for better searchability

## Notes

- Keep requests scoped to the current task
- Respect organization boundaries and sensitive materials
- Run `brief --help` or `brief <command> --help` for full command reference
- See @brief-guidelines.md for complete usage documentation
