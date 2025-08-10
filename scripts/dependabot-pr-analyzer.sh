#!/bin/bash

# Dependabot PR Analysis Tool
# Comprehensive analysis and failure diagnosis for Dependabot PRs

set -euo pipefail

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANALYSIS_DIR="${PROJECT_ROOT}/.dependabot-analysis"
BUILD_REPORTS_DIR="${PROJECT_ROOT}/build/reports"
LOG_FILE="${ANALYSIS_DIR}/analysis.log"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"
}

error() {
    echo -e "${RED}ERROR: $1${NC}" | tee -a "${LOG_FILE}"
}

warning() {
    echo -e "${YELLOW}WARNING: $1${NC}" | tee -a "${LOG_FILE}"
}

success() {
    echo -e "${GREEN}SUCCESS: $1${NC}" | tee -a "${LOG_FILE}"
}

info() {
    echo -e "${BLUE}INFO: $1${NC}" | tee -a "${LOG_FILE}"
}

# Initialize analysis directory
init_analysis_dir() {
    mkdir -p "${ANALYSIS_DIR}"
    mkdir -p "${ANALYSIS_DIR}/reports"
    mkdir -p "${ANALYSIS_DIR}/build-logs"
    mkdir -p "${ANALYSIS_DIR}/dependency-graphs"
    
    if [[ ! -f "${LOG_FILE}" ]]; then
        touch "${LOG_FILE}"
    fi
    
    log "Analysis directory initialized at: ${ANALYSIS_DIR}"
}

# Function to check if gh CLI is available
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        error "GitHub CLI (gh) not found. Please install it first."
        echo "Visit: https://cli.github.com/"
        return 1
    fi
    
    # Check if authenticated
    if ! gh auth status &>/dev/null; then
        error "GitHub CLI not authenticated. Run 'gh auth login' first."
        return 1
    fi
    
    success "GitHub CLI is available and authenticated"
    return 0
}

# Get Dependabot PRs
get_dependabot_prs() {
    log "Fetching Dependabot PRs..."
    
    # Get open Dependabot PRs
    local pr_list
    if pr_list=$(gh pr list --author=app/dependabot --state=open --json number,title,headRefName,baseRefName,url,createdAt,updatedAt 2>/dev/null); then
        echo "$pr_list" > "${ANALYSIS_DIR}/open-dependabot-prs.json"
        
        local pr_count
        pr_count=$(echo "$pr_list" | jq length)
        info "Found $pr_count open Dependabot PRs"
        
        # Create summary
        echo "$pr_list" | jq -r '.[] | "PR #\(.number): \(.title)"' > "${ANALYSIS_DIR}/pr-summary.txt"
    else
        warning "Could not fetch Dependabot PRs. This may be normal if there are none or if not using GitHub."
        echo "[]" > "${ANALYSIS_DIR}/open-dependabot-prs.json"
        touch "${ANALYSIS_DIR}/pr-summary.txt"
    fi
}

# Analyze dependency versions
analyze_current_dependencies() {
    log "Analyzing current dependency versions..."
    
    local deps_file="${ANALYSIS_DIR}/current-dependencies.txt"
    
    # Extract Spring Boot version
    grep -n "spring-boot" "${PROJECT_ROOT}/build.gradle" | head -20 > "$deps_file"
    
    # Extract other key dependencies
    {
        echo "=== Spring Boot Dependencies ==="
        grep -r "spring-boot" "${PROJECT_ROOT}"/**/*.gradle | grep -v build/ || true
        
        echo -e "\n=== QueryDSL Dependencies ==="
        grep -r "querydsl" "${PROJECT_ROOT}"/**/*.gradle || true
        
        echo -e "\n=== JWT Dependencies ==="
        grep -r "jjwt\|jwt" "${PROJECT_ROOT}"/**/*.gradle || true
        
        echo -e "\n=== Redisson Dependencies ==="
        grep -r "redisson" "${PROJECT_ROOT}"/**/*.gradle || true
        
        echo -e "\n=== Other Key Dependencies ==="
        grep -r "version.*:" "${PROJECT_ROOT}/build.gradle" | grep -E "(guava|threeten|moneta|hibernate|bucket4j|springdoc|opencsv|poi)" || true
    } >> "$deps_file"
    
    success "Dependency analysis saved to: $deps_file"
}

