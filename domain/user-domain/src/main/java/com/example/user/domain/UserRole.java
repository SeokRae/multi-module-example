package com.example.user.domain;

public enum UserRole {
    USER("일반 사용자"),
    ADMIN("시스템 관리자"),
    PRODUCT_ADMIN("상품 관리자"),
    ORDER_ADMIN("주문 관리자");
    
    private final String description;
    
    UserRole(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
    
    public boolean hasAdminPrivileges() {
        return this == ADMIN || this == PRODUCT_ADMIN || this == ORDER_ADMIN;
    }
    
    public boolean canManageProducts() {
        return this == ADMIN || this == PRODUCT_ADMIN;
    }
    
    public boolean canManageOrders() {
        return this == ADMIN || this == ORDER_ADMIN;
    }
}