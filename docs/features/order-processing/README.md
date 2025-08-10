# 📦 Order Processing (주문 처리)

> 이 문서는 주문 처리 기능에 대한 종합적인 개요를 제공합니다.

## 📝 개요

### 목적
- 전자상거래 플랫폼의 주문 생명주기 관리
- 안전하고 신뢰할 수 있는 주문 처리 프로세스
- 주문 상태 추적 및 관리 도구

### 범위
- ✅ **포함되는 기능들**
  - 주문 생성 및 관리
  - 주문 상태 전이 (대기→확인→결제→배송→완료)
  - 주문 항목 관리 (수량, 가격 계산)
  - 주문 취소 및 환불 처리
  - 주문 내역 조회 및 검색
  - 재고 연동 및 검증

- ❌ **제외되는 기능들**  
  - 결제 게이트웨이 연동 (향후 계획)
  - 배송 추적 시스템 (향후 계획)
  - 주문 알림 시스템 (향후 계획)
  - 반품/교환 처리 (향후 계획)

## 🏗️ 아키텍처 개요

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ OrderController │───▶│  OrderService   │───▶│ OrderRepository │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Order DTO     │    │     Order       │    │  orders/        │
│   OrderItem     │    │   OrderItem     │    │  order_items    │
│   Request/      │    │    Domain       │    │   tables        │
│   Response      │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🧩 주요 구성요소

### Domain Layer (`domain/order-domain`)
- **Entities**: 
  - `Order` (주문 엔티티) - 사용자, 총액, 상태, 주소 관리
  - `OrderItem` (주문 항목) - 상품, 수량, 단가, 총액
- **Value Objects**: 
  - `OrderStatus` (PENDING, CONFIRMED, PAID, SHIPPED, DELIVERED, CANCELLED)
- **Domain Services**: 
  - `OrderService` (주문 비즈니스 로직)

### Application Layer (예정)
- **Controllers**: `OrderController`
- **DTOs**: 
  - Request: `OrderCreateRequest`, `OrderUpdateRequest`
  - Response: `OrderResponse`, `OrderSummaryResponse`

### Infrastructure Layer
- **Repositories**: 
  - `OrderRepository` (주문 데이터 접근)

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
- [x] Order 엔티티 구현
- [x] OrderItem 엔티티 구현  
- [x] 주문 상태 전이 로직 구현
- [x] Repository 인터페이스 정의
- [ ] REST API Controller 구현
- [ ] 결제 시스템 연동
- [ ] 배송 관리 시스템 연동
- [ ] 통합 테스트 작성

## 🔧 핵심 기능

### 1. 주문 생성 및 관리
- **주문 생성**: 사용자, 상품 목록, 배송 주소 기반
- **주문 항목 관리**: 상품별 수량, 단가, 총액 계산
- **자동 총액 계산**: 항목 변경시 실시간 총액 재계산
- **주문 검증**: 재고 확인, 상품 유효성 체크

### 2. 주문 상태 관리
- **상태 전이 규칙**: 안전한 상태 변경만 허용
- **자동 날짜 추적**: 배송일, 완료일 자동 기록
- **취소 가능 여부**: 상태에 따른 취소 가능성 판단

### 3. 주문 조회 및 검색
- **사용자별 주문**: 개인 주문 내역 조회
- **상태별 필터링**: 특정 상태의 주문만 조회
- **기간별 검색**: 주문 날짜 범위 검색
- **금액별 필터**: 주문 금액 구간 검색

### 4. 비즈니스 규칙 적용
- **재고 연동**: 주문시 재고 차감, 취소시 복원
- **가격 정합성**: 주문 당시 가격으로 고정
- **상태 전이 검증**: 불법적인 상태 변경 방지

## 🔄 주문 생명주기

```
[주문 생성] → PENDING (대기중)
     ↓
[관리자 확인] → CONFIRMED (주문확인)  
     ↓
[결제 완료] → PAID (결제완료)
     ↓  
[배송 시작] → SHIPPED (배송중)
     ↓
[배송 완료] → DELIVERED (배송완료)

※ PENDING/CONFIRMED/PAID 상태에서는 CANCELLED 가능
```

## 🛡️ 비즈니스 규칙

### 주문 생성 규칙
- 주문자는 로그인한 사용자여야 함
- 최소 1개 이상의 주문 항목 필요
- 주문 항목의 상품은 활성 상태여야 함
- 충분한 재고가 있어야 함

### 상태 전이 규칙  
- PENDING → CONFIRMED, CANCELLED만 가능
- CONFIRMED → PAID, CANCELLED만 가능
- PAID → SHIPPED, CANCELLED만 가능
- SHIPPED → DELIVERED만 가능
- DELIVERED, CANCELLED는 최종 상태

### 취소 규칙
- DELIVERED 상태는 취소 불가
- CANCELLED 상태는 취소 불가
- 취소시 재고 자동 복원

## 📊 데이터 모델

### Order 엔티티
```java
public class Order {
    private Long id;
    private Long userId;              // 주문자 ID
    private List<OrderItem> orderItems; // 주문 항목들
    private BigDecimal totalAmount;   // 총 금액
    private OrderStatus status;       // 주문 상태
    private String shippingAddress;   // 배송 주소
    private String billingAddress;    // 청구 주소
    private LocalDateTime orderDate;  // 주문일
    private LocalDateTime shippedDate;   // 배송일
    private LocalDateTime deliveredDate; // 완료일
}
```

### OrderItem 엔티티  
```java
public class OrderItem {
    private Long id;
    private Long productId;        // 상품 ID
    private String productName;    // 상품명 (스냅샷)
    private BigDecimal unitPrice;  // 단가 (주문 당시)
    private Integer quantity;      // 주문 수량
    private BigDecimal totalPrice; // 항목별 총액
}
```

## 🎲 상태별 액션

| 상태 | 가능한 액션 | 제약사항 |
|------|------------|----------|
| **PENDING** | confirm(), cancel() | 재고 확인 필요 |
| **CONFIRMED** | pay(), cancel() | 결제 준비 완료 |  
| **PAID** | ship(), cancel() | 환불 처리 필요 |
| **SHIPPED** | deliver() | 취소 불가 |
| **DELIVERED** | (없음) | 최종 상태 |
| **CANCELLED** | (없음) | 최종 상태 |

---

**최종 수정**: 2025-01-10  
**담당자**: Claude Code AI