# Generate dependency compatibility matrix
generate_compatibility_matrix() {
    log "Generating Spring Boot compatibility matrix..."
    
    local matrix_file="${ANALYSIS_DIR}/compatibility-matrix.md"
    
    cat > "$matrix_file" << 'EOF'
# Spring Boot Compatibility Matrix

## Current Project Configuration
- Spring Boot: 3.2.2
- Java: 17
- Gradle: 8.14

## Spring Boot 3.x Compatibility

| Component | 3.2.x | 3.3.x | 3.4.x | 3.5.x | Notes |
|-----------|-------|-------|-------|-------|-------|
| Java 17 | ✓ | ✓ | ✓ | ✓ | Fully supported |
| Java 21 | ✓ | ✓ | ✓ | ✓ | Recommended for 3.3+ |
| QueryDSL 5.0.0 | ✓ | ✓ | ⚠️ | ⚠️ | May need update |
| JJWT 0.12.3 | ✓ | ✓ | ✓ | ✓ | Compatible |
| Redisson 3.24.3 | ✓ | ✓ | ⚠️ | ⚠️ | Check version compatibility |
| Hibernate Types 60 | ✓ | ⚠️ | ⚠️ | ❌ | Deprecated in newer versions |

## Upgrade Path Recommendations

### To Spring Boot 3.3.x
1. Update Spring Boot version
2. Consider Java 21 upgrade
3. Update QueryDSL to 5.1.0+
4. Update Redisson to 3.27.0+

### To Spring Boot 3.4.x
1. Update Spring Boot version
2. Upgrade to Java 21
3. Replace hibernate-types-60 with Spring Boot native JSON support
4. Update all related dependencies

### To Spring Boot 3.5.x
1. Update Spring Boot version
2. Require Java 21
3. Major dependency updates required
4. Test extensively due to breaking changes

EOF
    
    success "Compatibility matrix generated: $matrix_file"
}

# Analyze build failures
analyze_build_failures() {
    log "Analyzing potential build failures..."
    
    local failure_analysis="${ANALYSIS_DIR}/build-failure-analysis.md"
    
    cat > "$failure_analysis" << 'EOF'
# Build Failure Analysis

## Common Dependabot PR Failure Patterns

### 1. Spring Boot Version Conflicts
**Symptoms:**
- Compilation errors with Spring annotations
- Bean definition conflicts
- Auto-configuration failures

**Resolution:**
- Update all Spring Boot starters simultaneously
- Check for deprecated configuration properties
- Update application.yml/properties files

### 2. QueryDSL Compatibility Issues
**Symptoms:**
- Q-class generation failures
- Compilation errors in repository implementations
- Missing QueryDSL APT processor

**Resolution:**
- Update QueryDSL version alongside Spring Boot
- Regenerate Q-classes after update
- Update annotation processor configuration

### 3. JWT Library Breaking Changes
**Symptoms:**
- JWT token parsing failures
- Security configuration errors
- Method signature changes

**Resolution:**
- Review JJWT changelog for breaking changes
- Update JWT configuration classes
- Test authentication flows thoroughly

### 4. Redisson Version Incompatibility
**Symptoms:**
- Redis connection failures
- Serialization issues
- Configuration property changes

**Resolution:**
- Check Redisson-Spring Boot compatibility
- Update Redisson configuration
- Test caching functionality

### 5. Gradle Build Script Issues
**Symptoms:**
- Plugin version conflicts
- Dependency resolution failures
- Task execution errors

**Resolution:**
- Update Gradle wrapper if needed
- Check plugin compatibility
- Update dependency management configuration

## Automated Failure Detection

This script checks for:
- Version compatibility issues
- Configuration deprecations
- Breaking API changes
- Build script problems

EOF
    
    success "Build failure analysis generated: $failure_analysis"
}

