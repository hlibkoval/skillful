# glab CLI Command Reference

This reference provides comprehensive documentation for glab CLI commands, organized by functional category.

## Command Structure

All glab commands follow this pattern:

```
glab <command> <subcommand> [flags]
```

## Authentication Commands (`glab auth`)

### `glab auth login`

Authenticate with a GitLab instance using OAuth or personal access token.

**Syntax:**
```bash
glab auth login [flags]
```

**Common Flags:**
- `--hostname <host>`: GitLab instance hostname (e.g., gitlab.example.com)
- `--stdin`: Read token from standard input
- `--web`: Use web-based OAuth flow (default for GitLab.com)

**Examples:**
```bash
# OAuth login to GitLab.com
glab auth login

# Login to self-managed instance
glab auth login --hostname gitlab.example.com

# Non-interactive login with token
echo "glpat-xxxxxxxxxxxx" | glab auth login --stdin

# Login to specific instance with token
echo "glpat-xxxxxxxxxxxx" | glab auth login --hostname gitlab.example.com --stdin
```

### `glab auth status`

Display authentication status for current or all GitLab instances.

**Syntax:**
```bash
glab auth status [flags]
```

**Common Flags:**
- `--hostname <host>`: Check specific instance
- `--show-token`: Display the authentication token (use carefully)

**Examples:**
```bash
# Check current auth status
glab auth status

# Check specific instance
glab auth status --hostname gitlab.example.com

# Show token (for debugging)
glab auth status --show-token
```

### `glab auth logout`

Remove authentication credentials for a GitLab instance.

**Syntax:**
```bash
glab auth logout [flags]
```

**Common Flags:**
- `--hostname <host>`: Logout from specific instance

**Examples:**
```bash
# Logout from current instance
glab auth logout

# Logout from specific instance
glab auth logout --hostname gitlab.example.com
```

## Merge Request Commands (`glab mr`)

### `glab mr create`

Create a new merge request.

**Syntax:**
```bash
glab mr create [flags]
```

**Common Flags:**
- `-t, --title <title>`: MR title
- `-d, --description <desc>`: MR description
- `-l, --label <labels>`: Comma-separated labels
- `-a, --assignee <users>`: Comma-separated assignees
- `-r, --reviewer <users>`: Comma-separated reviewers
- `-m, --milestone <milestone>`: Milestone name or ID
- `--draft`: Create as draft/WIP
- `--source-branch <branch>`: Source branch (default: current)
- `--target-branch <branch>`: Target branch (default: default branch)
- `--remove-source-branch`: Delete source branch after merge
- `--squash`: Squash commits when merging
- `--no-editor`: Don't open editor for description
- `-f, --fill`: Fill description from commits
- `-w, --web`: Open MR in browser after creation

**Examples:**
```bash
# Create MR with editor for description
glab mr create --title "Add user authentication"

# Create MR with all details inline
glab mr create -t "Fix login bug" -d "Resolves #123" -l bug,urgent -a @user1 -r @user2

# Create draft MR
glab mr create --draft -t "WIP: New dashboard"

# Create MR with auto-filled description from commits
glab mr create --fill

# Create MR targeting specific branch
glab mr create -t "Hotfix" --target-branch production

# Create MR that auto-deletes source branch and squashes commits
glab mr create -t "Feature X" --remove-source-branch --squash
```

### `glab mr list`

List merge requests.

**Syntax:**
```bash
glab mr list [flags]
```

**Common Flags:**
- `-a, --assignee <user>`: Filter by assignee (use `@me` for current user)
- `-A, --author <user>`: Filter by author
- `-r, --reviewer <user>`: Filter by reviewer
- `-l, --label <labels>`: Filter by labels
- `-m, --milestone <milestone>`: Filter by milestone
- `-s, --state <state>`: Filter by state (opened, closed, merged, all)
- `--draft`: Show only draft MRs
- `--not-label <labels>`: Exclude labels
- `-P, --per-page <number>`: Number of items per page
- `--source-branch <branch>`: Filter by source branch
- `--target-branch <branch>`: Filter by target branch

