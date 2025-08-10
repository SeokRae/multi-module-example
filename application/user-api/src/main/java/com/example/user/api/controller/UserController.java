package com.example.user.api.controller;

import com.example.common.security.jwt.UserPrincipal;
import com.example.common.web.response.ApiResponse;
import com.example.user.api.dto.PasswordChangeRequest;
import com.example.user.api.dto.UserCreateRequest;
import com.example.user.api.dto.UserResponse;
import com.example.user.api.dto.UserUpdateRequest;
import com.example.user.domain.User;
import com.example.user.domain.UserRole;
import com.example.user.domain.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    
    // Public endpoint for user registration
    @PostMapping
    public ResponseEntity<ApiResponse<UserResponse>> registerUser(@Valid @RequestBody UserCreateRequest request) {
        User user = userService.registerUser(request.getEmail(), request.getName(), 
                request.getPassword(), request.getPhone());
        UserResponse response = UserResponse.from(user);
        return ResponseEntity.ok(ApiResponse.success(response, "사용자가 성공적으로 등록되었습니다"));
    }
    
    // Get current user profile
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        User user = userService.findById(userPrincipal.getId());
        UserResponse response = UserResponse.from(user);
        return ResponseEntity.ok(ApiResponse.success(response));
    }
    
    // Update current user profile
    @PutMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> updateCurrentUser(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody UserUpdateRequest request) {
        User user = userService.updateUserProfile(userPrincipal.getId(), request.getName(), request.getPhone());
        UserResponse response = UserResponse.from(user);
        return ResponseEntity.ok(ApiResponse.success(response, "프로필이 업데이트되었습니다"));
    }
    
    // Change password
    @PutMapping("/me/password")
    public ResponseEntity<ApiResponse<Void>> changePassword(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody PasswordChangeRequest request) {
        userService.changeUserPassword(userPrincipal.getId(), request.getCurrentPassword(), request.getNewPassword());
        return ResponseEntity.ok(ApiResponse.success(null, "비밀번호가 변경되었습니다"));
    }
    
    // Get specific user (Admin only)
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<UserResponse>> getUser(@PathVariable Long id) {
        User user = userService.findById(id);
        UserResponse response = UserResponse.from(user);
        return ResponseEntity.ok(ApiResponse.success(response));
    }
    
    // Get all users with pagination (Admin only)
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Page<UserResponse>>> getAllUsers(Pageable pageable) {
        List<User> users = userService.findAllUsers();
        List<UserResponse> responses = users.stream()
                .map(UserResponse::from)
                .collect(Collectors.toList());
        
        int start = (int) pageable.getOffset();
        int end = Math.min((start + pageable.getPageSize()), responses.size());
        Page<UserResponse> page = new PageImpl<>(responses.subList(start, end), pageable, responses.size());
        
        return ResponseEntity.ok(ApiResponse.success(page));
    }
    
    // Update user (Admin only)
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<UserResponse>> updateUser(
            @PathVariable Long id,
            @Valid @RequestBody UserUpdateRequest request) {
        User user = userService.updateUserProfile(id, request.getName(), request.getPhone());
        UserResponse response = UserResponse.from(user);
        return ResponseEntity.ok(ApiResponse.success(response, "사용자 정보가 업데이트되었습니다"));
    }
    
    // Activate user (Admin only)
    @PutMapping("/{id}/activate")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<UserResponse>> activateUser(@PathVariable Long id) {
        User user = userService.activateUser(id);
        UserResponse response = UserResponse.from(user);
        return ResponseEntity.ok(ApiResponse.success(response, "사용자가 활성화되었습니다"));
    }
    
    // Deactivate user (Admin only)
    @PutMapping("/{id}/deactivate")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<UserResponse>> deactivateUser(@PathVariable Long id) {
        User user = userService.deactivateUser(id);
        UserResponse response = UserResponse.from(user);
        return ResponseEntity.ok(ApiResponse.success(response, "사용자가 비활성화되었습니다"));
    }
    
    // Get users by role (Admin only)
    @GetMapping("/role/{role}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<UserResponse>>> getUsersByRole(@PathVariable UserRole role) {
        List<User> users = userService.findUsersByRole(role);
        List<UserResponse> responses = users.stream()
                .map(UserResponse::from)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(responses));
    }
    
    // Delete user (Admin only)
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> deleteUser(@PathVariable Long id) {
        User user = userService.findById(id);
        userService.deactivateUser(id); // Soft delete by deactivating
        return ResponseEntity.ok(ApiResponse.success(null, "사용자가 삭제되었습니다"));
    }
}