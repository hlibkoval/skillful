---
name: gitlab
description: Work with GitLab repositories, MRs, pipelines, and issue tracking on GitLab.com and self-managed instances using glab CLI. Use to create, view, and manage merge requests, issues, CI/CD pipelines, and releases.
---

# GitLab Workflow with glab CLI

This skill provides comprehensive guidance for working with GitLab repositories using the `glab` CLI tool. It supports both GitLab.com and self-managed GitLab instances, covering merge requests, issues, CI/CD pipelines, and releases.

**Prerequisites**: This skill assumes `glab` CLI is installed and authenticated. Users should have already configured authentication with their GitLab instance(s) before using this skill.

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

## Important Considerations

### GitLab.com vs Self-Managed Instances

**Automatic Instance Detection**: When inside a git repository with a GitLab remote, glab automatically detects which instance to use. This is the preferred method.

**Manual Instance Override**: For operations outside a repository, use the `GITLAB_HOST` environment variable:

```bash
GITLAB_HOST=gitlab.example.com glab issue list -R group/project
```

**Version Compatibility**: glab officially supports GitLab 16.0+. Earlier versions may have compatibility issues.

### Best Practices

1. **Leverage automatic instance detection**: Work inside git repositories whenever possible
2. **Check pipeline status early**: Use `glab ci view` proactively to catch failures quickly
3. **Use draft MRs for WIP**: Create draft merge requests to signal incomplete work
4. **Use descriptive labels**: Tag MRs and issues with relevant labels for organization
5. **Review diffs before merging**: Always review changes with `glab mr view` or `glab mr diff`

## Example Workflow

```bash
# 1. Check what MRs are assigned to me
glab mr list --assignee=@me

# 2. Create a new MR for current branch
glab mr create --title "Add user authentication" --description "Implements OAuth2 flow" --label feature

# 3. Check pipeline status for the MR
glab ci view

# 4. If pipeline fails, check logs
glab ci trace <job-id>

# 5. After fixes, get MR approved
glab mr approve <mr-number>

# 6. Merge when ready
glab mr merge <mr-number>
```

## Additional Resources

- Official glab documentation: https://gitlab.com/gitlab-org/cli
- GitLab CI/CD documentation: https://docs.gitlab.com/ee/ci/
- GitLab API documentation: https://docs.gitlab.com/ee/api/

For detailed command references and advanced workflows, load the bundled `references/` files as needed.
