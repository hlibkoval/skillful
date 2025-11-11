# Hooks Reference

Complete guide to Claude Code's hook system for intercepting and augmenting tool execution.

## Overview

Hooks allow you to run custom commands before/after tool calls or at session start. Common use cases:
- **Validation**: Check inputs before execution
- **Formatting**: Auto-format code after edits
- **Logging**: Track tool usage
- **Security**: Block dangerous operations
- **Integration**: Trigger external workflows

## Hook Events

### PreToolUse

Runs before a tool is executed. Can block execution.

**Use cases:**
- Validate command inputs
- Check security policies
- Log intended operations
- Confirm destructive actions

**Exit code behavior:**
- `0` - Allow execution, continue
- `1` - Allow execution, show stderr to user
- `2` - Block execution, show stderr to user

### PostToolUse

Runs after a tool completes. Cannot block execution (already done).

**Use cases:**
- Auto-format edited files
- Run linters after code changes
- Update indexes or caches
- Notify external systems
- Log completed operations

**Exit code behavior:**
- `0` - Success, continue silently
- `1` - Success, show stderr to user
- `2` - Show stderr to user

### SessionStart

Runs when a new Claude Code session begins.

**Use cases:**
- Install dependencies
- Set up development environment
- Load project context
- Display welcome messages
- Initialize services

## Configuration

### File Locations

Hooks can be configured in:
- `~/.claude/hooks.json` - User-level hooks
- `.claude/hooks.json` - Project-level hooks
- Plugin `hooks/hooks.json` - Plugin-provided hooks

### Basic Structure

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "ToolPattern",
        "hooks": [
          {
            "type": "command",
            "command": "your-command-here",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

## Matchers

Matchers use regex patterns to target specific tools:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",           // Match Bash tool
        "hooks": [...]
      },
      {
        "matcher": "Write|Edit",     // Match Write OR Edit
        "hooks": [...]
      },
      {
        "matcher": "mcp__memory__.*", // Match all Memory MCP tools
        "hooks": [...]
      },
      {
        "matcher": "mcp__.*__write.*", // Match all MCP write tools
        "hooks": [...]
      }
    ]
  }
}
```

**Common patterns:**
- `Bash` - All Bash commands
- `Read` - File read operations
- `Write|Edit` - File modifications
- `mcp__github__.*` - All GitHub MCP tools
- `mcp__.*` - All MCP tools

## Hook Input

Hooks receive tool information via stdin as JSON:

```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test",
    "description": "Run tests"
  }
}
```

Access in scripts:

```bash
#!/usr/bin/env bash
input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')
command=$(echo "$input" | jq -r '.tool_input.command')
```

```python
#!/usr/bin/env python3
import json
import sys

input_data = json.load(sys.stdin)
tool_name = input_data["tool_name"]
tool_input = input_data["tool_input"]
```

## Practical Examples

### Auto-Format After Edits

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/format-code.sh"
          }
        ]
      }
    ]
  }
}
```

```bash
#!/usr/bin/env bash
# ~/.claude/hooks/format-code.sh

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [ -n "$file_path" ]; then
  case "$file_path" in
    *.js|*.ts|*.jsx|*.tsx)
      npx prettier --write "$file_path" 2>&1
      ;;
    *.py)
      black "$file_path" 2>&1
      ;;
    *.go)
      gofmt -w "$file_path" 2>&1
      ;;
  esac
fi

exit 0
```

### Validate Bash Commands

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/validate-bash.py"
          }
        ]
      }
    ]
  }
}
```

```python
#!/usr/bin/env python3
# ~/.claude/hooks/validate-bash.py

import json
import re
import sys

BLOCKED_PATTERNS = [
    (r"^rm -rf /", "Dangerous: Deleting from root"),
    (r"^curl.*\|.*sh", "Security risk: Piping to shell"),
    (r"^wget.*\|.*sh", "Security risk: Piping to shell"),
]

