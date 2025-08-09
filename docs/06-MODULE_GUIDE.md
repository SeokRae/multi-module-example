# 모듈별 개발 가이드

## 1. Common 모듈

### 1.1 common-core
공통 기능과 유틸리티를 제공하는 핵심 모듈입니다.

#### 주요 구성요소

**예외 처리**
```java
// BusinessException: 비즈니스 로직 예외
public class BusinessException extends RuntimeException {
    private final String code;
    
    public BusinessException(String code, String message) {
        super(message);
        this.code = code;
    }
}

// ErrorCode: 시스템 전체 에러 코드 정의
@Getter
@RequiredArgsConstructor
public enum ErrorCode {
    USER_NOT_FOUND("USER_001", "사용자를 찾을 수 없습니다"),
    USER_ALREADY_EXISTS("USER_002", "이미 존재하는 사용자입니다");
    
    private final String code;
    private final String message;
}
```

#### 사용 방법
```java
// 다른 모듈에서 예외 발생
throw new BusinessException(ErrorCode.USER_NOT_FOUND.getCode(), 
                           ErrorCode.USER_NOT_FOUND.getMessage());
```

### 1.2 common-web
웹 애플리케이션 공통 기능을 제공합니다.

#### 주요 구성요소

**표준 API 응답**
```java
@Getter
public class ApiResponse<T> {
    private boolean success;
    private T data;
    private String message;
    private String code;
    
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(true, data, "성공", null);
    }
    
    public static <T> ApiResponse<T> error(String code, String message) {
        return new ApiResponse<>(false, null, message, code);
    }
}
```

**전역 예외 처리**
```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiResponse<Void>> handleBusinessException(BusinessException e) {
        ApiResponse<Void> response = ApiResponse.error(e.getCode(), e.getMessage());
        return ResponseEntity.badRequest().body(response);
    }
}
```

## 2. Domain 모듈

### 2.1 user-domain
사용자 관련 비즈니스 로직을 담당합니다.

#### 도메인 모델
```java
@Getter
@Builder
public class User {
    private Long id;
    private String email;
    private String name;
    private UserStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // 비즈니스 메서드
    public void activate() {
        this.status = UserStatus.ACTIVE;
        this.updatedAt = LocalDateTime.now();
    }
    
    public void deactivate() {
        this.status = UserStatus.INACTIVE;
        this.updatedAt = LocalDateTime.now();
    }
    
    public boolean isActive() {
        return UserStatus.ACTIVE.equals(this.status);
    }
}
```

#### 리포지토리 인터페이스
```java
public interface UserRepository {
    User save(User user);
    Optional<User> findById(Long id);
    Optional<User> findByEmail(String email);
    List<User> findAll();
    void delete(User user);
    boolean existsByEmail(String email);
}
```

#### 도메인 서비스
```java
@Service
@RequiredArgsConstructor
public class UserService {
    
    private final UserRepository userRepository;
    
    public User createUser(String email, String name) {
        // 비즈니스 규칙: 이메일 중복 검사
        if (userRepository.existsByEmail(email)) {
            throw new BusinessException(ErrorCode.USER_ALREADY_EXISTS.getCode(), 
                    ErrorCode.USER_ALREADY_EXISTS.getMessage());
        }
        
        // 도메인 객체 생성
        User user = User.builder()
                .email(email)
                .name(name)
                .status(UserStatus.ACTIVE)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        
        return userRepository.save(user);
    }
}
```

### 2.2 order-domain
주문 관련 비즈니스 로직을 담당합니다.

#### 도메인 모델 설계 원칙
```java
@Getter
@Builder
public class Order {
    private Long id;
    private Long userId;
    private List<OrderItem> orderItems;
    private BigDecimal totalAmount;
    private OrderStatus status;
    private LocalDateTime createdAt;
    
    // 비즈니스 규칙이 포함된 메서드
    public void confirm() {
        validateCanConfirm();
        this.status = OrderStatus.CONFIRMED;
        this.updatedAt = LocalDateTime.now();
    }
    
    public void cancel() {
        validateCanCancel();
        this.status = OrderStatus.CANCELLED;
        this.updatedAt = LocalDateTime.now();
    }
    
    private void validateCanCancel() {
        if (status == OrderStatus.SHIPPED || status == OrderStatus.DELIVERED) {
            throw new BusinessException("ORDER_003", 
                "배송 중이거나 완료된 주문은 취소할 수 없습니다");
        }
    }
}
```

## 3. Infrastructure 모듈

### 3.1 data-access
데이터 영속성과 관련된 구현을 담당합니다.

#### JPA 엔티티
```java
@Entity
@Table(name = "users")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    @Column(nullable = false)
    private String name;
    
    @Enumerated(EnumType.STRING)
    private UserStatus status;
    
    // 도메인 모델 변환
    public User toDomain() {
        return User.builder()
                .id(id)
                .email(email)
                .name(name)
                .status(status)
                .createdAt(createdAt)
                .updatedAt(updatedAt)
                .build();
    }
    
    public static UserEntity fromDomain(User user) {
        return UserEntity.builder()
                .id(user.getId())
                .email(user.getEmail())
                .name(user.getName())
                .status(user.getStatus())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }
}
```

#### 리포지토리 구현체
```java
@Repository
@RequiredArgsConstructor
public class UserRepositoryImpl implements UserRepository {
    
    private final UserJpaRepository jpaRepository;
    
    @Override
    public User save(User user) {
        UserEntity entity = user.getId() == null 
                ? UserEntity.fromDomain(user)
                : jpaRepository.findById(user.getId())
                    .map(existingEntity -> {
                        existingEntity.updateFromDomain(user);
                        return existingEntity;
                    })
                    .orElse(UserEntity.fromDomain(user));
        
        return jpaRepository.save(entity).toDomain();
    }
    
    @Override
    public Optional<User> findById(Long id) {
        return jpaRepository.findById(id)
                .map(UserEntity::toDomain);
    }
}
```

