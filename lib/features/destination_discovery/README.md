# Destination Discovery Feature

AI-powered destination and activity discovery specifically for solo travelers.

## Domain Models

### Destination
Core domain entity representing a travel destination with solo-travel-specific information.

**Properties:**
- Basic info: id, name, description, location (lat/lng), country code, region
- Safety: safety score (1-10), detailed safety insights
- Solo suitability: solo suitability score (1-10), individual factors (safety, nightlife, walkability, accommodation, solo dining, communication)
- Trip planning: budget level, activity levels, tags, images
- Activities: popular activities list
- Metadata: best time to visit, average daily cost, currency, language, timezone
- Flags: isHiddenGem, popularityScore
- Timestamps: createdAt, updatedAt

### Helper Models
- **SoloSuitabilityFactors**: Individual scores for different solo-travel aspects
- **SafetyInsight**: Detailed safety information with category, severity, and tips
- **Activity**: Popular activities at a destination
- **BudgetLevel**: Enum (budget, moderate, expensive)
- **ActivityLevel**: Enum (relaxed, moderate, adventurous)

## Build Instructions

This feature uses Freezed for immutable models with code generation.

**To generate code:**
```bash
# Run this command after modifying any domain models
flutter pub run build_runner build --delete-conflicting-outputs
```

**Note:** The generated files (.freezed.dart and .g.dart) need to be created by running build_runner.
This cannot be done in the restricted build environment and should be run by the developer.

## Testing

Unit tests are located in `test/features/destination_discovery/domain/models/destination_test.dart`

Run tests with:
```bash
flutter test test/features/destination_discovery/
```

## Architecture

This feature follows Clean Architecture principles:
- **Domain Layer**: Models and repositories (interfaces)
- **Data Layer**: Repository implementations, GraphQL queries, DTOs
- **Application Layer**: Riverpod providers for state management
- **Presentation Layer**: UI components and screens
