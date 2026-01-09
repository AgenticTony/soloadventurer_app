# SoloAdventurer Clean Architecture

## Overview

This document outlines the clean architecture approach we are implementing in the SoloAdventurer app. The architecture is designed to create a maintainable, testable, and scalable codebase by separating concerns and enforcing dependency rules.

## Core Principles

1. **Separation of Concerns**: Each layer has a specific responsibility and should not be concerned with the implementation details of other layers.
2. **Dependency Rule**: Dependencies always point inward. Outer layers can depend on inner layers, but inner layers cannot depend on outer layers.
3. **Abstraction**: Inner layers define interfaces that outer layers implement.
4. **Testability**: Each layer can be tested independently with appropriate mocks.
5. **Feature-Based Organization**: Code is organized by feature rather than by layer, promoting cohesion and reducing coupling.
6. **Observability First**: Built-in monitoring and tracing using OpenTelemetry from the ground up.
7. **State Management**: Riverpod-based state management with AsyncValue pattern.
8. **Authentication**: AWS Cognito integration with proper token lifecycle management.

## Architecture Layers

### 1. Domain Layer

The domain layer is the innermost layer and contains the business logic of the application. It is independent of any framework or implementation details.

#### Components:

- **Entities**: Core business objects that represent the domain concepts.
- **Use Cases**: Application-specific business rules that orchestrate the flow of data to and from entities.
- **Repository Interfaces**: Abstractions that define how data is accessed and manipulated.
- **Value Objects**: Immutable objects that represent domain concepts without identity.

### 2. Data Layer

The data layer is responsible for data retrieval and storage. It implements the repository interfaces defined in the domain layer.

#### Components:

- **Repositories**: Implementations of the repository interfaces defined in the domain layer.
- **Data Sources**: Local and remote data sources that provide data to repositories.
- **Models**: Data transfer objects (DTOs) that map to and from domain entities.
- **AWS Cognito Integration**: Authentication and user management implementation.

### 3. Presentation Layer

The presentation layer is responsible for displaying data to the user and handling user interactions.

#### Components:

- **UI**: Widgets and screens that display data to the user.
- **State Management**: Riverpod providers and state notifiers.
- **View Models**: Objects that transform domain entities into a format suitable for display.
- **Error Handling**: Comprehensive error handling with AsyncValue.

### 4. Infrastructure Layer

The infrastructure layer provides cross-cutting concerns and technical capabilities.

#### Components:

- **Monitoring**: OpenTelemetry integration for metrics, traces, and logs.
- **Network**: API clients and interceptors.
- **Storage**: Local storage implementations.
- **Security**: Authentication and encryption.

## State Management with Riverpod

### Authentication State Pattern

```dart
@riverpod
class AuthState extends _$AuthState {
  @override
  AsyncValue<AuthState> build() => const AsyncValue.data(AuthState.unauthenticated());

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.signIn(email, password));
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.signOut());
  }
}
```

### Token Management

```dart
@riverpod
class TokenManager extends _$TokenManager {
  @override
  AsyncValue<TokenState> build() => const AsyncValue.data(TokenState.empty());

  Future<void> refreshToken() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.refreshToken());
  }

  Future<void> revokeToken() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.revokeToken());
  }
}
```

### Session Management

```dart
@riverpod
class SessionManager extends _$SessionManager {
  Timer? _refreshTimer;

  @override
  AsyncValue<SessionState> build() {
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });
    return const AsyncValue.data(SessionState.initial());
  }

  void startSessionMonitoring() {
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 45),
      (_) => _refreshTokenIfNeeded(),
    );
  }
}
```

## Feature-Based Organization

Each feature is organized as a vertical slice through all layers:

```
lib/
├── app/                 # Core app infrastructure
│   ├── config/         # Environment configurations
│   ├── di/            # Dependency injection
│   └── bootstrap.dart  # App initialization
│
├── features/           # Feature modules
│   ├── auth/          # Authentication feature
│   │   ├── data/      # AWS Cognito integration
│   │   ├── domain/    # Auth business logic
│   │   └── presentation/  # Auth UI and state
│   └── trips/         # Trip management
│
└── shared/            # Cross-cutting concerns
    ├── monitoring/    # OpenTelemetry integration
    ├── network/       # Network handling
    └── storage/       # Local storage
```

## Testing Strategy

### Unit Tests

- Domain layer tests with no external dependencies
- Repository tests with mocked data sources
- Provider tests with mocked dependencies
- Token management tests
- Session handling tests

### Widget Tests

