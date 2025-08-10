package com.example.product.domain;

import lombok.Builder;
import lombok.Getter;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.ToString;
import lombok.EqualsAndHashCode;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
@EqualsAndHashCode(of = "id")
public class Product {
    
    private Long id;
    
    @NotBlank(message = "상품명은 필수입니다")
    @Size(max = 255, message = "상품명은 255자를 초과할 수 없습니다")
    private String name;
    
    @Size(max = 2000, message = "상품 설명은 2000자를 초과할 수 없습니다")
    private String description;
    
    @NotNull(message = "가격은 필수입니다")
    @DecimalMin(value = "0.0", inclusive = false, message = "가격은 0보다 커야 합니다")
    @Digits(integer = 8, fraction = 2, message = "가격 형식이 올바르지 않습니다")
    private BigDecimal price;
    
    @NotNull(message = "재고 수량은 필수입니다")
    @Min(value = 0, message = "재고 수량은 0 이상이어야 합니다")
    private Integer stockQuantity;
    
    @NotNull(message = "카테고리는 필수입니다")
    private Long categoryId;
    
    @Size(max = 100, message = "브랜드명은 100자를 초과할 수 없습니다")
    private String brand;
    
    @Size(max = 100, message = "SKU는 100자를 초과할 수 없습니다")
    private String sku;
    
    @NotNull(message = "상품 상태는 필수입니다")
    private ProductStatus status;
    
    @Min(value = 0, message = "조회수는 0 이상이어야 합니다")
    private Long viewCount;
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public void updateStock(Integer quantity) {
        if (this.stockQuantity + quantity < 0) {
            throw new IllegalArgumentException("재고가 부족합니다");
        }
        this.stockQuantity += quantity;
        this.updatedAt = LocalDateTime.now();
    }
    
    public void decreaseStock(Integer quantity) {
        if (this.stockQuantity < quantity) {
            throw new IllegalArgumentException("재고가 부족합니다");
        }
        this.stockQuantity -= quantity;
        this.updatedAt = LocalDateTime.now();
    }
    
    public void increaseViewCount() {
        this.viewCount++;
        this.updatedAt = LocalDateTime.now();
    }
    
    public boolean isAvailable() {
        return ProductStatus.ACTIVE.equals(this.status) && this.stockQuantity > 0;
    }
    
    public boolean isLowStock(Integer threshold) {
        return this.stockQuantity <= threshold;
    }
    
    public void activate() {
        this.status = ProductStatus.ACTIVE;
        this.updatedAt = LocalDateTime.now();
    }
    
    public void deactivate() {
        this.status = ProductStatus.INACTIVE;
        this.updatedAt = LocalDateTime.now();
    }
    
    public void discontinue() {
        this.status = ProductStatus.DISCONTINUED;
        this.updatedAt = LocalDateTime.now();
    }
}