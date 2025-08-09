package com.example.user.domain.service;

import com.example.common.exception.BusinessException;
import com.example.common.exception.ErrorCode;
import com.example.user.domain.User;
import com.example.user.domain.UserStatus;
import com.example.user.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {
    
    private final UserRepository userRepository;
    
    public User createUser(String email, String name) {
        if (userRepository.existsByEmail(email)) {
            throw new BusinessException(ErrorCode.USER_ALREADY_EXISTS.getCode(), 
                    ErrorCode.USER_ALREADY_EXISTS.getMessage());
        }
        
        User user = User.builder()
                .email(email)
                .name(name)
                .status(UserStatus.ACTIVE)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        
        return userRepository.save(user);
    }
    
    public User findById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND.getCode(),
                        ErrorCode.USER_NOT_FOUND.getMessage()));
    }
    
    public List<User> findAllUsers() {
        return userRepository.findAll();
    }
    
    public User activateUser(Long id) {
        User user = findById(id);
        user.activate();
        return userRepository.save(user);
    }
}