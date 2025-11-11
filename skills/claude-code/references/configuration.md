# Configuration Reference

Complete guide to configuring Claude Code through settings files.

## Settings File Locations

Claude Code uses a hierarchical configuration system:

1. **User-level**: `~/.claude/settings.json` - Global settings for all projects
2. **Project-level**: `.claude/settings.json` - Project-specific settings (version controlled)
3. **Local overrides**: `.claude/settings.local.json` - Local overrides (gitignored)

Priority: Local overrides > Project-level > User-level

## Creating Settings Files

### User-Level Settings

```bash
# Create user-level settings directory and file
mkdir -p ~/.claude
cat > ~/.claude/settings.json << 'EOF'
{
  "permissions": {
    "allow": [],
    "deny": []
  }
}
EOF
```

### Project-Level Settings

```bash
# Create project-level settings directory and file
mkdir -p .claude
cat > .claude/settings.json << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(npm run:*)",
      "Bash(git:*)"
    ]
  }
}
EOF
```

### Local Overrides (Gitignored)

```bash
# Add to .gitignore first
echo ".claude/settings.local.json" >> .gitignore

# Create local override file
cat > .claude/settings.local.json << 'EOF'
{
  "env": {
    "API_KEY": "your-secret-key"
  }
}
EOF
```

## Complete Settings Schema

```json
{
  "permissions": {
    "allow": ["pattern1", "pattern2"],
    "deny": ["pattern3", "pattern4"]
  },
  "permissionMode": "interactive",
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "excludedCommands": ["docker"],
    "network": {
      "allowUnixSockets": ["/var/run/docker.sock"],
      "allowLocalBinding": true
    }
  },
  "env": {
    "VAR_NAME": "value"
  },
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@package/name"]
    }
  },
  "enabledPlugins": {
    "plugin-name@marketplace": true
  },
  "extraKnownMarketplaces": {
    "marketplace-name": {
      "source": "github",
      "repo": "owner/repo"
    }
  },
  "hooks": {
    "PreToolUse": [],
    "PostToolUse": [],
    "SessionStart": []
  },
  "statusLine": {
    "enabled": true,
    "format": "{{model}} | {{tokens}}"
  },
  "spinnerTipsEnabled": true,
  "companyAnnouncements": ["message1", "message2"]
}
```

## Permission Patterns

### Tool Permission Syntax

```json
{
  "permissions": {
    "allow": [
      // Allow specific tool
      "Read(src/**/*.ts)",
      "Edit(**/*.js)",

      // Allow Bash commands with patterns
      "Bash(npm run:*)",
      "Bash(git:*)",
      "Bash(python -m:*)",

      // Allow specific file access
      "Read(~/.zshrc)",
      "Read(**/*.{js,ts,json,md})",

      // Allow MCP tools
      "mcp__github",                    // All tools from server
      "mcp__github__get_issue",         // Specific tool

      // Allow WebFetch for specific domains
      "WebFetch(domain:example.com)"
    ],
    "deny": [
      // Block dangerous operations
      "Bash(rm -rf:*)",
      "Bash(curl:*)",

      // Block sensitive file access
      "Read(.env)",
      "Read(.env.*)",
      "Read(./secrets/**)",
      "Read(~/.aws/**)",
      "Read(.envrc)",

      // Block specific tools
      "Edit(/config/secrets.json)"
    ]
  }
}
```

**Pattern Matching:**
- `*` - Matches any characters except `/`
- `**` - Matches any characters including `/`
- `{a,b,c}` - Matches any of the alternatives
- `?` - Matches single character

### Permission Modes

```json
{
  "permissionMode": "interactive"  // Prompt for each tool (default)
  "permissionMode": "acceptEdits"  // Auto-approve edits only
  "permissionMode": "plan"         // No execution without approval
}
```

Or set via CLI:

```bash
claude --permission-mode plan
```

## Practical Configuration Examples

### Development Project

```json
{
  "permissions": {
    "allow": [
      "Read(**/*.{js,ts,tsx,json,md})",
      "Edit(**/*.{js,ts,tsx})",
      "Bash(npm run:*)",
      "Bash(npm install:*)",
      "Bash(git:*)",
      "Bash(node:*)",
      "Bash(npx:*)"
    ],
    "deny": [
      "Edit(/config/production.json)",
      "Read(.env)",
      "Bash(rm -rf:*)",
      "Bash(curl:*)"
    ]
  },
  "env": {
    "NODE_ENV": "development"
  }
}
```

### Python Data Science Project

```json
{
  "permissions": {
    "allow": [
      "Read(**/*.{py,ipynb,csv,json})",
      "Edit(**/*.py)",
      "Bash(python:*)",
      "Bash(pip:*)",
      "Bash(jupyter:*)",
      "Bash(pytest:*)"
    ]
  },
  "env": {
    "PYTHONPATH": "${PWD}/src"
  }
}
```

### Security-Focused Configuration

```json
{
  "permissions": {
    "allow": [
      "Read(src/**/*.ts)",
      "Read(tests/**/*.ts)"
    ],
    "deny": [
      "Bash(*)",
      "Edit(*)",
      "Read(.env*)",
      "Read(**/secrets/**)",
      "Read(~/.ssh/**)",
      "Read(~/.aws/**)"
    ]
  },
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": false
  }
}
```

