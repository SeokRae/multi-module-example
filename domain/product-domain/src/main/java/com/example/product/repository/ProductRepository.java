package com.example.product.repository;

import com.example.product.domain.Product;
import com.example.product.domain.ProductStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

public interface ProductRepository {
    
    Product save(Product product);
    
    Optional<Product> findById(Long id);
    
    Optional<Product> findBySku(String sku);
    
    List<Product> findByIds(List<Long> ids);
    
    Page<Product> findAll(Pageable pageable);
    
    Page<Product> findByStatus(ProductStatus status, Pageable pageable);
    
    Page<Product> findByCategoryId(Long categoryId, Pageable pageable);
    
    Page<Product> findByNameContaining(String name, Pageable pageable);
    
    Page<Product> findByBrand(String brand, Pageable pageable);
    
    Page<Product> findByPriceBetween(BigDecimal minPrice, BigDecimal maxPrice, Pageable pageable);
    
    Page<Product> findByCategoryIdAndStatus(Long categoryId, ProductStatus status, Pageable pageable);
    
    List<Product> findLowStockProducts(Integer threshold);
    
    List<Product> findPopularProducts(int limit);
    
    void deleteById(Long id);
    
    boolean existsById(Long id);
    
    boolean existsBySku(String sku);
    
    long countByStatus(ProductStatus status);
    
    long countByCategoryId(Long categoryId);
}