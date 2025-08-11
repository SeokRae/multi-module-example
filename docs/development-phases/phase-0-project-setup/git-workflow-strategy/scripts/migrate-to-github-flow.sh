#!/bin/bash

# GitHub Flow 마이그레이션 스크립트
# 사용법: ./scripts/migrate-to-github-flow.sh

set -e  # 오류 발생 시 스크립트 중단

echo "🚀 Git Flow에서 GitHub Flow로 마이그레이션 시작"
echo "================================================"

# 색상 코드 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수 정의
print_step() {
    echo -e "${BLUE}📋 Step $1: $2${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

confirm_action() {
    echo -e "${YELLOW}$1${NC}"
    read -p "계속하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "사용자가 취소했습니다."
        exit 1
    fi
}

# Phase 0: 사전 확인
print_step "0" "사전 확인 및 백업"

# Git 저장소 확인
if [ ! -d ".git" ]; then
    print_error "Git 저장소가 아닙니다. Git 저장소에서 실행해주세요."
    exit 1
fi

# 현재 브랜치 확인
current_branch=$(git branch --show-current)
echo "현재 브랜치: $current_branch"

# 미완료 변경사항 확인
if [[ -n $(git status --porcelain) ]]; then
    print_warning "미완료 변경사항이 있습니다."
    git status --short
    confirm_action "변경사항을 stash하거나 커밋한 후 다시 실행하는 것을 권장합니다."
fi

# 백업 태그 생성
backup_tag="backup-before-github-flow-$(date +%Y%m%d-%H%M%S)"
git tag "$backup_tag"
print_success "백업 태그 생성: $backup_tag"

# Phase 1: 현재 상태 분석
print_step "1" "현재 브랜치 구조 분석"

echo "로컬 브랜치:"
git branch

echo "원격 브랜치:"
git branch -r

# develop 브랜치 존재 확인
if git show-ref --verify --quiet refs/heads/develop; then
    develop_exists=true
    print_success "develop 브랜치가 존재합니다."
else
    develop_exists=false
    print_warning "develop 브랜치가 없습니다. Git Flow 구조가 아닐 수 있습니다."
fi

# feature 브랜치들 확인
feature_branches=$(git branch --list "feature/*" | sed 's/^..//')
if [[ -n "$feature_branches" ]]; then
    echo "진행 중인 feature 브랜치들:"
    echo "$feature_branches"
else
    print_success "진행 중인 feature 브랜치가 없습니다."
fi

# Phase 2: develop → main 동기화
if [ "$develop_exists" = true ]; then
    print_step "2" "develop 브랜치를 main에 병합"
    
    confirm_action "develop 브랜치의 모든 변경사항을 main에 병합합니다."
    
    # main 브랜치로 전환하고 최신 상태로 업데이트
    git checkout main
    git pull origin main
    
    # develop 브랜치 병합
    echo "develop 브랜치 병합 중..."
    if git merge origin/develop --no-ff -m "chore: merge develop branch for GitHub Flow migration"; then
        print_success "develop → main 병합 완료"
        git push origin main
    else
        print_error "병합 중 충돌이 발생했습니다. 수동으로 해결한 후 다시 실행해주세요."
        exit 1
    fi
else
    print_step "2" "develop 브랜치가 없으므로 건너뜀"
fi

# Phase 3: feature 브랜치들을 main 기준으로 rebase
if [[ -n "$feature_branches" ]]; then
    print_step "3" "feature 브랜치들을 main 기준으로 rebase"
    
    confirm_action "진행 중인 feature 브랜치들을 main 기준으로 rebase합니다."
    
    echo "$feature_branches" | while IFS= read -r branch; do
        if [[ -n "$branch" ]]; then
            echo "브랜치 '$branch'를 rebase 중..."
            git checkout "$branch"
            
            if git rebase main; then
                print_success "브랜치 '$branch' rebase 완료"
                # 원격 브랜치가 있다면 force push (주의 필요)
                if git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
                    print_warning "원격 브랜치 '$branch'에 force push합니다."
                    git push --force-with-lease origin "$branch"
                fi
            else
                print_error "브랜치 '$branch' rebase 중 충돌 발생. 수동으로 해결해주세요."
                echo "해결 후 다음 명령어를 실행하세요:"
                echo "  git add ."
                echo "  git rebase --continue"
                echo "  git push --force-with-lease origin $branch"
                exit 1
            fi
        fi
    done
    
    # main 브랜치로 돌아가기
    git checkout main
else
    print_step "3" "진행 중인 feature 브랜치가 없으므로 건너뜀"
fi

# Phase 4: GitHub Flow 도구 설치 및 설정
print_step "4" "GitHub Flow 도구 및 스크립트 설정"

# GitHub CLI 설치 확인
if ! command -v gh &> /dev/null; then
    print_warning "GitHub CLI(gh)가 설치되어 있지 않습니다."
    echo "설치 방법: brew install gh"
    echo "또는 https://cli.github.com/ 에서 설치하세요."
else
    print_success "GitHub CLI가 설치되어 있습니다."
fi

# GitHub Flow 헬퍼 스크립트들 생성
mkdir -p scripts

# 기능 시작 스크립트
cat > scripts/github-flow-start.sh << 'EOF'
#!/bin/bash
# GitHub Flow 기능 개발 시작 스크립트

feature_name=$1
if [ -z "$feature_name" ]; then
    echo "사용법: $0 <feature-name>"
    echo "예시: $0 user-authentication"
    exit 1
fi

echo "🚀 GitHub Flow 기능 개발 시작: $feature_name"

# main 브랜치에서 최신 상태로 시작
git checkout main
git pull origin main
git checkout -b "feature/$feature_name"

echo "✅ 브랜치 'feature/$feature_name' 생성 완료"
echo "📝 개발 완료 후 다음 명령어로 PR을 생성하세요:"
echo "   gh pr create --title 'Add $feature_name' --body 'Description of changes'"
EOF

# 브랜치 정리 스크립트
cat > scripts/cleanup-branches.sh << 'EOF'
#!/bin/bash
# 병합 완료된 브랜치들 정리 스크립트

echo "🧹 병합 완료된 브랜치들을 정리합니다..."

# 현재 main 브랜치로 전환
git checkout main
git pull origin main

# 로컬 브랜치 중 main에 병합된 것들 삭제
merged_branches=$(git branch --merged main | grep -v "main" | grep -v "*")
if [[ -n "$merged_branches" ]]; then
    echo "삭제할 로컬 브랜치들:"
    echo "$merged_branches"
    echo "$merged_branches" | xargs -n 1 git branch -d
    echo "✅ 로컬 브랜치 정리 완료"
else
    echo "삭제할 로컬 브랜치가 없습니다."
fi

# 원격 브랜치 중 삭제된 것들의 로컬 참조 정리
git remote prune origin
echo "✅ 원격 브랜치 참조 정리 완료"
EOF

chmod +x scripts/github-flow-start.sh
chmod +x scripts/cleanup-branches.sh

print_success "GitHub Flow 헬퍼 스크립트 생성 완료"

# Phase 5: Pull Request 템플릿 생성
print_step "5" "Pull Request 템플릿 생성"

mkdir -p .github

cat > .github/pull_request_template.md << 'EOF'
## 변경 내용
- [ ] 새로운 기능
- [ ] 버그 수정
- [ ] 문서 업데이트
- [ ] 리팩토링
- [ ] 테스트 추가

## 설명
<!-- 변경 사항에 대한 상세한 설명을 작성해주세요 -->

## 테스트
- [ ] 단위 테스트 통과
- [ ] 통합 테스트 통과
- [ ] 수동 테스트 완료

## 스크린샷 (해당되는 경우)
<!-- UI 변경사항이 있다면 스크린샷을 첨부해주세요 -->

## 체크리스트
- [ ] 코드 리뷰 요청 완료
- [ ] 관련 문서 업데이트
- [ ] 변경 로그 업데이트 (필요한 경우)
- [ ] 브랜치명이 규칙에 맞음 (feature/, bugfix/, docs/ 등)
EOF

print_success "Pull Request 템플릿 생성 완료"

# Phase 6: CI/CD 워크플로우 업데이트
print_step "6" "GitHub Actions 워크플로우 업데이트"

if [ -d ".github/workflows" ]; then
    echo "기존 워크플로우 파일들을 GitHub Flow에 맞게 업데이트합니다..."
    
    # 기존 워크플로우 파일들 백업
    backup_dir=".github/workflows.backup-$(date +%Y%m%d-%H%M%S)"
    cp -r .github/workflows "$backup_dir"
    print_success "기존 워크플로우 백업: $backup_dir"
    
    # GitHub Flow용 워크플로우 생성
    cat > .github/workflows/github-flow.yml << 'EOF'
name: GitHub Flow CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          
      - name: Cache Gradle dependencies
        uses: actions/cache@v4
        with:
          path: ~/.gradle/caches
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*') }}
          
      - name: Run tests
        run: ./gradlew test
        
      - name: Run build
        run: ./gradlew build

  deploy:
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Deploy to production
        run: |
          echo "🚀 Deploying to production..."
          # 실제 배포 스크립트를 여기에 추가하세요
          echo "✅ Deployment completed"
EOF
    
    print_success "GitHub Flow CI/CD 워크플로우 생성 완료"
else
    print_warning ".github/workflows 디렉토리가 없습니다. 필요시 나중에 생성하세요."
fi

# Phase 7: develop 브랜치 제거 (옵션)
if [ "$develop_exists" = true ]; then
    print_step "7" "develop 브랜치 제거 (선택사항)"
    
    echo "develop 브랜치를 제거하면 완전히 GitHub Flow로 전환됩니다."
    echo "팀이 새로운 워크플로우에 적응한 후 제거하는 것을 권장합니다."
    
    read -p "지금 develop 브랜치를 제거하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # develop 브랜치에 deprecated 메시지 추가
        git checkout develop
        echo "⚠️ 이 브랜치는 더 이상 사용되지 않습니다. main 브랜치를 사용하세요." > DEPRECATED.md
        git add DEPRECATED.md
        git commit -m "docs: mark develop branch as deprecated"
        git push origin develop
        
        git checkout main
        
        print_warning "develop 브랜치에 deprecated 메시지를 추가했습니다."
        print_warning "충분한 확인 후 다음 명령어로 제거할 수 있습니다:"
        echo "  git push origin --delete develop"
        echo "  git branch -d develop"
    else
        print_success "develop 브랜치를 유지합니다. 나중에 제거할 수 있습니다."
    fi
else
    print_step "7" "develop 브랜치가 없으므로 건너뜀"
fi

# Phase 8: 최종 확인 및 안내
print_step "8" "마이그레이션 완료 및 안내"

echo ""
echo "🎉 GitHub Flow 마이그레이션이 완료되었습니다!"
echo "================================================"
echo ""
echo "📋 다음 단계:"
echo "1. 팀원들에게 새로운 워크플로우 안내"
echo "2. 첫 번째 기능을 GitHub Flow로 개발해보기"
echo "3. CI/CD 파이프라인이 정상 작동하는지 확인"
echo ""
echo "🛠️  새로운 개발 프로세스:"
echo "   # 새 기능 시작"
echo "   ./scripts/github-flow-start.sh feature-name"
echo ""
echo "   # 개발 완료 후 PR 생성"
echo "   gh pr create --title 'Add feature' --body 'Description'"
echo ""
echo "   # 브랜치 정리"
echo "   ./scripts/cleanup-branches.sh"
echo ""
echo "📚 도움말:"
echo "   - 마이그레이션 가이드: docs/github-flow-migration-guide.md"
echo "   - 백업 태그: $backup_tag"
echo "   - 문제 발생시 롤백: git reset --hard $backup_tag"
echo ""
echo "✅ GitHub Flow를 사용한 즐거운 개발 되세요!"
EOF