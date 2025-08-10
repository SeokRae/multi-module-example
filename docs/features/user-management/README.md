# 👤 User Management (사용자 관리)

> 이 문서는 사용자 관리 기능에 대한 종합적인 개요를 제공합니다.

## 📝 개요

### 목적
- 시스템 사용자의 등록, 인증, 정보 관리
- 역할 기반 접근 제어 (RBAC) 제공
- 안전한 사용자 데이터 관리

### 범위
- ✅ **포함되는 기능들**
  - 사용자 회원가입/탈퇴
  - 사용자 로그인/로그아웃  
  - 사용자 정보 조회/수정
  - 역할 기반 권한 관리
  - 이메일 중복 검증
  - 비밀번호 정책 적용

- ❌ **제외되는 기능들**  
  - 소셜 로그인 (향후 계획)
  - 2FA 인증 (향후 계획)
  - 비밀번호 찾기 (향후 계획)

## 🏗️ 아키텍처 개요

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  UserController │───▶│   UserService   │───▶│ UserRepository  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   UserRequest/  │    │      User       │    │   users table   │
│   UserResponse  │    │     Domain      │    │   (Database)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🧩 주요 구성요소

### Domain Layer (`domain/user-domain`)
- **Entities**: `User` (사용자 엔티티)
- **Value Objects**: `UserRole`, `UserStatus`
- **Domain Services**: `UserService` (도메인 비즈니스 로직)

### Application Layer (`application/user-api`)
- **Controllers**: `UserController` (REST API 컨트롤러)
- **DTOs**: `UserCreateRequest`, `UserUpdateRequest`, `UserResponse`

### Infrastructure Layer (`infrastructure/data-access`)
- **Repositories**: `UserRepository` (데이터 접근 계층)

### Security Layer (`common/common-security`)
- **Authentication**: JWT 기반 인증
- **Authorization**: 역할 기반 접근 제어

## 🔗 관련 문서

- [📋 요구사항](./requirements.md)
- [🎨 설계](./design.md) 
- [⚙️ 구현](./implementation.md)
- [🌐 API 명세](./api-specification.md)
- [🧪 테스트](./testing.md)
- [🚀 배포](./deployment.md)

## 📊 현재 상태

- **요구사항 분석**: ✅ 완료
- **설계 완료**: ✅ 완료  
- **구현 완료**: ✅ 완료
- **테스트 완료**: ⏳ 진행중
- **문서화 완료**: ⏳ 진행중
- **배포 준비**: ✅ 완료

## 🎯 주요 이정표

- [x] 요구사항 분석 및 승인
- [x] 기술적 설계 완료
- [x] Domain Layer 구현
- [x] REST API 구현
- [x] JWT 인증 시스템 구현
- [x] 기본 테스트 작성
- [ ] 통합 테스트 완료
- [ ] 성능 테스트 완료
- [ ] 프로덕션 배포

## 👥 관련 팀/역할

- **Product Owner**: 개발팀
- **Tech Lead**: Claude Code AI
- **Backend Developer**: Claude Code AI
- **QA Engineer**: 미정

## 📈 성공 지표

### 비즈니스 지표
- 사용자 등록률: 목표 설정 필요
- 로그인 성공률: > 99%

### 기술적 지표  
- API 응답시간: < 100ms
- 가용성: > 99.9%
- 동시 접속자 지원: > 1000명

## 🔧 핵심 기능

### 1. 사용자 등록
- 이메일 중복 검증
- 비밀번호 강도 검증 (8자 이상, 영문+숫자+특수문자)
- 자동 역할 할당 (기본: USER)

### 2. 인증/인가
- JWT 토큰 기반 인증
- Role-based 접근 제어
- 토큰 만료 및 갱신 관리

### 3. 사용자 관리
- 사용자 정보 CRUD
- 상태 관리 (ACTIVE/INACTIVE/SUSPENDED)
- 프로필 업데이트

## 🛡️ 보안 특징

- **비밀번호 암호화**: BCrypt 해싱
- **JWT 서명**: HS512 알고리즘
- **입력 검증**: Jakarta Validation
- **SQL Injection 방지**: JPA/QueryDSL 사용

---

**최종 수정**: 2025-01-10  
**담당자**: Claude Code AI