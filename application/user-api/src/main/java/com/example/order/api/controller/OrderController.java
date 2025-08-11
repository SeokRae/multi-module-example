package com.example.order.api.controller;

import com.example.common.security.jwt.UserPrincipal;
import com.example.common.web.response.ApiResponse;
import com.example.order.api.dto.*;
import com.example.order.domain.Order;
import com.example.order.domain.OrderItem;
import com.example.order.domain.OrderStatus;
import com.example.order.service.OrderService;
import com.example.product.domain.Product;
import com.example.product.service.ProductService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;
    private final ProductService productService;

    @PostMapping
    public ResponseEntity<ApiResponse<OrderResponse>> createOrder(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody OrderCreateRequest request) {
        
        List<OrderItem> orderItems = request.getOrderItems().stream()
                .map(item -> {
                    Product product = productService.findById(item.getProductId());
                    if (!product.isAvailable()) {
                        throw new IllegalArgumentException("상품이 판매 중지되었거나 재고가 없습니다: " + product.getName());
                    }
                    if (product.getStockQuantity() < item.getQuantity()) {
                        throw new IllegalArgumentException("재고가 부족합니다. 요청: " + item.getQuantity() + ", 재고: " + product.getStockQuantity());
                    }
                    
                    return OrderItem.create(
                            product.getId(),
                            product.getName(),
                            product.getPrice(),
                            item.getQuantity()
                    );
                })
                .collect(Collectors.toList());

        request.getOrderItems().forEach(item -> {
            productService.decreaseStock(item.getProductId(), item.getQuantity());
        });

        Order order = orderService.createOrder(
                userPrincipal.getId(),
                orderItems,
                request.getShippingAddress(),
                request.getBillingAddress()
        );

        OrderResponse response = OrderResponse.from(order);
        return ResponseEntity.ok(ApiResponse.success(response, "주문이 성공적으로 생성되었습니다"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<OrderResponse>> getOrder(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long id) {
        
        Order order = orderService.findById(id);
        
        if (!order.getUserId().equals(userPrincipal.getId()) && !userPrincipal.hasRole("ADMIN")) {
            throw new IllegalArgumentException("해당 주문에 접근할 권한이 없습니다");
        }

        OrderResponse response = OrderResponse.from(order);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<Page<OrderResponse>>> getMyOrders(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestParam(required = false) OrderStatus status,
            Pageable pageable) {
        
        Page<Order> orders;
        if (status != null) {
            orders = orderService.findByStatus(status, pageable);
            orders = orders.filter(order -> order.getUserId().equals(userPrincipal.getId()));
        } else {
            orders = orderService.findByUserId(userPrincipal.getId(), pageable);
        }

        Page<OrderResponse> responses = orders.map(OrderResponse::from);
        return ResponseEntity.ok(ApiResponse.success(responses));
    }

    @GetMapping("/admin/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Page<OrderResponse>>> getAllOrders(
            @RequestParam(required = false) OrderStatus status,
            Pageable pageable) {
        
        Page<Order> orders;
        if (status != null) {
            orders = orderService.findByStatus(status, pageable);
        } else {
            orders = orderService.findAll(pageable);
        }

        Page<OrderResponse> responses = orders.map(OrderResponse::from);
        return ResponseEntity.ok(ApiResponse.success(responses));
    }

    @PutMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<OrderResponse>> updateOrderStatus(
            @PathVariable Long id,
            @Valid @RequestBody OrderStatusUpdateRequest request) {
        
        Order order = orderService.updateOrderStatus(id, request.getStatus());
        OrderResponse response = OrderResponse.from(order);
        return ResponseEntity.ok(ApiResponse.success(response, "주문 상태가 업데이트되었습니다"));
    }

    @PutMapping("/{id}/confirm")
    public ResponseEntity<ApiResponse<OrderResponse>> confirmOrder(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long id) {
        
        Order existingOrder = orderService.findById(id);
        if (!existingOrder.getUserId().equals(userPrincipal.getId())) {
            throw new IllegalArgumentException("해당 주문에 접근할 권한이 없습니다");
        }

        Order order = orderService.confirmOrder(id);
        OrderResponse response = OrderResponse.from(order);
        return ResponseEntity.ok(ApiResponse.success(response, "주문이 확정되었습니다"));
    }

    @PutMapping("/{id}/cancel")
    public ResponseEntity<ApiResponse<OrderResponse>> cancelOrder(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable Long id) {
        
        Order existingOrder = orderService.findById(id);
        if (!existingOrder.getUserId().equals(userPrincipal.getId()) && !userPrincipal.hasRole("ADMIN")) {
            throw new IllegalArgumentException("해당 주문에 접근할 권한이 없습니다");
        }

        if (!existingOrder.canBeCancelled()) {
            throw new IllegalStateException("현재 상태에서는 주문을 취소할 수 없습니다");
        }

        existingOrder.getOrderItems().forEach(item -> {
            productService.updateStock(item.getProductId(), item.getQuantity());
        });

        Order order = orderService.cancelOrder(id);
        OrderResponse response = OrderResponse.from(order);
        return ResponseEntity.ok(ApiResponse.success(response, "주문이 취소되었습니다"));
    }

    @PutMapping("/{id}/pay")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<OrderResponse>> payOrder(@PathVariable Long id) {
        Order order = orderService.payOrder(id);
        OrderResponse response = OrderResponse.from(order);
        return ResponseEntity.ok(ApiResponse.success(response, "주문 결제가 완료되었습니다"));
    }

    @PutMapping("/{id}/ship")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<OrderResponse>> shipOrder(@PathVariable Long id) {
        Order order = orderService.shipOrder(id);
        OrderResponse response = OrderResponse.from(order);
        return ResponseEntity.ok(ApiResponse.success(response, "주문이 배송되었습니다"));
    }

    @PutMapping("/{id}/deliver")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<OrderResponse>> deliverOrder(@PathVariable Long id) {
        Order order = orderService.deliverOrder(id);
        OrderResponse response = OrderResponse.from(order);
        return ResponseEntity.ok(ApiResponse.success(response, "주문이 배송완료되었습니다"));
    }

    @GetMapping("/admin/status/{status}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<OrderResponse>>> getOrdersByStatus(@PathVariable OrderStatus status) {
        List<Order> orders = orderService.findByUserIdAndStatus(null, status);
        List<OrderResponse> responses = orders.stream()
                .map(OrderResponse::from)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(responses));
    }
}