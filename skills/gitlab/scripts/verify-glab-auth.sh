#!/usr/bin/env bash
#
# verify-glab-auth.sh
#
# Verifies glab CLI authentication status and provides troubleshooting guidance.
# This script checks:
# 1. glab installation
# 2. Authentication status
# 3. GitLab instance detection
# 4. Token validity
#
# Usage:
#   ./verify-glab-auth.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Symbols
CHECK_MARK="✓"
CROSS_MARK="✗"
INFO="ℹ"

# Print functions
print_success() {
    echo -e "${GREEN}${CHECK_MARK}${NC} $1"
}

print_error() {
    echo -e "${RED}${CROSS_MARK}${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}${INFO}${NC} $1"
}

print_info() {
    echo -e "${BLUE}${INFO}${NC} $1"
}

print_section() {
    echo ""
    echo -e "${BLUE}===${NC} $1"
    echo ""
}

# Check glab installation
check_glab_installed() {
    print_section "Checking glab Installation"

    if ! command -v glab &> /dev/null; then
        print_error "glab is not installed"
        echo ""
        echo "To install glab:"
        echo "  • macOS:   brew install glab"
        echo "  • Linux:   See https://gitlab.com/gitlab-org/cli#installation"
        echo "  • Windows: scoop install glab  OR  choco install glab"
        return 1
    fi

    local glab_version
    glab_version=$(glab --version | head -n 1)
    print_success "glab is installed: $glab_version"
    return 0
}

# Check authentication status
check_auth_status() {
    print_section "Checking Authentication Status"

    # Capture both stdout and stderr
    local auth_output
    auth_output=$(glab auth status 2>&1)

    # Check if at least one instance is authenticated
    # Look for "✓ Logged in to" or "✓ Token found" patterns
    if echo "$auth_output" | grep -qE "(✓ Logged in to|✓ Token found)"; then
        print_success "Authenticated with at least one GitLab instance"
        echo ""

        # Show detailed auth status
        print_info "Authentication details:"
        echo ""
        echo "$auth_output" | sed 's/^/  /'

        # Check if any instances failed but don't fail the whole check
        if echo "$auth_output" | grep -qE "(X |x )"; then
            echo ""
            print_warning "Some GitLab instances have authentication issues (this is okay if you don't use them)"
        fi

        return 0
    else
        print_error "Not authenticated with any GitLab instance"
        echo ""
        echo "To authenticate:"
        echo "  • GitLab.com:        glab auth login"
        echo "  • Self-managed:      glab auth login --hostname gitlab.example.com"
        echo "  • With token:        echo 'YOUR_TOKEN' | glab auth login --stdin"
        return 1
    fi
}

