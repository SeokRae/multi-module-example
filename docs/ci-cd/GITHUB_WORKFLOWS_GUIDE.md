# GitHub Workflows 가이드

## 📋 개요

이 문서는 multi-module-example 프로젝트의 GitHub Actions 워크플로우에 대한 완전한 가이드입니다. 
모든 워크플로우는 성능 최적화와 신뢰성을 위해 설계되었습니다.

## 🚀 워크플로우 목록

### 1. CI/CD 메인 워크플로우 (`ci.yml`)

**트리거**: 
- Push: `main`, `develop`, `feature/**`, `release/**`, `hotfix/**` 브랜치
- Pull Request: `main`, `develop` 브랜치 대상

**주요 작업**:
- **Code Quality**: 컴파일 검사 및 코드 품질 확인
- **Smart Tests**: 모듈별 병렬 테스트 실행
- **Build**: 최적화된 JAR 빌드 및 아티팩트 생성
- **Integration Tests**: PostgreSQL/Redis 통합 테스트
- **Security Check**: 의존성 취약점 및 하드코딩 시크릿 검사
- **Deployment**: 스테이징/프로덕션 배포 (브랜치별)

**성능 최적화**:
```yaml
# Gradle 최적화
- uses: gradle/gradle-build-action@v3
  with:
    cache-read-only: false
    cache-write-only: false
    gradle-home-cache-cleanup: true

# 병렬 빌드 + 캐시
- run: ./gradlew build --parallel --build-cache
```

### 2. Pull Request 검증 (`pr-checks.yml`)

**트리거**: PR 생성, 업데이트, 재오픈 시

**주요 검증**:
- **PR 제목 검증**: Semantic PR 제목 형식 검사
- **브랜치명 검증**: `feature/`, `fix/`, `hotfix/`, `docs/`, `chore/` 형식
- **빠른 컴파일 검사**: 컴파일 오류 조기 발견
- **변경 영향 분석**: 변경된 파일 기반 스마트 테스트
- **문서 일관성 검사**: API 변경시 문서 업데이트 확인
- **보안 패턴 검사**: 민감정보, SQL 인젝션 패턴 검사
- **빌드 성능 측정**: 빌드 시간 모니터링 (2분/5분 임계값)

**스마트 테스트 로직**:
```bash
# 변경된 파일 기반으로 영향받는 모듈만 테스트
if echo "$changed_files" | grep -q "common/"; then
  run_tests_if_exist "common:common-core"
  run_tests_if_exist "common:common-web"
fi
```

### 3. SonarQube 분석 (`sonarqube.yml`)

**트리거**: 
- 수동 실행 (`workflow_dispatch`)
- Push: `main`, `develop` 브랜치
- Pull Request: `main`, `develop` 브랜치 대상

**현재 상태**: 
- SonarQube 분석은 프로젝트 설정 이슈로 일시 비활성화
- 최적화된 빌드만 실행하여 코드 컴파일 검증

### 4. Claude Code 자동 워크플로우 (`claude-auto-workflow.yml`)

**트리거**: 
- 수동 실행 (`workflow_dispatch`)
- 이슈 코멘트 (`issue_comment`)

**자동화 단계**:
1. **이슈 생성**: 상세한 개발 이슈 자동 생성
2. **브랜치 생성**: `feature/[기능명]` 브랜치 생성
3. **개발 트리거**: Claude Code에게 개발 시작 알림
4. **자동 머지**: CI 통과시 자동 승인 및 머지

## ⚡ 성능 최적화 전략

### 1. Gradle 빌드 최적화

```yaml
env:
  GRADLE_OPTS: '-Dorg.gradle.daemon=false -Dorg.gradle.parallel=true -Dorg.gradle.caching=true'
```

**주요 플래그**:
- `--parallel`: 병렬 실행으로 빌드 시간 단축
- `--build-cache`: 빌드 캐시로 중복 작업 방지  
- `--info`: 상세 로그로 디버깅 지원

### 2. 캐싱 전략

**Enhanced Gradle Caching**:
```yaml
- name: Setup Gradle with enhanced caching
  uses: gradle/gradle-build-action@v3
  with:
    cache-read-only: false
    cache-write-only: false
    gradle-home-cache-cleanup: true
```

**SonarQube 캐싱**:
```yaml
- name: Cache SonarQube packages
  uses: actions/cache@v4
  with:
    path: ~/.sonar/cache
    key: ${{ runner.os }}-sonar-${{ hashFiles('**/build.gradle*') }}
```

