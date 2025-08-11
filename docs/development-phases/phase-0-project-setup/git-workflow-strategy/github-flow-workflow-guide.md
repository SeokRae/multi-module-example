# GitHub Flow 워크플로우 가이드

이 문서는 GitHub Flow로 전환한 후의 일상적인 개발 워크플로우를 설명합니다.

## 목차
1. [GitHub Flow 개요](#github-flow-개요)
2. [일상적인 개발 워크플로우](#일상적인-개발-워크플로우)
3. [브랜치 네이밍 규칙](#브랜치-네이밍-규칙)
4. [Pull Request 가이드라인](#pull-request-가이드라인)
5. [코드 리뷰 프로세스](#코드-리뷰-프로세스)
6. [헬퍼 도구 사용법](#헬퍼-도구-사용법)
7. [CI/CD와 배포](#cicd와-배포)
8. [문제 해결 가이드](#문제-해결-가이드)

## GitHub Flow 개요

### 핵심 원칙
1. **main 브랜치는 항상 배포 가능한 상태**
2. **모든 작업은 main에서 분기한 브랜치에서 진행**
3. **Pull Request를 통한 코드 리뷰 필수**
4. **병합 후 즉시 배포**

### 간단한 워크플로우
```
main → feature branch → Pull Request → Code Review → Merge → Deploy
```

## 일상적인 개발 워크플로우

### 1. 새로운 기능 개발 시작

#### 헬퍼 함수 사용 (권장)
```bash
# 헬퍼 함수 로드
source scripts/github-flow-helpers.sh

# 새 기능 시작
gf_start user-profile-update
```

#### 직접 Git 명령어 사용
```bash
git checkout main
git pull origin main
git checkout -b feature/user-profile-update
```

### 2. 개발 진행

#### 작은 단위로 자주 커밋
```bash
# 기능의 일부 구현
git add src/main/java/user/ProfileController.java
git commit -m "feat: add profile update endpoint"

# 테스트 추가
git add src/test/java/user/ProfileControllerTest.java  
git commit -m "test: add profile update endpoint tests"

# 문서 업데이트
git add docs/api/user-profile.md
git commit -m "docs: update user profile API documentation"
```

#### 정기적으로 main과 동기화
```bash
# 헬퍼 함수 사용
gf_sync

# 또는 직접 명령어
git fetch origin
git rebase origin/main
```

### 3. Pull Request 생성

#### 헬퍼 함수 사용
```bash
gf_pr "Add user profile update feature" "Implements user profile update with validation and tests"
```

#### GitHub CLI 사용
```bash
gh pr create \
  --title "Add user profile update feature" \
  --body "## 변경 내용
- 사용자 프로필 업데이트 API 엔드포인트 추가
- 입력 값 검증 로직 구현
- 단위 테스트 및 통합 테스트 추가

## 테스트
- [x] 단위 테스트 통과
- [x] 통합 테스트 통과
- [x] 수동 테스트 완료"
```

### 4. 코드 리뷰 대응

#### 리뷰 피드백 반영
```bash
# 피드백에 따른 수정
git add .
git commit -m "fix: address review feedback - add input validation"
git push origin feature/user-profile-update
```

### 5. 병합 후 정리

#### 자동 정리 (PR 병합 시 자동으로 원격 브랜치 삭제 설정)
```bash
# 로컬 브랜치만 정리
git checkout main
git pull origin main
git branch -d feature/user-profile-update
```

#### 헬퍼 함수로 일괄 정리
```bash
gf_cleanup
```

## 브랜치 네이밍 규칙

### 브랜치 타입별 접두사

#### 1. 기능 개발: `feature/`
```bash
feature/user-authentication
feature/payment-integration  
feature/search-optimization
feature/mobile-responsive-design
```

#### 2. 버그 수정: `bugfix/`
```bash
bugfix/login-timeout-issue
bugfix/payment-calculation-error
bugfix/search-results-pagination
```

#### 3. 문서 업데이트: `docs/`
```bash
docs/api-documentation-update
docs/readme-installation-guide
docs/architecture-decision-records
```

#### 4. 리팩토링: `refactor/`
```bash
refactor/database-query-optimization
refactor/service-layer-cleanup
refactor/frontend-component-structure
```

#### 5. 핫픽스: `hotfix/` (긴급 수정)
```bash
hotfix/security-vulnerability-patch
hotfix/critical-performance-issue
```

### 네이밍 가이드라인

#### 좋은 브랜치명 예시
- `feature/user-profile-management`
- `bugfix/email-validation-error`  
- `docs/api-endpoint-documentation`
- `refactor/payment-service-cleanup`

#### 피해야 할 브랜치명
- `feature/fix` (너무 애매함)
- `bugfix/bug` (구체성 부족)
- `feature/Feature123` (대소문자 혼용)
- `my-branch` (개인 소유 느낌)

## Pull Request 가이드라인

### PR 제목 작성 규칙

#### 형식
```
<타입>: <간결한 설명>

예시:
feat: Add user profile update functionality
fix: Resolve login timeout issue
docs: Update API documentation for v2.0
refactor: Optimize database query performance
```

### PR 설명 템플릿

```markdown
## 변경 내용
- [ ] 새로운 기능
- [ ] 버그 수정  
- [ ] 문서 업데이트
- [ ] 리팩토링
- [ ] 테스트 추가

## 설명
<!-- 변경 사항에 대한 상세한 설명 -->

## 관련 이슈
<!-- 관련된 GitHub 이슈 번호 (있는 경우) -->
Closes #123

## 테스트
- [ ] 단위 테스트 통과
- [ ] 통합 테스트 통과
- [ ] 수동 테스트 완료

## 스크린샷 (UI 변경 시)
<!-- Before/After 스크린샷 첨부 -->

## 체크리스트
- [ ] 코드 리뷰 요청 완료
- [ ] 관련 문서 업데이트
- [ ] 브랜치명이 규칙에 맞음
- [ ] 커밋 메시지가 명확함
```

### PR 크기 가이드라인

#### 권장 PR 크기
- **Small (1-100 lines)**: 이상적, 빠른 리뷰 가능
- **Medium (100-500 lines)**: 적정 크기
- **Large (500-1000 lines)**: 분할 검토 필요
- **XL (1000+ lines)**: 분할 권장

#### 큰 PR 분할 전략
```bash
# 1. 기능을 작은 단위로 분할
git checkout -b feature/user-auth-step1-database
git checkout -b feature/user-auth-step2-service
git checkout -b feature/user-auth-step3-controller

# 2. 의존성 순서대로 PR 생성
```

## 코드 리뷰 프로세스

### 리뷰어 지정 규칙

#### 자동 리뷰어 할당 (.github/CODEOWNERS)
```
# 전체 프로젝트
* @team-lead @senior-developer

# 특정 디렉토리별 전문가
/src/main/java/user/ @user-team-lead
/src/main/java/payment/ @payment-expert
/docs/ @tech-writer
/.github/ @devops-engineer
```

### 리뷰 체크리스트

#### 코드 품질
- [ ] 코드가 읽기 쉽고 이해하기 쉬운가?
- [ ] 네이밍이 의미있고 일관적인가?
- [ ] 중복 코드가 없는가?
- [ ] 적절한 디자인 패턴을 사용했는가?

#### 기능성
- [ ] 요구사항을 올바르게 구현했는가?
- [ ] 에지 케이스를 고려했는가?
- [ ] 에러 처리가 적절한가?

#### 테스트
- [ ] 적절한 테스트 커버리지를 가지고 있는가?
- [ ] 테스트가 의미있고 실용적인가?
- [ ] 통합 테스트가 필요한가?

#### 보안
- [ ] 보안 취약점이 없는가?
- [ ] 입력값 검증이 적절한가?
- [ ] 민감한 정보가 노출되지 않는가?

### 리뷰 응답 가이드

#### 건설적인 피드백 예시
```
🔍 제안: 이 메서드가 너무 길어 보입니다. 작은 메서드들로 분할하는 것이 어떨까요?

💡 개선: null 체크 대신 Optional을 사용하면 더 안전할 것 같습니다.

❓ 질문: 이 로직이 특별한 이유가 있나요? 다른 접근 방식도 고려해봤는지 궁금합니다.

✅ 좋네요: 이 테스트 케이스가 잘 작성되었네요!
```

## 헬퍼 도구 사용법

### GitHub Flow 헬퍼 함수들

#### 기본 설정
```bash
# .bashrc 또는 .zshrc에 추가
source /path/to/scripts/github-flow-helpers.sh

# 또는 별칭만 설정
alias gfs="source scripts/github-flow-helpers.sh && gf_start"
alias gfp="gf_pr"
alias gfc="gf_cleanup"  
alias gfst="gf_status"
```

#### 주요 함수들 사용법

##### 1. 새 기능 시작
```bash
gf_start user-notifications
# 실행 결과:
# ✅ 브랜치 'feature/user-notifications' 생성 완료
# 📝 개발 완료 후 다음 명령어로 PR을 생성하세요:
#    gf_pr 'Add user notifications' 'Description of changes'
```

##### 2. 상태 확인
```bash
gf_status
# 실행 결과:
# 📊 GitHub Flow 상태 확인
# 현재 브랜치: feature/user-notifications
# main 브랜치와의 차이:
#   앞선 커밋: 3
#   뒤처진 커밋: 0
# ✅ 작업 디렉토리가 깨끗합니다.
```

##### 3. main과 동기화
```bash
gf_sync
# 실행 결과:
# 🔄 main 브랜치와 동기화 중...
# ✅ 브랜치 'feature/user-notifications'를 main과 동기화했습니다.
```

##### 4. PR 생성
```bash
gf_pr "Add user notifications" "Implements email and push notification system with preferences"
# 실행 결과:
# 📝 Pull Request 생성 중...
# ✅ Pull Request가 생성되었습니다.
# https://github.com/owner/repo/pull/123
```

##### 5. 브랜치 정리
```bash
gf_cleanup
# 실행 결과:
# 🧹 병합 완료된 브랜치들 정리 중...
# 삭제할 로컬 브랜치들:
#   feature/user-auth
#   bugfix/login-issue
# ✅ 로컬 브랜치 정리 완료
# ✅ 원격 브랜치 참조 정리 완료
```

### GitHub CLI (gh) 활용

#### 기본 설정
```bash
# GitHub CLI 인증
gh auth login

# 설정 확인
gh auth status
```

#### 유용한 명령어들
```bash
# PR 목록 확인
gh pr list

# PR 상세 정보
gh pr view 123

# PR 체크아웃
gh pr checkout 123

# 이슈 생성
gh issue create --title "Bug: Login timeout" --body "Description"

# 릴리스 생성
gh release create v1.2.0 --title "Version 1.2.0" --notes "Release notes"
```

## CI/CD와 배포

### 자동화된 워크플로우

#### Pull Request 시 실행
```yaml
# .github/workflows/github-flow.yml
name: GitHub Flow CI/CD
on:
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          java-version: '17'
      - name: Run tests
        run: ./gradlew test
      - name: Run build
        run: ./gradlew build
      - name: Code coverage
        run: ./gradlew jacocoTestReport
```

#### main 브랜치 병합 시 배포
```yaml
deploy:
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  needs: test
  runs-on: ubuntu-latest
  environment: production
  steps:
    - name: Deploy to production
      run: |
        echo "🚀 Deploying to production..."
        # 실제 배포 스크립트 실행
        ./scripts/deploy.sh
```

### Feature Flags 활용

#### 점진적 기능 배포
```java
@Service
public class FeatureToggleService {
    @Value("${features.new-payment-system:false}")
    private boolean newPaymentEnabled;
    
    @Value("${features.user-notifications:false}")  
    private boolean notificationsEnabled;
    
    public boolean isNewPaymentEnabled(User user) {
        // 사용자별 또는 비율별 활성화
        return newPaymentEnabled && 
               (user.isTestUser() || user.getId() % 10 < 3); // 30%
    }
}
```

#### 환경별 Feature Flags 설정
```yaml
# application-prod.yml
features:
  new-payment-system: false    # 프로덕션에서는 비활성화
  user-notifications: true

# application-staging.yml  
features:
  new-payment-system: true     # 스테이징에서는 테스트
  user-notifications: true
```

### 배포 모니터링

#### 배포 후 자동 검증
```bash
#!/bin/bash
# scripts/post-deploy-verification.sh

echo "🔍 배포 후 검증 중..."

# Health check
health_status=$(curl -s -o /dev/null -w "%{http_code}" https://api.example.com/health)
if [ "$health_status" != "200" ]; then
    echo "❌ Health check 실패"
    exit 1
fi

# 핵심 API 테스트
api_status=$(curl -s -o /dev/null -w "%{http_code}" https://api.example.com/users/me)
if [ "$api_status" != "200" ]; then
    echo "❌ 핵심 API 테스트 실패"  
    exit 1
fi

echo "✅ 배포 검증 완료"
```

## 문제 해결 가이드

### 일반적인 문제들

#### 1. 병합 충돌 해결
```bash
# main과 동기화 중 충돌 발생
git rebase origin/main

# 충돌 파일 수정 후
git add .
git rebase --continue

# 강제 푸시 (주의!)
git push --force-with-lease origin feature/branch-name
```

#### 2. 실수로 잘못된 브랜치에서 작업
```bash
# 현재 작업을 stash
git stash

# 올바른 브랜치로 이동
git checkout correct-branch

# 작업 내용 복원
git stash pop
```

#### 3. 커밋 메시지 수정
```bash
# 마지막 커밋 메시지 수정
git commit --amend -m "fix: correct commit message"

# 여러 커밋 메시지 수정 (interactive rebase)
git rebase -i HEAD~3
```

#### 4. PR 생성 실패
```bash
# GitHub CLI 인증 확인
gh auth status

# 재인증
gh auth login

# 원격 저장소 확인
git remote -v
```

### 긴급 상황 대응

#### 1. 프로덕션 긴급 수정
```bash
# 긴급 수정 브랜치 생성
git checkout main
git pull origin main
git checkout -b hotfix/critical-security-fix

# 수정 작업
# ... 

# 긴급 PR 생성
gh pr create \
  --title "🚨 HOTFIX: Critical security vulnerability" \
  --body "Urgent security fix - requires immediate review and deployment" \
  --label "urgent,security"
```

#### 2. 배포 롤백
```bash
# 이전 커밋으로 롤백
git revert HEAD --no-commit
git commit -m "revert: rollback problematic deployment"
git push origin main

# 또는 긴급 롤백 스크립트 사용
./scripts/emergency-rollback.sh
```

### 도움 요청하기

#### 1. 팀 내 도움
```bash
# Slack 또는 Teams에 상황 공유
@channel GitHub Flow 사용 중 다음 오류가 발생했습니다:
- 현재 브랜치: feature/user-auth
- 오류 메시지: [오류 내용]
- 시도한 해결책: [시도한 내용]
```

#### 2. 이슈 트래커 활용
```bash
# GitHub 이슈 생성
gh issue create \
  --title "GitHub Flow 워크플로우 질문: 병합 충돌 해결" \
  --body "상황 설명 및 스크린샷" \
  --label "question,workflow"
```

이 가이드를 참고하여 GitHub Flow의 효율적이고 안전한 워크플로우를 구축하시기 바랍니다.