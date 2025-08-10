package com.example.product.domain;

public enum ProductStatus {
    ACTIVE("활성"),
    INACTIVE("비활성"),
    DISCONTINUED("단종");
    
    private final String description;
    
    ProductStatus(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
}