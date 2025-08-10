#!/bin/bash
# 문서 관리 자동화 스크립트

set -e

DOCS_DIR="docs"
SCRIPTS_DIR="scripts"
ROOT_DIR="."

echo "📚 Multi-Module Project 문서 관리 도구"
echo "========================================"

# 함수: 문서 통계 생성
generate_docs_stats() {
    echo "📊 문서 통계 생성 중..."
    
    total_docs=$(find $DOCS_DIR -name "*.md" | wc -l | tr -d ' ')
    total_lines=$(find $DOCS_DIR -name "*.md" -exec wc -l {} + | tail -n 1 | awk '{print $1}')
    total_chars=$(find $DOCS_DIR -name "*.md" -exec wc -c {} + | tail -n 1 | awk '{print $1}')
    
    echo "  - 총 문서 수: $total_docs 개"
    echo "  - 총 줄 수: $total_lines 줄"
    echo "  - 총 문자 수: $total_chars 문자"
}

# 함수: 깨진 링크 검사
check_broken_links() {
    echo ""
    echo "🔍 내부 링크 검사 중..."
    
    broken_links=0
    
    find $DOCS_DIR -name "*.md" | while read file; do
        # Markdown 링크 패턴 [text](path) 찾기
        grep -n "\[.*\](\..*\.md)" "$file" 2>/dev/null | while IFS=: read line_num link; do
            # 링크 경로 추출
            link_path=$(echo "$link" | sed -n 's/.*(\(\..*\.md\)).*/\1/p')
            
            if [[ -n "$link_path" ]]; then
                # 상대 경로를 절대 경로로 변환
                dir_path=$(dirname "$file")
                full_path="$dir_path/$link_path"
                
                if [[ ! -f "$full_path" ]]; then
                    echo "  ❌ $file:$line_num - 깨진 링크: $link_path"
                    broken_links=$((broken_links + 1))
                fi
            fi
        done
    done
    
    if [[ $broken_links -eq 0 ]]; then
        echo "  ✅ 모든 내부 링크가 정상입니다."
    else
        echo "  ⚠️  총 $broken_links 개의 깨진 링크를 발견했습니다."
    fi
}

# 함수: 문서 구조 검증
validate_docs_structure() {
    echo ""
    echo "📋 문서 구조 검증 중..."
    
    # README.md 존재 확인
    if [[ ! -f "README.md" ]]; then
        echo "  ❌ 루트 README.md가 없습니다."
    else
        echo "  ✅ 루트 README.md 존재"
    fi
    
    # docs 디렉토리 구조 확인
    required_docs=("ARCHITECTURE.md" "BUILD_GUIDE.md" "API_SPECIFICATION.md")
    
    for doc in "${required_docs[@]}"; do
        if [[ -f "$DOCS_DIR/$doc" ]]; then
            echo "  ✅ $doc 존재"
        else
            echo "  ❌ $doc가 누락되었습니다."
        fi
    done
}

# 함수: 문서 템플릿 체크
check_docs_template() {
    echo ""
    echo "📝 문서 템플릿 준수 검사 중..."
    
    find $DOCS_DIR -name "*.md" | while read file; do
        # H1 헤더 개수 확인 (1개여야 함)
        h1_count=$(grep -c "^# " "$file" 2>/dev/null || echo 0)
        
        if [[ $h1_count -eq 0 ]]; then
            echo "  ⚠️  $file: H1 헤더가 없습니다."
        elif [[ $h1_count -gt 1 ]]; then
            echo "  ⚠️  $file: H1 헤더가 $h1_count 개입니다. (1개 권장)"
        fi
        
        # 목차 존재 확인 (대형 문서의 경우)
        lines=$(wc -l < "$file")
        if [[ $lines -gt 200 ]] && ! grep -q "## 목차\|## Table of Contents\|## Contents" "$file"; then
            echo "  💡 $file: 큰 문서($lines 줄)에 목차 추가를 고려해보세요."
        fi
    done
}

# 함수: 자동 백업 생성
create_docs_backup() {
    echo ""
    echo "💾 문서 백업 생성 중..."
    
    backup_dir="backups/docs-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    cp -r $DOCS_DIR "$backup_dir/"
    cp README.md "$backup_dir/" 2>/dev/null || true
    
    echo "  ✅ 백업 생성 완료: $backup_dir"
}

# 함수: 문서 인덱스 업데이트
update_docs_index() {
    echo ""
    echo "🗂️  문서 인덱스 업데이트 중..."
    
    index_file="$DOCS_DIR/00-INDEX.md"
    temp_file=$(mktemp)
    
    # 기존 인덱스 파일의 헤더 부분 유지
    if [[ -f "$index_file" ]]; then
        # "## 📋 전체 문서 목록" 이전까지 복사
        sed '/## 📋 전체 문서 목록/,$d' "$index_file" > "$temp_file"
    else
        # 새 인덱스 파일 헤더 생성
        cat > "$temp_file" << 'EOF'
# 📚 Multi-Module Example Project - 문서 인덱스

> 자동 생성된 문서 인덱스 (마지막 업데이트: $(date))

EOF
    fi
    
    echo "" >> "$temp_file"
    echo "## 📋 전체 문서 목록" >> "$temp_file"
    echo "" >> "$temp_file"
    
    # 문서 목록 자동 생성
    find $DOCS_DIR -name "*.md" -not -name "00-INDEX.md" | sort | while read file; do
        filename=$(basename "$file")
        title=$(head -n 5 "$file" | grep "^# " | head -n 1 | sed 's/^# //' | sed 's/[🎯📚🏗️🔧📡🚀⭐]*//g' | xargs)
        
        if [[ -z "$title" ]]; then
            title="$filename"
        fi
        
        echo "- [$title]($filename)" >> "$temp_file"
    done
    
    mv "$temp_file" "$index_file"
    echo "  ✅ 문서 인덱스 업데이트 완료"
}

# 메인 실행 함수
main() {
    case "${1:-stats}" in
        "stats")
            generate_docs_stats
            ;;
        "check")
            generate_docs_stats
            check_broken_links
            validate_docs_structure
            check_docs_template
            ;;
        "backup")
            create_docs_backup
            ;;
        "index")
            update_docs_index
            ;;
        "all")
            generate_docs_stats
            check_broken_links
            validate_docs_structure
            check_docs_template
            create_docs_backup
            update_docs_index
            ;;
        "help"|"-h"|"--help")
            cat << 'EOF'
📚 문서 관리 도구 사용법

사용법: ./docs-generator.sh [COMMAND]

명령어:
  stats     문서 통계 출력 (기본값)
  check     문서 검증 (링크, 구조, 템플릿)
  backup    문서 백업 생성
  index     문서 인덱스 자동 업데이트
  all       모든 작업 수행
  help      이 도움말 출력

예제:
  ./docs-generator.sh check     # 문서 검증
  ./docs-generator.sh all       # 모든 작업 수행
EOF
            ;;
        *)
            echo "❌ 알 수 없는 명령어: $1"
            echo "사용법을 보려면 './docs-generator.sh help'를 실행하세요."
            exit 1
            ;;
    esac
}

# 스크립트 실행
main "$@"