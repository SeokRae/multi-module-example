package com.example.product.domain;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class Category {
    
    private Long id;
    private String name;
    private String description;
    private Long parentId;
    private CategoryStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public void activate() {
        this.status = CategoryStatus.ACTIVE;
        this.updatedAt = LocalDateTime.now();
    }
    
    public void deactivate() {
        this.status = CategoryStatus.INACTIVE;
        this.updatedAt = LocalDateTime.now();
    }
    
    public boolean isActive() {
        return CategoryStatus.ACTIVE.equals(this.status);
    }
    
    public boolean hasParent() {
        return this.parentId != null;
    }
}