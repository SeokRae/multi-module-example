package com.example.order.api.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import java.util.List;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class OrderCreateRequest {

    @NotEmpty(message = "주문 상품이 없습니다")
    @Valid
    private List<OrderItemRequest> orderItems;

    @Size(max = 1000, message = "배송 주소는 1000자를 초과할 수 없습니다")
    private String shippingAddress;

    @Size(max = 1000, message = "청구 주소는 1000자를 초과할 수 없습니다")
    private String billingAddress;
}