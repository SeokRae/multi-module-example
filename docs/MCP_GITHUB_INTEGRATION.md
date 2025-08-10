# MCP GitHub 통합 가이드
**Claude Code에서 GitHub CLI 기능 활용하기**

## 📋 현재 사용 가능한 MCP 서버들

### ✅ **이미 활성화된 MCP 서버**
1. **Git MCP Server** - Git 기본 작업
2. **Fetch MCP Server** - GitHub REST API 호출 (설정됨)

### 🔧 **MCP 설정 파일**
```json
// .claude/mcp.json
{
  "servers": {
    "git": {
      "command": "uv",
      "args": ["--directory", "./mcp-servers/src/git", "run", "mcp-server-git", "--repository", "."]
    },
    "fetch": {
      "command": "uv", 
      "args": ["--directory", "./mcp-servers/src/fetch", "run", "mcp-server-fetch"]
    }
  }
}
```

## 🚀 **GitHub 기능 활용 방법**

### 1. **Git MCP로 가능한 기능**
Claude Code가 이미 사용하고 있는 기능들:

```bash
# ✅ 현재 사용 중인 Git 기능
- git_status          # 작업 상태 확인
- git_log             # 커밋 히스토리
- git_branch          # 브랜치 관리
- git_add             # 파일 스테이징
- git_commit          # 커밋 생성 (Conventional Commits 형식)
- git_push            # 원격 저장소 푸시
- git_diff_*          # 변경사항 확인
- git_create_branch   # 브랜치 생성
- git_checkout        # 브랜치 전환
```

### 2. **Fetch MCP로 가능한 GitHub API 호출**
새로 설정된 Fetch MCP 서버로 가능한 기능들:

```bash
# 🔮 Fetch MCP로 호출 가능한 GitHub API
- PR 목록 조회: https://api.github.com/repos/SeokRae/multi-module-example/pulls
- PR 상세 정보: https://api.github.com/repos/SeokRae/multi-module-example/pulls/{number}
- 이슈 목록: https://api.github.com/repos/SeokRae/multi-module-example/issues  
- 저장소 정보: https://api.github.com/repos/SeokRae/multi-module-example
- 브랜치 정보: https://api.github.com/repos/SeokRae/multi-module-example/branches
- 커밋 정보: https://api.github.com/repos/SeokRae/multi-module-example/commits
- 릴리즈 정보: https://api.github.com/repos/SeokRae/multi-module-example/releases
```

### 3. **Claude Code에서 사용 예시**

#### **PR 관련 요청**
```
"GitHub에서 현재 열린 PR 목록을 보여줘"
→ Claude가 Fetch MCP로 GitHub API 호출

"PR #123의 상세 정보를 확인해줘"  
→ GitHub REST API에서 PR 정보 가져오기

"최근 머지된 PR들을 확인해줘"
→ state=closed&sort=updated로 API 호출
```

#### **이슈 관련 요청**
```
"현재 열린 이슈들을 보여줘"
→ Issues API 호출로 이슈 목록 가져오기

"라벨이 'bug'인 이슈들을 찾아줘"
→ 라벨 필터링된 이슈 검색
```

#### **저장소 통계**
```
"이 저장소의 스타 수와 포크 수를 알려줘"
→ Repository API로 통계 정보 확인

"최근 릴리즈 정보를 확인해줘"
→ Releases API 호출
```

## 🎯 **실제 사용 가능한 조합**

### **완벽한 Git + GitHub 워크플로우**

1. **개발 준비** (Git MCP)
   ```
   "Phase 2 개발을 위한 feature 브랜치를 만들어줘"
   → git_create_branch + git_checkout
   ```

2. **개발 중** (Git MCP)
   ```
   "현재 변경사항을 확인하고 커밋해줘"
   → git_status + git_diff_unstaged + git_add + git_commit
   ```

3. **PR 생성 후 확인** (Fetch MCP)
   ```
   "방금 생성한 PR의 CI 상태를 확인해줘"
   → GitHub API로 PR checks 상태 조회
   ```

