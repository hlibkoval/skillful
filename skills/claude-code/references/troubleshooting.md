# Troubleshooting Guide

Common issues and solutions for Claude Code.

## Authentication Issues

### API Key Not Working

**Symptoms:**
- "Invalid API key" errors
- "Unauthorized" responses

**Solutions:**

```bash
# 1. Verify API key is set correctly
echo $ANTHROPIC_API_KEY

# 2. Set API key if missing
export ANTHROPIC_API_KEY=sk-ant-...

# 3. Add to shell profile for persistence
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.zshrc
source ~/.zshrc

# 4. Check usage limits
/usage
```

### OAuth Token Expired

**Symptoms:**
- MCP servers fail to authenticate
- "Token expired" errors

**Solutions:**

```bash
# In Claude Code session
/mcp

# Select the failing server and re-authenticate
# Follow the browser prompt to authorize again
```

### macOS Keychain Locked

**Symptoms:**
- Authentication prompts don't appear
- Keychain access errors

**Solution:**

```bash
# Unlock keychain
security unlock-keychain
```

## Permission Errors

### Tool Blocked by Permissions

**Symptoms:**
- "Permission denied" messages
- Tools not executing

**Diagnosis:**

```bash
# 1. Enable debug mode
claude --debug

# 2. Check logs for permission errors
tail -f ~/.claude/debug.log | grep permission

# 3. Check settings file
cat .claude/settings.json
```

**Solutions:**

```bash
# Option 1: Add to allow list in settings.json
cat > .claude/settings.json << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(npm run:*)",
      "Bash(git:*)",
      "Read(**/*.ts)",
      "Edit(**/*.ts)"
    ]
  }
}
EOF

# Option 2: Use plan mode to approve interactively
claude --permission-mode interactive

# Option 3: Temporarily skip permissions (DANGEROUS)
claude --dangerously-skip-permissions
```

### MCP Tool Permission Denied

**Solution:**

```json
{
  "permissions": {
    "allow": [
      "mcp__github",              // All GitHub tools
      "mcp__github__get_issue",   // Or specific tools
      "mcp__github__list_issues"
    ]
  }
}
```

## MCP Server Issues

### MCP Server Not Connecting

**Symptoms:**
- Server appears offline in `/mcp`
- Tools from server unavailable

**Diagnosis:**

```bash
# 1. Check server status
claude
> /mcp

# 2. List configured servers
claude mcp list

# 3. Get server details
claude mcp get <server-name>

# 4. Enable debug logging
claude --debug
tail -f ~/.claude/debug.log | grep mcp
```

**Solutions:**

```bash
# 1. Verify server configuration
claude mcp get github

# 2. Remove and re-add server
claude mcp remove github
claude mcp add --transport http github https://api.githubcopilot.com/mcp/

# 3. Check environment variables are set
echo $API_KEY

# 4. Test connection manually
curl -v https://mcp.example.com/mcp
```

### Connection Closed (Windows)

**Symptoms:**
- stdio MCP servers fail on native Windows
- "Connection closed" errors

**Solution:**

```bash
# Use cmd wrapper for npx
claude mcp add --transport stdio server -- cmd /c npx -y @package/name
```

### MCP Output Truncated

**Symptoms:**
- Large query results cut off
- Incomplete data returned

**Solution:**

```bash
# Increase output token limit
export MAX_MCP_OUTPUT_TOKENS=50000
claude
```

## Context and Memory Issues

### Context Window Full

**Symptoms:**
- "Context too large" errors
- Slowdown in responses

**Solutions:**

```bash
# In Claude Code session

# Option 1: Compact conversation
/compact

# Option 2: Clear conversation entirely
/clear

# Option 3: Resume with fresh context
/exit
claude --resume <session-id>
```

### Memory Not Persisting

**Symptoms:**
- Claude forgets previous conversation context
- Need to repeat information

**Solutions:**

