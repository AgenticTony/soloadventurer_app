# Memory Monitor Service

Real-time memory usage tracking and alerting for Flutter applications.

## Overview

The `MemoryMonitor` service provides comprehensive memory monitoring with:
- **Real-time tracking**: Periodic memory usage snapshots
- **Configurable thresholds**: Warning and critical alert levels
- **Alert callbacks**: Automatic notifications when thresholds are exceeded
- **Statistics tracking**: Average, peak, and lowest memory usage
- **Trend analysis**: Detect memory leaks and usage patterns
- **Stream updates**: Reactive UI integration
- **Production-safe**: Automatically disabled in release mode

## Features

### 1. Real-Time Memory Monitoring

Continuous monitoring with configurable intervals (default: 5 seconds).

```dart
await MemoryMonitor.initialize(
  config: const MemoryMonitorConfig(
    monitoringInterval: Duration(seconds: 5),
  ),
  onAlert: (alert) {
    debugPrint('Alert: ${alert.message}');
  },
);
```

### 2. Memory Thresholds & Alerting

Configurable warning and critical thresholds with automatic alerts.

```dart
await MemoryMonitor.initialize(
  config: const MemoryMonitorConfig(
    warningThresholdBytes: 150 * 1024 * 1024,  // 150 MB
    criticalThresholdBytes: 180 * 1024 * 1024, // 180 MB
  ),
  onAlert: (alert) {
    if (alert.level == MemoryAlertLevel.critical) {
      // Take action: clear caches, release resources, etc.
      ImageCacheConfig.clearMemoryCache();
    }
  },
);
```

### 3. Memory Statistics

Track memory usage patterns over time.

```dart
final stats = await MemoryMonitor.getStatistics();
debugPrint('Current: ${stats.currentUsageMB.toStringAsFixed(2)} MB');
debugPrint('Average: ${stats.averageUsageMB.toStringAsFixed(2)} MB');
debugPrint('Peak: ${stats.peakUsageMB.toStringAsFixed(2)} MB');
debugPrint('Trend: ${stats.trend.name} (${stats.trendPercentage.toStringAsFixed(1)}%)');
```

### 4. Trend Analysis

Detect memory leaks and usage patterns automatically.

```dart
final stats = await MemoryMonitor.getStatistics();
switch (stats.trend) {
  case MemoryTrend.increasing:
    debugPrint('Memory usage is increasing! Possible leak.');
    break;
  case MemoryTrend.decreasing:
    debugPrint('Memory usage is decreasing. Good!');
    break;
  case MemoryTrend.stable:
    debugPrint('Memory usage is stable.');
    break;
}
```

### 5. Stream Updates

Reactive UI integration with real-time memory updates.

```dart
MemoryMonitor.memoryStream.listen((snapshot) {
  debugPrint('Memory: ${snapshot.memoryUsageMB.toStringAsFixed(2)} MB');
});
```

## Device-Specific Configurations

### Low-End Devices

For devices with limited memory (1-2 GB RAM).

```dart
await MemoryMonitor.initialize(
  config: MemoryMonitorConfig.forLowMemoryDevice(),
  onAlert: (alert) {
    debugPrint('Low memory alert: ${alert.message}');
    // Aggressive cache clearing
    await ImageCacheConfig.clearMemoryCache();
  },
);
```

**Settings:**
- Warning threshold: 100 MB
- Critical threshold: 120 MB
- Monitoring interval: 10 seconds
- Max history: 50 snapshots

### High-End Devices

For devices with ample memory (6+ GB RAM).

```dart
await MemoryMonitor.initialize(
  config: MemoryMonitorConfig.forHighMemoryDevice(),
  onAlert: (alert) {
    debugPrint('Memory alert: ${alert.message}');
    // Standard cache clearing
    await ImageCacheConfig.clearMemoryCache();
  },
);
```

**Settings:**
- Warning threshold: 250 MB
- Critical threshold: 300 MB
- Monitoring interval: 3 seconds
- Max history: 200 snapshots

## Memory Alert Levels

### Normal

Memory usage is within acceptable range.
- No action needed
- Below warning threshold

### Warning

Memory usage is approaching limit.
- Current usage ≥ Warning threshold (150 MB default)
- Consider clearing non-essential caches
- Monitor for memory leaks

