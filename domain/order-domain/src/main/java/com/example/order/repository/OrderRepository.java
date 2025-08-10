package com.example.order.repository;

import com.example.order.domain.Order;
import com.example.order.domain.OrderStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface OrderRepository {
    
    Order save(Order order);
    
    Optional<Order> findById(Long id);
    
    List<Order> findByIds(List<Long> ids);
    
    Page<Order> findAll(Pageable pageable);
    
    Page<Order> findByUserId(Long userId, Pageable pageable);
    
    Page<Order> findByStatus(OrderStatus status, Pageable pageable);
    
    Page<Order> findByUserIdAndStatus(Long userId, OrderStatus status, Pageable pageable);
    
    List<Order> findByUserIdOrderByCreatedAtDesc(Long userId);
    
    Page<Order> findByOrderDateBetween(LocalDateTime startDate, LocalDateTime endDate, Pageable pageable);
    
    Page<Order> findByTotalAmountBetween(BigDecimal minAmount, BigDecimal maxAmount, Pageable pageable);
    
    List<Order> findByCreatedAtAfter(LocalDateTime date);
    
    List<Order> findRecentOrdersByUserId(Long userId, int limit);
    
    void deleteById(Long id);
    
    boolean existsById(Long id);
    
    long countByStatus(OrderStatus status);
    
    long countByUserId(Long userId);
    
    long countByUserIdAndStatus(Long userId, OrderStatus status);
    
    BigDecimal sumTotalAmountByStatus(OrderStatus status);
    
    BigDecimal sumTotalAmountByUserIdAndDateBetween(Long userId, LocalDateTime startDate, LocalDateTime endDate);
}