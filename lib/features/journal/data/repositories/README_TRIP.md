# Trip Management System

Complete trip management system for organizing journal entries in the SoloAdventurer travel journal app.

## Overview

The trip management system allows users to create, view, edit, and delete trips to organize their journal entries. This addresses the user story: "As a user, I want to organize my journal by trip so that I can easily find memories from specific adventures."

## Architecture

The system follows Clean Architecture principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │ TripListScreen  │  │ CreateTripScreen│  │TripDetail    │ │
│  │                 │  │                 │  │  Screen      │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
│                              ↓                                │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Trip Providers (Riverpod)                 │  │
│  │  • tripListProvider       • tripFormProvider          │  │
│  │  • tripDetailProvider    • tripRepositoryProvider     │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                            │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              TripRepository (Interface)                │  │
│  └───────────────────────────────────────────────────────┘  │
│                              ↓                                │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                    Trip Entity                         │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         TripRepositoryImpl                             │  │
│  └───────────────────────────────────────────────────────┘  │
│                              ↓                                │
│  ┌───────────────────────────────────────────────────────┐  │
│  │      TripRemoteDataSource (Interface)                  │  │
│  └───────────────────────────────────────────────────────┘  │
│                              ↓                                │
│  ┌───────────────────────────────────────────────────────┐  │
│  │      TripRemoteDataSourceImpl (Supabase)               │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Files Created

### Data Layer

1. **lib/features/journal/data/datasources/trip_remote_data_source.dart**
   - Interface for remote data operations
   - Methods: createTrip, getTrip, getTrips, getTripsByDateRange, getOngoingTrips, updateTrip, deleteTrip, getEntryCountForTrip

2. **lib/features/journal/data/datasources/trip_remote_data_source_impl.dart**
   - Supabase implementation of TripRemoteDataSource
   - Full CRUD operations with proper error handling
   - User authentication checks
   - PostgrestException handling with meaningful error messages

3. **lib/features/journal/data/repositories/trip_repository_impl.dart**
   - Implementation of TripRepository interface
   - Converts between entities and models
   - Comprehensive error handling with AppException

### Domain Layer

4. **lib/features/journal/domain/repositories/trip_repository.dart**
   - Repository interface for trip operations
   - Clean abstraction of data sources
   - Methods for CRUD and querying trips

### Presentation Layer

5. **lib/features/journal/presentation/providers/trip_providers.dart** (600+ lines)
   - **Dependency Injection Providers:**
     - `supabaseClientProvider`: Provides Supabase client
     - `tripRemoteDataSourceProvider`: Provides data source
     - `tripRepositoryProvider`: Provides repository

   - **Trip List State Management:**
     - `TripListState`: State for trip list operations
     - `TripListNotifier`: Notifier for managing trip list state
     - `tripListProvider`: Provider for trip list state
     - Methods: loadTrips, loadOngoingTrips, clearError

   - **Trip Form State Management:**
     - `TripFormState`: State for trip creation/editing
     - `TripFormNotifier`: Notifier for managing form state
     - `tripFormProvider`: Provider for form state
     - Methods: updateName, updateDescription, updateStartDate, updateEndDate, updateDestination, updatePublic, updateCoverImage, loadTrip, saveTrip, reset, validate
     - Form validation with error messages

   - **Trip Detail State Management:**
     - `TripDetailState`: State for individual trip viewing
     - `TripDetailNotifier`: Notifier for managing detail state
     - `tripDetailProvider`: Family provider for different trip IDs
     - Methods: loadTrip, deleteTrip, clearError

6. **lib/features/journal/presentation/screens/trip_list_screen.dart**
   - Screen displaying all user trips
   - Pull-to-refresh support
   - Empty state with call-to-action
   - Error handling with retry option
   - Trip cards with:
     - Cover image or placeholder
     - Trip name, destination, date range
     - Ongoing badge
     - Duration display
     - Public indicator

7. **lib/features/journal/presentation/screens/create_trip_screen.dart**
   - Screen for creating or editing trips
   - Form with validation:
     - Trip name (required, 3-200 characters)
     - Destination (optional, max 200 characters)
     - Start date (required, date picker)
     - End date (optional, date picker)
     - Description (optional, max 2000 characters)
     - Cover image URL (optional, with URL validation)
     - Public trip switch
   - Loading states during save
   - Error display
   - Success feedback with SnackBar

8. **lib/features/journal/presentation/screens/trip_detail_screen.dart**
   - Screen displaying trip details
   - Cover image in app bar
   - Edit and delete actions
   - Trip information sections:
     - Status badges (ongoing, public, duration)
     - Destination
     - Date range
     - Description
     - Statistics (entry count, duration)
     - Metadata (created, updated, synced)
   - Placeholder sections for future features:
     - Journal entries list
     - Media gallery
   - Delete confirmation dialog

## Features Implemented

### CRUD Operations
- ✅ Create trips with full validation
- ✅ Read/view single trip details
- ✅ Read/list all user trips
- ✅ Update existing trips
- ✅ Delete trips with confirmation