input_data = json.load(sys.stdin)

if input_data.get("tool_name") != "Bash":
    sys.exit(0)

command = input_data.get("tool_input", {}).get("command", "")

for pattern, message in BLOCKED_PATTERNS:
    if re.search(pattern, command):
        print(f"❌ {message}", file=sys.stderr)
        print(f"   Command: {command}", file=sys.stderr)
        sys.exit(2)  # Block execution

sys.exit(0)
```

### Log Bash Commands

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '\"\\(.tool_input.command) - \\(.tool_input.description // \\\"No description\\\")\"' >> ~/.claude/bash-command-log.txt"
          }
        ]
      }
    ]
  }
}
```

### Run Tests After Edits

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/run-tests.sh",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```

```bash
#!/usr/bin/env bash
# ~/.claude/hooks/run-tests.sh

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Only run tests for source files, not test files
if [[ "$file_path" =~ src/.*\.(js|ts)$ ]]; then
  echo "Running tests for $file_path..." >&2
  npm test -- --findRelatedTests "$file_path" 2>&1
fi

exit 0
```

### Session Startup: Install Dependencies

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/install-deps.sh"
          }
        ]
      }
    ]
  }
}
```

```bash
#!/usr/bin/env bash
# ~/.claude/hooks/install-deps.sh

if [ -f "package.json" ] && [ ! -d "node_modules" ]; then
  echo "Installing npm dependencies..." >&2
  npm install 2>&1
fi

if [ -f "requirements.txt" ] && [ ! -d "venv" ]; then
  echo "Creating Python virtual environment..." >&2
  python3 -m venv venv
  source venv/bin/activate
  pip install -r requirements.txt 2>&1
fi

exit 0
```

### MCP Tool Logging

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "mcp__.*",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/log-mcp.sh"
          }
        ]
      }
    ]
  }
}
```

```bash
#!/usr/bin/env bash
# ~/.claude/hooks/log-mcp.sh

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "[$timestamp] $tool_name" >> ~/.claude/mcp-usage.log

exit 0
```

### Security: Block Sensitive File Access

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/block-sensitive-reads.py"
          }
        ]
      }
    ]
  }
}
```

```python
#!/usr/bin/env python3
# ~/.claude/hooks/block-sensitive-reads.py

import json
import sys
from pathlib import Path

BLOCKED_PATHS = [
    ".env",
    ".env.local",
    ".env.production",
    "secrets/",
    ".ssh/",
    ".aws/credentials",
]

input_data = json.load(sys.stdin)
file_path = input_data.get("tool_input", {}).get("file_path", "")

for blocked in BLOCKED_PATHS:
    if blocked in file_path:
        print(f"❌ Access denied: {file_path}", file=sys.stderr)
        print(f"   Contains sensitive path: {blocked}", file=sys.stderr)
        sys.exit(2)

sys.exit(0)
```

## Plugin Hooks

Plugins can provide hooks using `${CLAUDE_PLUGIN_ROOT}`:

```json
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
```

## Best Practices

### Script Development

1. **Make scripts executable**: `chmod +x script.sh`
2. **Use proper shebang**: `#!/usr/bin/env bash` or `#!/usr/bin/env python3`
3. **Handle errors gracefully**: Check for missing dependencies
4. **Provide helpful messages**: Use stderr for user-facing output
5. **Test exit codes**: Verify blocking behavior works correctly
6. **Set appropriate timeouts**: Prevent long-running hooks from hanging

### Security

1. **Validate inputs**: Check tool_input before using values
2. **Use allowlists**: Explicitly list allowed operations, block rest
3. **Avoid shell injection**: Use proper escaping for command arguments
4. **Log security events**: Track blocked operations for audit
5. **Test thoroughly**: Verify hooks don't create security vulnerabilities

### Performance

