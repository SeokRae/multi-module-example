# 🛍️ Product Catalog (상품 카탈로그)

> 이 문서는 상품 카탈로그 관리 기능에 대한 종합적인 개요를 제공합니다.

## 📝 개요

### 목적
- 전자상거래 플랫폼의 상품 및 카테고리 관리
- 상품 검색, 필터링, 카탈로그 브라우징 기능
- 관리자용 상품/카테고리 관리 도구

### 범위
- ✅ **포함되는 기능들**
  - 상품 CRUD (생성, 조회, 수정, 삭제)
  - 계층형 카테고리 관리
  - 상품 검색 및 필터링
  - 상품 상태 관리 (활성/비활성/단종)
  - 재고 관리 및 알림
  - 상품 조회수 추적
  - SKU 기반 상품 관리

- ❌ **제외되는 기능들**  
  - 상품 리뷰/평점 (별도 feature)
  - 상품 이미지 관리 (향후 계획)
  - 상품 추천 시스템 (향후 계획)
  - 다국어 상품 정보 (향후 계획)

## 🏗️ 아키텍처 개요

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ ProductController│───▶│ ProductService  │───▶│ProductRepository│
│ CategoryController│    │ CategoryService │    │CategoryRepository│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│Product/Category │    │   Product       │    │  products       │
│  Request/       │    │   Category      │    │  categories     │
│   Response      │    │   Domain        │    │   tables        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🧩 주요 구성요소

### Domain Layer (`domain/product-domain`)
- **Entities**: 
  - `Product` (상품 엔티티) - 이름, 가격, 재고, 상태 관리
  - `Category` (카테고리 엔티티) - 계층형 구조, 상태 관리
- **Value Objects**: 
  - `ProductStatus` (ACTIVE, INACTIVE, DISCONTINUED)
  - `CategoryStatus` (ACTIVE, INACTIVE)
- **Domain Services**: 
  - `ProductService` (상품 비즈니스 로직)
  - `CategoryService` (카테고리 비즈니스 로직)

### Application Layer (예정)
- **Controllers**: `ProductController`, `CategoryController`
- **DTOs**: 
  - Request: `ProductCreateRequest`, `CategoryCreateRequest`
  - Response: `ProductResponse`, `CategoryResponse`

### Infrastructure Layer
- **Repositories**: 
  - `ProductRepository` (상품 데이터 접근)
  - `CategoryRepository` (카테고리 데이터 접근)

## 🔗 관련 문서

- [📋 요구사항](./requirements.md)
- [🎨 설계](./design.md) 
- [⚙️ 구현](./implementation.md)
- [🌐 API 명세](./api-specification.md)
- [🧪 테스트](./testing.md)

## 📊 현재 상태

- **요구사항 분석**: ✅ 완료
- **설계 완료**: ✅ 완료  
- **Domain Layer 구현**: ✅ 완료
- **API Layer 구현**: ⏳ 계획됨
- **테스트 완료**: ⏳ 진행중
- **문서화 완료**: ⏳ 진행중
- **배포 준비**: ⏳ 대기중

## 🎯 주요 이정표

- [x] 요구사항 분석 및 승인
- [x] Domain 모델 설계
- [x] Product 엔티티 구현
- [x] Category 엔티티 구현  
- [x] Repository 인터페이스 정의
- [x] Service Layer 구현
- [x] DTO 및 예외 클래스 구현
- [ ] REST API Controller 구현
- [ ] API 문서화 완료
- [ ] 통합 테스트 작성
- [ ] 성능 테스트 완료

## 👥 관련 팀/역할

- **Product Owner**: 개발팀
- **Tech Lead**: Claude Code AI
- **Backend Developer**: Claude Code AI
- **QA Engineer**: 미정

## 📈 성공 지표

### 비즈니스 지표
- 상품 등록률: 목표 설정 필요
- 상품 검색 성공률: > 95%
- 카탈로그 브라우징 만족도: > 4.0/5.0

### 기술적 지표  
- API 응답시간: < 100ms (상품 조회)
- 검색 응답시간: < 200ms (복잡한 필터 포함)
- 가용성: > 99.9%
- 동시 상품 조회: > 5000 req/sec

## 🔧 핵심 기능

### 1. 상품 관리
- **상품 생성**: 이름, 설명, 가격, 재고, 카테고리, SKU 등
- **상품 수정**: 모든 정보 변경 가능 (SKU 중복 검증)
- **상품 상태 관리**: 활성화/비활성화/단종 처리
- **재고 관리**: 재고 증감, 부족 알림, 안전 재고 체크
- **조회수 추적**: 상품별 조회 통계

### 2. 카테고리 관리
- **계층형 구조**: 부모-자식 관계의 무한 depth 지원
- **카테고리 CRUD**: 생성, 조회, 수정, 삭제
- **상태 관리**: 활성/비활성 상태 전환
- **제약 검증**: 자기참조 방지, 하위 카테고리 존재시 삭제 방지

### 3. 검색 및 필터링
- **텍스트 검색**: 상품명 기반 부분 일치 검색
- **카테고리 필터**: 특정 카테고리 상품만 조회
- **가격 범위 필터**: 최소-최대 가격 구간 검색
- **상태 필터**: 활성 상품만 조회
- **브랜드 필터**: 브랜드별 상품 검색
- **페이징**: 대량 데이터 효율적 처리

### 4. 고급 기능
- **인기 상품**: 조회수 기반 인기 상품 목록
- **재고 부족 알림**: 설정한 임계값 이하 상품 목록
- **SKU 관리**: 중복 방지 및 고유성 보장

## 🛡️ 비즈니스 규칙

### 상품 규칙
- 상품명은 필수이며 255자 이하
- 가격은 양수여야 함 (0 초과)
- 재고는 0 이상의 정수
- SKU는 고유해야 함 (중복 불허)
- 단종된 상품은 재활성화 불가

### 카테고리 규칙  
- 카테고리명은 필수이며 100자 이하
- 자기 자신을 부모로 설정 불가
- 하위 카테고리가 있는 경우 삭제 불가
- 비활성 카테고리의 상품은 검색에서 제외

## 📊 데이터 모델

### Product 엔티티
```java
public class Product {
    private Long id;
    private String name;           // 상품명 (필수)
    private String description;    // 상품 설명
    private BigDecimal price;      // 가격 (양수)
    private Integer stockQuantity; // 재고 수량 (0 이상)
    private Long categoryId;       // 카테고리 ID
    private String brand;          // 브랜드
    private String sku;           // 상품 코드 (고유)
    private ProductStatus status;  // 상품 상태
    private Long viewCount;       // 조회수
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
```

### Category 엔티티
```java
public class Category {
    private Long id;
    private String name;              // 카테고리명 (필수)
    private String description;       // 카테고리 설명
    private Long parentId;           // 부모 카테고리 ID
    private CategoryStatus status;    // 카테고리 상태
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
```

## 🔄 상태 전이 다이어그램

### 상품 상태 전이
```
  ACTIVE ←→ INACTIVE
     ↓
  DISCONTINUED
     (종료상태)
```

### 카테고리 상태 전이
```
  ACTIVE ←→ INACTIVE
```

---

**최종 수정**: 2025-01-10  
**담당자**: Claude Code AI