### Critical

Memory usage is critical and needs immediate attention.
- Current usage ≥ Critical threshold (180 MB default)
- Clear all caches immediately
- Release unused resources
- Consider logging out users or reducing data

## API Reference

### Classes

#### `MemoryMonitor`

Main memory monitoring service.

**Static Methods:**

- `Future<void> initialize({MemoryMonitorConfig? config, required void Function(MemoryAlert) onAlert})` - Initialize the monitor
- `Future<int> getCurrentUsage()` - Get current memory usage in bytes
- `Future<MemoryStatistics> getStatistics()` - Get memory statistics
- `List<MemorySnapshot> getHistory()` - Get memory snapshot history
- `void clearHistory()` - Clear memory history
- `Future<void> updateConfig(MemoryMonitorConfig config)` - Update configuration
- `MemoryAlertLevel getCurrentAlertLevel()` - Get current alert level
- `bool isAtWarningLevel()` - Check if at warning level
- `bool isAtCriticalLevel()` - Check if at critical level
- `Future<void> dispose()` - Stop monitoring and cleanup

**Static Properties:**

- `MemoryMonitor instance` - Get singleton instance
- `bool isInitialized` - Check if initialized
- `Stream<MemorySnapshot> memoryStream` - Stream of memory snapshots

#### `MemoryMonitorConfig`

Configuration for memory monitoring.

**Properties:**

- `int warningThresholdBytes` - Warning threshold (default: 150 MB)
- `int criticalThresholdBytes` - Critical threshold (default: 180 MB)
- `Duration monitoringInterval` - Monitoring interval (default: 5 seconds)
- `int maxHistorySize` - Max history size (default: 100)
- `bool enabled` - Enable monitoring (default: true)
- `bool enableTrendAnalysis` - Enable trend analysis (default: true)
- `double trendAnalysisThreshold` - Trend threshold (default: 0.1 = 10%)

**Computed Properties:**

- `double warningThresholdMB` - Warning threshold in MB
- `double criticalThresholdMB` - Critical threshold in MB

**Factory Constructors:**

- `MemoryMonitorConfig.forLowMemoryDevice()` - Low-end device config
- `MemoryMonitorConfig.forHighMemoryDevice()` - High-end device config

**Methods:**

- `MemoryMonitorConfig copyWith({...})` - Copy with modified values

#### `MemorySnapshot`

Memory usage captured at a point in time.

**Properties:**

- `int memoryUsageBytes` - Memory usage in bytes
- `DateTime timestamp` - Timestamp of snapshot

**Computed Properties:**

- `double memoryUsageMB` - Memory usage in MB

**Methods:**

- `Map<String, dynamic> toJson()` - Convert to JSON
- `factory MemorySnapshot.fromJson(Map<String, dynamic>)` - Create from JSON

#### `MemoryAlert`

Memory alert event.

**Properties:**

- `MemoryAlertLevel level` - Alert level (warning/critical)
- `int currentUsageBytes` - Current usage in bytes
- `int thresholdBytes` - Threshold that triggered alert
- `DateTime timestamp` - Alert timestamp
- `String message` - Alert message

**Computed Properties:**

- `double currentUsageMB` - Current usage in MB
- `double thresholdMB` - Threshold in MB

**Methods:**

- `Map<String, dynamic> toJson()` - Convert to JSON

#### `MemoryStatistics`

Memory usage statistics over time.

**Properties:**

- `int currentUsageBytes` - Current usage
- `int averageUsageBytes` - Average usage
- `int peakUsageBytes` - Peak usage
- `int lowestUsageBytes` - Lowest usage
- `int snapshotCount` - Number of snapshots
- `DateTime startTime` - First snapshot time
- `DateTime endTime` - Last snapshot time
- `MemoryTrend trend` - Memory trend
- `double trendPercentage` - Trend percentage change

**Computed Properties:**

- `double currentUsageMB` - Current usage in MB
- `double averageUsageMB` - Average usage in MB
- `double peakUsageMB` - Peak usage in MB
- `double lowestUsageMB` - Lowest usage in MB
- `Duration monitoringDuration` - Monitoring duration

**Methods:**

- `Map<String, dynamic> toJson()` - Convert to JSON

### Enums

#### `MemoryAlertLevel`

