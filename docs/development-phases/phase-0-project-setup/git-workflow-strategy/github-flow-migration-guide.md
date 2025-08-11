# Git Flow에서 GitHub Flow로 마이그레이션 가이드

이 문서는 현재 Git Flow 구조에서 GitHub Flow로 전환하는 방법을 단계별로 설명합니다.

## 목차
1. [현재 상태 분석](#현재-상태-분석)
2. [마이그레이션 전략](#마이그레이션-전략)
3. [단계별 마이그레이션](#단계별-마이그레이션)
4. [팀 교육 및 적응](#팀-교육-및-적응)
5. [CI/CD 파이프라인 조정](#cicd-파이프라인-조정)
6. [문제 해결](#문제-해결)

## 현재 상태 분석

### 기존 Git Flow 구조
```
main (프로덕션)
├── develop (개발 통합)
│   ├── feature/phase-2-api-implementation
│   └── feature/test-git-flow (완료됨)
└── hotfix/* (필요시 생성)
    release/* (릴리스시 생성)
```

### GitHub Flow 목표 구조
```
main (프로덕션 + 개발)
├── feature/user-authentication
├── feature/payment-integration
├── bugfix/login-issue
└── docs/update-readme
```

## 마이그레이션 전략

### 전략 옵션

#### 1. 점진적 마이그레이션 (권장) 🟢
- **특징**: 기존 Git Flow와 병행하며 천천히 전환
- **기간**: 2-4주
- **위험도**: 낮음
- **팀 부담**: 최소

#### 2. 하이브리드 접근 🟡
- **특징**: 주요 기능은 Git Flow, 작은 기능은 GitHub Flow
- **기간**: 지속적
- **위험도**: 중간
- **팀 부담**: 중간

#### 3. 완전 전환 🔴
- **특징**: 한 번에 GitHub Flow로 완전 전환
- **기간**: 1주
- **위험도**: 높음
- **팀 부담**: 높음

## 단계별 마이그레이션

### Phase 1: 준비 단계 (1-2일)

#### 1.1 현재 작업 상황 정리
```bash
# 진행 중인 feature 브랜치 확인
git branch -a | grep feature

# 미완성 작업 현황 파악
git status
git stash list
```

#### 1.2 팀 미팅 및 교육
- GitHub Flow 개념 설명
- 기존 Git Flow와의 차이점
- 새로운 워크플로우 실습
- Q&A 세션

#### 1.3 CI/CD 파이프라인 검토
```yaml
# .github/workflows/ 에서 브랜치별 트리거 확인
name: CI
on:
  push:
    branches: [ main, develop ]  # develop 제거 예정
  pull_request:
    branches: [ main ]           # main만 남김
```

### Phase 2: 브랜치 구조 조정 (2-3일)

#### 2.1 develop 브랜치를 main으로 병합 준비
```bash
# 현재 상태 백업
git tag backup-before-migration

# develop의 모든 변경사항을 main에 반영
git checkout main
git pull origin main
git merge origin/develop
git push origin main
```

#### 2.2 기존 feature 브랜치 정리
```bash
# 진행 중인 feature 브랜치들을 GitHub Flow 방식으로 전환
git checkout feature/phase-2-api-implementation
git rebase main  # main 기준으로 rebase
```

#### 2.3 브랜치 보호 규칙 설정
```json
{
  "protection": {
    "required_pull_request_reviews": {
      "required_approving_review_count": 1
    },
    "enforce_admins": true,
    "required_status_checks": {
      "strict": true,
      "contexts": ["ci/build", "ci/test"]
    }
  }
}
```

### Phase 3: 워크플로우 전환 (1주)

#### 3.1 새로운 기능 개발 방식
```bash
# 이전 방식 (Git Flow)
git checkout develop
git pull origin develop
git checkout -b feature/new-feature

# 새로운 방식 (GitHub Flow)
git checkout main
git pull origin main
git checkout -b feature/new-feature
```

#### 3.2 Pull Request 템플릿 생성
```markdown
<!-- .github/pull_request_template.md -->
## 변경 내용
- [ ] 새로운 기능
- [ ] 버그 수정
- [ ] 문서 업데이트
- [ ] 리팩토링

## 설명
<!-- 변경 사항에 대한 설명 -->

## 테스트
- [ ] 단위 테스트 통과
- [ ] 통합 테스트 통과
- [ ] 수동 테스트 완료

## 체크리스트
- [ ] 코드 리뷰 요청
- [ ] 문서 업데이트
- [ ] 변경 로그 업데이트
```

#### 3.3 자동화 스크립트 작성
```bash
#!/bin/bash
# scripts/github-flow-start.sh

feature_name=$1
if [ -z "$feature_name" ]; then
    echo "사용법: $0 <feature-name>"
    exit 1
fi

echo "GitHub Flow 기능 개발 시작: $feature_name"

# main 브랜치에서 최신 상태로 시작
git checkout main
git pull origin main
git checkout -b feature/$feature_name

echo "브랜치 feature/$feature_name 생성 완료"
echo "개발 완료 후 'gh pr create' 명령어로 PR을 생성하세요"
```

### Phase 4: develop 브랜치 단계적 제거 (3-5일)

#### 4.1 develop 브랜치 사용 중단 공지
```bash
# develop 브랜치에 더 이상 푸시 금지 알림
git checkout develop
echo "⚠️  이 브랜치는 더 이상 사용되지 않습니다. main 브랜치를 사용하세요." > DEPRECATED.md
git add DEPRECATED.md
git commit -m "docs: mark develop branch as deprecated"
git push origin develop
```

#### 4.2 모든 변경사항을 main으로 이전
```bash
# 마지막 develop → main 동기화
git checkout main
git pull origin main
git merge develop
git push origin main
```

#### 4.3 원격 develop 브랜치 삭제
```bash
# 충분한 확인 후 삭제
git push origin --delete develop
```

### Phase 5: 최적화 및 안정화 (1-2주)

#### 5.1 CI/CD 파이프라인 최적화
```yaml
# .github/workflows/github-flow.yml
name: GitHub Flow CI/CD
on:
  push:
    branches: [ main ]
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
      - name: Test
        run: ./gradlew test

  deploy:
    if: github.ref == 'refs/heads/main'
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to production
        run: echo "Deploying to production..."
```

#### 5.2 브랜치 정리 자동화
```bash
#!/bin/bash
# scripts/cleanup-merged-branches.sh

echo "병합 완료된 브랜치들을 정리합니다..."

# 로컬 브랜치 중 main에 병합된 것들 삭제
git branch --merged main | grep -v "main" | xargs -n 1 git branch -d

# 원격 브랜치 중 삭제된 것들의 로컬 참조 정리
git remote prune origin

echo "브랜치 정리 완료"
```

## 팀 교육 및 적응

### 교육 자료

#### GitHub Flow 치트 시트
```bash
# 🚀 새로운 기능 시작
git checkout main && git pull origin main
git checkout -b feature/amazing-feature

# 💻 개발 및 커밋
git add .
git commit -m "feat: implement amazing feature"
git push -u origin feature/amazing-feature

# 📝 Pull Request 생성
gh pr create --title "Add amazing feature" --body "Description of changes"

# 🔍 코드 리뷰 후 병합
gh pr merge --squash

# 🧹 정리
git checkout main && git pull origin main
git branch -d feature/amazing-feature
```

#### 자주 사용하는 명령어
```bash
# 브랜치 생성 및 전환
alias gf="git checkout main && git pull origin main && git checkout -b"

# Pull Request 생성
alias gpr="gh pr create --web"

# 브랜치 정리
alias gclean="git branch --merged main | grep -v main | xargs git branch -d"
```

### 점진적 적응 전략

#### Week 1: 소규모 변경으로 시작
- 문서 업데이트
- 작은 버그 수정
- 코드 스타일 정리

#### Week 2: 중간 크기 기능
- API 엔드포인트 추가
- 새로운 컴포넌트 개발
- 테스트 코드 작성

#### Week 3-4: 복잡한 기능
- 전체 기능 모듈 개발
- 데이터베이스 스키마 변경
- 대규모 리팩토링

## CI/CD 파이프라인 조정

### 기존 파이프라인 문제점
```yaml
# 문제: develop과 main을 별도 관리
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ develop ]  # main으로 변경 필요
```

### 개선된 파이프라인
```yaml
# 해결: main 중심의 단순한 구조
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: ./gradlew test
        
  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: |
          echo "Deploying to production"
          # 실제 배포 스크립트
```

### Feature Flags 도입
```java
@Component
public class FeatureToggle {
    @Value("${features.new-payment-system:false}")
    private boolean newPaymentSystemEnabled;
    
    public boolean isNewPaymentSystemEnabled() {
        return newPaymentSystemEnabled;
    }
}
```

## 문제 해결

### 자주 발생하는 문제들

#### 1. main 브랜치가 불안정한 경우
**해결책:**
```bash
# 더 엄격한 브랜치 보호 규칙
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["ci/test","ci/build"]}' \
  --field required_pull_request_reviews='{"required_approving_review_count":2}'
```

#### 2. 빈번한 충돌 발생
**해결책:**
```bash
# 정기적인 main 브랜치 동기화
git checkout feature/my-feature
git fetch origin
git rebase origin/main
```

#### 3. 복잡한 기능의 긴 개발 주기
**해결책:**
- Feature Flags 사용
- 단계별 PR 분할
- Draft PR 활용

#### 4. 롤백이 어려운 경우
**해결책:**
```bash
# Git revert 사용
git revert <commit-hash>
git push origin main

# 또는 빠른 hotfix
git checkout main
git checkout -b hotfix/urgent-fix
# 수정 작업
gh pr create --title "Urgent hotfix" --body "Critical issue fix"
```

## 마이그레이션 체크리스트

### 사전 준비
- [ ] 팀 미팅 및 교육 완료
- [ ] 현재 브랜치 상태 백업
- [ ] CI/CD 파이프라인 검토
- [ ] Feature Flag 시스템 준비

### 브랜치 구조 변경
- [ ] develop의 모든 변경사항을 main에 병합
- [ ] 진행 중인 feature 브랜치들 main 기준으로 rebase
- [ ] 브랜치 보호 규칙 설정
- [ ] develop 브랜치 사용 중단 및 삭제

### 워크플로우 변경
- [ ] PR 템플릿 생성
- [ ] GitHub Flow 스크립트 작성
- [ ] 팀원들에게 새로운 방식 교육
- [ ] 첫 번째 GitHub Flow PR 성공적 완료

### 파이프라인 최적화
- [ ] CI/CD 워크플로우 업데이트
- [ ] 자동 브랜치 정리 스크립트 설정
- [ ] 모니터링 및 알림 설정

### 사후 관리
- [ ] 2주간 모니터링 및 피드백 수집
- [ ] 문제점 해결 및 프로세스 개선
- [ ] 최종 마이그레이션 완료 확인

## 롤백 계획

만약 마이그레이션에 문제가 발생한다면:

### 1. 즉시 롤백
```bash
# 백업 태그로 복원
git checkout main
git reset --hard backup-before-migration
git push --force-with-lease origin main

# develop 브랜치 복구 (삭제했다면)
git checkout -b develop backup-before-migration
git push -u origin develop
```

### 2. 하이브리드 모드로 전환
```bash
# GitHub Flow와 Git Flow를 병행 사용
# 안정화될 때까지 기존 방식과 혼용
```

### 3. 점진적 재시도
```bash
# 문제점을 해결한 후 더 천천히 재시도
# 더 작은 단위로 변경사항 적용
```

이 가이드를 따라하면 안전하고 체계적으로 GitHub Flow로 마이그레이션할 수 있습니다.