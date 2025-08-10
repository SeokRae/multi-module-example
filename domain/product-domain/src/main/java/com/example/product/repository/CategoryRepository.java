package com.example.product.repository;

import com.example.product.domain.Category;
import com.example.product.domain.CategoryStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

public interface CategoryRepository {
    
    Category save(Category category);
    
    Optional<Category> findById(Long id);
    
    List<Category> findByIds(List<Long> ids);
    
    Page<Category> findAll(Pageable pageable);
    
    List<Category> findByParentIdIsNull();
    
    List<Category> findByParentId(Long parentId);
    
    Page<Category> findByStatus(CategoryStatus status, Pageable pageable);
    
    Page<Category> findByNameContaining(String name, Pageable pageable);
    
    List<Category> findAllChildCategories(Long parentId);
    
    void deleteById(Long id);
    
    boolean existsById(Long id);
    
    boolean existsByName(String name);
    
    long countByStatus(CategoryStatus status);
    
    long countByParentId(Long parentId);
}