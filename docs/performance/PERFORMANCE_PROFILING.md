# Performance Profiling Guide

**Version:** 1.0.0
**Date:** 2026-01-07
**App:** Solo Adventurer

## Overview

This guide provides comprehensive instructions for profiling the Solo Adventurer app to ensure optimal performance and identify potential issues before production release.

## Performance Benchmarks

Based on Flutter best practices and industry standards for 2026:

| Metric | Target | Acceptable | Critical |
|--------|--------|------------|----------|
| **Startup Time** | < 2s | < 3s | ≥ 3s |
| **Time to Interactive** | < 3s | < 5s | ≥ 5s |
| **Provider Initialization** | < 200ms | < 500ms | ≥ 500ms |
| **Memory Usage** | < 100MB | < 150MB | ≥ 150MB |
| **Frame Rate** | 60 FPS | ≥ 55 FPS | < 50 FPS |
| **Jank** (stutter) | < 1% | < 5% | ≥ 10% |

## Quick Start

### Option 1: Automated Profiling Script

The easiest way to profile your app is using the automated script:

```bash
# Run all performance profiles
dart run scripts/performance_profiling.dart

# Run with verbose output
dart run scripts/performance_profiling.dart --verbose

# Run specific profiles
dart run scripts/performance_profiling.dart --startup
dart run scripts/performance_profiling.dart --memory
dart run scripts/performance_profiling.dart --providers
dart run scripts/performance_profiling.dart --leaks
```

### Option 2: Manual Profiling with Flutter DevTools

For detailed analysis, use Flutter DevTools:

```bash
# 1. Start the app in profile mode
flutter run --profile

# 2. In another terminal, start DevTools
flutter pub global run devtools

# 3. Open DevTools in your browser
# 4. Connect to your app using the observatory URL
```

## Profiling Techniques

### 1. Startup Time Profiling

#### Using the Timeline

1. Run app in profile mode:
   ```bash
   flutter run --profile
   ```

2. Open DevTools Timeline tab

3. Record a timeline session during app startup

4. Analyze the following key events:
   - Framework initialization
   - First frame rasterization
   - Provider setup
   - Route navigation

#### Key Metrics to Track

- **Time to First Frame**: Time until first frame is rendered
- **Time to Interactive**: Time until app is fully interactive
- **Main Thread Jank**: Any frame taking > 16ms

#### Optimization Tips

```dart
// ❌ Bad: Initializing everything at startup
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final heavyService = HeavyService(); // Blocks startup
    return MaterialApp(...);
  }
}

// ✅ Good: Lazy initialization
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(...),
    );
  }
}
```

### 2. Memory Profiling

#### Using DevTools Memory Tab

1. Navigate to Memory tab in DevTools

2. Take a baseline snapshot:
   - Click "Take Snapshot" at app start
   - Navigate through the app
   - Take another snapshot

3. Analyze:
   - Objects that should be GC'd but aren't
   - Memory growth patterns
   - Large memory allocations

#### Common Memory Leak Patterns

```dart
// ❌ Bad: Not disposing controllers
class MyWidget extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    final controller = AnimationController(...);
    // Forgot to dispose!
  }
}

// ✅ Good: Proper disposal
class MyWidget extends StatefulWidget {
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

```dart
// ❌ Bad: Not canceling subscriptions
class MyWidget extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    _streamSubscription = stream.listen(_onData);
    // Forgot to cancel in dispose!
  }
}

// ✅ Good: Cancel in dispose
@override
void dispose() {
  _streamSubscription.cancel();
  super.dispose();
}
```

### 3. Provider Initialization Profiling

#### Measuring Provider Setup

```dart
// Add to bootstrap.dart
void main() async {
  final stopwatch = Stopwatch()..start();

  WidgetsFlutterBinding.ensureInitialized();
  print('Bindings: ${stopwatch.elapsedMilliseconds}ms');

  await dotenv.load();
  print('Dotenv: ${stopwatch.elapsedMilliseconds}ms');

  final container = ProviderContainer(...);
  print('Providers: ${stopwatch.elapsedMilliseconds}ms');

  runApp(...);
  stopwatch.stop();
}
```

#### Provider Optimization

```dart
// ❌ Bad: Synchronous heavy initialization
@riverpod
class HeavyService {
  @override
  FutureOr<HeavyService> build() {
    // Heavy computation blocks the thread
    final data = performHeavyComputation();
    return HeavyService(data);
  }
}

