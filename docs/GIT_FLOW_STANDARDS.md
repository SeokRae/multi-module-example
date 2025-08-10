# Git Flow 표준화 가이드
**Multi-Module E-Commerce Platform - Git Workflow Standards**

## 📋 개요
본 문서는 멀티모듈 Spring Boot 프로젝트의 Git 워크플로우 표준을 정의하며, 팀 협업과 CI/CD 파이프라인을 위한 일관된 브랜치 관리 및 커밋 규칙을 제시합니다.

## 🌳 브랜치 전략 (Git Flow Model)

### 메인 브랜치
```
main (production)     ←── 배포 가능한 안정 버전
├── develop          ←── 개발 통합 브랜치
├── release/v1.0.0   ←── 릴리즈 준비 브랜치
├── hotfix/critical  ←── 긴급 수정 브랜치
└── feature/user-api ←── 기능 개발 브랜치
```

#### 1. **main** (보호된 브랜치)
- **용도**: 배포 가능한 안정 버전
- **규칙**: 
  - Direct push 금지 (Pull Request 필수)
  - 최소 2명 이상의 Code Review 필수
  - 모든 테스트 통과 후 merge
  - Semantic Versioning 태그 적용

#### 2. **develop** (통합 브랜치)
- **용도**: 개발 중인 기능들의 통합
- **규칙**:
  - feature 브랜치들이 merge되는 곳
  - 안정화 후 release 브랜치 생성
  - Direct push 권장하지 않음

#### 3. **feature/*** (기능 브랜치)
- **용도**: 새로운 기능 개발
- **명명 규칙**: `feature/[phase-number]-[feature-name]`
- **예시**: 
  - `feature/phase1-user-authentication`
  - `feature/phase2-product-management`
  - `feature/phase3-redis-cache`

#### 4. **release/*** (릴리즈 브랜치)
- **용도**: 배포 준비 및 버그 수정
- **명명 규칙**: `release/v[major].[minor].[patch]`
- **예시**: `release/v1.0.0`, `release/v1.1.0`

#### 5. **hotfix/*** (긴급 수정 브랜치)
- **용도**: 프로덕션 긴급 버그 수정
- **명명 규칙**: `hotfix/[issue-description]`
- **예시**: `hotfix/security-vulnerability`, `hotfix/payment-error`

## 🔄 워크플로우 절차

### 1. 기능 개발 워크플로우
```bash
# 1. develop 브랜치에서 feature 브랜치 생성
git checkout develop
git pull origin develop
git checkout -b feature/phase2-product-api

# 2. 기능 개발 및 커밋
git add .
git commit -m "feat(product): implement product CRUD API"

# 3. 정기적으로 develop과 동기화
git fetch origin
git rebase origin/develop

# 4. Push 및 Pull Request 생성
git push origin feature/phase2-product-api
# GitHub/GitLab에서 PR 생성

# 5. Code Review 후 merge
# PR이 승인되면 develop으로 merge
```

### 2. 릴리즈 워크플로우
```bash
# 1. develop에서 release 브랜치 생성
git checkout develop
git pull origin develop
git checkout -b release/v1.0.0

# 2. 버전 번호 업데이트
# build.gradle, package.json 등 버전 정보 수정

# 3. 릴리즈 준비 커밋
git commit -m "chore(release): prepare v1.0.0"

# 4. main과 develop에 merge
git checkout main
git merge release/v1.0.0
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin main --tags

git checkout develop
git merge release/v1.0.0
git push origin develop
```

### 3. 긴급 수정 워크플로우
```bash
# 1. main에서 hotfix 브랜치 생성
git checkout main
git pull origin main
git checkout -b hotfix/critical-security-fix

# 2. 버그 수정 및 커밋
git commit -m "fix(security): resolve critical vulnerability"

# 3. main과 develop 양쪽에 merge
git checkout main
git merge hotfix/critical-security-fix
git tag -a v1.0.1 -m "Hotfix v1.0.1"
git push origin main --tags

git checkout develop
git merge hotfix/critical-security-fix
git push origin develop
```

## 📝 커밋 메시지 표준

### Conventional Commits 규칙 사용
```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

#### 커밋 타입 (Type)
- **feat**: 새로운 기능 추가
- **fix**: 버그 수정
- **docs**: 문서 변경
- **style**: 코드 스타일 변경 (세미콜론, 포매팅 등)
- **refactor**: 코드 리팩토링 (기능 변경 없음)
- **test**: 테스트 코드 추가/수정
- **chore**: 빌드 프로세스, 의존성 등 변경
- **perf**: 성능 개선
- **ci**: CI/CD 설정 변경
- **build**: 빌드 시스템 변경

#### 스코프 (Scope) - 모듈 기반
- **user**: User 도메인 관련
- **product**: Product 도메인 관련
- **order**: Order 도메인 관련
- **auth**: 인증/인가 관련
- **api**: API 레이어
- **db**: 데이터베이스 관련
- **security**: 보안 관련
- **cache**: 캐싱 관련
- **batch**: 배치 처리 관련

#### 커밋 메시지 예시
```bash
# 좋은 예시
feat(user): implement JWT authentication system
fix(product): resolve product search pagination issue
docs(api): update user API documentation
test(order): add integration tests for order creation
chore(deps): upgrade Spring Boot to 3.2.2

