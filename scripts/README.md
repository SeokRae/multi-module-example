# 🚀 Scripts Execution Guide

> **Multi-Module E-Commerce Platform** 개발 및 CI/CD를 위한 스크립트 실행 가이드

## 📋 스크립트 실행 순서

새로운 개발자나 CI/CD 환경에서 **순서대로 실행**하면 됩니다.

### 🏗️ Phase 1: 초기 설정 (Setup Scripts)

#### `01-setup-branch-protection.sh` 
```bash
./scripts/01-setup-branch-protection.sh
```
**목적**: GitHub 브랜치 보호 규칙 설정  
**필요조건**: 
- GitHub CLI (`gh`) 설치 및 인증
- Repository admin 권한  
**결과**: main/develop 브랜치 보호 규칙 적용

#### `02-setup-mcp-integration.sh`
```bash
./scripts/02-setup-mcp-integration.sh  
```
**목적**: Claude Code MCP Git 통합 설정  
**필요조건**: 
- Node.js/npm 설치
- Claude Code 사용 환경  
**결과**: AI 기반 개발 환경 구축

---

### 🛠️ Phase 2: 개발 도구 (Development Tools)

#### `10-branch-helper.sh`
```bash
# Git Flow 브랜치 관리
./scripts/10-branch-helper.sh status              # 현재 상태 확인
./scripts/10-branch-helper.sh feature <name>      # Feature 브랜치 생성
./scripts/10-branch-helper.sh finish feature      # Feature 완료 (PR 생성)
./scripts/10-branch-helper.sh cleanup             # 머지된 브랜치 정리
```
**목적**: Git Flow 워크플로우 자동화  
**사용시점**: 매일 개발 시작 전/후  
**결과**: 체계적인 브랜치 관리

#### `11-verify-build-modules.sh`
```bash
./scripts/11-verify-build-modules.sh
```
**목적**: 전체 모듈 빌드 검증  
**사용시점**: 개발 완료 후, CI 시작 전  
**결과**: 11개 모듈 빌드 성공 확인

#### `12-build-diagnostics.sh`
```bash
./scripts/12-build-diagnostics.sh
```
**목적**: 빌드 문제 진단 및 해결책 제시  
**사용시점**: 빌드 실패 시  
**결과**: 상세한 오류 분석 및 수정 가이드

#### `13-test-api-endpoints.sh`
```bash
./scripts/13-test-api-endpoints.sh
```
**목적**: API 엔드포인트 기능 테스트  
**사용시점**: API 구현 완료 후  
**결과**: 모든 API 엔드포인트 동작 검증

---

### 🔄 Phase 3: CI/CD 자동화 (Automation Scripts)

#### `20-dependency-health-check.sh`
```bash
./scripts/20-dependency-health-check.sh
```
**목적**: 의존성 보안 및 버전 상태 점검  
**사용시점**: 주간 정기 점검, 릴리스 전  
**결과**: 의존성 취약점 및 업데이트 리포트

#### `21-dependabot-pr-analyzer.sh`
```bash
./scripts/21-dependabot-pr-analyzer.sh
```
**목적**: Dependabot PR 자동 분석 및 분류  
**사용시점**: Dependabot PR 생성 시 (자동)  
**결과**: 위험도별 PR 분류 및 처리 권장사항

#### `22-auto-review-dependabot-pr.sh`
```bash
./scripts/22-auto-review-dependabot-pr.sh
```
**목적**: 안전한 Dependabot PR 자동 승인  
**사용시점**: 저위험 Dependabot PR 생성 시  
**결과**: 자동 리뷰 및 머지

---

### 📝 Phase 4: GitHub/PR 관리 (GitHub Management)

#### `30-check-github-prs.sh`
```bash
./scripts/30-check-github-prs.sh
```
**목적**: GitHub PR 상태 및 충돌 확인  
**사용시점**: PR 머지 전, 정기 점검  
**결과**: PR 상태 대시보드

#### `31-pr-manager.sh`
```bash
./scripts/31-pr-manager.sh
```
**목적**: PR 생성, 리뷰, 머지 자동화  
**사용시점**: 대량 PR 처리 시  
**결과**: 일괄 PR 관리

#### `32-github-mcp-helper.py`
```bash
python ./scripts/32-github-mcp-helper.py
```
**목적**: GitHub API와 MCP 통합 도구  
**사용시점**: 고급 GitHub 자동화 필요 시  
**결과**: AI 기반 GitHub 작업 자동화

