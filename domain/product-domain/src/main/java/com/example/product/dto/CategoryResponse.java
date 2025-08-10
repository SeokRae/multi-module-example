package com.example.product.dto;

import com.example.product.domain.Category;
import com.example.product.domain.CategoryStatus;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class CategoryResponse {
    
    private Long id;
    private String name;
    private String description;
    private Long parentId;
    private CategoryStatus status;
    private String statusDescription;
    private boolean hasParent;
    private boolean active;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public static CategoryResponse from(Category category) {
        return CategoryResponse.builder()
                .id(category.getId())
                .name(category.getName())
                .description(category.getDescription())
                .parentId(category.getParentId())
                .status(category.getStatus())
                .statusDescription(category.getStatus().getDescription())
                .hasParent(category.hasParent())
                .active(category.isActive())
                .createdAt(category.getCreatedAt())
                .updatedAt(category.getUpdatedAt())
                .build();
    }
}