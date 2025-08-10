package com.example.user.api.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class UserUpdateRequest {
    
    @NotBlank(message = "이름은 필수입니다")
    private String name;
    
    private String phone;
}