# Sync State Management Architecture

## Overview

This document describes the sync state management architecture for SoloAdventurer, which handles data synchronization between local storage and remote backend, including conflict resolution for concurrent edits.

## State Management Approach

We use **Riverpod** (`flutter_riverpod`) for state management, consistent with the rest of the application. Riverpod provides:

- Reactive state management
- Dependency injection
- Compile-time safety
- Testability

### Key Benefits

1. **Reactive Updates**: UI components automatically update when sync state changes
2. **Provider Dependencies**: Sync state can depend on auth state and connectivity
3. **Persistence Support**: Easy integration with local storage providers
4. **Testing**: Mock providers for unit and integration tests

## Sync States

The sync system uses five distinct states:

| State | Description | User Experience |
|-------|-------------|-----------------|
| **idle** | No sync activity, system ready | Show "Ready" or last sync time |
| **syncing** | Currently syncing data | Show animated sync indicator |
| **success** | Last sync completed successfully | Show success checkmark |
| **failed** | Last sync failed with errors | Show error icon with retry option |
| **pending** | Changes waiting to sync | Show pending count badge |

### State Transitions

```
idle -> syncing -> success
                  -> failed -> syncing (retry)
                  -> pending (if more changes)

pending -> syncing -> success
                  -> failed

success -> idle
failed -> idle (after user dismissal)

any state -> syncing (manual trigger)
```

## Data Types to Sync

### Syncable Entity Types

| Entity Type | Description | Priority | Offline Support | Auto-Merge |
|-------------|-------------|----------|-----------------|------------|
| **authTokens** | Authentication tokens | 100 (highest) | ❌ No | ❌ No |
| **profile** | User profile & preferences | 90 | ❌ No | ❌ No |
| **trip** | Trip data (main records) | 80 | ❌ No | ❌ No |
| **tripPlanning** | Trip planning operations | 70 | ❌ No | ❌ No |
| **travelNote** | Travel notes (text, photo, voice, location, expense) | 60 | ✅ Yes | ✅ Yes |
| **locationUpdate** | Location tracking updates | 50 | ✅ Yes | ✅ Yes |
| **travelPreference** | User travel preferences | 40 | ❌ No | ❌ No |
| **companions** | Travel companion relationships | 30 | ❌ No | ❌ No |
| **sharedTrips** | Shared trip data | 20 | ❌ No | ❌ No |

### Entity Type Details

#### 1. Auth Tokens (Priority: 100)
- **What**: User authentication tokens and session data
- **Sync Strategy**: Always first, must complete before other operations
- **Conflict Resolution**: Last-write-wins based on server timestamp
- **Offline Support**: No - requires network for token refresh

#### 2. Profile (Priority: 90)
- **What**: User profile information, avatar, bio
- **Sync Strategy**: Full object sync
- **Conflict Resolution**: Manual resolution (profile changes are important)
- **Offline Support**: No - profile updates require network

#### 3. Trip (Priority: 80)
- **What**: Main trip records (title, dates, destination, etc.)
- **Sync Strategy**: Full object sync with version control
- **Conflict Resolution**: Manual resolution (trip metadata is critical)
- **Offline Support**: No - trip creation/modification requires network

#### 4. Trip Planning (Priority: 70)
- **What**: Flight bookings, hotel reservations, itinerary items
- **Sync Strategy**: Incremental sync with operation history
- **Conflict Resolution**: Manual resolution (bookings are critical)
- **Offline Support**: No - planning operations require network

#### 5. Travel Notes (Priority: 60)
- **What**: Text notes, photos, voice memos, expenses, location markers
- **Sync Strategy**: Append-only with timestamps
- **Conflict Resolution**: Auto-merge by timestamp (notes are additive)
- **Offline Support**: Yes - notes can be created offline and synced later

#### 6. Location Updates (Priority: 50)
- **What**: GPS location tracking during trips
- **Sync Strategy**: Batch sync of location points
- **Conflict Resolution**: Auto-merge by timestamp (location is time-series)
- **Offline Support**: Yes - locations cached locally and synced when online

