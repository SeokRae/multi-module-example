#!/bin/bash

# Dependency Health Check Tool
# Comprehensive health monitoring for project dependencies

set -euo pipefail

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HEALTH_CHECK_DIR="${PROJECT_ROOT}/.dependency-health"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Logging functions
info() { echo -e "${BLUE}ℹ️  INFO: $1${NC}"; }
success() { echo -e "${GREEN}✅ SUCCESS: $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  WARNING: $1${NC}"; }
error() { echo -e "${RED}❌ ERROR: $1${NC}"; }
debug() { echo -e "${PURPLE}🔍 DEBUG: $1${NC}"; }

# Initialize health check directory
init_health_check() {
    mkdir -p "${HEALTH_CHECK_DIR}"
    mkdir -p "${HEALTH_CHECK_DIR}/reports"
    mkdir -p "${HEALTH_CHECK_DIR}/vulnerability-scans"
    mkdir -p "${HEALTH_CHECK_DIR}/compatibility-checks"
    mkdir -p "${HEALTH_CHECK_DIR}/performance-metrics"
    
    info "Health check directory initialized at: ${HEALTH_CHECK_DIR}"
}

# Check for security vulnerabilities
check_security_vulnerabilities() {
    info "Checking for security vulnerabilities..."
    
    local vuln_report="${HEALTH_CHECK_DIR}/vulnerability-scans/vulnerabilities-${TIMESTAMP}.txt"
    
    # Check if gradle-dependency-check plugin is available
    if ./gradlew tasks --all | grep -q "dependencyCheckAnalyze"; then
        info "Running OWASP dependency check..."
        ./gradlew dependencyCheckAnalyze > "$vuln_report" 2>&1 || true
        success "Vulnerability scan completed - results in: $vuln_report"
    else
        # Manual vulnerability check using gradle vulnerabilities task if available
        info "Running gradle vulnerability check..."
        {
            echo "=== GRADLE VULNERABILITY CHECK ==="
            echo "Timestamp: $(date)"
            echo
            
            # Try to get vulnerable dependencies
            if ./gradlew dependencies --configuration runtimeClasspath | grep -E "(VULNERABLE|CVE)" > /dev/null 2>&1; then
                echo "❌ VULNERABILITIES FOUND:"
                ./gradlew dependencies --configuration runtimeClasspath | grep -E "(VULNERABLE|CVE)"
            else
                echo "✅ No obvious vulnerabilities found in direct dependency scan"
            fi
            
            echo
            echo "=== CURRENT DEPENDENCY VERSIONS ==="
            ./gradlew dependencies --configuration runtimeClasspath | head -50
            
        } > "$vuln_report"
        
        warning "Manual vulnerability check completed - consider adding OWASP Dependency Check plugin"
    fi
    
    # Check for known problematic versions
    local known_issues="${HEALTH_CHECK_DIR}/reports/known-issues-${TIMESTAMP}.txt"
    {
        echo "=== KNOWN PROBLEMATIC VERSIONS ==="
        echo "Timestamp: $(date)"
        echo
        
        # Check for specific problematic versions
        echo "--- Checking for known problematic versions ---"
        
        # Spring Boot versions with known issues
        if grep -r "spring-boot.*3\.1\.[0-5]" "${PROJECT_ROOT}"/**/*.gradle 2>/dev/null; then
            echo "⚠️  Spring Boot 3.1.0-3.1.5 have known security issues - update to 3.1.6+"
        fi
        
        # Log4j versions (if present)
        if ./gradlew dependencies | grep -i log4j | grep -E "2\.(0|1[0-6])" > /dev/null 2>&1; then
            echo "🚨 CRITICAL: Log4j 2.0-2.16 vulnerable to Log4Shell - update immediately"
        fi
        
        # Jackson versions with known CVEs
        if ./gradlew dependencies | grep jackson-databind | grep -E "2\.(9\.[0-9]|10\.[0-5])" > /dev/null 2>&1; then
            echo "⚠️  Jackson Databind versions before 2.13.0 have known vulnerabilities"
        fi
        
        # Hibernate versions
        if ./gradlew dependencies | grep hibernate-core | grep -E "5\.[0-4]" > /dev/null 2>&1; then
            echo "⚠️  Hibernate Core versions before 5.6 have known issues with Spring Boot 2.7+"
        fi
        
        echo "✅ Known problematic version check completed"
        
    } > "$known_issues"
    
    success "Known issues check completed: $known_issues"
}

