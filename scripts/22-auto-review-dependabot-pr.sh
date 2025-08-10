#!/bin/bash

# Automated Dependabot PR Review Script

set -euo pipefail

PR_NUMBER="$1"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -z "${PR_NUMBER:-}" ]]; then
    echo "Usage: $0 <PR_NUMBER>"
    exit 1
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting automated review of PR #${PR_NUMBER}${NC}"

# Fetch PR information
PR_INFO=$(gh pr view "$PR_NUMBER" --json title,body,headRefName,baseRefName,author)
PR_TITLE=$(echo "$PR_INFO" | jq -r '.title')
PR_AUTHOR=$(echo "$PR_INFO" | jq -r '.author.login')

echo "PR Title: $PR_TITLE"
echo "Author: $PR_AUTHOR"

# Check if it's a Dependabot PR
if [[ "$PR_AUTHOR" != "app/dependabot" ]]; then
    echo -e "${YELLOW}This is not a Dependabot PR. Skipping automated review.${NC}"
    exit 0
fi

# Checkout the PR branch
BRANCH_NAME=$(echo "$PR_INFO" | jq -r '.headRefName')
echo "Checking out branch: $BRANCH_NAME"

git fetch origin "$BRANCH_NAME"
git checkout "$BRANCH_NAME"

# Run build test
echo -e "${GREEN}Running build test...${NC}"
if ./gradlew clean build; then
    echo -e "${GREEN}✓ Build passed${NC}"
    BUILD_PASSED=true
else
    echo -e "${RED}✗ Build failed${NC}"
    BUILD_PASSED=false
fi

# Run tests
echo -e "${GREEN}Running tests...${NC}"
if ./gradlew test; then
    echo -e "${GREEN}✓ Tests passed${NC}"
    TESTS_PASSED=true
else
    echo -e "${RED}✗ Tests failed${NC}"
    TESTS_PASSED=false
fi

# Analyze the update
echo -e "${GREEN}Analyzing dependency update...${NC}"

# Extract version information from PR title
VERSION_INFO=$(echo "$PR_TITLE" | grep -oE 'from [0-9]+\.[0-9]+\.[0-9]+.*to [0-9]+\.[0-9]+\.[0-9]+' || echo "Version info not found")
echo "Version change: $VERSION_INFO"

# Determine risk level
RISK_LEVEL="UNKNOWN"
if echo "$PR_TITLE" | grep -qE 'Bump.*from.*\.[0-9]+.*to.*\.[0-9]+$'; then
    RISK_LEVEL="LOW"  # Patch version
elif echo "$PR_TITLE" | grep -qE 'Bump.*from.*\.[0-9]+\..*to.*\.[0-9]+\.'; then
    RISK_LEVEL="MEDIUM"  # Minor version
else
    RISK_LEVEL="HIGH"  # Major version or unclear
fi

echo "Risk Level: $RISK_LEVEL"

# Generate review comment
REVIEW_COMMENT="## Automated Review Results

**PR**: $PR_TITLE
**Risk Level**: $RISK_LEVEL
**Version Change**: $VERSION_INFO

### Test Results
- Build: $(if $BUILD_PASSED; then echo "✅ PASSED"; else echo "❌ FAILED"; fi)
- Tests: $(if $TESTS_PASSED; then echo "✅ PASSED"; else echo "❌ FAILED"; fi)

### Recommendation
"

if [[ "$BUILD_PASSED" == true ]] && [[ "$TESTS_PASSED" == true ]] && [[ "$RISK_LEVEL" == "LOW" ]]; then
    REVIEW_COMMENT+="\n✅ **APPROVE**: This appears to be a safe patch update with all tests passing."
    REVIEW_ACTION="APPROVE"
elif [[ "$BUILD_PASSED" == true ]] && [[ "$TESTS_PASSED" == true ]]; then
    REVIEW_COMMENT+="\n⚠️ **REVIEW REQUIRED**: Tests pass but manual review recommended for $RISK_LEVEL risk update."
    REVIEW_ACTION="COMMENT"
else
    REVIEW_COMMENT+="\n❌ **REQUEST CHANGES**: Build or tests failed. Investigation required."
    REVIEW_ACTION="REQUEST_CHANGES"
fi

# Post review comment
echo -e "${GREEN}Posting review...${NC}"
gh pr review "$PR_NUMBER" --"${REVIEW_ACTION,,}" --body "$REVIEW_COMMENT"

echo -e "${GREEN}Automated review completed${NC}"

# Return to main branch
git checkout main

