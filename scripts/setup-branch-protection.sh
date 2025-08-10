#!/bin/bash

# 🛡️ GitHub Branch Protection Setup Script
# Multi-Module E-Commerce Platform

set -e

echo "🛡️ Setting up GitHub Branch Protection Rules..."

# Repository information
REPO_OWNER="SeokRae"
REPO_NAME="multi-module-example"

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "💡 Install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI."
    echo "💡 Run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is ready"

# Function to setup branch protection
setup_branch_protection() {
    local branch_name=$1
    local protection_level=$2
    
    echo "🔒 Setting up protection for branch: $branch_name"
    
    case $protection_level in
        "strict")
            # main branch - strict protection
            gh api repos/$REPO_OWNER/$REPO_NAME/branches/$branch_name/protection \
                --method PUT \
                --field required_status_checks='{
                    "strict": true,
                    "contexts": ["build", "test", "lint"]
                }' \
                --field enforce_admins=true \
                --field required_pull_request_reviews='{
                    "required_approving_review_count": 1,
                    "dismiss_stale_reviews": true,
                    "require_code_owner_reviews": false,
                    "require_last_push_approval": false
                }' \
                --field restrictions=null \
                --field allow_force_pushes=false \
                --field allow_deletions=false \
                --field block_creations=false
            ;;
        "moderate")
            # develop branch - moderate protection
            gh api repos/$REPO_OWNER/$REPO_NAME/branches/$branch_name/protection \
                --method PUT \
                --field required_status_checks='{
                    "strict": false,
                    "contexts": ["build", "test"]
                }' \
                --field enforce_admins=false \
                --field required_pull_request_reviews='{
                    "required_approving_review_count": 1,
                    "dismiss_stale_reviews": false,
                    "require_code_owner_reviews": false,
                    "require_last_push_approval": false
                }' \
                --field restrictions=null \
                --field allow_force_pushes=false \
                --field allow_deletions=false \
                --field block_creations=false
            ;;
    esac
    
    echo "✅ Branch protection set for: $branch_name"
}

# Setup branch protection rules
echo "🔧 Configuring branch protection rules..."

# Main branch (production) - Strict protection
if gh api repos/$REPO_OWNER/$REPO_NAME/branches/main &> /dev/null; then
    setup_branch_protection "main" "strict"
else
    echo "⚠️  Main branch not found, skipping protection setup"
fi

# Develop branch - Moderate protection  
if gh api repos/$REPO_OWNER/$REPO_NAME/branches/develop &> /dev/null; then
    setup_branch_protection "develop" "moderate"
else
    echo "⚠️  Develop branch not found, skipping protection setup"
fi

echo ""
echo "✅ Branch protection setup completed!"
echo ""
echo "📊 Current protection status:"
echo "├── main: Strict protection (1 reviewer required, status checks, no force push)"
echo "└── develop: Moderate protection (1 reviewer required, basic status checks)"
echo ""
echo "🔧 Additional setup recommendations:"
echo "1. Configure CI/CD workflows to set required status checks"
echo "2. Add CODEOWNERS file for automatic reviewer assignment"
echo "3. Enable 'Automatically delete head branches' in repository settings"
echo "4. Configure branch protection rules for release/* and hotfix/* patterns"
echo ""
echo "📚 Workflow Guide: .github/DEVELOPMENT_WORKFLOW.md"