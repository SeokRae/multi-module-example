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

## 🤖 자동 개발 워크플로우 규칙

### 개발 요청 자동화 프로토콜
사용자가 다음과 같은 **개발 요청**을 하면 **전체 워크플로우를 자동 실행**:

#### 트리거 키워드
- "구현해줘", "개발해줘", "만들어줘"
- "추가해줘", "생성해줘", "작성해줘"
- "Phase [이름]" 관련 요청
- "[기능명] 시스템 구축해줘"

#### 자동 실행 단계
**모든 개발 요청에 대해 다음 8단계를 순차적으로 자동 실행:**

1. **🎯 GitHub 이슈 생성**: 요청 내용 기반으로 상세 이슈 자동 생성
2. **🌿 피처 브랜치 생성**: `feature/[기능명]` 형식으로 브랜치 생성
3. **💻 코드 구현**: 요청된 기능의 완전한 코드 구현
4. **🧪 테스트 작성**: 단위 테스트 및 통합 테스트 작성
5. **📚 문서화**: 상세 개발 문서 및 API 문서 작성
6. **✅ CI/CD 확인**: 빌드, 테스트, 품질 검사 통과 확인
7. **🔄 PR 생성 및 머지**: Pull Request 생성 후 자동 머지
8. **🎉 완료 보고**: 구현 완료 및 결과 요약 보고

#### 예외 상황
- 단순 질문이나 정보 요청은 자동화 대상이 **아님**
- 파일 읽기, 검색, 분석 요청은 자동화 대상이 **아님**
- "설명해줘", "어떻게 해?", "뭐가 있어?" 같은 질의는 일반 응답

#### 품질 보장
- **항상** TodoWrite로 진행 상황 추적
- **항상** ExitPlanMode로 계획 승인 후 진행 (복잡한 작업시)
- **항상** 완전한 기능 구현 (부분 구현 금지)
- **항상** 테스트와 문서를 포함한 완성된 결과물
- **항상** CI/CD 통과 후 머지

### 예시
```
사용자: "Redis 캐싱 시스템 구현해줘"
Claude: [자동 워크플로우 시작]
       ✅ 이슈 #24 생성
       ✅ feature/phase-cache-redis 브랜치 생성
       ✅ RedisConfig, CacheService 구현
       ✅ 캐싱 적용 및 테스트 작성
       ✅ 문서화 완료
       ✅ CI/CD 통과 확인
       ✅ PR #25 생성 및 머지
       ✅ "Redis 캐싱 시스템 구현 완료!" 보고
```

이 규칙은 개발 속도와 품질을 동시에 보장하며, 모든 작업이 추적 가능하고 일관된 형태로 진행됩니다.