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
sleep 15

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