# Run build test with detailed output
run_build_test() {
    log "Running comprehensive build test..."
    
    local build_log="${ANALYSIS_DIR}/build-logs/build-test-${TIMESTAMP}.log"
    
    cd "${PROJECT_ROOT}"
    
    # Clean build
    info "Running clean build..."
    if ./gradlew clean --info > "${build_log}" 2>&1; then
        success "Clean completed successfully"
    else
        error "Clean failed - check log: $build_log"
        return 1
    fi
    
    # Full build with tests
    info "Running full build with tests..."
    if ./gradlew build --info >> "${build_log}" 2>&1; then
        success "Build completed successfully"
    else
        error "Build failed - check log: $build_log"
        
        # Extract error information
        local error_summary="${ANALYSIS_DIR}/build-error-summary.txt"
        {
            echo "=== BUILD FAILURE SUMMARY ==="
            echo "Timestamp: $(date)"
            echo -e "\n=== COMPILATION ERRORS ==="
            grep -A 5 -B 5 "FAILED" "$build_log" || true
            echo -e "\n=== DEPENDENCY ERRORS ==="
            grep -A 3 -B 3 "Could not resolve" "$build_log" || true
            echo -e "\n=== TEST FAILURES ==="
            grep -A 10 "FAILED" "$build_log" | grep -E "(test|Test)" || true
        } > "$error_summary"
        
        error "Build error summary saved to: $error_summary"
        return 1
    fi
    
    # Test individual modules
    info "Testing individual modules..."
    local modules=("common:common-core" "common:common-web" "common:common-security" "domain:user-domain" "infrastructure:data-access" "application:user-api" "application:batch-app")
    
    for module in "${modules[@]}"; do
        info "Testing module: $module"
        if ./gradlew ":$module:test" --info >> "${build_log}" 2>&1; then
            success "Module $module tests passed"
        else
            warning "Module $module tests failed"
        fi
    done
    
    success "Build test completed - log: $build_log"
}

# Generate dependency update recommendations
generate_update_recommendations() {
    log "Generating dependency update recommendations..."
    
    local recommendations="${ANALYSIS_DIR}/update-recommendations.md"
    
    cat > "$recommendations" << 'EOF'
# Dependency Update Recommendations

## Prioritized Update Strategy

### Phase 1: Critical Security Updates
1. **Spring Boot Security patches**
   - Update to latest 3.2.x patch version first
   - Test authentication and authorization
   - Verify security configurations

2. **JWT library updates**
   - JJWT security patches
   - Test token generation and validation
   - Check for deprecated methods

### Phase 2: Minor Version Updates
1. **Spring Boot 3.2.x → 3.3.x**
   - Compatibility: High
   - Breaking changes: Minimal
   - Testing required: Moderate

2. **Supporting library updates**
   - QueryDSL patch versions
   - Redisson compatible versions
   - Utility library updates

### Phase 3: Major Version Updates
1. **Spring Boot 3.3.x → 3.4.x/3.5.x**
   - Compatibility: Medium
   - Breaking changes: Significant
   - Testing required: Extensive

2. **Java version upgrade**
   - Consider Java 21 for newer Spring Boot versions
   - Update build configurations
   - Test all functionality

## Update Checklist

### Before Updating
- [ ] Review changelog for breaking changes
- [ ] Check compatibility matrix
- [ ] Backup current working version
- [ ] Plan rollback strategy

### During Update
- [ ] Update versions systematically
- [ ] Run comprehensive tests
- [ ] Check configuration compatibility
- [ ] Verify functionality

### After Update
- [ ] Run full test suite
- [ ] Performance testing
- [ ] Security testing
- [ ] Documentation updates

## Risk Assessment

| Update Type | Risk Level | Required Testing |
|-------------|------------|------------------|
| Patch (x.y.Z) | Low | Unit + Integration tests |
| Minor (x.Y.z) | Medium | Full test suite + Manual testing |
| Major (X.y.z) | High | Full test suite + Performance + Security |

EOF
    
    success "Update recommendations generated: $recommendations"
}

