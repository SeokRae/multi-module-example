# Git Flow 빠른 시작 가이드
**5분만에 Git Flow 적용하기**

## 🚀 빠른 설정

### 1. Git 기본 설정
```bash
# 커밋 메시지 템플릿 설정
git config --global commit.template .gitmessage

# Pull 시 rebase 설정
git config --global pull.rebase true

# 기본 에디터 설정 (선택사항)
git config --global core.editor "code --wait"
```

### 2. 브랜치 생성 및 작업
```bash
# 새로운 기능 개발 시작
git checkout develop
git pull origin develop
git checkout -b feature/phase2-product-api

# 작업 및 커밋
git add .
git commit  # 템플릿이 열립니다

# 정기적으로 develop과 동기화
git fetch origin
git rebase origin/develop

# PR 생성을 위한 push
git push origin feature/phase2-product-api
```

## 📝 커밋 메시지 빠른 가이드

### 자주 사용하는 패턴
```bash
# 새 기능 추가
git commit -m "feat(user): implement JWT authentication"

# 버그 수정
git commit -m "fix(product): resolve search pagination issue"

# 문서 수정
git commit -m "docs(api): update user endpoint documentation"

# 테스트 추가
git commit -m "test(order): add order creation integration tests"

# 리팩토링
git commit -m "refactor(common): extract validation utility functions"
```

### Phase별 개발 예시
```bash
# Phase 1: User Management
git commit -m "feat(user): implement User domain entity"
git commit -m "feat(auth): add JWT token provider"
git commit -m "feat(api): implement user CRUD endpoints"

# Phase 2: Product Management
git commit -m "feat(product): implement Product domain entity"
git commit -m "feat(api): implement product search with pagination"
git commit -m "feat(cache): add Redis caching for product queries"
```

## 🔄 일상 워크플로우

### 아침 작업 시작
```bash
# 1. 최신 develop 받기
git checkout develop
git pull origin develop

# 2. 작업 브랜치로 이동 (또는 새로 생성)
git checkout feature/my-feature
git rebase develop  # conflict 있으면 해결

# 3. 작업 시작
```

### 작업 중간 저장
```bash
# 작업 중간 저장 (WIP 커밋)
git add .
git commit -m "wip: working on user authentication logic"

# 나중에 정리할 때
git rebase -i HEAD~2  # 마지막 2개 커밋 정리
```

### 작업 완료 후
```bash
# 1. develop과 동기화
git fetch origin
git rebase origin/develop

# 2. 커밋 정리 (선택사항)
git rebase -i HEAD~3

# 3. Push 및 PR 생성
git push origin feature/my-feature
# GitHub에서 PR 생성
```

## 🏷️ 태그 및 릴리즈

### Phase 완료 시 태그
```bash
# Phase 1 완료
git tag -a v0.1.0 -m "Phase 1: User Management Complete"
git push origin v0.1.0

# Phase 2 완료  
git tag -a v0.2.0 -m "Phase 2: Product Management Complete"
git push origin v0.2.0

# 정식 릴리즈
git tag -a v1.0.0 -m "Release v1.0.0: E-Commerce Platform MVP"
git push origin v1.0.0
```

## 🆘 문제 해결

### Conflict 해결
```bash
# rebase 중 conflict 발생 시
git status                    # conflict 파일 확인
# 파일 수정 후
git add .
git rebase --continue

# merge conflict 발생 시
git status                    # conflict 파일 확인  
# 파일 수정 후
git add .
git commit
```

### 잘못된 커밋 수정
```bash
# 마지막 커밋 메시지 수정
git commit --amend

# 마지막 n개 커밋 수정
git rebase -i HEAD~n

# 특정 파일만 마지막 커밋에 추가
git add forgotten-file.java
git commit --amend --no-edit
```

### 브랜치 정리
```bash
# 로컬 브랜치 정리
git branch -d feature/completed-feature

# 원격 브랜치 정리
git push origin --delete feature/completed-feature

# 모든 원격 추적 브랜치 동기화
git remote prune origin
```

## ✅ 일일 체크리스트

### 개발 시작 전
- [ ] develop 브랜치 최신화
- [ ] 작업 브랜치 rebase
- [ ] 이슈 확인 및 할당

### 커밋 전
- [ ] 코드 자체 리뷰 완료
- [ ] 테스트 실행 (`./gradlew test`)
- [ ] 빌드 확인 (`./gradlew build`)
- [ ] Conventional Commits 형식 확인

### PR 생성 전
- [ ] develop과 동기화 완료
- [ ] Conflict 해결 완료
- [ ] PR 템플릿 작성 완료
- [ ] 관련 문서 업데이트

### PR 승인 후
- [ ] 브랜치 삭제
- [ ] 이슈 상태 업데이트
- [ ] 다음 작업 계획 수립

## 🔧 유용한 Git 명령어

### 정보 조회
```bash
# 브랜치 그래프 보기
git log --oneline --graph --all

# 특정 파일 변경 이력
git log --follow -- path/to/file

# 커밋간 차이 보기
git diff HEAD~1 HEAD

# 특정 작성자 커밋 보기
git log --author="홍길동"
```

### 브랜치 관리
```bash
# 원격 브랜치 목록
git branch -r

# 브랜치별 마지막 커밋
git branch -v

# 브랜치 rename
git branch -m old-name new-name
```

---

## 💡 팁 & 트릭

1. **작은 커밋을 자주**: 큰 기능도 작은 단위로 나누어 커밋
2. **의미있는 커밋 메시지**: 나중에 찾기 쉽도록 명확하게 작성
3. **정기적인 rebase**: develop과 자주 동기화하여 conflict 최소화
4. **PR은 작게**: 리뷰하기 쉽도록 변경사항을 최소화

이 가이드를 통해 팀 전체가 일관된 Git 워크플로우를 유지할 수 있습니다! 🚀