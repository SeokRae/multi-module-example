# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Status
This is a fully-developed multi-module Gradle Spring Boot project with comprehensive documentation and MCP Git integration for AI-powered development.

## Current Structure
- Multi-module Gradle Spring Boot project
- IntelliJ IDEA project configuration
- Comprehensive documentation in `docs/` directory
- MCP Git integration for AI-powered development
- Common libraries, domain models, infrastructure, and applications

## Development Setup
This is a Gradle-based multi-module project. Common commands:

- Build: `./gradlew build`
- Test: `./gradlew test`
- Run user API: `./gradlew :application:user-api:bootRun`
- Run batch app: `./gradlew :application:batch-app:bootRun`

## MCP Git Integration
The project includes Model Context Protocol (MCP) Git integration:

- Run `./setup-mcp.sh` to set up MCP Git server
- Configuration files are in `.claude/mcp.json` and `.vscode/mcp.json`
- Provides AI assistants with Git repository access and tools
- See `docs/11-MCP_GIT_INTEGRATION.md` for detailed setup guide

## Architecture Notes
This is a learning/example project demonstrating multi-module Gradle Spring Boot architecture:

- Parent build.gradle with shared configuration and dependency management
- Common modules: shared utilities, core business logic, web components
- Domain modules: business entities and services (User, Order)
- Infrastructure modules: data access and caching
- Application modules: user-api (REST API), batch-app (Spring Batch)

## Development Notes
- Project uses Gradle with multi-module structure
- Spring Boot 3.2.2 with Java 17
- Comprehensive documentation in docs/ directory
- MCP integration for AI-assisted development
- Follow modular architecture patterns defined in docs/02-ARCHITECTURE.md

## AI Assistant Guidelines
- ALWAYS use plan mode for all non-trivial tasks that require multiple steps or implementation work
- Present implementation plans for user approval before executing code changes
- Use ExitPlanMode tool to present plans clearly before implementation