package com.example.product.domain;

public enum ReviewStatus {
    ACTIVE("활성"),
    HIDDEN("숨김"),
    DELETED("삭제");
    
    private final String description;
    
    ReviewStatus(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
}