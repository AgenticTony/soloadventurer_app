# Memory Leak Detection Tests

Integration tests for detecting memory leaks during common user flows in the SoloAdventurer app.

## Purpose

These tests verify that the app properly manages memory during:
- Scrolling through large lists (activities, photos)
- Loading and caching images
- Map navigation with marker clustering
- Widget creation and disposal cycles
- Stream subscription management

## Test Files

- `memory_leak_test.dart` - Main memory leak detection test suite
- `test_data_generators.dart` - Utilities for generating large test datasets
- `large_trip_performance_test.dart` - Performance benchmark tests

## Running the Tests

### Run All Memory Leak Tests

```bash
flutter test integration_test/performance/memory_leak_test.dart
```

### Run Specific Test

```bash
flutter test integration_test/performance/memory_leak_test.dart --name="Activities screen"
```

### Run with Detailed Output

```bash
flutter test integration_test/performance/memory_leak_test.dart --reporter=expanded
```

## Test Descriptions

### 1. Activities Screen Memory Leak Test
Tests for memory leaks during scrolling through a list of 500+ activities.

**Test Flow:**
1. Generate 500 activities
2. Build activities screen with infinite scroll
3. Scroll through multiple pages (5 pages × 3 cycles)
4. Dispose widget
5. Verify memory returns to baseline

**Acceptance Criteria:**
- Memory growth < 30% across cycles
- Total growth < 50% from baseline
- Memory trend is not consistently increasing

### 2. Photo Gallery Memory Leak Test
Tests for memory leaks during image loading in a photo gallery.

**Test Flow:**
1. Generate 300 photos with varied aspect ratios
2. Build photo gallery with infinite scroll grid
3. Load and cache images (5 pages × 3 cycles)
4. Dispose widget
5. Verify memory returns to baseline

**Acceptance Criteria:**
- Memory growth < 30% across cycles
- Total growth < 100% from baseline (images are cached)
- No excessive memory retention after disposal

### 3. Map Screen Memory Leak Test
Tests for memory leaks during map navigation with marker clustering.

**Test Flow:**
1. Generate 200 clustered map markers
2. Build map screen with clustering manager
3. Simulate pan and zoom operations
4. Dispose managers and widget
5. Verify memory returns to baseline

**Acceptance Criteria:**
- Memory growth < 30% across cycles
- Total growth < 50% from baseline
- Stream subscriptions properly canceled
- Managers properly disposed

### 4. Widget Creation/Disposal Memory Leak Test
Tests for memory leaks from rapid widget creation and disposal.

**Test Flow:**
1. Create complex widget hierarchy
2. Capture memory snapshot
3. Dispose widget
4. Repeat 20 times
5. Verify memory remains stable

**Acceptance Criteria:**
- Memory growth < 15% across cycles
- Total growth < 20% from baseline
- Memory trend is stable or decreasing

### 5. Stream Subscription Memory Leak Test
Tests for memory leaks from stream subscription cycles.

**Test Flow:**
1. Create clustering manager
2. Subscribe to clustering stream
3. Trigger multiple updates
4. Cancel subscription and dispose
5. Repeat 5 times
6. Verify no accumulated memory

**Acceptance Criteria:**
- Memory growth < 20% across cycles
- Total growth < 25% from baseline
- No retained stream subscriptions

## Memory Leak Detection Strategy

### What Constitutes a Memory Leak?

A memory leak is indicated when:
1. **Consistent Growth**: Memory grows consistently across iterations (> 10% per cycle)
2. **No Recovery**: Memory doesn't return to baseline after widget disposal
3. **Continuous Trend**: Memory trend shows continuous growth without recovery

### Testing Methodology

1. **Baseline Capture**: Capture initial memory snapshot before any operations
2. **Iterative Testing**: Perform operations in multiple cycles (3-5 iterations)
3. **Snapshot Collection**: Capture memory after each cycle
4. **Disposal Verification**: Ensure widgets and resources are properly disposed
5. **Trend Analysis**: Verify memory trend is stable or decreasing

### Memory Thresholds

- **Strict Threshold** (< 15% growth): Widget creation/disposal cycles
- **Normal Threshold** (< 30% growth): Scrolling, navigation, subscriptions
- **Lenient Threshold** (< 50-100% growth): Image caching (expected to cache data)

