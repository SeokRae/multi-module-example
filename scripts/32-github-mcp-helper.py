#!/usr/bin/env python3
"""
GitHub MCP Helper
GitHub REST API를 활용한 PR 및 이슈 관리 도구
"""

import os
import sys
import json
import requests
from typing import Optional, Dict, List
from datetime import datetime

class GitHubMCPHelper:
    def __init__(self, repo_owner: str, repo_name: str, token: Optional[str] = None):
        self.repo_owner = repo_owner
        self.repo_name = repo_name
        self.token = token or os.getenv('GITHUB_TOKEN')
        self.base_url = f"https://api.github.com/repos/{repo_owner}/{repo_name}"
        
        self.headers = {
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'GitHubMCPHelper/1.0'
        }
        
        if self.token:
            self.headers['Authorization'] = f'token {self.token}'
    
    def _request(self, method: str, url: str, **kwargs) -> Dict:
        """GitHub API 요청 실행"""
        try:
            response = requests.request(method, url, headers=self.headers, **kwargs)
            response.raise_for_status()
            return response.json() if response.text else {}
        except requests.exceptions.RequestException as e:
            return {"error": str(e), "status_code": getattr(e.response, 'status_code', None)}
    
    def list_prs(self, state: str = "open", per_page: int = 10) -> List[Dict]:
        """PR 목록 조회"""
        url = f"{self.base_url}/pulls"
        params = {"state": state, "per_page": per_page, "sort": "updated", "direction": "desc"}
        
        result = self._request("GET", url, params=params)
        if isinstance(result, list):
            return result
        return []
    
    def get_pr(self, pr_number: int) -> Dict:
        """특정 PR 상세 정보"""
        url = f"{self.base_url}/pulls/{pr_number}"
        return self._request("GET", url)
    
    def get_pr_reviews(self, pr_number: int) -> List[Dict]:
        """PR 리뷰 목록"""
        url = f"{self.base_url}/pulls/{pr_number}/reviews"
        result = self._request("GET", url)
        return result if isinstance(result, list) else []
    
    def get_pr_checks(self, pr_number: int) -> Dict:
        """PR 체크 상태"""
        # PR 정보 먼저 가져오기
        pr = self.get_pr(pr_number)
        if "error" in pr:
            return pr
        
        # Commit SHA 가져오기
        sha = pr.get("head", {}).get("sha")
        if not sha:
            return {"error": "Could not find commit SHA"}
        
        # 체크 상태 조회
        url = f"{self.base_url}/commits/{sha}/status"
        return self._request("GET", url)
    
    def create_pr(self, title: str, body: str, head: str, base: str = "main") -> Dict:
        """PR 생성"""
        url = f"{self.base_url}/pulls"
        data = {
            "title": title,
            "body": body,
            "head": head,
            "base": base
        }
        return self._request("POST", url, json=data)
    
    def list_issues(self, state: str = "open", per_page: int = 10) -> List[Dict]:
        """이슈 목록 조회"""
        url = f"{self.base_url}/issues"
        params = {
            "state": state, 
            "per_page": per_page, 
            "sort": "updated", 
            "direction": "desc",
            "filter": "all"  # PR과 이슈 모두 포함
        }
        
        result = self._request("GET", url, params=params)
        if isinstance(result, list):
            # PR은 제외하고 순수 이슈만 반환
            return [item for item in result if "pull_request" not in item]
        return []
    
    def get_repo_info(self) -> Dict:
        """저장소 기본 정보"""
        return self._request("GET", self.base_url)
    
    def format_pr_list(self, prs: List[Dict]) -> str:
        """PR 목록을 보기 좋게 포맷"""
        if not prs:
            return "📭 PR이 없습니다."
        
        output = []
        for pr in prs:
            status = "🟢" if pr["state"] == "open" else "🟣" if pr.get("merged_at") else "🔴"
            output.append(f"{status} #{pr['number']} - {pr['title']}")
            output.append(f"   👤 {pr['user']['login']} → {pr['base']['ref']}")
            output.append(f"   🌿 {pr['head']['ref']}")
            
            # 업데이트 시간
            updated = datetime.fromisoformat(pr['updated_at'].replace('Z', '+00:00'))
            output.append(f"   ⏰ {updated.strftime('%Y-%m-%d %H:%M')}")
            output.append("")
        
        return "\n".join(output)
    
    def format_pr_detail(self, pr: Dict) -> str:
        """PR 상세 정보를 보기 좋게 포맷"""
        if "error" in pr:
            return f"❌ 오류: {pr['error']}"
        
        status = "🟢 열림" if pr["state"] == "open" else "🟣 머지됨" if pr.get("merged_at") else "🔴 닫힘"
        
        output = [
            f"# PR #{pr['number']} - {pr['title']}",
            f"**상태**: {status}",
            f"**작성자**: {pr['user']['login']}",
            f"**브랜치**: {pr['head']['ref']} → {pr['base']['ref']}",
            f"**생성일**: {pr['created_at'][:10]}",
            f"**업데이트**: {pr['updated_at'][:10]}",
            "",
            "## 설명",
            pr.get("body", "설명 없음") or "설명 없음",
            "",
            f"**🔗 링크**: {pr['html_url']}"
        ]
        
        return "\n".join(output)

