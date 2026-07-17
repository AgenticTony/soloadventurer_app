# Performance Tracking Guide for Virtual Lists

This guide explains how to use the performance tracking system for VirtualListView and VirtualGridView widgets.

## Overview

The performance tracking system provides real-time metrics for virtual scrolling components to help optimize rendering performance, memory usage, and frame rates. It consists of two main components:

1. **VirtualListPerformanceTracker** - Widget that wraps virtual lists/grids and tracks performance
2. **ScrollPerformanceTracker** - Utility for detailed scroll performance analysis

## Features

### Tracked Metrics

- **Initial Render Time**: Time taken for the first render in milliseconds
- **Memory Usage**: Current memory consumption during scrolling
- **Average FPS**: Frames per second during scrolling
- **Janky Frame Percentage**: Percentage of frames that took >16ms (below 60 FPS)
- **Total Frames**: Number of frames rendered
- **Peak Velocity**: Maximum scroll velocity (for scroll tracker)
- **Scroll Distance**: Total pixels scrolled (for scroll tracker)

### Performance Targets

- **Initial Render Time**: < 1000ms
- **Memory Usage**: < 150 MB
- **Average FPS**: ≥ 55 FPS
- **Janky Frames**: < 10%

## Usage

### Basic Performance Tracking

Wrap your VirtualListView or VirtualGridView with VirtualListPerformanceTracker:

```dart
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/widgets/widgets.dart';

VirtualListPerformanceTracker(
  itemName: 'Trip Items List',
  showOverlay: true,
  onMetricsUpdated: (metrics) {
    if (kDebugMode) {
      debugPrint('Performance: ${metrics.averageFPS.toStringAsFixed(1)} FPS');
      debugPrint('Memory: ${(metrics.currentMemoryUsageBytes / 1024 / 1024).toStringAsFixed(1)} MB');
    }
  },
  child: VirtualListView<Trip>(
    itemCount: trips.length,
    itemBuilder: (context, index) => TripCard(trip: trips[index]),
  ),
)
```

### Without Overlay

If you don't want the visual overlay but still want to track metrics:

```dart
VirtualListPerformanceTracker(
  itemName: 'Photo Gallery',
  showOverlay: false,
  onMetricsUpdated: (metrics) {
    // Send to analytics or logging service
    Analytics.logPerformance(
      fps: metrics.averageFPS,
      renderTime: metrics.initialRenderTimeMs,
      memory: metrics.currentMemoryUsageBytes,
    );
  },
  child: VirtualGridView<Photo>(
    itemCount: photos.length,
    crossAxisCount: 3,
    itemBuilder: (context, index) => PhotoCard(photo: photos[index]),
  ),
)
```

### Disabling Tracking

Disable tracking in production builds (automatic by default):

```dart
VirtualListPerformanceTracker(
  enabled: kDebugMode, // Only track in debug mode
  child: VirtualListView<Trip>(...),
)
```

### Scroll Performance Tracking

For detailed scroll performance metrics, use ScrollPerformanceTrackerWidget:

```dart
import 'package:soloadventurer/core/utils/scroll_performance_tracker.dart';

ScrollPerformanceTrackerWidget(
  minScrollDurationMs: 500, // Only track scrolls > 500ms
  maxIdleTimeMs: 100, // Consider scroll ended after 100ms idle
  onScrollComplete: (details) {
    if (kDebugMode) {
      debugPrint('Scroll Performance:');
      debugPrint('  Duration: ${details.scrollDurationMs}ms');
      debugPrint('  Distance: ${details.pixelsScrolled.toStringAsFixed(0)}px');
      debugPrint('  Avg Velocity: ${details.averageVelocity.toStringAsFixed(0)}px/s');
      debugPrint('  Peak Velocity: ${details.peakVelocity.toStringAsFixed(0)}px/s');
      debugPrint('  Avg FPS: ${details.averageFPS.toStringAsFixed(1)}');
      debugPrint('  Janky: ${details.jankyFramePercentage.toStringAsFixed(1)}%');
    }
  },
  child: VirtualListView<Trip>(
    itemCount: trips.length,
    itemBuilder: (context, index) => TripCard(trip: trips[index]),
  ),
)
```

### Manual Scroll Tracking

For more control, use ScrollPerformanceTracker directly:

