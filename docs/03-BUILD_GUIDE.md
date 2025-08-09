# 빌드 및 실행 가이드

## 1. 개발 환경 설정

### 1.1 필수 요구사항
- **Java**: 17 이상 (Oracle JDK 또는 OpenJDK)
- **IDE**: IntelliJ IDEA 2023.1 이상 (권장)
- **Git**: 2.30 이상

### 1.2 권장 도구
- **Gradle**: 8.5 (Wrapper 포함되어 있음)
- **Docker**: 컨테이너 환경 테스트용 (선택사항)

### 1.3 개발 환경 확인
```bash
# Java 버전 확인
java -version

# Gradle 버전 확인 (프로젝트 내에서)
./gradlew --version

# Git 버전 확인
git --version
```

## 2. 프로젝트 설정

### 2.1 프로젝트 클론
```bash
git clone <repository-url>
cd multi-module-example-1
```

### 2.2 IDE 설정

#### IntelliJ IDEA
1. **프로젝트 열기**
   - `File` → `Open` → 프로젝트 루트 디렉터리 선택
   - Gradle 프로젝트로 인식되면 자동으로 설정됨

2. **Java SDK 설정**
   - `File` → `Project Structure` → `Project`
   - Project SDK: Java 17 설정
   - Language level: 17 설정

3. **Gradle 설정**
   - `File` → `Settings` → `Build, Execution, Deployment` → `Build Tools` → `Gradle`
   - Use Gradle from: 'gradle-wrapper.properties' file 선택
   - Gradle JVM: Project SDK 사용

### 2.3 프로젝트 구조 확인
```bash
# 프로젝트 구조 출력
tree -I 'build|.gradle|.idea'

# 또는 
ls -la
```

## 3. 빌드

### 3.1 전체 프로젝트 빌드
```bash
# 클린 빌드 (권장)
./gradlew clean build

# 빠른 빌드 (테스트 제외)
./gradlew clean build -x test

# 의존성 다운로드 확인
./gradlew dependencies
```

### 3.2 모듈별 빌드
```bash
# 특정 모듈만 빌드
./gradlew :common:common-core:build
./gradlew :domain:user-domain:build
./gradlew :application:user-api:build

# 여러 모듈 동시 빌드
./gradlew :common:common-core:build :common:common-web:build
```

### 3.3 빌드 결과 확인
```bash
# 빌드된 JAR 파일 확인
find . -name "*.jar" -path "*/build/libs/*"

# 각 모듈 빌드 디렉터리
ls -la */build/libs/
ls -la */*/build/libs/
```

## 4. 테스트

### 4.1 전체 테스트 실행
```bash
# 모든 테스트 실행
./gradlew test

# 테스트 결과 리포트 생성
./gradlew test jacocoTestReport
```

### 4.2 모듈별 테스트
```bash
# 특정 모듈 테스트
./gradlew :application:user-api:test
./gradlew :domain:user-domain:test

# 특정 테스트 클래스 실행
./gradlew :application:user-api:test --tests "*.UserControllerTest"

# 특정 테스트 메서드 실행
./gradlew :application:user-api:test --tests "*.UserControllerTest.createUser_Success"
```

### 4.3 테스트 리포트 확인
```bash
# 테스트 리포트 위치
open application/user-api/build/reports/tests/test/index.html

# 코버리지 리포트 (Jacoco 설정 시)
open application/user-api/build/reports/jacoco/test/html/index.html
```

## 5. 애플리케이션 실행

### 5.1 User API 실행

#### 개발 환경
```bash
# Gradle을 통한 실행
./gradlew :application:user-api:bootRun

# 또는 JAR 파일 실행
java -jar application/user-api/build/libs/user-api-1.0.0-SNAPSHOT.jar

# 프로필 지정 실행
./gradlew :application:user-api:bootRun --args='--spring.profiles.active=dev'
```

#### 애플리케이션 상태 확인
```bash
# Health Check
curl http://localhost:8080/actuator/health

# 애플리케이션 정보
curl http://localhost:8080/actuator/info

# H2 Database Console 접속
open http://localhost:8080/h2-console
```

### 5.2 Batch Application 실행
```bash
# Batch 애플리케이션 실행
./gradlew :application:batch-app:bootRun

# 특정 Job 실행
java -jar application/batch-app/build/libs/batch-app-1.0.0-SNAPSHOT.jar \
  --spring.batch.job.names=userProcessingJob
```

### 5.3 다중 애플리케이션 실행
```bash
# Terminal 1: User API
./gradlew :application:user-api:bootRun

# Terminal 2: Batch App  
./gradlew :application:batch-app:bootRun
```

## 6. 데이터베이스

