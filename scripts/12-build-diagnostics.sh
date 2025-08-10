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

