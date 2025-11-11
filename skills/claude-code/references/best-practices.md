# Best Practices

Recommended workflows and optimization strategies for Claude Code.

## Project Setup

### Initialize Claude Code Configuration

```bash
# 1. Create project configuration directory
mkdir -p .claude

# 2. Create settings.json with project-specific permissions
cat > .claude/settings.json << 'EOF'
{
  "permissions": {
    "allow": [
      "Read(**/*.{js,ts,tsx,json,md})",
      "Edit(**/*.{js,ts,tsx})",
      "Bash(npm run:*)",
      "Bash(git:*)"
    ],
    "deny": [
      "Read(.env*)",
      "Read(**/secrets/**)",
      "Bash(rm -rf:*)"
    ]
  }
}
EOF

# 3. Add local overrides to .gitignore
cat >> .gitignore << 'EOF'

# Claude Code local configuration
.claude/settings.local.json
.claude/*.log
EOF

# 4. Create CLAUDE.md for project-specific instructions
cat > CLAUDE.md << 'EOF'
# Project Guidelines

## Architecture

[Describe your project structure]

## Coding Standards

[Team conventions and patterns]

## Testing

[Testing requirements and commands]

## Deployment

[Deployment process and constraints]
EOF

# 5. Commit project configuration
git add .claude/settings.json CLAUDE.md .gitignore
git commit -m "Add Claude Code project configuration"
```

### Team Onboarding

```markdown
# .claude/README.md

## Claude Code Setup

### Prerequisites
- Claude Code installed: `npm install -g @anthropic-ai/claude-code`
- API key set: `export ANTHROPIC_API_KEY=sk-ant-...`

### Configuration
This project uses Claude Code with:
- Auto-approved: npm scripts, git commands, read/edit TS files
- Blocked: Environment files, destructive commands

### Recommended First Steps
1. `claude` - Start Claude Code session
2. Ask: "Give me an overview of this codebase"
3. Ask: "What's the testing strategy?"
4. Ask: "Show me how to run this locally"
```

## Model Selection Strategy

### Task-Based Model Selection

```bash
# Haiku: Fast, economical
# Use for: Simple edits, quick questions, refactoring
claude --model haiku "fix the typo in README"
claude --model haiku "run the tests and show me results"

# Sonnet: Balanced (default)
# Use for: Feature development, debugging, code review
claude "implement user authentication"
claude "debug the failing integration test"

# Opus: Most capable, expensive
# Use for: Complex architecture, novel algorithms, deep analysis
claude --model opus "design a distributed caching system"
claude --model opus "analyze this for security vulnerabilities"
```

### Switching Models Mid-Session

```bash
# Start with Sonnet for implementation
claude "implement the user service"

# Switch to Haiku for quick iteration
/model haiku
> "run the linter and fix issues"

# Switch to Opus for complex design decision
/model opus
> "should we use event sourcing or CQRS for this?"
```

## Context Management

### Proactive Context Control

```bash
# Start of session: Add key directories
/add-dir src/core
/add-dir src/services
/add-dir tests

# Check context usage regularly
/context

# Compact when approaching limits
/compact

# Clear and save state for long projects
> "Summarize what we've implemented so far"
/clear
# Paste summary as first message of new session
```

### Effective Context Loading

```bash
# ❌ Poor: Load everything upfront
> "Read all files in src/"

# ✅ Better: Load as needed
> "Find the authentication logic"
> "Now read the file you found"

# ✅ Better: Use specific patterns
> "Search for API endpoints in src/"

# ✅ Better: Let Claude explore
> "How does user registration work?"
# Claude will read only necessary files
```

## Permission Strategy

### Progressive Permission Model

```json
// Start restrictive
{
  "permissions": {
    "allow": [
      "Read(**/*.ts)"
    ],
    "deny": [
      "Bash(*)",
      "Edit(*)"
    ]
  }
}

// Add permissions as needed
{
  "permissions": {
    "allow": [
      "Read(**/*.ts)",
      "Edit(src/**/*.ts)",  // After reviewing changes
      "Bash(npm test:*)"    // After verifying test suite
    ]
  }
}

// Final production configuration
{
  "permissions": {
    "allow": [
      "Read(**/*.{ts,tsx,json,md})",
      "Edit(src/**/*.{ts,tsx})",
      "Bash(npm run:*)",
      "Bash(git:*)"
    ],
    "deny": [
      "Read(.env*)",
      "Edit(package.json)",  // Require approval for deps
      "Bash(npm publish:*)"  // Never auto-publish
    ]
  }
}
```

### Environment-Specific Permissions

```json
// Development (.claude/settings.local.json)
{
  "permissions": {
    "allow": [
      "Bash(docker:*)",
      "Bash(curl:*)"
    ]
  },
  "permissionMode": "acceptEdits"
}

// CI/CD (.claude/settings.json)
{
  "permissions": {
    "allow": [
      "Read(**/*)",
      "Bash(npm run test)",
      "Bash(npm run build)"
    ],
    "deny": [
      "Edit(**/*)",
      "Bash(git push:*)",
      "Bash(npm publish:*)"
    ]
  },
  "permissionMode": "plan"
}

// Production (managed-settings.json)
{
  "deniedMcpServers": [
    { "serverName": "filesystem" }
  ],
  "permissions": {
    "deny": [
      "Bash(curl:*)",
      "Bash(wget:*)",
      "Read(~/.ssh/**)"
    ]
  }
}
```

