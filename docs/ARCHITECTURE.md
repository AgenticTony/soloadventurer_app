# SoloAdventurer Architecture

## Overview

SoloAdventurer is a Flutter application designed to help solo travelers connect with like-minded individuals, plan trips, and share experiences. This document outlines the architectural decisions, patterns, and best practices used in the development of the application.

## Architectural Principles

The application follows these key architectural principles:

1. **Clean Architecture**: Separation of concerns with distinct layers (data, domain, presentation)
2. **Feature-First Organization**: Code organized by feature rather than by type
3. **Dependency Inversion**: Dependencies point inward, with abstractions at boundaries
4. **Single Responsibility**: Each component has a single, well-defined responsibility
5. **Testability**: Architecture designed to facilitate comprehensive testing

## Project Structure

The project follows a feature-based organization with clean architecture principles:

```
lib/
├── app/                     # Core app infrastructure
│   ├── config/              # Environment configurations
│   │   ├── env.dart         # Environment variables
│   │   ├── router/          # App routing
│   │   └── feature_flags/   # Feature toggle system
│   ├── di/                  # Dependency injection
│   │   ├── service_locator.dart
│   │   └── providers/       # Riverpod provider setup
│   └── bootstrap.dart       # App initialization
│
├── features/                # Feature modules (vertical slices)
│   ├── auth/                # Authentication feature
│   │   ├── data/            # Data layer
│   │   │   ├── sources/     # Local & remote data sources
│   │   │   └── repositories/
│   │   ├── domain/          # Business logic
│   │   │   ├── entities/
│   │   │   └── use_cases/
│   │   └── presentation/    # UI layer
│   │       ├── screens/
│   │       ├── widgets/
│   │       └── state/       # State management
│   │
│   ├── trips/               # Trip management
│   └── matching/            # Traveler matching system
│
├── shared/                  # Cross-cutting concerns
    ├── api/                 # API infrastructure
    ├── design_system/       # UI components
    ├── utils/               # Utilities
    └── monitoring/          # Observability
```

## Layer Responsibilities

### Data Layer

The data layer is responsible for:

- Retrieving data from external sources (API, local storage)
- Converting between external data formats and domain entities
- Implementing repository interfaces defined in the domain layer

**Key Components**:

- **Data Sources**: Interfaces and implementations for data retrieval
- **Repositories**: Implementations of repository interfaces defined in the domain layer
- **Models**: Data transfer objects (DTOs) for external data formats

### Domain Layer

The domain layer contains the business logic of the application:

- Business entities
- Repository interfaces
- Use cases that orchestrate the flow of data

**Key Components**:

- **Entities**: Core business models
- **Repository Interfaces**: Abstractions for data operations
- **Use Cases**: Business logic operations

### Presentation Layer

The presentation layer is responsible for:

- UI components
- State management
- User interaction

**Key Components**:

- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components
- **State**: Riverpod providers and state management

## State Management

The application uses Riverpod for state management:

- **StateNotifierProvider**: For complex state with multiple properties
- **FutureProvider**: For asynchronous data
- **Provider**: For derived state and simple values

Example:

```dart
// Auth state management
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    getCurrentUser: ref.watch(getCurrentUserProvider),
    signIn: ref.watch(signInProvider),
    signOut: ref.watch(signOutProvider),
  );
});
```

## Dependency Injection

The application uses a combination of GetIt and Riverpod for dependency injection:

- **GetIt**: For service location and singleton management
- **Riverpod**: For reactive dependencies and state management

Example:

```dart
// Service registration
final getIt = GetIt.instance;

void setupDependencies() {
  // Register repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: getIt<AuthLocalDataSource>(),
      remoteDataSource: getIt<AuthRemoteDataSource>(),
    ),
  );

  // Register use cases
  getIt.registerLazySingleton(() => GetCurrentUser(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignIn(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignOut(getIt<AuthRepository>()));
}

// Provider using GetIt
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return getIt<AuthRepository>();
});
```

## Navigation

The application uses Flutter's Navigator 2.0 with a custom router implementation:

```dart
// App router
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      // Other routes...
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
```

## Error Handling

The application uses a centralized error handling approach:

- **AppException**: Base class for all application exceptions
- **ErrorHandler**: Centralized error reporting and handling
- **ErrorInterceptor**: Interceptor for API errors

```dart
// Error handling
class ErrorHandler {
  static void reportError(String message, dynamic error, StackTrace stackTrace) {
    // Report to monitoring service
    // Log error
    // Show user-friendly message if appropriate
  }
}
```

## Monitoring

The application includes comprehensive monitoring:

- **Performance Tracking**: App start time, network requests, memory usage
- **Error Tracking**: Crash reporting, error logging
- **Analytics**: User behavior, feature usage

```dart
// Performance tracking
class AppStartTracker {
  static void trackAppStart() {
    final startTime = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final duration = DateTime.now().difference(startTime);
      // Report to analytics
    });
  }
}
```

## Testing Strategy

The application follows a comprehensive testing strategy:

- **Unit Tests**: For domain logic, repositories, and providers
- **Widget Tests**: For UI components
- **Integration Tests**: For feature flows

```dart
// Provider testing
void main() {
  test('AuthNotifier should authenticate user on successful sign in', () async {
    // Arrange
    final mockRepository = MockAuthRepository();
    when(mockRepository.signInWithEmailAndPassword(
      email: 'test@example.com',
      password: 'password',
    )).thenAnswer((_) async => mockUser);

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    // Act
    await container.read(authProvider.notifier).signIn(
      email: 'test@example.com',
      password: 'password',
    );

    // Assert
    expect(container.read(authProvider).user, mockUser);
    expect(container.read(authProvider).isAuthenticated, true);
  });
}
```

## Design System

The application uses a consistent design system:

- **Theme**: Centralized theme configuration
- **Components**: Reusable UI components
- **Typography**: Consistent text styles
- **Colors**: Defined color palette

```dart
// Theme configuration
class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    // Other theme properties
  );

  static final ThemeData darkTheme = ThemeData(
    // Dark theme configuration
  );
}
```

## API Layer

The API layer is designed for flexibility and testability:

- **ApiClient**: Wrapper around HTTP client (Dio)
- **Interceptors**: Authentication, error handling, logging
- **Models**: Standardized response models

```dart
// API client
class ApiClient {
  final Dio _dio;

  ApiClient({
    required String baseUrl,
    required AuthInterceptor authInterceptor,
    required ErrorInterceptor errorInterceptor,
    required NetworkMonitor networkMonitor,
  }) : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.interceptors.addAll([
      authInterceptor,
      errorInterceptor,
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  // Other HTTP methods
}
```

## Conclusion

This architecture provides a solid foundation for the SoloAdventurer application, with clear separation of concerns, testability, and maintainability. The feature-first organization with clean architecture principles allows for scalable development and easy onboarding of new team members.