- `normal` - Within acceptable range
- `warning` - Approaching limit
- `critical` - Needs immediate attention

#### `MemoryTrend`

- `increasing` - Memory usage is increasing
- `decreasing` - Memory usage is decreasing
- `stable` - Memory usage is stable (< 10% change)

## Usage Examples

### Example 1: Basic Memory Monitoring

```dart
import 'package:soloadventurer/core/services/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize memory monitor
  await MemoryMonitor.initialize(
    config: const MemoryMonitorConfig(),
    onAlert: (alert) {
      debugPrint('🚨 ${alert.level.name}: ${alert.message}');

      // Clear caches on critical alert
      if (alert.level == MemoryAlertLevel.critical) {
        ImageCacheConfig.clearMemoryCache();
      }
    },
  );

  runApp(MyApp());
}
```

### Example 2: Display Memory Usage in UI

```dart
class MemoryUsageWidget extends StatefulWidget {
  @override
  _MemoryUsageWidgetState createState() => _MemoryUsageWidgetState();
}

class _MemoryUsageWidgetState extends State<MemoryUsageWidget> {
  MemoryStatistics? _stats;
  StreamSubscription<MemorySnapshot>? _subscription;

  @override
  void initState() {
    super.initState();

    // Listen to memory updates
    _subscription = MemoryMonitor.memoryStream.listen((snapshot) {
      setState(() {
        _stats = MemoryMonitor.getStatistics() as MemoryStatistics?;
      });
    });

    // Get initial statistics
    MemoryMonitor.getStatistics().then((stats) {
      setState(() {
        _stats = stats;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_stats == null) {
      return CircularProgressIndicator();
    }

    final stats = _stats!;
    final alertLevel = MemoryMonitor.getCurrentAlertLevel();
    final color = alertLevel == MemoryAlertLevel.critical
        ? Colors.red
        : alertLevel == MemoryAlertLevel.warning
            ? Colors.orange
            : Colors.green;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Memory Usage',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: stats.currentUsageBytes / (200 * 1024 * 1024),
              color: color,
            ),
            SizedBox(height: 8),
            Text('Current: ${stats.currentUsageMB.toStringAsFixed(1)} MB'),
            Text('Average: ${stats.averageUsageMB.toStringAsFixed(1)} MB'),
            Text('Peak: ${stats.peakUsageMB.toStringAsFixed(1)} MB'),
            SizedBox(height: 8),
            Text('Trend: ${stats.trend.name}',
                style: TextStyle(
                  color: stats.trend == MemoryTrend.increasing
                      ? Colors.red
                      : Colors.green,
                )),
          ],
        ),
      ),
    );
  }
}
```

### Example 3: Memory-Leak Detection

```dart
class MemoryLeakDetector {
  Timer? _leakCheckTimer;

  void startLeakDetection() {
    _leakCheckTimer = Timer.periodic(Duration(minutes: 5), (_) async {
      final stats = await MemoryMonitor.getStatistics();

      if (stats.trend == MemoryTrend.increasing &&
          stats.trendPercentage > 20) {
        debugPrint('⚠️ Possible memory leak detected!');
        debugPrint('Memory increased by ${stats.trendPercentage.toStringAsFixed(1)}%');
        debugPrint('Current: ${stats.currentUsageMB.toStringAsFixed(2)} MB');
        debugPrint('Peak: ${stats.peakUsageMB.toStringAsFixed(2)} MB');

        // Log memory history for debugging
        final history = MemoryMonitor.getHistory();
        for (final snapshot in history) {
          debugPrint('  ${snapshot.timestamp.toIso8601String()}: ${snapshot.memoryUsageMB.toStringAsFixed(2)} MB');
        }
      }
    });
  }

  void stopLeakDetection() {
    _leakCheckTimer?.cancel();
  }
}
```

### Example 4: Automatic Cache Management

```dart
class AutomaticCacheManager {
  static void setupAutoCacheManagement() {
    MemoryMonitor.memoryStream.listen((snapshot) async {
      final alertLevel = MemoryMonitor.getCurrentAlertLevel();

      if (alertLevel == MemoryAlertLevel.warning) {
        // Warning: Clear image cache
        await ImageCacheConfig.clearMemoryCache();
        debugPrint('Cleared image cache (warning level)');
      } else if (alertLevel == MemoryAlertLevel.critical) {
        // Critical: Clear all caches
        await ImageCacheConfig.clearAllCaches();
        debugPrint('Cleared all caches (critical level)');

        // Notify user
        _showMemoryWarningDialog();
      }
    });
  }

  static void _showMemoryWarningDialog() {
    // Show dialog to user
    debugPrint('Memory is critically low. Please restart the app.');
  }
}
```