## Git Workflow

### Effective Commit Messages

```bash
# ❌ Poor: Vague instruction
> "commit my changes"

# ✅ Better: Provide context
> "commit these changes - we added rate limiting to the API"

# ✅ Better: Let Claude analyze
> "review the changes and create an appropriate commit"
# Claude will read git diff and craft descriptive message

# ✅ Best: Structured workflow
> "create a commit for the authentication changes, then create a PR"
# Claude will:
# 1. Review git status and diff
# 2. Create descriptive commit
# 3. Push to origin
# 4. Create PR with summary
```

### Branch Management

```bash
# ❌ Poor: Manual branch creation
> "create a branch called feature-auth"

# ✅ Better: Let Claude name appropriately
> "create a feature branch for user authentication"
# Claude will create: feature/user-authentication or similar

# ✅ Better: Include issue tracking
> "create a branch for fixing issue #123"
# Claude will create: fix/issue-123 or bugfix/issue-123
```

## MCP Server Usage

### Strategic MCP Integration

```bash
# Add only needed MCP servers
# Don't add every available server

# ✅ Good: Project-relevant servers
claude mcp add --transport http github https://api.githubcopilot.com/mcp/
claude mcp add --transport stdio db -- npx -y @bytebase/dbhub --dsn "..."

# ❌ Avoid: Unused servers
# Adding servers you won't use increases complexity
```

### MCP Server Scoping

```bash
# User-level: Tools you use across all projects
claude mcp add --transport http github https://api.githubcopilot.com/mcp/

# Project-level: Project-specific integrations
claude mcp add --transport stdio project-db --scope project \
  -- npx -y @bytebase/dbhub --dsn "${PROJECT_DB_URL}"
```

### MCP Permission Strategy

```json
{
  "permissions": {
    "allow": [
      // Approve entire trusted server
      "mcp__github",

      // Or specific tools only
      "mcp__db__query",
      "mcp__db__get_schema"
    ],
    "deny": [
      // Block dangerous tools even from trusted server
      "mcp__db__execute_raw",
      "mcp__db__drop_table"
    ]
  }
}
```

## Hook Best Practices

### Auto-Formatting

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/format.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

### Pre-Commit Validation

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/validate-commit.sh"
          }
        ]
      }
    ]
  }
}
```

### Testing After Changes

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/run-related-tests.sh",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```

## Cost Optimization

### Token Management

```bash
# 1. Use compact frequently for long sessions
/compact

# 2. Use faster models when appropriate
/model haiku

# 3. Be specific in queries
# ❌ "tell me about this codebase" (reads many files)
# ✅ "what does src/auth/login.ts do?" (reads one file)

# 4. Set budget limits
claude --max-budget-usd 5.00

# 5. Monitor costs
/cost
/usage
```

### Efficient Tool Usage

```bash
# ❌ Inefficient: Multiple reads
> "read src/utils/helper.ts"
> "read src/utils/format.ts"
> "read src/utils/validate.ts"

# ✅ Efficient: Pattern-based read
> "read all utility files in src/utils/"

# ❌ Inefficient: Sequential operations
> "run tests"
> "run linter"
> "run build"

# ✅ Efficient: Parallel or chained
> "run tests, linter, and build in sequence"
```

## CLAUDE.md Guidelines

### Essential Project Information

```markdown
# CLAUDE.md

## Project Overview
[2-3 sentence description of what this project does]

## Architecture
- Framework: Next.js 14
- Database: PostgreSQL via Prisma
- API: tRPC
- Testing: Vitest + Playwright

## Key Conventions
- All API routes use tRPC procedures
- Database mutations require transactions
- UI components use shadcn/ui
- Forms use react-hook-form + zod

## Critical Constraints
- ❌ NEVER commit .env files
- ❌ NEVER modify database schema without migration
- ✅ ALWAYS write tests for new features
- ✅ ALWAYS run type check before committing

## Development Workflow
1. Create feature branch: `git checkout -b feature/name`
2. Implement with tests
3. Run: `npm run typecheck && npm test && npm run build`
4. Create PR with description

## Deployment
- Staging: Auto-deploy on push to `develop`
- Production: Manual deploy from `main` via GitHub Actions
- Requires: All CI checks passing + 1 approval
```

### Anti-Patterns to Avoid

```markdown
# ❌ Don't: Dump configuration files
# This clutters context and isn't actionable

# ❌ Don't: Provide Claude Code instructions
# Claude already knows how to use itself

# ✅ Do: Provide project-specific guidance
# Architecture, conventions, constraints

# ✅ Do: Document gotchas
# "Database uses soft deletes - check deleted_at column"

# ✅ Do: Link to relevant documentation
# "See docs/api.md for endpoint conventions"
```

