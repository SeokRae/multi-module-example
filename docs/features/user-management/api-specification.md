# 👤 User Management API 명세서

> 사용자 관리 기능의 REST API 상세 명세서입니다.

## 📌 기본 정보

- **Base URL**: `/api/v1/users`
- **Content-Type**: `application/json`
- **Authorization**: `Bearer <JWT_TOKEN>` (로그인 후)

## 🔑 인증

### POST /api/v1/auth/login
사용자 로그인

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "password123!"
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9...",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "홍길동",
      "role": "USER",
      "status": "ACTIVE",
      "createdAt": "2025-01-10T10:00:00Z"
    }
  }
}
```

**Error Responses**:
```json
// 401 Unauthorized
{
  "success": false,
  "error": {
    "code": "USER_005",
    "message": "이메일 또는 비밀번호가 올바르지 않습니다"
  }
}

// 423 Locked
{
  "success": false,
  "error": {
    "code": "USER_006", 
    "message": "계정이 잠겨있습니다"
  }
}
```

---

## 👤 사용자 관리

### POST /api/v1/users
사용자 등록 (회원가입)

**Request Body**:
```json
{
  "email": "newuser@example.com",
  "password": "newPassword123!",
  "name": "김철수",
  "phone": "010-1234-5678"
}
```

**Response (201 Created)**:
```json
{
  "success": true,
  "data": {
    "id": 2,
    "email": "newuser@example.com",
    "name": "김철수", 
    "phone": "010-1234-5678",
    "role": "USER",
    "status": "ACTIVE",
    "createdAt": "2025-01-10T10:30:00Z",
    "updatedAt": "2025-01-10T10:30:00Z"
  }
}
```

**Error Responses**:
```json
// 400 Bad Request - 이메일 중복
{
  "success": false,
  "error": {
    "code": "USER_002",
    "message": "이미 존재하는 사용자입니다"
  }
}

// 400 Bad Request - 비밀번호 정책 위반
{
  "success": false,
  "error": {
    "code": "USER_004", 
    "message": "비밀번호는 8자 이상이어야 하며 영문, 숫자, 특수문자를 포함해야 합니다"
  }
}

// 400 Bad Request - 유효성 검증 실패
{
  "success": false,
  "error": {
    "code": "COMMON_001",
    "message": "잘못된 입력값입니다",
    "details": [
      {
        "field": "email",
        "message": "올바르지 않은 이메일 형식입니다"
      },
      {
        "field": "name", 
        "message": "이름은 필수입니다"
      }
    ]
  }
}
```

### GET /api/v1/users/me
현재 로그인한 사용자 정보 조회

**Headers**: 
```
Authorization: Bearer <JWT_TOKEN>
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "phone": "010-9876-5432",
    "role": "USER", 
    "status": "ACTIVE",
    "createdAt": "2025-01-10T10:00:00Z",
    "updatedAt": "2025-01-10T10:15:00Z"
  }
}
```

### PUT /api/v1/users/me
현재 로그인한 사용자 정보 수정

**Headers**: 
```
Authorization: Bearer <JWT_TOKEN>
```

**Request Body**:
```json
{
  "name": "홍길동(수정됨)",
  "phone": "010-1111-2222"
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "홍길동(수정됨)",
    "phone": "010-1111-2222", 
    "role": "USER",
    "status": "ACTIVE",
    "createdAt": "2025-01-10T10:00:00Z",
    "updatedAt": "2025-01-10T11:00:00Z"
  }
}
```

### GET /api/v1/users/{userId}
특정 사용자 정보 조회 (관리자 전용)

**Headers**: 
```
Authorization: Bearer <ADMIN_JWT_TOKEN>
```

**Path Parameters**:
- `userId` (Long): 사용자 ID

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "id": 2,
    "email": "target@example.com", 
    "name": "대상사용자",
    "phone": "010-3333-4444",
    "role": "USER",
    "status": "ACTIVE", 
    "createdAt": "2025-01-10T09:00:00Z",
    "updatedAt": "2025-01-10T09:30:00Z"
  }
}
```

**Error Responses**:
```json
// 403 Forbidden - 권한 없음
{
  "success": false,
  "error": {
    "code": "USER_007",
    "message": "접근 권한이 없습니다"  
  }
}

// 404 Not Found - 사용자 없음
{
  "success": false,
  "error": {
    "code": "USER_001", 
    "message": "사용자를 찾을 수 없습니다"
  }
}
```

### GET /api/v1/users
사용자 목록 조회 (관리자 전용, 페이징)