# 나쁜 예시 (비추천)
git commit -m "bug fix"
git commit -m "update code"
git commit -m "working on features"
```

## 🏷️ 태그 및 버전 관리

### Semantic Versioning (SemVer) 적용
```
MAJOR.MINOR.PATCH
```

#### 버전 증가 규칙
- **MAJOR**: API 호환성이 깨지는 변경 (1.0.0 → 2.0.0)
- **MINOR**: 하위 호환성 유지하며 기능 추가 (1.0.0 → 1.1.0)  
- **PATCH**: 하위 호환성 유지하며 버그 수정 (1.0.0 → 1.0.1)

#### 태그 명명 규칙
```bash
# 정식 릴리즈
v1.0.0, v1.1.0, v2.0.0

# 프리릴리즈
v1.0.0-alpha.1, v1.0.0-beta.1, v1.0.0-rc.1

# 태그 생성 및 푸시
git tag -a v1.0.0 -m "Release v1.0.0: Complete Phase 1"
git push origin --tags
```

## 🔍 Pull Request 규칙

### PR 템플릿
```markdown
## 📋 변경 사항
- [ ] 새로운 기능 추가
- [ ] 버그 수정
- [ ] 리팩토링
- [ ] 문서 업데이트
- [ ] 테스트 추가

## 🎯 관련 이슈
Closes #123

## 📝 상세 설명
### 변경된 내용
- User API에 JWT 인증 시스템 추가
- Password 암호화 로직 구현
- Role 기반 접근 제어 적용

### 테스트 내용
- [ ] 단위 테스트 통과
- [ ] 통합 테스트 통과
- [ ] API 테스트 통과

## 🧪 테스트 방법
```bash
./gradlew test
./gradlew :application:user-api:bootRun
curl -X POST http://localhost:8080/api/v1/auth/login
```

## ⚠️ 주의사항
- 환경변수 JWT_SECRET 설정 필요
- 데이터베이스 마이그레이션 필요

## 📸 스크린샷
(필요한 경우 UI 변경사항 첨부)
```

### PR 승인 규칙
1. **최소 리뷰어**: 2명 이상 승인 필요
2. **테스트 통과**: 모든 자동화 테스트 통과 필수
3. **Conflict 해결**: Merge conflict 없어야 함
4. **문서 업데이트**: API 변경시 문서 업데이트 필수

## 🚀 CI/CD 파이프라인 연동

### GitHub Actions 워크플로우
```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          java-version: '17'
      - name: Run tests
        run: ./gradlew test
      
  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Build and deploy
        run: ./gradlew build bootJar
```

### 브랜치별 자동화 규칙
- **main**: 배포 자동화 (Production)
- **develop**: 통합 테스트 및 스테이징 배포
- **feature/***: 단위 테스트 및 코드 품질 검사
- **release/***: 전체 테스트 스위트 실행

## 📊 코드 품질 관리

### Pre-commit Hooks 설정
```bash
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: gradle-test
        name: Run Gradle tests
        entry: ./gradlew test
        language: system
        pass_filenames: false
      
      - id: checkstyle
        name: Run Checkstyle
        entry: ./gradlew checkstyleMain
        language: system
        pass_filenames: false
```

### 코드 리뷰 체크리스트
- [ ] **기능 요구사항** 충족
- [ ] **코드 품질** (가독성, 재사용성)
- [ ] **테스트 커버리지** 80% 이상
- [ ] **보안 취약점** 없음
- [ ] **성능 영향** 고려
- [ ] **문서화** 적절성
- [ ] **API 호환성** 유지

## 🔧 도구 및 설정

### Git 설정
```bash
# Git 사용자 설정
git config --global user.name "Your Name"
git config --global user.email "your.email@company.com"

# 커밋 메시지 템플릿 설정
git config --global commit.template ~/.gitmessage

# Push 기본 설정
git config --global push.default simple
git config --global pull.rebase true
```

### IDE 설정 (.gitignore)
```
# Build outputs
build/
target/
*.jar
*.war

# IDE files
.idea/
.vscode/
*.iml

# OS files
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# Environment
.env
application-*.yml
```

## 📋 체크리스트

### 개발자 체크리스트
- [ ] 적절한 브랜치 명명 규칙 사용
- [ ] Conventional Commits 메시지 작성
- [ ] 코드 리뷰 요청 전 자체 테스트 완료
- [ ] Conflict 해결 후 rebase 수행
- [ ] 관련 문서 업데이트

### 리뷰어 체크리스트
- [ ] 코드 품질 및 아키텍처 적합성
- [ ] 테스트 코드 작성 및 커버리지
- [ ] 보안 및 성능 고려사항
- [ ] API 문서화 완료
- [ ] 브랜치 전략 준수

### 릴리즈 매니저 체크리스트
- [ ] 모든 테스트 통과 확인
- [ ] 버전 번호 정확성 검증
- [ ] 릴리즈 노트 작성 완료
- [ ] 배포 환경 설정 확인
- [ ] 롤백 계획 수립

---

## 🎯 적용 예시

### Phase 기반 개발 예시
```bash
# Phase 1: User Management 개발
git checkout -b feature/phase1-user-domain
git commit -m "feat(user): implement User entity and repository"
git commit -m "feat(auth): add JWT authentication system"
git commit -m "feat(api): implement user CRUD endpoints"
git commit -m "docs(user): add API documentation"

# Phase 1 완료 후 통합
git checkout develop
git merge feature/phase1-user-domain
git tag -a v0.1.0 -m "Phase 1: User Management Complete"

# Phase 2: Product Management 시작
git checkout -b feature/phase2-product-domain
```

이 Git Flow 표준을 통해 팀 전체가 일관된 워크플로우를 유지하고, 안정적인 CI/CD 파이프라인을 구축할 수 있습니다.

**💡 핵심 원칙**: 작은 단위의 잦은 커밋, 명확한 커밋 메시지, 철저한 코드 리뷰를 통해 코드 품질을 유지합니다.