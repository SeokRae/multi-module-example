# 🚀 Multi-Module Spring Boot Example Project

> **Spring Boot + Gradle 기반 멀티모듈 프로젝트 예제**  
> Domain-Driven Design과 Hexagonal Architecture를 적용한 현대적인 Java 애플리케이션 구조

## 📋 프로젝트 개요

이 프로젝트는 **Spring Boot와 Gradle을 활용한 멀티모듈 아키텍처**의 모범 사례를 보여주는 예제입니다.

### 🎯 주요 특징
- **🏗️ 계층형 모듈 구조**: Common → Domain → Infrastructure → Application
- **📦 의존성 최적화**: 각 모듈 특성에 맞는 최소 의존성 구성
- **🔧 Gradle 멀티프로젝트**: 효율적인 빌드 시스템
- **🧪 포괄적 테스트**: 단위/통합/E2E 테스트 가이드
- **📡 REST API**: OpenAPI 3.0 기반 문서화

## 📚 문서 읽기 순서

**이 프로젝트의 문서들은 순서대로 읽을 수 있도록 파일명에 번호를 붙였습니다:**

### 🚀 **1단계: 시작하기**
1. **[01-README.md](01-README.md)** (이 문서) - 프로젝트 전체 개요
2. **[02-ARCHITECTURE.md](02-ARCHITECTURE.md)** - 시스템 아키텍처 설계
3. **[03-BUILD_GUIDE.md](03-BUILD_GUIDE.md)** - 빌드 및 실행 가이드

### 🧪 **2단계: 개발 및 테스트**
4. **[04-MODULE_TESTING_GUIDE.md](04-MODULE_TESTING_GUIDE.md)** - 모듈 테스트 방법
5. **[05-API_SPECIFICATION.md](05-API_SPECIFICATION.md)** - REST API 명세서
6. **[06-MODULE_GUIDE.md](06-MODULE_GUIDE.md)** - 모듈별 개발 가이드

### 🔧 **3단계: 문제 해결 및 최적화**
7. **[07-BUILD_TROUBLESHOOTING.md](07-BUILD_TROUBLESHOOTING.md)** - 빌드 문제 해결
8. **[08-DEPENDENCY_ARCHITECTURE.md](08-DEPENDENCY_ARCHITECTURE.md)** - 의존성 아키텍처
9. **[09-MODULE_DEPENDENCY_OPTIMIZATION.md](09-MODULE_DEPENDENCY_OPTIMIZATION.md)** - 의존성 최적화
10. **[10-DEPENDENCY_OPTIMIZATION_SUMMARY.md](10-DEPENDENCY_OPTIMIZATION_SUMMARY.md)** - 최적화 요약

### 📋 **참고 자료**
- **[00-INDEX.md](00-INDEX.md)** - 역할별 문서 인덱스 (빠른 탐색용)
- **[99-DOCUMENTATION_ORGANIZATION_STRATEGY.md](99-DOCUMENTATION_ORGANIZATION_STRATEGY.md)** - 문서 관리 전략

## 🏗️ 프로젝트 구조

```
multi-module-example-1/
├── 📁 common/                    # 공통 모듈
│   ├── common-core/             # 핵심 유틸리티
│   ├── common-web/              # 웹 공통 기능
│   └── common-cache/            # 캐시 추상화
├── 📁 domain/                   # 도메인 모듈
│   ├── user-domain/            # 사용자 도메인
│   └── order-domain/           # 주문 도메인  
├── 📁 infrastructure/           # 인프라 모듈
│   ├── data-access/            # 데이터 접근
│   └── cache-infrastructure/   # 캐시 구현
├── 📁 application/             # 애플리케이션 모듈
│   ├── user-api/              # 사용자 API
│   └── batch-app/             # 배치 애플리케이션
└── 📁 scripts/                # 자동화 스크립트
    ├── verify-all-modules.sh  # 모듈 검증
    └── docs-generator.sh      # 문서 관리
```

## ⚡ 빠른 시작

### 1️⃣ 프로젝트 클론 및 빌드
```bash
# 프로젝트 클론
git clone [repository-url]
cd multi-module-example-1

# 전체 빌드
./gradlew build

# 테스트 실행  
./gradlew test
```

### 2️⃣ 애플리케이션 실행
```bash
# User API 서버 실행
./gradlew :application:user-api:bootRun

# 배치 애플리케이션 실행
./gradlew :application:batch-app:bootRun
```

### 3️⃣ API 문서 확인
```bash
# 서버 실행 후 브라우저에서 접속
http://localhost:8080/swagger-ui.html
```

## 🛠️ 주요 기술 스택

| 영역 | 기술 스택 |
|------|-----------|
| **Framework** | Spring Boot 3.2, Spring Security, Spring Data JPA |
| **Build Tool** | Gradle 8.x Multi-Project |
| **Database** | PostgreSQL + H2 (테스트) |
| **Cache** | Redis + Caffeine |
| **Documentation** | OpenAPI 3.0 (Swagger) |
| **Testing** | JUnit 5, TestContainers, MockMvc |
| **Monitoring** | Spring Actuator, Prometheus |

## 👥 대상 사용자

| 역할 | 추천 읽기 순서 |
|------|---------------|
| **🆕 신규 개발자** | 01 → 02 → 03 → 04 |
| **👨‍💻 백엔드 개발자** | 02 → 05 → 06 → 09 |
| **🏗️ 아키텍트** | 02 → 08 → 09 → 10 |
| **🔧 데브옵스** | 03 → 07 → 04 |

## 🎯 학습 목표

이 프로젝트를 통해 다음을 학습할 수 있습니다:

- **📦 모듈화 설계**: 응집도 높고 결합도 낮은 모듈 구조
- **🔗 의존성 관리**: Gradle을 활용한 체계적인 의존성 관리
- **🏛️ 아키텍처 패턴**: DDD, Hexagonal Architecture 실무 적용
- **🧪 테스트 전략**: 계층별 테스트 작성 및 자동화
- **🚀 DevOps**: 빌드, 배포, 모니터링 자동화

## 🤝 기여하기

1. **이슈 제기**: 버그나 개선사항을 GitHub Issues에 등록
2. **문서 개선**: 오타나 설명 부족 부분 수정
3. **코드 기여**: Fork → Feature Branch → Pull Request

## 📞 지원

- **📖 문서 질문**: [00-INDEX.md](00-INDEX.md)에서 역할별 가이드 참조
- **🐛 빌드 문제**: [07-BUILD_TROUBLESHOOTING.md](07-BUILD_TROUBLESHOOTING.md) 확인
- **💬 논의**: GitHub Discussions 활용

---

**💡 Tip**: 이 README를 북마크하고 다음 문서인 [02-ARCHITECTURE.md](02-ARCHITECTURE.md)로 진행하세요!

**🏁 다음 단계**: → [02-ARCHITECTURE.md](02-ARCHITECTURE.md) - 시스템 아키텍처 이해하기