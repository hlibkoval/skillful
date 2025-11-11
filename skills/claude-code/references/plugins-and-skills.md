# Plugins and Skills Reference

Complete guide to Claude Code's extensibility system.

## Plugins vs Skills

**Plugins** are installable packages that can contain:
- Slash commands (user-invoked, e.g., `/deploy`)
- Agents (specialized Claude instances)
- Hooks (event-driven scripts)
- MCP servers (external integrations)
- Skills (auto-invoked capabilities)

**Skills** are specialized capabilities that Claude auto-invokes based on task descriptions. They can be bundled in plugins or exist standalone.

## Plugin System

### Installing Plugins

```bash
# In Claude Code session
/plugin install <plugin-name>@<marketplace-name>

# Examples
/plugin install security-guidance@anthropic
/plugin install code-review@anthropic
/plugin install pr-review-toolkit@anthropic
```

### Managing Plugins

```bash
# List installed plugins
/plugin list

# Enable plugin
/plugin enable security-guidance

# Disable plugin
/plugin disable security-guidance

# Validate plugin structure
/plugin validate
```

### Managing Marketplaces

```bash
# List available marketplaces
/plugin marketplace list

# Add marketplace from GitHub
/plugin marketplace add owner/repo

# Add local marketplace for development
/plugin marketplace add ./path/to/marketplace

# Install from specific branch/tag
/plugin install plugin@marketplace#branch-name
/plugin install plugin@marketplace#v1.2.3
```

## Creating a Plugin

### Directory Structure

```
my-plugin/
├── .claude-plugin/
│   ├── plugin.json          # Required: Plugin metadata
│   └── marketplace.json     # Optional: Self-reference as marketplace
├── commands/                # Optional: Slash commands
│   └── my-command.md
├── agents/                  # Optional: Specialized agents
│   └── my-agent.md
├── skills/                  # Optional: Auto-invoked skills
│   └── my-skill/
│       └── SKILL.md
├── hooks/                   # Optional: Hook configurations
│   └── hooks.json
└── .mcp.json               # Optional: Bundled MCP servers
```

### plugin.json (Required)

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Brief description of what this plugin does",
  "author": {
    "name": "Your Name",
    "email": "you@example.com",
    "url": "https://github.com/yourusername"
  },
  "homepage": "https://docs.example.com/plugin",
  "repository": "https://github.com/yourusername/my-plugin",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"],
  "commands": "./commands/",
  "agents": "./agents/",
  "skills": "./skills/",
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

### Creating a Slash Command

```bash
# Create command file
mkdir -p commands
cat > commands/deploy.md << 'EOF'
---
description: Deploy application to production
---

# Deploy Command

When this command is invoked, follow these steps:

1. Run tests to ensure code quality
2. Build the application
3. Deploy to production environment
4. Verify deployment success

## Implementation

To deploy:

```bash
npm run test
npm run build
npm run deploy:prod
```

Check deployment status at https://status.example.com
EOF
```

### Creating an Agent

```bash
# Create agent file
mkdir -p agents
cat > agents/code-reviewer.md << 'EOF'
---
description: Expert code reviewer focused on security and best practices
---

# Code Reviewer Agent

You are a senior code reviewer with expertise in security, performance, and maintainability.

## Focus Areas

1. **Security**: Look for vulnerabilities, injection risks, authentication issues
2. **Performance**: Identify inefficient algorithms, memory leaks, unnecessary operations
3. **Maintainability**: Check code clarity, documentation, naming conventions
4. **Best Practices**: Ensure adherence to language and framework conventions

## Review Process

1. Read the code thoroughly
2. Identify issues and categorize by severity (critical/major/minor)
3. Provide specific, actionable feedback
4. Suggest improvements with code examples
5. Acknowledge well-written code

## Output Format

Provide review feedback as:

**Critical Issues** - Security vulnerabilities, data loss risks
**Major Issues** - Performance problems, architectural concerns
**Minor Issues** - Style inconsistencies, documentation gaps
**Positive Notes** - Well-implemented patterns, good practices
EOF
```

### Creating Plugin Hooks

```bash
# Create hooks configuration
mkdir -p hooks
cat > hooks/hooks.json << 'EOF'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
EOF

# Create formatting script
mkdir -p scripts
cat > scripts/format.sh << 'EOF'
#!/usr/bin/env bash
# Auto-format code after edits

# Read tool input from stdin
input=$(cat)

# Extract file path from tool input
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [ -n "$file_path" ]; then
  # Run formatter based on file type
  case "$file_path" in
    *.js|*.ts|*.jsx|*.tsx)
      npx prettier --write "$file_path" 2>/dev/null
      ;;
    *.py)
      black "$file_path" 2>/dev/null
      ;;
  esac
fi

exit 0
EOF

chmod +x scripts/format.sh
```

### Bundling MCP Servers

```bash
# Create MCP configuration for plugin
cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "plugin-database": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
      "env": {
        "DB_PATH": "${CLAUDE_PLUGIN_ROOT}/data"
      }
    }
  }
}
EOF
```

### Validating Plugin

```bash
# Validate plugin structure
cd my-plugin
claude /plugin validate .

# Or from Claude CLI
claude --debug
```

