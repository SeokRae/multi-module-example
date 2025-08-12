package com.example.batch.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderReport {
    
    private Long orderId;
    private Long userId;
    private String userEmail;
    private String orderStatus;
    private BigDecimal totalAmount;
    private Integer totalItems;
    private LocalDateTime orderDate;
    private LocalDateTime reportDate;
    
    // 집계 통계
    private String reportPeriod; // DAILY, WEEKLY, MONTHLY
    private Long totalOrderCount;
    private BigDecimal totalRevenue;
    private Double averageOrderValue;
}