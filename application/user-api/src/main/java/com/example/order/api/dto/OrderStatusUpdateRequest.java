package com.example.order.api.dto;

import com.example.order.domain.OrderStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.NotNull;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class OrderStatusUpdateRequest {

    @NotNull(message = "주문 상태는 필수입니다")
    private OrderStatus status;
}