# 브랜치 머지 충돌 및 CI 오류 Trouble-shooting 가이드

## 📋 목차
- [개요](#개요)
- [일반적인 문제 유형](#일반적인-문제-유형)
- [상세 해결 방법](#상세-해결-방법)
- [예방 방법](#예방-방법)
- [실제 해결 사례](#실제-해결-사례)

## 개요

멀티 모듈 프로젝트에서 여러 PR이 동시에 작업될 때 발생할 수 있는 일반적인 문제들과 해결 방법을 정리한 문서입니다.

## 일반적인 문제 유형

### 🔀 1. 브랜치 머지 충돌

**발생 상황:**
- 같은 파일을 여러 브랜치에서 동시에 수정
- main 브랜치가 업데이트된 후 오래된 브랜치를 머지할 때
- 워크플로우 파일이나 설정 파일의 동시 수정

**증상:**
```bash
Auto-merging .github/workflows/sonarqube.yml
CONFLICT (add/add): Merge conflict in .github/workflows/sonarqube.yml
Auto-merging build.gradle
CONFLICT (content): Merge conflict in build.gradle
Automatic merge failed; fix conflicts and then commit the result.
```

### 🚫 2. 컴파일 에러로 인한 CI 실패

**발생 상황:**
- 인터페이스 메서드 변경 후 구현체 미수정
- 의존성 관계 변경 후 관련 코드 미업데이트
- 브랜치 간 코드 동기화 누락

**증상:**
```bash
error: cannot find symbol
  symbol:   method getTotalAmountByUserId(Long)
  location: variable orderRepository of type OrderRepository
BUILD FAILED in 20s
```

### 🤖 3. GitHub Actions 권한 오류

**발생 상황:**
- 워크플로우에서 PR 승인/머지 시도
- 부족한 GITHUB_TOKEN 권한
- GitHub 정책 제한 위반

**증상:**
```bash
HttpError: Resource not accessible by integration
HttpError: GitHub Actions is not permitted to approve pull requests
```

### 🔧 4. 워크플로우 파일 오류

**발생 상황:**
- 존재하지 않는 job 참조
- 잘못된 조건문이나 스크립트
- 환경 변수 누락

**증상:**
```bash
This run likely failed because of a workflow file issue.
```

## 상세 해결 방법

### 🔀 브랜치 머지 충돌 해결

#### 1단계: 현재 상태 확인
```bash
git status
```

#### 2단계: 충돌 파일 확인 및 수정
```bash
# 충돌 파일 목록 확인
git status | grep "both modified\|both added"

# 충돌 파일 내용 확인
git diff HEAD
```

#### 3단계: 충돌 해결 전략 결정
```bash
# Option 1: Manual merge (권장)
# 충돌 마커(<<<<<<, ======, >>>>>>)를 찾아 수동으로 해결

# Option 2: 특정 브랜치 버전 선택
git checkout --ours [파일명]    # 현재 브랜치 버전 선택
git checkout --theirs [파일명]  # 머지할 브랜치 버전 선택
```

#### 4단계: 충돌 해결 후 커밋
```bash
git add .
git commit -m "resolve merge conflicts with main branch"
```

### 🚫 컴파일 에러 해결

#### 1단계: 에러 로그 분석
```bash
# GitHub Actions에서 실패한 워크플로우 로그 확인
gh run view [run-id] --log-failed

# 로컬에서 빌드 테스트
./gradlew build --info
```

#### 2단계: 누락된 코드 식별
```bash
# 인터페이스와 구현체 비교
grep -r "method_name" src/
```

#### 3단계: 코드 동기화
```bash
# main 브랜치의 최신 변경사항 확인
git diff main..HEAD

# 필요한 코드 수정 후 테스트
./gradlew build
```

### 🤖 GitHub Actions 권한 오류 해결

#### 1단계: 권한 추가
```yaml
# 워크플로우 파일에 permissions 블록 추가
permissions:
  contents: write
  pull-requests: write
  checks: write
  actions: read
```

#### 2단계: 토큰 명시적 설정
```yaml
# github-script 액션에 토큰 명시
- uses: actions/github-script@v7
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    script: |
      # 스크립트 내용
```

#### 3단계: 대안책 적용
```yaml
# Auto-approve 대신 직접 머지로 변경
- name: Auto-merge PR
  uses: actions/github-script@v7
  with:
    script: |
      await github.rest.pulls.merge({
        owner: context.repo.owner,
        repo: context.repo.repo,
        pull_number: context.payload.pull_request.number,
        merge_method: 'squash'
      });
```

### 🔧 워크플로우 파일 오류 해결

#### 1단계: 문법 검증
```bash
# GitHub CLI로 워크플로우 문법 검증
gh workflow view [workflow-name]
```

#### 2단계: Job 의존성 확인
```yaml
# needs 필드의 job 이름 확인
deploy-production:
  needs: [build, integration-test, security-check]  # 실제 job 이름과 일치해야 함
```

#### 3단계: 환경 변수 및 시크릿 확인
```bash
# Repository 시크릿 확인
gh secret list

# 워크플로우에서 사용하는 시크릿과 일치하는지 확인
```

## 예방 방법

### 1. 정기적인 브랜치 동기화
```bash
# 주기적으로 main 브랜치의 최신 변경사항 병합
git checkout feature-branch
git pull origin main
```

### 2. 로컬 빌드 테스트
```bash
# PR 생성 전 로컬에서 전체 빌드 테스트
./gradlew clean build
```

### 3. 단계별 커밋
```bash
# 큰 변경사항을 작은 단위로 나누어 커밋
git add -p  # 부분적 스테이징
```

### 4. 코드 리뷰 체크리스트
- [ ] 인터페이스 변경 시 모든 구현체 업데이트 확인
- [ ] 새로운 의존성 추가 시 관련 모듈 업데이트 확인
- [ ] 워크플로우 파일 변경 시 문법 검증
- [ ] 빌드 및 테스트 통과 확인

## 실제 해결 사례

### 사례 1: OrderRepository 컴파일 에러

**문제:**
```java
error: cannot find symbol
symbol: method getTotalAmountByUserId(Long)
```

**원인:** PR #21이 main 브랜치의 최신 변경사항(PR #25에서 추가된 메서드)을 병합하지 않음

**해결:**
```bash
git checkout fix/github-token-permissions-issue-17
git merge main
# 충돌 해결 후
git push origin fix/github-token-permissions-issue-17
```

### 사례 2: Auto PR Review 403 오류

**문제:**
```
HttpError: GitHub Actions is not permitted to approve pull requests.
```

**원인:** GitHub 정책상 Actions가 자신의 PR을 승인할 수 없음

**해결:**
```yaml
# Auto-approve 단계 제거하고 직접 merge로 변경
- name: Auto-merge PR
  uses: actions/github-script@v7
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    script: |
      await github.rest.pulls.merge({
        owner: context.repo.owner,
        repo: context.repo.repo,
        pull_number: context.payload.pull_request.number,
        merge_method: 'squash'
      });
```

### 사례 3: 워크플로우 Job 참조 오류

**문제:**
```
This run likely failed because of a workflow file issue.
```

**원인:** `deploy-production` job이 존재하지 않는 `security-scan` job을 참조

**해결:**
```yaml
# ci.yml 파일 수정
deploy-production:
  needs: [build, integration-test, security-check]  # security-scan → security-check
```

## 🔧 Quick Fix Commands

```bash
# 브랜치 상태 확인
git status

# 충돌 파일 목록
git ls-files -u

# 충돌 해결 후 테스트
./gradlew build

# 워크플로우 로그 확인
gh run list --limit 5
gh run view [run-id] --log-failed

# PR 상태 확인
gh pr view [pr-number]
gh pr view [pr-number] --json statusCheckRollup
```

## 📞 추가 도움이 필요한 경우

1. **GitHub Discussions**: 커뮤니티에서 유사한 문제 검색
2. **GitHub Actions 로그**: 상세한 오류 메시지 확인
3. **로컬 재현**: 동일한 환경에서 문제 재현 시도
4. **단계별 롤백**: 마지막으로 작동했던 커밋으로 되돌아가서 변경사항 하나씩 적용

---

*이 문서는 실제 프로젝트에서 발생한 문제들을 기반으로 작성되었으며, 지속적으로 업데이트됩니다.*

🤖 Generated with [Claude Code](https://claude.ai/code)