## Skills System

Skills are auto-invoked based on their description matching the user's task.

### Creating a Skill

```bash
# Use skill-creator if available
~/.claude/plugins/marketplaces/anthropic-agent-skills/skill-creator/scripts/init_skill.py my-skill --path skills/

# Or create manually
mkdir -p skills/my-skill/{scripts,references,assets}
cat > skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: Use when working with XYZ files or performing ABC tasks. Specific trigger conditions here.
---

# My Skill

## Overview

This skill enables Claude to [specific capability].

## When to Use

Invoke this skill when:
- User mentions XYZ files
- Task involves ABC operations
- Specific domain keywords appear

## Workflow

To accomplish [task]:

1. First step
2. Second step
3. Reference bundled resources as needed

## Resources

### scripts/

Executable code for deterministic operations:
- `process.py` - Processes XYZ files

### references/

Documentation loaded into context:
- `api-docs.md` - API reference
- `schemas.md` - Data schemas

### assets/

Files used in output:
- `template.xyz` - Starter template
EOF
```

### Skill Best Practices

1. **Write clear descriptions**: The `description` field determines when Claude invokes the skill
2. **Keep SKILL.md lean**: Target ~2-3k words, move details to `references/`
3. **Use imperative voice**: "To do X, do Y" not "You should do X"
4. **Provide concrete examples**: Show actual commands and workflows
5. **Reference bundled resources**: Guide Claude to scripts, references, assets
6. **Test trigger conditions**: Ensure description matches actual use cases

### Skill vs Command vs Agent

**Skill** - Auto-invoked based on description (e.g., "pdf-editor" for PDF tasks)
**Command** - User-invoked with `/command-name` (e.g., `/deploy`)
**Agent** - Specialized Claude instance with custom instructions (e.g., code-reviewer)

Use skills for domain-specific workflows, commands for explicit actions, agents for specialized perspectives.

## Built-in Plugins

### Security Guidance

Security reminder hooks for potential vulnerabilities.

```bash
/plugin install security-guidance@anthropic
```

### PR Review Toolkit

Comprehensive PR review with 6 specialized agents:
- comment-analyzer - Verify documentation accuracy
- pr-test-analyzer - Evaluate test coverage
- silent-failure-hunter - Find error handling gaps
- type-design-analyzer - Review type design
- code-reviewer - General code quality
- code-simplifier - Suggest refactoring

```bash
/plugin install pr-review-toolkit@anthropic
```

Usage:
```
> "Check if the tests cover all edge cases"
> "Review the error handling in this PR"
> "Is the documentation accurate?"
```

### Code Review

Automated PR review with confidence-based scoring (≥80 threshold).

```bash
/plugin install code-review@anthropic
/code-review  # Run on current PR branch
```

### Feature Development

7-phase structured feature development workflow with specialized agents:
- code-explorer - Deep codebase analysis
- code-architect - Feature design
- code-reviewer - Quality assurance

```bash
/plugin install feature-dev@anthropic
/feature-dev  # Start structured workflow
```

### Explanatory Output Style

Educational output with implementation insights.

```bash
/plugin install explanatory-output-style@anthropic
```

## Hybrid Marketplace/Plugin Pattern

A repository can act as both marketplace and plugin simultaneously:

```json
// .claude-plugin/marketplace.json
{
  "name": "my-marketplace",
  "version": "1.0.0",
  "description": "Marketplace and plugin collection",
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./",  // Self-reference
      "version": "1.0.0"
    }
  ]
}
```

This allows users to:
- Add as marketplace: `/plugin marketplace add owner/repo`
- Install as plugin: `/plugin install my-plugin@my-marketplace`

Both paths provide identical functionality.

## Debugging Plugins

```bash
# Enable debug mode
claude --debug

# Check plugin loading
tail -f ~/.claude/debug.log | grep plugin

# Validate plugin structure
/plugin validate .

# Test skill invocation
# Add logging to SKILL.md to verify loading
```

## Publishing Plugins

### GitHub Marketplace

```bash
# 1. Create repository with plugin structure
git init
git add .
git commit -m "Initial plugin"
git remote add origin https://github.com/username/my-plugin
git push -u origin main

# 2. Tag release
git tag v1.0.0
git push --tags

# 3. Users install with
/plugin marketplace add username/my-plugin
/plugin install my-plugin@username-my-plugin
```

### Private Marketplaces

Configure in `settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "company-plugins": {
      "source": "github",
      "repo": "company/claude-plugins"
    }
  }
}
```

## Best Practices

1. **Follow naming conventions**: Use kebab-case for plugin names
2. **Semantic versioning**: Follow semver for version numbers
3. **Comprehensive testing**: Test all commands, agents, and skills
4. **Clear documentation**: Include README with installation and usage
5. **Minimal dependencies**: Reduce external dependencies where possible
6. **Use environment variables**: Make configurations portable with `${CLAUDE_PLUGIN_ROOT}`
7. **Validate before publishing**: Run `/plugin validate` to catch issues
8. **Provide examples**: Include example usage in documentation
9. **Version control**: Use git tags for releases
10. **Security review**: Audit hooks and scripts for security issues
