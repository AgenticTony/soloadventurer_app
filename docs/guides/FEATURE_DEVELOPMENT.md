# Feature Development Guide

## Overview

This guide outlines the process for developing new features in the SoloAdventurer app using clean architecture principles. It provides templates, examples, and best practices to ensure consistent implementation across the codebase.

## Feature Structure

Each feature follows a clean architecture structure with three main layers:

```
features/
└── feature_name/
    ├── data/
    │   ├── sources/
    │   │   ├── local_data_source.dart
    │   │   └── remote_data_source.dart
    │   ├── models/
    │   │   └── feature_model.dart
    │   └── repositories/
    │       └── feature_repository_impl.dart
    ├── domain/
    │   ├── entities/
    │   │   └── feature_entity.dart
    │   ├── repositories/
    │   │   └── feature_repository.dart
    │   └── use_cases/
    │       └── feature_use_case.dart
    └── presentation/
        ├── screens/
        │   └── feature_screen.dart
        ├── widgets/
        │   └── feature_widget.dart
        └── providers/
            └── feature_provider.dart
```

## Development Process

### 1. Domain Layer

Start with the domain layer to define the core business logic:

1. **Create Entities**:

   - Define the core business objects
   - Implement validation logic
   - Define relationships with other entities

2. **Define Repository Interfaces**:

   - Create abstract classes that define data operations
   - Define method signatures with clear input/output types
   - Document expected behavior and error cases

3. **Implement Use Cases**:
   - Create classes for specific business operations
   - Implement business logic that orchestrates data flow
   - Handle validation and business rules

### 2. Data Layer

Implement the data layer to handle data retrieval and storage:

1. **Create Data Models**:

   - Define DTOs that map to/from domain entities
   - Implement serialization/deserialization
   - Handle data validation and transformation

2. **Implement Data Sources**:

   - Create local data sources (e.g., database, shared preferences)
   - Create remote data sources (e.g., API clients)
   - Handle data caching and synchronization

3. **Implement Repositories**:
   - Create concrete implementations of repository interfaces
   - Coordinate between data sources
   - Handle error mapping and recovery

### 3. Presentation Layer

Develop the presentation layer to display data and handle user interactions:

1. **Create Providers**:

   - Implement state management using Riverpod
   - Connect to use cases from the domain layer
   - Handle UI state transformations

2. **Develop Widgets**:

   - Create reusable UI components
   - Implement widget-specific logic
   - Connect to providers for data and actions

3. **Implement Screens**:
   - Compose widgets into full screens
   - Handle navigation and screen-level state
   - Connect to providers for data and actions

## Templates

### Domain Layer Templates

#### Entity Template

```dart
class FeatureEntity {
  final String id;
  final String name;
  final String description;

  const FeatureEntity({
    required this.id,
    required this.name,
    required this.description,
  });

  // Validation methods
  bool isValid() {
    return id.isNotEmpty && name.isNotEmpty;
  }
}
```

#### Repository Interface Template

```dart
abstract class FeatureRepository {
  /// Gets a feature by ID
  ///
  /// Throws [NotFoundException] if the feature is not found
  Future<FeatureEntity> getFeature(String id);

  /// Gets all features
  ///
  /// Returns an empty list if no features are found
  Future<List<FeatureEntity>> getAllFeatures();

  /// Creates a new feature
  ///
  /// Returns the created feature
  /// Throws [ValidationException] if the feature is invalid
  Future<FeatureEntity> createFeature(FeatureEntity feature);

  /// Updates an existing feature
  ///
  /// Returns the updated feature
  /// Throws [NotFoundException] if the feature is not found
  /// Throws [ValidationException] if the feature is invalid
  Future<FeatureEntity> updateFeature(FeatureEntity feature);

  /// Deletes a feature by ID
  ///
  /// Throws [NotFoundException] if the feature is not found
  Future<void> deleteFeature(String id);
}
```

#### Use Case Template

```dart
class GetFeatureUseCase {
  final FeatureRepository repository;

  GetFeatureUseCase(this.repository);

  Future<FeatureEntity> execute(String id) async {
    if (id.isEmpty) {
      throw ValidationException('Feature ID cannot be empty');
    }

    return repository.getFeature(id);
  }
}
```

### Data Layer Templates

#### Data Model Template

