# SonarCloud 설정 가이드

## 📋 개요

SonarCloud는 퍼블릭 리포지토리에 무료로 제공되는 코드 품질 및 보안 분석 도구입니다.

## 🚀 설정 단계

### 1단계: SonarCloud 계정 생성

1. **SonarCloud 접속**: https://sonarcloud.io
2. **GitHub 연동**: "Log in with GitHub" 클릭
3. **권한 승인**: SonarCloud가 GitHub 리포지토리에 접근할 수 있도록 승인

### 2단계: Organization 설정

SonarCloud에서 "Organization"은 프로젝트를 그룹화하는 단위입니다. 개인 계정도 하나의 Organization으로 취급됩니다.

1. **개인 계정 사용** (권장):
   - GitHub 로그인 시 자동으로 개인 Organization이 생성됨
   - Organization key: 보통 GitHub 사용자명과 동일 (예: `seokrae`)

2. **새 Organization 생성** (선택사항):
   - "Create an organization" 선택
   - 팀이나 회사용으로 별도 Organization 생성

### 3단계: 프로젝트 생성

1. **프로젝트 추가**:
   - "+" 버튼 클릭 → "Analyze new project"
   - GitHub 리포지토리에서 `multi-module-example` 선택
   - "Set up" 클릭

2. **프로젝트 설정**:
   - **Project key**: `SeokRae_multi-module-example` (자동 생성됨)
   - **Display name**: `Multi-Module Example`
   - **Visibility**: Public (무료)

### 4단계: SONAR_TOKEN 생성

1. **토큰 생성**:
   - SonarCloud 우상단 프로필 클릭
   - "My Account" → "Security" 탭
   - "Generate Tokens" 섹션에서:
     - **Name**: `GitHub Actions`
     - **Type**: `User Token` (권장)
     - **Expiration**: `90 days` 또는 `No expiration`
     - "Generate" 클릭

2. **토큰 복사**:
   ```
   예시: squ_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0
   ```
   ⚠️ **중요**: 토큰은 한 번만 표시되므로 반드시 복사해서 저장해두세요.

### 5단계: GitHub Secrets 설정

1. **GitHub 리포지토리 이동**: https://github.com/SeokRae/multi-module-example

2. **Settings → Secrets and variables → Actions**:
   - "New repository secret" 클릭
   - **Name**: `SONAR_TOKEN`
   - **Value**: 위에서 복사한 토큰 값
   - "Add secret" 클릭

### 5-1단계: ⚠️ 중요 - Automatic Analysis 비활성화

**GitHub Actions CI 분석과 충돌 방지를 위해 반드시 설정해야 합니다:**

1. **SonarCloud 프로젝트 페이지 이동**
2. **Administration → Analysis Method** 클릭
3. **설정 변경**:
   - ❌ **"Automatic Analysis"** → OFF (비활성화)
   - ✅ **"CI-based Analysis"** → ON (활성화)
4. **Save** 클릭

**이 단계를 건너뛰면 다음 오류가 발생합니다:**
```
You are running CI analysis while Automatic Analysis is enabled. 
Please consider disabling one or the other.
```

### 6단계: build.gradle 설정 업데이트

현재 build.gradle의 SonarQube 설정을 실제 값으로 업데이트:

```gradle
sonar {
    properties {
        property "sonar.projectKey", "SeokRae_multi-module-example"
        property "sonar.organization", "seokrae"  // 실제 organization key로 변경
        property "sonar.host.url", "https://sonarcloud.io"
        // 기타 설정들...
    }
}
```

## ✅ 설정 확인

1. **GitHub Actions 실행**:
   - 다음 commit/PR에서 SonarQube Analysis가 성공적으로 실행되는지 확인

2. **SonarCloud 대시보드**:
   - https://sonarcloud.io 에서 프로젝트 분석 결과 확인
   - Code Quality, Security Hotspots, Coverage 등의 메트릭 확인

## 🔧 트러블슈팅

### 토큰 권한 오류
```
ERROR: You're not authorized to push analysis. Please check the user token.
```
**해결**: 토큰을 다시 생성하고 GitHub Secret을 업데이트

### Organization 키 불일치
```
ERROR: Project key 'wrong-key' not found
```
**해결**: build.gradle의 `sonar.organization`과 `sonar.projectKey` 확인

### 프로젝트 가시성 오류
```
ERROR: Insufficient privileges
```
**해결**: SonarCloud에서 프로젝트를 Public으로 설정

## 📊 SonarQube 분석 결과

설정 완료 후 다음과 같은 분석 결과를 얻을 수 있습니다:

- **Code Quality**: 버그, 코드 스멜, 기술 부채
- **Security**: 보안 취약점, 보안 핫스팟
- **Coverage**: 테스트 커버리지 (JaCoCo 연동 시)
- **Duplications**: 중복 코드 비율
- **Maintainability**: 유지보수성 등급

## 🔗 유용한 링크

- [SonarCloud 문서](https://docs.sonarcloud.io/)
- [Gradle SonarQube 플러그인](https://docs.sonarsource.com/sonarqube/10.6/analyzing-source-code/scanners/sonarscanner-for-gradle/)
- [GitHub Actions 통합](https://docs.sonarcloud.io/integrations/github/)