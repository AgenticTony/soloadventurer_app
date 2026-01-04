# Sync Service Tests

Comprehensive test suite for the offline sync functionality of the travel journal feature.

## Overview

The sync service test suite verifies the bidirectional synchronization between local SQLite storage and remote Supabase database. These tests ensure that offline editing works correctly and syncs properly when connectivity is restored.

## Test Files

- **`sync_test_helpers.dart`** - Test utilities, mock classes, and test data factories
- **`sync_service_test.dart`** - Comprehensive unit tests for all sync operations

## Test Coverage

### 1. Initialization Tests
- ✅ Service initialization without errors
- ✅ Correct initial state (isSyncing, lastSyncTime, progress)
- ✅ Proper disposal of resources

### 2. Full Sync Tests (`syncAll`)
- ✅ Sync all entities successfully when connected
- ✅ Fail gracefully when not connected
- ✅ Sync entities in correct order (entries → trips → tags → media)
- ✅ Update `lastSyncTime` on successful sync
- ✅ Use custom configuration when provided
- ✅ Skip media sync when `syncMedia: false`

### 3. Entry Sync Tests (`syncEntries`)
- ✅ Upload pending entries to remote
- ✅ Download remote entries to local
- ✅ Detect conflicts when entry modified both locally and remotely
- ✅ Update local entry if remote is newer
- ✅ Not update local entry if remote is older
- ✅ Bidirectional sync (upload and download)
- ✅ Handle 404 errors (entry not found remotely)
- ✅ Handle server errors during sync

### 4. Trip Sync Tests (`syncTrips`)
- ✅ Upload pending trips to remote
- ✅ Download remote trips to local
- ✅ Detect conflicts when trip modified both locally and remotely
- ✅ Update local trip if remote is newer
- ✅ Handle 404 and server errors

### 5. Tag Sync Tests (`syncTags`)
- ✅ Upload pending tags to remote
- ✅ Download remote tags to local
- ✅ Detect conflicts when tag modified both locally and remotely
- ✅ Update local tag if remote is newer
- ✅ Handle 404 and server errors

### 6. Media Sync Tests (`syncMedia`)
- ✅ Upload pending media to remote
- ✅ Download media for synced entries
- ✅ Handle media upload errors gracefully
- ✅ Mark failed media as pending for retry
- ✅ Handle network errors during media sync

### 7. Conflict Resolution Tests
- ✅ Resolve conflict with `mostRecent` strategy
- ✅ Resolve conflict with `localWins` strategy
- ✅ Resolve conflict with `remoteWins` strategy
- ✅ Resolve conflict with `manual` strategy
- ✅ Update local/remote based on resolution strategy
- ✅ Mark conflicts as resolved after resolution

### 8. Statistics Tests
- ✅ Track total syncs correctly
- ✅ Track successful syncs correctly
- ✅ Track failed syncs correctly
- ✅ Calculate average duration correctly
- ✅ Track last sync time
- ✅ Clear statistics on request
- ✅ Calculate success rate correctly

### 9. Progress Tracking Tests
- ✅ Emit progress updates during sync
- ✅ Call progress callbacks
- ✅ Remove progress callbacks
- ✅ Call conflict callbacks
- ✅ Update progress for each operation type
- ✅ Report accurate progress percentage

### 10. Cancellation Tests
- ✅ Cancel sync operation
- ✅ Stop processing when cancelled
- ✅ Update state after cancellation

### 11. Directional Sync Tests
- ✅ Upload only local changes
- ✅ Download only remote changes
- ✅ Sync pending items only (quick sync)

## Running the Tests

### Run All Sync Tests
```bash
flutter test test/features/journal/data/services/sync_service_test.dart
```

### Run Specific Test Group
```bash
# Run only syncEntries tests
flutter test test/features/journal/data/services/sync_service_test.dart --name="syncEntries"

# Run only conflict resolution tests
flutter test test/features/journal/data/services/sync_service_test.dart --name="Conflict Resolution"
```

### Run with Coverage
```bash
flutter test --coverage test/features/journal/data/services/sync_service_test.dart
```

### Run with Verbose Output
```bash
flutter test test/features/journal/data/services/sync_service_test.dart --verbose
```

## Test Utilities

### Mock Classes

The test helpers provide mock implementations for:
- `MockJournalLocalDataSource` - Local SQLite data source
- `MockJournalRemoteDataSource` - Remote Supabase data source
- `MockTripLocalDataSource` - Local trip storage
- `MockTripRemoteDataSource` - Remote trip storage
- `MockTagLocalDataSource` - Local tag storage
- `MockTagRemoteDataSource` - Remote tag storage
- `MockConnectivityService` - Network connectivity monitoring

### Test Data Factories

#### Journal Entries
```dart
// Create a test entry
final entry = createTestJournalEntryModel(
  id: 'entry-123',
  title: 'Test Entry',
  syncStatus: SyncStatus.pending,
);

// Create multiple pending entries
final pendingEntries = createPendingJournalEntries(count: 5);
```

