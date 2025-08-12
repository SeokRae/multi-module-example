# 🚀 CI/CD 문제 해결 Quick Checklist

## 📋 문제 발생 시 체크리스트

### 🔍 1단계: 상황 파악 (2분)

```bash
# 현재 상태 빠른 확인
□ gh run list --limit 5
□ gh pr view [PR_NUMBER]
□ git status
□ git log --oneline -5
```

**체크 포인트:**
- [ ] 어떤 워크플로우가 실패했는가?
- [ ] 마지막 성공한 커밋은 언제인가?
- [ ] 현재 브랜치 상태는?

### 🔧 2단계: 빠른 해결 시도 (5분)

#### CI 실패 시
```bash
# 로컬에서 빌드 테스트
□ ./gradlew clean build
□ ./gradlew test

# 의존성 문제 확인
□ ./gradlew dependencies --refresh-dependencies
```

#### 브랜치 충돌 시
```bash
# main과 동기화
□ git fetch origin
□ git merge origin/main
□ # 충돌 해결 후
□ git add . && git commit
```

#### 권한 오류 시
```yaml
# 워크플로우에 추가
permissions:
  contents: write
  pull-requests: write
  checks: write
```

### 🚨 3단계: 상세 진단 (10분)

```bash
# 실패 로그 확인
□ gh run view [RUN_ID] --log-failed

# PR 체크 상태 확인
□ gh pr view [PR_NUMBER] --json statusCheckRollup

# 최근 변경사항 확인
□ git diff HEAD~1
```

### ⚡ 4단계: 응급 조치

#### 긴급 워크플로우 비활성화
```bash
□ gh workflow disable [WORKFLOW_NAME]
```

#### 문제 커밋 롤백
```bash
□ git revert [COMMIT_SHA]
□ git push origin [BRANCH_NAME]
```

#### 우회 전략 적용
```yaml
# 워크플로우에서 문제 단계 건너뛰기
- name: Problematic step
  run: echo "Temporarily disabled"
  if: false
```

## 🎯 일반적인 오류별 빠른 해결법

### 컴파일 에러
```bash
1. □ git pull origin main
2. □ ./gradlew clean build
3. □ 누락된 의존성/메서드 추가
4. □ git push
```

### 권한 오류 (403)
```yaml
1. □ permissions 블록 추가
2. □ github-token: ${{ secrets.GITHUB_TOKEN }} 명시
3. □ Auto-approve → Direct merge로 변경
```

### 워크플로우 문법 오류
```bash
1. □ YAML 들여쓰기 확인
2. □ Job 이름 철자 확인
3. □ 존재하지 않는 job 참조 확인
```

### 테스트 실패
```bash
1. □ 로컬에서 테스트 실행
2. □ 테스트 데이터 초기화
3. □ CI 환경 변수 확인
```

## 🔄 워크플로우 재실행 방법

```bash
# 전체 워크플로우 재실행
□ gh run rerun [RUN_ID]

# 실패한 job만 재실행
□ gh run rerun [RUN_ID] --failed

# PR에서 새로운 빈 커밋으로 트리거
□ git commit --allow-empty -m "retrigger CI"
□ git push
```

## 📞 에스컬레이션 기준

다음 상황에서는 추가 도움 요청:

- [ ] 30분 이상 해결되지 않는 경우
- [ ] 여러 PR에서 동시에 같은 오류 발생
- [ ] 보안 관련 오류 (시크릿, 권한)
- [ ] 인프라 관련 오류 (GitHub 서비스 장애)

## 🛠️ 유용한 원라이너 명령어

```bash
# 최근 실패한 워크플로우 확인
gh run list --status failure --limit 3

# 현재 PR의 모든 체크 상태
gh pr checks $(gh pr view --json number -q .number)

# 브랜치의 최신 상태로 강제 동기화
git reset --hard origin/$(git branch --show-current)

# 워크플로우 실행 상태 실시간 모니터링
watch -n 5 'gh run list --limit 5'

# 마지막 성공한 커밋 찾기
git log --pretty=format:"%h %s" --grep="SUCCESS"
```

## 🚨 비상 연락처 / 리소스

- **GitHub Status**: https://www.githubstatus.com/
- **Actions 커뮤니티**: https://github.community/c/github-actions
- **프로젝트 Wiki**: [내부 링크]
- **팀 슬랙**: #dev-ci-cd

## 📈 사후 분석 체크리스트

문제 해결 후:
- [ ] 근본 원인 파악 및 문서화
- [ ] 재발 방지책 수립
- [ ] 모니터링/알림 개선
- [ ] 팀 지식 공유

---

⏱️ **목표 해결 시간**
- 간단한 문제: 5분 이내
- 복합적 문제: 30분 이내  
- 복잡한 문제: 2시간 이내

📍 **기억하세요**: 불확실할 때는 롤백하고 차근차근 다시 시작하는 것이 더 빠를 수 있습니다.

🤖 Generated with [Claude Code](https://claude.ai/code)