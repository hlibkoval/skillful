# MCP Servers Reference

Model Context Protocol (MCP) servers connect Claude Code to external tools and services.

## Overview

MCP servers provide:
- **Tools** - Functions Claude can invoke (e.g., GitHub API calls, database queries)
- **Resources** - Data Claude can reference (e.g., documentation, schemas)
- **Prompts** - Pre-configured workflows accessible as slash commands

## Transport Types

### HTTP (Recommended)

Best for cloud-based services. Supports OAuth 2.0 authentication.

```bash
claude mcp add --transport http <name> <url>

# Examples
claude mcp add --transport http github https://api.githubcopilot.com/mcp/
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
claude mcp add --transport http notion https://mcp.notion.com/mcp
```

### Stdio

Best for local processes and command-line tools.

```bash
claude mcp add --transport stdio <name> -- <command> [args...]

# Examples
claude mcp add --transport stdio airtable \
  --env AIRTABLE_API_KEY=YOUR_KEY \
  -- npx -y airtable-mcp-server

claude mcp add --transport stdio db \
  -- npx -y @bytebase/dbhub \
  --dsn "postgresql://user:pass@host:5432/db"
```

### SSE (Deprecated)

Server-Sent Events transport. Use HTTP instead when possible.

```bash
claude mcp add --transport sse <name> <url>

# Example
claude mcp add --transport sse asana https://mcp.asana.com/sse
```

## Configuration Methods

### 1. Command Line (Local Scope)

Servers added via CLI are stored in `~/.claude/.mcp.json` (user-level).

```bash
claude mcp add --transport http stripe https://mcp.stripe.com
```

### 2. Project Configuration

Create `.mcp.json` in project root for team-shared servers.

```json
{
  "mcpServers": {
    "project-api": {
      "type": "http",
      "url": "https://api.company.com/mcp"
    },
    "project-db": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@bytebase/dbhub", "--dsn", "${DB_URL}"]
    }
  }
}
```

Add with project scope:

```bash
claude mcp add --transport http paypal --scope project https://mcp.paypal.com/mcp
```

### 3. Settings File

Define in `settings.json` (user or project level).

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-github"],
      "oauth": {
        "clientId": "your-client-id",
        "clientSecret": "your-client-secret",
        "scopes": ["repo", "issues"]
      }
    }
  }
}
```

### 4. Plugin Configuration

Plugins can bundle MCP servers in `.mcp.json` or inline in `plugin.json`.

```json
{
  "name": "my-plugin",
  "mcpServers": {
    "plugin-api": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/api-server",
      "args": ["--port", "8080"]
    }
  }
}
```

### 5. Enterprise Management

Enterprise environments can use `managed-mcp.json` for centralized control.

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    },
    "company-internal": {
      "type": "stdio",
      "command": "/usr/local/bin/company-mcp-server",
      "args": ["--config", "/etc/company/mcp-config.json"]
    }
  }
}
```

With allowlist/denylist in `managed-settings.json`:

```json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverName": "company-internal" }
  ],
  "deniedMcpServers": [
    { "serverName": "filesystem" }
  ]
}
```

## Environment Variables

MCP configurations support variable expansion:

```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

Syntax:
- `${VAR}` - Required variable
- `${VAR:-default}` - Variable with fallback

Available in: `command`, `args`, `env`, `url`, `headers`

Special variables:
- `${CLAUDE_PLUGIN_ROOT}` - Plugin root directory (plugin MCP configs only)

## Authentication

### OAuth 2.0 (HTTP Servers)

Many HTTP MCP servers use OAuth for authentication.

```bash
# Add server
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp

# Authenticate in session
> /mcp
# Select "Authenticate" for the server
# Follow browser prompt to authorize
```

OAuth configuration in settings:

```json
{
  "mcpServers": {
    "github": {
      "oauth": {
        "clientId": "...",
        "clientSecret": "...",
        "scopes": ["repo", "issues"]
      }
    }
  }
}
```

### API Keys (Stdio Servers)

Pass API keys via environment variables:

```bash
claude mcp add --transport stdio airtable \
  --env AIRTABLE_API_KEY=YOUR_KEY \
  -- npx -y airtable-mcp-server
