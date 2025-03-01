# Travel Preferences UI Implementation Plan

## 1. Design & Planning (2 days)

### Requirements & Acceptance Criteria

- Users can set and update travel preferences
- Preferences include destination types, activity interests, travel style, budget range, and accommodation preferences
- Changes save automatically and sync with the backend
- UI is intuitive and visually appealing
- Works offline with local caching

### Database Schema

```sql
CREATE TABLE user_preferences (
  user_id UUID PRIMARY KEY REFERENCES users(id),
  destination_types TEXT[] NOT NULL DEFAULT '{}',
  activity_interests TEXT[] NOT NULL DEFAULT '{}',
  travel_style TEXT NOT NULL DEFAULT 'flexible',
  budget_range INT4RANGE NOT NULL DEFAULT '[500,3000]',
  accommodation_preferences JSONB NOT NULL DEFAULT '{}',
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Add geospatial index for location-based queries
CREATE INDEX idx_user_preferences_location_gist ON user_preferences USING GIST (location);
```

### API Endpoints

- `GET /api/users/me/preferences` - Fetch current user preferences
- `PUT /api/users/me/preferences` - Update user preferences
- `PATCH /api/users/me/preferences` - Partially update preferences

### UI Mockup (Conceptual)

- Main preferences screen with sections for each preference category
- Interactive selectors for destination types (beach, mountain, city, etc.)
- Slider for budget range
- Toggle buttons for travel style options
- Checkbox grid for activity interests
- Bottom action bar with save/reset buttons

## 2. Backend Implementation (3 days)

### Day 1: Data Layer

- Create `PreferenceEntity` model in `lib/features/preferences/data/models/preference_entity.dart`
- Implement `PreferenceLocalDataSource` for local storage with Drift
- Implement `PreferenceRemoteDataSource` for API communication

### Day 2: Domain Layer

- Create `Preference` domain model in `lib/features/preferences/domain/entities/preference.dart`
- Implement `PreferenceRepository` interface and its implementation
- Create use cases: `GetUserPreferences`, `UpdateUserPreferences`

### Day 3: API Integration

- Implement API client methods for preference endpoints
- Set up proper error handling and retry logic
- Implement offline request queueing for preference updates
- Add unit tests for repository and use cases

## 3. Frontend Development (3 days)

### Day 1: State Management

- Create preference providers using Riverpod
- Implement state notifiers for preference management
- Set up proper loading, error, and success states
- Create preference form state management

### Day 2: UI Components

- Implement destination type selector component
- Create budget range slider with custom styling
- Build activity interest grid with animations
- Implement travel style toggle buttons

### Day 3: Screen Integration

- Create main preferences screen layout
- Integrate all UI components
- Implement form validation
- Add loading and error states
- Implement auto-save functionality

## 4. Integration & Testing (2 days)

### Day 1: Testing

- Write widget tests for preference components
- Create integration tests for the preferences screen
- Test offline functionality
- Verify proper state management
- Test edge cases (empty preferences, network errors)

### Day 2: Refinement

- Optimize performance
- Add animations for state transitions
- Implement proper error handling with user feedback
- Create documentation for the preferences feature
- Conduct final review and bug fixes

## Implementation Details

### Key Files to Create/Modify

```
lib/features/preferences/
├── data/
│   ├── datasources/
│   │   ├── preference_local_data_source.dart
│   │   └── preference_remote_data_source.dart
│   ├── models/
│   │   └── preference_entity.dart
│   └── repositories/
│       └── preference_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── preference.dart
│   ├── repositories/
│   │   └── preference_repository.dart
│   └── usecases/
│       ├── get_user_preferences.dart
│       └── update_user_preferences.dart
└── presentation/
    ├── providers/
    │   └── preference_providers.dart
    ├── screens/
    │   └── preferences_screen.dart
    └── widgets/
        ├── destination_type_selector.dart
        ├── budget_range_slider.dart
        ├── activity_interest_grid.dart
        └── travel_style_toggles.dart
```

### Riverpod Providers

```dart
// lib/features/preferences/presentation/providers/preference_providers.dart

final preferenceRepositoryProvider = Provider<PreferenceRepository>((ref) {
  return ref.watch(serviceLocatorProvider).get<PreferenceRepository>();
});

final userPreferencesProvider = StateNotifierProvider<PreferencesNotifier, AsyncValue<Preference>>((ref) {
  final repository = ref.watch(preferenceRepositoryProvider);
  return PreferencesNotifier(repository);
});

class PreferencesNotifier extends StateNotifier<AsyncValue<Preference>> {
  final PreferenceRepository _repository;

  PreferencesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    state = const AsyncValue.loading();
    try {
      final preferences = await _repository.getUserPreferences();
      state = AsyncValue.data(preferences);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updatePreferences(Preference preferences) async {
    try {
      // Optimistic update
      state = AsyncValue.data(preferences);
      await _repository.updateUserPreferences(preferences);
    } catch (e, stackTrace) {
      // Revert on error
      _loadPreferences();
      throw AsyncError(e, stackTrace);
    }
  }
}
```

## Timeline and Task Distribution

For a two-person team, work can be distributed as follows:

**Person A (Backend Focus):**

- Database schema design
- API endpoint implementation
- Repository and use case implementation
- Unit tests for backend components

**Person B (Frontend Focus):**

- UI component design and implementation
- State management with Riverpod
- Screen integration
- Widget tests

**Pair Programming Sessions:**

- Initial architecture and design decisions
- Integration between frontend and backend
- Final testing and refinement

This plan provides a structured approach to implementing the Travel Preferences UI feature, following the vertical slice methodology and clean architecture principles. The estimated 10-day timeline (2+3+3+2) includes some buffer for unexpected challenges.

## Next Steps After Implementation

1. Review the implementation against the requirements
2. Conduct user testing to gather feedback
3. Iterate on the UI based on feedback
4. Optimize performance if needed
5. Document any lessons learned for future features
