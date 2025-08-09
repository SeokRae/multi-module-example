package com.example.infrastructure.user;

import com.example.user.domain.User;
import com.example.user.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Repository
@RequiredArgsConstructor
public class UserRepositoryImpl implements UserRepository {
    
    private final UserJpaRepository jpaRepository;
    
    @Override
    public User save(User user) {
        UserEntity entity = user.getId() == null 
                ? UserEntity.fromDomain(user)
                : jpaRepository.findById(user.getId())
                    .map(existingEntity -> {
                        existingEntity.updateFromDomain(user);
                        return existingEntity;
                    })
                    .orElse(UserEntity.fromDomain(user));
        
        return jpaRepository.save(entity).toDomain();
    }
    
    @Override
    public Optional<User> findById(Long id) {
        return jpaRepository.findById(id)
                .map(UserEntity::toDomain);
    }
    
    @Override
    public Optional<User> findByEmail(String email) {
        return jpaRepository.findByEmail(email)
                .map(UserEntity::toDomain);
    }
    
    @Override
    public List<User> findAll() {
        return jpaRepository.findAll().stream()
                .map(UserEntity::toDomain)
                .collect(Collectors.toList());
    }
    
    @Override
    public void delete(User user) {
        jpaRepository.deleteById(user.getId());
    }
    
    @Override
    public boolean existsByEmail(String email) {
        return jpaRepository.existsByEmail(email);
    }
}