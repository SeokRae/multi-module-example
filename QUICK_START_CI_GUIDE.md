# ⚡ CI/CD 퀵 스타트 가이드

> **새로운 개발자를 위한 5분 CI/CD 온보딩**

## 🎯 목표

이 가이드를 따라하면 **5분 내에** CI/CD 파이프라인을 이해하고 첫 번째 PR을 성공적으로 생성할 수 있습니다.

## 📋 단계별 가이드

### 1️⃣ **환경 설정 (2분)**

```bash
# GitHub CLI 설치 확인
gh --version

# 프로젝트 클론 (이미 했다면 스킵)
git clone https://github.com/SeokRae/multi-module-example.git
cd multi-module-example

# 초기 설정 스크립트 실행
./scripts/01-setup-branch-protection.sh  # GitHub 브랜치 보호 설정
./scripts/02-setup-mcp-integration.sh    # MCP Git 통합 (선택사항)
```

### 2️⃣ **빌드 검증 (1분)**

```bash
# 전체 프로젝트 빌드 확인
./scripts/11-verify-build-modules.sh

# 성공 시 다음과 같이 출력됩니다:
# ✅ All 11 modules built successfully
# ✅ Tests passed: 156/156
# ✅ Build time: 45s
```

### 3️⃣ **첫 번째 Feature 개발 (2분)**

```bash
# Git Flow 브랜치 생성
./scripts/10-branch-helper.sh feature my-first-feature

# 간단한 변경사항 추가 (예: README 수정)
echo "## My First Contribution" >> README.md

# 커밋 (Conventional Commits 형식)
git add .
git commit -m "docs: add my first contribution section

- Add new section to README
- Test CI/CD pipeline functionality

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# PR 생성 및 자동 CI 트리거
./scripts/10-branch-helper.sh finish feature
```

## 🚀 CI/CD가 자동으로 하는 일들

### PR 생성 시 즉시 실행:

1. **형식 검증** (30초)
   ```
   ✅ PR 제목: docs: add my first contribution section
   ✅ 브랜치명: feature/my-first-feature
   ✅ Conventional Commits 형식 확인
   ```

2. **빠른 빌드 체크** (1분)
   ```
   ✅ 컴파일 성공
   ✅ 영향받는 모듈 테스트
   ✅ 보안 패턴 체크
   ```

3. **품질 검증** (2분)
   ```
   ✅ 코드 품질 스캔
   ✅ 문서 변경 감지
   ✅ 성능 영향 분석
   ```

### PR 머지 후 자동 실행:

4. **전체 테스트** (5분)
   ```
   ✅ 11개 모듈 병렬 테스트
   ✅ PostgreSQL + Redis 통합 테스트
   ✅ 보안 취약점 스캔
   ```

5. **자동 배포** (3분)
   ```
   ✅ 스테이징 환경 배포 (develop 브랜치)
   ✅ 프로덕션 배포 (main 브랜치, 수동 승인 필요)
   ```

## 📊 CI/CD 상태 확인 방법

### GitHub에서 확인

1. **Actions 탭**: 모든 워크플로우 실행 상태
   ```
   https://github.com/SeokRae/multi-module-example/actions
   ```

2. **Pull Request**: 자동 상태 체크
   ```
   ✅ PR Checks: All checks have passed
   ✅ Build Status: Success
   ✅ Tests: 156 passed
   ```

3. **Security 탭**: 보안 스캔 결과
   ```
   https://github.com/SeokRae/multi-module-example/security
   ```

### CLI로 확인

```bash
# 현재 워크플로우 상태
gh workflow list

# PR 상태 확인
gh pr status

# 마지막 CI 실행 결과
gh run list --limit 5
```

## 🆘 문제 발생 시 해결 방법

### ❌ 빌드 실패

```bash
# 1. 진단 스크립트 실행
./scripts/12-build-diagnostics.sh

# 2. 로컬에서 빌드 재시도
./gradlew clean build

# 3. 특정 모듈 테스트
./gradlew :domain:user-domain:test
```

### ❌ 테스트 실패

```bash
# 1. API 테스트 실행
./scripts/13-test-api-endpoints.sh

# 2. 특정 모듈 상세 테스트
./gradlew :application:user-api:test --info

# 3. 테스트 보고서 확인
open application/user-api/build/reports/tests/test/index.html
```

### ❌ 보안 스캔 실패

```bash
# 1. 의존성 보안 체크
./scripts/20-dependency-health-check.sh

# 2. Dependabot 분석
./scripts/21-dependabot-pr-analyzer.sh

# 3. 취약점 상세 정보 확인
# GitHub Security 탭에서 확인
```

## 🤖 Dependabot 자동화 체험

### 의존성 업데이트 PR 생성

Dependabot이 자동으로 의존성 업데이트 PR을 생성하면:

1. **자동 분석 실행** (3분)
   ```
   🤖 Automated Dependabot Review
   
   Dependency: spring-boot-starter-web
   Update Type: patch
   Risk Level: LOW
   Version Change: from 3.2.1 to 3.2.2
   ```

2. **자동 승인 또는 리뷰 요청**
   ```
   ✅ LOW Risk → 자동 승인 + 머지
   ⚠️ MEDIUM Risk → 리뷰 요청
   ❌ HIGH Risk → 변경 요청
   ```

## 🔗 상세 가이드 링크

완전한 이해를 위한 상세 가이드들:

- 📚 **[종합 CI/CD 가이드](.github/CI_ONBOARDING_GUIDE.md)**: 전체 파이프라인 상세 설명
- 🌿 **[Git Flow 가이드](.github/DEVELOPMENT_WORKFLOW.md)**: 브랜치 전략과 워크플로우  
- 🔧 **[스크립트 가이드](scripts/README.md)**: 모든 자동화 스크립트 설명
- 🏗️ **[아키텍처 가이드](docs/development-phases/phase-0-project-setup/architecture-design.md)**: 프로젝트 구조 이해

## ✅ 성공 체크리스트

온보딩이 성공적으로 완료되었는지 확인:

- [ ] 첫 번째 PR이 자동 CI 검증을 통과했다
- [ ] GitHub Actions에서 녹색 체크마크를 확인했다  
- [ ] PR 머지 후 develop 브랜치에 자동 배포되었다
- [ ] 스크립트들을 사용해서 로컬 빌드/테스트를 실행했다
- [ ] Dependabot PR의 자동 분석을 확인했다

## 🎉 다음 단계

CI/CD 온보딩을 완료했다면:

1. **Phase 2 개발 참여**: Product/Order API 구현
2. **고급 스크립트 활용**: 성능 최적화, 보안 강화
3. **모니터링 설정**: 배포 알림, 성능 메트릭 추가
4. **팀 워크플로우 개선**: CI/CD 파이프라인 최적화 제안

---

**🚀 축하합니다! 이제 CI/CD 파이프라인을 완전히 활용할 수 있습니다!**

**문의사항**: GitHub Issues 또는 팀 Slack 채널에서 언제든 질문해주세요.