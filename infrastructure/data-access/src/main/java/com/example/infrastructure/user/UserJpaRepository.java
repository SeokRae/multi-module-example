package com.example.infrastructure.user;

import com.example.user.domain.UserRole;
import com.example.user.domain.UserStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserJpaRepository extends JpaRepository<UserEntity, Long> {
    
    Optional<UserEntity> findByEmail(String email);
    
    boolean existsByEmail(String email);
    
    List<UserEntity> findByRole(UserRole role);
    
    List<UserEntity> findByStatus(UserStatus status);
    
    List<UserEntity> findByRoleAndStatus(UserRole role, UserStatus status);
}