// ✅ Good: Async initialization
@riverpod
class HeavyService {
  @override
  Future<HeavyService> build() async {
    // Computation happens asynchronously
    final data = await performHeavyComputationAsync();
    return HeavyService(data);
  }
}
```

### 4. Memory Leak Detection

#### Automated Detection Script

The `performance_profiling.dart` script includes automatic leak detection:

```bash
dart run scripts/performance_profiling.dart --leaks
```

#### Manual Detection with DevTools

1. Take initial memory snapshot
2. Perform action (navigate, login/logout, etc.)
3. Return to previous screen
4. Force garbage collection (DevTools has a button)
5. Take another snapshot
6. Compare - objects should be GC'd

#### Leak Detection Checklist

- [ ] Stream subscriptions are cancelled
- [ ] AnimationControllers are disposed
- [ ] TextEditingControllers are disposed
- [ ] FocusNodes are disposed
- [ ] Timer instances are cancelled
- [ ] ProviderContainer is disposed in tests
- [ ] Isolate cleanup (if using isolates)

## Using Flutter DevTools

### Installation

```bash
# Install DevTools globally
flutter pub global activate devtools

# Verify installation
flutter pub global run devtools --version
```

### Launching DevTools

```bash
# Option 1: Auto-connect to running Flutter app
flutter pub global run devtools

# Option 2: Connect to specific app
flutter pub global run devtools --appSizeMemory
```

### DevTools Features

#### 1. Performance Tab

- **Flutter Frames**: Visualize frame rendering
- **Timeline**: See all events over time
- **Frame Analysis**: Detailed breakdown of slow frames

#### 2. Memory Tab

- **Memory Chart**: Track memory usage over time
- **Snapshot**: Analyze objects in memory
- **Allocation Tracing**: Track object allocations

#### 3. Network Tab

- **Request Logging**: See all network requests
- **Timing**: Measure API call durations
- **Payload Analysis**: Check request/response sizes

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Performance Test

on: [pull_request]

jobs:
  performance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2

      - name: Run Performance Profiler
        run: dart run scripts/performance_profiling.dart

      - name: Upload Results
        uses: actions/upload-artifact@v3
        with:
          name: performance-report
          path: performance_report_*.json
```

## Performance Optimization Checklist

### App-Level Optimizations

- [ ] Enable `--release` mode for production builds
- [ ] Use `const` constructors where possible
- [ ] Implement lazy loading for images
- [ ] Use `ListView.builder` instead of `ListView`
- [ ] Implement image caching
- [ ] Use `AutomaticKeepAliveClientMixin` judiciously
- [ ] Optimize asset bundles
- [ ] Enable code shrinking (R8/ProGuard)

### Provider Optimizations

- [ ] Use `keepAlive: true` only when necessary
- [ ] Lazy load providers with `FutureProvider`/`StreamProvider`
- [ ] Avoid unnecessary provider watches
- [ ] Use `select` to watch specific values
- [ ] Dispose providers properly

### Widget Optimizations

- [ ] Extract widgets to reduce rebuilds
- [ ] Use `RepaintBoundary` for expensive paints
- [ ] Implement `shouldRebuild` in custom widgets
- [ ] Avoid opacity animations (use `AnimatedOpacity`)
- [ ] Use `Builder` widget to get optimized context

### Network Optimizations

- [ ] Implement request caching
- [ ] Use connection pooling
- [ ] Compress request/response bodies
- [ ] Implement request batching
- [ ] Use pagination for large datasets

## Troubleshooting

### Common Performance Issues

#### Issue: Slow App Startup

**Symptoms**: App takes > 3 seconds to launch

**Solutions**:
1. Profile with Timeline to find bottlenecks
2. Move heavy initialization to background
3. Use lazy loading for providers
4. Defer non-critical initialization

#### Issue: High Memory Usage

**Symptoms**: App uses > 150MB memory

**Solutions**:
1. Check for memory leaks with DevTools
2. Optimize image loading and caching
3. Clear unused caches
4. Dispose unused controllers and listeners

#### Issue: Janky Scrolling

**Symptoms**: Scuttering during scroll

**Solutions**:
1. Use `ListView.builder` instead of `ListView`
2. Implement item extent caching
3. Use `RepaintBoundary` for complex items
4. Avoid expensive operations in `build()`

#### Issue: Slow Provider Initialization

**Symptoms**: Providers take > 500ms to initialize

**Solutions**:
1. Use async initialization with `FutureProvider`
2. Implement provider lazy loading
3. Reduce dependencies between providers
4. Cache expensive computations

## Resources

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter DevTools Documentation](https://docs.flutter.dev/tools/devtools/overview)
- [Flutter Performance Profiling](https://docs.flutter.dev/perf/rendering/best-practices)
- [Dart Observatory Documentation](https://dart.dev/tools/dart-observatory)
- [Riverpod Performance Guide](https://riverpod.dev/docs/concepts/performance)

## Support

For performance-related questions or issues:
1. Check this guide first
2. Review generated performance reports
3. Consult Flutter DevTools
4. Refer to official Flutter documentation
