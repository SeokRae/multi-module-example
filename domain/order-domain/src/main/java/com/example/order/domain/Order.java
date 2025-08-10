package com.example.order.domain;

import lombok.Builder;
import lombok.Getter;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.ToString;
import lombok.EqualsAndHashCode;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString(exclude = "orderItems")
@EqualsAndHashCode(of = "id")
public class Order {
    
    private Long id;
    
    @NotNull(message = "사용자 ID는 필수입니다")
    private Long userId;
    
    @NotEmpty(message = "주문 상품이 없습니다")
    private List<OrderItem> orderItems = new ArrayList<>();
    
    @NotNull(message = "총 금액은 필수입니다")
    @DecimalMin(value = "0.0", inclusive = false, message = "총 금액은 0보다 커야 합니다")
    private BigDecimal totalAmount;
    
    @NotNull(message = "주문 상태는 필수입니다")
    private OrderStatus status;
    
    @Size(max = 1000, message = "배송 주소는 1000자를 초과할 수 없습니다")
    private String shippingAddress;
    
    @Size(max = 1000, message = "청구 주소는 1000자를 초과할 수 없습니다")
    private String billingAddress;
    
    private LocalDateTime orderDate;
    private LocalDateTime shippedDate;
    private LocalDateTime deliveredDate;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public void addOrderItem(OrderItem orderItem) {
        if (orderItem == null) {
            throw new IllegalArgumentException("주문 상품은 null일 수 없습니다");
        }
        this.orderItems.add(orderItem);
        recalculateTotalAmount();
    }
    
    public void removeOrderItem(Long orderItemId) {
        this.orderItems.removeIf(item -> item.getId().equals(orderItemId));
        recalculateTotalAmount();
    }
    
    public void recalculateTotalAmount() {
        this.totalAmount = orderItems.stream()
                .map(OrderItem::getTotalPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        this.updatedAt = LocalDateTime.now();
    }
    
    public void confirm() {
        validateStatusTransition(OrderStatus.CONFIRMED);
        this.status = OrderStatus.CONFIRMED;
        this.updatedAt = LocalDateTime.now();
    }
    
    public void pay() {
        validateStatusTransition(OrderStatus.PAID);
        this.status = OrderStatus.PAID;
        this.updatedAt = LocalDateTime.now();
    }
    
    public void ship() {
        validateStatusTransition(OrderStatus.SHIPPED);
        this.status = OrderStatus.SHIPPED;
        this.shippedDate = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    public void deliver() {
        validateStatusTransition(OrderStatus.DELIVERED);
        this.status = OrderStatus.DELIVERED;
        this.deliveredDate = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    public void cancel() {
        if (!canBeCancelled()) {
            throw new IllegalStateException("현재 상태에서는 주문을 취소할 수 없습니다: " + status);
        }
        this.status = OrderStatus.CANCELLED;
        this.updatedAt = LocalDateTime.now();
    }
    
    public boolean canBeCancelled() {
        return status == OrderStatus.PENDING || status == OrderStatus.CONFIRMED || status == OrderStatus.PAID;
    }
    
    public boolean isCompleted() {
        return status == OrderStatus.DELIVERED;
    }
    
    public boolean isCancelled() {
        return status == OrderStatus.CANCELLED;
    }
    
    public boolean isPaid() {
        return status == OrderStatus.PAID || status == OrderStatus.SHIPPED || status == OrderStatus.DELIVERED;
    }
    
    public int getTotalItemCount() {
        return orderItems.stream().mapToInt(OrderItem::getQuantity).sum();
    }
    
    private void validateStatusTransition(OrderStatus newStatus) {
        if (!isValidStatusTransition(this.status, newStatus)) {
            throw new IllegalStateException(
                String.format("주문 상태를 %s에서 %s로 변경할 수 없습니다", 
                    this.status.getDescription(), newStatus.getDescription()));
        }
    }
    
    private boolean isValidStatusTransition(OrderStatus from, OrderStatus to) {
        switch (from) {
            case PENDING:
                return to == OrderStatus.CONFIRMED || to == OrderStatus.CANCELLED;
            case CONFIRMED:
                return to == OrderStatus.PAID || to == OrderStatus.CANCELLED;
            case PAID:
                return to == OrderStatus.SHIPPED || to == OrderStatus.CANCELLED;
            case SHIPPED:
                return to == OrderStatus.DELIVERED;
            case DELIVERED:
            case CANCELLED:
                return false;
            default:
                return false;
        }
    }
}