## 4. Application 모듈

### 4.1 user-api
사용자 REST API를 제공합니다.

#### DTO 설계
```java
// 요청 DTO
@Getter
@NoArgsConstructor
public class UserCreateRequest {
    
    @NotBlank(message = "이메일은 필수입니다")
    @Email(message = "유효한 이메일 형식이 아닙니다")
    private String email;
    
    @NotBlank(message = "이름은 필수입니다")
    private String name;
}

// 응답 DTO
@Getter
@Builder
public class UserResponse {
    
    private Long id;
    private String email;
    private String name;
    private UserStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public static UserResponse from(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .name(user.getName())
                .status(user.getStatus())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }
}
```

#### 컨트롤러 설계
```java
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    
    @PostMapping
    public ResponseEntity<ApiResponse<UserResponse>> createUser(
            @Valid @RequestBody UserCreateRequest request) {
        
        User user = userService.createUser(request.getEmail(), request.getName());
        UserResponse response = UserResponse.from(user);
        
        return ResponseEntity.ok(
            ApiResponse.success(response, "사용자가 성공적으로 생성되었습니다")
        );
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<UserResponse>> getUser(@PathVariable Long id) {
        User user = userService.findById(id);
        UserResponse response = UserResponse.from(user);
        
        return ResponseEntity.ok(ApiResponse.success(response));
    }
}
```

### 4.2 batch-app
배치 처리 애플리케이션입니다.

#### Spring Batch Job 구성
```java
@Configuration
@RequiredArgsConstructor
public class UserBatchJobConfiguration {
    
    private final JobBuilderFactory jobBuilderFactory;
    private final StepBuilderFactory stepBuilderFactory;
    private final UserService userService;
    
    @Bean
    public Job userProcessingJob() {
        return jobBuilderFactory.get("userProcessingJob")
                .start(userProcessingStep())
                .build();
    }
    
    @Bean
    public Step userProcessingStep() {
        return stepBuilderFactory.get("userProcessingStep")
                .<User, User>chunk(100)
                .reader(userReader())
                .processor(userProcessor())
                .writer(userWriter())
                .build();
    }
}
```

## 5. 개발 가이드

### 5.1 새로운 기능 추가 절차

1. **도메인 모델 설계**
   ```java
   // 1. 도메인 엔티티 생성
   @Getter
   @Builder
   public class Product {
       private Long id;
       private String name;
       private BigDecimal price;
       
       public void updatePrice(BigDecimal newPrice) {
           validatePrice(newPrice);
           this.price = newPrice;
       }
   }
   ```

2. **리포지토리 인터페이스 정의**
   ```java
   public interface ProductRepository {
       Product save(Product product);
       Optional<Product> findById(Long id);
       List<Product> findByCategory(String category);
   }
   ```

3. **도메인 서비스 구현**
   ```java
   @Service
   @RequiredArgsConstructor
   public class ProductService {
       private final ProductRepository productRepository;
       
       public Product createProduct(String name, BigDecimal price) {
           // 비즈니스 로직 구현
       }
   }
   ```

4. **인프라스트럭처 구현**
   ```java
   @Entity
   public class ProductEntity {
       // JPA 매핑
   }
   
   @Repository
   public class ProductRepositoryImpl implements ProductRepository {
       // 리포지토리 구현
   }
   ```

5. **API 컨트롤러 구현**
   ```java
   @RestController
   @RequestMapping("/api/products")
   public class ProductController {
       // REST API 구현
   }
   ```

### 5.2 테스트 작성 가이드

#### 도메인 테스트
```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    @DisplayName("사용자 생성 시 이메일 중복이면 예외 발생")
    void createUser_WhenEmailExists_ThrowsException() {
        // given
        String email = "test@example.com";
        when(userRepository.existsByEmail(email)).thenReturn(true);
        
        // when & then
        assertThatThrownBy(() -> userService.createUser(email, "Test User"))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("이미 존재하는 사용자입니다");
    }
}
```

#### API 테스트
```java
@WebMvcTest(UserController.class)
class UserControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService userService;
    
    @Test
    @DisplayName("사용자 생성 API 성공")
    void createUser_Success() throws Exception {
        // given
        UserCreateRequest request = new UserCreateRequest("test@example.com", "Test User");
        User mockUser = createMockUser();
        when(userService.createUser(any(), any())).thenReturn(mockUser);
        
        // when & then
        mockMvc.perform(post("/api/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpected(status().isOk())
                .andExpected(jsonPath("$.success").value(true))
                .andExpected(jsonPath("$.data.email").value("test@example.com"));
    }
}
```

### 5.3 주의사항

#### 의존성 방향 준수
- Domain Layer는 다른 계층에 의존하면 안됨
- Infrastructure는 Domain을 구현하되 Domain이 Infrastructure를 알아서는 안됨

#### 트랜잭션 경계
- Domain Service에서는 `@Transactional` 사용
- Controller에서는 트랜잭션을 시작하지 않음

#### 예외 처리
- 비즈니스 로직 예외는 `BusinessException` 사용
- 기술적 예외는 `GlobalExceptionHandler`에서 처리

---

이 가이드는 각 모듈의 역할과 개발 방법을 제시합니다.
새로운 기능 개발 시 이 가이드를 참고하여 일관성 있는 코드를 작성해주세요.