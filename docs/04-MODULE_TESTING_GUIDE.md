# 모듈 테스트 및 검증 가이드

## 1. 개요

이 문서는 멀티모듈 프로젝트의 각 모듈이 제대로 동작하는지 확인하는 방법을 제공합니다.

## 2. 전체 검증 절차

### 2.1 빠른 검증 스크립트

모든 모듈을 한번에 검증하는 스크립트입니다:

```bash
#!/bin/bash
# scripts/verify-all-modules.sh

echo "=== Multi-Module Project Verification ==="
echo "Starting comprehensive module testing..."
echo ""

# 1. 전체 빌드 테스트
echo "1. 전체 프로젝트 빌드 테스트"
echo "-----------------------------------"
./gradlew clean build
if [ $? -eq 0 ]; then
    echo "✅ 빌드 성공"
else
    echo "❌ 빌드 실패"
    exit 1
fi
echo ""

# 2. 의존성 검증
echo "2. 의존성 검증"
echo "-----------------------------------"
echo "User API 모듈 의존성 확인:"
./gradlew :application:user-api:dependencies --configuration compileClasspath --quiet
echo "✅ 의존성 확인 완료"
echo ""

# 3. 모듈별 테스트
echo "3. 모듈별 테스트"
echo "-----------------------------------"
modules=("common:common-core" "common:common-web" "domain:user-domain" "domain:order-domain" "infrastructure:data-access" "application:user-api" "application:batch-app")

for module in "${modules[@]}"; do
    echo "Testing module: $module"
    ./gradlew :$module:test --quiet
    if [ $? -eq 0 ]; then
        echo "✅ $module 테스트 성공"
    else
        echo "❌ $module 테스트 실패"
    fi
done
echo ""

# 4. 애플리케이션 실행 테스트
echo "4. User API 애플리케이션 실행 테스트"
echo "-----------------------------------"
./gradlew :application:user-api:bootRun &
APP_PID=$!
echo "애플리케이션 시작 중... (PID: $APP_PID)"

# 애플리케이션이 완전히 시작될 때까지 대기
sleep 10

# Health Check
echo "Health Check 테스트:"
HEALTH_RESPONSE=$(curl -s http://localhost:8080/actuator/health)
echo $HEALTH_RESPONSE | grep -q '"status":"UP"'
if [ $? -eq 0 ]; then
    echo "✅ 애플리케이션 정상 시작"
else
    echo "❌ 애플리케이션 시작 실패"
    kill $APP_PID
    exit 1
fi

# API 테스트
echo ""
echo "5. API 엔드포인트 테스트"
echo "-----------------------------------"

# 사용자 생성
echo "사용자 생성 테스트:"
CREATE_RESPONSE=$(curl -s -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "name": "테스트 사용자"
  }')

echo $CREATE_RESPONSE | grep -q '"success":true'
if [ $? -eq 0 ]; then
    echo "✅ 사용자 생성 성공"
    echo "Response: $CREATE_RESPONSE"
else
    echo "❌ 사용자 생성 실패"
    echo "Response: $CREATE_RESPONSE"
fi

# 사용자 조회
echo ""
echo "사용자 조회 테스트:"
GET_RESPONSE=$(curl -s http://localhost:8080/api/users/1)
echo $GET_RESPONSE | grep -q '"email":"test@example.com"'
if [ $? -eq 0 ]; then
    echo "✅ 사용자 조회 성공"
else
    echo "❌ 사용자 조회 실패"
    echo "Response: $GET_RESPONSE"
fi

# 전체 사용자 조회
echo ""
echo "전체 사용자 조회 테스트:"
LIST_RESPONSE=$(curl -s http://localhost:8080/api/users)
echo $LIST_RESPONSE | grep -q '"success":true'
if [ $? -eq 0 ]; then
    echo "✅ 전체 사용자 조회 성공"
else
    echo "❌ 전체 사용자 조회 실패"
fi

# 애플리케이션 종료
echo ""
echo "애플리케이션 종료 중..."
kill $APP_PID
sleep 2

echo ""
echo "🎉 모든 검증이 완료되었습니다!"
```

### 2.2 스크립트 실행

```bash
# 실행 권한 부여
chmod +x scripts/verify-all-modules.sh

# 스크립트 실행
./scripts/verify-all-modules.sh
```

## 3. 개별 모듈 검증

### 3.1 빌드 검증

```bash
# 전체 프로젝트 빌드
./gradlew clean build

# 특정 모듈만 빌드
./gradlew :common:common-core:build
./gradlew :application:user-api:build

# 빌드 결과 확인
find . -name "*.jar" -path "*/build/libs/*"
```

### 3.2 의존성 검증

```bash
# User API 모듈 의존성 트리
./gradlew :application:user-api:dependencies

# 컴파일 의존성만 확인
./gradlew :application:user-api:dependencies --configuration compileClasspath

# 의존성 충돌 확인
./gradlew :application:user-api:dependencyInsight --dependency spring-boot-starter-web
```

### 3.3 테스트 실행

```bash
# 모든 테스트 실행
./gradlew test

# 특정 모듈 테스트
./gradlew :application:user-api:test

# 테스트 결과 상세 출력
./gradlew test --info

# 특정 테스트 클래스 실행
./gradlew :application:user-api:test --tests "*UserControllerTest"
```

## 4. 애플리케이션 실행 검증

### 4.1 User API 실행

```bash
# 애플리케이션 실행
./gradlew :application:user-api:bootRun

# 또는 JAR 파일로 실행
java -jar application/user-api/build/libs/user-api-1.0.0-SNAPSHOT.jar
```

### 4.2 실행 상태 확인

