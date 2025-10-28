---
name: gitlab
description: Use when working with GitLab repositories (cloud or self-managed) - provides workflows for creating MRs, managing issues, checking pipelines, and using glab CLI correctly, including authentication verification and instance detection
---

# GitLab Workflow with glab CLI

This skill provides comprehensive guidance for working with GitLab repositories using the `glab` CLI tool. It supports both GitLab.com and self-managed GitLab instances, covering merge requests, issues, CI/CD pipelines, and proper authentication workflows.

## When to Use This Skill

Invoke this skill when:
- Creating, reviewing, or managing GitLab merge requests
- Working with GitLab issues and project management
- Checking pipeline status or debugging CI/CD failures
- Configuring glab for GitLab.com or self-managed instances
- Troubleshooting glab authentication or instance detection
- Setting up GitLab workflows in CI/CD environments
- Managing releases or working with GitLab Duo AI features

## Prerequisites and Installation

### Check glab Installation

Before proceeding with any GitLab workflows, verify that glab is installed and accessible:

```bash
which glab
glab --version
```

If glab is not installed, install it based on the platform:
- **macOS**: `brew install glab`
- **Linux**: Download from GitLab CLI releases or use package manager
- **Windows**: Use Scoop, Chocolatey, or download binary

### Minimum Requirements

- **glab CLI**: Latest version recommended
- **GitLab Version**: 16.0 or later (self-managed instances)
- **Required Token Scopes**: `api`, `write_repository` (for personal access tokens)

## Authentication Workflow

Authentication is the foundation of glab workflows. Always verify authentication before attempting operations.

### Verify Authentication Status

Use the bundled authentication verification script:

```bash
scripts/verify-glab-auth.sh
```

This script checks:
1. glab installation status
2. Current authentication state
3. GitLab instance detection (from git remote or config)
4. Token validity and scopes

### Authentication Methods

#### OAuth (Recommended for GitLab.com)

```bash
glab auth login
```

Follow the browser-based OAuth flow. OAuth tokens are scoped and can be revoked centrally, providing better security than long-lived personal access tokens.

#### Personal Access Token

For automation or when OAuth is not available:

```bash
# Interactive
glab auth login

# Non-interactive (for CI/CD)
echo "your-token-here" | glab auth login --stdin
```

Required scopes: `api`, `write_repository`

#### Self-Managed Instance OAuth

Self-managed and GitLab Dedicated instances require pre-configured OAuth applications:
1. Create OAuth application in GitLab admin settings
2. Set redirect URI: `http://localhost:7171/auth/redirect`
3. Set scopes: `openid`, `profile`, `read_user`, `write_repository`, `api`
4. Run `glab auth login` and follow prompts

#### CI Job Token (Automatic)

Within GitLab CI pipelines, glab automatically authenticates using the `CI_JOB_TOKEN` environment variable. No manual authentication needed.

### Instance Detection

**Automatic Detection**: When inside a git repository with a GitLab remote, glab automatically detects which instance to use. This is the preferred method as it requires no manual configuration.

**Manual Configuration**: For operations outside a repository or to set a default instance:

```bash
# Set default host globally
glab config set -g host gitlab.example.com

# Verify current configuration
glab config get host
```

**Environment Override**: Use `GITLAB_HOST` environment variable for one-off commands:

```bash
GITLAB_HOST=gitlab.example.com glab issue list -R group/project
```

## Core Workflows

### Merge Request Workflows

#### Creating a Merge Request

```bash
# Create MR with defaults (opens editor for description)
glab mr create

# Create MR with inline details
glab mr create --title "Fix authentication bug" --description "Resolves #123" --label bug,urgent

# Create draft MR
glab mr create --draft --title "WIP: New feature"

# Target specific branch
glab mr create --source feature-branch --target development
```

#### Listing and Viewing MRs

```bash
# List MRs assigned to me
glab mr list --assignee=@me

# List all open MRs
glab mr list

# View specific MR details
glab mr view 42

# View MR in browser
glab mr view 42 --web
```

#### Reviewing and Approving MRs

```bash
# Approve an MR
glab mr approve 42

# Add review comment
glab mr note 42 --message "LGTM, just one minor suggestion"

# Check out MR locally for testing
glab mr checkout 42

# Merge an MR
glab mr merge 42

# Merge with squash
glab mr merge 42 --squash
```