4. **코드 리뷰** (Fetch MCP)
   ```
   "이 PR에 달린 리뷰 댓글들을 보여줘"
   → PR reviews API 호출
   ```

5. **머지 후 정리** (Git MCP)
   ```
   "PR이 머지됐으니까 브랜치 정리해줘"
   → git_checkout main + git_branch -d feature/...
   ```

## 🔧 **수동 대안 방법들**

### **1. GitHub CLI 설치 (권장)**
```bash
# macOS
brew install gh

# 기본 사용법
gh pr list              # PR 목록
gh pr view 123         # PR 상세보기  
gh pr create           # PR 생성
gh issue list          # 이슈 목록
```

### **2. 간단한 curl 명령어**
```bash
# PR 목록
curl -s "https://api.github.com/repos/SeokRae/multi-module-example/pulls?state=open"

# 저장소 정보  
curl -s "https://api.github.com/repos/SeokRae/multi-module-example"

# 특정 PR 정보
curl -s "https://api.github.com/repos/SeokRae/multi-module-example/pulls/1"
```

### **3. 웹 인터페이스**
```
직접 브라우저에서 접근:
- PR 목록: https://github.com/SeokRae/multi-module-example/pulls
- 이슈 목록: https://github.com/SeokRae/multi-module-example/issues  
- Actions: https://github.com/SeokRae/multi-module-example/actions
```

## 📊 **기능 비교표**

| 기능 | Git MCP | Fetch MCP | GitHub CLI | 웹 UI |
|------|---------|-----------|------------|-------|
| **Git 기본 작업** | ✅ 완벽 | ❌ | ✅ | ❌ |
| **PR 조회** | ❌ | ✅ API | ✅ 완벽 | ✅ 완벽 |
| **PR 생성** | ❌ | ⚠️ 복잡 | ✅ 간단 | ✅ 간단 |
| **이슈 관리** | ❌ | ✅ API | ✅ 완벽 | ✅ 완벽 |
| **코드 리뷰** | ❌ | ✅ 읽기전용 | ✅ 완벽 | ✅ 완벽 |
| **Claude 통합** | ✅ 완벽 | ✅ 완벽 | ❌ 수동 | ❌ 수동 |

## 🎯 **권장 워크플로우**

### **Phase 2 개발 시나리오**
```bash
# 1. Claude Code MCP 활용
"Phase 2 Product API 개발을 시작할게. 브랜치 만들고 기본 구조 설정해줘"
→ Git MCP로 브랜치 생성, 파일 구조 생성

# 2. 개발 진행
"Product 도메인 엔티티를 구현하고 테스트도 만들어줘"
→ 코드 생성, Git MCP로 커밋

# 3. PR 생성 (GitHub CLI 추천)
gh pr create --title "feat(product): implement Product domain and API"

# 4. PR 상태 확인 (Claude + Fetch MCP)
"방금 생성한 PR의 CI 상태와 리뷰 상황을 확인해줘"
→ Fetch MCP로 GitHub API 호출

# 5. 머지 후 정리 (Git MCP)
"PR이 머지됐으니까 main 브랜치로 전환하고 정리해줘"
```

## 💡 **팁 & 트릭**

1. **MCP 재시작**: `.claude/mcp.json` 변경 후 Claude Code 재시작 필요
2. **API 제한**: GitHub API는 시간당 60회 제한 (인증시 5000회)
3. **토큰 설정**: 개인 토큰 설정시 더 많은 기능 사용 가능
4. **조합 활용**: Git MCP + Fetch MCP + GitHub CLI 조합이 최적

---

**결론**: 현재 **Git MCP + Fetch MCP** 조합으로 대부분의 GitHub 기능을 Claude Code에서 직접 사용할 수 있습니다! 🚀

추가로 **GitHub CLI**를 설치하면 완벽한 GitHub 워크플로우가 완성됩니다.