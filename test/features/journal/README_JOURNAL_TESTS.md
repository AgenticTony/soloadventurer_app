# Journal Feature Tests

Comprehensive unit tests for the Travel Journal feature covering all CRUD operations and edge cases.

## Test Files

### 1. Test Helpers
**Location:** `test/features/journal/helpers/journal_test_helpers.dart`

Provides:
- Mock classes for all journal dependencies
- Test data factories for journal entries, media items, and tags
- Helper functions for creating test entities with custom properties
- Helper functions for creating test JSON maps (Supabase format)
- Custom assertion helpers for exception testing

**Key Functions:**
- `createTestJournalEntryModel()` - Creates test journal entry data models
- `createTestJournalEntry()` - Creates test journal entry entities
- `createTestMediaItemModel()` - Creates test media item data models
- `createTestMediaItem()` - Creates test media item entities
- `createTestJournalEntryList({count})` - Creates lists of entries
- `createTestMediaItemList({count})` - Creates lists of media items
- `verifyThrowsAppException()` - Verifies AppException is thrown
- `verifyThrowsServerException()` - Verifies ServerException is thrown

### 2. Remote Data Source Tests
**Location:** `test/features/journal/data/datasources/journal_remote_data_source_test.dart`

Tests the `JournalRemoteDataSourceImpl` class which communicates with Supabase.

**Coverage Areas:**

#### Entry CRUD Operations (14 tests)
- ✅ `createEntry` - Success case, error handling, custom error codes
- ✅ `getEntry` - Found case, 404 errors (both 404 and PGRST116 codes)
- ✅ `getEntries` - List retrieval, authentication check
- ✅ `getEntriesByTrip` - Trip filtering, error handling
- ✅ `getEntriesByDateRange` - Date range filtering, authentication check
- ✅ `searchEntries` - Text search, authentication check
- ✅ `getFavoriteEntries` - Favorite filtering, authentication check
- ✅ `updateEntry` - Success case, error handling
- ✅ `deleteEntry` - Success case, error handling
- ✅ `toggleFavorite` - Toggle logic, error handling
- ✅ `getEntriesWithLocation` - Location filtering, authentication check
- ✅ `getEntriesNearLocation` - Geospatial queries, authentication check

#### Media CRUD Operations (12 tests)
- ✅ `addMedia` - Success case, error handling
- ✅ `updateMedia` - Success case, error handling
- ✅ `deleteMedia` - Success case, error handling
- ✅ `getMediaForEntry` - List retrieval, error handling
- ✅ `getMediaForTrip` - Trip media retrieval, empty trip case, error handling
- ✅ `updateMediaUploadProgress` - Progress updates, status changes at 100%
- ✅ `completeMediaUpload` - Completion with all fields set
- ✅ `failMediaUpload` - Failure status marking

#### Tag Operations (8 tests)
- ✅ `getTagsForEntry` - Tag retrieval, error handling
- ✅ `addTagToEntry` - Tag addition, error handling
- ✅ `removeTagFromEntry` - Tag removal, error handling
- ✅ `updateTagsForEntry` - Bulk tag replacement, empty list handling

#### Edge Cases (5 tests)
- ✅ Null values in optional fields
- ✅ Concurrent operations
- ✅ Large content strings (100KB)
- ✅ Special characters in content
- ✅ Date range boundary conditions

### 3. Repository Tests
**Location:** `test/features/journal/data/repositories/journal_repository_impl_test.dart`

Tests the `JournalRepositoryImpl` class which orchestrates data operations.

**Coverage Areas:**

#### Entry CRUD Operations (25 tests)
- ✅ `createEntry` - Entity to model conversion, success/failure paths
- ✅ `getEntry` - Model to entity conversion, error propagation
- ✅ `getEntries` - List conversion, empty list handling
- ✅ `getEntriesByTrip` - Trip filtering with conversion
- ✅ `getEntriesByDateRange` - Date filtering, invalid range handling
- ✅ `searchEntries` - Empty queries, special characters
- ✅ `getFavoriteEntries` - Favorite status verification
- ✅ `updateEntry` - Update with conversion
- ✅ `deleteEntry` - Deletion with error handling
- ✅ `toggleFavorite` - Toggle both directions (false→true, true→false)
- ✅ `getEntriesWithLocation` - Location data verification
- ✅ `getEntriesNearLocation` - Zero radius, very large radius

#### Media CRUD Operations (14 tests)
- ✅ `addMedia` - Entity to model conversion
- ✅ `updateMedia` - Media update with conversion
- ✅ `deleteMedia` - Deletion with error handling
- ✅ `getMediaForEntry` - List with conversion
- ✅ `getMediaForTrip` - Trip media with conversion
- ✅ `updateMediaUploadProgress` - Progress at 0%, 50%, 100%
- ✅ `completeMediaUpload` - Completion status verification
- ✅ `failMediaUpload` - Failed status marking

#### Tag Operations (8 tests)
- ✅ `getTagsForEntry` - Tag list retrieval
- ✅ `addTagToEntry` - Tag addition with error handling
- ✅ `removeTagFromEntry` - Tag removal with error handling
- ✅ `updateTagsForEntry` - Bulk updates, empty list handling

#### Edge Cases (5 tests)
- ✅ Null optional fields in entries
- ✅ Large content (100KB text)
- ✅ Special characters and emoji
- ✅ Rapid successive operations
- ✅ Media with all null optional fields

