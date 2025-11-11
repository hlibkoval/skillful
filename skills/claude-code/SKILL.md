---
name: claude-code
description: Use when answering questions about Claude Code CLI, configuration, settings, MCP servers, plugins, skills, hooks, or troubleshooting Claude Code issues. Provides comprehensive guidance on using Claude Code features, setup, and best practices.
---

# Claude Code

## Overview

This skill provides comprehensive knowledge about Claude Code, Anthropic's official CLI for agentic coding. Use this skill when users ask questions about Claude Code's features, configuration, troubleshooting, or best practices.

## Core Capabilities

Claude Code offers several key capabilities that users frequently need help with:

### 1. CLI Usage and Commands

Claude Code provides both the `claude` command for launching sessions and in-session slash commands for control.

**Launch Commands:**
- `claude` - Start interactive session
- `claude --model opus` - Launch with specific model
- `claude --debug` - Enable debug logging for troubleshooting
- `claude --resume <session-id>` - Resume previous session
- `claude --continue` - Continue last session

**In-Session Commands:**
- `/model` - Switch AI model interactively
- `/mcp` - Manage MCP servers and authentication
- `/context` - Check current context usage
- `/memory` - Review memory status
- `/clear` - Clear conversation history
- `/rewind` - Undo recent changes
- `/cost` - View API usage details
- `/usage` - Track plan limits
- `/plugin` - Manage plugins and marketplaces

For complete CLI reference, see `references/cli-reference.md`.

### 2. MCP (Model Context Protocol) Servers

MCP servers connect Claude Code to external tools and services. Common operations:

**Adding MCP Servers:**
```bash
# HTTP transport (recommended for cloud services)
claude mcp add --transport http <name> <url>

# Stdio transport (for local processes)
claude mcp add --transport stdio <name> <command> [args...]

# With environment variables
claude mcp add --transport stdio <name> --env API_KEY=value -- <command>
```

**Managing MCP Servers:**
```bash
# List all servers
claude mcp list

# Get server details
claude mcp get <name>

# Remove server
claude mcp remove <name>

# Check server status (in Claude Code session)
/mcp
```

**Common MCP Servers:**
- GitHub: `claude mcp add --transport http github https://api.githubcopilot.com/mcp/`
- Sentry: `claude mcp add --transport http sentry https://mcp.sentry.dev/mcp`
- PostgreSQL: Uses `npx -y @bytebase/dbhub --dsn "connection-string"`

For detailed MCP configuration, authentication, and troubleshooting, see `references/mcp-servers.md`.

### 3. Configuration and Settings

Claude Code uses JSON configuration files for permissions, environment variables, and behavior control.

**Settings Files:**
- `~/.claude/settings.json` - User-level settings
- `.claude/settings.json` - Project-level settings
- `.claude/settings.local.json` - Local overrides (gitignored)

**Key Configuration Areas:**
- **Permissions**: Allow/deny specific tools and commands
- **Environment Variables**: Set via `env` object
- **Sandbox Mode**: Configure command execution security
- **Plugin Management**: Enable/disable plugins
- **MCP Servers**: Define server configurations

For complete configuration reference and examples, see `references/configuration.md`.

### 4. Plugins and Skills

**Plugins** are installable packages that extend Claude Code with commands, agents, hooks, and MCP servers.

**Skills** are specialized capabilities that Claude auto-invokes based on task descriptions.

**Plugin Management:**
```bash
# In Claude Code session
/plugin install <plugin>@<marketplace>
/plugin enable <plugin>
/plugin disable <plugin>
/plugin marketplace list
/plugin marketplace add <path-or-repo>
```

**Creating Plugins:**
- Use `.claude-plugin/plugin.json` for metadata
- Organize commands in `commands/` directory
- Define agents in `agents/` directory
- Configure hooks in `hooks/` or `hooks.json`
- Package MCP servers in `.mcp.json`

For plugin development and skill creation, see `references/plugins-and-skills.md`.

### 5. Hooks System

Hooks intercept tool execution to run custom validation, formatting, or logging.

**Hook Events:**
- `PreToolUse` - Before tool execution
- `PostToolUse` - After tool execution
- `SessionStart` - At session initialization

