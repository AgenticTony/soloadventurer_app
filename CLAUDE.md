# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Essential Commands
```bash
flutter pub get              # Install dependencies
flutter run                  # Run the app
flutter test                 # Run all unit and widget tests
flutter test --coverage      # Run tests with coverage report
flutter analyze              # Run static analysis
./scripts/run_tests.sh       # Comprehensive test runner with reporting
```

### Running Single Tests
```bash
# Run a specific test file
flutter test test/features/auth/domain/usecases/login_use_case_test.dart

# Run tests matching a pattern
flutter test --name "test_name"

# Run integration tests
flutter test integration_test/auth_flow_test.dart
```

### Code Generation
```bash
# Generate code (freezed, riverpod generators, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Watch for changes and regenerate
dart run build_runner watch --delete-conflicting-outputs
```

### Performance Measurement
```bash
dart scripts/measure_performance.dart    # Measure app performance metrics
```

## Architecture Overview

SoloAdventurer follows **Clean Architecture** with **feature-first organization** using Riverpod for state management.

**See `docs/ARCHITECTURE.md`** for detailed architecture patterns and layer definitions.

### Directory Structure

```
lib/
├── app/                          # Application infrastructure
│   ├── bootstrap.dart            # App initialization (configure GetIt, AWS)
│   ├── di/
│   │   └── modules/              # Dependency injection modules (auth_module, core_module)
│   ├── router/                   # App routing with go_router
│   └── theme/                    # App theming
│
├── features/                     # Feature modules (vertical slices)
│   ├── auth/                     # Authentication (Complete - AWS Cognito)
│   │   ├── data/                 # Data sources, models, repository impl
│   │   ├── domain/               # Entities, use cases, repository interfaces
│   │   └── presentation/         # UI, state, providers
│   │
│   ├── profile/                  # User profiles (In Progress)
│   ├── travel/                   # Travel features (planning, preferences)
│   └── core/                     # Core services (connectivity, logging)
│
└── core/                         # Cross-cutting concerns
    ├── api/                      # HTTP client (Dio) and interceptors
    ├── config/                   # Environment config (Cognito, AWS)
    ├── error/                    # Error handling
    ├── monitoring/               # Performance monitoring (CloudWatch)
    ├── security/                 # Encryption, secure storage
    └── services/                 # Background services (notifications)
```

### Layer Dependency Rules

- **Domain** layer: No dependencies on outer layers (pure business logic)
- **Data** layer: Implements domain repositories, depends only on domain
- **Presentation** layer: Depends on domain via use cases
- **Infrastructure** (core/): Provides technical capabilities to all layers

## Riverpod Patterns

**See `docs/RIVERPOD_PATTERNS.md`** for comprehensive patterns and best practices.

### Standard Provider Pattern

All state management uses `AsyncValue` for consistent loading/error handling:

```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<AuthState> build() => const AsyncValue.data(AuthState.initial());

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _authRepository.signIn(email, password);
    });
  }
}
```

### Provider Organization

- Providers are organized by feature in `*_providers.dart` files
- Use `@riverpod` annotation with code generation
- Abstract providers throw `UnimplementedError` for DI overriding
- Provider dependencies are injected via `ref.watch()` or constructor

### Error Handling Pattern

Use `ref.listen()` for side effects like navigation and error display:

```dart
ref.listen(authStateProvider, (previous, next) {
  next.whenOrNull(
    error: (error, stack) => _showErrorSnackBar(context, error),
    data: (data) {
      if (data is Authenticated) {
        _navigateToHome(context);
      }
    },
  );
});
```

## Authentication Architecture

**See `docs/AUTH_ARCHITECTURE.md`** for detailed auth system design and AWS Cognito integration.

The auth feature uses **AWS Cognito** with comprehensive token management:

### Key Components

- **AuthRepository**: Interface for auth operations (login, signup, token refresh)
- **AuthNotifier**: Manages auth state with AsyncValue
- **TokenManager**: Handles token lifecycle, refresh, and revocation
- **SessionManager**: Background token refresh with Timer

### Token States

Tokens are stored in `AuthState`:
- `accessToken`: For API calls
- `idToken`: User identity claims
- `refreshToken`: For obtaining new access tokens
- `tokenExpiresAt`: Expiration timestamp

### Token Refresh Flow

1. Session manager checks token expiration every 45 minutes
2. Tokens refresh automatically before expiry
3. Silent refresh overlay shows during background refresh
4. TokenExpiredDialog shows if refresh fails

## Testing Patterns

**See `docs/TESTING_PATTERNS.md`** for comprehensive testing patterns and conventions.

### Test Structure

```
test/
├── features/              # Feature-specific tests (mirrors lib/features/)
│   ├── auth/
│   └── profile/
├── providers/             # Provider state tests
├── screens/               # Widget tests
├── mocks/                 # Mock repositories and services
└── utils/                 # Test utilities (TestData, ProviderContainerUtils)
```

### Test Utilities

- **TestData**: Factory class for creating test data (users, profiles, etc.)
- **ProviderContainerUtils**: Helper for setting up test provider containers
- **AuthTestUtils**: Auth-specific test helpers

### Provider Testing

```dart
test('auth state changes on login', () {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockAuthRepository),
    ],
  );

  final notifier = container.read(authNotifierProvider.notifier);
  await notifier.signIn('test@example.com', 'password');

  expect(
    container.read(authNotifierProvider),
    isA<AsyncData<AuthState>>().having((s) => s, 'state', isA<Authenticated>()),
  );
});
```

## Dependency Injection

### GetIt Service Locator

Dependencies are registered in `lib/app/di/modules/`:

- **core_module.dart**: Core services (logging, storage, network)
- **auth_module.dart**: Auth-specific dependencies

### Test Mode

The app can be configured for testing by overriding providers in tests rather than using GetIt directly. Use `ProviderContainer(overrides: [...])` for test isolation.

## Important Implementation Notes

### Environment Configuration

- AWS Cognito config is in `.env` (use `.env.example` as template)
- Use `flutter_dotenv` to load environment variables
- Never commit `.env` file with real credentials

### Code Generation

Run `dart run build_runner build --delete-conflicting-outputs` after:
- Creating new `@riverpod` annotated classes
- Modifying `@freezed` classes
- Changing `@JsonSerializable` models

### Navigation

The app uses `go_router` for declarative routing. Routes are defined in `lib/app/router/` and auth-specific routes in `lib/features/auth/presentation/routes/`.

### Freezed Models

Most domain entities and models use `freezed` for immutable data classes:

```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? accessToken,
  }) = _User;
}
```

### Error Types

The app uses sealed class hierarchies for type-safe error handling. See `lib/core/error/` and `lib/features/core/errors/`.

## Current Feature Status

- **Auth**: Complete (AWS Cognito integration, token management, testing)
- **Profile**: In progress (domain and data layers complete, presentation in progress)
- **Travel**: Early development (domain models defined)

## Further Reading

| Document | Description |
|----------|-------------|
| `docs/ARCHITECTURE.md` | Clean architecture patterns, layer definitions, and feature organization |
| `docs/RIVERPOD_PATTERNS.md` | Comprehensive Riverpod patterns, error handling, and best practices |
| `docs/AUTH_ARCHITECTURE.md` | Detailed authentication system design and AWS Cognito integration |
| `docs/TESTING_PATTERNS.md` | Testing patterns and conventions for unit, widget, and integration tests |
| `docs/FEATURE_DEVELOPMENT.md` | Guidelines for developing new features in the codebase |
| `docs/PROJECT_ROADMAP.md` | Overall project roadmap and planned features |
