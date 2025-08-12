package com.example.batch.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserStatistics {
    
    private Long userId;
    private String userName;
    private String userEmail;
    private String userRole;
    private LocalDateTime registrationDate;
    private LocalDateTime lastActiveDate;
    private Boolean isActive;
    private LocalDateTime statisticsDate;
    
    // 추가 통계 필드들
    private Long totalOrders;
    private Double totalSpent;
    private Integer loginCount;
    private LocalDateTime lastLoginDate;
}