package com.example.common.exception;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum ErrorCode {
    
    INVALID_INPUT("COMMON_001", "잘못된 입력값입니다"),
    SYSTEM_ERROR("COMMON_002", "시스템 에러가 발생했습니다"),
    
    USER_NOT_FOUND("USER_001", "사용자를 찾을 수 없습니다"),
    USER_ALREADY_EXISTS("USER_002", "이미 존재하는 사용자입니다"),
    
    ORDER_NOT_FOUND("ORDER_001", "주문을 찾을 수 없습니다"),
    INSUFFICIENT_STOCK("ORDER_002", "재고가 부족합니다");
    
    private final String code;
    private final String message;
}