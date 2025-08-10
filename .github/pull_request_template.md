# 🔄 Pull Request

## 📋 PR 유형 및 브랜치
<!-- 해당하는 항목에 ✅ 표시해주세요 -->

### 브랜치 타입
- [ ] 🌿 **Feature Branch** (`feature/*`)
- [ ] 🐛 **Bugfix Branch** (`bugfix/*`)
- [ ] 🚨 **Hotfix Branch** (`hotfix/*`)
- [ ] 🚀 **Release Branch** (`release/*`)

### 변경 사항 유형
- [ ] 🆕 새로운 기능 (feature)
- [ ] 🐛 버그 수정 (fix)
- [ ] 📚 문서 업데이트 (docs)
- [ ] 🎨 코드 스타일 변경 (style)
- [ ] ♻️ 리팩토링 (refactor)
- [ ] ⚡ 성능 개선 (perf)
- [ ] ✅ 테스트 추가/수정 (test)
- [ ] 🔧 빌드/설정 변경 (chore)
- [ ] 🔒 보안 개선 (security)

## 🎯 Phase 정보
<!-- Phase 개발인 경우 작성 -->

**브랜치명**: `[브랜치 전체명]`  
**Phase**: Phase [번호] - [이름] (해당시)  
**목표**: [Phase의 주요 목표]

## 🔗 관련 이슈
<!-- 관련 이슈가 있다면 연결해주세요 -->
- Closes #(이슈번호)
- Fixes #(이슈번호)  
- Related to #(이슈번호)

### 종속성
- [ ] 다른 PR에 의존: #(PR번호)
- [ ] 다른 PR을 블록: #(PR번호)
- [ ] 독립적 PR

## 📝 변경 상세 내용
### 구현된 기능
<!-- 어떤 기능을 추가했는지 설명해주세요 -->
- 

### 수정된 버그
<!-- 어떤 버그를 수정했는지 설명해주세요 -->
- 

### 변경된 아키텍처
<!-- 아키텍처나 설계 변경사항이 있다면 설명해주세요 -->
- 

## 🧪 테스트
### 테스트 완료 체크리스트
- [ ] 단위 테스트 통과 (`./gradlew test`)
- [ ] 통합 테스트 통과 (`./gradlew integrationTest`)
- [ ] API 테스트 수행
- [ ] 보안 테스트 수행 (해당하는 경우)
- [ ] 성능 테스트 수행 (해당하는 경우)

### 테스트 방법
<!-- 리뷰어가 테스트할 수 있는 방법을 설명해주세요 -->
```bash
# 예시: API 테스트 방법
./gradlew :application:user-api:bootRun
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

## 📊 영향도 분석
### 영향받는 모듈
- [ ] common-core
- [ ] common-web  
- [ ] common-security
- [ ] user-domain
- [ ] product-domain
- [ ] order-domain
- [ ] data-access
- [ ] user-api
- [ ] batch-app

### Breaking Changes
- [ ] 없음
- [ ] 있음 (아래에 상세 설명)

<!-- Breaking Changes가 있다면 상세히 설명해주세요 -->
**Breaking Changes 상세:**
- 

### 데이터베이스 변경
- [ ] 없음
- [ ] 스키마 변경 있음 (마이그레이션 스크립트 포함)
- [ ] 데이터 마이그레이션 필요

## 📚 문서화
- [ ] API 문서 업데이트 완료
- [ ] README 업데이트 완료 (필요한 경우)
- [ ] 아키텍처 문서 업데이트 완료 (필요한 경우)
- [ ] 변경사항 CHANGELOG에 추가

## 🔒 보안 체크리스트
- [ ] 민감 정보 (API 키, 비밀번호 등) 하드코딩 없음
- [ ] SQL 인젝션 취약점 없음
- [ ] XSS 취약점 없음
- [ ] 인증/인가 로직 적절히 구현
- [ ] 입력 데이터 검증 로직 포함

## 📸 스크린샷/데모 (UI 변경사항이 있는 경우)
<!-- 스크린샷이나 GIF를 첨부해주세요 -->

## ⚠️ 주의사항
<!-- 배포시 주의할 점이나 설정 변경사항을 기록해주세요 -->
- [ ] 환경변수 설정 필요: `JWT_SECRET=your-secret-key`
- [ ] 데이터베이스 마이그레이션 실행 필요
- [ ] 캐시 초기화 필요
- [ ] 기타: 

## 🔍 체크리스트 (리뷰어용)
### 코드 품질
- [ ] 코드가 프로젝트 코딩 스타일을 따름
- [ ] 복잡한 로직에 적절한 주석 있음
- [ ] 변수/메서드명이 명확함
- [ ] 중복 코드 없음

### 아키텍처
- [ ] 레이어 구조 적절히 분리됨
- [ ] 의존성 주입 적절히 사용됨
- [ ] 도메인 로직이 적절한 위치에 있음
- [ ] 예외 처리가 적절함

### 테스트
- [ ] 테스트 커버리지 충분함 (80% 이상)
- [ ] 엣지 케이스 테스트 포함
- [ ] Mock 객체 적절히 사용됨

### 성능
- [ ] N+1 쿼리 문제 없음
- [ ] 불필요한 데이터 로딩 없음
- [ ] 적절한 인덱스 사용

---

## ✅ 브랜치 워크플로우 체크리스트

### 브랜치 생성 확인
- [ ] `develop` 브랜치에서 시작
- [ ] 브랜치명이 컨벤션을 따름 (`feature/`, `bugfix/`, `hotfix/`)
- [ ] 최신 `develop` 브랜치로 시작됨

### 커밋 확인  
- [ ] Conventional Commits 형식 준수
- [ ] 각 커밋이 논리적 단위를 가짐
- [ ] Co-Authored-By 태그 포함 (Claude Code 사용시)

### 머지 전 확인
- [ ] 모든 CI 체크 통과
- [ ] 충돌(Conflicts) 해결 완료
- [ ] 최신 target 브랜치와 동기화
- [ ] 최소 1명 이상의 리뷰 승인

### 머지 후 작업 (체크용)
- [ ] Feature 브랜치 삭제 예정
- [ ] 관련 이슈 닫기 예정
- [ ] 다음 Phase 또는 작업 계획됨

---

**Git Flow 워크플로우를 따라주세요:**
1. **Feature**: `develop` → `feature/branch-name` → `develop` (PR 머지)
2. **Release**: `develop` → `release/vX.Y.Z` → `main` + `develop`
3. **Hotfix**: `main` → `hotfix/issue-name` → `main` + `develop`

**PR 작성자를 위한 팁:**
- 작고 집중된 변경사항으로 PR을 구성해주세요
- 커밋 메시지는 Conventional Commits 형식을 따라주세요
- 자신의 코드를 먼저 리뷰한 후 PR을 생성해주세요
- 📚 [개발 워크플로우 가이드](DEVELOPMENT_WORKFLOW.md) 참조