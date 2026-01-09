# Performance Baseline Documentation

## Overview

This document describes the performance baseline measurement system established for the SoloAdventurer app to handle large datasets (500+ items).

## Purpose

The performance baseline system:
- Establishes current performance metrics before optimization
- Provides measurable targets for optimization efforts
- Enables regression detection to prevent performance degradation
- Tracks progress across the optimization initiative

## Performance Targets

Based on the spec acceptance criteria, the following targets must be met:

| Metric | Target | Rationale |
|--------|--------|-----------|
| **App Startup Time** | < 2 seconds | Users expect fast app launch |
| **Memory Usage** | < 200 MB | Mobile device limits |
| **List Render Time (500 items)** | < 3 seconds | Acceptable wait time for content |
| **Scroll FPS** | ≥ 55 FPS | Smooth scrolling experience |
| **Janky Frames** | < 10% | Consistent frame delivery |

## Components

### 1. PerformanceReporter Utility

**Location:** `test/utils/performance/performance_reporter.dart`

Provides utilities for capturing and reporting performance metrics:

#### Key Methods

- `captureMemoryUsage()` - Capture current heap memory usage
- `measureTime()` - Measure async execution time
- `measureSyncTime()` - Measure sync execution time
- `captureScrollMetrics()` - Capture scroll performance metrics
- `createMetrics()` - Create a PerformanceMetrics object
- `printReport()` - Print formatted metrics report
- `compareMetrics()` - Compare two sets of metrics

#### PerformanceMetrics Class

Encapsulates all performance measurements:

```dart
class PerformanceMetrics {
  final int startupTimeMs;           // App startup time
  final int memoryUsageBytes;        // Memory consumption
  final int listRenderTimeMs;        // List rendering time
  final double scrollFPS;            // Scroll frame rate
  final double jankyFramePercentage; // Janky frames %
  final DateTime timestamp;          // Capture time
}
```

### 2. Baseline Performance Tests

**Location:** `test/features/travel/performance/baseline_performance_test.dart`

Comprehensive test suite measuring:

#### Memory Tests
- **500 trips memory usage** - Baseline memory for trip objects
- **500 photo URLs memory usage** - Baseline for URL strings
- **500 photo metadata memory usage** - Baseline for complex objects
- **1000 trips stress test** - Memory scalability

#### Rendering Tests
- **List rendering (500 items)** - Initial render time
- **Complex list rendering** - Render time with rich items
- **Scroll performance** - FPS and janky frames during scroll

#### Generation Tests
- **Data generation performance** - Test data creation speed
- **Geographic distribution** - Coordinate-based data generation

### 3. Test Data Generators

**Location:** `test/utils/performance/test_data_generator.dart`
**Location:** `test/utils/performance/photo_data_generator.dart`

Generate realistic test data for benchmarking:

- `PerformanceTestDataGenerator.generateLargeTripList(count: 500)` - 500 trips
- `PhotoDataGenerator.generatePhotoMetadata(count: 500)` - 500 photo metadata objects

## Usage

### Running Baseline Tests

```bash
# Run all baseline tests
flutter test test/features/travel/performance/baseline_performance_test.dart

# Run with coverage
flutter test --coverage test/features/travel/performance/baseline_performance_test.dart

# Run integration tests (includes full app startup)
flutter test integration_test/test/features/travel/performance/baseline_performance_test.dart
```

### Using PerformanceReporter in Custom Tests

```dart
test('My performance test', () async {
  // Measure execution time
  final result = await PerformanceReporter.measureTime(
    'My operation',
    () async {
      // Your code here
      return someValue;
    },
  );

  // Capture memory
  final memoryBefore = await PerformanceReporter.captureMemoryUsage();
  // ... perform operations ...
  final memoryAfter = await PerformanceReporter.captureMemoryUsage();
  final memoryDelta = memoryAfter - memoryBefore;

  // Create metrics
  final metrics = PerformanceReporter.createMetrics(
    startupTimeMs: 0,
    memoryUsageBytes: memoryDelta,
    listRenderTimeMs: 100,
    scrollFPS: 60.0,
    jankyFramePercentage: 0.0,
  );

  // Print report
  PerformanceReporter.printReport(metrics);

  // Verify targets
  expect(metrics.meetsTargets(), isTrue);
});
```

## Current Baseline Metrics

### Initial Measurements (Phase 1)

These are the baseline measurements before optimization:

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Startup Time | TBD | < 2000ms | ⏳ Pending |
| Memory (500 trips) | TBD | < 200 MB | ⏳ Pending |
| List Render (500 items) | TBD | < 3000ms | ⏳ Pending |
| Scroll FPS | TBD | ≥ 55 | ⏳ Pending |
| Janky Frames | TBD | < 10% | ⏳ Pending |

**Note:** Baseline values will be populated after first test run.

## Interpreting Results

### Memory Usage

- **Good:** < 100 MB for 500 items
- **Acceptable:** 100-200 MB
- **Poor:** > 200 MB

### Render Time

- **Good:** < 1 second for 500 items
- **Acceptable:** 1-3 seconds
- **Poor:** > 3 seconds

### Scroll Performance

- **Good:** > 58 FPS, < 5% janky
- **Acceptable:** 55-58 FPS, 5-10% janky
- **Poor:** < 55 FPS, > 10% janky

## Optimization Tracking

As you implement optimizations:

1. **Before optimization:** Run baseline tests and record metrics
2. **Implement optimization:** Apply changes (virtual scrolling, lazy loading, etc.)
3. **After optimization:** Run baseline tests again
4. **Compare results:** Use `PerformanceReporter.compareMetrics()` to see improvements
5. **Update baseline:** Set new baseline if improvements are significant

### Example Comparison

```dart
final baseline = PerformanceMetrics(...); // Before optimization
final current = PerformanceMetrics(...);  // After optimization

print(PerformanceReporter.compareMetrics(baseline, current));
// Output:
// Performance Comparison:
// - Startup Time: -300ms (1700ms vs 2000ms) ✅
// - Memory Usage: -25.50MB (150.00MB vs 175.50MB) ✅
// - List Render Time: -800ms (1200ms vs 2000ms) ✅
```

## Continuous Monitoring

### CI/CD Integration

Add baseline tests to CI/CD pipeline to detect regressions:

```yaml
# .github/workflows/performance.yml
name: Performance Tests
on: [pull_request]
jobs:
  performance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter test test/features/travel/performance/
      - name: Upload results
        uses: actions/upload-artifact@v2
        with:
          name: performance-results
          path: test/results/
```

### Regression Detection

If performance degrades significantly:

1. Check what changed in the PR
2. Run tests locally to confirm
3. Profile with Flutter DevTools to identify bottlenecks
4. Fix or revert the regression

## Best Practices

1. **Run tests on consistent hardware** - Different devices produce different results
2. **Close other apps** - Ensure consistent system resources
3. **Run multiple iterations** - Average out variations
4. **Test in profile mode** - More accurate than debug mode
   ```bash
     flutter test --profile
   ```
5. **Monitor over time** - Track metrics across releases

## Troubleshooting

### VM Service Not Available

If you see "VM service protocol not available":

```bash
# Run tests with VM service enabled
flutter test --enable-vm-service
```

### Inconsistent Results

- Ensure consistent device load
- Run tests multiple times and average
- Use profile mode instead of debug mode

### Memory Reporting Zero

- Check if VM service is available
- Verify test environment supports memory profiling
- Try running in profile mode

## Next Steps

After establishing baseline:

1. ✅ **Phase 1-Subtask-1:** Create test data generators (COMPLETE)
2. ✅ **Phase 1-Subtask-2:** Establish performance baseline (IN PROGRESS)
3. **Phase 1-Subtask-3:** Add performance monitoring dependencies
4. **Phase 1-Subtask-4:** Create performance benchmark dashboard
5. **Phase 2:** Implement virtual scrolling
6. **Phase 3:** Implement lazy loading
7. **Phase 8:** Validate all targets met

## Related Documentation

- [Spec: Performance Optimization for Large Trips](../.auto-claude/specs/006-performance-optimization-for-large-trips/spec.md)
- [Test Data Generators README](./test/utils/performance/README.md)
- [Implementation Plan](../.auto-claude/specs/006-performance-optimization-for-large-trips/implementation_plan.json)

## References

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools/performance)
- [Performance Profiling](https://docs.flutter.dev/perf/rendering/best-practices)