#### Trips
```dart
// Create a test trip
final trip = createTestTripModel(
  id: 'trip-123',
  name: 'Paris Trip',
  syncStatus: SyncStatus.pending,
);

// Create multiple pending trips
final pendingTrips = createPendingTrips(count: 3);
```

#### Tags
```dart
// Create a test tag
final tag = createTestTagModel(
  id: 'tag-123',
  name: 'Adventure',
  syncStatus: SyncStatus.pending,
);
```

#### Media Items
```dart
// Create a test media item
final media = createTestMediaItemModel(
  id: 'media-123',
  journalEntryId: 'entry-123',
  mediaType: MediaType.image,
  syncStatus: SyncStatus.pending,
);
```

#### Sync Results and Conflicts
```dart
// Create a test sync result
final result = createTestSyncResult(
  success: true,
  uploadedCount: 5,
  downloadedCount: 3,
  conflictCount: 1,
);

// Create a test conflict
final conflict = createTestSyncConflict(
  entityType: 'journal_entry',
  entityId: 'entry-123',
  localUpdatedAt: testDateTime,
  remoteUpdatedAt: testDateTimeLater,
);
```

### Helper Functions

#### Setup Connectivity
```dart
// Setup mock to return connected
setupConnectivityConnected(mockConnectivityService);

// Setup mock to return disconnected
setupConnectivityDisconnected(mockConnectivityService);
```

#### Setup Errors
```dart
// Setup remote to throw 404
setupRemoteThrows404(mockRemoteDataSource, () => mockRemoteDataSource.getEntry('id'));

// Setup remote to throw 500
setupRemoteThrows500(mockRemoteDataSource, () => mockRemoteDataSource.getEntries());
```

#### Assertions
```dart
// Assert sync result matches expected values
assertSyncResultMatches(
  actualResult,
  success: true,
  uploadedCount: 5,
  downloadedCount: 3,
);

// Assert sync progress matches expected values
assertSyncProgressMatches(
  actualProgress,
  totalItems: 100,
  syncedItems: 50,
  progress: 0.5,
);
```

## Test Scenarios

### Offline to Online Transition
Tests that offline changes are synced when connectivity is restored:

```dart
test('should upload pending entries when connection restored', () async {
  // 1. Setup: Create entries while offline
  final pendingEntries = createPendingJournalEntries(count: 3);

  // 2. Setup: Mock connectivity restored
  setupConnectivityConnected(mockConnectivityService);

  // 3. Action: Sync when connected
  final result = await syncService.syncAll();

  // 4. Assert: All entries uploaded
  expect(result.uploadedCount, 3);
  expect(result.success, true);
});
```

### Conflict Detection and Resolution
Tests that conflicts are properly detected and resolved:

```dart
test('should detect and resolve conflicts', () async {
  // 1. Setup: Entry modified both locally and remotely
  final localEntry = createTestJournalEntryModel(
    id: 'conflict-entry',
    title: 'Local Title',
    updatedAt: testDateTime,
  );

  final remoteEntry = createTestJournalEntryModel(
    id: 'conflict-entry',
    title: 'Remote Title',
    updatedAt: testDateTimeLater,
  );

  // 2. Setup: Mock to return both versions
  when(() => mockLocalDataSource.getEntry('conflict-entry'))
      .thenAnswer((_) async => localEntry);
  when(() => mockRemoteDataSource.getEntry('conflict-entry'))
      .thenAnswer((_) async => remoteEntry);

  // 3. Listen for conflicts
  final conflicts = <SyncConflict>[];
  syncService.conflictStream.listen(conflicts.add);

  // 4. Action: Sync
  await syncService.syncEntries();

  // 5. Assert: Conflict detected
  expect(conflicts.length, 1);
  expect(conflicts.first.entityType, 'journal_entry');

  // 6. Resolve conflict
  await syncService.resolveConflict(
    conflicts.first,
    ConflictResolutionStrategy.mostRecent,
  );

  // 7. Assert: Conflict resolved
  verify(() => mockLocalDataSource.updateSyncStatus('conflict-entry', 'synced'))
      .called(1);
});
```

### Network Error Handling
Tests that the service handles network errors gracefully:

```dart
test('should handle network errors during sync', () async {
  // 1. Setup: Mock network error
  when(() => mockRemoteDataSource.getEntries())
      .thenThrow(ServerException(message: 'Network error', statusCode: 500));

  // 2. Action: Sync
  final result = await syncService.syncEntries();

  // 3. Assert: Sync failed gracefully
  expect(result.success, false);
  expect(result.errors.length, greaterThan(0));
  expect(result.errors.first, contains('Network error'));
});
```

### Large Dataset Sync
Tests that the service handles large datasets efficiently:

```dart
test('should sync large dataset in batches', () async {
  // 1. Setup: Create 100 pending entries
  final pendingEntries = createPendingJournalEntries(count: 100);

  // 2. Setup: Configure batch size
  final config = SyncConfig(batchSize: 20);

  // 3. Action: Sync with batch config
  final result = await syncService.syncAll(config);

  // 4. Assert: All entries synced
  expect(result.uploadedCount, 100);
  expect(result.success, true);
});
```