## Running the Tests

### Run All Journal Tests
```bash
# Run all journal tests
flutter test test/features/journal/

# Run with coverage
flutter test --coverage test/features/journal/

# Run specific test file
flutter test test/features/journal/data/repositories/journal_repository_impl_test.dart

# Run specific test group
flutter test --name "JournalRepositoryImpl.*Entry CRUD"
```

### Run with Verbose Output
```bash
flutter test --verbose test/features/journal/
```

### Run Tests Watching for Changes
```bash
flutter test test/features/journal/ --watch
```

## Test Statistics

**Total Test Count:** 80+ tests
- Remote Data Source: 39 tests
- Repository: 52 tests
- Edge Cases: 10 tests

**Coverage:**
- ✅ All CRUD operations (Create, Read, Update, Delete)
- ✅ All query methods (by trip, date, location, search, favorites)
- ✅ All media operations (add, update, delete, upload progress)
- ✅ All tag operations (get, add, remove, update)
- ✅ All error scenarios (404, 500, authentication failures)
- ✅ All edge cases (null values, large content, special characters, concurrent operations)

## Testing Patterns Used

### 1. AAA Pattern (Arrange-Act-Assert)
All tests follow the Arrange-Act-Assert pattern:
```dart
test('should return JournalEntry when creation is successful', () async {
  // Arrange - Set up test data and mocks
  final testEntity = createTestJournalEntry();
  when(() => mockRemoteDataSource.createEntry(any()))
      .thenAnswer((_) async => testModel);

  // Act - Execute the code under test
  final result = await repository.createEntry(testEntity);

  // Assert - Verify the outcome
  expect(result, isA<JournalEntry>());
  verify(() => mockRemoteDataSource.createEntry(any())).called(1);
});
```

### 2. Mock Verification
Tests verify both return values and mock interactions:
```dart
verify(() => mockRemoteDataSource.createEntry(any())).called(1);
verifyNever(() => mockRemoteDataSource.getCurrentUser());
```

### 3. Exception Testing
Tests verify proper exception handling and propagation:
```dart
expect(
  () => repository.createEntry(testEntity),
  throwsA(isA<AppException>()),
);
```

### 4. Edge Case Coverage
Tests include boundary conditions and unusual inputs:
- Empty strings and lists
- Null values for optional fields
- Very large content strings (100KB)
- Special characters and emoji (🎉)
- Invalid date ranges (end before start)
- Zero and very large radius values
- Rapid successive operations

### 5. Data Conversion Verification
Tests verify proper entity↔model conversion:
```dart
// Arrange
final testEntity = createTestJournalEntry();
final testModel = createTestJournalEntryModel();

// Act - Should convert entity to model before calling data source
await repository.createEntry(testEntity);

// Assert - Verify conversion happened
final captured = verify(() => mockRemoteDataSource.createEntry(captureAny()))
    .captured.single as JournalEntryModel;
expect(captured.title, equals(testEntity.title));
```

## Key Test Scenarios

### CRUD Operations
1. **Create** - Success, error handling, entity conversion
2. **Read** - Single item, lists, by filters, not found
3. **Update** - Success, error handling, field updates
4. **Delete** - Success, error handling, cascade effects

### Query Methods
- By trip ID
- By date range (including boundary conditions)
- By location (nearby queries)
- By favorite status
- By text search
- By upload status

### Media Operations
- Upload progress tracking (0%, 50%, 100%)
- Completion status setting
- Failure status marking
- Media for entries and trips
- Optional field handling (dimensions, duration, etc.)

### Tag Operations
- Single tag addition/removal
- Bulk tag replacement
- Empty tag lists
- Tag retrieval for entries

### Error Handling
- 404 Not Found errors
- 500 Server errors
- Authentication failures (401)
- Custom error codes (e.g., PGRST116)
- Exception propagation from data source to repository

## Dependencies

- `flutter_test` - Flutter testing framework
- `mocktail` - Mocking library (modern replacement for mockito)
- `supabase_flutter` - Supabase client (for real data source)
- `soloadventurer` - App imports

## Maintenance Notes

### Adding New Tests
1. Add test data factory to `journal_test_helpers.dart` if needed
2. Add test case to appropriate test file (repository or data source)
3. Follow AAA pattern
4. Include success, failure, and edge case scenarios

### Debugging Failed Tests
- Run with `--verbose` flag for detailed output
- Use `print()` statements for temporary debugging
- Check mock setup with `verify()` and `verifyNever()`
- Ensure fallback values are registered for mocktail

### Test Data Factories
When adding new fields to entities:
1. Update `createTestJournalEntryModel()` or `createTestMediaItemModel()`
2. Update `createTestJournalEntryJson()` or `createTestMediaItemJson()`
3. Add parameter to factory function with default value

## Integration with CI/CD

These tests are designed to run in CI/CD pipelines:
- No external dependencies required (all mocked)
- Fast execution (no real database calls)
- Deterministic results (no random data)
- Clear error messages for failures

## Future Enhancements

Potential improvements:
1. Add widget tests for journal UI components
2. Add integration tests with real Supabase instance
3. Add performance tests for large datasets
4. Add concurrency stress tests
5. Add property-based testing for edge cases
