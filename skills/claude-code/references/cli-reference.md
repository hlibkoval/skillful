# CLI Reference

Complete reference for Claude Code command-line interface.

## Launch Commands

### Basic Usage

```bash
# Start interactive session
claude

# Start with specific prompt
claude "analyze this codebase"

# Continue last session
claude --continue
```

### Model Selection

```bash
# Launch with specific model
claude --model opus
claude --model sonnet
claude --model haiku

# Switch models during session
/model
```

Available models:
- `claude-sonnet-4-5-20250929` - Latest Sonnet (default)
- `claude-opus-4` - Most capable, slower
- `claude-haiku-4-5` - Fastest, most economical

### Session Management

```bash
# Resume previous session by ID
claude --resume abc123

# Continue most recent session
claude --continue
```

### Permission Modes

```bash
# Set permission mode
claude --permission-mode plan       # Plan mode (no execution without approval)
claude --permission-mode acceptEdits # Auto-approve edits only
claude --permission-mode interactive # Prompt for each tool (default)

# Skip all permission prompts (dangerous)
claude --dangerously-skip-permissions
```

### Tool Control

```bash
# Approve specific tool on launch
claude -p --permission-prompt-tool mcp_auth_tool "query"

# Disallow specific tools
claude --disallowedTools "Bash(git log:*)" "Bash(git diff:*)" "Edit"
```

### Debug and Diagnostics

```bash
# Enable debug logging
claude --debug

# Check debug logs
tail -f ~/.claude/debug.log

# Validate configuration (in-session)
/doctor
```

### Budget Control

```bash
# Set maximum spend limit
claude --max-budget-usd 10.00
```

### Configuration

```bash
# Use custom settings file
claude --mcp-config /path/to/config.json

# Load only project-level settings
claude --setting-sources 'project'

# Define custom agents
claude --agents '{ "code-reviewer": { "description": "Expert code reviewer", "prompt": "Focus on security and best practices", "tools": ["Read", "Grep"], "model": "sonnet" } }'
```

### Output Format

```bash
# JSON output format (for programmatic use)
claude --output-format json
```

## In-Session Commands

### Session Control

- `/clear` - Clear conversation history
- `/rewind` - Undo recent changes
- `/exit` or `/quit` - Exit Claude Code

### Context Management

- `/context` - Check current context usage
- `/add-dir <path>` - Add directory to context
- `/compact` - Reduce conversation size
- `/memory` - Review memory status

### Model and Configuration

- `/model` - Switch AI model interactively
- `/cost` - View API usage and costs
- `/usage` - Track plan limits

### MCP Server Management

- `/mcp` - Manage MCP servers, view status, authenticate

### Plugin Management

- `/plugin install <plugin>@<marketplace>` - Install plugin
- `/plugin enable <plugin>` - Enable plugin
- `/plugin disable <plugin>` - Disable plugin
- `/plugin list` - List installed plugins
- `/plugin marketplace list` - List available marketplaces
- `/plugin marketplace add <source>` - Add marketplace
- `/plugin validate` - Validate plugin structure

### Diagnostics

- `/doctor` - Validate configuration and environment

## Environment Variables

### API Configuration

```bash
# Anthropic API key
export ANTHROPIC_API_KEY=sk-ant-...

# OpenAI compatibility
export OPENAI_API_KEY=sk-...

# AWS Bedrock
export AWS_REGION=us-west-2
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...

# Google Vertex AI
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
export GOOGLE_CLOUD_PROJECT=project-id
export GOOGLE_CLOUD_LOCATION=us-central1
```

### Claude Code Settings

```bash
# Skip login shell
export CLAUDE_BASH_NO_LOGIN=1

# Default model
export ANTHROPIC_DEFAULT_SONNET_MODEL=claude-sonnet-4-5

# Disable non-essential traffic
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# Increase MCP output token limit
export MAX_MCP_OUTPUT_TOKENS=50000

# Bash timeout customization
export BASH_DEFAULT_TIMEOUT_MS=120000

# Proxy settings
export HTTP_PROXY=http://proxy:8080
export HTTPS_PROXY=http://proxy:8080
export NO_PROXY=localhost,127.0.0.1
```

### Telemetry

```bash
# Enable telemetry
export CLAUDE_CODE_ENABLE_TELEMETRY=1

# OpenTelemetry metrics exporter
export OTEL_METRICS_EXPORTER=otlp
```

## MCP Commands

### Add MCP Servers

```bash
# HTTP transport (cloud services)
claude mcp add --transport http <name> <url>
claude mcp add --transport http github https://api.githubcopilot.com/mcp/

# With authentication header
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer token"

# Stdio transport (local processes)
claude mcp add --transport stdio <name> -- <command> [args...]
claude mcp add --transport stdio airtable \
  --env AIRTABLE_API_KEY=YOUR_KEY \
  -- npx -y airtable-mcp-server

# SSE transport (deprecated, use HTTP instead)
claude mcp add --transport sse <name> <url>

# From JSON configuration
claude mcp add-json <name> '<json>'

# Import from Claude Desktop
claude mcp add-from-claude-desktop

# Project-scoped server
claude mcp add --transport http paypal --scope project https://mcp.paypal.com/mcp
```

### Manage MCP Servers

```bash
# List all servers
claude mcp list

# Get server details
claude mcp get <name>

# Remove server
claude mcp remove <name>

# Serve Claude Code as MCP server
claude mcp serve
```

## Exit Codes

- `0` - Success
- `1` - General error
- `2` - Configuration error
- `130` - Interrupted by user (Ctrl+C)

## Platform-Specific Notes

### Windows

```bash
# Use cmd wrapper for npx on native Windows
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package

# Use POSIX path format
//c/Users/username/file.txt
```

### macOS

```bash
# Unlock keychain if locked
security unlock-keychain
```

### WSL

- Claude Desktop import supported
- Use Linux-style paths within WSL environment

## Best Practices

1. **Use specific models for tasks**: Haiku for simple tasks, Sonnet for balanced work, Opus for complex reasoning
2. **Enable debug mode for troubleshooting**: Always use `--debug` when diagnosing issues
3. **Set budget limits for experiments**: Use `--max-budget-usd` to prevent unexpected costs
4. **Resume sessions for continuity**: Use `--resume` or `--continue` to maintain context
5. **Configure environment variables in shell profile**: Add exports to `.bashrc`, `.zshrc`, or similar for persistence
