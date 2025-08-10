package com.example.common.security.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AuthResponse {
    
    private String accessToken;
    private String refreshToken;
    @Builder.Default
    private String tokenType = "Bearer";
    private Long expiresIn;
    private UserInfo userInfo;
    
    @Data
    @Builder
    public static class UserInfo {
        private Long id;
        private String email;
        private String name;
        private String role;
    }
}