```bash
# Check memory status
/memory

# Use /add-dir to explicitly add important directories
/add-dir src/core

# Save important context before compacting
> "Remember: we're using React 18 with TypeScript strict mode"
/compact
```

## Performance Issues

### Claude Code Running Slow

**Symptoms:**
- Slow responses
- Long wait times

**Diagnosis:**

```bash
# 1. Check context usage
/context

# 2. Check model being used
/model

# 3. Monitor costs
/cost
```

**Solutions:**

```bash
# 1. Use faster model for simple tasks
/model
# Select Haiku

# 2. Reduce context
/compact

# 3. Disable non-essential traffic
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
claude

# 4. Check network connectivity
ping claude.ai
```

### High API Costs

**Symptoms:**
- Unexpected charges
- Budget exceeded

**Solutions:**

```bash
# 1. Set budget limits
claude --max-budget-usd 10.00

# 2. Use more economical models
claude --model haiku

# 3. Monitor usage
/usage
/cost

# 4. Compact context more frequently
/compact
```

## Configuration Issues

### Settings Not Loading

**Symptoms:**
- Permissions not enforced
- Environment variables not available

**Diagnosis:**

```bash
# 1. Check settings file syntax
python3 -m json.tool .claude/settings.json

# 2. Enable debug mode
claude --debug

# 3. Check which settings are loaded
tail -f ~/.claude/debug.log | grep settings

# 4. Verify file locations
ls -la ~/.claude/settings.json
ls -la .claude/settings.json
```

**Solutions:**

```bash
# 1. Fix JSON syntax errors
# Use json.tool to validate

# 2. Check file permissions
chmod 644 .claude/settings.json

# 3. Load specific settings source
claude --setting-sources 'project'

# 4. Validate configuration
claude
> /doctor
```

### Hooks Not Executing

**Symptoms:**
- Hook scripts not running
- Expected side effects not happening

**Diagnosis:**

```bash
# 1. Check hook configuration
cat .claude/hooks.json
python3 -m json.tool .claude/hooks.json

# 2. Verify script is executable
ls -l ~/.claude/hooks/script.sh

# 3. Test hook manually
echo '{"tool_name":"Bash","tool_input":{"command":"test"}}' | ~/.claude/hooks/script.sh
echo $?  # Should be 0, 1, or 2

# 4. Check debug logs
claude --debug
tail -f ~/.claude/debug.log | grep hook
```

**Solutions:**

```bash
# 1. Make script executable
chmod +x ~/.claude/hooks/script.sh

# 2. Verify shebang
head -1 ~/.claude/hooks/script.sh
# Should be #!/usr/bin/env bash or python3

# 3. Test matcher pattern
# Ensure pattern matches tool name

# 4. Check for script errors
bash -x ~/.claude/hooks/script.sh < test-input.json
```

## Plugin Issues

### Plugin Not Loading

**Symptoms:**
- Plugin commands unavailable
- Plugin features not working

**Diagnosis:**

```bash
# 1. List installed plugins
/plugin list

# 2. Check plugin is enabled
# Look for enabled: true

# 3. Validate plugin structure
/plugin validate /path/to/plugin

# 4. Check debug logs
claude --debug
tail -f ~/.claude/debug.log | grep plugin
```

**Solutions:**

```bash
# 1. Enable plugin
/plugin enable plugin-name

# 2. Reinstall plugin
/plugin install plugin-name@marketplace

# 3. Validate plugin structure
cd /path/to/plugin
/plugin validate .

# 4. Check plugin.json syntax
python3 -m json.tool .claude-plugin/plugin.json
```

### Marketplace Not Found

**Symptoms:**
- Cannot install plugins from marketplace
- "Marketplace not found" errors

**Solutions:**

```bash
# 1. List known marketplaces
/plugin marketplace list

# 2. Add marketplace
/plugin marketplace add owner/repo

# 3. For local development
/plugin marketplace add ./path/to/marketplace

# 4. Check marketplace structure
ls -la /path/to/marketplace/.claude-plugin/marketplace.json
```

