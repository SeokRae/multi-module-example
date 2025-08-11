package com.example.order.service;

import com.example.order.domain.Order;
import com.example.order.domain.OrderItem;
import com.example.order.domain.OrderStatus;
import com.example.order.repository.OrderRepository;
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

@Slf4j
@Service
@Validated
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class OrderService {

    private final OrderRepository orderRepository;

    @Transactional
    public Order createOrder(@NotNull Long userId, @Valid @NotNull List<OrderItem> orderItems, 
                           String shippingAddress, String billingAddress) {
        log.info("Creating new order for user: {}", userId);
        
        if (orderItems.isEmpty()) {
            throw new IllegalArgumentException("주문 상품이 없습니다");
        }

        BigDecimal totalAmount = orderItems.stream()
                .map(OrderItem::getTotalPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        Order order = Order.builder()
                .userId(userId)
                .orderItems(orderItems)
                .totalAmount(totalAmount)
                .status(OrderStatus.PENDING)
                .shippingAddress(shippingAddress)
                .billingAddress(billingAddress)
                .orderDate(LocalDateTime.now())
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        Order saved = orderRepository.save(order);
        log.info("Order created successfully with ID: {}", saved.getId());
        return saved;
    }

    public Order findById(@NotNull Long id) {
        return orderRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("주문을 찾을 수 없습니다: " + id));
    }

    public Page<Order> findByUserId(@NotNull Long userId, Pageable pageable) {
        return orderRepository.findByUserId(userId, pageable);
    }

    public Page<Order> findAll(Pageable pageable) {
        return orderRepository.findAll(pageable);
    }

    public Page<Order> findByStatus(@NotNull OrderStatus status, Pageable pageable) {
        return orderRepository.findByStatus(status, pageable);
    }

    public List<Order> findByUserIdAndStatus(@NotNull Long userId, @NotNull OrderStatus status) {
        return orderRepository.findByUserIdAndStatus(userId, status);
    }

    @Transactional
    public Order confirmOrder(@NotNull Long id) {
        log.info("Confirming order with ID: {}", id);
        Order order = findById(id);
        order.confirm();
        Order saved = orderRepository.save(order);
        log.info("Order confirmed: {}", id);
        return saved;
    }

    @Transactional
    public Order payOrder(@NotNull Long id) {
        log.info("Processing payment for order ID: {}", id);
        Order order = findById(id);
        order.pay();
        Order saved = orderRepository.save(order);
        log.info("Order payment processed: {}", id);
        return saved;
    }

    @Transactional
    public Order shipOrder(@NotNull Long id) {
        log.info("Shipping order with ID: {}", id);
        Order order = findById(id);
        order.ship();
        Order saved = orderRepository.save(order);
        log.info("Order shipped: {}", id);
        return saved;
    }

    @Transactional
    public Order deliverOrder(@NotNull Long id) {
        log.info("Delivering order with ID: {}", id);
        Order order = findById(id);
        order.deliver();
        Order saved = orderRepository.save(order);
        log.info("Order delivered: {}", id);
        return saved;
    }

    @Transactional
    public Order cancelOrder(@NotNull Long id) {
        log.info("Cancelling order with ID: {}", id);
        Order order = findById(id);
        order.cancel();
        Order saved = orderRepository.save(order);
        log.info("Order cancelled: {}", id);
        return saved;
    }

    @Transactional
    public Order updateOrderStatus(@NotNull Long id, @NotNull OrderStatus status) {
        log.info("Updating order status for ID: {} to {}", id, status);
        Order order = findById(id);
        
        switch (status) {
            case CONFIRMED:
                order.confirm();
                break;
            case PAID:
                order.pay();
                break;
            case SHIPPED:
                order.ship();
                break;
            case DELIVERED:
                order.deliver();
                break;
            case CANCELLED:
                order.cancel();
                break;
            default:
                throw new IllegalArgumentException("지원하지 않는 주문 상태입니다: " + status);
        }
        
        Order saved = orderRepository.save(order);
        log.info("Order status updated: {} -> {}", id, status);
        return saved;
    }

    public boolean existsById(@NotNull Long id) {
        return orderRepository.existsById(id);
    }

    public long countByUserId(@NotNull Long userId) {
        return orderRepository.countByUserId(userId);
    }

    public long countByStatus(@NotNull OrderStatus status) {
        return orderRepository.countByStatus(status);
    }

    public BigDecimal getTotalAmountByUserId(@NotNull Long userId) {
        return orderRepository.getTotalAmountByUserId(userId);
    }
}