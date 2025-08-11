package com.example.product.api.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ProductUpdateRequest {

    @Size(max = 255, message = "상품명은 255자를 초과할 수 없습니다")
    private String name;

    @Size(max = 2000, message = "상품 설명은 2000자를 초과할 수 없습니다")
    private String description;

    @DecimalMin(value = "0.0", inclusive = false, message = "가격은 0보다 커야 합니다")
    @Digits(integer = 8, fraction = 2, message = "가격 형식이 올바르지 않습니다")
    private BigDecimal price;

    @Min(value = 0, message = "재고 수량은 0 이상이어야 합니다")
    private Integer stockQuantity;

    private Long categoryId;

    @Size(max = 100, message = "브랜드명은 100자를 초과할 수 없습니다")
    private String brand;

    @Size(max = 100, message = "SKU는 100자를 초과할 수 없습니다")
    private String sku;
}