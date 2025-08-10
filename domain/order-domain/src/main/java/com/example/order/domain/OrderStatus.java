package com.example.order.domain;

public enum OrderStatus {
    PENDING("대기중"),
    CONFIRMED("주문확인"),
    PAID("결제완료"),
    SHIPPED("배송중"),
    DELIVERED("배송완료"),
    CANCELLED("취소됨");
    
    private final String description;
    
    OrderStatus(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
}