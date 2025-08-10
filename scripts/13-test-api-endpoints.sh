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

# Test 6: Error Case - Invalid Email
echo "6. 에러 케이스 테스트 - 잘못된 이메일"
RESPONSE=$(curl -s -X POST $BASE_URL/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "invalid-email",
    "name": "Invalid User"
  }')
echo "Response: $RESPONSE"
echo ""

# Test 7: Error Case - Duplicate Email
echo "7. 에러 케이스 테스트 - 중복 이메일"
RESPONSE=$(curl -s -X POST $BASE_URL/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "name": "Duplicate User"
  }')
echo "Response: $RESPONSE"
echo ""

echo "API 테스트 완료!"