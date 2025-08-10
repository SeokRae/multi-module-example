package com.example.product.exception;

import com.example.common.exception.BusinessException;
import com.example.common.exception.ErrorCode;

public class CategoryNotFoundException extends BusinessException {
    
    public CategoryNotFoundException(String message) {
        super(ErrorCode.ENTITY_NOT_FOUND.getCode(), message);
    }
    
    public CategoryNotFoundException(Long categoryId) {
        super(ErrorCode.ENTITY_NOT_FOUND.getCode(), "카테고리를 찾을 수 없습니다: " + categoryId);
    }
}