**Hook Configuration:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 /path/to/validator.py"
          }
        ]
      }
    ]
  }
}
```

**Exit Code Behavior:**
- `0` - Success, continue execution
- `1` - Show stderr, continue execution
- `2` - Block tool call, show stderr

For hook patterns and examples, see `references/hooks.md`.

### 6. Git Workflow Automation

Claude Code automates git operations including commits and pull requests.

**Commit Workflow:**
1. Runs `git status` and `git diff`
2. Creates branch if needed
3. Stages relevant files
4. Generates commit message
5. Creates commit with co-authorship attribution

**PR Workflow:**
1. Analyzes branch commits since divergence
2. Drafts PR summary with bullet points
3. Pushes to remote if needed
4. Creates PR via `gh` CLI with structured body

Users should explicitly request commits or PRs. Never commit changes proactively unless requested.

### 7. Troubleshooting

**Common Issues:**
- **Authentication errors**: Check `/usage` for token expiration
- **Permission denied**: Update `settings.json` allowedTools
- **MCP server failures**: Verify with `/mcp` and check authentication
- **Context too large**: Use `/compact` or `/clear`
- **Hook failures**: Check exit codes and stderr output
- **Plugin issues**: Run `/plugin validate`

**Debug Commands:**
```bash
# Enable debug logging
claude --debug

# Check debug logs
tail -f ~/.claude/debug.log

# Validate configuration
claude /doctor
```

For comprehensive troubleshooting guides, see `references/troubleshooting.md`.

## Best Practices

### When Answering Questions

1. **Check references first**: Before answering, check if detailed documentation exists in `references/` for the topic
2. **Use WebFetch for latest docs**: If the question involves recent features or the references don't cover it, use WebFetch to fetch from https://docs.claude.com/en/docs/claude-code/
3. **Provide concrete examples**: Always include code snippets or command examples
4. **Link to documentation**: Reference official docs at https://docs.claude.com/en/docs/claude-code/
5. **Explain context**: Help users understand *why* certain approaches are recommended

### Common Patterns

**For "How do I..." questions:**
1. Provide the direct command or configuration
2. Explain what it does
3. Show a concrete example
4. Link to relevant reference file

**For "Why isn't..." troubleshooting:**
1. Identify the likely cause
2. Provide diagnostic steps
3. Suggest the fix
4. Reference troubleshooting documentation

**For "What is..." conceptual questions:**
1. Explain the concept clearly
2. Provide use cases
3. Show examples
4. Compare with related concepts if helpful

## Documentation Map

The Claude Code documentation is available at https://docs.claude.com/en/docs/claude-code/. The following map shows key documentation pages:

**Core Concepts:**
- `/claude-code/overview.md` - Introduction and key features
- `/claude-code/quickstart.md` - Getting started guide
- `/claude-code/workflow.md` - Typical usage patterns

**Configuration:**
- `/claude-code/settings.md` - Settings file reference
- `/claude-code/iam.md` - Permissions and security
- `/claude-code/hooks.md` - Hook system reference
- `/claude-code/hooks-guide.md` - Hook implementation guide

**Extensibility:**
- `/claude-code/mcp.md` - MCP server integration
- `/claude-code/plugins.md` - Plugin system
- `/claude-code/plugins-reference.md` - Plugin API reference
- `/claude-code/plugin-marketplaces.md` - Marketplace system
- `/claude-code/skills.md` - Skills framework
- `/claude-code/slash-commands.md` - Command system

**Reference:**
- `/claude-code/cli-reference.md` - CLI commands and flags
- `/claude-code/model-config.md` - Model selection and configuration

When users ask questions, prefer using the bundled `references/` files first, then use WebFetch to fetch specific documentation pages as needed.

## Resources

This skill includes comprehensive reference documentation organized by topic:

### references/

- `cli-reference.md` - Complete CLI command reference and flags
- `mcp-servers.md` - MCP server configuration, authentication, and examples
- `configuration.md` - Settings file schemas and examples
- `plugins-and-skills.md` - Plugin and skill development guides
- `hooks.md` - Hook system patterns and examples
- `troubleshooting.md` - Common issues and solutions
- `best-practices.md` - Recommended workflows and optimization tips

Load these files as needed to answer specific questions. They contain detailed information that would be too verbose for SKILL.md.