```dart
class FeatureModel {
  final String id;
  final String name;
  final String description;

  const FeatureModel({
    required this.id,
    required this.name,
    required this.description,
  });

  // From JSON
  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    return FeatureModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  // From Entity
  factory FeatureModel.fromEntity(FeatureEntity entity) {
    return FeatureModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
    );
  }

  // To Entity
  FeatureEntity toEntity() {
    return FeatureEntity(
      id: id,
      name: name,
      description: description,
    );
  }
}
```

#### Data Source Template

```dart
abstract class FeatureRemoteDataSource {
  Future<FeatureModel> getFeature(String id);
  Future<List<FeatureModel>> getAllFeatures();
  Future<FeatureModel> createFeature(FeatureModel feature);
  Future<FeatureModel> updateFeature(FeatureModel feature);
  Future<void> deleteFeature(String id);
}

class FeatureRemoteDataSourceImpl implements FeatureRemoteDataSource {
  final ApiClient apiClient;

  FeatureRemoteDataSourceImpl(this.apiClient);

  @override
  Future<FeatureModel> getFeature(String id) async {
    final response = await apiClient.get('/features/$id');
    return FeatureModel.fromJson(response.data);
  }

  @override
  Future<List<FeatureModel>> getAllFeatures() async {
    final response = await apiClient.get('/features');
    return (response.data as List)
        .map((json) => FeatureModel.fromJson(json))
        .toList();
  }

  @override
  Future<FeatureModel> createFeature(FeatureModel feature) async {
    final response = await apiClient.post(
      '/features',
      data: feature.toJson(),
    );
    return FeatureModel.fromJson(response.data);
  }

  @override
  Future<FeatureModel> updateFeature(FeatureModel feature) async {
    final response = await apiClient.put(
      '/features/${feature.id}',
      data: feature.toJson(),
    );
    return FeatureModel.fromJson(response.data);
  }

  @override
  Future<void> deleteFeature(String id) async {
    await apiClient.delete('/features/$id');
  }
}
```

#### Repository Implementation Template

```dart
class FeatureRepositoryImpl implements FeatureRepository {
  final FeatureRemoteDataSource remoteDataSource;
  final FeatureLocalDataSource localDataSource;

  FeatureRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<FeatureEntity> getFeature(String id) async {
    try {
      // Try to get from local cache first
      final localFeature = await localDataSource.getFeature(id);
      return localFeature.toEntity();
    } catch (e) {
      // If not in cache, get from remote
      final remoteFeature = await remoteDataSource.getFeature(id);

      // Cache the result
      await localDataSource.cacheFeature(remoteFeature);

      return remoteFeature.toEntity();
    }
  }

  @override
  Future<List<FeatureEntity>> getAllFeatures() async {
    try {
      final remoteFeatures = await remoteDataSource.getAllFeatures();

      // Cache the results
      await localDataSource.cacheFeatures(remoteFeatures);

      return remoteFeatures.map((model) => model.toEntity()).toList();
    } catch (e) {
      // If remote fails, try local
      final localFeatures = await localDataSource.getAllFeatures();
      return localFeatures.map((model) => model.toEntity()).toList();
    }
  }

  @override
  Future<FeatureEntity> createFeature(FeatureEntity feature) async {
    final featureModel = FeatureModel.fromEntity(feature);
    final createdFeature = await remoteDataSource.createFeature(featureModel);

    // Cache the result
    await localDataSource.cacheFeature(createdFeature);

    return createdFeature.toEntity();
  }

  @override
  Future<FeatureEntity> updateFeature(FeatureEntity feature) async {
    final featureModel = FeatureModel.fromEntity(feature);
    final updatedFeature = await remoteDataSource.updateFeature(featureModel);

    // Update cache
    await localDataSource.cacheFeature(updatedFeature);

    return updatedFeature.toEntity();
  }

  @override
  Future<void> deleteFeature(String id) async {
    await remoteDataSource.deleteFeature(id);

    // Remove from cache
    await localDataSource.removeFeature(id);
  }
}
```

### Presentation Layer Templates

#### Provider Template

