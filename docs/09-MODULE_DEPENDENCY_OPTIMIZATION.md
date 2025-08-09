# 모듈별 Spring 의존성 최적화 가이드

## 1. 개요

각 모듈의 역할과 특성에 맞는 최적화된 Spring 의존성 구성을 제안합니다. 불필요한 의존성을 제거하고, 각 모듈의 목적에 맞는 최소한의 의존성만 포함하여 성능과 유지보수성을 향상시킵니다.

## 2. Common 모듈 최적화

### 2.1 common-core (개선된 버전)

```gradle
dependencies {
    // Core Spring Framework (Spring Boot 없이)
    api 'org.springframework:spring-context'
    api 'org.springframework:spring-beans'
    
    // Validation
    api 'jakarta.validation:jakarta.validation-api'
    implementation 'org.hibernate.validator:hibernate-validator'
    
    // Utilities
    api 'org.apache.commons:commons-lang3'
    api 'com.google.guava:guava'
    
    // JSON Processing
    api 'com.fasterxml.jackson.core:jackson-databind'
    api 'com.fasterxml.jackson.datatype:jackson-datatype-jsr310'
    
    // Logging
    api 'org.slf4j:slf4j-api'
    
    // Optional: Configuration Properties
    compileOnly 'org.springframework.boot:spring-boot-configuration-processor'
}
```

**개선 포인트:**
- Spring Boot Starter 대신 필요한 Spring Core만 사용
- `api` 의존성으로 전이적 의존성 제공
- JSON 처리를 위한 Jackson 추가
- Guava로 유틸리티 기능 강화

### 2.2 common-web (개선된 버전)

```gradle
dependencies {
    api project(':common:common-core')
    
    // Web essentials
    api 'org.springframework:spring-web'
    api 'org.springframework:spring-webmvc'
    
    // HTTP client
    api 'org.springframework:spring-webflux'
    api 'org.springframework.boot:spring-boot-starter-webflux'
    
    // Security (선택적)
    compileOnly 'org.springframework.security:spring-security-web'
    compileOnly 'org.springframework.security:spring-security-config'
    
    // OpenAPI/Swagger
    compileOnly 'org.springdoc:springdoc-openapi-starter-webmvc-ui'
    
    // Servlet API
    compileOnly 'jakarta.servlet:jakarta.servlet-api'
    
    // HTTP client libraries
    implementation 'org.apache.httpcomponents:httpclient'
}
```

**개선 포인트:**
- WebFlux 추가로 비동기 HTTP 클라이언트 지원
- 선택적 보안 의존성으로 유연성 확보
- OpenAPI 문서화 지원
- HTTP 클라이언트 라이브러리 포함

### 2.3 새로운 common 모듈 제안

#### common-cache
```gradle
dependencies {
    api project(':common:common-core')
    
    // Caching
    api 'org.springframework:spring-context-support'
    api 'org.springframework.boot:spring-boot-starter-cache'
    
    // Cache providers
    compileOnly 'org.springframework.boot:spring-boot-starter-data-redis'
    compileOnly 'com.github.ben-manes.caffeine:caffeine'
    compileOnly 'org.ehcache:ehcache'
}
```

#### common-monitoring
```gradle
dependencies {
    api project(':common:common-core')
    
    // Monitoring & Metrics
    api 'org.springframework.boot:spring-boot-starter-actuator'
    api 'io.micrometer:micrometer-core'
    api 'io.micrometer:micrometer-registry-prometheus'
    
    // Tracing
    compileOnly 'io.micrometer:micrometer-tracing'
    compileOnly 'io.micrometer:micrometer-tracing-bridge-brave'
    
    // Health checks
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
}
```

## 3. Domain 모듈 최적화

### 3.1 user-domain (개선된 버전)

```gradle
dependencies {
    api project(':common:common-core')
    
    // Spring Context (DI container)
    api 'org.springframework:spring-context'
    
    // Transaction management
    api 'org.springframework:spring-tx'
    
    // Event publishing
    api 'org.springframework:spring-context'
    
    // Validation
    api 'org.springframework.boot:spring-boot-starter-validation'
    
    // Money handling
    implementation 'org.javamoney:moneta'
    
    // Time handling
    implementation 'org.threeten:threeten-extra'
    
    // Domain events (optional)
    compileOnly 'org.springframework.data:spring-data-commons'
}
```

**개선 포인트:**
- 트랜잭션 관리 명시적 추가
- Money API로 금전 계산 정확성 확보
- 도메인 이벤트 지원
- 시간 처리 라이브러리 추가

