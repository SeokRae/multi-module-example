# API 명세서

## 1. 개요

### 1.1 API 정보
- **Base URL**: `http://localhost:8080/api`
- **API Version**: v1
- **Content Type**: `application/json`
- **Character Encoding**: UTF-8

### 1.2 응답 형식
모든 API는 다음과 같은 표준 응답 형식을 사용합니다.

#### 성공 응답
```json
{
  "success": true,
  "data": {},
  "message": "요청이 성공적으로 처리되었습니다",
  "code": null
}
```

#### 오류 응답
```json
{
  "success": false,
  "data": null,
  "message": "오류 메시지",
  "code": "ERROR_CODE"
}
```

### 1.3 HTTP 상태 코드
| 상태 코드 | 설명 |
|---------|------|
| 200 | OK - 요청 성공 |
| 201 | Created - 리소스 생성 성공 |
| 400 | Bad Request - 잘못된 요청 |
| 404 | Not Found - 리소스를 찾을 수 없음 |
| 500 | Internal Server Error - 서버 내부 오류 |

### 1.4 에러 코드
| 에러 코드 | 설명 |
|----------|------|
| COMMON_001 | 잘못된 입력값입니다 |
| COMMON_002 | 시스템 에러가 발생했습니다 |
| USER_001 | 사용자를 찾을 수 없습니다 |
| USER_002 | 이미 존재하는 사용자입니다 |
| VALIDATION_ERROR | 입력값 검증 실패 |

## 2. 사용자 API (User API)

### 2.1 사용자 생성

#### 기본 정보
- **URL**: `/api/users`
- **Method**: `POST`
- **Description**: 새로운 사용자를 생성합니다

#### 요청
**Headers**
```
Content-Type: application/json
```

**Request Body**
```json
{
  "email": "user@example.com",
  "name": "홍길동"
}
```

**Request Body 스키마**
| 필드 | 타입 | 필수 | 검증 규칙 | 설명 |
|------|------|------|---------|------|
| email | string | ✓ | 이메일 형식 | 사용자 이메일 |
| name | string | ✓ | 1-50자 | 사용자 이름 |

#### 응답

**성공 응답 (200 OK)**
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

**오류 응답 (400 Bad Request)**
```json
{
  "success": false,
  "data": null,
  "message": "이미 존재하는 사용자입니다",
  "code": "USER_002"
}
```

#### cURL 예시
```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "name": "홍길동"
  }'
```

### 2.2 사용자 조회

#### 기본 정보
- **URL**: `/api/users/{id}`
- **Method**: `GET`
- **Description**: ID로 특정 사용자를 조회합니다

#### 요청
**Path Parameters**
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| id | long | ✓ | 사용자 ID |

#### 응답

**성공 응답 (200 OK)**
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
  "message": "요청이 성공적으로 처리되었습니다",
  "code": null
}
```

**오류 응답 (404 Not Found)**
```json
{
  "success": false,
  "data": null,
  "message": "사용자를 찾을 수 없습니다",
  "code": "USER_001"
}
```

#### cURL 예시
```bash
curl http://localhost:8080/api/users/1
```

### 2.3 전체 사용자 조회

#### 기본 정보
- **URL**: `/api/users`
- **Method**: `GET`
- **Description**: 모든 사용자를 조회합니다

#### 요청
파라미터 없음

#### 응답

**성공 응답 (200 OK)**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "email": "user1@example.com",
      "name": "홍길동",
      "status": "ACTIVE",
      "createdAt": "2024-01-01T10:00:00",
      "updatedAt": "2024-01-01T10:00:00"
    },
    {
      "id": 2,
      "email": "user2@example.com",
      "name": "김철수",
      "status": "INACTIVE",
      "createdAt": "2024-01-01T11:00:00",
      "updatedAt": "2024-01-01T11:00:00"
    }
  ],
  "message": "요청이 성공적으로 처리되었습니다",
  "code": null
}
```

#### cURL 예시
```bash
curl http://localhost:8080/api/users
```

### 2.4 사용자 활성화

#### 기본 정보
- **URL**: `/api/users/{id}/activate`
- **Method**: `PUT`
- **Description**: 사용자를 활성화 상태로 변경합니다

#### 요청
**Path Parameters**
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| id | long | ✓ | 사용자 ID |

#### 응답