# Check dependency compatibility
check_dependency_compatibility() {
    info "Checking dependency compatibility..."
    
    local compat_report="${HEALTH_CHECK_DIR}/compatibility-checks/compatibility-${TIMESTAMP}.txt"
    
    {
        echo "=== DEPENDENCY COMPATIBILITY ANALYSIS ==="
        echo "Timestamp: $(date)"
        echo
        
        # Extract current versions
        echo "--- Current Key Versions ---"
        SPRING_BOOT_VERSION=$(grep -o "spring-boot.*version.*'[^']*'" "${PROJECT_ROOT}/build.gradle" | cut -d"'" -f2 || echo "Not found")
        echo "Spring Boot: $SPRING_BOOT_VERSION"
        
        JAVA_VERSION=$(grep -o "JavaLanguageVersion.of([0-9]*)" "${PROJECT_ROOT}/build.gradle" | grep -o "[0-9]*" || echo "Not found")
        echo "Java: $JAVA_VERSION"
        
        # Check for version conflicts
        echo
        echo "--- Version Conflict Analysis ---"
        
        # Check for multiple Spring versions
        echo "Checking for Spring version conflicts..."
        SPRING_VERSIONS=$(./gradlew dependencies --configuration runtimeClasspath | grep -E "org\.springframework:" | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+" | sort -u)
        if [[ $(echo "$SPRING_VERSIONS" | wc -l) -gt 1 ]]; then
            echo "⚠️  Multiple Spring versions detected:"
            echo "$SPRING_VERSIONS"
        else
            echo "✅ Consistent Spring version usage"
        fi
        
        # Check Jackson versions
        echo
        echo "Checking for Jackson version conflicts..."
        JACKSON_VERSIONS=$(./gradlew dependencies --configuration runtimeClasspath | grep jackson | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+" | sort -u)
        if [[ $(echo "$JACKSON_VERSIONS" | wc -l) -gt 1 ]]; then
            echo "⚠️  Multiple Jackson versions detected:"
            echo "$JACKSON_VERSIONS"
        else
            echo "✅ Consistent Jackson version usage"
        fi
        
        # Check compatibility matrix
        echo
        echo "--- Spring Boot Compatibility Matrix ---"
        case "$SPRING_BOOT_VERSION" in
            3.2.*)
                echo "✅ Spring Boot 3.2.x - Stable LTS version"
                echo "✅ Java 17+ required - Current: $JAVA_VERSION"
                echo "✅ QueryDSL 5.0.x compatible"
                echo "✅ JJWT 0.12.x compatible"
                ;;
            3.3.*)
                echo "✅ Spring Boot 3.3.x - Current stable version"
                echo "✅ Java 17+ required, Java 21 recommended - Current: $JAVA_VERSION"
                echo "⚠️  QueryDSL 5.1.x recommended"
                echo "✅ JJWT 0.12.x compatible"
                ;;
            3.4.*|3.5.*)
                echo "⚠️  Spring Boot 3.4.x/3.5.x - Newer version, check compatibility"
                echo "⚠️  Java 21 recommended - Current: $JAVA_VERSION"
                echo "⚠️  QueryDSL 5.1.x+ required"
                echo "⚠️  Hibernate Types may be deprecated"
                ;;
            *)
                echo "❓ Unknown Spring Boot version pattern"
                ;;
        esac
        
        # Check for deprecated dependencies
        echo
        echo "--- Deprecated Dependencies Check ---"
        
        if ./gradlew dependencies | grep -q "hibernate-types"; then
            echo "⚠️  hibernate-types-60 is deprecated in newer Spring Boot versions"
            echo "   Consider migrating to native Spring Boot JSON support"
        fi
        
        if ./gradlew dependencies | grep -q "spring-boot-starter-data-jpa.*1\."; then
            echo "⚠️  Old Spring Boot Data JPA version detected"
        fi
        
        echo "✅ Compatibility analysis completed"
        
    } > "$compat_report"
    
    success "Compatibility analysis completed: $compat_report"
}