```dart
// State class
class FeatureState {
  final AsyncValue<List<FeatureEntity>> features;
  final AsyncValue<FeatureEntity?> selectedFeature;
  final String? error;

  const FeatureState({
    this.features = const AsyncValue.loading(),
    this.selectedFeature = const AsyncValue.loading(),
    this.error,
  });

  FeatureState copyWith({
    AsyncValue<List<FeatureEntity>>? features,
    AsyncValue<FeatureEntity?>? selectedFeature,
    String? error,
  }) {
    return FeatureState(
      features: features ?? this.features,
      selectedFeature: selectedFeature ?? this.selectedFeature,
      error: error,
    );
  }
}

// Notifier class
class FeatureNotifier extends StateNotifier<FeatureState> {
  final GetAllFeaturesUseCase getAllFeatures;
  final GetFeatureUseCase getFeature;
  final CreateFeatureUseCase createFeature;
  final UpdateFeatureUseCase updateFeature;
  final DeleteFeatureUseCase deleteFeature;

  FeatureNotifier({
    required this.getAllFeatures,
    required this.getFeature,
    required this.createFeature,
    required this.updateFeature,
    required this.deleteFeature,
  }) : super(const FeatureState()) {
    _loadFeatures();
  }

  Future<void> _loadFeatures() async {
    try {
      final features = await getAllFeatures.execute();
      state = state.copyWith(
        features: AsyncValue.data(features),
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        features: AsyncValue.error(e, stackTrace),
        error: e.toString(),
      );
    }
  }

  Future<void> loadFeature(String id) async {
    try {
      state = state.copyWith(
        selectedFeature: const AsyncValue.loading(),
      );

      final feature = await getFeature.execute(id);

      state = state.copyWith(
        selectedFeature: AsyncValue.data(feature),
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        selectedFeature: AsyncValue.error(e, stackTrace),
        error: e.toString(),
      );
    }
  }

  // Other methods for creating, updating, and deleting features
}

// Provider
final featureProvider = StateNotifierProvider<FeatureNotifier, FeatureState>((ref) {
  return FeatureNotifier(
    getAllFeatures: ref.watch(getAllFeaturesProvider),
    getFeature: ref.watch(getFeatureProvider),
    createFeature: ref.watch(createFeatureProvider),
    updateFeature: ref.watch(updateFeatureProvider),
    deleteFeature: ref.watch(deleteFeatureProvider),
  );
});

// Use case providers
final getAllFeaturesProvider = Provider((ref) {
  return GetAllFeaturesUseCase(ref.watch(featureRepositoryProvider));
});

final getFeatureProvider = Provider((ref) {
  return GetFeatureUseCase(ref.watch(featureRepositoryProvider));
});

// Repository provider
final featureRepositoryProvider = Provider<FeatureRepository>((ref) {
  return getIt<FeatureRepository>();
});
```

#### Screen Template

```dart
class FeatureScreen extends ConsumerWidget {
  const FeatureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(featureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Features'),
      ),
      body: state.features.when(
        data: (features) {
          if (features.isEmpty) {
            return const Center(
              child: Text('No features found'),
            );
          }

          return ListView.builder(
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return ListTile(
                title: Text(feature.name),
                subtitle: Text(feature.description),
                onTap: () {
                  ref.read(featureProvider.notifier).loadFeature(feature.id);
                  // Navigate to feature details
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create feature screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## Testing Requirements

Each feature should have comprehensive tests for all layers:

### Domain Layer Tests

- Test entities for validation logic
- Test use cases for business logic
- Test repository interfaces with mocks

### Data Layer Tests

- Test data models for serialization/deserialization
- Test data sources with mocked API responses
- Test repository implementations with mocked data sources

### Presentation Layer Tests

- Test providers for state management
- Test widgets for UI rendering
- Test screens for integration with providers

## Best Practices

1. **Single Responsibility**: Each class should have a single responsibility
2. **Dependency Injection**: Use constructor injection for dependencies
3. **Error Handling**: Handle errors at appropriate layers
4. **Documentation**: Document public APIs and complex logic
5. **Testing**: Write tests for all layers
6. **Naming Conventions**: Use consistent naming across the codebase
7. **Code Style**: Follow the Dart style guide
8. **Performance**: Consider performance implications of your code
9. **Accessibility**: Ensure UI is accessible
10. **Internationalization**: Support multiple languages where appropriate

## Conclusion

Following this guide will ensure consistent implementation of features across the SoloAdventurer app. The clean architecture approach promotes maintainability, testability, and scalability, making it easier to add new features and modify existing ones.