### 3. 아티팩트 최적화

```yaml
- name: Upload build artifacts
  uses: actions/upload-artifact@v4
  with:
    retention-days: 7  # 7일 후 자동 삭제
```

## 🔒 보안 검사 항목

### 1. 시크릿 패턴 검사
- 하드코딩된 패스워드, API 키, 토큰 탐지
- 워크플로우 및 문서 파일 제외
- GitHub Secrets 사용 패턴은 허용

### 2. SQL 인젝션 패턴 검사
- 파라미터 바인딩 없는 쿼리 탐지
- PreparedStatement 사용 권장

### 3. 의존성 취약점 검사
```bash
./gradlew dependencies --configuration runtimeClasspath | grep -i "FAIL\|ERROR\|WARN"
```

## 📊 성능 메트릭 및 임계값

### 빌드 성능 기준
- **양호**: 2분 이하
- **주의**: 2-5분
- **개선 필요**: 5분 초과

### 캐시 성능 기준
- **캐시 히트율**: 80% 이상 목표
- **빌드 시간 단축**: 30% 이상

### 아티팩트 저장 최적화
- **보존 기간**: 7일 (비용 절약)
- **압축률**: JAR 파일 자동 압축

## 🎯 워크플로우 실행 시나리오

### 시나리오 1: Feature 개발
```
1. feature/* 브랜치 Push
   → CI 워크플로우 트리거
   → 전체 테스트 스위트 실행
   
2. PR 생성
   → PR 검증 워크플로우 트리거
   → 변경 영향 분석 후 스마트 테스트
   
3. PR 머지
   → develop 브랜치 CI 실행
   → 스테이징 배포 트리거
```

### 시나리오 2: 핫픽스
```
1. hotfix/* 브랜치 생성
   → 긴급 수정 사항 구현
   
2. PR to main
   → 전체 보안 검사 + 성능 테스트
   
3. 머지 후
   → 프로덕션 배포 (수동 승인 필요)
   → 릴리즈 노트 자동 생성
```

### 시나리오 3: 문서 업데이트
```
1. docs/* 파일만 변경
   → PR 검증에서 빌드 스킵
   → 문서 일관성만 검사
   
2. 빠른 머지 가능
   → CI 오버헤드 최소화
```

## 🛠️ 트러블슈팅 가이드

### 일반적인 문제 해결

**1. 빌드 실패시**
```bash
# 로컬에서 같은 명령어 실행
./gradlew build --parallel --build-cache --info

# 캐시 문제시 초기화
./gradlew clean build --no-build-cache
```

**2. 테스트 실패시**
```bash
# 특정 모듈만 테스트
./gradlew :application:user-api:test

# 테스트 리포트 확인
open application/user-api/build/reports/tests/test/index.html
```

**3. 캐시 문제시**
- GitHub Actions 캐시 수동 삭제
- `gradle-home-cache-cleanup: true` 설정 확인

### 성능 이슈 디버깅

**빌드 성능 분석**:
```bash
./gradlew build --profile --parallel --build-cache
# 결과: build/reports/profile/
```

**의존성 분석**:
```bash
./gradlew dependencies --configuration compileClasspath
```

## 📈 모니터링 및 알림

### GitHub Actions 대시보드
- 워크플로우 실행 시간 모니터링
- 성공/실패율 추적
- 캐시 히트율 분석

### 알림 설정
- 빌드 실패시 Slack/이메일 알림 (향후 추가 예정)
- 성능 저하 임계값 도달시 경고

## 🔄 워크플로우 유지보수

### 정기 점검 항목
- [ ] 의존성 업데이트 (월 1회)
- [ ] 캐시 성능 검토 (주 1회) 
- [ ] 보안 패턴 규칙 업데이트 (분기 1회)
- [ ] 성능 임계값 조정 (필요시)

### 개선 계획
- [ ] 스마트 모듈 감지 시스템 고도화
- [ ] 조건부 작업 실행 확대
- [ ] 테스트 병렬성 향상
- [ ] SonarQube 재활성화

---

## 📚 참고 자료

- [GitHub Actions 공식 문서](https://docs.github.com/actions)
- [Gradle Build Action](https://github.com/gradle/gradle-build-action)
- [Spring Boot CI/CD 모범 사례](https://spring.io/guides/gs/testing-web/)

**문서 버전**: v1.0  
**최종 업데이트**: 2025-01-12  
**작성자**: Claude Code Auto Development Workflow