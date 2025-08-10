package com.example.product.service;

import com.example.product.domain.Category;
import com.example.product.domain.CategoryStatus;
import com.example.product.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.annotation.Validated;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@Validated
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CategoryService {
    
    private final CategoryRepository categoryRepository;
    
    @Transactional
    public Category createCategory(@Valid @NotNull Category category) {
        log.info("Creating new category: {}", category.getName());
        
        if (categoryRepository.existsByName(category.getName())) {
            throw new IllegalArgumentException("이미 존재하는 카테고리명입니다: " + category.getName());
        }
        
        if (category.getParentId() != null && !categoryRepository.existsById(category.getParentId())) {
            throw new IllegalArgumentException("존재하지 않는 부모 카테고리입니다: " + category.getParentId());
        }
        
        Category newCategory = Category.builder()
                .name(category.getName())
                .description(category.getDescription())
                .parentId(category.getParentId())
                .status(CategoryStatus.ACTIVE)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        
        Category saved = categoryRepository.save(newCategory);
        log.info("Category created successfully with ID: {}", saved.getId());
        return saved;
    }
    
    @Transactional
    public Category updateCategory(@NotNull Long id, @Valid @NotNull Category category) {
        log.info("Updating category with ID: {}", id);
        
        Category existing = findById(id);
        
        if (!category.getName().equals(existing.getName()) && categoryRepository.existsByName(category.getName())) {
            throw new IllegalArgumentException("이미 존재하는 카테고리명입니다: " + category.getName());
        }
        
        if (category.getParentId() != null) {
            if (category.getParentId().equals(id)) {
                throw new IllegalArgumentException("자기 자신을 부모로 설정할 수 없습니다");
            }
            if (!categoryRepository.existsById(category.getParentId())) {
                throw new IllegalArgumentException("존재하지 않는 부모 카테고리입니다: " + category.getParentId());
            }
        }
        
        Category updated = Category.builder()
                .id(existing.getId())
                .name(category.getName())
                .description(category.getDescription())
                .parentId(category.getParentId())
                .status(existing.getStatus())
                .createdAt(existing.getCreatedAt())
                .updatedAt(LocalDateTime.now())
                .build();
        
        Category saved = categoryRepository.save(updated);
        log.info("Category updated successfully: {}", saved.getId());
        return saved;
    }
    
    public Category findById(@NotNull Long id) {
        return categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("카테고리를 찾을 수 없습니다: " + id));
    }
    
    public Page<Category> findAll(Pageable pageable) {
        return categoryRepository.findAll(pageable);
    }
    
    public List<Category> findRootCategories() {
        return categoryRepository.findByParentIdIsNull();
    }
    
    public List<Category> findSubCategories(@NotNull Long parentId) {
        return categoryRepository.findByParentId(parentId);
    }
    
    public Page<Category> findByStatus(@NotNull CategoryStatus status, Pageable pageable) {
        return categoryRepository.findByStatus(status, pageable);
    }
    
    public Page<Category> searchCategories(String keyword, Pageable pageable) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return findAll(pageable);
        }
        return categoryRepository.findByNameContaining(keyword.trim(), pageable);
    }
    
    public List<Category> findAllChildCategories(@NotNull Long parentId) {
        return categoryRepository.findAllChildCategories(parentId);
    }
    
    @Transactional
    public void activateCategory(@NotNull Long id) {
        log.info("Activating category with ID: {}", id);
        Category category = findById(id);
        category.activate();
        categoryRepository.save(category);
    }
    
    @Transactional
    public void deactivateCategory(@NotNull Long id) {
        log.info("Deactivating category with ID: {}", id);
        Category category = findById(id);
        category.deactivate();
        categoryRepository.save(category);
    }
    
    @Transactional
    public void deleteCategory(@NotNull Long id) {
        log.info("Deleting category with ID: {}", id);
        
        if (!categoryRepository.existsById(id)) {
            throw new IllegalArgumentException("삭제할 카테고리를 찾을 수 없습니다: " + id);
        }
        
        long childCount = categoryRepository.countByParentId(id);
        if (childCount > 0) {
            throw new IllegalArgumentException("하위 카테고리가 존재하는 카테고리는 삭제할 수 없습니다");
        }
        
        categoryRepository.deleteById(id);
    }
    
    public boolean existsById(@NotNull Long id) {
        return categoryRepository.existsById(id);
    }
    
    public boolean existsByName(@NotNull String name) {
        return categoryRepository.existsByName(name);
    }
    
    public long countByStatus(@NotNull CategoryStatus status) {
        return categoryRepository.countByStatus(status);
    }
    
    public long countByParentId(@NotNull Long parentId) {
        return categoryRepository.countByParentId(parentId);
    }
}