### Issue Management

```bash
# Create an issue
glab issue create --title "Bug in login flow" --description "Users cannot log in with OAuth" --label bug

# List open issues
glab issue list

# View issue details
glab issue view 123

# Close an issue
glab issue close 123

# Reopen an issue
glab issue reopen 123
```

### CI/CD Pipeline Management

```bash
# View latest pipeline status
glab ci view

# List recent pipelines
glab ci list

# View specific pipeline
glab ci view --pipeline-id 12345

# Retry failed jobs
glab ci retry 12345

# View job logs
glab ci trace <job-id>
```

### Release Management

```bash
# Create a release
glab release create v1.0.0 --notes "Initial release"

# List releases
glab release list

# View specific release
glab release view v1.0.0
```

### GitLab Duo AI Integration

```bash
# Ask GitLab Duo for git help
glab duo ask "How do I squash the last 3 commits?"

# Get command suggestions
glab duo ask "How to rebase my feature branch onto main?"
```

## Bundled Resources

### References

For detailed command syntax, flags, and advanced usage patterns, load the bundled reference files as needed:

- **`references/glab-commands.md`**: Comprehensive command reference organized by category (auth, mr, issue, ci, release, config) with syntax and examples
- **`references/workflows.md`**: Step-by-step workflows for common tasks including MR approval flows, pipeline debugging, and multi-instance patterns

To load a reference file into context:

```bash
cat references/glab-commands.md
```

### Scripts

- **`scripts/verify-glab-auth.sh`**: Authentication verification and troubleshooting script that checks installation, auth status, and instance detection

## Important Considerations

### GitLab.com vs Self-Managed

**Default Behavior**: When outside a git repository, glab defaults to GitLab.com unless configured otherwise.

**Instance Override**: Always prefer automatic instance detection (from git remote) over manual configuration. Only use manual configuration when working outside repositories or setting organization-wide defaults.

**Version Compatibility**: glab officially supports GitLab 16.0+. Earlier versions may have compatibility issues.

### Common Troubleshooting

#### Authentication Issues

1. Run `scripts/verify-glab-auth.sh` to diagnose the problem
2. Check token scopes include `api` and `write_repository`
3. Verify instance host configuration matches git remote
4. For self-managed instances, confirm OAuth app is properly configured

#### Instance Detection Issues

1. Verify git remote URL points to correct GitLab instance: `git remote -v`
2. Check global host configuration: `glab config get host`
3. Use `GITLAB_HOST` environment variable to override if needed

#### Command Not Found Errors

1. Ensure glab is installed: `which glab`
2. Check PATH includes glab installation directory
3. Restart terminal after installation

### Best Practices

1. **Leverage automatic instance detection**: Work inside git repositories whenever possible to avoid manual configuration
2. **Use OAuth for interactive work**: More secure than long-lived personal access tokens
3. **Use tokens for automation**: Personal access tokens or CI job tokens for scripts and pipelines
4. **Verify authentication first**: Always check auth status before debugging other issues
5. **Check pipeline status early**: Use `glab ci view` proactively to catch failures quickly
6. **Use draft MRs for WIP**: Create draft merge requests for work-in-progress to signal incomplete status

## Example Session

```bash
# 1. Verify authentication and instance
scripts/verify-glab-auth.sh

# 2. Check what MRs are assigned to me
glab mr list --assignee=@me

# 3. Create a new MR for my current branch
glab mr create --title "Add user authentication" --description "Implements OAuth2 flow" --label feature

# 4. Check pipeline status for the MR
glab ci view

# 5. If pipeline fails, check logs
glab ci trace <job-id>

# 6. After fixes, get MR approved
glab mr approve <mr-number>

# 7. Merge when ready
glab mr merge <mr-number>
```

## Additional Resources

- Official glab documentation: https://gitlab.com/gitlab-org/cli
- GitLab CI/CD documentation: https://docs.gitlab.com/ee/ci/
- GitLab API documentation: https://docs.gitlab.com/ee/api/

For detailed command references and advanced workflows, load the bundled `references/` files as needed.