**Examples:**
```bash
# List MRs assigned to me
glab mr list --assignee=@me

# List all open MRs
glab mr list

# List MRs I authored
glab mr list --author=@me

# List merged MRs
glab mr list --state=merged

# List MRs with specific label
glab mr list --label=bug

# List draft MRs
glab mr list --draft

# List MRs targeting main branch
glab mr list --target-branch=main
```

### `glab mr view`

View merge request details.

**Syntax:**
```bash
glab mr view [<id>] [flags]
```

**Common Flags:**
- `-w, --web`: Open in browser
- `-c, --comments`: Show comments
- `-s, --system-logs`: Show system logs/events

**Examples:**
```bash
# View MR #42 in terminal
glab mr view 42

# View MR in browser
glab mr view 42 --web

# View with comments
glab mr view 42 --comments

# View current branch's MR
glab mr view

# View with system events
glab mr view 42 --system-logs
```

### `glab mr approve`

Approve a merge request.

**Syntax:**
```bash
glab mr approve [<id>] [flags]
```

**Examples:**
```bash
# Approve MR #42
glab mr approve 42

# Approve current branch's MR
glab mr approve
```

### `glab mr merge`

Merge a merge request.

**Syntax:**
```bash
glab mr merge [<id>] [flags]
```

**Common Flags:**
- `--squash`: Squash commits
- `--remove-source-branch`: Delete source branch after merge
- `--when-pipeline-succeeds`: Merge when pipeline succeeds
- `--auto-merge`: Enable auto-merge
- `-y, --yes`: Skip confirmation

**Examples:**
```bash
# Merge MR #42
glab mr merge 42

# Merge with squash
glab mr merge 42 --squash

# Merge and remove source branch
glab mr merge 42 --remove-source-branch

# Auto-merge when pipeline succeeds
glab mr merge 42 --when-pipeline-succeeds

# Merge without confirmation
glab mr merge 42 --yes
```

### `glab mr checkout`

Check out merge request locally.

**Syntax:**
```bash
glab mr checkout <id> [flags]
```

**Common Flags:**
- `-b, --branch <name>`: Custom local branch name

**Examples:**
```bash
# Checkout MR #42
glab mr checkout 42

# Checkout with custom branch name
glab mr checkout 42 --branch review-feature-x
```

### `glab mr close`

Close a merge request.

**Syntax:**
```bash
glab mr close [<id>] [flags]
```

**Examples:**
```bash
# Close MR #42
glab mr close 42

# Close current branch's MR
glab mr close
```

### `glab mr reopen`

Reopen a closed merge request.

**Syntax:**
```bash
glab mr reopen [<id>] [flags]
```

**Examples:**
```bash
# Reopen MR #42
glab mr reopen 42
```

### `glab mr note`

Add a comment/note to a merge request.

**Syntax:**
```bash
glab mr note <id> [flags]
```

**Common Flags:**
- `-m, --message <text>`: Comment message

**Examples:**
```bash
# Add comment to MR #42
glab mr note 42 --message "LGTM! Great work."

# Add multi-line comment
glab mr note 42 --message "Changes look good.

Please update the changelog before merging."
```

### `glab mr update`

Update merge request properties.

**Syntax:**
```bash
glab mr update <id> [flags]
```

**Common Flags:**
- `-t, --title <title>`: Update title
- `-d, --description <desc>`: Update description
- `-l, --label <labels>`: Set labels (replaces existing)
- `-a, --assignee <users>`: Set assignees
- `--lock-discussion`: Lock discussion
- `--unlock-discussion`: Unlock discussion
- `--ready`: Mark as ready (remove draft status)
- `--draft`: Mark as draft

**Examples:**
```bash
# Update title
glab mr update 42 --title "New title"

# Add labels (replaces existing)
glab mr update 42 --label bug,urgent,security

# Mark as ready
glab mr update 42 --ready

# Mark as draft
glab mr update 42 --draft

# Lock discussion
glab mr update 42 --lock-discussion
```

## Issue Commands (`glab issue`)

### `glab issue create`

Create a new issue.

**Syntax:**
```bash
glab issue create [flags]
```

