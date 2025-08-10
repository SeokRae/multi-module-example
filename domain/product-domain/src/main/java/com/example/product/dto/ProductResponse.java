package com.example.product.dto;

import com.example.product.domain.Product;
import com.example.product.domain.ProductStatus;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Builder
public class ProductResponse {
    
    private Long id;
    private String name;
    private String description;
    private BigDecimal price;
    private Integer stockQuantity;
    private Long categoryId;
    private String brand;
    private String sku;
    private ProductStatus status;
    private String statusDescription;
    private Long viewCount;
    private boolean available;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public static ProductResponse from(Product product) {
        return ProductResponse.builder()
                .id(product.getId())
                .name(product.getName())
                .description(product.getDescription())
                .price(product.getPrice())
                .stockQuantity(product.getStockQuantity())
                .categoryId(product.getCategoryId())
                .brand(product.getBrand())
                .sku(product.getSku())
                .status(product.getStatus())
                .statusDescription(product.getStatus().getDescription())
                .viewCount(product.getViewCount())
                .available(product.isAvailable())
                .createdAt(product.getCreatedAt())
                .updatedAt(product.getUpdatedAt())
                .build();
    }
}