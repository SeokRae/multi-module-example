package com.example.user.api.controller;

import com.example.common.web.response.ApiResponse;
import com.example.user.api.dto.UserCreateRequest;
import com.example.user.api.dto.UserResponse;
import com.example.user.domain.User;
import com.example.user.domain.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    
    @PostMapping
    public ResponseEntity<ApiResponse<UserResponse>> createUser(@Valid @RequestBody UserCreateRequest request) {
        User user = userService.createUser(request.getEmail(), request.getName());
        UserResponse response = UserResponse.from(user);
        return ResponseEntity.ok(ApiResponse.success(response, "사용자가 성공적으로 생성되었습니다"));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<UserResponse>> getUser(@PathVariable Long id) {
        User user = userService.findById(id);
        UserResponse response = UserResponse.from(user);
        return ResponseEntity.ok(ApiResponse.success(response));
    }
    
    @GetMapping
    public ResponseEntity<ApiResponse<List<UserResponse>>> getAllUsers() {
        List<User> users = userService.findAllUsers();
        List<UserResponse> responses = users.stream()
                .map(UserResponse::from)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(responses));
    }
    
    @PutMapping("/{id}/activate")
    public ResponseEntity<ApiResponse<UserResponse>> activateUser(@PathVariable Long id) {
        User user = userService.activateUser(id);
        UserResponse response = UserResponse.from(user);
        return ResponseEntity.ok(ApiResponse.success(response, "사용자가 활성화되었습니다"));
    }
}