# Generate PR review checklist
generate_pr_review_checklist() {
    log "Generating PR review checklist..."
    
    local checklist="${ANALYSIS_DIR}/pr-review-checklist.md"
    
    cat > "$checklist" << 'EOF'
# Dependabot PR Review Checklist

## Automated Checks
- [ ] Build passes successfully
- [ ] All tests pass
- [ ] No compilation errors
- [ ] Dependency compatibility verified

## Manual Review Items

### Version Analysis
- [ ] Review changelog for breaking changes
- [ ] Check version compatibility with current dependencies
- [ ] Verify no deprecated APIs are used
- [ ] Assess impact on existing functionality

### Configuration Review
- [ ] Check for configuration property changes
- [ ] Verify application.yml/properties compatibility
- [ ] Review security configuration impact
- [ ] Validate database migration requirements

### Testing Requirements
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Security tests pass
- [ ] Performance impact assessed
- [ ] Manual testing completed

### Code Quality
- [ ] No code quality regressions
- [ ] Documentation updated if needed
- [ ] API compatibility maintained
- [ ] Error handling not affected

## Risk Categories

### Low Risk (Auto-merge candidates)
- Patch versions with no breaking changes
- Security patches for known vulnerabilities
- Minor bug fixes with good test coverage

### Medium Risk (Review required)
- Minor version updates
- New features in dependencies
- Configuration changes required

### High Risk (Thorough review required)
- Major version updates
- Breaking changes present
- Security configuration changes
- Performance impact possible

## Approval Criteria

### Auto-approve if:
- Patch version update
- All tests pass
- No breaking changes
- Security patches

### Manual review if:
- Minor/major version update
- Test failures present
- Breaking changes identified
- Configuration changes required

### Reject if:
- Critical functionality broken
- Security vulnerabilities introduced
- Major performance degradation
- Breaking changes not addressed

EOF
    
    success "PR review checklist generated: $checklist"
}

# Create automated PR review script
create_pr_review_script() {
    log "Creating automated PR review script..."
    
    local review_script="${PROJECT_ROOT}/scripts/auto-review-dependabot-pr.sh"
    
    cat > "$review_script" << 'EOF'
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

EOF
    
    chmod +x "$review_script"
    success "Automated PR review script created: $review_script"
}

# Generate build diagnostics tools
create_build_diagnostics() {
    log "Creating build diagnostics tools..."
    
    local diagnostics_script="${PROJECT_ROOT}/scripts/build-diagnostics.sh"
    
    cat > "$diagnostics_script" << 'EOF'
#!/bin/bash

# Build Diagnostics Tool
# Comprehensive build failure analysis

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIAGNOSTICS_DIR="${PROJECT_ROOT}/.build-diagnostics"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}INFO: $1${NC}"; }
success() { echo -e "${GREEN}SUCCESS: $1${NC}"; }
warning() { echo -e "${YELLOW}WARNING: $1${NC}"; }
error() { echo -e "${RED}ERROR: $1${NC}"; }

# Initialize diagnostics directory
init_diagnostics() {
    mkdir -p "${DIAGNOSTICS_DIR}"
    mkdir -p "${DIAGNOSTICS_DIR}/logs"
    mkdir -p "${DIAGNOSTICS_DIR}/reports"
}

# System information
collect_system_info() {
    info "Collecting system information..."
    
    local sys_info="${DIAGNOSTICS_DIR}/system-info.txt"
    
    {
        echo "=== SYSTEM INFORMATION ==="
        echo "Date: $(date)"
        echo "OS: $(uname -a)"
        echo "Java Version:"
        java -version
        echo -e "\nGradle Version:"
        ./gradlew --version
        echo -e "\nGit Status:"
        git status --porcelain
        echo -e "\nCurrent Branch:"
        git branch --show-current
    } > "$sys_info"
    
    success "System info saved to: $sys_info"
}

# Dependency analysis
analyze_dependencies() {
    info "Analyzing project dependencies..."
    
    local deps_report="${DIAGNOSTICS_DIR}/reports/dependencies-${TIMESTAMP}.txt"
    
    {
        echo "=== DEPENDENCY TREE ==="
        ./gradlew dependencies --configuration compileClasspath
        
        echo -e "\n=== DEPENDENCY INSIGHTS ==="
        ./gradlew dependencyInsight --dependency org.springframework.boot
        
        echo -e "\n=== BUILD ENVIRONMENT ==="
        ./gradlew buildEnvironment
    } > "$deps_report" 2>&1
    
    success "Dependency analysis saved to: $deps_report"
}

