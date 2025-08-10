#!/bin/bash

# 🌿 Branch Helper Script
# Git Flow workflow helper for Multi-Module E-Commerce Platform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to show usage
show_usage() {
    echo "🌿 Git Flow Branch Helper"
    echo ""
    echo "Usage: $0 <command> [arguments]"
    echo ""
    echo "Commands:"
    echo "  feature <name>     Create a new feature branch"
    echo "  bugfix <name>      Create a new bugfix branch"
    echo "  hotfix <name>      Create a new hotfix branch"
    echo "  release <version>  Create a new release branch"
    echo "  finish <type>      Finish current branch (merge to target)"
    echo "  status             Show current branch status"
    echo "  cleanup            Clean up merged branches"
    echo ""
    echo "Examples:"
    echo "  $0 feature phase-3-redis-cache"
    echo "  $0 bugfix user-api-validation"
    echo "  $0 hotfix security-jwt-fix"
    echo "  $0 release v1.1.0"
    echo "  $0 finish feature"
    echo "  $0 status"
    echo "  $0 cleanup"
}

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not a git repository"
        exit 1
    fi
}

# Function to check if branch exists
branch_exists() {
    git show-ref --verify --quiet refs/heads/$1
}

# Function to check if remote branch exists
remote_branch_exists() {
    git show-ref --verify --quiet refs/remotes/origin/$1
}

# Function to ensure develop branch exists
ensure_develop_branch() {
    if ! branch_exists "develop"; then
        if remote_branch_exists "develop"; then
            print_info "Checking out existing remote develop branch..."
            git checkout -b develop origin/develop
        else
            print_info "Creating develop branch from main..."
            git checkout main
            git pull origin main
            git checkout -b develop
            git push -u origin develop
        fi
    fi
}

# Function to create feature branch
create_feature_branch() {
    local branch_name="feature/$1"
    
    if [ -z "$1" ]; then
        print_error "Feature name is required"
        show_usage
        exit 1
    fi
    
    if branch_exists "$branch_name"; then
        print_error "Branch $branch_name already exists"
        exit 1
    fi
    
    ensure_develop_branch
    
    print_info "Creating feature branch: $branch_name"
    git checkout develop
    git pull origin develop
    git checkout -b "$branch_name"
    
    print_success "Feature branch created: $branch_name"
    print_info "You can now start developing your feature"
    print_info "When ready, run: $0 finish feature"
}

# Function to create bugfix branch
create_bugfix_branch() {
    local branch_name="bugfix/$1"
    
    if [ -z "$1" ]; then
        print_error "Bugfix name is required"
        show_usage
        exit 1
    fi
    
    if branch_exists "$branch_name"; then
        print_error "Branch $branch_name already exists"
        exit 1
    fi
    
    ensure_develop_branch
    
    print_info "Creating bugfix branch: $branch_name"
    git checkout develop
    git pull origin develop
    git checkout -b "$branch_name"
    
    print_success "Bugfix branch created: $branch_name"
    print_info "You can now fix the bug"
    print_info "When ready, run: $0 finish bugfix"
}

# Function to create hotfix branch
create_hotfix_branch() {
    local branch_name="hotfix/$1"
    
    if [ -z "$1" ]; then
        print_error "Hotfix name is required"
        show_usage
        exit 1
    fi
    
    if branch_exists "$branch_name"; then
        print_error "Branch $branch_name already exists"
        exit 1
    fi
    
    print_info "Creating hotfix branch: $branch_name"
    git checkout main
    git pull origin main
    git checkout -b "$branch_name"
    
    print_success "Hotfix branch created: $branch_name"
    print_warning "Remember: Hotfixes must be merged to both main and develop"
    print_info "When ready, run: $0 finish hotfix"
}

# Function to create release branch
create_release_branch() {
    local branch_name="release/$1"
    
    if [ -z "$1" ]; then
        print_error "Release version is required"
        show_usage
        exit 1
    fi
    
    if branch_exists "$branch_name"; then
        print_error "Branch $branch_name already exists"
        exit 1
    fi
    
    ensure_develop_branch
    
    print_info "Creating release branch: $branch_name"
    git checkout develop
    git pull origin develop
    git checkout -b "$branch_name"
    
    print_success "Release branch created: $branch_name"
    print_info "Prepare your release (version bumps, documentation, etc.)"
    print_info "When ready, run: $0 finish release"
}

