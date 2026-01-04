# Performance Benchmark Dashboard

## Overview

The Performance Benchmark Dashboard provides a UI for running, monitoring, and validating performance tests for the SoloAdventurer app. This screen is designed to help developers track performance metrics and ensure the app meets performance targets when handling large datasets (500+ items).

## Location

- **Screen**: `lib/features/performance/presentation/screens/performance_benchmark_screen.dart`
- **Routes**: `lib/features/performance/presentation/routes/performance_routes.dart`
- **Route Path**: `/performance-benchmark`

## Features

### 1. Test Selection
Choose from multiple performance test types:
- **Comprehensive Baseline**: Complete performance measurement (memory + generation speed)
- **Memory Test (500 trips)**: Measures memory usage when loading 500 trips
- **Memory Test (500 photos)**: Measures memory usage when loading 500 photo metadata
- **List Rendering Test**: Measures list widget creation and rendering time
- **Data Generation Test**: Measures performance of generating 500+ test data items

### 2. Performance Metrics Display
The dashboard displays the following metrics:
- **Startup Time**: Time taken to initialize (ms)
- **Memory Usage**: Current memory consumption (MB)
- **List Render Time**: Time to render list widgets (ms)
- **Scroll FPS**: Frames per second during scrolling
- **Janky Frames**: Percentage of frames that took > 16ms

### 3. Performance Targets
Visual indicators show whether metrics meet performance targets:
- ✅ Startup Time < 2000ms
- ✅ Memory Usage < 200 MB
- ✅ List Render Time < 3000ms
- ✅ Scroll FPS ≥ 55
- ✅ Janky Frames < 10%

### 4. Baseline Comparison
- **Set Baseline**: Save current metrics as a baseline for comparison
- **Compare Results**: View differences between current and baseline metrics
- **Track Improvements**: Monitor performance improvements over time

### 5. Visual Feedback
- **Green indicators**: Metrics meet performance targets
- **Orange indicators**: Metrics exceed performance targets
- **Snackbar notifications**: Test completion status
- **Loading indicators**: Visual feedback during test execution

## Usage

### Access the Dashboard

1. Run the app and log in
2. Navigate to the Home screen
3. Click the "Performance Benchmark" button
4. Or navigate directly: `Navigator.pushNamed(context, PerformanceRoutes.benchmark)`

### Running Tests

1. **Select Test Type**: Choose from the dropdown menu
2. **Run Test**: Click the "Run Performance Test" button
3. **View Results**: Metrics will display below the test button
4. **Set Baseline** (optional): Click the save icon in the app bar to save as baseline

### Interpreting Results

**Passing Test (All Targets Met)**:
- All metric rows show green checkmarks
- Success message: "✅ All performance targets met!"
- Green snackbar notification

**Failing Test (Targets Not Met)**:
- Problematic metrics show orange warning icons
- Failure message lists which targets were not met
- Orange snackbar notification with warning

### Best Practices

1. **Run in Profile Mode**: For accurate metrics, run tests in profile mode:
   ```bash
   flutter run --profile
   ```

2. **Establish Baseline**: Run tests before optimizations to establish a baseline

3. **Compare Results**: Use baseline comparison to measure optimization impact

4. **Test on Real Devices**: Test on physical devices for accurate memory metrics

5. **Multiple Runs**: Run each test multiple times to account for variance

## Integration with Performance Testing Utilities

The dashboard integrates with:
- `PerformanceTestDataGenerator`: Generates test data
- `PhotoDataGenerator`: Generates photo test data
- `PerformanceReporter`: Captures and reports metrics
- `PerformanceMetrics`: Data model for metrics

## Architecture

### State Management
- Uses `ConsumerStatefulWidget` with Riverpod
- Local state for UI (test status, results, metrics)
- No persistent state management required (metrics are ephemeral)

### Performance Test Flow

```
User selects test → Run button clicked → Test executes → Metrics captured → Results displayed
                                                    ↓
                                            Set as baseline (optional)
```

### Error Handling
- Try-catch blocks around all test executions
- User-friendly error messages in snackbar
- Test status reset on error

## Future Enhancements

Potential improvements for the dashboard:
1. **Historical Metrics**: Store and display test history in a graph
2. **Export Results**: Export metrics as JSON/CSV for analysis
3. **Automated Testing**: Run all tests in sequence
4. **Device Information**: Display device model and specs
5. **Performance Trends**: Visual charts showing performance over time
6. **CI/CD Integration**: Automated performance regression detection

## Related Files

- `test/utils/performance/performance_reporter.dart`: Core metrics capture
- `test/utils/performance/test_data_generator.dart`: Test data generation
- `test/features/travel/performance/baseline_performance_test.dart`: Automated tests
- `lib/core/monitoring/performance/app_start_tracker.dart`: App startup tracking

## Troubleshooting

**Issue**: Tests fail with "VM service not available"
- **Solution**: Some metrics require running in debug/profile mode, not release mode

**Issue**: Memory metrics show 0 or estimate
- **Solution**: This is expected when VM service is unavailable. The app uses a 100MB estimate

**Issue**: Tests run very slowly
- **Solution**: Ensure you're running in profile mode, not debug mode with heavy debugging

**Issue**: Results vary between runs
- **Solution**: This is normal. Run multiple tests and use averages for accurate metrics

## Example Workflow

```dart
// 1. Navigate to dashboard
Navigator.pushNamed(context, PerformanceRoutes.benchmark);

// 2. Select "Comprehensive Baseline" test
// 3. Click "Run Performance Test"
// 4. Review results
// 5. Click save icon to set as baseline
// 6. Make optimizations to code
// 7. Run test again
// 8. Compare with baseline to measure improvement
```

## Performance Targets Summary

| Metric | Target | Direction |
|--------|--------|-----------|
| Startup Time | < 2000ms | Lower is better |
| Memory Usage | < 200 MB | Lower is better |
| List Render Time | < 3000ms | Lower is better |
| Scroll FPS | ≥ 55 | Higher is better |
| Janky Frames | < 10% | Lower is better |

These targets are based on industry standards for mobile app performance and ensure smooth user experience even with large datasets (500+ items).