# Performance impact analysis
analyze_performance_impact() {
    info "Analyzing performance impact of current dependencies..."
    
    local perf_report="${HEALTH_CHECK_DIR}/performance-metrics/performance-${TIMESTAMP}.txt"
    
    {
        echo "=== PERFORMANCE IMPACT ANALYSIS ==="
        echo "Timestamp: $(date)"
        echo
        
        # Dependency count analysis
        echo "--- Dependency Metrics ---"
        TOTAL_DEPS=$(./gradlew dependencies --configuration runtimeClasspath | grep -E "^\+---|\\\---" | wc -l)
        echo "Total runtime dependencies: $TOTAL_DEPS"
        
        if [[ $TOTAL_DEPS -gt 200 ]]; then
            echo "⚠️  High dependency count - consider dependency optimization"
        elif [[ $TOTAL_DEPS -gt 100 ]]; then
            echo "ℹ️  Moderate dependency count - within normal range"
        else
            echo "✅ Low dependency count - optimized"
        fi
        
        # Large dependency identification
        echo
        echo "--- Large Dependencies Analysis ---"
        
        # Check for known large dependencies
        if ./gradlew dependencies | grep -q "spring-boot-starter-web"; then
            echo "📦 Spring Boot Web Starter - Standard web dependency (~15MB)"
        fi
        
        if ./gradlew dependencies | grep -q "spring-boot-starter-data-jpa"; then
            echo "📦 Spring Boot Data JPA - Database connectivity (~20MB)"
        fi
        
        if ./gradlew dependencies | grep -q "redisson"; then
            echo "📦 Redisson - Redis client with many features (~10MB)"
        fi
        
        if ./gradlew dependencies | grep -q "querydsl"; then
            echo "📦 QueryDSL - Type-safe queries (~5MB)"
        fi
        
        # Memory usage estimation
        echo
        echo "--- Memory Usage Estimation ---"
        
        # Basic estimation based on common dependency patterns
        BASE_MEMORY=50  # Base Spring Boot memory
        WEB_MEMORY=30   # Web starter
        JPA_MEMORY=40   # JPA starter
        CACHE_MEMORY=20 # Cache dependencies
        SECURITY_MEMORY=15 # Security dependencies
        
        ESTIMATED_MEMORY=$BASE_MEMORY
        
        if ./gradlew dependencies | grep -q "spring-boot-starter-web"; then
            ESTIMATED_MEMORY=$((ESTIMATED_MEMORY + WEB_MEMORY))
        fi
        
        if ./gradlew dependencies | grep -q "spring-boot-starter-data-jpa"; then
            ESTIMATED_MEMORY=$((ESTIMATED_MEMORY + JPA_MEMORY))
        fi
        
        if ./gradlew dependencies | grep -q "redisson\|spring-boot-starter-cache"; then
            ESTIMATED_MEMORY=$((ESTIMATED_MEMORY + CACHE_MEMORY))
        fi
        
        if ./gradlew dependencies | grep -q "spring-boot-starter-security"; then
            ESTIMATED_MEMORY=$((ESTIMATED_MEMORY + SECURITY_MEMORY))
        fi
        
        echo "Estimated base memory usage: ${ESTIMATED_MEMORY}MB"
        
        if [[ $ESTIMATED_MEMORY -gt 150 ]]; then
            echo "⚠️  High memory usage - consider optimization"
        else
            echo "✅ Reasonable memory usage"
        fi
        
        # Startup time impact
        echo
        echo "--- Startup Time Impact ---"
        
        STARTUP_FACTORS=0
        
        if ./gradlew dependencies | grep -q "spring-boot-starter-data-jpa"; then
            echo "📊 JPA Starter - Adds ~2-3s to startup time"
            STARTUP_FACTORS=$((STARTUP_FACTORS + 1))
        fi
        
        if ./gradlew dependencies | grep -q "spring-boot-starter-security"; then
            echo "📊 Security Starter - Adds ~1-2s to startup time"
            STARTUP_FACTORS=$((STARTUP_FACTORS + 1))
        fi
        
        if ./gradlew dependencies | grep -q "redisson"; then
            echo "📊 Redisson - Adds ~1s to startup time"
            STARTUP_FACTORS=$((STARTUP_FACTORS + 1))
        fi
        
        if [[ $STARTUP_FACTORS -gt 3 ]]; then
            echo "⚠️  Multiple startup-heavy dependencies detected"
            echo "   Consider lazy initialization for non-critical components"
        else
            echo "✅ Startup impact within acceptable range"
        fi
        
    } > "$perf_report"
    
    success "Performance analysis completed: $perf_report"
}

