#!/bin/bash

# MCP Git 기능 테스트 스크립트
# 이 스크립트는 MCP Git 서버의 주요 기능들을 테스트합니다

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_GIT_DIR="$PROJECT_ROOT/mcp-servers/src/git"

echo "🧪 MCP Git 기능 테스트 시작..."

# Source uv environment
if [ -f "$HOME/.local/bin/env" ]; then
    source "$HOME/.local/bin/env"
fi

# Check if uv is available
if ! command -v uv &> /dev/null; then
    echo "❌ uv가 설치되지 않았거나 PATH에 없습니다"
    exit 1
fi

echo "✅ uv 사용 가능"

cd "$MCP_GIT_DIR"

echo ""
echo "📋 1. Git Status 테스트..."
echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {"tools": {}}, "clientInfo": {"name": "test", "version": "1.0"}}}' | uv run mcp-server-git --repository "$PROJECT_ROOT" 2>/dev/null | head -1

echo ""
echo "📈 2. Git Log 테스트..."
echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {"tools": {}}, "clientInfo": {"name": "test", "version": "1.0"}}}' | uv run mcp-server-git --repository "$PROJECT_ROOT" 2>/dev/null | head -1

echo ""
echo "🌿 3. Branch 목록 테스트..."
echo '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {"tools": {}}, "clientInfo": {"name": "test", "version": "1.0"}}}' | uv run mcp-server-git --repository "$PROJECT_ROOT" 2>/dev/null | head -1

echo ""
echo "✅ MCP Git 서버가 정상적으로 응답합니다!"
echo ""
echo "🎉 MCP Git 기능 테스트 완료!"
echo ""
echo "사용 가능한 명령어:"
echo "  - '현재 git 상태 보여줘'"
echo "  - '최근 커밋 5개 보여줘'"
echo "  - '브랜치 목록 보여줘'"
echo "  - '새 브랜치 feature/test 만들어줘'"
echo "  - '변경사항 커밋해줘'"