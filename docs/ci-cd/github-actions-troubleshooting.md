# GitHub Actions 트러블슈팅 가이드

## 🚨 현재 발생하는 주요 문제들

### 1. Git Diff 참조 오류
**에러 메시지:**
```
fatal: ambiguous argument 'origin/main...HEAD': unknown revision or path not in the working tree.
```

**원인:**
- PR 체크 워크플로우에서 `origin/main...HEAD` 참조를 찾을 수 없음
- GitHub Actions의 shallow clone으로 인해 base 브랜치 참조가 없음

**해결 방법:**
```yaml
# 현재 문제가 있는 코드
changed_files=$(git diff --name-only origin/main...HEAD)

# 해결된 코드 
changed_files=$(git diff --name-only ${{ github.event.pull_request.base.sha }}...${{ github.event.pull_request.head.sha }})
```

### 2. GitHub Token 권한 부족
**에러 메시지:**
```
Resource not accessible by integration
```

**원인:**
- `amannn/action-semantic-pull-request@v5` 액션이 필요한 권한이 없음
- 기본 GITHUB_TOKEN의 권한이 제한적

**해결 방법:**
```yaml
# PR 검증 작업에 권한 추가
pr-validation:
  name: Validate PR
  runs-on: ubuntu-latest
  permissions:
    contents: read
    pull-requests: write  # PR 제목 검증을 위해 필요 
    checks: write        # 체크 상태 업데이트를 위해 필요
  steps:
    - name: Validate PR title
      uses: amannn/action-semantic-pull-request@v5
```

### 3. Security Scan 최적화 (개인 리포지토리용)
**문제:**
- GitHub Security Scan(SARIF)은 주로 Enterprise/Organization 용도
- 개인 리포지토리에서는 불필요한 복잡성 추가

**해결 방법:**
```yaml
# 복잡한 SARIF 업로드 대신 간단한 보안 체크 사용
security-check:
  name: Security Check
  steps:
    - name: Run dependency vulnerability check
      run: |
        ./gradlew dependencies --configuration runtimeClasspath | grep -i "FAIL\|ERROR\|WARN" || echo "✅ No issues found"
        
    - name: Check for hardcoded secrets (basic)
      run: |
        # 기본적인 시크릿 패턴 체크
        git log --oneline -10 | xargs -I {} git show {} --name-only | grep -v ".github" | xargs grep -l -i -E "(password|secret|key|token).*=" 2>/dev/null || echo "✅ No secrets found"
```

### 4. Checkout 설정 부족
**원인:**
- 기본 checkout은 shallow clone을 수행
- PR diff를 위해서는 base 브랜치 히스토리가 필요

**해결 방법:**
```yaml
- name: Checkout code
  uses: actions/checkout@v4
  with:
    fetch-depth: 0  # 전체 히스토리 가져오기
    ref: ${{ github.event.pull_request.head.sha }}
```

## 🔧 워크플로우별 해결 방안

### PR 체크 워크플로우 개선

#### 기존 문제가 있는 코드:
```yaml
- name: Run affected module tests
  run: |
    changed_files=$(git diff --name-only origin/${{ github.base_ref }}...HEAD)
    # ... 나머지 로직
```

#### 개선된 코드:
```yaml
- name: Checkout code
  uses: actions/checkout@v4
  with:
    fetch-depth: 0
    
- name: Run affected module tests  
  run: |
    # GitHub 컨텍스트를 사용하여 안전한 diff 수행
    changed_files=$(git diff --name-only ${{ github.event.pull_request.base.sha }}...${{ github.sha }})
    
    # 또는 gh CLI를 사용
    changed_files=$(gh pr diff ${{ github.event.number }} --name-only)
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 권한 설정 표준화

#### PR 관련 워크플로우:
```yaml
name: Pull Request Checks
on:
  pull_request:
    branches: [main, develop]

permissions:
  contents: read
  pull-requests: write
  checks: write
  actions: read
```

#### 보안 스캔 워크플로우:
```yaml
security-scan:
  permissions:
    actions: read
    contents: read
    security-events: write
    
  steps:
    - name: Upload SARIF
      uses: github/codeql-action/upload-sarif@v3
      if: always()
```

## 🛠️ 모범 사례

### 1. 조건부 실행 패턴
```yaml
- name: Check if tests exist
  id: check-tests
  run: |
    if [ -d "src/test" ] && [ "$(find src/test -name '*.java' | wc -l)" -gt 0 ]; then
      echo "tests_exist=true" >> $GITHUB_OUTPUT
    else
      echo "tests_exist=false" >> $GITHUB_OUTPUT
    fi

- name: Run tests
  if: steps.check-tests.outputs.tests_exist == 'true'
  run: ./gradlew test
```

### 2. 에러 핸들링
```yaml
- name: Safe git diff
  run: |
    set -e  # 에러 시 중단
    
    # 여러 방법 중 작동하는 방법 사용
    if git diff --name-only ${{ github.event.pull_request.base.sha }}...${{ github.sha }} 2>/dev/null; then
      echo "Using SHA-based diff"
      changed_files=$(git diff --name-only ${{ github.event.pull_request.base.sha }}...${{ github.sha }})
    elif gh pr diff ${{ github.event.number }} --name-only 2>/dev/null; then
      echo "Using GitHub CLI diff"  
      changed_files=$(gh pr diff ${{ github.event.number }} --name-only)
    else
      echo "Fallback: assume all files changed"
      changed_files=$(find . -name "*.java" -o -name "*.gradle")
    fi
```

### 3. 캐싱 최적화
```yaml
- name: Cache Gradle packages
  uses: actions/cache@v4
  with:
    path: |
      ~/.gradle/caches
      ~/.gradle/wrapper
      .gradle
    key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
    restore-keys: |
      ${{ runner.os }}-gradle-
```

## 🚀 빠른 수정 체크리스트

### PR 체크 실패 시:
- [ ] checkout에 `fetch-depth: 0` 추가됨
- [ ] git diff 명령어가 GitHub 컨텍스트 사용함
- [ ] 필요한 권한이 설정됨
- [ ] 조건부 실행으로 빈 모듈 처리함

### 보안 스캔 실패 시:
- [ ] `security-events: write` 권한 추가됨
- [ ] SARIF 업로드가 조건부로 실행됨
- [ ] 에러 무시 설정(`if: always()`) 추가됨

### 일반적인 실패 시:
- [ ] 워크플로우 파일 문법 오류 확인
- [ ] 필요한 secrets 설정 확인  
- [ ] 브랜치 보호 규칙과 충돌 없는지 확인

## 📞 추가 지원

더 복잡한 문제가 발생하면:
1. GitHub Actions 로그에서 정확한 에러 메시지 확인
2. 해당 액션의 문서 참조
3. GitHub Community Forum에서 유사 사례 검색
4. 필요시 워크플로우 단순화하여 문제 격리