package com.example.product.api.controller;

import com.example.common.security.jwt.UserPrincipal;
import com.example.common.web.response.ApiResponse;
import com.example.product.api.dto.ProductCreateRequest;
import com.example.product.api.dto.ProductResponse;
import com.example.product.api.dto.ProductUpdateRequest;
import com.example.product.domain.Product;
import com.example.product.domain.ProductStatus;
import com.example.product.service.ProductService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<ProductResponse>> createProduct(@Valid @RequestBody ProductCreateRequest request) {
        Product product = Product.builder()
                .name(request.getName())
                .description(request.getDescription())
                .price(request.getPrice())
                .stockQuantity(request.getStockQuantity())
                .categoryId(request.getCategoryId())
                .brand(request.getBrand())
                .sku(request.getSku())
                .build();
        
        Product created = productService.createProduct(product);
        ProductResponse response = ProductResponse.from(created);
        return ResponseEntity.ok(ApiResponse.success(response, "상품이 성공적으로 생성되었습니다"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ProductResponse>> getProduct(@PathVariable Long id) {
        productService.increaseViewCount(id);
        Product product = productService.findById(id);
        ProductResponse response = ProductResponse.from(product);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<Page<ProductResponse>>> getAllProducts(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) ProductStatus status,
            Pageable pageable) {
        
        Page<Product> products;
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            products = productService.searchProducts(keyword, pageable);
        } else if (categoryId != null) {
            products = productService.findByCategoryId(categoryId, pageable);
        } else if (minPrice != null && maxPrice != null) {
            products = productService.findByPriceRange(minPrice, maxPrice, pageable);
        } else if (status != null) {
            products = productService.findByStatus(status, pageable);
        } else {
            products = productService.findAll(pageable);
        }
        
        Page<ProductResponse> responses = products.map(ProductResponse::from);
        return ResponseEntity.ok(ApiResponse.success(responses));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<ProductResponse>> updateProduct(
            @PathVariable Long id,
            @Valid @RequestBody ProductUpdateRequest request) {
        
        Product existingProduct = productService.findById(id);
        Product product = Product.builder()
                .name(request.getName() != null ? request.getName() : existingProduct.getName())
                .description(request.getDescription() != null ? request.getDescription() : existingProduct.getDescription())
                .price(request.getPrice() != null ? request.getPrice() : existingProduct.getPrice())
                .stockQuantity(request.getStockQuantity() != null ? request.getStockQuantity() : existingProduct.getStockQuantity())
                .categoryId(request.getCategoryId() != null ? request.getCategoryId() : existingProduct.getCategoryId())
                .brand(request.getBrand() != null ? request.getBrand() : existingProduct.getBrand())
                .sku(request.getSku() != null ? request.getSku() : existingProduct.getSku())
                .build();
        
        Product updated = productService.updateProduct(id, product);
        ProductResponse response = ProductResponse.from(updated);
        return ResponseEntity.ok(ApiResponse.success(response, "상품이 업데이트되었습니다"));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
        return ResponseEntity.ok(ApiResponse.success(null, "상품이 삭제되었습니다"));
    }

    @PutMapping("/{id}/activate")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<ProductResponse>> activateProduct(@PathVariable Long id) {
        productService.activateProduct(id);
        Product product = productService.findById(id);
        ProductResponse response = ProductResponse.from(product);
        return ResponseEntity.ok(ApiResponse.success(response, "상품이 활성화되었습니다"));
    }

    @PutMapping("/{id}/deactivate")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<ProductResponse>> deactivateProduct(@PathVariable Long id) {
        productService.deactivateProduct(id);
        Product product = productService.findById(id);
        ProductResponse response = ProductResponse.from(product);
        return ResponseEntity.ok(ApiResponse.success(response, "상품이 비활성화되었습니다"));
    }

    @PutMapping("/{id}/discontinue")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<ProductResponse>> discontinueProduct(@PathVariable Long id) {
        productService.discontinueProduct(id);
        Product product = productService.findById(id);
        ProductResponse response = ProductResponse.from(product);
        return ResponseEntity.ok(ApiResponse.success(response, "상품이 단종되었습니다"));
    }

    @PutMapping("/{id}/stock")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<ProductResponse>> updateStock(
            @PathVariable Long id,
            @RequestParam Integer quantity) {
        productService.updateStock(id, quantity);
        Product product = productService.findById(id);
        ProductResponse response = ProductResponse.from(product);
        return ResponseEntity.ok(ApiResponse.success(response, "재고가 업데이트되었습니다"));
    }

    @GetMapping("/low-stock")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<ProductResponse>>> getLowStockProducts(
            @RequestParam(defaultValue = "10") Integer threshold) {
        List<Product> products = productService.findLowStockProducts(threshold);
        List<ProductResponse> responses = products.stream()
                .map(ProductResponse::from)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(responses));
    }

    @GetMapping("/popular")
    public ResponseEntity<ApiResponse<List<ProductResponse>>> getPopularProducts(
            @RequestParam(defaultValue = "10") Integer limit) {
        List<Product> products = productService.findPopularProducts(limit);
        List<ProductResponse> responses = products.stream()
                .map(ProductResponse::from)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(responses));
    }
}