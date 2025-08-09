# Multi-Module Example Project

Spring Boot 기반의 멀티모듈 Gradle 프로젝트입니다. 도메인 주도 설계(DDD)와 헥사고날 아키텍처 원칙을 적용한 확장 가능한 구조로 설계되었습니다.

## 📋 목차

- [프로젝트 개요](#프로젝트-개요)
- [아키텍처 설계](#아키텍처-설계)
- [모듈 구조](#모듈-구조)
- [기술 스택](#기술-스택)
- [빌드 및 실행](#빌드-및-실행)
- [API 문서](#api-문서)
- [개발 가이드](#개발-가이드)
- [AI 기반 Git 자동화 (MCP Git)](#ai-기반-git-자동화-mcp-git)

## 🎯 프로젝트 개요

이 프로젝트는 다음과 같은 목적으로 설계되었습니다:

- **모듈화된 아키텍처**: 비즈니스 도메인별로 모듈을 분리하여 독립적인 개발과 배포 가능
- **확장성**: 새로운 도메인이나 기능을 쉽게 추가할 수 있는 구조
- **유지보수성**: 의존성 방향을 명확히 하여 코드의 가독성과 유지보수성 향상
- **재사용성**: 공통 기능을 별도 모듈로 분리하여 재사용성 극대화

## 🏗️ 아키텍처 설계

### 전체 아키텍처 다이어그램

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                        │
│  ┌─────────────────┐              ┌─────────────────┐      │
│  │   user-api      │              │   batch-app     │      │
│  │  (REST API)     │              │  (Batch Jobs)   │      │
│  └─────────────────┘              └─────────────────┘      │
└─────────────────┬───────────────────────┬───────────────────┘
                  │                       │
                  ▼                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    Domain Layer                             │
│  ┌─────────────────┐              ┌─────────────────┐      │
│  │  user-domain    │              │ order-domain    │      │
│  │ (Business Logic)│              │(Business Logic) │      │
│  └─────────────────┘              └─────────────────┘      │
└─────────────────┬───────────────────────┬───────────────────┘
                  │                       │
                  ▼                       ▼
┌─────────────────────────────────────────────────────────────┐
│                Infrastructure Layer                         │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                  data-access                            │ │
│  │            (JPA Repositories & Entities)               │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
            ┌─────────────────────────────────┐
            │           Database              │
            │         (H2 In-Memory)          │
            └─────────────────────────────────┘

                Common Modules (횡단 관심사)
    ┌─────────────────┐              ┌─────────────────┐
    │  common-core    │              │  common-web     │
    │ (Base Classes,  │              │ (Web Common,    │
    │  Exceptions,    │              │  Global Handler,│
    │  Utilities)     │              │  API Response)  │
    └─────────────────┘              └─────────────────┘
```

### 의존성 방향

```
Application → Domain ← Infrastructure
     ↓           ↓
   Common ←─────┘
```

- **Application Layer**: Domain Layer에만 의존
- **Domain Layer**: Common Layer에만 의존 (외부 의존성 없음)
- **Infrastructure Layer**: Domain Layer와 Common Layer에 의존
- **Common Layer**: 외부 의존성 없음 (Spring Boot 기본 라이브러리 제외)

## 📁 모듈 구조

### 1. Common Modules (공통 모듈)

#### `common-core`
```
common/common-core/
├── src/main/java/com/example/common/
│   ├── exception/
│   │   ├── BusinessException.java        # 비즈니스 예외
│   │   └── ErrorCode.java               # 에러 코드 정의
│   └── util/
│       └── DateTimeUtils.java           # 날짜/시간 유틸리티
└── build.gradle
```

**역할**: 
- 전사 공통 예외 처리
- 유틸리티 클래스
- 공통 상수 및 열거형

#### `common-web`
```
common/common-web/
├── src/main/java/com/example/common/web/
│   ├── response/
│   │   └── ApiResponse.java             # 표준 API 응답 형식
│   └── exception/
│       └── GlobalExceptionHandler.java  # 전역 예외 핸들러
└── build.gradle
```

**역할**:
- 웹 계층 공통 기능
- 표준 API 응답 형식
- 전역 예외 처리

### 2. Domain Modules (도메인 모듈)

#### `user-domain`
```
domain/user-domain/
├── src/main/java/com/example/user/domain/
│   ├── User.java                        # 사용자 도메인 엔티티
│   ├── UserStatus.java                  # 사용자 상태 열거형
│   ├── repository/
│   │   └── UserRepository.java          # 사용자 리포지토리 인터페이스
│   └── service/
│       └── UserService.java             # 사용자 도메인 서비스
└── build.gradle
```

**역할**:
- 사용자 관련 비즈니스 로직
- 도메인 모델 정의
- 비즈니스 규칙 구현

#### `order-domain`
```
domain/order-domain/
├── src/main/java/com/example/order/domain/
│   ├── Order.java                       # 주문 도메인 엔티티
│   ├── OrderItem.java                   # 주문 상품 도메인 엔티티
│   └── OrderStatus.java                 # 주문 상태 열거형
└── build.gradle
```

**역할**:
- 주문 관련 비즈니스 로직
- 주문 도메인 모델 정의

### 3. Infrastructure Module (인프라 모듈)

#### `data-access`
```
infrastructure/data-access/
├── src/main/java/com/example/infrastructure/
│   └── user/
│       ├── UserEntity.java              # JPA 엔티티
│       ├── UserJpaRepository.java       # Spring Data JPA 인터페이스
│       └── UserRepositoryImpl.java      # 도메인 리포지토리 구현체
└── build.gradle
```

**역할**:
- 데이터 접근 계층 구현
- JPA 엔티티 및 리포지토리
- 도메인 모델과 JPA 엔티티 간 매핑

### 4. Application Modules (애플리케이션 모듈)

#### `user-api`
```
application/user-api/
├── src/main/java/com/example/user/api/
│   ├── UserApiApplication.java          # Spring Boot 메인 클래스
│   ├── controller/
│   │   └── UserController.java          # REST API 컨트롤러
│   └── dto/
│       ├── UserCreateRequest.java       # 사용자 생성 요청 DTO
│       └── UserResponse.java            # 사용자 응답 DTO
├── src/main/resources/
│   └── application.yml                  # 애플리케이션 설정
└── build.gradle
```

**역할**:
- REST API 제공
- HTTP 요청/응답 처리
- API 문서화

#### `batch-app`
```
application/batch-app/
├── src/main/java/com/example/batch/
│   └── BatchApplication.java            # Spring Boot 배치 메인 클래스
├── src/main/resources/
│   └── application.yml                  # 배치 애플리케이션 설정
└── build.gradle
```

**역할**:
- 배치 작업 실행
- 스케줄링된 작업
- 대용량 데이터 처리

## 🛠️ 기술 스택

### Core
- **Java 17**: 최신 LTS 버전
- **Spring Boot 3.2.2**: 메인 프레임워크
- **Gradle**: 빌드 도구

### Web & API
- **Spring Web**: REST API 구현
- **Spring Validation**: 입력값 검증
- **Jackson**: JSON 직렬화/역직렬화

### Data Access
- **Spring Data JPA**: 데이터 접근 계층
- **H2 Database**: 인메모리 데이터베이스

### Batch Processing
- **Spring Batch**: 배치 처리

### Utility & Tools
- **Lombok**: 코드 간소화
- **Spring Boot Actuator**: 모니터링 및 관리

## 🚀 빌드 및 실행

### 사전 요구사항
- Java 17 이상
- IDE (IntelliJ IDEA 권장)

### 프로젝트 빌드
```bash
# 프로젝트 루트에서 실행
./gradlew build

# 특정 모듈만 빌드
./gradlew :application:user-api:build
```

### 애플리케이션 실행

#### 1. User API 서버 실행
```bash
./gradlew :application:user-api:bootRun
```
- 포트: `8080`
- H2 Console: http://localhost:8080/h2-console
- Health Check: http://localhost:8080/actuator/health

#### 2. Batch Application 실행
```bash
./gradlew :application:batch-app:bootRun
```
- 포트: `8081`

### 테스트 실행
```bash
# 전체 테스트
./gradlew test

# 특정 모듈 테스트
./gradlew :application:user-api:test
```

## 📚 API 문서

### 사용자 API

#### Base URL
```
http://localhost:8080/api/users
```

#### 엔드포인트

| Method | URL | Description | Request Body | Response |
|--------|-----|-------------|--------------|----------|
| POST | `/api/users` | 사용자 생성 | UserCreateRequest | ApiResponse<UserResponse> |
| GET | `/api/users/{id}` | 사용자 조회 | - | ApiResponse<UserResponse> |
| GET | `/api/users` | 전체 사용자 조회 | - | ApiResponse<List<UserResponse>> |
| PUT | `/api/users/{id}/activate` | 사용자 활성화 | - | ApiResponse<UserResponse> |

#### 요청/응답 예시

**사용자 생성**
```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "name": "홍길동"
  }'
```

**응답 예시**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "status": "ACTIVE",
    "createdAt": "2024-01-01T10:00:00",
    "updatedAt": "2024-01-01T10:00:00"
  },
  "message": "사용자가 성공적으로 생성되었습니다",
  "code": null
}
```

## 👨‍💻 개발 가이드

### 새로운 도메인 추가

1. **도메인 모듈 생성**
```bash
mkdir -p domain/product-domain/src/main/java/com/example/product/domain
```

2. **settings.gradle에 모듈 추가**
```gradle
include 'domain:product-domain'
```

3. **도메인 모델 구현**
```java
// domain/product-domain/src/main/java/com/example/product/domain/Product.java
@Getter
@Builder
public class Product {
    private Long id;
    private String name;
    private BigDecimal price;
    // ... 비즈니스 로직
}
```

### 새로운 API 애플리케이션 추가

1. **애플리케이션 모듈 생성**
```bash
mkdir -p application/product-api/src/main/java/com/example/product/api
```

2. **의존성 설정 (build.gradle)**
```gradle
dependencies {
    implementation project(':common:common-web')
    implementation project(':domain:product-domain')
    implementation project(':infrastructure:data-access')
    // ... 기타 의존성
}
```

### 코딩 컨벤션

1. **패키지 네이밍**: `com.example.{domain}.{layer}`
2. **클래스 네이밍**: PascalCase, 의미있는 이름 사용
3. **메서드 네이밍**: camelCase, 동사+명사 형태
4. **상수**: UPPER_SNAKE_CASE

### 테스트 전략

1. **단위 테스트**: 각 모듈별 핵심 로직 테스트
2. **통합 테스트**: API 레벨 end-to-end 테스트
3. **테스트 데이터**: H2 인메모리 DB 활용

## 🤖 AI 기반 Git 자동화 (MCP Git)

이 프로젝트는 **Model Context Protocol (MCP) Git 통합**을 통해 AI 기반 Git 자동화 기능을 제공합니다.

### ⚡ 빠른 시작

1. **MCP Git 서버 설정**
   ```bash
   ./setup-mcp.sh
   ```

2. **AI와 대화하며 Git 작업**
   ```
   "현재 git 상태 보여줘"
   "새 브랜치 feature/payment 만들어줘"
   "변경사항을 '결제 API 추가' 메시지로 커밋해줘"
   "main 브랜치와 차이점 분석해줘"
   ```

### 🎯 주요 기능

- **13가지 Git 도구**: status, log, branch, add, commit, reset, diff, checkout 등
- **자연스러운 대화**: 복잡한 Git 명령어 대신 일상 언어로 Git 조작
- **지능적 분석**: 변경사항 분석, 브랜치 비교, 커밋 히스토리 요약
- **워크플로우 자동화**: 개발 시작부터 배포까지 AI가 도움

### 📚 상세 가이드

- **설치 및 설정**: [docs/11-MCP_GIT_INTEGRATION.md](docs/11-MCP_GIT_INTEGRATION.md)
- **실사용 시나리오**: [docs/12-MCP_USAGE_EXAMPLES.md](docs/12-MCP_USAGE_EXAMPLES.md)
- **전체 문서 인덱스**: [docs/00-INDEX.md](docs/00-INDEX.md)

### 🛠️ 지원 환경

- **Claude Code**: 자동 감지 및 연동
- **VS Code**: MCP 확장을 통한 연동
- **Claude Desktop**: 설정 파일 복사로 연동

---

## 🔧 확장 계획

- [x] **MCP Git 통합**: AI 기반 Git 자동화 ✅
- [ ] Spring Security 인증/인가 추가
- [ ] Redis 캐시 레이어 추가  
- [ ] MySQL/PostgreSQL 데이터베이스 연동
- [ ] Docker 컨테이너화
- [ ] CI/CD 파이프라인 구축
- [ ] API 문서 자동화 (Swagger/OpenAPI)
- [ ] 모니터링 및 로깅 시스템 구축

---

## 📞 문의사항

프로젝트 관련 문의사항이나 MCP Git 사용법에 대한 질문이 있으시면 Issues를 통해 남겨주시기 바랍니다.