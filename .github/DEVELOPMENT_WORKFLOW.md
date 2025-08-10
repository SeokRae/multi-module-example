# 🌿 Git Flow Development Workflow

> **Multi-Module E-Commerce Platform** 개발을 위한 브랜치 기반 워크플로우

## 🎯 워크플로우 개요

이 프로젝트는 **Git Flow** 기반의 브랜치 전략을 사용합니다:

```
main (프로덕션)
├── develop (개발)
│   ├── feature/phase-3-redis-cache
│   ├── feature/product-api-implementation  
│   ├── hotfix/security-patch-jjwt
│   └── release/v2.0.0
└── hotfix/critical-security-fix
```

## 🌱 브랜치 유형 및 명명 규칙

### 1. 메인 브랜치
- **`main`**: 프로덕션 릴리스 브랜치
- **`develop`**: 개발 통합 브랜치

### 2. 지원 브랜치 
- **`feature/*`**: 새로운 기능 개발
- **`release/*`**: 릴리스 준비
- **`hotfix/*`**: 긴급 수정
- **`bugfix/*`**: 일반 버그 수정

### 3. 브랜치 명명 규칙

#### Feature 브랜치
```bash
feature/phase-[number]-[description]     # Phase별 개발
feature/api-[domain-name]               # API 구현
feature/[component-name]-[description]  # 일반 기능

# 예시:
feature/phase-3-redis-integration
feature/api-product-management
feature/security-jwt-enhancement
feature/batch-order-statistics
```

#### Release 브랜치
```bash
release/v[major].[minor].[patch]
release/v[major].[minor].[patch]-rc[number]

# 예시:
release/v1.1.0
release/v2.0.0-rc1
```

#### Hotfix 브랜치
```bash
hotfix/[issue-type]-[brief-description]
hotfix/security-[vulnerability-name]

# 예시:
hotfix/security-jjwt-vulnerability
hotfix/critical-database-connection
hotfix/performance-memory-leak
```

#### Bugfix 브랜치
```bash
bugfix/[component]-[issue-description]

# 예시:
bugfix/user-api-validation-error
bugfix/order-status-transition-bug
```

## 🔄 워크플로우 프로세스

### 1. Feature 개발 프로세스

```bash
# 1. develop 브랜치에서 시작
git checkout develop
git pull origin develop

# 2. 새로운 feature 브랜치 생성
git checkout -b feature/phase-3-redis-integration

# 3. 개발 작업 수행
# ... 코드 구현 ...

# 4. 커밋 (Conventional Commits 사용)
git add .
git commit -m "feat(cache): implement Redis caching for product data

- Add RedisConfig for cache configuration
- Implement ProductCacheService with TTL settings
- Add cache invalidation on product updates
- Include integration tests for cache functionality

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# 5. 원격 브랜치에 푸시
git push origin feature/phase-3-redis-integration

# 6. Pull Request 생성 (GitHub에서)
gh pr create --title "✨ feat: Implement Redis caching system (Phase 3)" \
  --body "$(cat <<'EOF'
## 🎯 Phase 3: Redis Caching System

### ✅ 완료된 작업
- [x] Redis 설정 및 연결 구성
- [x] Product 데이터 캐싱 구현
- [x] 캐시 무효화 로직 추가
- [x] 통합 테스트 작성

### 🧪 테스트 결과
- Unit Tests: ✅ 통과
- Integration Tests: ✅ 통과
- Performance Tests: ✅ 30% 성능 향상

### 📊 성능 지표
- 상품 조회 응답시간: 200ms → 50ms
- 캐시 적중률: 85%+
- 메모리 사용량: 적정 수준

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)" \
  --assignee @me \
  --label "feature,phase-3,caching"

# 7. 코드 리뷰 및 머지 (GitHub에서 수행)
```

### 2. Release 프로세스

```bash
# 1. develop에서 release 브랜치 생성
git checkout develop
git pull origin develop
git checkout -b release/v1.1.0

# 2. 릴리스 준비 (버전 업데이트, 문서 정리)
# ... 릴리스 준비 작업 ...

# 3. 릴리스 커밋
git commit -m "chore(release): prepare v1.1.0 release

- Update version to 1.1.0
- Update CHANGELOG.md
- Final documentation review

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# 4. main으로 머지 및 태깅
git checkout main
git merge --no-ff release/v1.1.0
git tag -a v1.1.0 -m "Release version 1.1.0"

# 5. develop으로 백머지
git checkout develop
git merge --no-ff release/v1.1.0

# 6. release 브랜치 정리
git branch -d release/v1.1.0
git push origin --delete release/v1.1.0
```

### 3. Hotfix 프로세스

