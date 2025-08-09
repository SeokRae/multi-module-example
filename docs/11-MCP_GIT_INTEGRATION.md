# MCP Git Integration Guide

## Overview

This document describes the Model Context Protocol (MCP) Git integration setup for the multi-module Spring Boot project. MCP allows AI assistants like Claude Code to interact with Git repositories using standardized tools.

## What is MCP?

The Model Context Protocol (MCP) is an open protocol that enables seamless integration between LLM applications and external data sources and tools. It provides standardized AI integration, flexibility, security, and scalability.

## Installation

### Prerequisites

- Python 3.8+ (for the Git MCP server)
- uv package manager (will be installed automatically by setup script)
- Git repository

### Setup Process

1. **Run the setup script:**
   ```bash
   ./setup-mcp.sh
   ```

   This script will:
   - Install the uv package manager if needed
   - Download and configure the official Git MCP server
   - Create necessary configuration files
   - Test the installation

2. **Manual installation (if needed):**
   ```bash
   # Install uv package manager
   curl -LsSf https://astral.sh/uv/install.sh | sh
   source ~/.local/bin/env
   
   # Clone MCP servers repository (already done by setup script)
   git clone https://github.com/modelcontextprotocol/servers.git mcp-servers
   ```

## Configuration Files

The setup creates several configuration files:

### `.vscode/mcp.json` (VS Code/Claude Code)
```json
{
  "servers": {
    "git": {
      "command": "uv",
      "args": [
        "--directory",
        "./mcp-servers/src/git",
        "run",
        "mcp-server-git",
        "--repository",
        "."
      ],
      "env": {}
    }
  }
}
```

### `.claude/mcp.json` (Claude Code project-level)
```json
{
  "servers": {
    "git": {
      "command": "uv",
      "args": [
        "--directory",
        "./mcp-servers/src/git",
        "run",
        "mcp-server-git",
        "--repository",
        "."
      ],
      "env": {
        "PATH": "${PATH}:${HOME}/.local/bin"
      }
    }
  }
}
```

### `claude-desktop-config.json` (Claude Desktop)
For Claude Desktop users, copy the contents to your Claude Desktop configuration file.

## Available Git Tools

The MCP Git server provides these tools:

### Repository Status and Information
- `git_status` - Shows working tree status
- `git_log` - Shows commit history with configurable count
- `git_branch` - Lists local/remote/all branches with optional filtering

### File Operations
- `git_diff_unstaged` - Shows unstaged changes
- `git_diff_staged` - Shows staged changes  
- `git_diff` - Compare branches or commits
- `git_show` - Shows contents of a specific commit

### Repository Modification
- `git_add` - Stage files for commit
- `git_commit` - Create commits with messages
- `git_reset` - Unstage all staged changes

### Branch Operations
- `git_create_branch` - Create new branches
- `git_checkout` - Switch between branches

### Repository Initialization
- `git_init` - Initialize new Git repositories

## Usage Examples

Once configured, AI assistants can use commands like:

- "Show me the current git status"
- "What changed in the last 5 commits?"
- "Create a new branch called 'feature/new-api'"
- "Show me unstaged changes"
- "Stage all modified files and commit with message 'Update configuration'"

## Integration with Claude Code

Claude Code will automatically detect and use the MCP Git server when:

1. The `.claude/mcp.json` or `.vscode/mcp.json` file is present
2. The uv package manager is installed and in PATH
3. The MCP servers repository is cloned in the project

## Troubleshooting

### Common Issues

1. **"uv not found" error**
   ```bash
   # Install uv and source the environment
   curl -LsSf https://astral.sh/uv/install.sh | sh
   source ~/.local/bin/env
   ```

2. **MCP server not responding**
   ```bash
   # Test the server manually
   cd mcp-servers/src/git
   uv run mcp-server-git --repository . --help
   ```

3. **Path issues**
   - Ensure all paths in configuration files are correct
   - Use absolute paths if relative paths cause issues

### Logs and Debugging

- Claude Desktop logs: `~/Library/Logs/Claude/mcp*.log` (macOS)
- Test MCP connection: Run `./setup-mcp.sh` to verify installation

## Security Considerations

- The MCP Git server only operates on the specified repository
- No external network access is required for Git operations
- All Git operations respect repository permissions
- Configuration files should not contain sensitive information

## Team Setup

For team members to use the MCP Git integration:

1. Pull the latest changes (includes configuration files)
2. Run `./setup-mcp.sh`
3. Restart their AI assistant/editor

The configuration files are committed to the repository for team sharing.

## Advanced Configuration

### Custom Repository Path
To use a different repository path, modify the `--repository` argument in configuration files.

### Environment Variables
Add custom environment variables to the `env` section of configuration files as needed.

### Performance Tuning
For large repositories, consider:
- Limiting log output with `max_count` parameter
- Using specific branch filtering
- Configuring diff context lines

## Version Information

- MCP Git Server Version: 1.1.0
- Protocol Version: 2024-11-05
- Last Updated: 2025-08-09