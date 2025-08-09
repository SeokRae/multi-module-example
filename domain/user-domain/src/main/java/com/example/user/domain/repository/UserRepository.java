package com.example.user.domain.repository;

import com.example.user.domain.User;

import java.util.List;
import java.util.Optional;

public interface UserRepository {
    
    User save(User user);
    
    Optional<User> findById(Long id);
    
    Optional<User> findByEmail(String email);
    
    List<User> findAll();
    
    void delete(User user);
    
    boolean existsByEmail(String email);
}