## Understanding Test Results

### Test Output Format

```
════════════════════════════════════════════════════════════════════════
Memory Leak Test: Activities Screen Memory Leak Test
──────────────────────────────────────────────────────────────────────────
Baseline Memory: 45.23 MB
Final Memory: 52.18 MB
Peak Memory: 58.45 MB
Average Memory: 50.12 MB
Trend: stable (2.3%)
Snapshots: 7
Total Growth: 15.4%

Cycle Snapshots:
  Cycle 1: 48.12 MB (+6.3%)
  Cycle 2: 49.87 MB (+10.2%)
  Cycle 3: 50.45 MB (+11.5%)
════════════════════════════════════════════════════════════════════════
```

### Interpreting Results

- **Baseline Memory**: Starting memory before test execution
- **Final Memory**: Memory after all test cycles
- **Peak Memory**: Highest memory usage during test
- **Average Memory**: Mean memory usage across all snapshots
- **Trend**: Memory direction (increasing, decreasing, stable)
- **Total Growth**: Percentage increase from baseline

### Success Indicators

✅ **Passing Test**: Memory growth within acceptable thresholds
✅ **Stable Trend**: Trend is "stable" or "decreasing"
✅ **No Continuous Growth**: Snapshots show fluctuations, not consistent increase

### Failure Indicators

❌ **Failing Test**: Memory growth exceeds thresholds
❌ **Increasing Trend**: Trend shows "increasing" with high percentage
❌ **Continuous Growth**: Each cycle shows higher memory than previous

## Troubleshooting

### Test Failures

If a memory leak test fails:

1. **Run DevTools Memory Profiler**
   ```bash
   flutter run --profile
   # Open DevTools > Memory
   # Capture heap snapshot before and after operations
   ```

2. **Check Common Issues**
   - undisposed controllers (MapController, AnimationController)
   - uncanceled stream subscriptions
   - retained references in closures
   - missing dispose() in StatefulWidgets

3. **Verify Disposal Patterns**
   - All StreamSubscription.cancel() called
   - All dispose() methods called
   - No circular references
   - Timers properly canceled

4. **Check Image Caching**
   - CachedNetworkImage cache limits
   - ImageCacheConfig settings
   - MemoryAwareCacheManager behavior

### Manual Verification

For manual memory leak verification:

1. Run the app in profile mode
2. Open Flutter DevTools
3. Navigate to Memory tab
4. Perform the user flow
5. Take memory snapshot
6. Perform GC (garbage collection)
7. Take another snapshot
8. Compare for growth

## Best Practices

### Prevention

1. **Dispose Patterns**
   - Always override dispose() in StatefulWidgets
   - Cancel stream subscriptions in reverse order of creation
   - Dispose controllers before parent widgets

2. **Stream Management**
   - Store subscriptions in variables for later cancellation
   - Use cancel() in dispose()
   - Avoid unawaited futures in streams

3. **Image Loading**
   - Use LazyLoadImage for off-screen images
   - Configure cache limits appropriately
   - Implement progressive loading for large images

4. **List Performance**
   - Use VirtualListView for large lists
   - Implement const constructors where possible
   - Use RepaintBoundary for complex items

### Testing

- Run memory leak tests regularly (before releases)
- Test with realistic data sizes (500+ activities, 1000+ photos)
- Verify on physical devices (not just simulators)
- Test on low-end devices to catch issues early

## Related Documentation

- [Performance Testing Guide](../docs/performance/benchmarks.md)
- [Memory Management Guide](../docs/performance/optimization_techniques.md)
- [Large Trip Performance Tests](./large_trip_performance_test.dart)
- [Memory Profiler Service](../../lib/core/monitoring/performance/memory_profiler.dart)

## Dependencies

- `flutter_test` - Testing framework
- `integration_test` - Integration test support
- `flutter_riverpod` - State management
- `MemoryProfiler` - Memory profiling utilities
- `TestDataGenerator` - Test data generation

## Maintenance

### When to Update Tests

- Adding new screens with heavy memory usage
- Changing image loading strategy
- Modifying list rendering logic
- Updating map marker clustering

### Test Maintenance Tips

- Keep dataset sizes realistic (match production scenarios)
- Update thresholds based on actual device capabilities
- Add new tests for new features
- Review and update documentation regularly