## Session Management

### Short Sessions

```bash
# For quick tasks: single session
claude "fix the typo in README and commit"
```

### Long Feature Development

```bash
# Session 1: Planning
claude "analyze the codebase for implementing user roles"
# End with summary

# Session 2: Implementation
claude --resume <id>
# Or start fresh and provide summary
claude "implement user roles based on this plan: ..."

# Session 3: Testing & refinement
claude --continue
```

### Resuming Effectively

```bash
# ❌ Poor: Resume without context
claude --resume abc123
> "continue"

# ✅ Better: Resume with reminder
claude --resume abc123
> "we were implementing user roles. Continue with the authorization middleware"

# ✅ Best: Save state before ending
> "summarize what we've done and what's left"
/exit
# Copy summary for next session
```

## Testing Strategy

### Test-Driven Development

```bash
# 1. Describe requirements
> "we need a function to validate email addresses"

# 2. Ask for tests first
> "write comprehensive tests for email validation"

# 3. Implement to pass tests
> "implement the email validation function to pass these tests"

# 4. Verify
> "run the tests"
```

### Iterative Testing

```bash
# After implementation
> "write tests for the authentication service"
> "run the tests"

# If failures
> "fix the failing tests"

# Coverage check
> "check test coverage for src/auth/"
```

## Documentation Workflow

### Code Documentation

```bash
# ❌ Poor: Generic request
> "add documentation"

# ✅ Better: Specific request
> "add JSDoc comments to all exported functions in src/api/"

# ✅ Better: With context
> "these functions lack documentation. Add clear JSDoc with examples"
```

### API Documentation

```bash
# Generate from code
> "generate API documentation for all tRPC procedures"

# Keep in sync
> "update docs/api.md to match the current tRPC procedures"
```

## Debugging Workflow

### Systematic Debugging

```bash
# 1. Reproduce the issue
> "run the failing test"

# 2. Analyze the error
> "read the error message and identify the root cause"

# 3. Investigate
> "read the relevant source files"

# 4. Fix
> "fix the issue"

# 5. Verify
> "run the tests again"

# 6. Regression prevention
> "add a test to prevent this from happening again"
```

### Production Debugging

```bash
# With Sentry MCP
> "what are the most common errors in the last 24 hours?"
> "show me the stack trace for error ID abc123"
> "which deployment introduced these errors?"
```

## Security Best Practices

### Sensitive Data Protection

```json
{
  "permissions": {
    "deny": [
      "Read(.env*)",
      "Read(**/secrets/**)",
      "Read(~/.ssh/**)",
      "Read(~/.aws/credentials)",
      "Read(.envrc)"
    ]
  }
}
```

### Pre-Deployment Checks

```bash
# Hook to prevent secret commits
# .claude/hooks/check-secrets.sh

#!/usr/bin/env bash
input=$(cat)

# Extract files being committed
files=$(git diff --cached --name-only)

# Check for secrets
if echo "$files" | grep -q "\.env"; then
  echo "❌ Attempting to commit .env file" >&2
  exit 2
fi

# Check file contents for API keys
for file in $files; do
  if grep -q "sk-[a-zA-Z0-9]\{32,\}" "$file" 2>/dev/null; then
    echo "❌ Possible API key found in $file" >&2
    exit 2
  fi
done

exit 0
```

## Collaboration Best Practices

### Shared Settings

```bash
# Project: .claude/settings.json (committed)
{
  "permissions": {
    "allow": ["Bash(npm run:*)", "Bash(git:*)"],
    "deny": ["Read(.env*)"]
  }
}

# Personal: .claude/settings.local.json (gitignored)
{
  "env": {
    "DATABASE_URL": "postgresql://localhost/mydb"
  },
  "permissionMode": "acceptEdits"
}
```

### Team Guidelines

```markdown
# docs/claude-code-guide.md

## Team Standards for Claude Code

### Before Committing
1. Run: `npm run typecheck && npm test`
2. Review changes: `git diff`
3. Use Claude to generate commit message

### Pull Requests
1. Use Claude to create PR: `> "create a PR for this feature"`
2. Include test coverage report
3. Request review from @team

### Testing
- All new features require tests
- Use Claude: `> "write tests for this feature"`
- Aim for >80% coverage
```

## Continuous Improvement

### Iterative Configuration

```bash
# Start simple
{
  "permissions": {
    "allow": ["Read(**/*.ts)"]
  }
}

# Add based on actual usage
# After Claude requests Edit permission several times:
{
  "permissions": {
    "allow": [
      "Read(**/*.ts)",
      "Edit(src/**/*.ts)"
    ]
  }
}

# Refine with deny list
{
  "permissions": {
    "allow": [
      "Read(**/*.ts)",
      "Edit(src/**/*.ts)"
    ],
    "deny": [
      "Edit(src/config/production.ts)"
    ]
  }
}
```

### Feedback Loop

```bash
# After each session, reflect:
# 1. What worked well?
# 2. What was slow or inefficient?
# 3. What permissions should be adjusted?
# 4. What hooks would be helpful?

# Update configuration accordingly
```
