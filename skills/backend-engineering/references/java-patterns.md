# Java Backend Patterns

## Project Structure (Spring Boot)
```
src/main/java/com/company/project/
├── controller/     # REST controllers (request handling)
├── service/        # Business logic
├── repository/     # Data access (JPA, JDBC)
├── model/          # Entities, DTOs
├── config/         # Configuration classes
├── exception/      # Custom exceptions, global handler
└── util/           # Shared utilities
```

## Layered Architecture
```java
// Controller — handles HTTP, delegates to service
@RestController
@RequestMapping("/api/v1/users")
public class UserController {
    private final UserService userService;

    @PostMapping
    public ResponseEntity<UserResponse> create(@Valid @RequestBody CreateUserRequest request) {
        UserResponse user = userService.create(request);
        return ResponseEntity.status(201).body(user);
    }
}

// Service — business logic, no HTTP awareness
@Service
public class UserService {
    private final UserRepository userRepository;

    public UserResponse create(CreateUserRequest request) {
        // validate, transform, persist
    }
}

// Repository — data access only
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
}
```

## DTOs and Validation
```java
public record CreateUserRequest(
    @NotBlank @Size(max = 100) String name,
    @NotBlank @Email String email
) {}

public record UserResponse(Long id, String name, String email, Instant createdAt) {}
```
Use records for immutable DTOs. Use Bean Validation annotations for input validation.

## Global Error Handling
```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(AppException.class)
    public ResponseEntity<ErrorResponse> handleAppException(AppException e) {
        return ResponseEntity.status(e.getStatus())
            .body(new ErrorResponse(e.getCode(), e.getMessage()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleUnexpected(Exception e) {
        log.error("Unexpected error", e);
        return ResponseEntity.status(500)
            .body(new ErrorResponse("internal", "Internal error"));
    }
}
```

## Dependency Injection
- Use constructor injection (not field injection)
- Mark dependencies as `final`
- Use `@RequiredArgsConstructor` (Lombok) or explicit constructors

## Configuration
```java
@ConfigurationProperties(prefix = "app")
public record AppConfig(String apiKey, int maxRetries, Duration timeout) {}
```
Externalize config via `application.yml` + environment variables. Never hardcode.
