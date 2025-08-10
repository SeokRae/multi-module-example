package com.example.user.domain.service;

import com.example.common.exception.BusinessException;
import com.example.common.exception.ErrorCode;
import com.example.user.domain.User;
import com.example.user.domain.UserStatus;
import com.example.user.domain.UserRole;
import com.example.user.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    
    public User registerUser(String email, String name, String password, String phone) {
        validateUserInput(email, name, password);
        
        if (userRepository.existsByEmail(email)) {
            throw new BusinessException(ErrorCode.USER_ALREADY_EXISTS.getCode(), 
                    ErrorCode.USER_ALREADY_EXISTS.getMessage());
        }
        
        String encodedPassword = passwordEncoder.encode(password);
        
        User user = User.builder()
                .email(email)
                .name(name)
                .password(encodedPassword)
                .phone(phone)
                .status(UserStatus.ACTIVE)
                .role(UserRole.USER)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        
        return userRepository.save(user);
    }
    
    public User authenticateUser(String email, String password) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new BusinessException(ErrorCode.INVALID_CREDENTIALS.getCode(),
                        ErrorCode.INVALID_CREDENTIALS.getMessage()));
        
        if (!user.isActive()) {
            throw new BusinessException(ErrorCode.ACCOUNT_LOCKED.getCode(),
                    ErrorCode.ACCOUNT_LOCKED.getMessage());
        }
        
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new BusinessException(ErrorCode.INVALID_CREDENTIALS.getCode(),
                    ErrorCode.INVALID_CREDENTIALS.getMessage());
        }
        
        return user;
    }
    
    private void validateUserInput(String email, String name, String password) {
        if (!User.isValidEmail(email)) {
            throw new BusinessException(ErrorCode.INVALID_EMAIL_FORMAT.getCode(),
                    ErrorCode.INVALID_EMAIL_FORMAT.getMessage());
        }
        
        if (!User.isValidPassword(password)) {
            throw new BusinessException(ErrorCode.WEAK_PASSWORD.getCode(),
                    ErrorCode.WEAK_PASSWORD.getMessage());
        }
        
        if (name == null || name.trim().isEmpty()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT.getCode(),
                    "사용자 이름은 필수입니다");
        }
    }
    
    public User findById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND.getCode(),
                        ErrorCode.USER_NOT_FOUND.getMessage()));
    }
    
    public List<User> findAllUsers() {
        return userRepository.findAll();
    }
    
    public User updateUserProfile(Long id, String name, String phone) {
        User user = findById(id);
        user.updateProfile(name, phone);
        return userRepository.save(user);
    }
    
    public User changeUserPassword(Long id, String currentPassword, String newPassword) {
        User user = findById(id);
        
        if (!passwordEncoder.matches(currentPassword, user.getPassword())) {
            throw new BusinessException(ErrorCode.INVALID_CREDENTIALS.getCode(),
                    "현재 비밀번호가 올바르지 않습니다");
        }
        
        if (!User.isValidPassword(newPassword)) {
            throw new BusinessException(ErrorCode.WEAK_PASSWORD.getCode(),
                    ErrorCode.WEAK_PASSWORD.getMessage());
        }
        
        String encodedPassword = passwordEncoder.encode(newPassword);
        user.changePassword(encodedPassword);
        
        return userRepository.save(user);
    }
    
    public User activateUser(Long id) {
        User user = findById(id);
        user.activate();
        return userRepository.save(user);
    }
    
    public User deactivateUser(Long id) {
        User user = findById(id);
        user.deactivate();
        return userRepository.save(user);
    }
    
    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }
    
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }
    
    public List<User> findUsersByRole(UserRole role) {
        return userRepository.findByRole(role);
    }
    
    public List<User> findActiveUsers() {
        return userRepository.findByStatus(UserStatus.ACTIVE);
    }
}