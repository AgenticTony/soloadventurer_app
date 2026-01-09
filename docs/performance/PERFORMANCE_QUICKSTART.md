# Performance Profiling Quick Start

**Solo Adventurer App - Task 4.8**

## Prerequisites

Ensure you have the following installed:
- Flutter SDK 3.x
- Dart SDK 3.x
- DevTools (`flutter pub global activate devtools`)
- Android Studio/Xcode (for device/emulator)

## Quick Profile (5 Minutes)

### Step 1: Run Automated Script

```bash
# Navigate to project root
cd SoloAdventurer_app

# Run all performance profiles
dart run scripts/performance_profiling.dart
```

This will:
- ✅ Profile startup time
- ✅ Profile memory usage
- ✅ Profile provider initialization
- ✅ Check for memory leaks
- ✅ Generate JSON report

### Step 2: Review Results

The script will output results to console and save a JSON report:

```bash
performance_report_2026-01-07-12-30-45.json
```

Look for:
- ✅ PASS: All metrics within acceptable range
- ❌ FAIL: Metrics exceed thresholds
- ⚠️ WARNING: Approaching thresholds

## Detailed Profiling (15-30 Minutes)

### 1. Startup Time Profiling with Timeline

```bash
# Start app in profile mode
flutter run --profile

# Open DevTools in another terminal
flutter pub global run devtools

# In DevTools:
# 1. Go to "Performance" tab
# 2. Click "Record"
# 3. Force restart the app (hot restart won't work)
# 4. Navigate through app once loaded
# 5. Stop recording
# 6. Analyze the timeline
```

**Key Metrics:**
- Time to first frame: Target < 2000ms
- Time to interactive: Target < 5000ms
- Main thread jank: < 5% of frames

### 2. Memory Profiling with DevTools

```bash
# Start app in profile mode
flutter run --profile

# Open DevTools
flutter pub global run devtools

# In DevTools:
# 1. Go to "Memory" tab
# 2. Take initial snapshot
# 3. Navigate through app features
# 4. Take another snapshot
# 5. Compare snapshots for leaks
```

**Key Metrics:**
- Initial heap: Target < 80MB
- Steady state: Target < 120MB
- Peak usage: Target < 150MB

### 3. Provider Initialization Profiling

The enhanced `AppStartTracker` now logs detailed phase information:

```bash
# Run the app and check console
flutter run --debug

# Look for performance report:
# ═════════════════════════════════════════
# 📊 App Startup Performance Report
# ═════════════════════════════════════════
# ✅ Total Startup Time: 1850ms
#
# 📋 Phase Breakdown:
#   ✅ framework_init: 250ms (13.5%)
#   ✅ error_handling_init: 10ms (0.5%)
#   ✅ storage_init: 150ms (8.1%)
#   ✅ supabase_init: 200ms (10.8%)
#   ✅ provider_init: 500ms (27.0%)
# ═════════════════════════════════════════
```

**Key Metrics:**
- Each phase: Target < 500ms
- Total startup: Target < 3000ms

### 4. Memory Leak Detection

```bash
# Run automated leak detection
dart run scripts/performance_profiling.dart --leaks

# Or manually with DevTools:
# 1. Open Memory tab
# 2. Take snapshot
# 3. Perform action (login, navigate, etc.)
# 4. Return to previous screen
# 5. Force GC (button in DevTools)
# 6. Take another snapshot
# 7. Look for objects that should be GC'd
```

**Common Leaks:**
- Unclosed Stream subscriptions
- Undisposed AnimationControllers
- Undisposed TextEditingControllers
- Unreleased Provider containers

## Performance Thresholds

| Metric | Pass | Warning | Fail |
|--------|------|---------|------|
| **Startup Time** | < 2s | 2-3s | > 3s |
| **Time to Interactive** | < 3s | 3-5s | > 5s |
| **Provider Init** | < 200ms | 200-500ms | > 500ms |
| **Memory Usage** | < 100MB | 100-150MB | > 150MB |
| **Frame Rate** | ≥ 58 FPS | 55-57 FPS | < 55 FPS |

## Common Issues and Fixes

### Issue: Slow Startup (> 3s)

**Quick Fix:**
```dart
// Remove unnecessary keepAlive providers
@Riverpod(keepAlive: false)  // Instead of true
class MyService { ... }
```

**Investigation:**
1. Check `AppStartTracker` output for slow phases
2. Use DevTools Timeline to find blocking operations
3. Look for synchronous I/O or computations

### Issue: High Memory Usage (> 150MB)

**Quick Fix:**
```dart
// Dispose controllers properly
@override
void dispose() {
  _controller.dispose();
  _subscription.cancel();
  super.dispose();
}
```

**Investigation:**
1. Use DevTools Memory tab
2. Take snapshots at different points
3. Look for growing object counts

### Issue: Janky Scrolling

**Quick Fix:**
```dart
// Use ListView.builder instead of ListView
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

**Investigation:**
1. Enable Performance overlay (in MaterialApp)
2. Use DevTools Flutter Frames view
3. Look for frames taking > 16ms

## Acceptance Criteria Checklist

Before marking Task 4.8 complete, verify:

- [ ] Automated profiling script runs without errors
- [ ] Startup time < 3 seconds on target device
- [ ] Memory usage < 150MB at steady state
- [ ] Provider initialization < 500ms per provider
- [ ] No memory leaks detected in 5-minute test
- [ ] Performance report generated and saved
- [ ] All documentation is up to date

## Device Target

For consistent results, test on:

**Android (Recommended):**
- Pixel 5 or newer
- 4GB+ RAM
- Android 11+

**iOS (Recommended):**
- iPhone 12 or newer
- 4GB+ RAM
- iOS 15+

## Next Steps

1. **Run the automated profiling script**
2. **Review the generated report**
3. **Address any FAIL metrics**
4. **Document baseline measurements**
5. **Set up CI/CD integration**

## Troubleshooting

### Script fails to run

```bash
# Ensure Dart SDK is in path
which dart

# Try running directly
dart scripts/performance_profiling.dart
```

### DevTools won't connect

```bash
# Ensure app is running in profile mode
flutter run --profile

# Look for observatory URL in console output
# Example: http://127.0.0.1:12345/abc123/

# Connect DevTools manually
flutter pub global run devtools --appSizeMemory
```

### Can't see performance logs

```bash
# Ensure running in debug mode
flutter run --debug

# Or enable verbose mode
dart run scripts/performance_profiling.dart --verbose
```

## Resources

- **Full Guide:** `docs/PERFORMANCE_PROFILING.md`
- **Baseline:** `docs/PERFORMANCE_BASELINE.md`
- **Script:** `scripts/performance_profiling.dart`
- **Flutter Docs:** https://docs.flutter.dev/perf