# Build failure analysis
analyze_build_failure() {
    info "Analyzing build failure..."
    
    local failure_log="${DIAGNOSTICS_DIR}/logs/failure-analysis-${TIMESTAMP}.log"
    
    # Attempt build with detailed logging
    if ! ./gradlew build --info --stacktrace > "$failure_log" 2>&1; then
        error "Build failed - analyzing errors..."
        
        # Extract common error patterns
        local error_patterns="${DIAGNOSTICS_DIR}/reports/error-patterns-${TIMESTAMP}.txt"
        
        {
            echo "=== COMPILATION ERRORS ==="
            grep -A 5 -B 5 "Compilation failed" "$failure_log" || echo "No compilation errors found"
            
            echo -e "\n=== DEPENDENCY RESOLUTION ERRORS ==="
            grep -A 3 -B 3 "Could not resolve" "$failure_log" || echo "No dependency resolution errors found"
            
            echo -e "\n=== TEST FAILURES ==="
            grep -A 10 -B 5 "FAILED" "$failure_log" | grep -E "(test|Test)" || echo "No test failures found"
            
            echo -e "\n=== PLUGIN ERRORS ==="
            grep -A 3 -B 3 "plugin" "$failure_log" | grep -i error || echo "No plugin errors found"
            
            echo -e "\n=== SPRING BOOT SPECIFIC ERRORS ==="
            grep -A 5 -B 5 -i "spring\|boot" "$failure_log" | grep -i error || echo "No Spring Boot errors found"
            
        } > "$error_patterns"
        
        error "Error patterns extracted to: $error_patterns"
        return 1
    else
        success "Build completed successfully"
        return 0
    fi
}

# Test specific modules
test_modules() {
    info "Testing individual modules..."
    
    local modules=("common:common-core" "common:common-web" "common:common-security" 
                   "domain:user-domain" "infrastructure:data-access" 
                   "application:user-api" "application:batch-app")
    
    local module_results="${DIAGNOSTICS_DIR}/reports/module-test-results-${TIMESTAMP}.txt"
    
    {
        echo "=== MODULE TEST RESULTS ==="
        echo "Timestamp: $(date)"
        echo
    } > "$module_results"
    
    for module in "${modules[@]}"; do
        info "Testing module: $module"
        
        {
            echo "--- Module: $module ---"
            if ./gradlew ":$module:test" --info 2>&1; then
                echo "Status: PASSED"
            else
                echo "Status: FAILED"
            fi
            echo
        } >> "$module_results"
    done
    
    success "Module test results saved to: $module_results"
}

# Configuration validation
validate_configuration() {
    info "Validating project configuration..."
    
    local config_report="${DIAGNOSTICS_DIR}/reports/configuration-validation-${TIMESTAMP}.txt"
    
    {
        echo "=== CONFIGURATION VALIDATION ==="
        echo "Timestamp: $(date)"
        echo
        
        echo "--- Gradle Configuration ---"
        if [[ -f "build.gradle" ]]; then
            echo "✓ Root build.gradle exists"
            echo "Spring Boot version: $(grep -o "spring-boot.*version.*'[^']*'" build.gradle || echo "Not found")"
        else
            echo "✗ Root build.gradle missing"
        fi
        
        echo -e "\n--- Settings Configuration ---"
        if [[ -f "settings.gradle" ]]; then
            echo "✓ settings.gradle exists"
            echo "Included projects: $(grep -c "include" settings.gradle || echo "0")"
        else
            echo "✗ settings.gradle missing"
        fi
        
        echo -e "\n--- Application Configurations ---"
        find . -name "application.yml" -o -name "application.properties" | while read -r config_file; do
            echo "✓ Found: $config_file"
        done
        
        echo -e "\n--- Module Build Files ---"
        find . -name "build.gradle" -not -path "./build.gradle" | while read -r build_file; do
            echo "✓ Found: $build_file"
        done
        
    } > "$config_report"
    
    success "Configuration validation saved to: $config_report"
}