### 3.2 order-domain (개선된 버전)

```gradle
dependencies {
    api project(':common:common-core')
    api project(':domain:user-domain')  // User 도메인 참조
    
    // Core Spring
    api 'org.springframework:spring-context'
    api 'org.springframework:spring-tx'
    
    // State machine (주문 상태 관리)
    implementation 'org.springframework.statemachine:spring-statemachine-core'
    
    // Business rules engine (선택적)
    compileOnly 'org.drools:drools-core'
    compileOnly 'org.drools:drools-compiler'
    
    // Money calculations
    implementation 'org.javamoney:moneta'
}
```

**개선 포인트:**
- State Machine으로 복잡한 주문 상태 관리
- 비즈니스 룰 엔진 지원 (선택적)
- User 도메인과의 연관 관계 명시

### 3.3 새로운 도메인 모듈 제안

#### product-domain
```gradle
dependencies {
    api project(':common:common-core')
    
    api 'org.springframework:spring-context'
    api 'org.springframework:spring-tx'
    
    // Search capabilities
    compileOnly 'org.springframework.data:spring-data-elasticsearch'
    
    // Image processing
    compileOnly 'org.springframework.boot:spring-boot-starter-web'
    
    // Price calculations
    implementation 'org.javamoney:moneta'
}
```

## 4. Infrastructure 모듈 최적화

### 4.1 data-access (개선된 버전)

```gradle
dependencies {
    api project(':common:common-core')
    implementation project(':domain:user-domain')
    implementation project(':domain:order-domain')
    
    // JPA & Database
    api 'org.springframework.boot:spring-boot-starter-data-jpa'
    api 'org.springframework.data:spring-data-jpa'
    
    // Query DSL
    implementation 'com.querydsl:querydsl-jpa:5.0.0:jakarta'
    annotationProcessor 'com.querydsl:querydsl-apt:5.0.0:jakarta'
    
    // Database drivers
    runtimeOnly 'com.h2database:h2'
    runtimeOnly 'org.postgresql:postgresql'
    runtimeOnly 'mysql:mysql-connector-java'
    
    // Connection pool
    implementation 'com.zaxxer:HikariCP'
    
    // Database migration
    implementation 'org.flywaydb:flyway-core'
    runtimeOnly 'org.flywaydb:flyway-mysql'
    
    // JSON column support
    implementation 'com.vladmihalcea:hibernate-types-60'
    
    // Audit
    implementation 'org.springframework.data:spring-data-envers'
}
```

**개선 포인트:**
- QueryDSL로 타입 안전한 쿼리 작성
- 여러 데이터베이스 드라이버 지원
- Flyway로 데이터베이스 마이그레이션
- JSON 컬럼 지원
- 엔티티 변경 이력 추적

### 4.2 새로운 Infrastructure 모듈 제안

#### message-infrastructure
```gradle
dependencies {
    api project(':common:common-core')
    implementation project(':domain:user-domain')
    
    // Message brokers
    api 'org.springframework.boot:spring-boot-starter-amqp'  // RabbitMQ
    compileOnly 'org.springframework.kafka:spring-kafka'    // Kafka
    
    // Event sourcing
    compileOnly 'org.axonframework:axon-spring-boot-starter'
    
    // Message serialization
    implementation 'org.springframework.boot:spring-boot-starter-json'
}
```

#### cache-infrastructure
```gradle
dependencies {
    api project(':common:common-core')
    api project(':common:common-cache')
    
    // Redis
    api 'org.springframework.boot:spring-boot-starter-data-redis'
    implementation 'org.redisson:redisson-spring-boot-starter'
    
    // Local cache
    implementation 'com.github.ben-manes.caffeine:caffeine'
    
    // Cache serialization
    implementation 'com.fasterxml.jackson.core:jackson-databind'
}
```

#### search-infrastructure
```gradle
dependencies {
    api project(':common:common-core')
    implementation project(':domain:product-domain')
    
    // Elasticsearch
    api 'org.springframework.boot:spring-boot-starter-data-elasticsearch'
    
    // Solr (alternative)
    compileOnly 'org.springframework.data:spring-data-solr'
    
    // Full-text search
    implementation 'org.hibernate.search:hibernate-search-mapper-orm'
    implementation 'org.hibernate.search:hibernate-search-backend-elasticsearch'
}
```

## 5. Application 모듈 최적화

### 5.1 user-api (개선된 버전)

