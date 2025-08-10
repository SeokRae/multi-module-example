package com.example.product.exception;

import com.example.common.exception.BusinessException;
import com.example.common.exception.ErrorCode;

public class InsufficientStockException extends BusinessException {
    
    public InsufficientStockException(String message) {
        super(ErrorCode.INVALID_INPUT_VALUE.getCode(), message);
    }
    
    public InsufficientStockException(Long productId, Integer requestedQuantity, Integer availableStock) {
        super(ErrorCode.INVALID_INPUT_VALUE.getCode(), 
              String.format("재고가 부족합니다. 상품 ID: %d, 요청 수량: %d, 가용 재고: %d", 
                          productId, requestedQuantity, availableStock));
    }
}