```bash
# 1. main에서 hotfix 브랜치 생성
git checkout main
git pull origin main
git checkout -b hotfix/security-jjwt-critical

# 2. 긴급 수정 작업
# ... 보안 패치 적용 ...

# 3. 긴급 커밋
git commit -m "fix(security): apply critical JJWT security patch

- Update JJWT from 0.12.3 to 0.12.6
- Fix JWT token validation vulnerability
- Add security tests for token verification

🚨 Critical Security Fix
🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# 4. main과 develop에 머지
git checkout main
git merge --no-ff hotfix/security-jjwt-critical
git tag -a v1.0.1 -m "Hotfix v1.0.1 - Security patch"

git checkout develop
git merge --no-ff hotfix/security-jjwt-critical

# 5. hotfix 브랜치 정리
git branch -d hotfix/security-jjwt-critical
```

## 📝 커밋 메시지 컨벤션

### Conventional Commits 사용
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Type 분류
- **feat**: 새로운 기능 추가
- **fix**: 버그 수정  
- **docs**: 문서 관련 변경
- **style**: 코드 formatting, 세미콜론 누락 등
- **refactor**: 코드 리팩토링
- **test**: 테스트 관련
- **chore**: 빌드, 설정 관련
- **perf**: 성능 개선
- **security**: 보안 관련 수정

### Scope 예시
- **api**: API 관련
- **domain**: 도메인 로직
- **auth**: 인증/인가
- **cache**: 캐싱
- **batch**: 배치 처리
- **security**: 보안
- **deps**: 의존성

### 메시지 예시
```bash
# Feature 개발
git commit -m "feat(api): implement Product API endpoints

- Add ProductController with CRUD operations
- Include search and filtering capabilities  
- Add comprehensive input validation
- Include API documentation

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Bug 수정
git commit -m "fix(auth): resolve JWT token refresh issue

- Fix token expiration validation logic
- Add proper error handling for expired tokens
- Update token refresh endpoint
- Add unit tests for token validation

Fixes #123

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# 문서 업데이트
git commit -m "docs: update API documentation for Order endpoints

- Add comprehensive API examples
- Update request/response schemas
- Include error handling documentation
- Add authentication requirements

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## 🛡️ 브랜치 보호 규칙

### main 브랜치 보호
- ✅ Direct push 금지
- ✅ Pull Request 필수
- ✅ 최소 1명 이상 리뷰 필수
- ✅ Status check 통과 필수
- ✅ Branch up-to-date 필수

### develop 브랜치 보호  
- ✅ Pull Request 필수
- ✅ CI 빌드 통과 필수
- ✅ 테스트 통과 필수

## 📋 Pull Request 체크리스트

### 기본 체크리스트
- [ ] 코드가 빌드되는가?
- [ ] 모든 테스트가 통과하는가?
- [ ] 코드 스타일이 일관적인가?
- [ ] 문서가 업데이트되었는가?
- [ ] Breaking change가 있다면 CHANGELOG에 기록했는가?

### Phase별 체크리스트
- [ ] Phase 목표에 부합하는가?
- [ ] 이전 Phase와의 호환성이 유지되는가?
- [ ] 아키텍처 원칙을 준수하는가?
- [ ] 성능 요구사항을 만족하는가?

## 🚀 자동화 도구

### GitHub Actions
```yaml
# .github/workflows/branch-protection.yml
name: Branch Protection
on:
  pull_request:
    branches: [ main, develop ]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run build and tests
        run: ./gradlew clean build test
      - name: Check code quality  
        run: ./gradlew check
```

### Branch 관리 스크립트
```bash
# scripts/create-feature-branch.sh
#!/bin/bash
BRANCH_NAME="$1"

if [ -z "$BRANCH_NAME" ]; then
    echo "❌ Usage: ./create-feature-branch.sh <branch-name>"
    exit 1
fi

echo "🌿 Creating feature branch: feature/$BRANCH_NAME"
git checkout develop
git pull origin develop
git checkout -b "feature/$BRANCH_NAME"
echo "✅ Feature branch created successfully!"
echo "💡 Start developing and commit your changes"
echo "📝 Remember to follow the commit message convention"
```

## 📊 워크플로우 모니터링

### 브랜치 현황 대시보드
```bash
# 활성 브랜치 목록
git branch -r --sort=-committerdate

# 최근 활동 브랜치
git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short) %(committerdate:relative)'

# 브랜치별 커밋 수
git rev-list --count HEAD ^develop
```

---

**워크플로우 버전**: v1.0  
**최종 업데이트**: 2025-01-10  
**검토자**: Claude Code AI  
**다음 업데이트**: Phase 3 개발 시작시