#### 7. Travel Preferences (Priority: 40)
- **What**: User preferences (seat selection, meal preferences, etc.)
- **Sync Strategy**: Full object sync
- **Conflict Resolution**: Manual resolution (preferences are personal)
- **Offline Support**: No - preference updates require network

#### 8. Companions (Priority: 30)
- **What**: Travel companion relationships and permissions
- **Sync Strategy**: Relationship sync with acceptance tracking
- **Conflict Resolution**: Server-authoritative (companion invites are managed server-side)
- **Offline Support**: No - companion operations require network

#### 9. Shared Trips (Priority: 20)
- **What**: Trips shared between users
- **Sync Strategy**: Merge with conflict detection per companion
- **Conflict Resolution**: Manual resolution (shared data needs consensus)
- **Offline Support**: No - sharing operations require network

## State Schema

### SyncState Structure

```dart
class SyncState {
  // Current sync status
  SyncStatus status;

  // Number of pending operations
  int pendingCount;

  // Number of failed operations
  int failedCount;

  // Last successful sync time
  DateTime? lastSyncTime;

  // Error message (if failed)
  String? error;

  // Error code for specific handling
  String? errorCode;

  // Progress of current sync (0.0 to 1.0)
  double syncProgress;

  // Entity types with pending changes
  List<SyncEntityType> pendingEntityTypes;
}
```

### State Properties

| Property | Type | Description |
|----------|------|-------------|
| `status` | `SyncStatus` | Current sync state (idle, syncing, success, failed, pending) |
| `pendingCount` | `int` | Total number of operations waiting to sync |
| `failedCount` | `int` | Number of operations that failed in last attempt |
| `lastSyncTime` | `DateTime?` | Timestamp of last successful sync |
| `error` | `String?` | Human-readable error message |
| `errorCode` | `String?` | Machine-readable error code for handling |
| `syncProgress` | `double` | Progress of current sync operation (0.0-1.0) |
| `pendingEntityTypes` | `List<SyncEntityType>` | Which entity types have pending changes |

## State Management Flow

### 1. Initialization

```dart
final syncStateProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ref.read);
});
```

### 2. State Updates

```dart
// Start sync
state = SyncState.syncing(
  progress: 0.0,
  pendingEntityTypes: [SyncEntityType.trip, SyncEntityType.travelNote],
);

// Update progress
state = state.copyWith(syncProgress: 0.5);

// Complete sync
state = SyncState.success(
  syncTime: DateTime.now(),
  pendingCount: 0,
);

// Handle error
state = SyncState.failed(
  'Network connection lost',
  code: 'NETWORK_ERROR',
  failedCount: 2,
);
```

### 3. Provider Dependencies

The sync state depends on:
- **Auth State**: Must have valid tokens to sync
- **Connectivity**: Must be online for network-required entities
- **Operation Queue**: Monitors pending operations

```dart
@riverpod
class SyncNotifier extends _$SyncNotifier {
  @override
  SyncState build() {
    // Watch dependencies
    ref.watch(authStateProvider);
    ref.watch(connectivityProvider);

    return SyncState.initial();
  }

  Future<void> sync() async {
    state = SyncState.syncing();
    // ... sync logic
  }
}
```

## Conflict Detection

### Version Control Strategy

Each synced entity includes:
- **Version Vector**: Tracks which devices have modified the data
- **Last Modified Timestamp**: Server timestamp for ordering
- **Hash**: Content hash for change detection

### Conflict Detection Logic

```dart
bool hasConflict(Entity local, Entity remote) {
  // Both modified since last sync
  final localModified = local.version > lastSyncVersion;
  final remoteModified = remote.version > lastSyncVersion;

  return localModified && remoteModified;
}
```

## Conflict Resolution Strategies

### 1. Last-Write-Wins (Automatic)
- Used for: Location updates, travel notes
- Strategy: Compare timestamps, keep the latest
- Pros: No user intervention needed
- Cons: Can lose data if timestamps are close

### 2. Manual Resolution (User Choice)
- Used for: Trips, profile, trip planning
- Strategy: Show user both versions, let them choose
- Pros: User maintains control
- Cons: Requires user action, blocks sync