**Common Flags:**
- `-t, --title <title>`: Issue title
- `-d, --description <desc>`: Issue description
- `-l, --label <labels>`: Comma-separated labels
- `-a, --assignee <users>`: Comma-separated assignees
- `-m, --milestone <milestone>`: Milestone name or ID
- `--confidential`: Mark as confidential
- `-w, --web`: Open in browser after creation

**Examples:**
```bash
# Create issue with editor
glab issue create --title "Login page broken"

# Create issue with all details
glab issue create -t "Bug in OAuth" -d "Users see error 500" -l bug,urgent -a @user1 -m v1.5

# Create confidential issue
glab issue create -t "Security vulnerability" --confidential -l security

# Create and open in browser
glab issue create -t "Feature request" --web
```

### `glab issue list`

List issues.

**Syntax:**
```bash
glab issue list [flags]
```

**Common Flags:**
- `-a, --assignee <user>`: Filter by assignee (use `@me`)
- `-A, --author <user>`: Filter by author
- `-l, --label <labels>`: Filter by labels
- `-m, --milestone <milestone>`: Filter by milestone
- `-s, --state <state>`: Filter by state (opened, closed, all)
- `--confidential`: Show only confidential issues
- `-P, --per-page <number>`: Items per page

**Examples:**
```bash
# List open issues
glab issue list

# List issues assigned to me
glab issue list --assignee=@me

# List closed issues
glab issue list --state=closed

# List issues with specific label
glab issue list --label=bug

# List issues in milestone
glab issue list --milestone=v2.0
```

### `glab issue view`

View issue details.

**Syntax:**
```bash
glab issue view <id> [flags]
```

**Common Flags:**
- `-w, --web`: Open in browser
- `-c, --comments`: Show comments

**Examples:**
```bash
# View issue #123
glab issue view 123

# View in browser
glab issue view 123 --web

# View with comments
glab issue view 123 --comments
```

### `glab issue close`

Close an issue.

**Syntax:**
```bash
glab issue close <id> [flags]
```

**Examples:**
```bash
# Close issue #123
glab issue close 123
```

### `glab issue reopen`

Reopen a closed issue.

**Syntax:**
```bash
glab issue reopen <id> [flags]
```

**Examples:**
```bash
# Reopen issue #123
glab issue reopen 123
```

### `glab issue note`

Add a comment to an issue.

**Syntax:**
```bash
glab issue note <id> [flags]
```

**Common Flags:**
- `-m, --message <text>`: Comment message

**Examples:**
```bash
# Add comment
glab issue note 123 --message "Working on this now"
```

### `glab issue update`

Update issue properties.

**Syntax:**
```bash
glab issue update <id> [flags]
```

**Common Flags:**
- `-t, --title <title>`: Update title
- `-d, --description <desc>`: Update description
- `-l, --label <labels>`: Set labels
- `-a, --assignee <users>`: Set assignees
- `--lock-discussion`: Lock discussion
- `--unlock-discussion`: Unlock discussion

**Examples:**
```bash
# Update title
glab issue update 123 --title "New title"

# Update labels
glab issue update 123 --label bug,critical

# Lock discussion
glab issue update 123 --lock-discussion
```

## CI/CD Pipeline Commands (`glab ci`)

### `glab ci view`

View CI/CD pipeline status.

**Syntax:**
```bash
glab ci view [flags]
```

**Common Flags:**
- `-b, --branch <branch>`: View pipeline for branch
- `-w, --web`: Open in browser
- `--pipeline-id <id>`: View specific pipeline

**Examples:**
```bash
# View latest pipeline for current branch
glab ci view

# View pipeline for specific branch
glab ci view --branch main

# View in browser
glab ci view --web

# View specific pipeline
glab ci view --pipeline-id 12345
```

### `glab ci list`

List CI/CD pipelines.

**Syntax:**
```bash
glab ci list [flags]
```

**Common Flags:**
- `-s, --status <status>`: Filter by status (pending, running, success, failed, canceled, skipped)
- `-b, --branch <branch>`: Filter by branch
- `-P, --per-page <number>`: Items per page

