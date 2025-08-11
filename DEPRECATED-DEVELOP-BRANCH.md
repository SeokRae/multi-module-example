# ⚠️ DEPRECATED: develop 브랜치

## 🚨 중요 공지

**이 브랜치는 더 이상 사용되지 않습니다.**

### 📅 변경 일시
- **마이그레이션 일시**: 2025-08-11
- **백업 태그**: `backup-before-github-flow-20250811-093246`

### 🔄 새로운 워크플로우: GitHub Flow

이 프로젝트는 **Git Flow에서 GitHub Flow로 마이그레이션**되었습니다.

#### 변경 사항:
- ❌ **develop 브랜치**: 더 이상 사용하지 않음
- ✅ **main 브랜치**: 모든 개발의 기준점
- ✅ **feature 브랜치**: main에서 분기하여 main으로 병합

### 🚀 새로운 개발 프로세스

#### Before (Git Flow):
```bash
git checkout develop
git pull origin develop
git checkout -b feature/new-feature
# ... 개발 ...
git checkout develop
git merge --no-ff feature/new-feature
```

#### After (GitHub Flow):
```bash
git checkout main
git pull origin main
git checkout -b feature/new-feature
# ... 개발 ...
# Pull Request 생성 후 웹에서 병합
```

### 📚 관련 문서

- **워크플로우 가이드**: `docs/development-phases/phase-0-project-setup/git-workflow-strategy/`
- **GitHub Flow 사용법**: `github-flow-workflow-guide.md`
- **마이그레이션 가이드**: `github-flow-migration-guide.md`

### 🔧 헬퍼 도구 사용

```bash
# 헬퍼 함수 로드
source docs/development-phases/phase-0-project-setup/git-workflow-strategy/scripts/github-flow-helpers.sh

# 새 기능 시작
gf_start feature-name

# Pull Request 생성
gf_pr "Feature title" "Feature description"

# 브랜치 정리
gf_cleanup
```

---

**앞으로 모든 개발은 main 브랜치를 기준으로 진행해주세요!** 🚀