**성공 응답 (200 OK)**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "status": "ACTIVE",
    "createdAt": "2024-01-01T10:00:00",
    "updatedAt": "2024-01-01T12:00:00"
  },
  "message": "사용자가 활성화되었습니다",
  "code": null
}
```

#### cURL 예시
```bash
curl -X PUT http://localhost:8080/api/users/1/activate
```

## 3. 데이터 모델

### 3.1 User (사용자)
```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "홍길동",
  "status": "ACTIVE",
  "createdAt": "2024-01-01T10:00:00",
  "updatedAt": "2024-01-01T10:00:00"
}
```

**필드 설명**
| 필드 | 타입 | 설명 | 값 범위 |
|------|------|------|--------|
| id | long | 사용자 고유 ID | 1 이상의 정수 |
| email | string | 이메일 주소 | 유효한 이메일 형식 |
| name | string | 사용자 이름 | 1-50자 |
| status | enum | 사용자 상태 | ACTIVE, INACTIVE, SUSPENDED |
| createdAt | datetime | 생성일시 | ISO 8601 형식 |
| updatedAt | datetime | 수정일시 | ISO 8601 형식 |

### 3.2 UserStatus (사용자 상태)
| 값 | 설명 |
|----|------|
| ACTIVE | 활성 |
| INACTIVE | 비활성 |
| SUSPENDED | 정지 |

## 4. 활용 예시

### 4.1 사용자 관리 시나리오

#### 1단계: 사용자 생성
```bash
# 새 사용자 생성
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "name": "John Doe"
  }'
```

#### 2단계: 사용자 조회
```bash
# 생성된 사용자 확인
curl http://localhost:8080/api/users/1
```

#### 3단계: 전체 사용자 목록 조회
```bash
# 모든 사용자 조회
curl http://localhost:8080/api/users
```

#### 4단계: 사용자 활성화
```bash
# 사용자 활성화
curl -X PUT http://localhost:8080/api/users/1/activate
```

### 4.2 에러 처리 예시

#### 중복 이메일로 사용자 생성 시도
```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "existing@example.com",
    "name": "Duplicate User"
  }'

# 응답
{
  "success": false,
  "data": null,
  "message": "이미 존재하는 사용자입니다",
  "code": "USER_002"
}
```

#### 존재하지 않는 사용자 조회
```bash
curl http://localhost:8080/api/users/999

# 응답
{
  "success": false,
  "data": null,
  "message": "사용자를 찾을 수 없습니다",
  "code": "USER_001"
}
```

#### 잘못된 입력값 검증
```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "invalid-email",
    "name": ""
  }'

# 응답
{
  "success": false,
  "data": {
    "email": "유효한 이메일 형식이 아닙니다",
    "name": "이름은 필수입니다"
  },
  "message": "입력값 검증 실패",
  "code": "VALIDATION_ERROR"
}
```

## 5. 테스트

### 5.1 API 테스트 스크립트
```bash
#!/bin/bash

BASE_URL="http://localhost:8080/api"
echo "=== User API Integration Test ==="

# 1. 사용자 생성 테스트
echo "1. 사용자 생성 테스트"
CREATE_RESPONSE=$(curl -s -X POST $BASE_URL/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "name": "테스트 사용자"
  }')
echo "Response: $CREATE_RESPONSE"

# 2. 사용자 조회 테스트
echo -e "\n2. 사용자 조회 테스트"
GET_RESPONSE=$(curl -s $BASE_URL/users/1)
echo "Response: $GET_RESPONSE"

# 3. 전체 사용자 조회 테스트
echo -e "\n3. 전체 사용자 조회 테스트"
LIST_RESPONSE=$(curl -s $BASE_URL/users)
echo "Response: $LIST_RESPONSE"

# 4. 사용자 활성화 테스트
echo -e "\n4. 사용자 활성화 테스트"
ACTIVATE_RESPONSE=$(curl -s -X PUT $BASE_URL/users/1/activate)
echo "Response: $ACTIVATE_RESPONSE"

# 5. 에러 케이스 테스트 (존재하지 않는 사용자)
echo -e "\n5. 에러 케이스 테스트"
ERROR_RESPONSE=$(curl -s $BASE_URL/users/999)
echo "Response: $ERROR_RESPONSE"
```

### 5.2 Postman Collection
```json
{
  "info": {
    "name": "Multi-Module User API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Create User",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"email\": \"test@example.com\",\n  \"name\": \"테스트 사용자\"\n}"
        },
        "url": {
          "raw": "{{baseUrl}}/api/users",
          "host": ["{{baseUrl}}"],
          "path": ["api", "users"]
        }
      }
    },
    {
      "name": "Get User",
      "request": {
        "method": "GET",
        "url": {
          "raw": "{{baseUrl}}/api/users/1",
          "host": ["{{baseUrl}}"],
          "path": ["api", "users", "1"]
        }
      }
    }
  ],
  "variable": [
    {
      "key": "baseUrl",
      "value": "http://localhost:8080"
    }
  ]
}
```

## 6. 향후 확장 계획

### 6.1 예정된 API
- **사용자 수정**: `PUT /api/users/{id}`
- **사용자 삭제**: `DELETE /api/users/{id}`
- **사용자 검색**: `GET /api/users/search`
- **페이징 지원**: `GET /api/users?page=0&size=10`

### 6.2 인증/인가 추가
- JWT 토큰 기반 인증
- Bearer 토큰 헤더 추가
- 권한별 API 접근 제어

### 6.3 추가 기능
- API 버저닝 (v2, v3)
- Rate Limiting
- API 문서 자동화 (Swagger/OpenAPI)
- GraphQL 지원

---

이 API 명세서는 현재 구현된 기능을 기준으로 작성되었으며, 
개발 진행에 따라 지속적으로 업데이트될 예정입니다.