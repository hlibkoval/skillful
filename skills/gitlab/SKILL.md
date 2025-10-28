---
name: gitlab
description: Use when working with GitLab repositories (cloud or self-managed) - provides workflows for creating MRs, managing issues, checking pipelines, and using glab CLI correctly, including authentication verification and instance detection
---

# GitLab Workflow

## Overview

Complete development workflow for GitLab repositories using `glab` CLI. Covers authentication, MR creation, issue management, and CI/CD pipeline checks for both gitlab.com and self-managed instances.

**Core principle:** Always verify before acting - check authentication, detect correct instance, verify pipeline status.

## When to Use

Use when:
- Creating merge requests in GitLab repos
- Managing GitLab issues or checking CI pipelines
- Working with self-managed GitLab instances
- Need to link MRs to issues
- Verifying work before creating MRs

**Don't use for GitHub repositories** - use `gh` CLI instead.

## Quick Reference

| Task | Command | Notes |
|------|---------|-------|
| Check auth | `glab auth status` | Do this FIRST, every time |
| View repo | `glab repo view` | Shows instance, default branch |
| Create MR | `glab mr create --fill` | Interactive with metadata |
| List MRs | `glab mr list` | Check if MR exists |
| Check pipeline | `glab ci status` | Verify tests pass |
| View issue | `glab issue view <num>` | Before linking |
| Link issue | Use "Closes #123" in MR description | Auto-closes on merge |

## Authentication Verification (MANDATORY)

**ALWAYS run `glab auth status` before GitLab operations.**

```bash
glab auth status
```

**What to check:**
- ✅ Correct GitLab instance listed (gitlab.com or self-managed)
- ✅ "Logged in as [username]" shown
- ✅ "Token found" confirmation
- ❌ "401 Unauthorized" = not authenticated
- ❌ "No token found" = need to authenticate

**If authentication fails:**
```bash
# For gitlab.com
glab auth login

# For self-managed instance
glab auth login --hostname gitlab.company.com
```

## Instance Detection Pattern

GitLab repos can be on gitlab.com OR self-managed instances. **Never assume gitlab.com.**

```bash
# Step 1: Check git remote to detect instance
git remote -v

# Examples:
# gitlab.com: git@gitlab.com:user/repo.git
# Self-managed: git@gitlab.company.com:user/repo.git

# Step 2: Verify glab knows about this instance
glab auth status  # Look for your instance in output

# Step 3: Confirm repo detection
glab repo view  # Shows instance URL and settings
```

## Creating Merge Requests

**Before creating MR:**

1. **Check authentication** (see above)
2. **Verify pipeline** (if CI configured)
3. **Check existing MRs** for this branch
4. **Get repo info** for default branch

**Complete workflow:**

```bash
# 1. Authentication
glab auth status

# 2. Check if MR already exists
glab mr list --source-branch $(git branch --show-current)

# 3. Check pipeline status (if applicable)
glab ci status

# 4. Get repo info (default branch, etc.)
glab repo view

# 5. Create MR interactively (recommended)
glab mr create --fill

# OR create with explicit values
glab mr create \
  --title "Your MR title" \
  --description "Description here" \
  --label "bug,priority::high" \
  --assignee @me \
  --reviewer @username
```

**`--fill` flag:** Uses commit messages to pre-fill title/description. Best for quick MRs.

## Issue Linking

**Always link MRs to issues when applicable.**

```bash
# First, verify issue exists
glab issue view 123

# Then create MR with issue link
glab mr create --fill --description "Closes #123"
```

**Auto-close keywords:** `Closes #123`, `Fixes #123`, `Resolves #123`

**Multiple issues:** `Closes #123, #456`

## CI/CD Pipeline Checks

**Before creating MR, verify tests pass:**

```bash
# Check current pipeline status
glab ci status

# View detailed pipeline
glab ci view

# Watch pipeline in real-time
glab ci view --wait

# View specific job logs
glab ci trace <job-name>
```

