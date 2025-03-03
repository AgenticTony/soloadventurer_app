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
