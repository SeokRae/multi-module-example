package com.example.product.domain;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class Review {
    
    private Long id;
    private Long productId;
    private Long userId;
    private Integer rating;
    private String title;
    private String content;
    private ReviewStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public void hide() {
        this.status = ReviewStatus.HIDDEN;
        this.updatedAt = LocalDateTime.now();
    }
    
    public void show() {
        this.status = ReviewStatus.ACTIVE;
        this.updatedAt = LocalDateTime.now();
    }
    
    public void delete() {
        this.status = ReviewStatus.DELETED;
        this.updatedAt = LocalDateTime.now();
    }
    
    public boolean isVisible() {
        return ReviewStatus.ACTIVE.equals(this.status);
    }
    
    public boolean isValidRating() {
        return this.rating >= 1 && this.rating <= 5;
    }
}