### 3. Automatic Merge (Smart)
- Used for: Notes (non-overlapping fields)
- Strategy: Merge non-conflicting fields, flag conflicts
- Pros: Best of both worlds
- Cons: Complex to implement

## Integration with Existing Systems

### Operation Queue Integration

The sync system integrates with the existing `OperationQueue`:

```dart
// Queue operations for later sync
await ref.read(operationQueueProvider).addOperation(
  TravelNoteOperation.text(tripId: '123', text: 'Great trip!'),
);

// Process queue when online
ref.listen(connectivityProvider, (previous, next) {
  if (next == ConnectivityStatus.online) {
    ref.read(syncNotifierProvider.notifier).sync();
  }
});
```

### Network Detection

Uses `connectivity_plus` package to monitor network state:

```dart
@riverpod
Stream<ConnectivityStatus> connectivity(ConnectivityRef ref) {
  return Connectivity().onConnectivityChanged
      .map((status) => status.toConnectivityStatus());
}
```

## Error Handling

### Error Categories

| Category | Error Codes | Retry Strategy |
|----------|-------------|----------------|
| **Network** | `NETWORK_ERROR`, `TIMEOUT` | Exponential backoff |
| **Auth** | `UNAUTHORIZED`, `TOKEN_EXPIRED` | Redirect to login |
| **Server** | `SERVER_ERROR`, `MAINTENANCE` | Exponential backoff |
| **Validation** | `INVALID_DATA`, `CONFLICT` | Manual resolution required |
| **Storage** | `STORAGE_FULL`, `CORRUPTED` | User notification + manual cleanup |

### Error Messages

User-friendly error messages for each error type:

```dart
String getErrorMessage(String errorCode) {
  switch (errorCode) {
    case 'NETWORK_ERROR':
      return 'Cannot connect to server. Check your internet connection.';
    case 'UNAUTHORIZED':
      return 'Session expired. Please log in again.';
    case 'CONFLICT':
      return 'Changes conflict with server data. Please choose which version to keep.';
    // ...
  }
}
```

## Persistence

### Queue Persistence

The operation queue is persisted to local storage:

- **Storage**: `shared_preferences` for queue metadata
- **Format**: JSON serialized operations
- **Recovery**: Queue restored on app startup
- **Corruption Handling**: Invalid entries discarded with logging

### State Persistence

Sync state is persisted across app restarts:

```dart
// Save last sync state
await prefs.setString('last_sync_state', jsonEncode(state.toJson()));

// Restore on startup
final saved = prefs.getString('last_sync_state');
if (saved != null) {
  state = SyncState.fromJson(jsonDecode(saved));
}
```

## Testing Strategy

### Unit Tests

- State transitions
- Conflict detection logic
- Error handling

### Integration Tests

- Full sync flow with mocked backend
- Conflict resolution scenarios
- Offline-to-online transitions

### E2E Tests

- Multi-device sync simulation
- Network interruption recovery
- Concurrent edit conflicts

## Performance Considerations

### Batch Operations

- Group multiple operations into single API calls
- Limit batch size to prevent timeout
- Prioritize high-priority entity types

### Throttling

- Limit sync frequency to prevent server overload
- Debounce rapid state changes
- Coalesce multiple updates into single sync

### Memory Management

- Stream large datasets instead of loading all
- Clear cached data after successful sync
- Monitor queue size and alert if too large

## Security Considerations

### Data Encryption

- Sync data encrypted in transit (HTTPS)
- Sensitive data encrypted at rest
- Token-based authentication for all sync operations

### Privacy

- Only sync data user has permission to access
- Respect user's privacy settings
- Anonymize analytics data

## Future Enhancements

1. **Delta Sync**: Only sync changed fields, not full objects
2. **Compression**: Compress large payloads before sync
3. **Background Sync**: Use platform-specific background tasks
4. **Predictive Sync**: Pre-sync data based on user behavior
5. **Smart Conflict Resolution**: ML-based conflict resolution

## References

- [Riverpod Documentation](https://riverpod.dev/)
- [Flutter State Management](https://docs.flutter.dev/data-and-backend/state-mgmt)
- [Offline-First Architecture](https://www.robinwieruch.de/react-native-offline-first/)