- Screen component tests
- Form validation tests
- Navigation flow tests
- Error handling tests

### Integration Tests

- Full authentication flow
- Token refresh flow
- Session management
- Error recovery scenarios

## Error Handling

### Riverpod Error Handling

```dart
@riverpod
class ErrorHandler extends _$ErrorHandler {
  @override
  void build() {
    ref.listen(authStateProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          // Handle error appropriately
          _handleError(error, stackTrace);
        },
      );
    });
  }
}
```

### AWS Cognito Error Mapping

```dart
sealed class AuthError {
  final String message;
  final String code;
}

class UserNotFoundError extends AuthError {
  UserNotFoundError() : super(
    message: 'No account found with this email',
    code: 'USER_NOT_FOUND',
  );
}

class InvalidCredentialsError extends AuthError {
  InvalidCredentialsError() : super(
    message: 'Invalid email or password',
    code: 'INVALID_CREDENTIALS',
  );
}
```

## Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  amazon_cognito_identity_dart_2: ^3.5.0
  dio: ^5.3.0
  get_it: ^7.6.0
  shared_preferences: ^2.2.0
  flutter_secure_storage: ^9.0.0
```

### Testing Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

## Migration Strategy

The migration to clean architecture will be incremental:

1. Set up the core infrastructure (app/, shared/).
2. Implement OpenTelemetry monitoring abstraction.
3. Migrate one feature at a time, starting with auth.
4. Update tests to match the new structure.
5. Maintain backward compatibility during transition.

## References

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod Documentation](https://riverpod.dev)
- [AWS Cognito Documentation](https://docs.aws.amazon.com/cognito)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)

# Clean Architecture Implementation

## Overview

This document describes the clean architecture implementation in the SoloAdventurer app. The architecture is divided into layers with clear separation of concerns and dependencies flowing inward.

## Layer Structure

### Domain Layer

#### Entities

- User
- Profile

#### Repositories (Interfaces)

- AuthRepository
- ProfileRepository

#### Use Cases

- Auth:
  - LoginUseCase
  - RegisterUseCase
  - LogoutUseCase
  - GetCurrentUserUseCase
- Profile:
  - GetCurrentProfileUseCase
  - UpdateProfileUseCase
  - ManageAvatarUseCase
  - DeleteProfileUseCase

### Data Layer

#### Models

- UserModel
- AuthResponseModel
- ProfileModel

#### Data Sources

- Auth:
  - AuthRemoteDataSource
  - AuthLocalDataSource
- Profile:
  - ProfileRemoteDataSource
  - ProfileLocalDataSource

#### Repository Implementations

- AuthRepositoryImpl
- ProfileRepositoryImpl

### Presentation Layer

#### State Management

- Auth:
  - AuthState
  - AuthNotifier
  - AuthProviders
- Profile:
  - ProfileState (In Progress)
  - ProfileNotifier (In Progress)
  - ProfileProviders (In Progress)

#### Screens

- Auth:
  - LoginScreen
  - SignupScreen
- Profile:
  - EditProfileScreen (In Progress)
  - ProfileScreen (In Progress)
  - ProfileSettingsScreen (In Progress)

## Feature Implementation Status

### Auth Feature (Complete)

- ✅ Domain Layer
- ✅ Data Layer
- ✅ Presentation Layer
- ✅ Tests

### Profile Feature (In Progress)

- ✅ Domain Layer
  - Entity definitions
  - Repository interfaces
  - Use case implementations
- ✅ Data Layer
  - Models
  - Data sources
  - Repository implementation
  - Mock implementations for testing
- 🚧 Presentation Layer (In Progress)
  - State management
  - Screen implementations
  - Navigation
  - Tests

## Testing Strategy

### Unit Tests

- Domain layer tests for entities and use cases
- Data layer tests for models and repositories
- Presentation layer tests for state management

### Widget Tests

- Screen component tests
- Form validation tests
- Navigation flow tests

### Integration Tests

- Full authentication flow
- Profile management flow
- Error handling scenarios
- Offline mode behavior

## Dependencies

### Core Dependencies

- flutter_riverpod: State management
- get_it: Dependency injection
- dio: HTTP client
- shared_preferences: Local storage
- flutter_secure_storage: Secure storage

### Testing Dependencies

- flutter_test: Widget testing
- integration_test: Integration testing
- mockito: Mocking for unit tests

## Next Steps

1. Complete Profile feature presentation layer
2. Implement remaining integration tests
3. Add error handling improvements
4. Update documentation with final implementation details
