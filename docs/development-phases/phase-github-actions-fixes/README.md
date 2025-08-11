# Phase: GitHub Actions 설정 문제 해결

## 📅 진행 기간
**시작일**: 2025-08-11  
**상태**: 진행 중

## 🎯 목적
GitHub Actions 워크플로우에서 발생하는 설정 문제들을 체계적으로 해결하여 안정적인 CI/CD 파이프라인 구축

## 📋 해결해야 할 Issues

### 🚨 High Priority
- [x] **Issue #16**: Git diff 참조 오류 해결
- [ ] **Issue #17**: Token 권한 부족 문제 해결
- [ ] **Issue #18**: 보안 스캔 SARIF 업로드 실패 해결

### ⚡ Enhancement  
- [ ] **Issue #19**: 워크플로우 최적화 및 성능 개선

## 📊 현재 진행 상황

### ✅ 완료된 작업

#### Issue #16 해결: Git diff 참조 오류
**날짜**: 2025-08-11  
**브랜치**: `fix/github-actions-git-diff-issue-16`

**문제점**:
```
fatal: ambiguous argument 'origin/main...HEAD': unknown revision or path not in the working tree.
```

**해결 방법**:
1. **Checkout 설정 개선**:
   ```yaml
   - name: Checkout code
     uses: actions/checkout@v4
     with:
       fetch-depth: 0  # 전체 히스토리 가져오기
   ```

2. **Git diff 명령어 수정**:
   ```yaml
   # 기존 (문제 있음)
   changed_files=$(git diff --name-only origin/${{ github.base_ref }}...HEAD)
   
   # 수정됨 (GitHub 컨텍스트 사용)
   changed_files=$(git diff --name-only ${{ github.event.pull_request.base.sha }}...${{ github.sha }})
   ```

**영향받는 파일**:
- `.github/workflows/pr-checks.yml`

**테스트 필요**: 다음 PR에서 자동으로 검증됨

#### Issue #17 해결: GitHub Token 권한 부족 문제
**날짜**: 2025-08-11  
**브랜치**: `fix/github-token-permissions-issue-17`

**문제점**:
```
Resource not accessible by integration
```

**해결 방법**:
1. **PR 검증 작업에 권한 추가**:
   ```yaml
   pr-validation:
     permissions:
       contents: read
       pull-requests: write  # PR 제목 검증을 위해 필요
       checks: write        # 체크 상태 업데이트를 위해 필요
   ```

2. **Git diff 명령어 통일**:
   - 보안 체크와 SQL 인젝션 체크에서 일관된 GitHub 컨텍스트 사용
   ```yaml
   # 수정됨 (모든 diff 명령어 통일)
   git diff ${{ github.event.pull_request.base.sha }}...${{ github.sha }}
   ```

**영향받는 파일**:
- `.github/workflows/pr-checks.yml`

**테스트 중**: [PR #21](https://github.com/SeokRae/multi-module-example/pull/21)에서 자동 검증 진행 중

### 🔄 진행 중인 작업
- PR #21 테스트 결과 확인 및 병합 대기

#### 추가 최적화: 개인 리포지토리용 워크플로우 단순화
**날짜**: 2025-08-11  
**브랜치**: `fix/github-token-permissions-issue-17`

**개선 사항**:
1. **Security Scan 단순화**:
   - 복잡한 SARIF 업로드 제거 (Enterprise/Organization 전용 기능)
   - Gradle 의존성 체크 및 기본 시크릿 패턴 검사로 대체

2. **Qodana 최적화**:
   - 자동 실행 비활성화 (`workflow_dispatch`만 허용)
   - 개인 리포지토리에는 과도한 분석 도구

**영향받는 파일**:
- `.github/workflows/ci.yml`
- `.github/workflows/qodana_code_quality.yml`

#### Issue #18 해결: SonarQube 코드 품질/보안 분석 도입
**날짜**: 2025-08-11  
**브랜치**: `fix/github-token-permissions-issue-17`

**문제 재정의**:
- 기존 SARIF 업로드는 Enterprise/Organization 전용 기능
- 개인 리포지토리에는 SonarQube가 더 적합한 솔루션

**구현 사항**:
1. **SonarQube 워크플로우 생성**:
   ```yaml
   # .github/workflows/sonarqube.yml
   - SonarCloud 연동 (무료 퍼블릭 리포지토리)
   - 캐싱으로 성능 최적화
   - PR 및 메인 브랜치 자동 분석
   ```

2. **Gradle 설정 추가**:
   ```gradle
   plugins {
       id 'org.sonarqube' version '4.4.1.3373'
   }
   
   sonar {
       properties {
           property "sonar.projectKey", "SeokRae_multi-module-example"
           property "sonar.organization", "seokrae"
           // 코드 커버리지, 테스트 결과 통합
       }
   }
   ```

**장점**:
- 코드 품질, 보안 취약점, 중복 코드 통합 분석
- PR에 직접 분석 결과 표시
- 무료 사용 (퍼블릭 리포지토리)

**영향받는 파일**:
- `.github/workflows/sonarqube.yml` (신규)
- `build.gradle` (SonarQube 플러그인 및 설정 추가)

**남은 작업**: SonarCloud 조직/프로젝트 생성 및 SONAR_TOKEN 설정

### ⏳ 예정된 작업
1. SonarCloud 계정 설정 및 첫 분석 실행
2. Issue #19: 워크플로우 성능 최적화
3. 성능 최적화 구현
4. 문서화 완료

## 📈 성공 지표
- [ ] 모든 PR에서 git diff 오류 없이 실행
- [ ] PR 제목 검증 액션 정상 작동
- [ ] 보안 스캔 결과가 GitHub Security 탭에 업로드
- [ ] 워크플로우 평균 실행 시간 30% 단축

## 🔗 관련 링크
- [트러블슈팅 가이드](../ci-cd/github-actions-troubleshooting.md)
- [워크플로우 설정 가이드](../ci-cd/workflow-configuration-guide.md)
- [Issue #16](https://github.com/SeokRae/multi-module-example/issues/16)
- [Issue #17](https://github.com/SeokRae/multi-module-example/issues/17)
- [Issue #18](https://github.com/SeokRae/multi-module-example/issues/18)
- [Issue #19](https://github.com/SeokRae/multi-module-example/issues/19)

## 📝 학습 내용
- GitHub Actions의 shallow clone 제한사항
- GITHUB_TOKEN 권한 설정의 중요성
- PR 컨텍스트에서의 안전한 git diff 방법
- SARIF 파일 업로드를 위한 보안 권한 설정