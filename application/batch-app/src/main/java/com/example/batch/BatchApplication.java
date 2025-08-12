package com.example.batch;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication(scanBasePackages = {
        "com.example.common",
        "com.example.user",
        "com.example.order", 
        "com.example.product",
        "com.example.infrastructure",
        "com.example.batch"
})
@EntityScan({"com.example.user.domain", "com.example.order.domain", "com.example.product.domain"})
@EnableJpaRepositories({"com.example.user.repository", "com.example.order.repository", "com.example.product.repository"})
@EnableScheduling
public class BatchApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(BatchApplication.class, args);
    }
}