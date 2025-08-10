#!/bin/bash

# MCP Git Server Setup Script
# This script sets up the Model Context Protocol (MCP) Git server for the project

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_GIT_DIR="$PROJECT_ROOT/mcp-servers/src/git"

echo "🚀 Setting up MCP Git Server..."

# Source uv environment
if [ -f "$HOME/.local/bin/env" ]; then
    source "$HOME/.local/bin/env"
fi

# Check if uv is available
if ! command -v uv &> /dev/null; then
    echo "❌ uv is not installed or not in PATH"
    echo "Please run: curl -LsSf https://astral.sh/uv/install.sh | sh"
    echo "Then restart your shell or run: source ~/.local/bin/env"
    exit 1
fi

echo "✅ uv is available"

# Test the MCP Git server
echo "🧪 Testing MCP Git server..."
cd "$MCP_GIT_DIR"
if uv run mcp-server-git --repository "$PROJECT_ROOT" --help > /dev/null 2>&1; then
    echo "✅ MCP Git server is working properly"
else
    echo "❌ MCP Git server test failed"
    exit 1
fi

echo ""
echo "🎉 MCP Git Server setup completed!"
echo ""
echo "Configuration files created:"
echo "  - .vscode/mcp.json (VS Code MCP configuration)"
echo "  - .claude/mcp.json (Claude Code MCP configuration)"
echo "  - mcp-config.json (General MCP configuration)"
echo "  - claude-desktop-config.json (Claude Desktop configuration)"
echo ""
echo "To use with Claude Code, the MCP server should automatically be detected."
echo "To use with Claude Desktop, copy the contents of claude-desktop-config.json"
echo "to your Claude Desktop configuration file."
echo ""
echo "Available Git MCP tools:"
echo "  - git_status, git_diff_unstaged, git_diff_staged, git_diff"
echo "  - git_commit, git_add, git_reset, git_log"
echo "  - git_create_branch, git_checkout, git_show, git_init, git_branch"