### CI/CD Environment

```json
{
  "permissions": {
    "allow": [
      "Read(**/*)",
      "Bash(npm run lint)",
      "Bash(npm run test:*)",
      "Bash(npm run build)"
    ],
    "deny": [
      "Edit(**/*)",
      "Bash(git push:*)"
    ]
  },
  "permissionMode": "acceptEdits"
}
```

## Sandbox Configuration

Enable sandboxed Bash execution on Linux and macOS:

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "excludedCommands": ["docker", "kubectl"],
    "network": {
      "allowUnixSockets": [
        "/var/run/docker.sock"
      ],
      "allowLocalBinding": true
    }
  }
}
```

### Enterprise Sandbox Policy

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": false
  },
  "permissions": {
    "deny": [
      "Bash(curl:*)",
      "Bash(wget:*)",
      "Bash(ssh:*)"
    ]
  }
}
```

## Environment Variables

Set environment variables available to Claude Code and tools:

```json
{
  "env": {
    "NODE_ENV": "development",
    "API_BASE_URL": "https://api.example.com",
    "PYTHONPATH": "${PWD}/src",
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1"
  }
}
```

Use in MCP configurations:

```json
{
  "mcpServers": {
    "api-server": {
      "command": "node",
      "args": ["server.js"],
      "env": {
        "API_URL": "${API_BASE_URL}"
      }
    }
  }
}
```

## Plugin Management

### Enable/Disable Plugins

```json
{
  "enabledPlugins": {
    "code-formatter@team-tools": true,
    "deployment-tools@team-tools": true,
    "experimental@personal": false
  }
}
```

### Add Custom Marketplaces

```json
{
  "extraKnownMarketplaces": {
    "company-tools": {
      "source": "github",
      "repo": "company/claude-plugins"
    },
    "team-plugins": {
      "source": "gitlab",
      "repo": "team/plugins"
    }
  }
}
```

## Status Line Configuration

Customize the status line display:

```json
{
  "statusLine": {
    "enabled": true,
    "format": "{{model}} | {{tokens}} | {{cost}}"
  }
}
```

Available variables:
- `{{model}}` - Current model name
- `{{tokens}}` - Token usage
- `{{cost}}` - Current session cost

## Company Announcements

Display messages to users:

```json
{
  "companyAnnouncements": [
    "Welcome to Acme Corp! Review our code guidelines at docs.acme.com",
    "Reminder: Code reviews required for all PRs",
    "New security policy in effect"
  ]
}
```

## Session Start Hooks

Run commands when sessions start:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/scripts/install_pkgs.sh"
          }
        ]
      }
    ]
  }
}
```

## Managed Settings (Enterprise)

Administrators can enforce settings via `managed-settings.json`:

```json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverName": "company-internal" }
  ],
  "deniedMcpServers": [
    { "serverName": "filesystem" }
  ],
  "permissions": {
    "deny": [
      "Bash(curl:*)",
      "Read(~/.ssh/**)"
    ]
  }
}
```

## Practical Workflows

### Creating Settings for New Project

```bash
# 1. Create project settings directory
mkdir -p .claude

# 2. Create settings file
cat > .claude/settings.json << 'EOF'
{
  "permissions": {
    "allow": [
      "Read(**/*.{js,ts,json,md})",
      "Edit(**/*.{js,ts})",
      "Bash(npm run:*)",
      "Bash(git:*)"
    ],
    "deny": [
      "Read(.env*)",
      "Bash(rm -rf:*)"
    ]
  }
}
EOF

# 3. Add local overrides to .gitignore
echo ".claude/settings.local.json" >> .gitignore

# 4. Validate configuration
claude /doctor
```

### Migrating from User to Project Settings

```bash
# 1. Copy user settings to project
cp ~/.claude/settings.json .claude/settings.json

# 2. Edit project settings to remove user-specific config
# Remove personal API keys, user paths, etc.

# 3. Move sensitive config to local overrides
cat > .claude/settings.local.json << 'EOF'
{
  "env": {
    "API_KEY": "your-key"
  }
}
EOF

# 4. Commit project settings
git add .claude/settings.json
git commit -m "Add Claude Code project configuration"
```

### Debugging Settings Issues

```bash
# 1. Enable debug mode
claude --debug

# 2. Check which settings are loaded
tail -f ~/.claude/debug.log | grep settings

# 3. Validate settings syntax
python3 -m json.tool .claude/settings.json

# 4. Test with project-only settings
claude --setting-sources 'project'
```

## Best Practices

1. **Version control project settings**: Commit `.claude/settings.json`, gitignore `.claude/settings.local.json`
2. **Use local overrides for secrets**: Never commit API keys or credentials
3. **Start restrictive, add permissions as needed**: Deny by default, allow specifically
4. **Document permission patterns**: Add comments explaining why permissions exist
5. **Test settings changes**: Use `/doctor` to validate configuration
6. **Use environment variables for paths**: Makes settings portable across machines
7. **Leverage permission modes**: Use `plan` mode for learning, `acceptEdits` for trusted environments