```dart
class MyWidgetState extends State<MyWidget> {
  late ScrollPerformanceTracker _scrollTracker;

  @override
  void initState() {
    super.initState();
    _scrollTracker = ScrollPerformanceTracker(
      onScrollComplete: (details) {
        // Handle scroll completion
      },
    );
  }

  @override
  void dispose() {
    _scrollTracker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _scrollTracker.handleScrollNotification(notification);
        return false;
      },
      child: VirtualListView<Trip>(...),
    );
  }
}
```

## Performance Overlay

When `showOverlay: true`, a performance overlay is displayed in the top-right corner showing:

- **FPS**: Current frames per second
- **Janky**: Percentage of janky frames
- **Render**: Initial render time
- **Memory**: Current memory usage

The overlay uses color coding:
- 🟢 **Green**: Meets performance targets
- 🟠 **Orange**: Below performance targets

## Metrics Structure

### VirtualListPerformanceMetrics

```dart
class VirtualListPerformanceMetrics {
  final int initialRenderTimeMs;        // First render time
  final int currentMemoryUsageBytes;    // Memory consumption
  final double averageFPS;              // Average FPS
  final double jankyFramePercentage;    // Janky frames %
  final int totalFrames;                // Total frames
  final int jankyFrames;                // Janky frame count
  final DateTime timestamp;             // Capture time
}
```

### ScrollPerformanceDetails

```dart
class ScrollPerformanceDetails {
  final int scrollDurationMs;           // Scroll duration
  final double pixelsScrolled;          // Distance scrolled
  final double averageVelocity;         // Average px/s
  final double peakVelocity;            // Peak px/s
  final int totalFrames;                // Frames during scroll
  final int jankyFrames;                // Janky frames
  final double averageFPS;              // Average FPS
  final double jankyFramePercentage;    // Janky %
  final DateTime timestamp;             // Capture time
}
```

## Integration with Existing Screens

### Updating TripItemsScreen

```dart
// In lib/features/travel/presentation/screens/trip_items_screen.dart

class TripItemsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trips')),
      body: VirtualListPerformanceTracker(
        itemName: 'Trip Items',
        showOverlay: kDebugMode,
        child: tripsAsync.when(
          data: (trips) => VirtualListView<Trip>(
            itemCount: trips.length,
            isLoading: tripsAsync.isLoading,
            hasError: tripsAsync.hasError,
            itemBuilder: (context, index) => TripListItem(trip: trips[index]),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => const Center(child: Text('Error loading')),
        ),
      ),
    );
  }
}
```

### Updating PhotoGalleryScreen

> **Note (2026-07-17):** `PhotoGalleryScreen` was **deleted** in Story 0.7 — it was unwired scaffold over a phantom `photos` table (see `docs/reports/phantom-schema-refs-2026-07-16.md`). The example below is retained as an **illustration of the API only**; the class no longer exists. The real media path is `media_items` + the journal (FOUNDATIONS §7).


```dart
// In lib/features/travel/presentation/screens/photo_gallery_screen.dart

class PhotoGalleryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(photosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Photos')),
      body: VirtualListPerformanceTracker(
        itemName: 'Photo Gallery',
        showOverlay: kDebugMode,
        child: ScrollPerformanceTrackerWidget(
          onScrollComplete: (details) {
            // Log scroll performance for optimization
          },
          child: photosAsync.when(
            data: (photos) => VirtualGridView<Photo>(
              itemCount: photos.length,
              crossAxisCount: _calculateCrossAxisCount(context),
              itemBuilder: (context, index) => PhotoGridItem(photo: photos[index]),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Center(child: Text('Error loading')),
          ),
        ),
      ),
    );
  }
}
```

## Best Practices

### 1. Only Track in Debug Mode

```dart
VirtualListPerformanceTracker(
  enabled: kDebugMode, // Automatic by default
  child: VirtualListView<Trip>(...),
)
```

### 2. Use Descriptive Item Names

```dart
VirtualListPerformanceTracker(
  itemName: 'Trip Items - Main Screen', // Be specific
  child: VirtualListView<Trip>(...),
)
```

### 3. Log Critical Metrics

```dart
VirtualListPerformanceTracker(
  onMetricsUpdated: (metrics) {
    if (!metrics.meetsTargets()) {
      // Log performance issues
      logger.warning(
        'Performance issues detected: ${metrics.getFailedTargets()}',
      );
    }
  },
  child: VirtualListView<Trip>(...),
)
```

### 4. Combine with Analytics

