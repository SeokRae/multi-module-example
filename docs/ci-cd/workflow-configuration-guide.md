# GitHub Actions 워크플로우 설정 가이드

## 📋 개요

이 가이드는 Spring Boot 멀티모듈 프로젝트를 위한 GitHub Actions 워크플로우 설정 모범 사례를 제공합니다.

## 🏗️ 워크플로우 구조

### 1. PR 체크 워크플로우 (`pr-checks.yml`)
PR 생성/업데이트 시 실행되는 빠른 검증 워크플로우

**주요 기능:**
- PR 제목 및 브랜치명 검증
- 빠른 컴파일 체크
- 영향받는 모듈만 테스트
- 문서 변경 확인
- 보안 체크

### 2. 메인 CI/CD 워크플로우 (`ci.yml`)  
모든 푸시와 PR에서 실행되는 완전한 CI/CD 파이프라인

**주요 기능:**
- 코드 품질 및 보안 체크
- 전체 모듈 테스트
- 애플리케이션 빌드
- 통합 테스트
- 보안 스캔
- 배포 (조건부)

## ⚙️ 필수 설정 요소

### 권한 설정
```yaml
# PR 관련 워크플로우
permissions:
  contents: read          # 코드 체크아웃
  pull-requests: write    # PR 코멘트 및 리뷰
  checks: write          # 체크 상태 업데이트
  actions: read          # 워크플로우 정보 읽기

# 보안 스캔이 포함된 워크플로우  
permissions:
  contents: read
  security-events: write  # SARIF 업로드
  actions: read
```

### Checkout 설정
```yaml
# PR에서 diff가 필요한 경우
- name: Checkout code
  uses: actions/checkout@v4
  with:
    fetch-depth: 0  # 전체 히스토리 (diff용)
    ref: ${{ github.event.pull_request.head.sha }}

# 일반적인 경우
- name: Checkout code
  uses: actions/checkout@v4
  # 기본 shallow clone 사용
```

### Java 환경 설정
```yaml
- name: Set up JDK ${{ env.JAVA_VERSION }}
  uses: actions/setup-java@v4
  with:
    java-version: ${{ env.JAVA_VERSION }}
    distribution: 'temurin'  # Eclipse Temurin 권장
```

### Gradle 캐싱
```yaml
- name: Cache Gradle packages
  uses: actions/cache@v4
  with:
    path: |
      ~/.gradle/caches
      ~/.gradle/wrapper
      .gradle/buildOutputCleanup  # 추가 캐시
    key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
    restore-keys: |
      ${{ runner.os }}-gradle-
```

## 🎯 최적화된 PR 체크 워크플로우

### 변경된 파일 감지 (개선된 방식)
```yaml
- name: Get changed files
  id: changed-files
  run: |
    # GitHub API를 사용한 안전한 방식
    if [ "${{ github.event_name }}" = "pull_request" ]; then
      gh api repos/${{ github.repository }}/pulls/${{ github.event.number }}/files \
        --jq '.[].filename' > changed_files.txt
      
      # 또는 GitHub 컨텍스트 사용
      git diff --name-only ${{ github.event.pull_request.base.sha }}...${{ github.sha }} > changed_files.txt || \
      gh pr diff ${{ github.event.number }} --name-only > changed_files.txt
      
      echo "changed_files<<EOF" >> $GITHUB_OUTPUT
      cat changed_files.txt >> $GITHUB_OUTPUT  
      echo "EOF" >> $GITHUB_OUTPUT
    fi
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 조건부 테스트 실행
```yaml
- name: Run affected tests
  run: |
    # 함수 정의
    run_module_tests() {
      local module=$1
      local module_path=$(echo "$module" | sed 's/:/\//g')
      
      if [ -d "$module_path/src/test" ] && [ "$(find $module_path/src/test -name '*.java' | wc -l)" -gt 0 ]; then
        echo "🧪 Testing $module..."
        ./gradlew :$module:test --parallel --continue
      else
        echo "⏭️  Skipping $module (no tests)"
      fi
    }
    
    # 변경된 파일에 따라 모듈 테스트
    changed_files="${{ steps.changed-files.outputs.changed_files }}"
    
    if echo "$changed_files" | grep -q "build.gradle\|settings.gradle"; then
      echo "📦 Build files changed, running full test suite"
      ./gradlew test --parallel
    else
      # 모듈별 조건부 실행
      if echo "$changed_files" | grep -q "^common/"; then
        for module in common:common-core common:common-web common:common-security common:common-cache; do
          run_module_tests "$module"
        done
      fi
      
      if echo "$changed_files" | grep -q "^domain/"; then
        for module in domain:user-domain domain:product-domain domain:order-domain; do
          run_module_tests "$module"  
        done
      fi
      
      if echo "$changed_files" | grep -q "^application/"; then
        for module in application:user-api application:batch-app; do
          run_module_tests "$module"
        done
      fi
    fi