```bash
# Health Check
curl http://localhost:8080/actuator/health

# 애플리케이션 정보
curl http://localhost:8080/actuator/info

# H2 Database Console
open http://localhost:8080/h2-console
```

## 5. API 기능 검증

### 5.1 기본 API 테스트

```bash
# 1. 사용자 생성
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "name": "John Doe"
  }'

# 2. 사용자 조회
curl http://localhost:8080/api/users/1

# 3. 전체 사용자 조회
curl http://localhost:8080/api/users

# 4. 사용자 활성화
curl -X PUT http://localhost:8080/api/users/1/activate
```

### 5.2 에러 케이스 테스트

```bash
# 존재하지 않는 사용자 조회
curl http://localhost:8080/api/users/999

# 잘못된 이메일로 사용자 생성
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "invalid-email",
    "name": "Test User"
  }'

# 중복 이메일로 사용자 생성
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "name": "Another User"
  }'
```

### 5.3 API 테스트 스크립트

```bash
#!/bin/bash
# scripts/test-api-endpoints.sh

BASE_URL="http://localhost:8080/api"

echo "=== API Endpoint Testing ==="

# Test 1: Create User
echo "1. 사용자 생성 테스트"
RESPONSE=$(curl -s -X POST $BASE_URL/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "name": "테스트 사용자"
  }')
echo "Response: $RESPONSE"
echo ""

# Test 2: Get User
echo "2. 사용자 조회 테스트"
RESPONSE=$(curl -s $BASE_URL/users/1)
echo "Response: $RESPONSE"
echo ""

# Test 3: List Users
echo "3. 전체 사용자 조회 테스트"
RESPONSE=$(curl -s $BASE_URL/users)
echo "Response: $RESPONSE"
echo ""

# Test 4: Activate User
echo "4. 사용자 활성화 테스트"
RESPONSE=$(curl -s -X PUT $BASE_URL/users/1/activate)
echo "Response: $RESPONSE"
echo ""

# Test 5: Error Case - User Not Found
echo "5. 에러 케이스 테스트 - 사용자 없음"
RESPONSE=$(curl -s $BASE_URL/users/999)
echo "Response: $RESPONSE"
echo ""

echo "API 테스트 완료!"
```

## 6. 배치 애플리케이션 검증

### 6.1 배치 애플리케이션 실행

```bash
# Batch 애플리케이션 실행
./gradlew :application:batch-app:bootRun

# 특정 Job 실행
java -jar application/batch-app/build/libs/batch-app-1.0.0-SNAPSHOT.jar \
  --spring.batch.job.names=userProcessingJob
```

## 7. 트러블슈팅

### 7.1 일반적인 문제들

#### 빌드 실패
```bash
# Gradle 캐시 클리어
./gradlew clean --refresh-dependencies

# 의존성 다시 다운로드
./gradlew build --refresh-dependencies
```

#### 포트 충돌
```bash
# 포트 사용 확인
lsof -i :8080

# 프로세스 종료
pkill -f "user-api"
```

#### 데이터베이스 연결 문제
```bash
# H2 Console 접속 확인
curl http://localhost:8080/h2-console

# 데이터베이스 URL 확인: jdbc:h2:mem:userdb
# 사용자명: sa
# 비밀번호: (비워둠)
```

### 7.2 로그 확인

```bash
# 애플리케이션 실행 로그
./gradlew :application:user-api:bootRun --info

# 특정 패키지 로그 레벨 변경
# application.yml에서 logging.level.com.example: DEBUG
```

## 8. 성능 검증

### 8.1 간단한 부하 테스트

```bash
# curl을 사용한 반복 테스트
for i in {1..10}; do
  curl -s -X POST http://localhost:8080/api/users \
    -H "Content-Type: application/json" \
    -d "{
      \"email\": \"user$i@example.com\",
      \"name\": \"User $i\"
    }"
done

# 응답 시간 측정
curl -w "@curl-format.txt" -s -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "perf-test@example.com",
    "name": "Performance Test User"
  }'
```

curl-format.txt 파일 내용:
```
     time_namelookup:  %{time_namelookup}s\n
        time_connect:  %{time_connect}s\n
     time_appconnect:  %{time_appconnect}s\n
    time_pretransfer:  %{time_pretransfer}s\n
       time_redirect:  %{time_redirect}s\n
  time_starttransfer:  %{time_starttransfer}s\n
                     ----------\n
          time_total:  %{time_total}s\n
```

## 9. 지속적 통합 (CI) 검증

### 9.1 GitHub Actions 워크플로우

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
    
    - name: Cache Gradle packages
      uses: actions/cache@v3
      with:
        path: |
          ~/.gradle/caches
          ~/.gradle/wrapper
        key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
        restore-keys: |
          ${{ runner.os }}-gradle-
    
    - name: Grant execute permission for gradlew
      run: chmod +x gradlew
    
    - name: Build with Gradle
      run: ./gradlew clean build
    
    - name: Run tests
      run: ./gradlew test
    
    - name: Start User API
      run: |
        ./gradlew :application:user-api:bootRun &
        sleep 10
    
    - name: Test API endpoints
      run: |
        # Health check
        curl -f http://localhost:8080/actuator/health
        
        # API tests
        curl -f -X POST http://localhost:8080/api/users \
          -H "Content-Type: application/json" \
          -d '{"email": "test@example.com", "name": "Test User"}'
        
        curl -f http://localhost:8080/api/users/1
```

---

이 가이드를 통해 각 모듈의 정상 동작을 체계적으로 검증할 수 있습니다.
정기적으로 이 절차를 따라 프로젝트의 안정성을 확인해주세요.