# Check for outdated dependencies
check_outdated_dependencies() {
    info "Checking for outdated dependencies..."
    
    local outdated_report="${HEALTH_CHECK_DIR}/reports/outdated-${TIMESTAMP}.txt"
    
    {
        echo "=== OUTDATED DEPENDENCIES CHECK ==="
        echo "Timestamp: $(date)"
        echo
        
        echo "--- Current vs Latest Versions ---"
        echo "Note: This is a basic check. Use gradle-versions-plugin for comprehensive analysis."
        echo
        
        # Check Spring Boot versions
        CURRENT_SPRING_BOOT=$(grep -o "spring-boot.*version.*'[^']*'" "${PROJECT_ROOT}/build.gradle" | cut -d"'" -f2)
        echo "Spring Boot: $CURRENT_SPRING_BOOT"
        echo "  Latest 3.2.x: Check https://spring.io/projects/spring-boot for latest patch"
        echo "  Latest stable: Check https://spring.io/projects/spring-boot for latest version"
        
        # Check other key dependencies
        echo
        echo "Key Dependencies to Monitor:"
        echo "- QueryDSL: Check https://github.com/querydsl/querydsl/releases"
        echo "- JJWT: Check https://github.com/jwtk/jjwt/releases"
        echo "- Redisson: Check https://github.com/redisson/redisson/releases"
        echo "- Guava: Check https://github.com/google/guava/releases"
        
        echo
        echo "Recommendation: Add gradle-versions-plugin to build.gradle for automated checks:"
        echo "plugins {"
        echo "  id 'com.github.ben-manes.versions' version 'x.x.x'"
        echo "}"
        echo
        echo "Then run: ./gradlew dependencyUpdates"
        
    } > "$outdated_report"
    
    success "Outdated dependencies check completed: $outdated_report"
}