### Query Operations
- ✅ Get trips by date range
- ✅ Get ongoing trips
- ✅ Get entry count for trip

### UI Components
- ✅ Trip list with cards
- ✅ Trip detail view
- ✅ Create/edit trip form
- ✅ Form validation
- ✅ Date pickers
- ✅ Loading states
- ✅ Error handling
- ✅ Empty states
- ✅ Pull-to-refresh
- ✅ Confirmation dialogs

### State Management
- ✅ Riverpod providers for all operations
- ✅ Reactive state updates
- ✅ Error state management
- ✅ Loading state management
- ✅ Form state with validation

## Usage Examples

### Navigating to Trip List

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const TripListScreen(),
  ),
);
```

### Creating a New Trip

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const CreateTripScreen(),
  ),
);
```

### Viewing Trip Details

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TripDetailScreen(tripId: tripId),
  ),
);
```

### Editing a Trip

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CreateTripScreen(tripId: tripId),
  ),
);
```

### Using Trip Repository Programmatically

```dart
final repository = ref.read(tripRepositoryProvider);

// Create a trip
final trip = Trip(
  id: '', // Server-generated
  userId: userId,
  name: 'Summer Vacation',
  startDate: DateTime(2024, 6, 1),
  endDate: DateTime(2024, 6, 15),
  destination: 'Paris, France',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
final createdTrip = await repository.createTrip(trip);

// Get all trips
final trips = await repository.getTrips();

// Get ongoing trips
final ongoingTrips = await repository.getOngoingTrips();

// Update a trip
final updatedTrip = await repository.updateTrip(createdTrip.copyWith(
  name: 'Updated Name',
));

// Delete a trip
await repository.deleteTrip(tripId);

// Get entry count
final count = await repository.getEntryCountForTrip(tripId);
```

## Database Schema Reference

The trips table structure (from migration):

```sql
CREATE TABLE trips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  name VARCHAR(200) NOT NULL,
  description TEXT,
  cover_image_url TEXT,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE,
  destination VARCHAR(200),
  is_public BOOLEAN DEFAULT false,
  sync_status VARCHAR(20) DEFAULT 'synced',
  last_synced_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## Validation Rules

- **Trip Name:**
  - Required
  - 3-200 characters
  - Cannot be empty or whitespace only

- **Destination:**
  - Optional
  - Maximum 200 characters

- **Description:**
  - Optional
  - Maximum 2000 characters

- **Start Date:**
  - Required
  - Cannot be in the past (enforced by UI)

- **End Date:**
  - Optional
  - Cannot be before start date

- **Cover Image URL:**
  - Optional
  - Must be valid HTTP/HTTPS URL

## Error Handling

All errors are wrapped in `AppException` with user-friendly messages:

- Authentication errors: "User not authenticated"
- Network errors: "Failed to connect to server"
- Validation errors: Specific field validation messages
- Not found errors: "Trip not found"
- Server errors: Detailed error message from server

## Future Enhancements

- ✨ Cover image upload from gallery
- ✨ Trip collaboration (multiple users)
- ✨ Trip templates for quick creation
- ✨ Trip sharing with public links
- ✨ Trip duplication/cloning
- ✨ Trip statistics and insights
- ✨ Trip itinerary planning
- ✨ Integration with journal entries (show entries in trip detail)
- ✨ Integration with media gallery (show photos/videos in trip detail)
- ✨ Map view of trip locations
- ✨ Export trip to PDF

## Integration with Other Features

### Journal Entries
- Journal entries can be associated with trips via the `trip_id` foreign key
- Use `JournalRepository.getEntriesByTrip(tripId)` to get all entries for a trip
- Trip detail screen shows entry count

### Media Items
- Media items can be filtered by trip
- Use `JournalRepository.getMediaForTrip(tripId)` to get all media for a trip
- Future: Media gallery in trip detail screen

## Testing Checklist

Before marking complete, verify:
- [x] Can create a new trip
- [x] Can view trip list
- [x] Can view trip details
- [x] Can edit existing trip
- [x] Can delete trip
- [x] Form validation works correctly
- [x] Date pickers work
- [x] Empty states display correctly
- [x] Error handling works
- [x] Loading states display
- [x] Pull-to-refresh works
- [x] Cover images display (if URL provided)

## Related Components

- **Journal Entries**: `lib/features/journal/presentation/screens/create_journal_entry_screen.dart`
- **Media Upload**: `lib/features/journal/presentation/providers/media_upload_providers.dart`
- **Location Services**: `lib/utils/location_service.dart`
- **Rich Text Editor**: `lib/features/journal/presentation/widgets/rich_text_editor.dart`

## Contributing

When adding new trip-related features:
1. Update the TripRepository interface with new methods
2. Implement in TripRemoteDataSourceImpl
3. Add methods to TripRepositoryImpl
4. Create/update providers in trip_providers.dart
5. Update UI components as needed
6. Update this documentation

## License

This component is part of the SoloAdventurer app and follows the same license.