```gradle
dependencies {
    // Common modules
    implementation project(':common:common-web')
    implementation project(':common:common-cache')
    implementation project(':common:common-monitoring')
    
    // Domain modules
    implementation project(':domain:user-domain')
    implementation project(':domain:order-domain')
    
    // Infrastructure modules
    implementation project(':infrastructure:data-access')
    implementation project(':infrastructure:cache-infrastructure')
    
    // Web stack
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    
    // API documentation
    implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui'
    
    // Rate limiting
    implementation 'com.github.vladimir-bukhtoyarov:bucket4j-core'
    implementation 'com.github.vladimir-bukhtoyarov:bucket4j-redis'
    
    // Database
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    runtimeOnly 'com.h2database:h2'
    
    // Monitoring
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
    implementation 'io.micrometer:micrometer-registry-prometheus'
    
    // Development tools
    developmentOnly 'org.springframework.boot:spring-boot-devtools'
    
    // Testing
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.springframework.security:spring-security-test'
    testImplementation 'org.testcontainers:junit-jupiter'
    testImplementation 'org.testcontainers:postgresql'
}
```

**개선 포인트:**
- 보안 및 인증 기능 추가
- API 문서화 (OpenAPI/Swagger)
- 속도 제한 기능
- 모니터링 및 메트릭
- 통합 테스트 지원

### 5.2 batch-app (개선된 버전)

```gradle
dependencies {
    // Common modules
    implementation project(':common:common-core')
    implementation project(':common:common-monitoring')
    
    // Domain modules
    implementation project(':domain:user-domain')
    implementation project(':domain:order-domain')
    
    // Infrastructure modules
    implementation project(':infrastructure:data-access')
    implementation project(':infrastructure:message-infrastructure')
    
    // Batch processing
    implementation 'org.springframework.boot:spring-boot-starter-batch'
    
    // Scheduling
    implementation 'org.springframework.boot:spring-boot-starter-quartz'
    
    // File processing
    implementation 'org.springframework.batch:spring-batch-integration'
    implementation 'org.apache.poi:poi-ooxml'  // Excel files
    
    // Email notifications
    implementation 'org.springframework.boot:spring-boot-starter-mail'
    
    // Database
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    runtimeOnly 'com.h2database:h2'
    
    // Monitoring
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
    
    // Testing
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.springframework.batch:spring-batch-test'
}
```

**개선 포인트:**
- Quartz 스케줄러로 고급 스케줄링
- 파일 처리 기능 (Excel, CSV)
- 이메일 알림 기능
- 배치 모니터링 강화

### 5.3 새로운 Application 모듈 제안

#### admin-api
```gradle
dependencies {
    // Common modules
    implementation project(':common:common-web')
    implementation project(':common:common-monitoring')
    
    // All domain modules (관리 목적)
    implementation project(':domain:user-domain')
    implementation project(':domain:order-domain')
    implementation project(':domain:product-domain')
    
    // Infrastructure modules
    implementation project(':infrastructure:data-access')
    implementation project(':infrastructure:search-infrastructure')
    
    // Admin-specific
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    implementation 'org.springframework.boot:spring-boot-admin-starter-server'
    
    // File upload
    implementation 'org.springframework.boot:spring-boot-starter-web'
    
    // Excel export
    implementation 'org.apache.poi:poi-ooxml'
    
    // PDF generation
    implementation 'com.itextpdf:itext7-core'
}
```

#### notification-service
```gradle
dependencies {
    // Common modules
    implementation project(':common:common-core')
    
    // Domain modules
    implementation project(':domain:user-domain')
    
    // Infrastructure modules
    implementation project(':infrastructure:message-infrastructure')
    
    // Notification channels
    implementation 'org.springframework.boot:spring-boot-starter-mail'
    implementation 'org.springframework.boot:spring-boot-starter-web'  // Push notifications
    
    // Message processing
    implementation 'org.springframework.boot:spring-boot-starter-amqp'
    
    // Template engine
    implementation 'org.springframework.boot:spring-boot-starter-thymeleaf'
    
    // SMS (선택적)
    compileOnly 'com.twilio.sdk:twilio'
}
```

## 6. 프로파일별 의존성 관리

### 6.1 개발 환경 (dev)

```gradle
configurations {
    developmentOnly
    runtimeClasspath {
        extendsFrom developmentOnly
    }
}

dependencies {
    // 개발 도구
    developmentOnly 'org.springframework.boot:spring-boot-devtools'
    developmentOnly 'org.springframework.boot:spring-boot-docker-compose'
    
    // 개발용 데이터베이스
    developmentOnly 'com.h2database:h2'
    
    // 프로파일링 도구
    developmentOnly 'org.springframework.boot:spring-boot-starter-actuator'
}
```