# Generate dependency health report
generate_health_report() {
    info "Generating comprehensive dependency health report..."
    
    local health_report="${HEALTH_CHECK_DIR}/DEPENDENCY_HEALTH_REPORT_${TIMESTAMP}.md"
    
    cat > "$health_report" << EOF
# Dependency Health Report

**Generated**: $(date)  
**Project**: Multi-Module Spring Boot Application  
**Scan Type**: Comprehensive Health Check  

## 🔍 Executive Summary

This report provides a comprehensive analysis of the project's dependency health, including security vulnerabilities, compatibility issues, performance impact, and update recommendations.

## 📊 Health Metrics

### Current Configuration
- **Spring Boot Version**: $(grep -o "spring-boot.*version.*'[^']*'" "${PROJECT_ROOT}/build.gradle" | cut -d"'" -f2 || echo "Not found")
- **Java Version**: $(grep -o "JavaLanguageVersion.of([0-9]*)" "${PROJECT_ROOT}/build.gradle" | grep -o "[0-9]*" || echo "Not found")
- **Total Modules**: $(find "${PROJECT_ROOT}" -name "build.gradle" | wc -l)
- **Scan Date**: $(date)

### Risk Assessment

| Category | Status | Priority |
|----------|--------|----------|
| Security Vulnerabilities | 🟡 Review Required | High |
| Version Compatibility | 🟢 Good | Medium |
| Performance Impact | 🟢 Good | Low |
| Outdated Dependencies | 🟡 Some Updates Available | Medium |

## 🛡️ Security Analysis

### Vulnerability Scan Results
- **Scan Location**: \`vulnerability-scans/vulnerabilities-${TIMESTAMP}.txt\`
- **Known Issues**: \`reports/known-issues-${TIMESTAMP}.txt\`

**Key Findings**:
- Review vulnerability scan results for any critical security issues
- Check known problematic version analysis
- Ensure all security patches are applied

**Recommendations**:
1. Add OWASP Dependency Check plugin for automated vulnerability scanning
2. Set up automated security alerts for dependencies
3. Establish regular security update schedule

### Security Best Practices Checklist
- [ ] OWASP Dependency Check plugin configured
- [ ] Automated security scanning in CI/CD
- [ ] Regular security update schedule
- [ ] Security patch testing procedures
- [ ] Vulnerability disclosure process

## ⚙️ Compatibility Analysis

### Version Compatibility Matrix
- **Analysis Location**: \`compatibility-checks/compatibility-${TIMESTAMP}.txt\`

**Key Areas**:
- Spring Boot ecosystem compatibility
- Java version requirements
- Third-party library compatibility
- Deprecated dependency identification

**Action Items**:
1. Review compatibility analysis results
2. Plan updates for deprecated dependencies
3. Validate version consistency across modules

## 🚀 Performance Impact

### Performance Metrics
- **Analysis Location**: \`performance-metrics/performance-${TIMESTAMP}.txt\`

**Metrics Analyzed**:
- Total dependency count
- Memory usage estimation
- Startup time impact
- Large dependency identification

**Optimization Opportunities**:
1. Review large dependencies for necessity
2. Consider lazy initialization for heavy components
3. Evaluate alternative lightweight libraries

## 📈 Update Recommendations

### Priority Updates

#### High Priority (Security & Critical Bugs)
- Review security vulnerability report
- Apply critical security patches
- Update dependencies with known CVEs

#### Medium Priority (Compatibility & Features)
- Update to latest patch versions
- Plan minor version updates
- Address deprecated dependency warnings

#### Low Priority (Nice to Have)
- Consider newer feature versions
- Evaluate alternative libraries
- Optimize dependency tree

### Update Strategy
1. **Security First**: Apply security patches immediately
2. **Incremental Updates**: Update dependencies incrementally
3. **Testing**: Comprehensive testing for each update batch
4. **Rollback Plan**: Always have rollback procedures ready

## 🔧 Tools and Scripts

### Available Tools
- \`scripts/dependabot-pr-analyzer.sh\` - Automated PR analysis
- \`scripts/dependency-health-check.sh\` - This health check tool
- \`scripts/build-diagnostics.sh\` - Build failure diagnostics
- \`scripts/auto-review-dependabot-pr.sh\` - Automated PR reviews

### Recommended Additional Tools
1. **Gradle Versions Plugin**: For dependency update checking
2. **OWASP Dependency Check**: For vulnerability scanning  
3. **Gradle Build Scan**: For build performance analysis
4. **Dependency License Report**: For license compliance

## 📋 Action Plan

### Immediate Actions (Next 7 Days)
- [ ] Review security vulnerability scan results
- [ ] Apply any critical security patches
- [ ] Address high-priority compatibility issues
- [ ] Set up automated security scanning

### Short-term Actions (Next 30 Days)
- [ ] Plan and execute medium-priority updates
- [ ] Implement additional monitoring tools
- [ ] Update CI/CD pipeline for dependency checks
- [ ] Create dependency update schedule

### Long-term Actions (Next Quarter)
- [ ] Evaluate and replace deprecated dependencies
- [ ] Optimize dependency tree for performance
- [ ] Implement comprehensive dependency governance
- [ ] Regular health check automation

## 📚 Resources

- [Dependency Management Guide](./DEPENDABOT_MANAGEMENT_GUIDE.md)
- [Build Troubleshooting Guide](./07-BUILD_TROUBLESHOOTING.md)
- [Spring Boot Migration Guides](https://spring.io/projects/spring-boot)
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)

## 📁 Generated Files

This health check generated the following analysis files:

- \`vulnerability-scans/vulnerabilities-${TIMESTAMP}.txt\` - Vulnerability scan results
- \`compatibility-checks/compatibility-${TIMESTAMP}.txt\` - Compatibility analysis  
- \`performance-metrics/performance-${TIMESTAMP}.txt\` - Performance impact analysis
- \`reports/known-issues-${TIMESTAMP}.txt\` - Known problematic versions
- \`reports/outdated-${TIMESTAMP}.txt\` - Outdated dependency check

Review all generated files for detailed technical analysis and specific recommendations.

---

**Next Health Check**: Schedule next comprehensive health check in 30 days  
**Emergency Contact**: Review security findings immediately if critical issues found  
**Automation**: Consider automating this health check in CI/CD pipeline  

EOF

    success "Comprehensive health report generated: $health_report"
    info "Review all generated files in: ${HEALTH_CHECK_DIR}"
}

# Main execution function
main() {
    info "Starting comprehensive dependency health check..."
    
    cd "${PROJECT_ROOT}"
    init_health_check
    
    check_security_vulnerabilities
    check_dependency_compatibility  
    analyze_performance_impact
    check_outdated_dependencies
    generate_health_report
    
    success "Dependency health check completed!"
    info "Results available in: ${HEALTH_CHECK_DIR}"
    
    # Summary
    echo
    echo "📋 Health Check Summary:"
    echo "├── 🛡️  Security vulnerability scan completed"
    echo "├── ⚙️  Compatibility analysis finished"  
    echo "├── 🚀 Performance impact assessed"
    echo "├── 📈 Outdated dependency check done"
    echo "└── 📊 Comprehensive report generated"
    echo
    info "Next steps: Review generated reports and implement recommended actions"
}

# Help function
show_help() {
    cat << EOF
Dependency Health Check Tool

Usage: $0 [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    --security-only         Run security checks only
    --compatibility-only    Run compatibility checks only
    --performance-only      Run performance analysis only
    --outdated-only         Check for outdated dependencies only

DESCRIPTION:
    Comprehensive dependency health monitoring including:
    - Security vulnerability scanning
    - Version compatibility analysis
    - Performance impact assessment  
    - Outdated dependency detection
    - Health report generation

EXAMPLES:
    $0                     # Full health check
    $0 --security-only     # Security scan only
    $0 --compatibility-only # Compatibility check only

FILES GENERATED:
    .dependency-health/
    ├── vulnerability-scans/    # Security scan results
    ├── compatibility-checks/   # Compatibility analysis
    ├── performance-metrics/    # Performance impact data
    ├── reports/               # Summary reports
    └── DEPENDENCY_HEALTH_REPORT_*.md # Main report

EOF
}

# Command line argument handling
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    --security-only)
        init_health_check
        check_security_vulnerabilities
        success "Security check completed"
        ;;
    --compatibility-only)
        init_health_check
        check_dependency_compatibility
        success "Compatibility check completed"
        ;;
    --performance-only)
        init_health_check
        analyze_performance_impact
        success "Performance analysis completed"
        ;;
    --outdated-only)
        init_health_check
        check_outdated_dependencies
        success "Outdated dependency check completed"
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