```

## Common MCP Servers

### GitHub

```bash
claude mcp add --transport http github https://api.githubcopilot.com/mcp/
```

Usage:
```
> /mcp  # Authenticate first
> "Review PR #456 and suggest improvements"
> "Create a new issue for the bug we just found"
```

### Sentry

```bash
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
```

Usage:
```
> /mcp  # Authenticate first
> "What are the most common errors in the last 24 hours?"
> "Show me the stack trace for error ID abc123"
```

### Notion

```bash
claude mcp add --transport http notion https://mcp.notion.com/mcp
```

### Figma

```bash
claude mcp add --transport http figma-remote-mcp https://mcp.figma.com/mcp
```

### Intercom

```bash
claude mcp add --transport http intercom https://mcp.intercom.com/mcp
```

### Airtable

```bash
claude mcp add --transport stdio airtable \
  --env AIRTABLE_API_KEY=YOUR_KEY \
  -- npx -y airtable-mcp-server
```

### ClickUp

```bash
claude mcp add --transport stdio clickup \
  --env CLICKUP_API_KEY=YOUR_KEY \
  --env CLICKUP_TEAM_ID=YOUR_TEAM \
  -- npx -y @hauptsache.net/clickup-mcp
```

### PostgreSQL/MySQL (Database)

```bash
claude mcp add --transport stdio db \
  -- npx -y @bytebase/dbhub \
  --dsn "postgresql://readonly:pass@prod.db.com:5432/analytics"
```

Usage:
```
> "What's our total revenue this month?"
> "Show me the schema for the orders table"
```

### Atlassian (Jira/Confluence)

```bash
claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse
```

## Using MCP Resources

Reference MCP resources using `@` mentions:

```
> Can you analyze @github:issue://123 and suggest a fix?
> Please review the API docs at @docs:file://api/authentication
> Compare @postgres:schema://users with @docs:file://database/user-model
```

## MCP Prompts as Slash Commands

MCP servers can expose prompts as slash commands:

```bash
# Format: /mcp__<server>__<prompt-name> [args...]

/mcp__github__list_prs
/mcp__github__pr_review 456
/mcp__jira__create_issue "Bug title" high
```

## Permissions

Configure MCP tool permissions in settings.json:

```json
{
  "permissions": {
    "allow": [
      "mcp__github",                    // All tools from github server
      "mcp__github__get_issue",         // Specific tool
      "mcp__github__list_issues"
    ]
  }
}
```

**Important**: Wildcards are NOT supported. Use server name to approve all tools.

✅ Correct: `mcp__github` (all tools from server)
✅ Correct: `mcp__github__get_issue` (specific tool)
❌ Wrong: `mcp__github__*` (wildcards not supported)

## Troubleshooting

### Connection Closed (Windows)

On native Windows, wrap npx commands:

```bash
# Instead of:
claude mcp add --transport stdio server -- npx -y @some/package

# Use:
claude mcp add --transport stdio server -- cmd /c npx -y @some/package
```

### OAuth Errors

Check authentication status:

```bash
> /mcp  # View server status and re-authenticate if needed
> /usage  # Check for token expiration
```

### Large Output Truncation

Increase token limit:

```bash
export MAX_MCP_OUTPUT_TOKENS=50000
claude
```

### Server Not Responding

1. Check server status: `/mcp`
2. Verify configuration: `claude mcp get <name>`
3. Check environment variables are set
4. Enable debug logging: `claude --debug`
5. Review logs: `tail -f ~/.claude/debug.log`

### Result Availability

Batch results expire 29 days after `created_at` time (not `ended_at`). Retrieve promptly.

## Claude Code as MCP Server

Serve Claude Code itself as an MCP server:

```bash
claude mcp serve
```

Then configure in Claude Desktop:

```json
{
  "mcpServers": {
    "claude-code": {
      "type": "stdio",
      "command": "claude",
      "args": ["mcp", "serve"]
    }
  }
}
```

## Best Practices

1. **Use HTTP for cloud services**: Better authentication support, cleaner configuration
2. **Use stdio for local tools**: Direct system access, custom scripts
3. **Project-scope team servers**: Add with `--scope project` for version-controlled configs
4. **Secure credentials**: Use environment variables, never hardcode API keys
5. **Test authentication early**: Run `/mcp` to verify server connection before heavy usage
6. **Use specific tool permissions**: Approve only needed tools to maintain security
7. **Monitor token limits**: Check `/cost` and `/usage` regularly when using MCP servers extensively
