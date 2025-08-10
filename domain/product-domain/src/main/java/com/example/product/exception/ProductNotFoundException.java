package com.example.product.exception;

import com.example.common.exception.BusinessException;
import com.example.common.exception.ErrorCode;

public class ProductNotFoundException extends BusinessException {
    
    public ProductNotFoundException(String message) {
        super(ErrorCode.ENTITY_NOT_FOUND.getCode(), message);
    }
    
    public ProductNotFoundException(Long productId) {
        super(ErrorCode.ENTITY_NOT_FOUND.getCode(), "상품을 찾을 수 없습니다: " + productId);
    }
}