# Detect GitLab instance from git remote
detect_instance() {
    print_section "Detecting GitLab Instance"

    # Check if we're in a git repository
    if ! git rev-parse --git-dir &> /dev/null; then
        print_warning "Not in a git repository"
        echo "  • Instance detection from git remote is not available"
        echo "  • glab will use the default instance configured globally"
        echo ""

        # Check global default host
        local default_host
        if default_host=$(glab config get host -g 2>/dev/null); then
            print_info "Global default host: $default_host"
        else
            print_info "No global default host set (will default to gitlab.com)"
        fi
        return 0
    fi

    # Get git remote URL
    local remote_url
    if ! remote_url=$(git remote get-url origin 2>/dev/null); then
        print_warning "No git remote 'origin' configured"
        echo "  • Cannot auto-detect GitLab instance"
        return 0
    fi

    print_info "Git remote: $remote_url"

    # Extract hostname from remote URL
    local hostname
    if [[ "$remote_url" =~ ^https?://([^/]+) ]]; then
        hostname="${BASH_REMATCH[1]}"
    elif [[ "$remote_url" =~ ^git@([^:]+): ]]; then
        hostname="${BASH_REMATCH[1]}"
    else
        print_warning "Could not parse hostname from remote URL"
        return 0
    fi

    # Check if this is actually a GitLab instance
    if [[ "$hostname" == "github.com" ]] || [[ "$hostname" =~ ^github\. ]]; then
        print_warning "This repository is hosted on GitHub, not GitLab"
        echo "  • glab is for GitLab repositories only"
        echo "  • This verification is skipped for GitHub repositories"
        return 0
    fi

    print_success "Detected GitLab instance: $hostname"

    # Check if authenticated with this instance
    # Parse the output to see if this specific instance is authenticated
    local instance_auth
    instance_auth=$(glab auth status 2>&1)

    if echo "$instance_auth" | grep -A 10 "^$hostname$" | grep -qE "✓ (Logged in to|Token found)"; then
        print_success "Authenticated with $hostname"
        return 0
    else
        print_error "NOT authenticated with $hostname"
        echo ""
        echo "To authenticate with this instance:"
        echo "  glab auth login --hostname $hostname"
        return 1
    fi
}

# Test basic glab operation
test_glab_operation() {
    print_section "Testing glab Operation"

    # Check if we're in a git repository
    if ! git rev-parse --git-dir &> /dev/null; then
        print_warning "Not in a git repository - skipping operation test"
        echo "  • Move to a GitLab repository to test operations"
        return 0
    fi

    # Check if this is a GitHub repository
    local remote_url
    if remote_url=$(git remote get-url origin 2>/dev/null); then
        if [[ "$remote_url" =~ github\.com ]]; then
            print_warning "This is a GitHub repository - skipping glab operation test"
            echo "  • glab is for GitLab repositories only"
            echo "  • Move to a GitLab repository to test glab operations"
            return 0
        fi
    fi

    # Try to get repository info
    if glab repo view &> /dev/null; then
        print_success "Successfully connected to GitLab repository"
        echo ""
        print_info "Repository details:"
        echo ""
        glab repo view 2>&1 | head -n 10 | sed 's/^/  /'
        return 0
    else
        print_error "Failed to connect to GitLab repository"
        echo ""
        echo "Possible causes:"
        echo "  • Not authenticated with the correct GitLab instance"
        echo "  • Repository is not hosted on GitLab"
        echo "  • Network connectivity issues"
        echo "  • Token lacks required permissions (needs 'api' and 'read_repository' scopes)"
        return 1
    fi
}

# Provide troubleshooting tips
provide_troubleshooting_tips() {
    print_section "Troubleshooting Tips"

    echo "Common Issues and Solutions:"
    echo ""
    echo "1. Authentication Failed:"
    echo "   → Check token scopes include 'api' and 'write_repository'"
    echo "   → Verify token hasn't expired"
    echo "   → Try re-authenticating: glab auth login"
    echo ""
    echo "2. Wrong GitLab Instance:"
    echo "   → Check git remote: git remote -v"
    echo "   → Set correct instance: glab config set -g host gitlab.example.com"
    echo "   → Or use GITLAB_HOST env: GITLAB_HOST=gitlab.com glab mr list"
    echo ""
    echo "3. Permission Denied:"
    echo "   → Verify you have access to the repository"
    echo "   → Check token has required permissions"
    echo "   → Try viewing in browser: glab repo view --web"
    echo ""
    echo "4. Network Issues:"
    echo "   → Check internet connectivity"
    echo "   → Verify GitLab instance is accessible"
    echo "   → Check for proxy/firewall restrictions"
    echo ""
}

# Main execution
main() {
    echo ""
    echo "═══════════════════════════════════════════"
    echo "  glab Authentication Verification"
    echo "═══════════════════════════════════════════"

    local exit_code=0

    # Run checks
    if ! check_glab_installed; then
        exit_code=1
    fi

    if [[ $exit_code -eq 0 ]]; then
        if ! check_auth_status; then
            exit_code=1
        fi
    fi

    if [[ $exit_code -eq 0 ]]; then
        if ! detect_instance; then
            exit_code=1
        fi
    fi

    if [[ $exit_code -eq 0 ]]; then
        if ! test_glab_operation; then
            exit_code=1
        fi
    fi

    # Always show troubleshooting tips if there were any failures
    if [[ $exit_code -ne 0 ]]; then
        provide_troubleshooting_tips
    fi

    # Final status
    print_section "Verification Summary"

    if [[ $exit_code -eq 0 ]]; then
        print_success "All checks passed! glab is properly configured and authenticated."
        echo ""
        echo "Authentication Status: Verified"
    else
        print_error "Some checks failed. See above for details and troubleshooting steps."
        echo ""
        echo "Authentication Status: Not Authenticated"
    fi

    echo ""
    exit $exit_code
}

# Run main function
main "$@"