**Pipeline states:**
- ✅ `success` → Safe to create MR
- ⚠️ `running` → Wait for completion
- ❌ `failed` → Fix issues first
- ⏭️ `skipped` / `manual` → May need manual trigger

**Don't create MRs with failing pipelines** unless explicitly requested.

## Common Workflows

### Workflow 1: Bug Fix with Issue

```bash
# 1. Verify auth
glab auth status

# 2. Check issue details
glab issue view 456

# 3. Make changes, commit
git add . && git commit -m "Fix null pointer in UserService"

# 4. Push and check pipeline
git push -u origin fix/null-pointer-456
glab ci status --wait

# 5. Create MR linking issue
glab mr create --fill --description "Fixes #456

Implemented null checks in UserService.validate()
Tested with edge cases from issue comments"
```

### Workflow 2: Feature with Review

```bash
# 1. Verify auth
glab auth status

# 2. Push feature branch
git push -u origin feature/new-validation

# 3. Wait for pipeline
glab ci status --wait

# 4. Create MR with reviewers
glab mr create \
  --title "Add email validation to registration" \
  --description "Implements RFC 5322 email validation" \
  --label "feature,needs-review" \
  --reviewer @tech-lead \
  --assignee @me
```

### Workflow 3: Self-Managed Instance

```bash
# 1. Detect instance from git remote
git remote -v
# Shows: git@gitlab.company.com:team/project.git

# 2. Check auth for THAT instance
glab auth status
# Should show: gitlab.company.com ✓ Logged in

# 3. If not authenticated
glab auth login --hostname gitlab.company.com

# 4. Proceed with normal workflow
glab mr create --fill
```

## Common Mistakes

| Mistake | Why It's Wrong | Fix |
|---------|----------------|-----|
| Use `gh` for GitLab | GitHub CLI ≠ GitLab CLI | Always use `glab` |
| Skip `glab auth status` | Operations fail with confusing errors | Check auth FIRST |
| Assume gitlab.com | Repos may be self-managed | Check `git remote -v` |
| Assume `main` branch | Could be `master`, `develop`, etc. | Check `glab repo view` |
| Create MR with failing CI | Wastes reviewer time | Check `glab ci status` first |
| Skip issue linking | Loses traceability | Use "Closes #123" |
| Guess if MR exists | Creates duplicate MRs | Check `glab mr list` first |

## Red Flags - STOP and Verify

If you catch yourself thinking:
- "I'll just use gh, it's faster" → WRONG. Use glab.
- "Auth probably works" → WRONG. Check `glab auth status`.
- "It's probably on gitlab.com" → WRONG. Check `git remote -v`.
- "Tests can fail, we'll fix later" → WRONG. Check `glab ci status` first.
- "I'll skip the issue link" → WRONG. Link issues when applicable.

**All of these mean: STOP. Follow the workflow.**

## Rationalizations Table

| Excuse | Reality |
|--------|---------|
| "Using gh is the fastest way" | Wrong tool = fails. Check git remote. |
| "Assuming credentials are configured" | Auth fails silently. Check `glab auth status`. |
| "It's probably gitlab.com" | Self-managed instances are common. Detect instance. |
| "We can fix tests later" | Failing CI blocks review. Check pipeline first. |
| "Issue linking isn't critical" | Loses traceability. Use "Closes #N". |
| "No time to verify" | Verification takes 10 seconds. Fixing errors takes 10 minutes. |

## Advanced: MR Templates and Variables

**Check for MR templates:**
```bash
# GitLab looks for:
.gitlab/merge_request_templates/
```

**Using variables in descriptions:**
```bash
glab mr create --description "$(cat .gitlab/merge_request_templates/feature.md)"
```

**Pipeline variables:**
```bash
# Trigger pipeline with variables
glab ci run --variable KEY=value
```

## The Bottom Line

**Working with GitLab = use glab CLI correctly.**

1. **Verify auth** for correct instance FIRST
2. **Detect instance** from git remote (don't assume)
3. **Check pipeline** before creating MRs
4. **Link issues** when fixing bugs
5. **Use glab** not gh

Speed comes from doing it right the first time, not skipping verification.