```dart
VirtualListPerformanceTracker(
  onMetricsUpdated: (metrics) {
    // Sample metrics (e.g., 1% of users) for production monitoring
    if (Random().nextDouble() < 0.01) {
      Analytics.logPerformance(
        screenName: 'trip_items',
        fps: metrics.averageFPS,
        renderTime: metrics.initialRenderTimeMs,
        memory: metrics.currentMemoryUsageBytes,
      );
    }
  },
  child: VirtualListView<Trip>(...),
)
```

### 5. Set Appropriate Scroll Tracking Thresholds

```dart
ScrollPerformanceTrackerWidget(
  minScrollDurationMs: 500,  // Ignore quick flicks
  maxIdleTimeMs: 100,        // Detect scroll end quickly
  child: VirtualListView<Trip>(...),
)
```

## Troubleshooting

### Overlay Not Showing

**Problem**: Performance overlay doesn't appear despite `showOverlay: true`

**Solutions**:
- Ensure you're in debug mode (`kDebugMode == true`)
- Check that metrics are being captured (add debug print in `onMetricsUpdated`)
- Verify the widget is not obscured by other floating widgets

### Inconsistent FPS Readings

**Problem**: FPS values vary significantly between measurements

**Solutions**:
- FPS is calculated over a rolling window; variations are normal
- Use longer scroll durations for more accurate readings
- Consider the device capabilities (emulator vs physical device)

### High Memory Usage

**Problem**: Memory usage exceeds 150 MB target

**Solutions**:
- Check for image caching issues (use thumbnails in grids)
- Verify item widgets are properly disposing resources
- Consider implementing pagination for very large datasets
- Use `addAutomaticKeepAlives: false` if items don't need state preservation

### Low FPS on Scrolling

**Problem**: FPS drops below 55 during scrolling

**Solutions**:
- Simplify item widget layouts
- Use `const` constructors where possible
- Avoid heavy computations in `itemBuilder`
- Use `itemExtent` for fixed-height items
- Implement placeholder widgets during data loading

## Testing

### Unit Tests

Test performance metrics validation:

```dart
test('Performance metrics validate targets correctly', () {
  final metrics = VirtualListPerformanceMetrics(
    initialRenderTimeMs: 800,
    currentMemoryUsageBytes: 100 * 1024 * 1024,
    averageFPS: 58.0,
    jankyFramePercentage: 8.0,
    totalFrames: 1000,
    jankyFrames: 80,
    timestamp: DateTime.now(),
  );

  expect(metrics.meetsTargets(), true);
});
```

### Integration Tests

Test performance tracking with real data:

```dart
testWidgets('Virtual list tracks performance correctly', (tester) async {
  final items = List.generate(500, (i) => 'Item $i');

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: VirtualListPerformanceTracker(
          onMetricsUpdated: (metrics) {
            expect(metrics.averageFPS, greaterThan(50));
          },
          child: VirtualListView<String>(
            itemCount: items.length,
            itemBuilder: (context, index) => Text(items[index]),
          ),
        ),
      ),
    ),
  );

  // Perform scroll
  await tester.fling(find.text('Item 0'), const Offset(0, -500), 10000);
  await tester.pumpAndSettle();
});
```

## Performance Monitoring Integration

### Integration with PerformanceReporter

The performance tracking system integrates with the existing `PerformanceReporter` utility:

```dart
import 'package:soloadventurer/test/utils/performance/performance_reporter.dart';

VirtualListPerformanceTracker(
  onMetricsUpdated: (metrics) {
    // Convert to PerformanceMetrics for comparison
    final perfMetrics = PerformanceReporter.createMetrics(
      startupTimeMs: 0,
      memoryUsageBytes: metrics.currentMemoryUsageBytes,
      listRenderTimeMs: metrics.initialRenderTimeMs,
      scrollFPS: metrics.averageFPS,
      jankyFramePercentage: metrics.jankyFramePercentage,
    );

    PerformanceReporter.printReport(perfMetrics);
  },
  child: VirtualListView<Trip>(...),
)
```

## Additional Resources

- [Flutter Performance Best Practices](https://flutter.dev/docs/perf/rendering/best-practices)
- [Flutter DevTools](https://flutter.dev/docs/tools/devtools/performance)
- [Performance Profiling Guide](https://flutter.dev/docs/perf/rendering/ui-performance)

## Future Enhancements

Planned features for the performance tracking system:

- [ ] Integration with Firebase Performance Monitoring
- [ ] Historical performance data tracking
- [ ] Automated performance regression detection
- [ ] Performance dashboards in developer menu
- [ ] Network request tracking alongside UI metrics
- [ ] Custom performance threshold configuration per screen