**Examples:**
```bash
# List recent pipelines
glab ci list

# List failed pipelines
glab ci list --status=failed

# List pipelines for main branch
glab ci list --branch=main
```

### `glab ci retry`

Retry a failed pipeline or job.

**Syntax:**
```bash
glab ci retry [<pipeline-id>] [flags]
```

**Examples:**
```bash
# Retry pipeline #12345
glab ci retry 12345

# Retry latest failed pipeline
glab ci retry
```

### `glab ci trace`

View job logs.

**Syntax:**
```bash
glab ci trace <job-id> [flags]
```

**Examples:**
```bash
# View logs for job
glab ci trace 67890
```

### `glab ci status`

View CI/CD status for a commit or branch.

**Syntax:**
```bash
glab ci status [flags]
```

**Common Flags:**
- `-b, --branch <branch>`: Check specific branch
- `--live`: Watch status in real-time

**Examples:**
```bash
# Check status for current branch
glab ci status

# Check status for specific branch
glab ci status --branch develop

# Watch status live
glab ci status --live
```

## Release Commands (`glab release`)

### `glab release create`

Create a new release.

**Syntax:**
```bash
glab release create <tag> [flags]
```

**Common Flags:**
- `-n, --notes <text>`: Release notes
- `-N, --notes-file <file>`: Release notes from file
- `-r, --ref <ref>`: Target branch/commit
- `-m, --milestones <milestones>`: Associated milestones
- `--assets-links <json>`: Asset links as JSON

**Examples:**
```bash
# Create release with notes
glab release create v1.0.0 --notes "Initial release"

# Create release from notes file
glab release create v1.0.0 --notes-file CHANGELOG.md

# Create release for specific commit
glab release create v1.0.1 --ref abc123 --notes "Hotfix release"
```

### `glab release list`

List releases.

**Syntax:**
```bash
glab release list [flags]
```

**Common Flags:**
- `-P, --per-page <number>`: Items per page

**Examples:**
```bash
# List releases
glab release list
```

### `glab release view`

View release details.

**Syntax:**
```bash
glab release view <tag> [flags]
```

**Common Flags:**
- `-w, --web`: Open in browser

**Examples:**
```bash
# View release
glab release view v1.0.0

# View in browser
glab release view v1.0.0 --web
```

### `glab release delete`

Delete a release.

**Syntax:**
```bash
glab release delete <tag> [flags]
```

**Common Flags:**
- `-y, --yes`: Skip confirmation
- `--with-tag`: Also delete the Git tag

**Examples:**
```bash
# Delete release
glab release delete v1.0.0

# Delete release and tag
glab release delete v1.0.0 --with-tag --yes
```

## Configuration Commands (`glab config`)

### `glab config get`

Get configuration value.

**Syntax:**
```bash
glab config get <key> [flags]
```

**Common Flags:**
- `-g, --global`: Get from global config
- `-h, --host <host>`: Get for specific host

**Examples:**
```bash
# Get default host
glab config get host

# Get global configuration
glab config get host --global

# Get for specific host
glab config get token --host gitlab.example.com
```

### `glab config set`

Set configuration value.

**Syntax:**
```bash
glab config set <key> <value> [flags]
```

**Common Flags:**
- `-g, --global`: Set in global config
- `-h, --host <host>`: Set for specific host

**Examples:**
```bash
# Set default host globally
glab config set host gitlab.example.com --global

# Set local repository config
glab config set check_update false

# Set host-specific config
glab config set api_protocol https --host gitlab.example.com
```

**Common Configuration Keys:**
- `host`: Default GitLab instance hostname
- `token`: Authentication token
- `api_protocol`: API protocol (http/https)
- `check_update`: Check for updates (true/false)
- `display_hyperlinks`: Display hyperlinks (true/false)
- `editor`: Preferred text editor
- `glamour_style`: Markdown rendering style
- `pager`: Paging program

## GitLab Duo Commands (`glab duo`)

### `glab duo ask`

Ask GitLab Duo AI for help with git commands.

**Syntax:**
```bash
glab duo ask [question] [flags]
```

