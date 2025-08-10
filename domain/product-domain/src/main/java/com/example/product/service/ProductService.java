package com.example.product.service;

import com.example.product.domain.Product;
import com.example.product.domain.ProductStatus;
import com.example.product.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.annotation.Validated;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@Validated
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductService {
    
    private final ProductRepository productRepository;
    
    @Transactional
    public Product createProduct(@Valid @NotNull Product product) {
        log.info("Creating new product: {}", product.getName());
        
        if (product.getSku() != null && productRepository.existsBySku(product.getSku())) {
            throw new IllegalArgumentException("이미 존재하는 SKU입니다: " + product.getSku());
        }
        
        Product newProduct = Product.builder()
                .name(product.getName())
                .description(product.getDescription())
                .price(product.getPrice())
                .stockQuantity(product.getStockQuantity())
                .categoryId(product.getCategoryId())
                .brand(product.getBrand())
                .sku(product.getSku())
                .status(ProductStatus.ACTIVE)
                .viewCount(0L)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        
        Product saved = productRepository.save(newProduct);
        log.info("Product created successfully with ID: {}", saved.getId());
        return saved;
    }
    
    @Transactional
    public Product updateProduct(@NotNull Long id, @Valid @NotNull Product product) {
        log.info("Updating product with ID: {}", id);
        
        Product existing = findById(id);
        
        if (product.getSku() != null && !product.getSku().equals(existing.getSku()) 
            && productRepository.existsBySku(product.getSku())) {
            throw new IllegalArgumentException("이미 존재하는 SKU입니다: " + product.getSku());
        }
        
        Product updated = Product.builder()
                .id(existing.getId())
                .name(product.getName())
                .description(product.getDescription())
                .price(product.getPrice())
                .stockQuantity(product.getStockQuantity())
                .categoryId(product.getCategoryId())
                .brand(product.getBrand())
                .sku(product.getSku())
                .status(existing.getStatus())
                .viewCount(existing.getViewCount())
                .createdAt(existing.getCreatedAt())
                .updatedAt(LocalDateTime.now())
                .build();
        
        Product saved = productRepository.save(updated);
        log.info("Product updated successfully: {}", saved.getId());
        return saved;
    }
    
    public Product findById(@NotNull Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("상품을 찾을 수 없습니다: " + id));
    }
    
    public Optional<Product> findBySku(@NotNull String sku) {
        return productRepository.findBySku(sku);
    }
    
    public Page<Product> findAll(Pageable pageable) {
        return productRepository.findAll(pageable);
    }
    
    public Page<Product> findByStatus(@NotNull ProductStatus status, Pageable pageable) {
        return productRepository.findByStatus(status, pageable);
    }
    
    public Page<Product> findByCategoryId(@NotNull Long categoryId, Pageable pageable) {
        return productRepository.findByCategoryId(categoryId, pageable);
    }
    
    public Page<Product> searchProducts(String keyword, Pageable pageable) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return findAll(pageable);
        }
        return productRepository.findByNameContaining(keyword.trim(), pageable);
    }
    
    public Page<Product> findByPriceRange(BigDecimal minPrice, BigDecimal maxPrice, Pageable pageable) {
        return productRepository.findByPriceBetween(minPrice, maxPrice, pageable);
    }
    
    public List<Product> findLowStockProducts(Integer threshold) {
        return productRepository.findLowStockProducts(threshold != null ? threshold : 10);
    }
    
    public List<Product> findPopularProducts(int limit) {
        return productRepository.findPopularProducts(limit);
    }
    
    @Transactional
    public void increaseViewCount(@NotNull Long id) {
        Product product = findById(id);
        product.increaseViewCount();
        productRepository.save(product);
        log.debug("Increased view count for product: {}", id);
    }
    
    @Transactional
    public void updateStock(@NotNull Long id, @NotNull Integer quantity) {
        log.info("Updating stock for product ID: {} by quantity: {}", id, quantity);
        Product product = findById(id);
        product.updateStock(quantity);
        productRepository.save(product);
    }
    
    @Transactional
    public void decreaseStock(@NotNull Long id, @NotNull Integer quantity) {
        log.info("Decreasing stock for product ID: {} by quantity: {}", id, quantity);
        Product product = findById(id);
        product.decreaseStock(quantity);
        productRepository.save(product);
    }
    
    @Transactional
    public void activateProduct(@NotNull Long id) {
        log.info("Activating product with ID: {}", id);
        Product product = findById(id);
        product.activate();
        productRepository.save(product);
    }
    
    @Transactional
    public void deactivateProduct(@NotNull Long id) {
        log.info("Deactivating product with ID: {}", id);
        Product product = findById(id);
        product.deactivate();
        productRepository.save(product);
    }
    
    @Transactional
    public void discontinueProduct(@NotNull Long id) {
        log.info("Discontinuing product with ID: {}", id);
        Product product = findById(id);
        product.discontinue();
        productRepository.save(product);
    }
    
    @Transactional
    public void deleteProduct(@NotNull Long id) {
        log.info("Deleting product with ID: {}", id);
        if (!productRepository.existsById(id)) {
            throw new IllegalArgumentException("삭제할 상품을 찾을 수 없습니다: " + id);
        }
        productRepository.deleteById(id);
    }
    
    public boolean existsById(@NotNull Long id) {
        return productRepository.existsById(id);
    }
    
    public boolean existsBySku(@NotNull String sku) {
        return productRepository.existsBySku(sku);
    }
    
    public long countByStatus(@NotNull ProductStatus status) {
        return productRepository.countByStatus(status);
    }
    
    public long countByCategoryId(@NotNull Long categoryId) {
        return productRepository.countByCategoryId(categoryId);
    }
}