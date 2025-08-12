# 🚀 Git 머지 Quick Guide

> Redis 캐싱 머지 이슈 경험을 바탕으로 작성된 빠른 참조 가이드

## ⚡ 긴급 상황별 해결법

### 🆘 Push 타임아웃 시
```bash
# 1. 네트워크 확인
ping github.com

# 2. 강제 푸시 (주의!)
git push --force-with-lease origin main

# 3. 작은 단위로 푸시
git push origin HEAD~10:main
git push origin main
```

### 🔀 브랜치 분기 시
```bash
# 1. 현재 상태 확인
git status
git log --oneline -5
git fetch origin

# 2. 리베이스 (권장)
git rebase origin/main

# 3. 충돌 시 해결 후
git add .
git rebase --continue

# 4. 리베이스 실패 시 머지
git rebase --abort
git merge origin/main
```

### 💥 머지 충돌 시
```bash
# 1. 충돌 파일 확인
git status

# 2. 수동 해결 후
git add [충돌파일]
git commit

# 3. 충돌 도구 사용
git mergetool
```

### 🚫 PR 생성 실패 시
```bash
# 1. 브랜치 푸시 확인
git push origin [브랜치명]

# 2. GitHub CLI 재인증
gh auth logout
gh auth login

# 3. 웹에서 직접 PR 생성
echo "https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]//' | sed 's/.git$//')/compare/main...$(git branch --show-current)"
```

## 🔧 사전 점검 체크리스트

### 머지 전 필수 점검
- [ ] `git fetch origin` 실행
- [ ] 로컬 변경사항 커밋 완료
- [ ] 브랜치 동기화 상태 확인
- [ ] 빌드 테스트 통과: `./gradlew clean build`
- [ ] 대용량 파일 없음 (>50MB)

### 안전한 머지를 위한 명령어
```bash
# 🔍 안전 점검 스크립트 실행
./scripts/git-merge-safety-check.sh

# 📋 상태 종합 확인
git status
git log --oneline -3
git remote -v

# 🧪 충돌 시뮬레이션
git merge-tree $(git merge-base HEAD main) HEAD main
```

## 🛠️ 자주 사용하는 복구 명령어

### 작업 백업
```bash
# 현재 상태 태그로 백업
git tag backup-$(date +%Y%m%d-%H%M%S)

# 스태시로 임시 보관
git stash push -m "작업 중인 내용 백업"
```

### 되돌리기
```bash
# 마지막 커밋 취소 (변경사항 유지)
git reset --soft HEAD~1

# 머지 취소
git merge --abort
git rebase --abort

# 강제 리셋 (위험!)
git reset --hard origin/main
```

### 충돌 해결
```bash
# 충돌 상태에서 우리 것 선택
git checkout --ours [파일명]

# 충돌 상태에서 그들 것 선택  
git checkout --theirs [파일명]

# 모든 충돌을 우리 것으로
git merge -X ours origin/main
```

## 🎯 Best Practices

### 1. 브랜치 전략
```bash
# 피처 브랜치 생성
git checkout -b feature/short-name

# 정기적 동기화 (매일)
git fetch origin
git rebase origin/main

# 짧은 생명주기 유지 (<48시간)
```

### 2. 커밋 전략
```bash
# 의미 있는 커밋 메시지
git commit -m "feat: add Redis caching to ProductService

- Add @Cacheable annotations to findById, findBySku
- Configure TTL: 1 hour for products
- Improve query performance by 50%"

# 작은 단위 커밋
git add -p  # 선택적 스테이징
```

### 3. 푸시 전략
```bash
# 안전한 푸시
git push --force-with-lease origin feature-branch

# 정기적 푸시 (하루 1회 이상)
git push origin feature-branch
```

## 🚨 Emergency Contacts

### 즉시 도움이 필요한 경우
1. **Slack #dev-emergency**: 실시간 도움
2. **GitHub Issues**: 버그 리포트
3. **Wiki**: 상세 가이드
4. **Code Review**: 동료 검토

### 복구 불가 상황
```bash
# 백업에서 복구
git reset --hard backup-20250812-143000

# 새로운 클론
git clone https://github.com/user/repo.git
cd repo
git checkout [브랜치명]
```

## 📊 트러블슈팅 히스토리

| 날짜 | 이슈 | 해결법 | 시간 |
|------|------|--------|------|
| 2025-08-12 | Push 타임아웃 | 강제 푸시 | 15분 |
| 2025-08-12 | 브랜치 분기 | 리베이스 후 푸시 | 10분 |
| 2025-08-12 | 워크플로우 충돌 | 수동 해결 | 5분 |

## 🔗 관련 문서

- [Git 머지 이슈 상세 리포트](./GIT_MERGE_ISSUES_REPORT.md)
- [브랜치 병합 충돌 가이드](./BRANCH_MERGE_CONFLICTS.md)
- [GitHub Actions 문제해결](./GITHUB_ACTIONS_TROUBLESHOOTING.md)

---

**💡 TIP**: 이 가이드를 즐겨찾기에 추가하고, 머지 전에 항상 체크하세요!

🤖 Generated with [Claude Code](https://claude.ai/code)