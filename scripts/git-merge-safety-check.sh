#!/bin/bash

# 🔍 Git Merge Safety Check Script
# Redis 캐싱 머지 이슈 경험을 바탕으로 작성된 사전 점검 스크립트

set -e

echo "🔍 Git Merge Safety Check 시작..."

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수 정의
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 1. 현재 브랜치 확인
current_branch=$(git rev-parse --abbrev-ref HEAD)
print_info "현재 브랜치: $current_branch"

# 2. 리모트 상태 업데이트
echo ""
print_info "리모트 상태 업데이트 중..."
git fetch origin

# 3. 브랜치 분기 상태 확인
ahead=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo "0")
behind=$(git rev-list --count origin/main..HEAD 2>/dev/null || echo "0")

echo ""
print_info "브랜치 동기화 상태:"
echo "  - 로컬이 리모트보다 $behind 커밋 앞서감"
echo "  - 리모트가 로컬보다 $ahead 커밋 앞서감"

if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
    print_warning "브랜치가 분기되었습니다! 머지 충돌 가능성 높음"
    echo "  해결 방법: git rebase origin/main 또는 git pull --rebase"
elif [ "$ahead" -gt 5 ]; then
    print_warning "리모트가 많이 앞서있습니다 (${ahead} 커밋)"
    echo "  해결 방법: git pull 또는 git rebase origin/main"
elif [ "$behind" -gt 10 ]; then
    print_warning "로컬이 많이 앞서있습니다 (${behind} 커밋)"
    echo "  해결 방법: 피처 브랜치를 더 자주 푸시하세요"
else
    print_success "브랜치 동기화 상태 양호"
fi

# 4. 워킹 디렉토리 상태 확인
echo ""
if [ -n "$(git status --porcelain)" ]; then
    print_warning "커밋되지 않은 변경사항이 있습니다"
    git status --short
    echo "  해결 방법: git add . && git commit 또는 git stash"
else
    print_success "워킹 디렉토리 정리됨"
fi

# 5. 대용량 파일 확인
echo ""
print_info "대용량 파일 검사 중..."
large_files=$(find . -name .git -prune -o -type f -size +50M -print 2>/dev/null || true)
if [ -n "$large_files" ]; then
    print_warning "50MB 이상 대용량 파일 발견:"
    echo "$large_files"
    echo "  해결 방법: Git LFS 사용 권장 (git lfs track '*.jar')"
else
    print_success "대용량 파일 없음"
fi

# 6. 충돌 가능성 사전 검사
echo ""
if [ "$current_branch" != "main" ]; then
    print_info "머지 시뮬레이션 중..."
    
    # 임시로 merge-base 확인
    merge_base=$(git merge-base HEAD origin/main)
    conflicts=$(git merge-tree "$merge_base" HEAD origin/main | grep -c "<<<<<<< " || echo "0")
    
    if [ "$conflicts" -gt 0 ]; then
        print_warning "예상 충돌 수: $conflicts"
        echo "  충돌 가능 파일들을 미리 확인하고 해결 계획을 세우세요"
        
        # 충돌 파일 목록 표시
        print_info "충돌 예상 파일들:"
        git merge-tree "$merge_base" HEAD origin/main | grep "Auto-merging" | sed 's/Auto-merging /  - /' || true
    else
        print_success "충돌 예상되지 않음"
    fi
fi

# 7. GitHub CLI 상태 확인
echo ""
if command -v gh &> /dev/null; then
    auth_status=$(gh auth status 2>&1 || echo "not authenticated")
    if echo "$auth_status" | grep -q "Logged in"; then
        print_success "GitHub CLI 인증 완료"
    else
        print_warning "GitHub CLI 인증 필요"
        echo "  해결 방법: gh auth login"
    fi
else
    print_warning "GitHub CLI가 설치되지 않음"
    echo "  설치 방법: brew install gh"
fi

# 8. 네트워크 연결 확인
echo ""
print_info "GitHub 연결 상태 확인 중..."
if ping -c 1 github.com &> /dev/null; then
    print_success "GitHub 연결 정상"
else
    print_error "GitHub 연결 실패"
    echo "  네트워크 상태를 확인하세요"
fi

# 9. 권장 사항
echo ""
echo "🚀 머지 전 권장 사항:"
echo "  1. 중요한 변경사항은 백업: git tag backup-$(date +%Y%m%d-%H%M%S)"
echo "  2. 테스트 실행: ./gradlew clean build"
echo "  3. 짧은 피처 브랜치 유지 (< 48시간)"
echo "  4. 정기적인 리모트 동기화 (매일)"

# 10. 최종 안전도 점수 계산
score=100
[ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ] && score=$((score - 30))
[ "$ahead" -gt 5 ] && score=$((score - 20))
[ -n "$(git status --porcelain)" ] && score=$((score - 15))
[ -n "$large_files" ] && score=$((score - 10))
[ "$conflicts" -gt 0 ] && score=$((score - 25))

echo ""
echo "📊 머지 안전도 점수: ${score}/100"
if [ "$score" -ge 80 ]; then
    print_success "머지 진행 권장 ✅"
elif [ "$score" -ge 60 ]; then
    print_warning "주의하여 머지 진행 ⚠️"
else
    print_error "머지 전 이슈 해결 필요 ❌"
fi

echo ""
echo "🔍 Git Merge Safety Check 완료!"
echo "📝 상세 가이드: docs/troubleshooting/GIT_MERGE_ISSUES_REPORT.md"