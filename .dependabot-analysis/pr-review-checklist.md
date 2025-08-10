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

