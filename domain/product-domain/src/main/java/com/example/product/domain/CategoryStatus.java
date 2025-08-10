package com.example.product.domain;

public enum CategoryStatus {
    ACTIVE("활성"),
    INACTIVE("비활성");
    
    private final String description;
    
    CategoryStatus(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
}