# Generate diagnostic report
generate_diagnostic_report() {
    info "Generating comprehensive diagnostic report..."
    
    local report="${DIAGNOSTICS_DIR}/DIAGNOSTIC_REPORT_${TIMESTAMP}.md"
    
    cat > "$report" << 'EOF'
# Build Diagnostics Report

Generated: %TIMESTAMP%

## Summary
This report contains comprehensive diagnostics for build failures and dependency issues.

## Files Generated
- `system-info.txt` - System and environment information
- `dependencies-*.txt` - Dependency analysis and trees
- `failure-analysis-*.log` - Detailed build failure logs
- `error-patterns-*.txt` - Extracted error patterns and common issues
- `module-test-results-*.txt` - Individual module test results
- `configuration-validation-*.txt` - Project configuration validation

## Analysis Steps

### 1. System Information
Check system compatibility:
- Java version compatibility with Spring Boot
- Gradle version compatibility
- Operating system specific issues

### 2. Dependency Analysis
Review dependency conflicts:
- Version conflicts between dependencies
- Missing or incompatible transitive dependencies
- Circular dependency issues

### 3. Build Failure Patterns
Common failure patterns:
- Compilation errors due to API changes
- Plugin compatibility issues
- Configuration errors
- Test failures

### 4. Module Testing
Individual module analysis:
- Identify which modules are failing
- Isolate dependency issues per module
- Test module interdependencies

### 5. Configuration Validation
Validate project setup:
- Gradle build scripts
- Application configurations
- Module structure

## Recommendations

Based on the diagnostic results, follow these steps:

1. **Review error patterns** - Start with the most critical errors
2. **Check compatibility matrix** - Ensure all versions are compatible
3. **Update systematically** - Update related dependencies together
4. **Test incrementally** - Test each change before proceeding

## Next Steps

1. Review all generated reports
2. Address critical errors first
3. Update dependencies following compatibility guidelines
4. Re-run diagnostics after changes

EOF

    # Replace timestamp placeholder
    sed -i.bak "s/%TIMESTAMP%/$(date)/" "$report" && rm "$report.bak" 2>/dev/null || true
    
    success "Diagnostic report generated: $report"
}

# Main execution
main() {
    info "Starting Dependabot PR Analysis..."
    
    cd "${PROJECT_ROOT}"
    init_analysis_dir
    
    # Check for GitHub CLI (optional for local analysis)
    if check_gh_cli; then
        get_dependabot_prs
    else
        warning "GitHub CLI not available - skipping PR fetching"
    fi
    
    analyze_current_dependencies
    generate_compatibility_matrix
    analyze_build_failures
    run_build_test
    generate_update_recommendations
    generate_pr_review_checklist
    create_pr_review_script
    create_build_diagnostics
    
    success "Analysis completed! Check ${ANALYSIS_DIR} for all reports and tools."
    
    info "Generated tools:"
    info "- Dependency analysis: ${ANALYSIS_DIR}"
    info "- PR review script: ${PROJECT_ROOT}/scripts/auto-review-dependabot-pr.sh"
    info "- Build diagnostics: ${PROJECT_ROOT}/scripts/build-diagnostics.sh"
}

# Run main function
main "$@"

EOF
    
    chmod +x "$diagnostics_script"
    success "Build diagnostics script created: $diagnostics_script"
}

# Main execution
main() {
    info "Starting Dependabot PR Analysis..."
    
    cd "${PROJECT_ROOT}"
    init_analysis_dir
    
    # Check for GitHub CLI (optional for local analysis)
    if check_gh_cli; then
        get_dependabot_prs
    else
        warning "GitHub CLI not available - skipping PR fetching"
    fi
    
    analyze_current_dependencies
    generate_compatibility_matrix
    analyze_build_failures
    run_build_test
    generate_update_recommendations
    generate_pr_review_checklist
    create_pr_review_script
    create_build_diagnostics
    
    success "Analysis completed! Check ${ANALYSIS_DIR} for all reports and tools."
    
    info "Generated tools:"
    info "- Dependency analysis: ${ANALYSIS_DIR}"
    info "- PR review script: ${PROJECT_ROOT}/scripts/auto-review-dependabot-pr.sh"
    info "- Build diagnostics: ${PROJECT_ROOT}/scripts/build-diagnostics.sh"
}

# Help function
show_help() {
    cat << EOF
Dependabot PR Analyzer

Usage: $0 [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    --build-test        Run build test only
    --analyze-deps      Analyze dependencies only
    --generate-reports  Generate reports only

DESCRIPTION:
    This tool provides comprehensive analysis of Dependabot PRs including:
    - Current dependency analysis
    - Compatibility matrix generation
    - Build failure prediction
    - Automated PR review capabilities
    - Build diagnostics tools

EXAMPLES:
    $0                  # Full analysis
    $0 --build-test     # Test current build
    $0 --analyze-deps   # Analyze dependencies only

EOF
}

# Handle command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    --build-test)
        init_analysis_dir
        run_build_test
        exit 0
        ;;
    --analyze-deps)
        init_analysis_dir
        analyze_current_dependencies
        generate_compatibility_matrix
        exit 0
        ;;
    --generate-reports)
        init_analysis_dir
        generate_update_recommendations
        generate_pr_review_checklist
        exit 0
        ;;
    "")
        main
        ;;
    *)
        error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac