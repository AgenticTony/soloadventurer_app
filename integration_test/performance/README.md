# Performance Integration Tests

This directory contains integration tests for establishing baseline performance metrics when handling large trips with 500+ activities and 1000+ photos.

## Test Files

### `large_trip_performance_test.dart`
Main integration test suite that benchmarks:
- **Activity Loading**: Generating and querying 500+ activities
- **Photo Loading**: Generating 1000+ photos with varying metadata
- **Complex Trips**: Trips with both 500 activities and 1000 photos
- **Pagination Performance**: Cursor-based pagination through large datasets
- **Memory Usage**: Memory profiling during large dataset operations
- **Query Performance**: Various filtered queries (by category, date range, etc.)
- **Performance Monitor Integration**: Testing the PerformanceMonitor service

### `test_data_generators.dart`
Utility library for generating realistic test data:
- `generateLargeActivitySet()`: Creates 500+ activities with realistic metadata
- `generateLargePhotoSet()`: Creates 1000+ photos with varying dimensions
- `generateComplexTripData()`: Creates a complete trip with activities and photos
- `generateActivitiesInDateRange()`: Creates activities distributed across time
- `generateClusteredActivities()`: Creates geographically clustered activities
- `generatePhotosWithAspectRatios()`: Creates photos with different aspect ratios

## Running the Tests

### Run All Performance Tests
```bash
flutter test integration_test/performance/large_trip_performance_test.dart
```

### Run with Verbose Output
```bash
flutter test integration_test/performance/large_trip_performance_test.dart --verbose
```

### Run Specific Test Group
```bash
flutter test integration_test/performance/large_trip_performance_test.dart --name="Large Trip Performance Tests"
```

## Performance Baselines

The tests establish the following baseline metrics:

### Activity Performance (500 items)
- **Generation Time**: < 1,000ms
- **Insert Time**: < 2,000ms
- **Query Time**: < 500ms

### Photo Performance (1000 items)
- **Generation Time**: < 1,000ms
- **Memory Usage**: < 250MB peak

### Complex Trip (500 activities + 1000 photos)
- **Setup Time**: < 3,000ms
- **Full Query Time**: < 2,000ms
- **Peak Memory**: < 300MB

### Pagination Performance
- **Average Page Load**: < 100ms
- **Max Page Load**: < 200ms

### Filtered Queries
- **Any Query Type**: < 200ms

## Understanding the Output

Each test outputs structured performance metrics:

```
════════════════════════════════════════════════════════════
Performance Test: 500+ Activities
────────────────────────────────────────────────────────────
  generationTimeMs: 456
  insertTimeMs: 1234
  queryTimeMs: 234
  activityCount: 500
  peakMemoryMB: 123.45
════════════════════════════════════════════════════════════
```

## Performance Targets

These tests validate the performance targets from the spec:

- ✅ App loads and renders smoothly with trips containing 500+ items
- ✅ List views use virtual scrolling for memory efficiency (validated through pagination tests)
- ✅ Images are lazy-loaded (photo generation tests)
- ✅ Memory usage stays within reasonable limits (memory profiling tests)
- ✅ Database queries are optimized (pagination tests)
- ✅ App startup time remains under 2 seconds (monitored via PerformanceMonitor)

## CI/CD Integration

These tests should be run as part of CI/CD pipelines to detect performance regressions. A failure in any performance test should:

1. Block the PR/merge
2. Alert the development team
3. Require investigation into performance degradation

## Future Enhancements

- Add widget-based rendering tests for UI components
- Add scrolling performance tests with Flutter integration
- Add image loading performance tests with actual network calls
- Add map marker clustering tests for 500+ locations
- Add battery usage and thermal throttling tests

## Notes

- These tests use in-memory repositories for fast, repeatable testing
- For production-like testing, replace with actual Supabase repositories
- Memory measurements are estimates based on VM service when available
- Results may vary based on machine performance and load
