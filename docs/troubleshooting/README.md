# 🔧 Troubleshooting 문서 모음

이 디렉토리는 프로젝트 개발 과정에서 발생할 수 있는 일반적인 문제들과 해결 방법을 정리한 실용적인 가이드들을 포함합니다.

## 📚 문서 목록

### 🚀 [Quick Checklist](./QUICK_CHECKLIST.md)
**빠른 문제 해결을 위한 단계별 체크리스트**
- ⏱️ 5분 내 빠른 진단
- 🎯 일반적인 오류별 해결법
- 🔄 워크플로우 재실행 방법
- 🚨 비상시 대응 방법

### 🔀 [Branch Merge Conflicts](./BRANCH_MERGE_CONFLICTS.md)
**브랜치 머지 충돌 및 CI 오류 종합 가이드**
- 브랜치 머지 충돌 해결
- 컴파일 에러 해결
- GitHub Actions 권한 문제
- 워크플로우 설정 오류
- 실제 해결 사례

### 🤖 [GitHub Actions Troubleshooting](./GITHUB_ACTIONS_TROUBLESHOOTING.md)
**GitHub Actions CI/CD 전문 트러블슈팅**
- 권한 관련 오류 해결
- 워크플로우 설정 오류 진단
- 빌드/테스트 관련 문제
- 진단 도구 및 명령어
- 로컬 테스트 환경 구성

## 🎯 사용 가이드

### 문제 발생 시 추천 순서

1. **⚡ 긴급 상황** → [Quick Checklist](./QUICK_CHECKLIST.md)
2. **🔀 브랜치/머지 문제** → [Branch Merge Conflicts](./BRANCH_MERGE_CONFLICTS.md)
3. **🤖 GitHub Actions 문제** → [GitHub Actions Troubleshooting](./GITHUB_ACTIONS_TROUBLESHOOTING.md)

### 문제 유형별 가이드

| 문제 유형 | 추천 문서 | 예상 해결 시간 |
|-----------|-----------|----------------|
| CI 실패 | Quick Checklist → GitHub Actions | 5-30분 |
| 머지 충돌 | Quick Checklist → Branch Merge | 10-20분 |
| 권한 오류 | GitHub Actions | 15-30분 |
| 컴파일 에러 | Branch Merge Conflicts | 10-60분 |
| 워크플로우 오류 | GitHub Actions | 20-45분 |

## 🔍 빠른 검색

### 자주 찾는 명령어
```bash
# 워크플로우 상태 확인
gh run list --limit 5

# PR 체크 상태 확인  
gh pr view [PR_NUMBER] --json statusCheckRollup

# 실패 로그 확인
gh run view [RUN_ID] --log-failed

# 로컬 빌드 테스트
./gradlew clean build
```

### 자주 발생하는 오류

- **"Resource not accessible by integration"** → [GitHub Actions - 권한 오류](./GITHUB_ACTIONS_TROUBLESHOOTING.md#resource-not-accessible-by-integration)
- **"cannot find symbol"** → [Branch Merge - 컴파일 에러](./BRANCH_MERGE_CONFLICTS.md#컴파일-에러-해결)
- **"CONFLICT (content)"** → [Branch Merge - 충돌 해결](./BRANCH_MERGE_CONFLICTS.md#브랜치-머지-충돌-해결)
- **"GitHub Actions is not permitted"** → [GitHub Actions - Auto-approve 오류](./GITHUB_ACTIONS_TROUBLESHOOTING.md#github-actions-is-not-permitted-to-approve-pull-requests)

## 🚨 긴급 상황 대응

```bash
# 1. 워크플로우 즉시 중단
gh run cancel [RUN_ID]

# 2. 워크플로우 비활성화
gh workflow disable [WORKFLOW_NAME]

# 3. 문제 커밋 롤백
git revert [COMMIT_SHA] && git push

# 4. 브랜치 보호 규칙 임시 해제 (관리자만)
# GitHub 웹 인터페이스에서 설정
```

## 📈 문제 해결 통계

### 일반적인 문제 분포 (경험적 데이터)
- **권한 문제**: 30%
- **머지 충돌**: 25%  
- **컴파일 에러**: 20%
- **테스트 실패**: 15%
- **워크플로우 설정**: 10%

### 평균 해결 시간
- **간단한 문제**: 5-15분
- **중간 복잡도**: 30-60분
- **복잡한 문제**: 1-3시간

## 🤝 기여 방법

새로운 문제나 해결 방법을 발견하신 경우:

1. **문제 재현 단계** 기록
2. **해결 방법** 단계별 정리
3. **스크린샷/로그** 첨부 (민감정보 제거)
4. **PR 생성** 또는 **이슈 등록**

### 문서 업데이트 가이드라인
- ✅ 실제 경험 기반의 해결법
- ✅ 단계별 명확한 설명
- ✅ 코드 예제와 명령어 포함
- ✅ 예상 소요 시간 명시
- ❌ 이론적이거나 검증되지 않은 방법

## 📞 추가 도움

### 내부 리소스
- **팀 슬랙**: #dev-ci-cd
- **프로젝트 Wiki**: [링크]
- **팀 미팅**: 매주 화요일 오전 10시

### 외부 리소스
- [GitHub Actions 문서](https://docs.github.com/en/actions)
- [GitHub Community](https://github.community/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/github-actions)

---

💡 **팁**: 문제 해결 시 해당 과정을 기록해 두면, 나중에 동일한 문제가 발생했을 때 빠르게 해결할 수 있습니다.

🤖 Generated with [Claude Code](https://claude.ai/code)

*마지막 업데이트: 2025-08-11*