```

## 🔒 보안 설정

### SARIF 업로드 (보안 스캔)
```yaml
security-scan:
  name: Security Scan
  runs-on: ubuntu-latest
  permissions:
    actions: read
    contents: read  
    security-events: write
    
  steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        format: 'sarif'
        output: 'trivy-results.sarif'
      continue-on-error: true  # 스캔 실패해도 계속 진행
        
    - name: Upload Trivy scan results to GitHub Security tab
      uses: github/codeql-action/upload-sarif@v3
      if: always()  # 이전 스텝 실패해도 업로드 시도
      with:
        sarif_file: 'trivy-results.sarif'
```

### 민감 정보 체크
```yaml
- name: Check for secrets
  run: |
    # 패턴 파일 생성
    cat << 'EOF' > .secret-patterns
    password\s*[:=]\s*["\'][^"\']*["\']
    api[_-]?key\s*[:=]\s*["\'][^"\']*["\']  
    secret\s*[:=]\s*["\'][^"\']*["\']
    token\s*[:=]\s*["\'][^"\']*["\']
    jdbc:.*://.*:.*@
    EOF
    
    # 변경된 파일에서 패턴 검색
    git diff ${{ github.event.pull_request.base.sha }}...${{ github.sha }} | \
      grep "^+" | \
      grep -v "^+++" | \
      grep -E -f .secret-patterns && \
      (echo "❌ Potential secrets detected!" && exit 1) || \
      echo "✅ No secrets pattern detected"
```

## 📊 병렬 처리 및 성능 최적화

### 매트릭스 전략
```yaml
test:
  name: Run Tests
  runs-on: ubuntu-latest
  strategy:
    fail-fast: false  # 하나 실패해도 다른 것들 계속 실행
    matrix:
      module: [
        'common:common-core',
        'common:common-web',
        'domain:user-domain',
        'application:user-api'
      ]
  steps:
    - name: Test ${{ matrix.module }}
      run: ./gradlew :${{ matrix.module }}:test --parallel
```

### 조건부 작업 실행
```yaml
# 특정 브랜치에서만 실행
deploy-staging:
  if: github.ref == 'refs/heads/develop'
  
# PR이 draft가 아닐 때만 실행  
pr-checks:
  if: github.event.pull_request.draft == false
  
# 파일 변경이 있을 때만 실행
build:
  if: contains(steps.changes.outputs.changed_files, '.gradle') || contains(steps.changes.outputs.changed_files, '.java')
```

## 🌱 환경별 설정

### 개발 환경
```yaml
env:
  JAVA_VERSION: '17'
  GRADLE_OPTS: '-Dorg.gradle.daemon=false -Dorg.gradle.workers.max=2'
  SPRING_PROFILES_ACTIVE: 'test'
```

### 스테이징 환경  
```yaml
deploy-staging:
  environment: staging  # GitHub Environment 사용
  env:
    SPRING_PROFILES_ACTIVE: 'staging'
    DATABASE_URL: ${{ secrets.STAGING_DATABASE_URL }}
```

### 프로덕션 환경
```yaml
deploy-production:
  environment: production
  if: github.ref == 'refs/heads/main'
  env:
    SPRING_PROFILES_ACTIVE: 'prod'
    DATABASE_URL: ${{ secrets.PROD_DATABASE_URL }}
```

## 🚀 배포 전략

### Blue-Green 배포
```yaml
deploy:
  steps:
    - name: Deploy to staging slot
      run: |
        # 스테이징 슬롯에 배포
        deploy-to-slot.sh staging
        
    - name: Run smoke tests
      run: |
        # 스모크 테스트 실행
        test-deployment.sh staging
        
    - name: Swap slots
      if: success()
      run: |
        # 슬롯 교체 (Blue-Green)
        swap-slots.sh staging production
```

### 롤백 준비
```yaml
- name: Create rollback point
  run: |
    echo "ROLLBACK_IMAGE=myapp:${{ github.sha }}" >> $GITHUB_ENV
    echo "PREVIOUS_IMAGE=myapp:$(git rev-parse HEAD~1)" >> $GITHUB_ENV
```

## 🔍 모니터링 및 알림

### Slack 알림
```yaml
- name: Notify Slack on failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: failure
    channel: '#ci-cd'
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### 배포 요약
```yaml
- name: Create deployment summary
  run: |
    echo "## 🚀 Deployment Summary" >> $GITHUB_STEP_SUMMARY
    echo "- **Environment**: ${{ github.ref_name }}" >> $GITHUB_STEP_SUMMARY
    echo "- **Commit**: ${{ github.sha }}" >> $GITHUB_STEP_SUMMARY  
    echo "- **Status**: ✅ Success" >> $GITHUB_STEP_SUMMARY
```

이 가이드를 참고하여 프로젝트에 맞는 워크플로우를 설정하시기 바랍니다.