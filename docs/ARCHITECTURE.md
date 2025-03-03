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

## Architecture Layers

### 1. Domain Layer

The domain layer is the innermost layer and contains the business logic of the application. It is independent of any framework or implementation details.

#### Components:

- **Entities**: Core business objects that represent the domain concepts.
- **Use Cases**: Application-specific business rules that orchestrate the flow of data to and from entities.
- **Repository Interfaces**: Abstractions that define how data is accessed and manipulated.

### 2. Data Layer

The data layer is responsible for data retrieval and storage. It implements the repository interfaces defined in the domain layer.

#### Components:

- **Repositories**: Implementations of the repository interfaces defined in the domain layer.
- **Data Sources**: Local and remote data sources that provide data to repositories.
- **Models**: Data transfer objects (DTOs) that map to and from domain entities.

### 3. Presentation Layer

The presentation layer is responsible for displaying data to the user and handling user interactions.

#### Components:

- **UI**: Widgets and screens that display data to the user.
- **State Management**: Providers, notifiers, and other state management solutions.
- **View Models**: Objects that transform domain entities into a format suitable for display.

### 4. Infrastructure Layer

The infrastructure layer provides cross-cutting concerns and technical capabilities.

#### Components:

- **Monitoring**: OpenTelemetry integration for metrics, traces, and logs.
- **Network**: API clients and interceptors.
- **Storage**: Local storage implementations.
- **Security**: Authentication and encryption.

## Feature-Based Organization

Each feature is organized as a vertical slice through all layers:

```
lib/
├── app/                 # Core app infrastructure
│   ├── config/          # Environment configurations
│   │   ├── env.dart
│   │   └── feature_flags/
│   ├── di/             # Dependency injection
│   └── bootstrap.dart   # App initialization
│
├── features/           # Feature modules
│   ├── auth/          # Authentication feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── trips/         # Trip management
│
└── shared/            # Cross-cutting concerns
    ├── monitoring/    # OpenTelemetry integration
    │   ├── telemetry/
    │   ├── metrics/
    │   └── traces/
    ├── network/
    └── storage/
```

## Monitoring Integration

We use OpenTelemetry as our primary monitoring solution:

```dart
// lib/shared/monitoring/telemetry/monitoring.dart
abstract class Monitoring {
  void trackEvent(String name, Map<String, dynamic> attributes);
  void startSpan(String name, Function() operation);
  void recordMetric(String name, double value, Map<String, String> labels);
}

// Implementation using OpenTelemetry
class OpenTelemetryMonitoring implements Monitoring {
  final OpenTelemetry _otel;

  OpenTelemetryMonitoring(this._otel);

  @override
  void trackEvent(String name, Map<String, dynamic> attributes) {
    final span = _otel.tracer.startSpan(name);
    span.setAttributes(attributes);
    span.end();
  }

  @override
  void startSpan(String name, Function() operation) {
    final span = _otel.tracer.startSpan(name);
    try {
      operation();
    } finally {
      span.end();
    }
  }

  @override
  void recordMetric(String name, double value, Map<String, String> labels) {
    _otel.meter
        .createHistogram(name)
        .record(value, attributes: labels);
  }
}
```

## Testing Strategy

Each layer has its own testing approach:

- **Domain Layer**: Unit tests with no external dependencies.
- **Data Layer**: Unit tests with mocked data sources.
- **Presentation Layer**: Widget tests with mocked repositories and services.
- **Infrastructure Layer**: Integration tests with test doubles for external services.

## Migration Strategy

The migration to clean architecture will be incremental:

1. Set up the core infrastructure (app/, shared/).
2. Implement OpenTelemetry monitoring abstraction.
3. Migrate one feature at a time, starting with auth.
4. Update tests to match the new structure.
5. Maintain backward compatibility during transition.

## Diagrams

(To be added: Visual representations of the architecture, including layer diagrams, dependency flow, and feature organization.)

## Examples

(To be added: Code examples for each layer and feature, demonstrating the implementation of clean architecture principles.)

## References

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [Feature-First Architecture by Ryan Edge](https://codewithandrea.com/articles/flutter-project-structure/)

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