1. **Keep hooks fast**: Avoid slow operations in frequently-called hooks
2. **Run async when possible**: Don't block Claude unnecessarily
3. **Cache expensive checks**: Store validation results when appropriate
4. **Use timeouts**: Prevent hung processes from blocking work
5. **Profile hook performance**: Measure impact on workflow

### Debugging

```bash
# Test hook manually
echo '{"tool_name":"Bash","tool_input":{"command":"npm test"}}' | ~/.claude/hooks/validate-bash.py

# Check hook execution in debug log
claude --debug
tail -f ~/.claude/debug.log | grep hook

# Verify exit codes
~/.claude/hooks/validate-bash.py < test-input.json
echo $?  # Should be 0, 1, or 2
```

### Organization

```
~/.claude/
├── hooks.json           # Hook configuration
└── hooks/              # Hook scripts
    ├── format-code.sh
    ├── validate-bash.py
    ├── run-tests.sh
    └── log-mcp.sh
```

## Common Patterns

### Conditional Execution

Only run hook for specific file types:

```bash
#!/usr/bin/env bash
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Only process TypeScript files
if [[ "$file_path" =~ \.tsx?$ ]]; then
  # Do something
fi

exit 0
```

### Combining Checks

Multiple validation rules in one hook:

```python
#!/usr/bin/env python3
import json
import sys

input_data = json.load(sys.stdin)
command = input_data.get("tool_input", {}).get("command", "")

issues = []

if "rm -rf" in command:
    issues.append("Dangerous deletion detected")

if "|" in command and "sh" in command:
    issues.append("Piping to shell detected")

if issues:
    for issue in issues:
        print(f"❌ {issue}", file=sys.stderr)
    sys.exit(2)

sys.exit(0)
```

### User Confirmation

Prompt for destructive operations:

```bash
#!/usr/bin/env bash
input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command')

# Check for destructive patterns
if echo "$command" | grep -q "rm -rf\|drop database\|truncate"; then
  echo "⚠️  Destructive operation detected:" >&2
  echo "   $command" >&2
  echo "" >&2
  echo "   This operation cannot be undone." >&2
  echo "   Claude will ask for your approval." >&2
  exit 1  # Show warning, continue with approval prompt
fi

exit 0
```

## Troubleshooting

### Hook Not Executing

1. Check matcher pattern matches tool name
2. Verify hook file is executable: `chmod +x hook.sh`
3. Check shebang is correct
4. Enable debug mode: `claude --debug`
5. Review logs: `tail -f ~/.claude/debug.log`

### Hook Blocking Unexpectedly

1. Check exit code logic (0=allow, 2=block)
2. Test hook manually with sample input
3. Add debug output to stderr
4. Verify matcher isn't too broad

### Hooks Timing Out

1. Increase timeout in hook configuration
2. Optimize hook script performance
3. Run expensive operations async
4. Consider if hook is appropriate for frequent tool

## Advanced Patterns

### State Management

Track state across hook invocations:

```bash
#!/usr/bin/env bash
STATE_FILE=~/.claude/hook-state.json

# Read current state
state=$(cat "$STATE_FILE" 2>/dev/null || echo '{}')

# Update state
new_state=$(echo "$state" | jq '. + {"last_run": "'$(date -u +%s)'"}')

# Save state
echo "$new_state" > "$STATE_FILE"

exit 0
```

### Context-Aware Hooks

Different behavior based on project:

```bash
#!/usr/bin/env bash

# Detect project type
if [ -f "package.json" ]; then
  npm run lint
elif [ -f "Cargo.toml" ]; then
  cargo clippy
elif [ -f "go.mod" ]; then
  go vet ./...
fi

exit 0
```

### Notification Integration

Send notifications for specific events:

```bash
#!/usr/bin/env bash
input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')

# Notify on production deployments
if echo "$input" | jq -e '.tool_input.command | contains("deploy:prod")' > /dev/null; then
  curl -X POST https://slack.com/webhook \
    -d '{"text":"Claude is deploying to production"}'
fi

exit 0
```
