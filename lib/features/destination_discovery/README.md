# Destination Discovery Feature

AI-powered destination and activity discovery specifically for solo travelers with safety ratings, solo-suitability filters, personalized recommendations, and comprehensive search.

## Table of Contents
- [Overview](#overview)
- [Domain Models](#domain-models)
- [State Management](#state-management)
- [Usage Examples](#usage-examples)
- [Navigation & Routing](#navigation--routing)
- [Build Instructions](#build-instructions)
- [Testing](#testing)
- [Architecture](#architecture)

## Overview

This feature provides comprehensive destination discovery with:
- **AI-powered search** with solo-suitability filters
- **Safety scores and insights** for informed travel decisions
- **Personalized recommendations** based on user preferences
- **Curated destination collections** (popular solo, hidden gems, etc.)
- **Save to wishlist or trips** functionality
- **Advanced filtering** (budget, activity level, safety, solo-friendliness)
- **Trip planning integration** for seamless workflow

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

### Other Domain Models
- **DestinationFilter**: Filter options for search (budget, safety, activity, location, tags, sort order)
- **PersonalizedRecommendation**: AI-generated recommendations with match scores and reasons
- **SavedDestination**: Destinations saved to wishlist or trips
- **CuratedList**: Curated destination collections (popular solo, hidden gems, budget-friendly, etc.)

## State Management

This feature uses Riverpod for state management with the following providers:

### Search Providers
- **destinationSearchProvider**: Manages destination search state with pagination
- **filterProvider**: Manages active filter state

### Detail Providers
- **destinationDetailProvider**: Manages single destination detail state
- **savedDestinationsProvider**: Manages saved destinations (wishlist/trips)

### Content Providers
- **recommendationProvider**: Manages personalized recommendations
- **curatedListsProvider**: Manages curated destination collections

### Integration Providers
- **addToTripProvider**: Manages adding destinations to trips

## Usage Examples

### Performing a Search
```dart
// Watch search state
final searchState = ref.watch(destinationSearchProvider);
final searchNotifier = ref.read(destinationSearchProvider.notifier);

// Perform search with filter
final filter = DestinationFilter(
  searchQuery: 'beach',
  budgetLevel: BudgetLevel.budget,
  minSafetyScore: 7.0,
  tags: ['beach', 'urban'],
);
await searchNotifier.search(filter);

// Load more results
await searchNotifier.loadMore();

// Clear search
searchNotifier.clear();
```

### Managing Filters
```dart
final filterNotifier = ref.read(filterProvider.notifier);

// Update specific filter
filterNotifier.updateSearchQuery('Tokyo');
filterNotifier.updateBudgetLevel(BudgetLevel.moderate);
filterNotifier.addTag('urban');

// Reset filters
filterNotifier.reset();

// Check if filters are active
final hasActive = ref.read(filterProvider).hasActiveFilters;
```

### Saving Destinations
```dart
final savedNotifier = ref.read(savedDestinationsProvider.notifier);

// Save to wishlist
await savedNotifier.saveDestination(
  SavedDestination(
    destination: destination,
    userId: userId,
    saveType: SaveType.wishlist,
    notes: 'Looks amazing!',
  ),
);

// Check if saved
final isSaved = ref.read(savedDestinationsProvider).isDestinationSaved(destination.id);

// Remove from saved
await savedNotifier.unsaveDestination(destinationId: destination.id, userId: userId);
```

### Adding to Trip
```dart
// Show add to trip flow
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => AddToTripFlow(
    destination: destination,
    onSuccess: (tripId, tripName) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to $tripName')),
      );
    },
  ),
);
```

## Navigation & Routing

### Basic Navigation
```dart
// Navigate to destination discovery
Navigator.pushNamed(context, '/destinations');

// Navigate to destination detail (with ID)
Navigator.pushNamed(context, '/destinations/detail/123');

// Navigate to recommendations
Navigator.pushNamed(context, '/destinations/recommendations');

// Navigate to curated lists
Navigator.pushNamed(context, '/destinations/curated-lists');
```

### Deep Linking with Filters
```dart
// Navigate to search with pre-applied filters
Navigator.pushNamed(
  context,
  '/destinations',
  arguments: DestinationFilter(
    searchQuery: 'beach',
    budgetLevel: BudgetLevel.budget,
    minSafetyScore: 7.0,
    tags: ['beach', 'urban'],
  ),
);

// Deep link URL example:
// /destinations?q=beach&budget=budget&minSafety=7&tags=beach,urban
```

### Supported Query Parameters
- `q`: Search query text
- `budget`: Budget level (budget, moderate, expensive)
- `minSafety`: Minimum safety score (1-10)
- `minSoloSuitability`: Minimum solo suitability score (1-10)
- `activity`: Activity level (relaxed, moderate, adventurous)
- `country`: Country code (e.g., JP, US, TH)
- `region`: Region name
- `tags`: Comma-separated tags (e.g., beach,urban,cultural)
- `hiddenGems`: true/false for hidden gems only
- `sortBy`: Sort order (popularity, safety, solo_suitability, budget_asc, budget_desc, newest, relevance)

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

### Running Tests
```bash
# Run all destination discovery tests
flutter test test/features/destination_discovery/

# Run specific test files
flutter test test/features/destination_discovery/domain/models/
flutter test test/features/destination_discovery/application/providers/
flutter test test/features/destination_discovery/presentation/widgets/
```

### Test Coverage
- **Domain Models**: Unit tests for all models, serialization, equality, and helper methods
- **Providers**: Unit tests for all state management providers with mocks
- **Widgets**: Widget tests for all custom UI components
- **Integration**: End-to-end tests for complete user flows

## Architecture

This feature follows Clean Architecture principles:

### Domain Layer (`lib/features/destination_discovery/domain/`)
- **Models**: Core business entities (Destination, DestinationFilter, etc.)
- **Repositories**: Abstract interfaces for data operations

### Data Layer (`lib/features/destination_discovery/infrastructure/`)
- **Repositories**: Implementations of domain repositories
- **GraphQL**: API queries and mutations
- **DTOs**: Data transfer objects for API mapping

### Application Layer (`lib/features/destination_discovery/application/`)
- **Providers**: Riverpod state management
- **State**: Immutable state classes

### Presentation Layer (`lib/features/destination_discovery/presentation/`)
- **Screens**: Full-screen UI components
- **Widgets**: Reusable UI components
- **Routes**: Navigation and deep linking

## Key Features

### Search & Filtering
- Text-based search with debouncing
- Multi-criteria filtering (budget, safety, activity, location, tags)
- Advanced filter modal with comprehensive options
- Sort options (popularity, safety, solo suitability, budget, newest, relevance)
- Infinite scroll pagination

### Safety Information
- Overall safety score (1-10)
- Detailed safety insights by category (theft, transportation, nightlife, etc.)
- Severity indicators (low, medium, high)
- Actionable safety tips

### Solo Suitability
- Overall solo suitability score (1-10)
- Individual factor scores:
  - Safety
  - Nightlife
  - Walkability
  - Accommodation options
  - Solo dining
  - Communication/language

### Personalization
- AI-powered recommendations based on:
  - User preferences and profile
  - Past trip history
  - Similar users' preferences
  - Trending destinations
- Match scores and recommendation reasons
- Hidden gem discoveries

### Trip Integration
- Save destinations to wishlist
- Add destinations to existing trips
- Create new trips with destinations
- Add notes and dates
- Seamless integration with trip planning feature

## Contributing

When modifying this feature:
1. Keep models immutable using Freezed
2. Run `build_runner` after changing domain models
3. Update tests for any changed functionality
4. Follow existing code patterns and documentation style
5. Ensure all public APIs have dartdoc comments
