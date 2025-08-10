#!/bin/bash
# GitHub REST API를 이용한 PR 확인 스크립트

REPO_OWNER="SeokRae"
REPO_NAME="multi-module-example"

# API 기본 URL
API_BASE="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME"

echo "🔍 GitHub PR 확인 (REST API 사용)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# PR 목록 조회
echo "📋 열린 PR 목록:"
curl -s "$API_BASE/pulls?state=open&per_page=10" | \
    python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if not data:
        print('   📭 열린 PR이 없습니다.')
    else:
        for pr in data:
            print(f\"   #{pr['number']} - {pr['title']}\")
            print(f\"      👤 {pr['user']['login']} → {pr['base']['ref']}\")
            print(f\"      🌿 {pr['head']['ref']}\")
            print()
except:
    print('   ❌ PR 정보를 가져올 수 없습니다.')
"

echo ""
echo "📋 최근 닫힌 PR 목록:"
curl -s "$API_BASE/pulls?state=closed&per_page=5" | \
    python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if not data:
        print('   📭 닫힌 PR이 없습니다.')
    else:
        for pr in data:
            state = '✅ 머지됨' if pr.get('merged_at') else '❌ 닫힘'
            print(f\"   #{pr['number']} - {pr['title']} ({state})\")
            print(f\"      👤 {pr['user']['login']}\")
            print()
except:
    print('   ❌ PR 정보를 가져올 수 없습니다.')
"

echo ""
echo "📊 저장소 통계:"
curl -s "$API_BASE" | \
    python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f\"   ⭐ Stars: {data['stargazers_count']}\")
    print(f\"   🍴 Forks: {data['forks_count']}\")
    print(f\"   👀 Watchers: {data['watchers_count']}\")
    print(f\"   📝 Open Issues: {data['open_issues_count']}\")
    print(f\"   🌿 Default Branch: {data['default_branch']}\")
except:
    print('   ❌ 저장소 정보를 가져올 수 없습니다.')
"