**Headers**: 
```
Authorization: Bearer <ADMIN_JWT_TOKEN>
```

**Query Parameters**:
- `page` (Integer, optional): 페이지 번호 (기본값: 0)
- `size` (Integer, optional): 페이지 크기 (기본값: 20, 최대값: 100)  
- `sort` (String, optional): 정렬 기준 (기본값: createdAt,desc)
- `status` (String, optional): 상태 필터 (ACTIVE, INACTIVE, SUSPENDED)
- `role` (String, optional): 역할 필터 (USER, ADMIN, PRODUCT_ADMIN, ORDER_ADMIN)
- `search` (String, optional): 이름 또는 이메일 검색

**Example Request**:
```
GET /api/v1/users?page=0&size=10&sort=createdAt,desc&status=ACTIVE&search=김
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "email": "user1@example.com",
        "name": "김철수", 
        "role": "USER",
        "status": "ACTIVE",
        "createdAt": "2025-01-10T10:00:00Z"
      },
      {
        "id": 2, 
        "email": "user2@example.com",
        "name": "김영희",
        "role": "USER", 
        "status": "ACTIVE",
        "createdAt": "2025-01-10T09:30:00Z"
      }
    ],
    "pageable": {
      "page": 0,
      "size": 10,
      "sort": "createdAt,desc"
    },
    "totalElements": 25,
    "totalPages": 3,
    "first": true,
    "last": false,
    "numberOfElements": 10
  }
}
```

### PUT /api/v1/users/{userId}/status
사용자 상태 변경 (관리자 전용)

**Headers**: 
```
Authorization: Bearer <ADMIN_JWT_TOKEN>
```

**Path Parameters**:
- `userId` (Long): 사용자 ID

**Request Body**:
```json
{
  "status": "SUSPENDED"
}
```

**Response (200 OK)**:
```json  
{
  "success": true,
  "data": {
    "id": 2,
    "email": "user@example.com",
    "name": "대상사용자",
    "role": "USER",
    "status": "SUSPENDED",
    "updatedAt": "2025-01-10T11:30:00Z"
  }
}
```

### DELETE /api/v1/users/me
계정 탈퇴 (본인)

**Headers**: 
```
Authorization: Bearer <JWT_TOKEN>
```

**Request Body**:
```json
{
  "password": "currentPassword123!"
}
```

**Response (204 No Content)**:
```
(본문 없음)
```

---

## 📊 공통 응답 형식

### 성공 응답
```json
{
  "success": true,
  "data": { /* 응답 데이터 */ },
  "timestamp": "2025-01-10T12:00:00Z"
}
```

### 에러 응답  
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "에러 메시지",
    "details": [ /* 상세 에러 정보 (선택사항) */ ]
  },
  "timestamp": "2025-01-10T12:00:00Z"
}
```

## 🔐 인증 및 인가

### JWT 토큰 구조
```
Header: {
  "alg": "HS512",
  "typ": "JWT"
}

Payload: {
  "sub": "user@example.com",
  "userId": 1,
  "role": "USER", 
  "iat": 1641811200,
  "exp": 1641814800
}
```

### 권한 레벨
- **PUBLIC**: 인증 불필요
- **USER**: 일반 사용자 인증 필요  
- **ADMIN**: 관리자 권한 필요

## ❌ 에러 코드

| 코드 | HTTP 상태 | 메시지 |
|------|-----------|--------|
| USER_001 | 404 | 사용자를 찾을 수 없습니다 |
| USER_002 | 409 | 이미 존재하는 사용자입니다 |
| USER_003 | 400 | 올바르지 않은 이메일 형식입니다 |
| USER_004 | 400 | 비밀번호는 8자 이상이어야 하며 영문, 숫자, 특수문자를 포함해야 합니다 |
| USER_005 | 401 | 이메일 또는 비밀번호가 올바르지 않습니다 |
| USER_006 | 423 | 계정이 잠겨있습니다 |
| USER_007 | 403 | 접근 권한이 없습니다 |
| COMMON_001 | 400 | 잘못된 입력값입니다 |

## 📝 사용 예시

### 사용자 등록 → 로그인 → 정보 조회 플로우

```bash
# 1. 사용자 등록
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123!",
    "name": "테스트사용자"
  }'

# 2. 로그인
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com", 
    "password": "test123!"
  }'

# 3. 내 정보 조회
curl -X GET http://localhost:8080/api/v1/users/me \
  -H "Authorization: Bearer <JWT_TOKEN>"
```

---

**작성일**: 2025-01-10  
**버전**: v1.0  
**담당자**: Claude Code AI