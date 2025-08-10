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
    INVALID_EMAIL_FORMAT("USER_003", "올바르지 않은 이메일 형식입니다"),
    WEAK_PASSWORD("USER_004", "비밀번호는 8자 이상이어야 하며 영문, 숫자, 특수문자를 포함해야 합니다"),
    INVALID_CREDENTIALS("USER_005", "이메일 또는 비밀번호가 올바르지 않습니다"),
    ACCOUNT_LOCKED("USER_006", "계정이 잠겨있습니다"),
    ACCESS_DENIED("USER_007", "접근 권한이 없습니다"),
    
    ORDER_NOT_FOUND("ORDER_001", "주문을 찾을 수 없습니다"),
    INSUFFICIENT_STOCK("ORDER_002", "재고가 부족합니다");
    
    private final String code;
    private final String message;
}