---

### 📚 Phase 5: 문서화 (Documentation)

#### `40-docs-generator.sh`
```bash
./scripts/40-docs-generator.sh
```
**목적**: API 문서 및 프로젝트 문서 자동 생성  
**사용시점**: 릴리스 전, 주기적 문서 업데이트  
**결과**: 최신 API 문서 및 아키텍처 문서

---

## 🎯 시나리오별 실행 가이드

### 🆕 새로운 개발자 온보딩

```bash
# 1. 기본 환경 설정
./scripts/01-setup-branch-protection.sh
./scripts/02-setup-mcp-integration.sh

# 2. 개발 환경 검증  
./scripts/11-verify-build-modules.sh
./scripts/13-test-api-endpoints.sh

# 3. 워크플로우 학습
./scripts/10-branch-helper.sh status
```

### 🛠️ 일반 개발 워크플로우

```bash
# 1. 개발 시작
./scripts/10-branch-helper.sh feature my-new-feature

# 2. 개발 중 검증
./scripts/11-verify-build-modules.sh
./scripts/13-test-api-endpoints.sh

# 3. 개발 완료
./scripts/10-branch-helper.sh finish feature

# 4. 정리
./scripts/10-branch-helper.sh cleanup
```

### 🚀 릴리스 준비

```bash
# 1. 의존성 및 보안 점검
./scripts/20-dependency-health-check.sh
./scripts/21-dependabot-pr-analyzer.sh

# 2. 전체 빌드 및 테스트
./scripts/11-verify-build-modules.sh
./scripts/13-test-api-endpoints.sh

# 3. 문서 업데이트
./scripts/40-docs-generator.sh

# 4. PR 상태 확인
./scripts/30-check-github-prs.sh
```

### 🆘 문제 해결 (Troubleshooting)

```bash
# 빌드 실패 시
./scripts/12-build-diagnostics.sh

# 의존성 문제 시
./scripts/20-dependency-health-check.sh

# GitHub PR 문제 시
./scripts/30-check-github-prs.sh
./scripts/31-pr-manager.sh
```

## ⚙️ 자동화 설정 (CI/CD)

### GitHub Actions 워크플로우

```yaml
# .github/workflows/ci.yml 예시
jobs:
  setup:
    steps:
      - run: ./scripts/11-verify-build-modules.sh
      - run: ./scripts/13-test-api-endpoints.sh
      
  security:
    steps:
      - run: ./scripts/20-dependency-health-check.sh
      - run: ./scripts/21-dependabot-pr-analyzer.sh
      
  documentation:
    steps:
      - run: ./scripts/40-docs-generator.sh
```

### 주간 자동 실행 (Cron)

```bash
# crontab 예시
# 매주 월요일 오전 9시: 의존성 점검
0 9 * * 1 cd /path/to/project && ./scripts/20-dependency-health-check.sh

# 매일 오후 6시: PR 상태 점검  
0 18 * * * cd /path/to/project && ./scripts/30-check-github-prs.sh
```

## 📊 스크립트 실행 결과 예시

### ✅ 성공적인 실행
```bash
$ ./scripts/11-verify-build-modules.sh
✅ All 11 modules built successfully
✅ Tests passed: 156/156
✅ Build time: 45s
```

### ⚠️ 주의가 필요한 경우
```bash
$ ./scripts/20-dependency-health-check.sh  
⚠️  Found 3 dependency updates available
⚠️  1 security vulnerability detected
💡 Run ./scripts/21-dependabot-pr-analyzer.sh for details
```

### ❌ 오류 발생 시
```bash
$ ./scripts/11-verify-build-modules.sh
❌ Build failed in module: user-api
💡 Run ./scripts/12-build-diagnostics.sh for detailed analysis
```

## 🔧 스크립트 요구사항

### 필수 도구
- **Git**: 버전 관리
- **GitHub CLI** (`gh`): GitHub API 작업
- **Node.js/npm**: MCP 통합
- **Java 17+**: 프로젝트 빌드
- **Gradle**: 빌드 도구

### 권한 요구사항
- **Repository Admin**: 브랜치 보호 설정
- **GitHub Token**: API 접근
- **Write Access**: PR 생성/머지

### 환경 변수
```bash
export GITHUB_TOKEN="your-github-token"
export JAVA_HOME="/path/to/java17"
```

---

**스크립트 가이드 버전**: v1.0  
**최종 업데이트**: 2025-01-10  
**문의**: 프로젝트 README 참조