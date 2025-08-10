#!/bin/bash
# PR 관리 스크립트 - GitHub CLI 기반

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# GitHub CLI 설치 확인
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI가 설치되지 않았습니다.${NC}"
        echo "설치 방법:"
        echo "  macOS: brew install gh"
        echo "  Ubuntu: apt install gh"
        echo "  또는: https://cli.github.com/"
        exit 1
    fi
}

# GitHub 로그인 상태 확인
check_auth() {
    if ! gh auth status &> /dev/null; then
        echo -e "${YELLOW}⚠️  GitHub에 로그인되지 않았습니다.${NC}"
        echo "로그인하시겠습니까? (y/n)"
        read -r response
        if [[ $response =~ ^[Yy]$ ]]; then
            gh auth login
        else
            exit 1
        fi
    fi
}

# PR 리스트 보기
list_prs() {
    echo -e "${BLUE}📋 Pull Request 목록${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    case $1 in
        "all")
            echo -e "${GREEN}📊 모든 PR:${NC}"
            gh pr list --limit 20
            ;;
        "open")
            echo -e "${GREEN}🔓 열린 PR:${NC}"
            gh pr list --state open --limit 20
            ;;
        "closed")
            echo -e "${GREEN}🔒 닫힌 PR:${NC}"
            gh pr list --state closed --limit 10
            ;;
        "mine")
            echo -e "${GREEN}👤 내 PR:${NC}"
            gh pr list --author "@me" --limit 20
            ;;
        "assigned")
            echo -e "${GREEN}📌 나에게 할당된 PR:${NC}"
            gh pr list --assignee "@me" --limit 20
            ;;
        *)
            echo -e "${GREEN}🔓 열린 PR (기본):${NC}"
            gh pr list --state open --limit 20
            ;;
    esac
}

# PR 상세 정보
show_pr() {
    if [ -z "$1" ]; then
        echo -e "${RED}❌ PR 번호를 입력해주세요.${NC}"
        echo "사용법: $0 show <PR번호>"
        exit 1
    fi
    
    echo -e "${BLUE}🔍 PR #$1 상세 정보${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    gh pr view "$1"
    
    echo -e "\n${YELLOW}🔄 체크 상태:${NC}"
    gh pr checks "$1" 2>/dev/null || echo "체크 정보 없음"
}

# PR 생성
create_pr() {
    echo -e "${BLUE}📝 새 PR 생성${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    current_branch=$(git branch --show-current)
    if [ "$current_branch" = "main" ] || [ "$current_branch" = "develop" ]; then
        echo -e "${RED}❌ main 또는 develop 브랜치에서는 PR을 생성할 수 없습니다.${NC}"
        echo "feature 브랜치를 먼저 생성하세요."
        exit 1
    fi
    
    echo "현재 브랜치: $current_branch"
    echo "PR 제목을 입력하세요 (Conventional Commits 형식 권장):"
    read -r title
    
    echo "PR 설명을 입력하세요 (엔터 두 번으로 종료):"
    description=""
    while IFS= read -r line; do
        [ -z "$line" ] && break
        description="$description$line\n"
    done
    
    gh pr create --title "$title" --body "$description"
}

# PR 상태 체크
check_status() {
    echo -e "${BLUE}📊 PR 상태 요약${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    gh pr status
}

# 브랜치별 PR 체크
check_branch_pr() {
    current_branch=$(git branch --show-current)
    echo -e "${BLUE}🌿 현재 브랜치 ($current_branch) PR 확인${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    pr_number=$(gh pr list --head "$current_branch" --json number --jq '.[0].number' 2>/dev/null)
    
    if [ "$pr_number" != "null" ] && [ -n "$pr_number" ]; then
        echo -e "${GREEN}✅ 이 브랜치의 PR이 있습니다: #$pr_number${NC}"
        gh pr view "$pr_number"
    else
        echo -e "${YELLOW}⚠️  이 브랜치에 대한 PR이 없습니다.${NC}"
        echo "PR을 생성하시겠습니까? (y/n)"
        read -r response
        if [[ $response =~ ^[Yy]$ ]]; then
            create_pr
        fi
    fi
}

# 도움말
show_help() {
    echo -e "${BLUE}🚀 PR 관리 도구${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "사용법: $0 <명령어> [옵션]"
    echo ""
    echo "명령어:"
    echo "  list [all|open|closed|mine|assigned]  - PR 목록 조회"
    echo "  show <PR번호>                        - PR 상세 정보"
    echo "  create                              - 새 PR 생성"
    echo "  status                              - PR 상태 요약"
    echo "  check                               - 현재 브랜치 PR 확인"
    echo "  help                                - 도움말"
    echo ""
    echo "예시:"
    echo "  $0 list open          # 열린 PR 목록"
    echo "  $0 show 123           # PR #123 상세 정보"
    echo "  $0 create             # 새 PR 생성"
    echo "  $0 check              # 현재 브랜치 PR 상태"
}

# 메인 함수
main() {
    check_gh_cli
    check_auth
    
    case "$1" in
        "list")
            list_prs "$2"
            ;;
        "show")
            show_pr "$2"
            ;;
        "create")
            create_pr
            ;;
        "status")
            check_status
            ;;
        "check")
            check_branch_pr
            ;;
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            echo -e "${RED}❌ 알 수 없는 명령어: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 스크립트 실행
main "$@"