# Function to finish current branch
finish_branch() {
    local branch_type="$1"
    local current_branch=$(git branch --show-current)
    
    if [ -z "$current_branch" ]; then
        print_error "Unable to determine current branch"
        exit 1
    fi
    
    case "$branch_type" in
        "feature"|"bugfix")
            if [[ $current_branch == feature/* ]] || [[ $current_branch == bugfix/* ]]; then
                print_info "Finishing $current_branch"
                print_info "Creating pull request to develop branch..."
                
                # Push current branch
                git push -u origin "$current_branch"
                
                # Create pull request using gh CLI if available
                if command -v gh &> /dev/null; then
                    gh pr create --base develop --head "$current_branch" \
                        --title "$(echo $current_branch | sed 's/.*\///' | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')" \
                        --body "Auto-generated PR for $current_branch

## 🎯 Description
[Please describe the changes made in this branch]

## 🧪 Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## 📋 Checklist
- [ ] Code follows project conventions
- [ ] Documentation updated
- [ ] Ready for review

🤖 Generated with [Claude Code](https://claude.ai/code)" \
                        --assignee @me
                        
                    print_success "Pull request created!"
                else
                    print_info "Create a pull request manually:"
                    print_info "From: $current_branch"
                    print_info "To: develop"
                fi
            else
                print_error "Current branch ($current_branch) is not a feature or bugfix branch"
                exit 1
            fi
            ;;
        "hotfix")
            if [[ $current_branch == hotfix/* ]]; then
                print_info "Finishing hotfix: $current_branch"
                print_warning "Hotfixes require manual merge to main and develop"
                print_info "Steps to complete:"
                print_info "1. Push branch: git push -u origin $current_branch"
                print_info "2. Create PR to main"
                print_info "3. After merge, create PR to develop"
                print_info "4. Clean up branch after both merges"
                
                # Push current branch
                git push -u origin "$current_branch"
                print_success "Hotfix branch pushed. Create pull requests manually."
            else
                print_error "Current branch ($current_branch) is not a hotfix branch"
                exit 1
            fi
            ;;
        "release")
            if [[ $current_branch == release/* ]]; then
                print_info "Finishing release: $current_branch"
                print_info "Release requires merge to main and develop"
                print_info "Steps to complete:"
                print_info "1. Push branch: git push -u origin $current_branch"
                print_info "2. Create PR to main"
                print_info "3. After merge, tag release"
                print_info "4. Create PR to develop"
                
                # Push current branch
                git push -u origin "$current_branch"
                print_success "Release branch pushed. Complete merge process manually."
            else
                print_error "Current branch ($current_branch) is not a release branch"
                exit 1
            fi
            ;;
        *)
            print_error "Unknown branch type: $branch_type"
            print_info "Available types: feature, bugfix, hotfix, release"
            exit 1
            ;;
    esac
}

# Function to show branch status
show_status() {
    local current_branch=$(git branch --show-current)
    
    print_info "Git Flow Branch Status"
    echo ""
    echo "📍 Current branch: $current_branch"
    echo ""
    
    # Show branch type and recommendations
    case "$current_branch" in
        main)
            print_warning "You're on main branch (production)"
            print_info "→ Create feature: $0 feature <name>"
            print_info "→ Create hotfix: $0 hotfix <name>"
            ;;
        develop)
            print_success "You're on develop branch (integration)"
            print_info "→ Create feature: $0 feature <name>"
            print_info "→ Create release: $0 release <version>"
            ;;
        feature/*)
            print_info "You're working on a feature"
            print_info "→ Finish feature: $0 finish feature"
            ;;
        bugfix/*)
            print_info "You're working on a bugfix"
            print_info "→ Finish bugfix: $0 finish bugfix"
            ;;
        hotfix/*)
            print_warning "You're working on a hotfix"
            print_info "→ Finish hotfix: $0 finish hotfix"
            ;;
        release/*)
            print_warning "You're working on a release"
            print_info "→ Finish release: $0 finish release"
            ;;
        *)
            print_warning "Unknown branch type"
            print_info "Consider using standard Git Flow branch names"
            ;;
    esac
    
    echo ""
    print_info "Recent branches:"
    git branch --sort=-committerdate | head -5
    
    echo ""
    print_info "Branch commits ahead/behind:"
    if branch_exists "develop"; then
        echo "  vs develop: $(git rev-list --left-right --count develop...$current_branch 2>/dev/null | tr '\t' '/' || echo "N/A")"
    fi
    if branch_exists "main"; then
        echo "  vs main: $(git rev-list --left-right --count main...$current_branch 2>/dev/null | tr '\t' '/' || echo "N/A")"
    fi
}

# Function to cleanup merged branches
cleanup_branches() {
    print_info "Cleaning up merged branches..."
    
    # Switch to develop or main
    if branch_exists "develop"; then
        git checkout develop
        git pull origin develop
    else
        git checkout main
        git pull origin main
    fi
    
    # Find merged branches
    local merged_branches=$(git branch --merged | grep -E "^\s*(feature|bugfix)/" | xargs)
    
    if [ -n "$merged_branches" ]; then
        print_info "Found merged branches: $merged_branches"
        
        for branch in $merged_branches; do
            print_info "Deleting local branch: $branch"
            git branch -d "$branch"
            
            # Delete remote branch if exists
            if remote_branch_exists "$branch"; then
                print_info "Deleting remote branch: $branch"
                git push origin --delete "$branch"
            fi
        done
        
        print_success "Cleanup completed!"
    else
        print_info "No merged branches to clean up"
    fi
}

# Main script logic
check_git_repo

case "${1:-}" in
    "feature")
        create_feature_branch "$2"
        ;;
    "bugfix")
        create_bugfix_branch "$2"
        ;;
    "hotfix")
        create_hotfix_branch "$2"
        ;;
    "release")
        create_release_branch "$2"
        ;;
    "finish")
        finish_branch "$2"
        ;;
    "status")
        show_status
        ;;
    "cleanup")
        cleanup_branches
        ;;
    "help"|"-h"|"--help")
        show_usage
        ;;
    *)
        print_error "Unknown command: ${1:-}"
        echo ""
        show_usage
        exit 1
        ;;
esac