### 6.2 테스트 환경 (test)

```gradle
dependencies {
    // 테스트 프레임워크
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.springframework.batch:spring-batch-test'
    testImplementation 'org.springframework.security:spring-security-test'
    
    // Test containers
    testImplementation 'org.testcontainers:junit-jupiter'
    testImplementation 'org.testcontainers:postgresql'
    testImplementation 'org.testcontainers:redis'
    testImplementation 'org.testcontainers:elasticsearch'
    
    // Mock servers
    testImplementation 'com.github.tomakehurst:wiremock-jre8'
    
    // Test data builders
    testImplementation 'com.navercorp.fixturemonkey:fixture-monkey-starter'
}
```

### 6.3 운영 환경 (prod)

```gradle
dependencies {
    // 운영 데이터베이스
    runtimeOnly 'org.postgresql:postgresql'
    
    // 모니터링
    implementation 'io.micrometer:micrometer-registry-prometheus'
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
    
    // APM
    runtimeOnly 'io.opentelemetry:opentelemetry-api'
    runtimeOnly 'io.opentelemetry:opentelemetry-exporter-jaeger'
    
    // 로그 수집
    runtimeOnly 'net.logstash.logback:logstash-logback-encoder'
}
```

## 7. 의존성 버전 관리 최적화

### 7.1 버전 카탈로그 (gradle/libs.versions.toml)

```toml
[versions]
spring-boot = "3.2.2"
spring-framework = "6.1.3"
querydsl = "5.0.0"
testcontainers = "1.19.3"
mapstruct = "1.5.5.Final"

[libraries]
# Spring
spring-boot-starter-web = { module = "org.springframework.boot:spring-boot-starter-web", version.ref = "spring-boot" }
spring-boot-starter-data-jpa = { module = "org.springframework.boot:spring-boot-starter-data-jpa", version.ref = "spring-boot" }
spring-boot-starter-batch = { module = "org.springframework.boot:spring-boot-starter-batch", version.ref = "spring-boot" }

# QueryDSL
querydsl-jpa = { module = "com.querydsl:querydsl-jpa", version.ref = "querydsl" }
querydsl-apt = { module = "com.querydsl:querydsl-apt", version.ref = "querydsl" }

# Testing
testcontainers-junit = { module = "org.testcontainers:junit-jupiter", version.ref = "testcontainers" }
testcontainers-postgresql = { module = "org.testcontainers:postgresql", version.ref = "testcontainers" }

[bundles]
spring-web-stack = ["spring-boot-starter-web", "spring-boot-starter-validation", "spring-boot-starter-actuator"]
querydsl = ["querydsl-jpa", "querydsl-apt"]
testcontainers = ["testcontainers-junit", "testcontainers-postgresql"]
```

### 7.2 모듈별 번들 사용

```gradle
// user-api/build.gradle
dependencies {
    implementation libs.bundles.spring.web.stack
    implementation libs.bundles.querydsl
    testImplementation libs.bundles.testcontainers
}
```

## 8. 성능 및 보안 최적화

### 8.1 스타터 의존성 최적화

```gradle
dependencies {
    // 전체 스타터 대신 필요한 모듈만
    implementation 'org.springframework:spring-webmvc'
    implementation 'org.springframework.boot:spring-boot-autoconfigure'
    
    // 불필요한 자동 설정 제외
    implementation('org.springframework.boot:spring-boot-starter-web') {
        exclude group: 'org.springframework.boot', module: 'spring-boot-starter-tomcat'
    }
    implementation 'org.springframework.boot:spring-boot-starter-undertow'
}
```

### 8.2 보안 강화 의존성

```gradle
dependencies {
    // OAuth 2.0 / JWT
    implementation 'org.springframework.boot:spring-boot-starter-oauth2-resource-server'
    implementation 'org.springframework.boot:spring-boot-starter-oauth2-client'
    
    // Rate limiting
    implementation 'com.github.vladimir-bukhtoyarov:bucket4j-core'
    
    // Security headers
    implementation 'org.springframework.security:spring-security-web'
    
    // CORS
    implementation 'org.springframework:spring-web'
}
```

---

이 최적화된 의존성 구성을 통해 각 모듈의 목적에 맞는 최적의 성능과 기능을 제공할 수 있습니다.
필요에 따라 선택적 의존성을 활성화하여 유연하게 확장 가능합니다.