### 6.1 H2 Database 설정
```yaml
# application.yml
spring:
  datasource:
    url: jdbc:h2:mem:userdb
    driver-class-name: org.h2.Driver
    username: sa
    password: 
  
  h2:
    console:
      enabled: true
      path: /h2-console
```

### 6.2 Database 접속
- **URL**: http://localhost:8080/h2-console
- **JDBC URL**: `jdbc:h2:mem:userdb`
- **User Name**: `sa`
- **Password**: (비워둠)

### 6.3 초기 데이터 설정
```sql
-- application/user-api/src/main/resources/data.sql
INSERT INTO users (email, name, status, created_at, updated_at) 
VALUES ('admin@example.com', '관리자', 'ACTIVE', NOW(), NOW());

INSERT INTO users (email, name, status, created_at, updated_at) 
VALUES ('user@example.com', '일반사용자', 'ACTIVE', NOW(), NOW());
```

## 7. API 테스트

### 7.1 기본 API 테스트
```bash
# 사용자 생성
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "name": "테스트 사용자"
  }'

# 사용자 조회
curl http://localhost:8080/api/users/1

# 전체 사용자 조회
curl http://localhost:8080/api/users

# 사용자 활성화
curl -X PUT http://localhost:8080/api/users/1/activate
```

### 7.2 API 테스트 스크립트
```bash
#!/bin/bash
# test-api.sh

BASE_URL="http://localhost:8080/api"

echo "=== User API Test ==="

# 1. 사용자 생성 테스트
echo "1. Creating user..."
USER_RESPONSE=$(curl -s -X POST $BASE_URL/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "name": "테스트 사용자"
  }')
echo $USER_RESPONSE | jq .

# 2. 사용자 조회 테스트  
echo "2. Getting user..."
curl -s $BASE_URL/users/1 | jq .

# 3. 전체 사용자 조회
echo "3. Getting all users..."
curl -s $BASE_URL/users | jq .
```

## 8. 배포

### 8.1 Production 빌드
```bash
# Production용 빌드
./gradlew clean build -Pprofile=prod

# 최적화된 JAR 생성
./gradlew :application:user-api:bootJar
```

### 8.2 Docker 컨테이너 생성
```dockerfile
# Dockerfile
FROM openjdk:17-jre-slim

WORKDIR /app
COPY application/user-api/build/libs/user-api-1.0.0-SNAPSHOT.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

```bash
# Docker 빌드 및 실행
docker build -t multi-module-user-api .
docker run -p 8080:8080 multi-module-user-api
```

### 8.3 Docker Compose
```yaml
# docker-compose.yml
version: '3.8'

services:
  user-api:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/userdb
    depends_on:
      - mysql

  mysql:
    image: mysql:8.0
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_DATABASE=userdb
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```

## 9. 트러블슈팅

### 9.1 일반적인 문제

#### 빌드 실패
```bash
# Gradle 캐시 정리
./gradlew clean --refresh-dependencies

# Gradle Wrapper 재생성
gradle wrapper --gradle-version 8.5
```

#### 포트 충돌
```bash
# 포트 사용 중인 프로세스 확인
lsof -i :8080
netstat -tulpn | grep :8080

# 프로세스 종료
kill -9 <PID>
```

#### 메모리 부족
```bash
# Gradle에 메모리 할당
export GRADLE_OPTS="-Xmx2g -XX:MaxMetaspaceSize=512m"

# JVM 메모리 설정
java -Xmx1g -Xms512m -jar app.jar
```

### 9.2 로그 확인
```bash
# 애플리케이션 로그
tail -f logs/application.log

# Gradle 빌드 로그
./gradlew build --info

# 상세 디버그 로그
./gradlew build --debug
```

### 9.3 의존성 문제
```bash
# 의존성 트리 확인
./gradlew dependencies

# 의존성 충돌 확인
./gradlew dependencyInsight --dependency spring-boot-starter-web

# 의존성 업데이트 확인
./gradlew dependencyUpdates
```

## 10. 성능 최적화

### 10.1 빌드 최적화
```bash
# 병렬 빌드 활성화
echo "org.gradle.parallel=true" >> gradle.properties
echo "org.gradle.daemon=true" >> gradle.properties
echo "org.gradle.caching=true" >> gradle.properties

# 빌드 캐시 사용
./gradlew build --build-cache
```

### 10.2 애플리케이션 최적화
```yaml
# application-prod.yml
spring:
  jpa:
    hibernate:
      ddl-auto: none
    show-sql: false
    properties:
      hibernate:
        jdbc:
          batch_size: 20
        order_inserts: true
        order_updates: true

server:
  tomcat:
    threads:
      max: 200
      min-spare: 10
```

---

이 가이드를 참조하여 프로젝트를 효율적으로 빌드하고 실행할 수 있습니다.
문제가 발생하면 트러블슈팅 섹션을 확인하거나 이슈를 등록해 주세요.