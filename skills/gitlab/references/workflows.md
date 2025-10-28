# GitLab Common Workflows

This document provides step-by-step workflows for common GitLab operations using glab CLI.

## Table of Contents

1. [Initial Setup Workflows](#initial-setup-workflows)
2. [Merge Request Workflows](#merge-request-workflows)
3. [Code Review Workflows](#code-review-workflows)
4. [CI/CD Workflows](#cicd-workflows)
5. [Issue Management Workflows](#issue-management-workflows)
6. [Release Workflows](#release-workflows)
7. [Multi-Instance Workflows](#multi-instance-workflows)
8. [Team Collaboration Workflows](#team-collaboration-workflows)

---

## Initial Setup Workflows

### First-Time Setup for GitLab.com

**Goal**: Authenticate and configure glab for GitLab.com.

**Steps**:

1. **Install glab** (if not already installed):
   ```bash
   # macOS
   brew install glab

   # Verify installation
   glab --version
   ```

2. **Authenticate with OAuth**:
   ```bash
   glab auth login
   ```
   - Follow browser prompts to authorize
   - OAuth is recommended for better security

3. **Verify authentication**:
   ```bash
   glab auth status
   ```

4. **Test with a simple command**:
   ```bash
   glab repo view
   ```

**Expected Outcome**: Successfully authenticated and able to run glab commands.

---

### First-Time Setup for Self-Managed GitLab

**Goal**: Authenticate and configure glab for self-managed GitLab instance.

**Prerequisites**:
- Self-managed GitLab instance URL (e.g., `gitlab.company.com`)
- Either OAuth app configured or personal access token with `api` and `write_repository` scopes

**Steps**:

1. **Install glab** (if not already installed):
   ```bash
   brew install glab  # macOS
   glab --version
   ```

2. **Set default host globally** (optional but recommended):
   ```bash
   glab config set -g host gitlab.company.com
   ```

3. **Authenticate**:

   **Option A: OAuth (if configured by admin)**:
   ```bash
   glab auth login --hostname gitlab.company.com
   ```

   **Option B: Personal Access Token**:
   ```bash
   # Interactive
   glab auth login --hostname gitlab.company.com
   # When prompted, select "Paste authentication token" and enter your token

   # Non-interactive
   echo "glpat-xxxxxxxxxxxx" | glab auth login --hostname gitlab.company.com --stdin
   ```

4. **Verify authentication**:
   ```bash
   glab auth status --hostname gitlab.company.com
   ```

5. **Test connection**:
   ```bash
   glab repo view
   ```

**Expected Outcome**: Successfully authenticated with self-managed instance.

---

### Multi-Instance Configuration

**Goal**: Configure glab to work with multiple GitLab instances simultaneously.

**Scenario**: You work with GitLab.com for open-source projects and a company self-managed instance for internal projects.

**Steps**:

1. **Authenticate with GitLab.com**:
   ```bash
   glab auth login
   ```

2. **Authenticate with self-managed instance**:
   ```bash
   glab auth login --hostname gitlab.company.com
   ```

3. **Verify both authentications**:
   ```bash
   glab auth status
   ```
   This shows status for all configured instances.

4. **Set default instance** (optional):
   ```bash
   glab config set -g host gitlab.company.com
   ```

5. **Use instance-specific commands**:
   ```bash
   # For GitLab.com repo
   cd ~/projects/opensource-repo
   glab mr list  # Automatically uses GitLab.com (detected from git remote)

   # For company GitLab repo
   cd ~/projects/company-repo
   glab mr list  # Automatically uses gitlab.company.com (detected from git remote)

   # Override for specific command
   GITLAB_HOST=gitlab.com glab issue list -R owner/project
   ```

**Expected Outcome**: Seamless switching between instances based on repository context.

---

## Merge Request Workflows

### Creating a Feature Branch MR

**Goal**: Create a feature branch, make changes, and open an MR.

**Steps**:

1. **Create and switch to feature branch**:
   ```bash
   git checkout -b feature/add-user-auth
   ```

2. **Make changes and commit**:
   ```bash
   # Make your changes
   git add .
   git commit -m "Add OAuth2 authentication flow"
   ```

3. **Push branch to remote**:
   ```bash
   git push -u origin feature/add-user-auth
   ```

4. **Create MR with glab**:
   ```bash
   glab mr create \
     --title "Add user authentication with OAuth2" \
     --description "Implements OAuth2 flow for user login. Resolves #42" \
     --label feature,authentication \
     --assignee @me \
     --reviewer @tech-lead \
     --remove-source-branch
   ```

5. **Verify MR was created**:
   ```bash
   glab mr view
   ```

6. **Check pipeline status**:
   ```bash
   glab ci view
   ```

**Expected Outcome**: MR created, pipeline running, ready for review.

---

### Creating a Draft MR for WIP

**Goal**: Create a draft MR to signal work-in-progress and get early feedback.

**Steps**:

1. **Create feature branch and make initial changes**:
   ```bash
   git checkout -b feature/new-dashboard
   # Make initial changes
   git add .
   git commit -m "Initial dashboard structure"
   git push -u origin feature/new-dashboard
   ```

2. **Create draft MR**:
   ```bash
   glab mr create \
     --draft \
     --title "New analytics dashboard" \
     --description "WIP: Building analytics dashboard. Feedback welcome on structure." \
     --label wip,feature
   ```

3. **Continue making changes**:
   ```bash
   # Make more changes
   git add .
   git commit -m "Add chart components"
   git push
   ```

4. **When ready, mark as ready for review**:
   ```bash
   glab mr update <mr-number> --ready
   ```

5. **Add reviewers**:
   ```bash
   glab mr update <mr-number> --reviewer @tech-lead,@designer
   ```

**Expected Outcome**: Draft MR created, updated as work progresses, marked ready when complete.

---

### Hotfix MR Workflow

**Goal**: Create an urgent hotfix MR targeting production.

**Steps**:

1. **Create hotfix branch from production**:
   ```bash
   git checkout production
   git pull
   git checkout -b hotfix/fix-login-error
   ```

2. **Make fix and commit**:
   ```bash
   # Fix the bug
   git add .
   git commit -m "Fix login error for OAuth users"
   git push -u origin hotfix/fix-login-error
   ```

3. **Create MR targeting production**:
   ```bash
   glab mr create \
     --title "Hotfix: Fix login error for OAuth users" \
     --description "Emergency fix for production login issue. Resolves #999" \
     --target-branch production \
     --label hotfix,urgent \
     --assignee @me \
     --reviewer @tech-lead,@devops-lead \
     --remove-source-branch
   ```

4. **Monitor CI status closely**:
   ```bash
   glab ci view --live
   ```

5. **Request immediate review**:
   ```bash
   # Notify via issue comment or external channels
   echo "Hotfix MR ready for urgent review"
   ```

6. **Merge as soon as approved**:
   ```bash
   glab mr merge <mr-number> --yes
   ```

**Expected Outcome**: Hotfix merged to production quickly with proper review.

---

### Auto-Filled MR from Commits

**Goal**: Create an MR with description auto-generated from commit messages.

**Steps**:

1. **Create feature branch with descriptive commits**:
   ```bash
   git checkout -b feature/payment-gateway

   # Make changes with descriptive commits
   git commit -m "Add Stripe SDK integration"
   git commit -m "Implement payment form component"
   git commit -m "Add payment validation logic"
   git commit -m "Add payment success/error handling"

   git push -u origin feature/payment-gateway
   ```

2. **Create MR with auto-filled description**:
   ```bash
   glab mr create \
     --fill \
     --label feature,payment
   ```
   The `--fill` flag automatically generates the description from commit messages.

3. **Review and edit if needed**:
   ```bash
   glab mr view

   # If description needs adjustment
   glab mr update <mr-number> --description "## Overview
   Integrates Stripe payment gateway...

   ## Changes
   - Stripe SDK integration
   - Payment form component
   - Validation logic
   - Error handling"
   ```

**Expected Outcome**: MR created with description automatically populated from commits.

---

## Code Review Workflows

### Reviewing an Assigned MR

**Goal**: Review an MR assigned to you.

**Steps**:

1. **List MRs assigned to you for review**:
   ```bash
   glab mr list --reviewer=@me
   ```

2. **View MR details**:
   ```bash
   glab mr view 123 --comments
   ```

3. **Check out MR locally for testing**:
   ```bash
   glab mr checkout 123
   ```

4. **Run tests locally**:
   ```bash
   # Run your project's test suite
   npm test  # or pytest, cargo test, etc.
   ```

5. **Check CI pipeline**:
   ```bash
   glab ci view
   ```

6. **Add review comments if needed**:
   ```bash
   glab mr note 123 --message "Great work! Just one suggestion:

   Consider adding error handling for the edge case where..."
   ```

7. **Approve if satisfied**:
   ```bash
   glab mr approve 123
   ```

8. **Return to your working branch**:
   ```bash
   git checkout main
   git branch -D <checkout-branch-name>
   ```

**Expected Outcome**: MR reviewed and approved (or feedback provided).

---

### Requesting Changes on an MR

**Goal**: Request changes on an MR that needs improvements.

**Steps**:

1. **View the MR**:
   ```bash
   glab mr view 456
   ```

2. **Check out locally if needed**:
   ```bash
   glab mr checkout 456
   ```

3. **Identify issues and add detailed comments**:
   ```bash
   glab mr note 456 --message "Changes requested:

   1. The function \`processPayment()\` needs error handling for network failures
   2. Please add unit tests for the new validation logic
   3. The API endpoint should return 400 instead of 500 for invalid input

   Please update and ping me when ready for another review."
   ```

4. **Do NOT approve yet**:
   ```bash
   # Wait for author to make changes
   ```

5. **Monitor for updates**:
   ```bash
   # Check periodically
   glab mr view 456 --comments
   ```

6. **When author updates, review again**:
   ```bash
   glab mr view 456
   glab mr checkout 456
   # Review changes
   ```

7. **Approve once satisfied**:
   ```bash
   glab mr approve 456
   ```

**Expected Outcome**: Author receives clear feedback, makes improvements, MR gets approved.

---

### Team MR Review Flow

**Goal**: Coordinate MR review among multiple team members.

**Steps**:

1. **Author creates MR with multiple reviewers**:
   ```bash
   glab mr create \
     --title "Refactor database layer" \
     --reviewer @backend-lead,@dba,@qa-lead
   ```

2. **Reviewers check their queue**:
   ```bash
   glab mr list --reviewer=@me --state=opened
   ```

3. **Each reviewer adds feedback**:
   ```bash
   # Backend lead
   glab mr note 789 --message "Backend architecture looks good 👍"
   glab mr approve 789

   # DBA
   glab mr note 789 --message "Migration scripts need indexes on user_id column"

   # QA lead
   glab mr note 789 --message "Please add integration tests for the new queries"
   ```

4. **Author addresses feedback**:
   ```bash
   # Make requested changes
   git add .
   git commit -m "Add indexes and integration tests"
   git push

   # Notify reviewers
   glab mr note 789 --message "Changes made per feedback. Ready for re-review."
   ```

5. **Reviewers re-review**:
   ```bash
   glab mr view 789 --comments
   glab mr approve 789
   ```

6. **Merge when all approvals received**:
   ```bash
   glab mr merge 789
   ```

**Expected Outcome**: MR gets thorough review from multiple perspectives before merging.

---

## CI/CD Workflows

### Monitoring Pipeline for Your MR

**Goal**: Track CI/CD pipeline status for your merge request.

**Steps**:

1. **Push changes**:
   ```bash
   git push
   ```

2. **Check pipeline status immediately**:
   ```bash
   glab ci view
   ```

3. **Watch pipeline in real-time** (if you need to wait):
   ```bash
   glab ci status --live
   ```

4. **If pipeline succeeds**:
   ```bash
   echo "✅ Pipeline passed! Ready for review."
   ```

5. **If pipeline fails, identify failed job**:
   ```bash
   glab ci view
   # Note the failed job ID
   ```

6. **View failed job logs**:
   ```bash
   glab ci trace <job-id>
   ```

7. **Fix issue and push**:
   ```bash
   # Fix the issue
   git add .
   git commit -m "Fix failing test"
   git push
   ```

8. **Monitor new pipeline**:
   ```bash
   glab ci view
   ```

**Expected Outcome**: Pipeline issue identified, fixed, and passing.

---

### Debugging Failed Pipeline

**Goal**: Systematically debug a failed CI/CD pipeline.

**Steps**:

1. **View pipeline summary**:
   ```bash
   glab ci view
   ```
   Output shows which stages/jobs failed.

2. **List recent pipelines to see failure pattern**:
   ```bash
   glab ci list --status=failed
   ```

3. **Get detailed logs for failed job**:
   ```bash
   glab ci trace <failed-job-id>
   ```

4. **Analyze the logs**:
   - Look for error messages
   - Check for missing dependencies
   - Verify environment variables
   - Check for flaky tests

5. **Common fixes**:

   **For dependency issues**:
   ```bash
   # Update dependency versions in package.json, requirements.txt, etc.
   git add .
   git commit -m "Update dependencies to fix CI"
   git push
   ```

   **For flaky tests**:
   ```bash
   # Fix or skip flaky test temporarily
   git add .
   git commit -m "Fix flaky test in UserServiceTest"
   git push
   ```

   **For environment issues**:
   ```bash
   # Update CI configuration (.gitlab-ci.yml)
   git add .
   git commit -m "Add missing DATABASE_URL env var to CI"
   git push
   ```

6. **Retry specific job** (if transient failure):
   ```bash
   glab ci retry <pipeline-id>
   ```

7. **Monitor new pipeline**:
   ```bash
   glab ci view
   ```

**Expected Outcome**: Failed pipeline debugged and fixed.

---

### Checking Pipeline Before Merging

**Goal**: Ensure pipeline is passing before merging MR.

**Steps**:

1. **Before approving/merging, check pipeline**:
   ```bash
   glab mr view 123
   glab ci view
   ```

2. **Verify all jobs passed**:
   ```bash
   glab ci view --pipeline-id <pipeline-id>
   ```

3. **If pipeline passed, proceed with merge**:
   ```bash
   glab mr approve 123
   glab mr merge 123 --when-pipeline-succeeds
   ```
   The `--when-pipeline-succeeds` flag ensures merge only happens after pipeline completes successfully.

4. **If pipeline failed, request fixes**:
   ```bash
   glab mr note 123 --message "Pipeline failed on linting job. Please fix and push."
   ```

**Expected Outcome**: MR only merged when pipeline is green.

---

## Issue Management Workflows

### Bug Report to Fix Workflow

**Goal**: Track a bug from report to resolution.

**Steps**:

1. **Create bug issue**:
   ```bash
   glab issue create \
     --title "Login fails for users with special characters in email" \
     --description "## Description
   Users with + or . in email cannot log in.

   ## Steps to Reproduce
   1. Go to login page
   2. Enter email: user+test@example.com
   3. Click login

   ## Expected
   User logs in successfully

   ## Actual
   Error: 'Invalid email format'

   ## Environment
   - Browser: Chrome 120
   - OS: macOS Ventura" \
     --label bug,authentication,high-priority \
     --assignee @me
   ```

2. **Track issue number** (e.g., #555):
   ```bash
   glab issue view 555
   ```

3. **Create fix branch referencing issue**:
   ```bash
   git checkout -b fix/login-special-chars-555
   ```

4. **Make fix**:
   ```bash
   # Fix the bug
   git add .
   git commit -m "Fix: Allow special characters in email validation

   Resolves #555"
   git push -u origin fix/login-special-chars-555
   ```

5. **Create MR referencing issue**:
   ```bash
   glab mr create \
     --title "Fix login for emails with special characters" \
     --description "Fixes email validation to support + and . characters.

   Resolves #555" \
     --label bug,authentication
   ```

6. **After MR is merged, verify issue auto-closed**:
   ```bash
   glab issue view 555
   ```
   Should show as closed if "Resolves #555" was in MR description.

**Expected Outcome**: Bug reported, fixed, merged, and issue auto-closed.

---

### Feature Request to Implementation Workflow

**Goal**: Track feature from request to delivery.

**Steps**:

1. **Create feature request issue**:
   ```bash
   glab issue create \
     --title "Add dark mode theme" \
     --description "## Proposal
   Add dark mode theme option for better accessibility and user preference.

   ## Acceptance Criteria
   - [ ] Theme toggle in settings
   - [ ] Dark color scheme defined
   - [ ] Persists user preference
   - [ ] Applies to all pages

   ## Design
   [Link to Figma mockups]" \
     --label feature,enhancement,ui \
     --milestone v2.5
   ```

2. **Discuss and refine in issue comments**:
   ```bash
   glab issue note 777 --message "Should we support system preference (auto dark mode)?"
   ```

3. **When ready to implement, assign and start**:
   ```bash
   glab issue update 777 --assignee @me
   ```

4. **Create feature branch**:
   ```bash
   git checkout -b feature/dark-mode-777
   ```

5. **Implement feature incrementally with commits**:
   ```bash
   git commit -m "Add dark mode color palette"
   git commit -m "Add theme toggle component"
   git commit -m "Wire up theme persistence"
   git commit -m "Apply dark mode to all pages"
   git push -u origin feature/dark-mode-777
   ```

6. **Create MR**:
   ```bash
   glab mr create \
     --fill \
     --description "Implements dark mode theme.

   Resolves #777" \
     --label feature,ui
   ```

7. **After merge, verify issue closed and milestone updated**:
   ```bash
   glab issue view 777
   glab issue list --milestone v2.5 --state closed
   ```

**Expected Outcome**: Feature delivered, issue closed, milestone progress tracked.

---

### Sprint Planning with Issues

**Goal**: Plan and track a sprint using GitLab issues and milestones.

**Steps**:

1. **Create milestone for sprint**:
   ```bash
   # Done via GitLab UI or API (glab doesn't have direct milestone create yet)
   # Assume milestone "Sprint 42" exists
   ```

2. **List candidate issues for sprint**:
   ```bash
   glab issue list --label priority:high --state opened
   ```

3. **Add issues to sprint milestone**:
   ```bash
   glab issue update 100 --milestone "Sprint 42"
   glab issue update 101 --milestone "Sprint 42"
   glab issue update 102 --milestone "Sprint 42"
   ```

4. **Assign issues to team members**:
   ```bash
   glab issue update 100 --assignee @developer1
   glab issue update 101 --assignee @developer2
   glab issue update 102 --assignee @me
   ```

5. **During sprint, track progress**:
   ```bash
   # View all sprint issues
   glab issue list --milestone "Sprint 42"

   # View open sprint issues
   glab issue list --milestone "Sprint 42" --state opened

   # View completed sprint issues
   glab issue list --milestone "Sprint 42" --state closed
   ```

6. **Update issue status as work progresses**:
   ```bash
   # Start work
   glab issue note 102 --message "Started working on this"

   # Complete work
   glab issue close 102
   ```

7. **End of sprint review**:
   ```bash
   # Sprint completion rate
   glab issue list --milestone "Sprint 42" --state closed
   glab issue list --milestone "Sprint 42" --state opened
   ```

**Expected Outcome**: Sprint planned, tracked, and reviewed using issues and milestones.

---

## Release Workflows

### Creating a Release from Main

**Goal**: Create a versioned release after merging features.

**Steps**:

1. **Ensure main branch is up to date**:
   ```bash
   git checkout main
   git pull
   ```

2. **Review changes since last release**:
   ```bash
   git log v1.2.0..HEAD --oneline
   ```

3. **Update version in project files** (package.json, Cargo.toml, etc.):
   ```bash
   # Update version to 1.3.0
   git add .
   git commit -m "Bump version to 1.3.0"
   git push
   ```

4. **Create git tag**:
   ```bash
   git tag -a v1.3.0 -m "Release v1.3.0"
   git push origin v1.3.0
   ```

5. **Generate release notes**:
   ```bash
   # Create RELEASE_NOTES.md with changes
   echo "# Release v1.3.0

   ## New Features
   - Dark mode theme (#777)
   - Advanced search (#790)

   ## Bug Fixes
   - Login special characters (#555)
   - Memory leak in dashboard (#812)

   ## Improvements
   - Faster API response times
   - Updated dependencies" > RELEASE_NOTES.md
   ```

6. **Create GitLab release**:
   ```bash
   glab release create v1.3.0 \
     --notes-file RELEASE_NOTES.md \
     --ref main
   ```

7. **Verify release created**:
   ```bash
   glab release view v1.3.0

   # View in browser
   glab release view v1.3.0 --web
   ```

**Expected Outcome**: Release v1.3.0 created with proper notes and tagged commit.

---

### Hotfix Release Workflow

**Goal**: Create an emergency hotfix release.

**Steps**:

1. **Create hotfix branch from production tag**:
   ```bash
   git checkout v1.3.0
   git checkout -b hotfix/v1.3.1
   ```

2. **Apply fix**:
   ```bash
   # Make the fix
   git add .
   git commit -m "Hotfix: Resolve critical auth bypass vulnerability"
   git push -u origin hotfix/v1.3.1
   ```

3. **Create hotfix MR to production**:
   ```bash
   glab mr create \
     --title "Hotfix v1.3.1: Auth bypass vulnerability" \
     --target-branch production \
     --label hotfix,security,urgent
   ```

4. **Fast-track review and merge**:
   ```bash
   # After urgent review
   glab mr merge <mr-number> --yes
   ```

5. **Tag hotfix release**:
   ```bash
   git checkout production
   git pull
   git tag -a v1.3.1 -m "Hotfix release v1.3.1"
   git push origin v1.3.1
   ```

6. **Create GitLab release**:
   ```bash
   glab release create v1.3.1 \
     --notes "# Hotfix v1.3.1

   ## Critical Fix
   - Resolved authentication bypass vulnerability (CVE-2024-XXXX)

   **This is a critical security release. All users should upgrade immediately.**" \
     --ref v1.3.1
   ```

7. **Backport fix to main**:
   ```bash
   git checkout main
   git cherry-pick <hotfix-commit-sha>
   git push
   ```

**Expected Outcome**: Hotfix deployed quickly, release created, fix backported to main.

---

## Multi-Instance Workflows

### Working with Projects Across GitLab.com and Self-Managed

**Goal**: Seamlessly work with projects on different GitLab instances.

**Scenario**: You contribute to an open-source project on GitLab.com and work on internal company projects on self-managed GitLab.

**Steps**:

1. **Set up authentication for both instances**:
   ```bash
   # GitLab.com
   glab auth login

   # Self-managed
   glab auth login --hostname gitlab.company.com

   # Verify both
   glab auth status
   ```

2. **Work with GitLab.com project**:
   ```bash
   cd ~/projects/opensource-project

   # Instance auto-detected from git remote
   glab mr list
   glab issue create --title "Feature request: Add dark mode"
   ```

3. **Work with self-managed project**:
   ```bash
   cd ~/projects/company-project

   # Instance auto-detected from git remote
   glab mr list
   glab ci view
   ```

4. **Explicitly specify instance when outside repo**:
   ```bash
   # List issues on GitLab.com project from anywhere
   GITLAB_HOST=gitlab.com glab issue list -R owner/project

   # List MRs on company GitLab from anywhere
   GITLAB_HOST=gitlab.company.com glab mr list -R company/internal-project
   ```

5. **Set default instance for convenience**:
   ```bash
   # If you mostly work with company GitLab
   glab config set -g host gitlab.company.com

   # Now commands outside repos default to company instance
   glab issue list -R company/project
   ```

**Expected Outcome**: Seamless operation across multiple GitLab instances.

---

## Team Collaboration Workflows

### Daily Standup Preparation

**Goal**: Quickly gather your work status for daily standup.

**Steps**:

1. **Check MRs you created or are working on**:
   ```bash
   glab mr list --author=@me --state=opened
   ```

2. **Check MRs assigned to you for review**:
   ```bash
   glab mr list --reviewer=@me --state=opened
   ```

3. **Check issues assigned to you**:
   ```bash
   glab issue list --assignee=@me --state=opened
   ```

4. **Check recent CI failures**:
   ```bash
   glab ci list --status=failed | head -5
   ```

5. **Compile standup notes**:
   ```
   Yesterday:
   - Merged MR #123 (dark mode feature)
   - Reviewed MR #456 (API refactor)

   Today:
   - Will complete MR #789 (payment gateway)
   - Will review MR #999 (database migration)

   Blockers:
   - Waiting on design feedback for issue #555
   ```

**Expected Outcome**: Quickly prepared for standup with accurate status.

---

### Code Freeze and Release Preparation

**Goal**: Prepare for release by reviewing all pending MRs and issues.

**Steps**:

1. **List all open MRs targeting release branch**:
   ```bash
   glab mr list --target-branch release/v2.0 --state=opened
   ```

2. **Check which MRs are ready to merge**:
   ```bash
   # Review each MR
   glab mr view 100
   glab mr view 101
   glab mr view 102
   ```

3. **Merge approved MRs**:
   ```bash
   glab mr merge 100
   glab mr merge 101
   ```

4. **List remaining open issues in milestone**:
   ```bash
   glab issue list --milestone "v2.0" --state=opened
   ```

5. **Decide which issues to defer**:
   ```bash
   # Move to next milestone
   glab issue update 200 --milestone "v2.1"
   glab issue update 201 --milestone "v2.1"
   ```

6. **Verify all pipeline passing**:
   ```bash
   glab ci list --branch release/v2.0
   ```

7. **Declare code freeze**:
   ```bash
   # Notify team via issue or external channels
   glab issue create \
     --title "Code freeze for v2.0" \
     --description "Code freeze in effect. No new MRs to release/v2.0 until release complete." \
     --label announcement,release
   ```

**Expected Outcome**: Release branch stabilized, ready for final testing and deployment.

---

This workflows document provides practical, step-by-step guidance for common GitLab operations using glab CLI. Refer to `glab-commands.md` for detailed command syntax and flags.