### Example 5: Performance Dashboard

```dart
class PerformanceDashboard extends StatefulWidget {
  @override
  _PerformanceDashboardState createState() => _PerformanceDashboardState();
}

class _PerformanceDashboardState extends State<PerformanceDashboard> {
  MemoryStatistics? _stats;
  MemorySnapshot? _current;

  @override
  void initState() {
    super.initState();
    _refreshStats();
    MemoryMonitor.memoryStream.listen((snapshot) {
      setState(() {
        _current = snapshot;
      });
    });
  }

  Future<void> _refreshStats() async {
    final stats = await MemoryMonitor.getStatistics();
    setState(() {
      _stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Performance Dashboard')),
      body: ListView(
        children: [
          if (_stats != null) ...[
            _buildMemoryCard(_stats!),
            _buildTrendCard(_stats!),
            _buildHistoryCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildMemoryCard(MemoryStatistics stats) {
    final alertLevel = MemoryMonitor.getCurrentAlertLevel();
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Memory Usage',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            _buildMemoryRow('Current', stats.currentUsageMB, Colors.blue),
            _buildMemoryRow('Average', stats.averageUsageMB, Colors.green),
            _buildMemoryRow('Peak', stats.peakUsageMB, Colors.orange),
            _buildMemoryRow('Lowest', stats.lowestUsageMB, Colors.grey),
            SizedBox(height: 16),
            Text('Alert Level: ${alertLevel.name.toUpperCase()}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendCard(MemoryStatistics stats) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Memory Trend',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            Text('Direction: ${stats.trend.name}'),
            Text('Change: ${stats.trendPercentage.toStringAsFixed(1)}%'),
            Text('Duration: ${stats.monitoringDuration.inMinutes} minutes'),
            Text('Snapshots: ${stats.snapshotCount}'),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard() {
    final history = MemoryMonitor.getHistory();
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Memory History (Last 10)',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            ...history.reversed.take(10).map((snapshot) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                    '${snapshot.timestamp.toIso8601String()}: ${snapshot.memoryUsageMB.toStringAsFixed(2)} MB'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryRow(String label, double valueMB, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color)),
          Text('${valueMB.toStringAsFixed(2)} MB',
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
```

## Performance Considerations

### Monitoring Interval

- **Default**: 5 seconds - Good balance between accuracy and performance
- **More frequent (3s)**: Better accuracy, slightly higher CPU usage
- **Less frequent (10s)**: Lower CPU usage, less accurate trends

### History Size

- **Default**: 100 snapshots - Good for trend analysis
- **More (200)**: Better long-term trends, higher memory usage
- **Less (50)**: Lower memory usage, less accurate trends

### Memory Overhead

The monitor adds approximately **1-2 MB** of memory overhead:
- History snapshots: ~1 MB (100 snapshots × 10 KB each)
- Stream controller: ~100 KB
- Timer and listeners: ~100 KB

## Best Practices

### 1. Initialize Early

Initialize the monitor in `main()` before `runApp()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MemoryMonitor.initialize(
    config: MemoryMonitorConfig(),
    onAlert: (alert) => _handleAlert(alert),
  );

  runApp(MyApp());
}
```

### 2. Set Appropriate Thresholds

Choose thresholds based on your app's memory needs:

```dart
// For simple apps
MemoryMonitorConfig(
  warningThresholdBytes: 120 * 1024 * 1024,   // 120 MB
  criticalThresholdBytes: 150 * 1024 * 1024,  // 150 MB
)

// For complex apps with many features
MemoryMonitorConfig(
  warningThresholdBytes: 200 * 1024 * 1024,   // 200 MB
  criticalThresholdBytes: 250 * 1024 * 1024,  // 250 MB
)
```

### 3. Handle Alerts Proactively

Clear caches and release resources before hitting critical limits:

```dart
void handleAlert(MemoryAlert alert) {
  if (alert.level == MemoryAlertLevel.warning) {
    // Clear non-essential caches
    ThumbnailService.clearCache();
  } else if (alert.level == MemoryAlertLevel.critical) {
    // Clear all caches
    await ImageCacheConfig.clearAllCaches();

    // Release unused resources
    _releaseUnusedResources();

    // Optionally, notify user
    _showMemoryWarning();
  }
}
```

### 4. Monitor Trends

Use trend analysis to detect memory leaks early:

```dart
final stats = await MemoryMonitor.getStatistics();
if (stats.trend == MemoryTrend.increasing &&
    stats.trendPercentage > 20) {
  debugPrint('⚠️ Possible memory leak!');
  // Investigate and fix memory leaks
}
```

### 5. Clean Up on Dispose

Always dispose the monitor when done:

```dart
@override
void dispose() {
  MemoryMonitor.dispose();
  super.dispose();
}
```

## Troubleshooting

### Monitor Not Capturing Memory

**Issue**: Memory values are always 0 or estimated.

**Solutions:**
1. Ensure you're running in debug mode
2. Check that VM service is available
3. Verify initialization completed successfully

```dart
try {
  await MemoryMonitor.initialize(
    config: MemoryMonitorConfig(),
    onAlert: (alert) => debugPrint(alert.message),
  );
  debugPrint('Monitor initialized successfully');
} catch (e) {
  debugPrint('Failed to initialize monitor: $e');
}
```

### High CPU Usage

**Issue**: Monitor is causing high CPU usage.

**Solutions:**
1. Increase monitoring interval
2. Reduce history size
3. Disable trend analysis if not needed

```dart
MemoryMonitorConfig(
  monitoringInterval: Duration(seconds: 10), // Slower monitoring
  maxHistorySize: 50,                        // Less history
  enableTrendAnalysis: false,                 // Disable trends
)
```

### Memory Leak in Monitor

**Issue**: Monitor itself is leaking memory.

**Solutions:**
1. Reduce `maxHistorySize`
2. Call `clearHistory()` periodically
3. Dispose monitor when not in use

```dart
// Clear history every hour
Timer.periodic(Duration(hours: 1), (_) {
  MemoryMonitor.clearHistory();
});
```

## Integration with Other Services

### ImageCacheConfig

Clear image caches on memory alerts:

```dart
MemoryMonitor.memoryStream.listen((snapshot) async {
  if (MemoryMonitor.isAtCriticalLevel()) {
    await ImageCacheConfig.clearAllCaches();
  }
});
```

### PerformanceReporter

Combine with performance metrics:

```dart
final memory = await MemoryMonitor.getCurrentUsage();
final metrics = PerformanceReporter.createMetrics(
  startupTimeMs: startupTime,
  memoryUsageBytes: memory,
  listRenderTimeMs: renderTime,
  scrollFPS: fps,
  jankyFramePercentage: jankyPercent,
);
```

## Testing

```dart
void main() {
  test('Memory monitor captures snapshots', () async {
    await MemoryMonitor.initialize(
      config: const MemoryMonitorConfig(
        monitoringInterval: Duration(seconds: 1),
      ),
      onAlert: (alert) {},
    );

    // Wait for a few snapshots
    await Future.delayed(Duration(seconds: 3));

    final history = MemoryMonitor.getHistory();
    expect(history.isNotEmpty, true);

    await MemoryMonitor.dispose();
  });

  test('Memory monitor triggers alerts', () async {
    MemoryAlert? lastAlert;

    await MemoryMonitor.initialize(
      config: const MemoryMonitorConfig(
        warningThresholdBytes: 1, // Very low for testing
      ),
      onAlert: (alert) {
        lastAlert = alert;
      },
    );

    // Wait for alert
    await Future.delayed(Duration(seconds: 2));

    expect(lastAlert, isNotNull);
    expect(lastAlert!.level, MemoryAlertLevel.warning);

    await MemoryMonitor.dispose();
  });
}
```

## Future Enhancements

- [ ] Add memory usage breakdown by category (images, UI, data, etc.)
- [ ] Export memory history to CSV for analysis
- [ ] Integrate with Firebase Performance Monitoring
- [ ] Add memory usage predictions based on trends
- [ ] Support for custom alert actions
- [ ] Memory usage heat map visualization