## Test Statistics

- **Total Test Groups**: 11
- **Total Tests**: 50+
- **Test Coverage**: All public methods and edge cases

### Coverage Breakdown
- Initialization: 3 tests
- Full Sync: 6 tests
- Entry Sync: 6 tests
- Trip Sync: 3 tests
- Tag Sync: 3 tests
- Media Sync: 3 tests
- Conflict Resolution: 4 tests
- Statistics: 5 tests
- Progress Tracking: 4 tests
- Cancellation: 1 test
- Directional Sync: 3 tests

## Best Practices

### 1. Isolation
Each test should be independent and not rely on the state of other tests:
```dart
setUp(() {
  // Reset mocks and create fresh service instance for each test
  mockJournalLocalDataSource = MockJournalLocalDataSource();
  syncService = SyncServiceImpl(...);
});
```

### 2. Descriptive Test Names
Use descriptive test names that explain what is being tested:
```dart
test('should upload pending entries to remote when connected', () {
  // Clear purpose
});
```

### 3. Arrange-Act-Assert Pattern
Follow the AAA pattern for clear test structure:
```dart
test('example', () async {
  // Arrange: Setup test data and mocks
  final entry = createTestJournalEntryModel();
  when(() => mockRemote.getEntry(entry.id)).thenAnswer(...);

  // Act: Execute the code being tested
  final result = await syncService.syncEntries();

  // Assert: Verify the expected outcome
  expect(result.success, true);
  verify(() => mockRemote.createEntry(entry)).called(1);
});
```

### 4. Use Test Helpers
Use test helper functions to reduce duplication:
```dart
// Instead of creating entries manually
final entry = JournalEntryModel(...); // Long setup

// Use helper function
final entry = createTestJournalEntryModel(); // Short and clear
```

### 5. Verify Mock Interactions
Always verify that mocks were called correctly:
```dart
verify(() => mockRemoteDataSource.createEntry(entry)).called(1);
verifyNever(() => mockRemoteDataSource.deleteEntry(entry.id));
```

### 6. Test Edge Cases
Don't forget to test edge cases:
- Empty lists (no pending items)
- Network failures
- Conflicts
- Cancellation
- Large datasets

### 7. Use Type-Safe Matchers
Use type-safe matchers for better error messages:
```dart
expect(result, isA<SyncResult>());
expect(result.success, true);
expect(result.uploadedCount, greaterThan(0));
```

## Troubleshooting

### Tests Fail with "No matching calls"
**Problem**: Mock not setup correctly for the test scenario.

**Solution**: Ensure all mock method calls are properly stubbed:
```dart
when(() => mockRemoteDataSource.getEntry(id))
    .thenAnswer((_) async => entry);
```

### Tests Pass Too Quickly
**Problem**: Async operations not being awaited.

**Solution**: Always use `await` for async operations:
```dart
await syncService.syncAll(); // Good
syncService.syncAll(); // Bad - doesn't wait for completion
```

### Mock Verification Fails
**Problem**: Mock not called with expected parameters.

**Solution**: Use `any()` for flexible parameter matching:
```dart
verify(() => mockLocalDataSource.updateEntry(any())).called(1);
```

### Test Data Issues
**Problem**: Test data doesn't match expected format.

**Solution**: Use helper functions with proper defaults:
```dart
final entry = createTestJournalEntryModel(
  syncStatus: SyncStatus.pending, // Override specific fields
);
```

## Integration with CI/CD

### GitHub Actions Example
```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter test test/features/journal/data/services/sync_service_test.dart --coverage
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

### Pre-commit Hook
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run sync tests before commit
flutter test test/features/journal/data/services/sync_service_test.dart

if [ $? -ne 0 ]; then
  echo "Sync tests failed. Commit aborted."
  exit 1
fi
```

## Related Documentation

- [Sync Service Implementation](../../../../../lib/features/journal/data/services/README_SYNC_SERVICE.md)
- [Journal API Tests](../README_JOURNAL_TESTS.md)
- [Media Upload Tests](../../utils/README_MEDIA_TESTS.md)
- [Conflict Resolution Service](../../../../../lib/features/journal/data/services/README_CONFLICT_RESOLUTION.md)

## Contributing

When adding new sync functionality:

1. **Add tests first** (TDD approach)
2. Follow existing test patterns
3. Use test helpers consistently
4. Update this README with new test scenarios
5. Ensure all edge cases are covered
6. Run full test suite before committing

## Future Enhancements

- [ ] Add integration tests with real Supabase
- [ ] Add performance tests for large datasets
- [ ] Add stress tests for concurrent sync operations
- [ ] Add tests for background sync with work manager
- [ ] Add tests for incremental sync using timestamps
- [ ] Add tests for delta sync for media files
- [ ] Add tests for multi-device sync scenarios
- [ ] Add tests for collaborative editing conflicts

## Support

For issues or questions about the sync service tests, please refer to the main project repository or contact the development team.
