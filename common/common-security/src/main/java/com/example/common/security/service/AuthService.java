package com.example.common.security.service;

import com.example.common.exception.BusinessException;
import com.example.common.exception.ErrorCode;
import com.example.common.security.dto.AuthResponse;
import com.example.common.security.dto.LoginRequest;
import com.example.common.security.dto.RefreshTokenRequest;
import com.example.common.security.jwt.JwtTokenProvider;
import com.example.common.security.jwt.UserPrincipal;
import com.example.user.domain.User;
import com.example.user.domain.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {
    
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;
    private final UserService userService;
    
    @Cacheable(value = "users", key = "'auth:' + #loginRequest.email", unless = "#result == null")
    public AuthResponse login(LoginRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginRequest.getEmail(),
                        loginRequest.getPassword()
                )
        );
        
        SecurityContextHolder.getContext().setAuthentication(authentication);
        
        String accessToken = tokenProvider.generateToken(authentication);
        String refreshToken = tokenProvider.generateRefreshToken(authentication);
        
        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
        
        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(86400L) // 24 hours in seconds
                .userInfo(AuthResponse.UserInfo.builder()
                        .id(userPrincipal.getId())
                        .email(userPrincipal.getEmail())
                        .name(userPrincipal.getUsername())
                        .role(userPrincipal.getRole().name())
                        .build())
                .build();
    }
    
    public AuthResponse refreshToken(RefreshTokenRequest request) {
        String refreshToken = request.getRefreshToken();
        
        if (!tokenProvider.validateToken(refreshToken)) {
            throw new BusinessException(ErrorCode.INVALID_CREDENTIALS.getCode(), "Invalid refresh token");
        }
        
        if (!tokenProvider.isRefreshToken(refreshToken)) {
            throw new BusinessException(ErrorCode.INVALID_CREDENTIALS.getCode(), "Invalid refresh token type");
        }
        
        Long userId = tokenProvider.getUserIdFromToken(refreshToken);
        User user = userService.findById(userId);
        
        if (!user.isActive()) {
            throw new BusinessException(ErrorCode.ACCOUNT_LOCKED.getCode(), 
                    ErrorCode.ACCOUNT_LOCKED.getMessage());
        }
        
        UserPrincipal userPrincipal = UserPrincipal.create(user);
        Authentication authentication = new UsernamePasswordAuthenticationToken(
                userPrincipal, null, userPrincipal.getAuthorities());
        
        String newAccessToken = tokenProvider.generateToken(authentication);
        String newRefreshToken = tokenProvider.generateRefreshToken(authentication);
        
        return AuthResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .tokenType("Bearer")
                .expiresIn(86400L)
                .userInfo(AuthResponse.UserInfo.builder()
                        .id(userPrincipal.getId())
                        .email(userPrincipal.getEmail())
                        .name(user.getName())
                        .role(userPrincipal.getRole().name())
                        .build())
                .build();
    }
}