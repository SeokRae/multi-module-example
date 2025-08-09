package com.example.user.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication(scanBasePackages = {
        "com.example.common",
        "com.example.user",
        "com.example.infrastructure"
})
@EntityScan("com.example.infrastructure")
@EnableJpaRepositories("com.example.infrastructure")
public class UserApiApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(UserApiApplication.class, args);
    }
}