**Examples:**
```bash
# Ask about rebasing
glab duo ask "How do I rebase my feature branch onto main?"

# Ask about squashing commits
glab duo ask "How to squash the last 3 commits?"

# Ask about undoing changes
glab duo ask "How do I undo my last commit but keep the changes?"
```

## Repository Commands (`glab repo`)

### `glab repo clone`

Clone a GitLab repository.

**Syntax:**
```bash
glab repo clone <repo> [flags]
```

**Common Flags:**
- `-g, --group <group>`: Clone all repos in group
- `--archived`: Include archived projects (when cloning group)
- `--preserve-namespace`: Preserve directory structure

**Examples:**
```bash
# Clone repository
glab repo clone owner/repo

# Clone with full path
glab repo clone group/subgroup/project

# Clone all repos in group
glab repo clone --group mygroup

# Clone group preserving structure
glab repo clone --group mygroup --preserve-namespace
```

### `glab repo view`

View repository information.

**Syntax:**
```bash
glab repo view [flags]
```

**Common Flags:**
- `-w, --web`: Open in browser

**Examples:**
```bash
# View current repository
glab repo view

# View in browser
glab repo view --web
```

### `glab repo fork`

Fork a repository.

**Syntax:**
```bash
glab repo fork [repo] [flags]
```

**Common Flags:**
- `--clone`: Clone after forking
- `--remote`: Add remote after forking

**Examples:**
```bash
# Fork current repository
glab repo fork

# Fork and clone
glab repo fork owner/repo --clone

# Fork and add as remote
glab repo fork owner/repo --remote
```

## Label Commands (`glab label`)

### `glab label create`

Create a new label.

**Syntax:**
```bash
glab label create <name> [flags]
```

**Common Flags:**
- `-c, --color <hex>`: Label color (hex code)
- `-d, --description <text>`: Label description

**Examples:**
```bash
# Create label
glab label create urgent --color "#FF0000" --description "Urgent priority"
```

### `glab label list`

List labels.

**Syntax:**
```bash
glab label list [flags]
```

**Examples:**
```bash
# List all labels
glab label list
```

## Variable Commands (`glab variable`)

### `glab variable set`

Set a CI/CD variable.

**Syntax:**
```bash
glab variable set <key> <value> [flags]
```

**Common Flags:**
- `-t, --type <type>`: Variable type (env_var, file)
- `-s, --scope <scope>`: Environment scope
- `--masked`: Mask variable value in logs
- `--protected`: Available only in protected branches/tags

**Examples:**
```bash
# Set simple variable
glab variable set DATABASE_URL "postgres://localhost/db"

# Set masked variable
glab variable set API_KEY "secret" --masked

# Set protected variable for production
glab variable set DEPLOY_KEY "key" --protected --scope production
```

### `glab variable list`

List CI/CD variables.

**Syntax:**
```bash
glab variable list [flags]
```

**Examples:**
```bash
# List all variables
glab variable list
```

### `glab variable delete`

Delete a CI/CD variable.

**Syntax:**
```bash
glab variable delete <key> [flags]
```

**Examples:**
```bash
# Delete variable
glab variable delete DATABASE_URL
```

## Global Flags

These flags work with most glab commands:

- `-R, --repo <owner/repo>`: Specify repository
- `-F, --output-format <format>`: Output format (text, json, yaml)
- `--help`: Show help for command
- `-v, --version`: Show glab version

**Examples:**
```bash
# Run command for specific repo
glab mr list -R owner/project

# Get JSON output
glab mr view 42 --output-format json

# Get help
glab mr create --help
```

## Environment Variables

- `GITLAB_HOST`: Override default GitLab instance
- `GITLAB_TOKEN`: Authentication token
- `CI_JOB_TOKEN`: CI job token (automatically set in GitLab CI)
- `VISUAL`, `EDITOR`: Preferred text editor

**Examples:**
```bash
# Use specific instance for one command
GITLAB_HOST=gitlab.example.com glab issue list

# Use specific token
GITLAB_TOKEN=glpat-xxx glab mr list
```