def main():
    if len(sys.argv) < 2:
        print("사용법: python3 github-mcp-helper.py <command> [args...]")
        print("명령어: list-prs, get-pr, list-issues, repo-info")
        return
    
    # 저장소 정보 (환경변수나 설정에서 가져올 수 있음)
    helper = GitHubMCPHelper("SeokRae", "multi-module-example")
    
    command = sys.argv[1]
    
    if command == "list-prs":
        state = sys.argv[2] if len(sys.argv) > 2 else "open"
        prs = helper.list_prs(state)
        print(f"📋 {state.upper()} PR 목록")
        print("=" * 50)
        print(helper.format_pr_list(prs))
    
    elif command == "get-pr":
        if len(sys.argv) < 3:
            print("PR 번호를 입력하세요: python3 github-mcp-helper.py get-pr <번호>")
            return
        
        pr_number = int(sys.argv[2])
        pr = helper.get_pr(pr_number)
        print(helper.format_pr_detail(pr))
        
        # 체크 상태도 함께 표시
        checks = helper.get_pr_checks(pr_number)
        if "error" not in checks:
            print(f"\n🔄 **체크 상태**: {checks.get('state', 'unknown')}")
    
    elif command == "list-issues":
        state = sys.argv[2] if len(sys.argv) > 2 else "open"
        issues = helper.list_issues(state)
        print(f"📋 {state.upper()} 이슈 목록")
        print("=" * 50)
        if not issues:
            print("📭 이슈가 없습니다.")
        else:
            for issue in issues:
                status = "🟢" if issue["state"] == "open" else "🔴"
                print(f"{status} #{issue['number']} - {issue['title']}")
                print(f"   👤 {issue['user']['login']}")
                print()
    
    elif command == "repo-info":
        info = helper.get_repo_info()
        if "error" not in info:
            print(f"📊 {info['full_name']} 저장소 정보")
            print("=" * 50)
            print(f"⭐ Stars: {info['stargazers_count']}")
            print(f"🍴 Forks: {info['forks_count']}")
            print(f"👀 Watchers: {info['watchers_count']}")
            print(f"📝 Open Issues: {info['open_issues_count']}")
            print(f"🌿 Default Branch: {info['default_branch']}")
            print(f"📄 Description: {info.get('description', 'N/A')}")
            print(f"🔗 URL: {info['html_url']}")
        else:
            print(f"❌ 오류: {info['error']}")
    
    else:
        print(f"❌ 알 수 없는 명령어: {command}")

if __name__ == "__main__":
    main()