## Git Integration Issues

### Git Commands Failing

**Symptoms:**
- Commit creation fails
- PR creation errors

**Diagnosis:**

```bash
# 1. Check git is installed
which git
git --version

# 2. Check gh CLI for PR creation
which gh
gh --version
gh auth status

# 3. Verify git configuration
git config --global user.name
git config --global user.email
```

**Solutions:**

```bash
# 1. Install gh CLI if missing
brew install gh  # macOS
# or follow: https://cli.github.com/

# 2. Authenticate gh
gh auth login

# 3. Set git config
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# 4. Check repository permissions
git remote -v
gh repo view
```

## Platform-Specific Issues

### Windows Path Issues

**Symptoms:**
- File paths not resolving
- "File not found" errors on Windows

**Solution:**

```bash
# Use POSIX path format
//c/Users/username/file.txt

# Not Windows format
C:\Users\username\file.txt
```

### WSL Issues

**Symptoms:**
- Tools not found in WSL
- Permission errors

**Solutions:**

```bash
# 1. Ensure tools installed in WSL, not Windows
which node npm git

# 2. Install missing tools
sudo apt update
sudo apt install nodejs npm git

# 3. Use WSL paths, not Windows paths
/home/username/project
# Not /mnt/c/Users/username/project
```

### macOS Rosetta Issues

**Symptoms:**
- Performance issues on Apple Silicon
- Architecture mismatch errors

**Solutions:**

```bash
# 1. Check architecture
uname -m  # Should be arm64 on Apple Silicon

# 2. Install native version
# Reinstall Claude Code for arm64

# 3. For x86 dependencies
arch -x86_64 npm install
```

## Debug Workflow

### Systematic Debugging Process

```bash
# 1. Enable debug mode
claude --debug

# 2. Reproduce the issue
# Perform the action that fails

# 3. Review debug logs
tail -50 ~/.claude/debug.log

# 4. Search for specific errors
grep -i error ~/.claude/debug.log
grep -i permission ~/.claude/debug.log
grep -i mcp ~/.claude/debug.log

# 5. Validate configuration
cat .claude/settings.json | python3 -m json.tool

# 6. Check tool access
/doctor

# 7. Test in isolation
# Create minimal reproduction case

# 8. Check official docs
# Visit https://docs.claude.com/en/docs/claude-code/
```

## Getting Help

### Information to Include

When seeking help, gather:

```bash
# 1. Claude Code version
claude --version

# 2. Operating system
uname -a  # Unix/macOS
ver  # Windows

# 3. Debug logs (last 50 lines)
tail -50 ~/.claude/debug.log

# 4. Configuration (sanitized)
cat .claude/settings.json  # Remove secrets first

# 5. Reproduction steps
# Exact commands that cause the issue

# 6. Error messages
# Complete error output
```

### Support Channels

- GitHub Issues: https://github.com/anthropics/claude-code/issues
- Documentation: https://docs.claude.com/en/docs/claude-code/
- Community: Search existing issues for similar problems

## Common Error Messages

### "Invalid API key"

```bash
export ANTHROPIC_API_KEY=sk-ant-your-key-here
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.zshrc
```

### "Permission denied for tool X"

```json
{
  "permissions": {
    "allow": ["X"]
  }
}
```

### "Context window exceeded"

```bash
/compact
# or
/clear
```

### "MCP server not responding"

```bash
claude mcp remove server-name
claude mcp add --transport http server-name <url>
/mcp  # Re-authenticate if needed
```

### "Hook timed out"

Increase timeout in hooks.json:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "slow-script.sh",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

### "File not found" (Bash commands)

```bash
# Use absolute paths
/usr/bin/python3 script.py

# Or set PATH in env
{
  "env": {
    "PATH": "/usr/local/bin:/usr/bin:/bin"
  }
}
```
