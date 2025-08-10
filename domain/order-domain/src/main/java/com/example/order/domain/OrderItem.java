package com.example.order.domain;

import lombok.Builder;
import lombok.Getter;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.ToString;
import lombok.EqualsAndHashCode;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
@EqualsAndHashCode(of = "id")
public class OrderItem {
    
    private Long id;
    
    @NotNull(message = "상품 ID는 필수입니다")
    private Long productId;
    
    @NotBlank(message = "상품명은 필수입니다")
    @Size(max = 255, message = "상품명은 255자를 초과할 수 없습니다")
    private String productName;
    
    @NotNull(message = "단가는 필수입니다")
    @DecimalMin(value = "0.0", inclusive = false, message = "단가는 0보다 커야 합니다")
    private BigDecimal unitPrice;
    
    @NotNull(message = "수량은 필수입니다")
    @Min(value = 1, message = "수량은 1 이상이어야 합니다")
    private Integer quantity;
    
    @NotNull(message = "총 가격은 필수입니다")
    @DecimalMin(value = "0.0", inclusive = false, message = "총 가격은 0보다 커야 합니다")
    private BigDecimal totalPrice;
    
    private LocalDateTime createdAt;
    
    public BigDecimal getTotalPrice() {
        if (totalPrice != null) {
            return totalPrice;
        }
        return unitPrice.multiply(BigDecimal.valueOf(quantity));
    }
    
    public void updateQuantity(Integer newQuantity) {
        if (newQuantity == null || newQuantity <= 0) {
            throw new IllegalArgumentException("수량은 1 이상이어야 합니다");
        }
        this.quantity = newQuantity;
        this.totalPrice = unitPrice.multiply(BigDecimal.valueOf(quantity));
    }
    
    public void updateUnitPrice(BigDecimal newUnitPrice) {
        if (newUnitPrice == null || newUnitPrice.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("단가는 0보다 커야 합니다");
        }
        this.unitPrice = newUnitPrice;
        this.totalPrice = unitPrice.multiply(BigDecimal.valueOf(quantity));
    }
    
    public static OrderItem create(Long productId, String productName, BigDecimal unitPrice, Integer quantity) {
        if (productId == null) {
            throw new IllegalArgumentException("상품 ID는 필수입니다");
        }
        if (productName == null || productName.trim().isEmpty()) {
            throw new IllegalArgumentException("상품명은 필수입니다");
        }
        if (unitPrice == null || unitPrice.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("단가는 0보다 커야 합니다");
        }
        if (quantity == null || quantity <= 0) {
            throw new IllegalArgumentException("수량은 1 이상이어야 합니다");
        }
        
        BigDecimal totalPrice = unitPrice.multiply(BigDecimal.valueOf(quantity));
        
        return OrderItem.builder()
                .productId(productId)
                .productName(productName)
                .unitPrice(unitPrice)
                .quantity(quantity)
                .totalPrice(totalPrice)
                .createdAt(LocalDateTime.now())
                .build();
    }
}