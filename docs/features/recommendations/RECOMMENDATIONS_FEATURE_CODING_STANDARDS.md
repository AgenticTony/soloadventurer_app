# Recommendations Feature - Coding Standards

This document outlines the coding standards, patterns, and best practices used in the recommendations feature refactoring. These standards ensure consistent, maintainable, and secure code across the SoloAdventurer codebase.

## Table of Contents

1. [Clean Architecture Principles](#clean-architecture-principles)
2. [User Data Isolation Security](#user-data-isolation-security)
3. [Riverpod Provider Patterns](#riverpod-provider-patterns)
4. [Error Handling Patterns](#error-handling-patterns)
5. [Testing Standards](#testing-standards)
6. [Code Organization](#code-organization)
7. [API Integration Patterns](#api-integration-patterns)

---

## Clean Architecture Principles

### Layer Separation

The recommendations feature follows Clean Architecture with clear separation of concerns:

```
lib/features/recommendations/
├── data/                 # External data sources, API clients
│   ├── datasources/      # Remote/local data implementations
│   ├── models/           # Data transfer objects (DTOs)
│   ├── repositories/     # Repository implementations
│   └── services/         # Data-layer services
├── domain/               # Business logic
│   ├── entities/         # Core business objects
│   ├── repositories/     # Repository interfaces
│   ├── services/         # Service interfaces
│   └── usecases/         # Business logic use cases
└── presentation/         # UI layer
    ├── providers/        # Riverpod providers
    ├── screens/          # Screen widgets
    ├── widgets/          # Reusable widgets
    └── routes/           # Navigation routes
```

### Dependency Rule

**Critical**: Dependencies must point inward only. Inner layers must not know anything about outer layers.

**✅ Correct:**
```dart
// Domain layer (no dependencies on outer layers)
abstract class RecommendationRepository {
  Future<Either<Failure, PersonalizedRecommendation>> saveRecommendation(
    String userId,
    PersonalizedRecommendation recommendation,
  );
}
```

**❌ Incorrect:**
```dart
// Domain layer importing data layer - VIOLATION
import 'package:soloadventurer/features/recommendations/data/models/recommendation_model.dart';
```

### Interface Segregation

Domain layer defines interfaces, data layer implements them:

```dart
// Domain layer - lib/features/recommendations/domain/repositories/recommendation_repository.dart
abstract class RecommendationRepository {
  Future<Either<Failure, PersonalizedRecommendation>> saveRecommendation(...);
}

// Data layer - lib/features/recommendations/data/repositories/recommendation_repository_impl.dart
class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationLocalDataSource _dataSource;

  RecommendationRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, PersonalizedRecommendation>> saveRecommendation(...) async {
    // Implementation
  }
}
```

---

## User Data Isolation Security

### Critical Security Principle

All user data MUST be scoped by `userId` to prevent data leakage between users.

### Storage Pattern

Use nested Maps with userId as the outer key:

```dart
/// ✅ CORRECT - User-scoped storage
class RecommendationLocalDataSourceImpl {
  // Outer map keyed by userId for proper isolation
  final Map<String, Map<String, PersonalizedRecommendation>> _saved = {};
  final Map<String, Set<String>> _dismissed = {};

  Future<PersonalizedRecommendation> saveRecommendation(
    String userId,
    PersonalizedRecommendation recommendation,
  ) async {
    // Create user-specific storage if doesn't exist
    _saved.putIfAbsent(userId, () => {});

    // Store in user's partition
    _saved[userId]![recommendation.id] = recommendation;
    return recommendation;
  }
}
```

```dart
/// ❌ INCORRECT - Global storage (SECURITY VULNERABILITY)
class VulnerableDataSource {
  // NO userId scoping - all users share the same data!
  final Map<String, PersonalizedRecommendation> _saved = {};

  Future<PersonalizedRecommendation> saveRecommendation(
    PersonalizedRecommendation recommendation,
  ) async {
    _saved[recommendation.id] = recommendation; // User A sees User B's data!
    return recommendation;
  }
}
```

### Repository Pattern

Repositories MUST require userId parameter:

```dart
// Domain layer interface
abstract class RecommendationRepository {
  Future<Either<Failure, PersonalizedRecommendation>> saveRecommendation(
    String userId,  // Required for data isolation
    PersonalizedRecommendation recommendation,
  );
}

// Use case calls repository with userId
class SaveRecommendation {
  Future<Either<Failure, PersonalizedRecommendation>> call(
    String userId,  // Required parameter
    PersonalizedRecommendation recommendation,
  ) async {
    final saved = recommendation.copyWith(isSaved: true);
    return await _repository.saveRecommendation(userId, saved);
  }
}
```

### Presentation Layer Integration

Get userId from auth state before calling use cases:

```dart
Future<void> _saveRecommendation(
  BuildContext context,
  PersonalizedRecommendation recommendation,
) async {
  // ✅ CORRECT - Get userId from auth state
  final userResult = await ref.read(getCurrentUserProvider.future);

  final userId = userResult.fold(
    (failure) {
      _showError(context, 'Please sign in to save recommendations');
      return null;
    },
    (user) => user.id,
  );

  if (userId == null) return;

  // Use case with userId parameter
  final useCase = ref.read(saveRecommendationProvider);
  final result = await useCase(userId, recommendation);

  result.fold(
    (failure) => _showError(context, failure.toString()),
    (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved for later')),
      );
    },
  );
}
```

### Testing Data Isolation

Unit tests MUST verify data isolation between users:

```dart
test('should isolate recommendations by userId', () async {
  const user1Id = 'user-123';
  const user2Id = 'user-456';
  final recommendation1 = _createTestRecommendation('rec-1', 'Museum A');
  final recommendation2 = _createTestRecommendation('rec-2', 'Museum B');

  await dataSource.saveRecommendation(user1Id, recommendation1);
  await dataSource.saveRecommendation(user2Id, recommendation2);

  // Each user should only see their own recommendations
  final user1Saved = await dataSource.getSavedRecommendations(user1Id);
  final user2Saved = await dataSource.getSavedRecommendations(user2Id);

  expect(user1Saved.length, 1);
  expect(user2Saved.length, 1);
  expect(user1Saved.first.id, 'rec-1');
  expect(user2Saved.first.id, 'rec-2');
});
```

---

## Riverpod Provider Patterns

### Provider Types

Use the appropriate provider type based on complexity:

**For simple dependencies without parameters:**
```dart
@riverpod
RecommendationRepository recommendationRepository(Ref ref) {
  final dataSource = ref.watch(recommendationLocalDataSourceProvider);
  return RecommendationRepositoryImpl(dataSource);
}
```

**For use cases with complex parameters:**
```dart
// Use Provider pattern when @riverpod code generation fails
final saveRecommendationProvider = Provider<SaveRecommendation>((ref) {
  final repository = ref.watch(recommendationRepositoryProvider);
  return SaveRecommendation(repository);
});

// Call with parameters:
final useCase = ref.read(saveRecommendationProvider);
final result = await useCase(userId, recommendation);
```

### Provider Organization

Organize providers by feature in `*_providers.dart` files:

```dart
// lib/features/recommendations/presentation/providers/recommendation_providers.dart

// Data source providers
@riverpod
RecommendationLocalDataSource recommendationLocalDataSource(Ref ref) {
  return RecommendationLocalDataSourceImpl();
}

// Repository providers
@riverpod
RecommendationRepository recommendationRepository(Ref ref) {
  final dataSource = ref.watch(recommendationLocalDataSourceProvider);
  return RecommendationRepositoryImpl(dataSource);
}

// Service providers
@riverpod
RecommendationService recommendationService(Ref ref) {
  final placesRepo = ref.watch(placesRepositoryProvider);
  final weatherService = ref.watch(weatherServiceProvider);
  return PersonalizedRecommendationService(
    placesRepo: placesRepo,
    weatherService: weatherService,
  );
}

// Use case providers
@riverpod
GetPersonalizedRecommendations getPersonalizedRecommendations(Ref ref) {
  final service = ref.watch(recommendationServiceProvider);
  return GetPersonalizedRecommendations(service);
}
```

### Watch vs Read

- Use `ref.watch()` for dependencies in provider construction
- Use `ref.read()` for one-time access (e.g., in event handlers)

```dart
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  Future<Result> build() async {
    // ✅ Use watch for provider dependencies
    final repository = ref.watch(repositoryProvider);
    return await repository.getData();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    // ✅ Use read for one-time access in methods
    final repository = ref.read(repositoryProvider);
    state = await AsyncValue.guard(() => repository.getData());
  }
}
```

### Abstract Providers

For dependencies that should be provided by DI modules, throw `UnimplementedError`:

```dart
@riverpod
WeatherService weatherService(Ref ref) {
  throw UnimplementedError(
    'WeatherService implementation must be provided in DI module',
  );
}
```

---

## Error Handling Patterns

### Either Pattern for Repository Results

Use `Either<Failure, T>` from dartz package:

```dart
// Repository returns Either
Future<Either<Failure, PersonalizedRecommendation>> saveRecommendation(
  String userId,
  PersonalizedRecommendation recommendation,
);

// Use case handles Either
class SaveRecommendation {
  Future<Either<Failure, PersonalizedRecommendation>> call(
    String userId,
    PersonalizedRecommendation recommendation,
  ) async {
    return await _repository.saveRecommendation(userId, saved);
  }
}
```

### AsyncValue for State Management

Use `AsyncValue<T>` for UI state:

```dart
@riverpod
class RecommendationsNotifier extends _$RecommendationsNotifier {
  @override
  AsyncValue<List<PersonalizedRecommendation>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> loadRecommendations(String itineraryId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final request = RecommendationRequest(itineraryId: itineraryId, ...);
      final useCase = ref.read(getPersonalizedRecommendationsProvider);
      final result = await useCase(request);

      return result.fold(
        (failure) => throw Exception(failure.toString()),
        (recommendations) => recommendations,
      );
    });
  }
}
```

### UI Error Display

Use `ref.listen()` for side effects like error display:

```dart
class RecommendationsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(recommendationsProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${error.toString()}')),
          );
        },
      );
    });

    final recommendationsAsync = ref.watch(recommendationsProvider);

    return recommendationsAsync.when(
      data: (recommendations) => RecommendationsList(recommendations),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

---

## Testing Standards

### Test Structure

```
test/features/recommendations/
├── data/
│   └── datasources/
│       └── recommendation_local_data_source_test.dart
└── domain/
    └── usecases/
        ├── save_recommendation_test.dart
        └── dismiss_recommendation_test.dart
```

### Test Pattern

Use Arrange-Act-Assert pattern with descriptive test names:

```dart
group('SaveRecommendation', () {
  test('should pass userId to repository when saving', () async {
    // Arrange
    const userId = 'user-123';
    final recommendation = _createTestRecommendation('rec-1', 'Test Place');

    when(() => mockRepository.saveRecommendation(userId, any()))
        .thenAnswer((_) async => Right(recommendation));

    // Act
    final result = await saveRecommendation(userId, recommendation);

    // Assert
    verify(() => mockRepository.saveRecommendation(userId, any())).called(1);
    expect(result.isRight(), true);
  });
});
```

### Security Testing

Always test user data isolation:

```dart
test('should isolate data between users', () async {
  const user1Id = 'user-123';
  const user2Id = 'user-456';

  await dataSource.saveRecommendation(user1Id, rec1);
  await dataSource.saveRecommendation(user2Id, rec2);

  // Verify isolation
  final user1Data = await dataSource.getSavedRecommendations(user1Id);
  final user2Data = await dataSource.getSavedRecommendations(user2Id);

  expect(user1Data.first.id, isNot(user2Data.first.id));
});
```

---

## Code Organization

### File Naming

- Use `snake_case.dart` for file names
- Match file name to primary class/function
- Group related classes in same file

```
✅ lib/features/recommendations/data/datasources/recommendation_local_data_source.dart
   (Contains RecommendationLocalDataSource interface and impl)

❌ lib/features/recommendations/data/recommendation_ds.dart
   (Unclear abbreviation)
```

### Import Organization

```dart
// 1. Dart SDK imports
import 'dart:async';

// 2. Package imports
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 3. Project imports - grouped by feature
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/core/providers/core_providers.dart';
import 'package:soloadventurer/features/recommendations/data/datasources/...';
import 'package:soloadventurer/features/recommendations/domain/entities/...';
import 'package:soloadventurer/features/recommendations/domain/repositories/...';
```

### Documentation

Public APIs MUST have documentation comments:

```dart
/// Use case for saving a recommendation for later
///
/// Allows users to bookmark recommendations they're interested in
/// but don't want to add to their itinerary yet.
///
/// [userId] The user's ID (required for data isolation)
/// [recommendation] The recommendation to save
///
/// Returns [Right] with the saved recommendation (marked as isSaved=true)
/// Returns [Left] with failure if cannot save
class SaveRecommendation {
  // ...
}
```

---

## API Integration Patterns

### Placeholder Implementation

When API integration is not yet implemented, use `UnimplementedError` with clear TODO:

```dart
class PlacesRemoteDataSourceImpl implements PlacesRemoteDataSource {
  final ApiClient _apiClient;

  PlacesRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<PlaceActivity>> findPlacesByInterest({
    required Destination destination,
    required TravelInterest interest,
    Set<RecommendationCategory>? categories,
    int limit = 20,
  }) async {
    // TODO: Implement Google Places API integration
    // Requires: Google Places API key in configuration
    // API endpoint: https://maps.googleapis.com/maps/api/place/nearbysearch/json
    throw UnimplementedError(
      'Real API integration not yet implemented. '
      'Google Places API key required.',
    );
  }
}
```

### Provider Update Pattern

When replacing mock with real implementation:

```dart
// Before (mock)
@riverpod
PlacesRemoteDataSource placesRemoteDataSource(Ref ref) {
  return MockPlacesRemoteDataSource();
}

// After (real implementation)
@riverpod
PlacesRemoteDataSource placesRemoteDataSource(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PlacesRemoteDataSourceImpl(apiClient);
}
```

---

## Summary

### Key Takeaways

1. **Clean Architecture**: Maintain layer separation with dependencies pointing inward
2. **Security First**: Always scope data by userId using nested Map structures
3. **Provider Patterns**: Use @riverpod for simple providers, Provider for complex cases
4. **Error Handling**: Use Either<Failure, T> for repositories, AsyncValue for UI
5. **Testing**: Always test user data isolation scenarios
6. **Documentation**: Document public APIs and complex logic

### Related Documents

- `docs/ARCHITECTURE.md` - Overall architecture patterns
- `docs/RIVERPOD_PATTERNS.md` - Comprehensive Riverpod guide
- `docs/TESTING_PATTERNS.md` - Testing patterns and conventions
- `docs/AUTH_ARCHITECTURE.md` - Authentication system design
