# GitHub Actions CI/CD Trouble-shooting 가이드

## 📋 목차
- [개요](#개요)
- [일반적인 오류 패턴](#일반적인-오류-패턴)
- [권한 관련 오류](#권한-관련-오류)
- [워크플로우 설정 오류](#워크플로우-설정-오류)
- [빌드/테스트 관련 오류](#빌드테스트-관련-오류)
- [진단 도구 및 명령어](#진단-도구-및-명령어)

## 개요

GitHub Actions를 사용한 CI/CD 파이프라인에서 발생하는 일반적인 오류들과 해결 방법을 정리한 실용적인 가이드입니다.

## 일반적인 오류 패턴

### 🔍 오류 확인 방법

```bash
# 최근 워크플로우 실행 목록 확인
gh run list --limit 10

# 특정 실행의 상세 정보
gh run view [RUN_ID]

# 실패한 단계의 로그만 확인
gh run view [RUN_ID] --log-failed

# PR의 체크 상태 확인
gh pr view [PR_NUMBER] --json statusCheckRollup
```

## 권한 관련 오류

### 🚫 Resource not accessible by integration

**오류 메시지:**
```
RequestError [HttpError]: Resource not accessible by integration
```

**원인:**
- GITHUB_TOKEN의 권한 부족
- 워크플로우에 필요한 permissions 미설정

**해결 방법:**

1. **워크플로우 레벨에서 권한 추가**
```yaml
name: CI/CD Pipeline

on: [push, pull_request]

permissions:
  contents: write        # 코드 읽기/쓰기
  pull-requests: write   # PR 생성/수정
  checks: write         # 체크 상태 업데이트
  actions: read         # Actions 접근
  issues: write         # 이슈 생성/수정

jobs:
  build:
    runs-on: ubuntu-latest
    # ...
```

2. **Job 레벨에서 권한 추가**
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      deployments: write
    steps:
      # ...
```

3. **github-script에서 명시적 토큰 설정**
```yaml
- name: Create PR comment
  uses: actions/github-script@v7
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    script: |
      await github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: 'Hello from GitHub Actions!'
      });
```

### 🚫 GitHub Actions is not permitted to approve pull requests

**오류 메시지:**
```
HttpError: Unprocessable Entity: "GitHub Actions is not permitted to approve pull requests."
```

**원인:**
- GitHub 정책: Actions가 자신이 생성한 PR을 승인할 수 없음
- 자동화 도구의 코드 리뷰 프로세스 우회 방지

**해결 방법:**

1. **Auto-approve 제거하고 직접 merge**
```yaml
- name: Auto-merge PR
  uses: actions/github-script@v7
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    script: |
      await github.rest.pulls.merge({
        owner: context.repo.owner,
        repo: context.repo.repo,
        pull_number: context.payload.pull_request.number,
        merge_method: 'squash',
        commit_title: `🤖 ${context.payload.pull_request.title}`,
        commit_message: `Auto-merged after CI checks passed`
      });
```

2. **Personal Access Token 사용 (비권장)**
```yaml
# Repository secrets에 PAT 추가 필요
- name: Auto-approve with PAT
  uses: actions/github-script@v7
  with:
    github-token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
    # ...
```

## 워크플로우 설정 오류

### 🔧 Job dependency 오류

**오류 메시지:**
```
This run likely failed because of a workflow file issue.
```

**일반적인 원인:**

1. **존재하지 않는 job 참조**
```yaml
# ❌ 잘못된 예
deploy:
  needs: [build, test, security-scan]  # security-scan job이 없음

# ✅ 올바른 예  
deploy:
  needs: [build, test, security-check]  # 실제 존재하는 job
```

2. **순환 dependency**
```yaml
# ❌ 잘못된 예
job-a:
  needs: job-b
job-b:
  needs: job-a

# ✅ 올바른 예
job-a:
  runs-on: ubuntu-latest
job-b:
  needs: job-a
```

3. **조건부 job의 의존성 문제**
```yaml
# ❌ 문제가 될 수 있는 예
deploy:
  needs: security-check
  if: github.ref == 'refs/heads/main'

security-check:
  if: github.event_name == 'pull_request'  # PR에서만 실행

# ✅ 개선된 예
deploy:
  needs: security-check
  if: github.ref == 'refs/heads/main' && always()  # 이전 job 상태 무관
```

### 🔧 Syntax 오류

**일반적인 실수:**

1. **YAML 들여쓰기 오류**
```yaml
# ❌ 잘못된 들여쓰기
jobs:
build:
  runs-on: ubuntu-latest
    steps:
  - name: Checkout

# ✅ 올바른 들여쓰기
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
```

2. **환경 변수 참조 오류**
```yaml
# ❌ 잘못된 참조
- name: Deploy
  run: echo "Deploying to $ENVIRONMENT"
  env:
    ENVIRONMENT: production

# ✅ 올바른 참조
- name: Deploy
  run: echo "Deploying to ${{ env.ENVIRONMENT }}"
  env:
    ENVIRONMENT: production
```

## 빌드/테스트 관련 오류

### 🏗️ 컴파일 에러

**오류 패턴:**
```
> Task :domain:order-domain:compileJava FAILED
error: cannot find symbol
  symbol:   method getTotalAmountByUserId(Long)
```

**해결 단계:**

1. **로컬에서 동일 오류 재현**
```bash
./gradlew clean build --info
```

2. **의존성 관계 확인**
```bash
./gradlew dependencies --configuration compileClasspath
```

3. **증분 빌드 문제 해결**
```bash
./gradlew clean build
```

4. **병렬 빌드 비활성화 (문제 격리용)**
```bash
./gradlew build --no-parallel
```

### 🧪 테스트 실패

**일반적인 원인과 해결:**

1. **테스트 환경 차이**
```yaml
# CI 환경에서 테스트용 데이터베이스 설정
services:
  postgres:
    image: postgres:15
    env:
      POSTGRES_PASSWORD: testpassword
    options: >-
      --health-cmd pg_isready
      --health-interval 10s
      --health-timeout 5s
      --health-retries 5
```

2. **시간대/지역 설정 차이**
```yaml
- name: Set timezone
  run: |
    sudo timedatectl set-timezone Asia/Seoul
    echo "TZ=Asia/Seoul" >> $GITHUB_ENV
```

3. **메모리 부족**
```yaml
env:
  GRADLE_OPTS: '-Xmx2048m -Dorg.gradle.daemon=false'
  JVM_OPTS: '-Xmx1024m'
```

### 🐳 Docker 관련 오류

**일반적인 문제:**

1. **이미지 빌드 실패**
```yaml
- name: Build Docker image
  run: |
    docker build --no-cache -t myapp:${{ github.sha }} .
    docker run --rm myapp:${{ github.sha }} echo "Container test"
```

2. **권한 문제**
```yaml
- name: Setup Docker Buildx
  uses: docker/setup-buildx-action@v3

- name: Login to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}
```

## 진단 도구 및 명령어

### 🔍 디버깅 Commands

```bash
# 워크플로우 실행 상태 모니터링
gh run watch [RUN_ID]

# 실행 중인 워크플로우 취소
gh run cancel [RUN_ID]

# 워크플로우 다시 실행
gh run rerun [RUN_ID]

# 특정 브랜치의 워크플로우만 확인
gh run list --branch feature/my-branch

# 실패한 워크플로우만 필터링
gh run list --status failure --limit 10

# PR의 모든 체크 상태 확인
gh pr checks [PR_NUMBER]
```

### 🔍 로컬 테스트 도구

1. **act (GitHub Actions 로컬 실행)**
```bash
# act 설치 (macOS)
brew install act

# 워크플로우 로컬 실행
act push

# 특정 job만 실행
act -j build

# 시크릿 파일 사용
act --secret-file .secrets
```

2. **Docker로 CI 환경 재현**
```bash
# 동일한 Ubuntu 환경에서 테스트
docker run -it ubuntu:latest /bin/bash

# Java 환경 설정 후 빌드 테스트
apt update && apt install -y openjdk-17-jdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
./gradlew build
```

### 📊 워크플로우 성능 분석

```bash
# 워크플로우 실행 시간 분석
gh run view [RUN_ID] --json jobs --jq '.jobs[] | {name: .name, duration: .conclusion, started: .started_at, completed: .completed_at}'

# 가장 오래 걸리는 단계 찾기
gh run view [RUN_ID] --json jobs --jq '.jobs[].steps[] | select(.conclusion == "success") | {name: .name, duration: (.completed_at | fromdate) - (.started_at | fromdate)}'
```

## 🚨 긴급 대응 방법

### 1. 빠른 문제 격리
```bash
# 워크플로우 비활성화
gh workflow disable [WORKFLOW_NAME]

# 특정 브랜치에서만 실행되도록 제한
# .github/workflows/ci.yml 수정
on:
  push:
    branches: [main]  # 문제 해결될 때까지 main만
```

### 2. 롤백 전략
```bash
# 마지막 성공한 커밋으로 되돌리기
git revert [COMMIT_SHA]
git push origin main

# 워크플로우 파일을 이전 버전으로 복구
git checkout HEAD~1 -- .github/workflows/ci.yml
git commit -m "revert: rollback CI workflow to previous version"
```

### 3. 우회 전략
```yaml
# 일시적으로 특정 단계 건너뛰기
- name: Flaky test
  run: ./gradlew test
  continue-on-error: true  # 실패해도 계속 진행

# 조건부로 단계 비활성화
- name: Deploy
  if: false  # 임시로 비활성화
  run: echo "Deploy step disabled"
```

## 📚 추가 리소스

- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [워크플로우 문법 참조](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions 커뮤니티 포럼](https://github.community/c/github-actions/9)
- [Action 마켓플레이스](https://github.com/marketplace?type=actions)

---

*이 문서는 실제 프로젝트 경험을 바탕으로 작성되었으며, 새로운 오류 패턴이 발견될 때마다 업데이트됩니다.*

🤖 Generated with [Claude Code](https://claude.ai/code)