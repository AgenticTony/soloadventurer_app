# Performance Baseline Test Execution Guide

## Quick Start

```bash
# Navigate to project directory
cd /path/to/SoloAdventurer_app

# Run all baseline performance tests
flutter test test/features/travel/performance/baseline_performance_test.dart

# Run with verbose output
flutter test test/features/travel/performance/baseline_performance_test.dart --reporter expanded

# Run in profile mode for more accurate results
flutter test test/features/travel/performance/baseline_performance_test.dart --profile
```

## Test Files Created

1. **PerformanceReporter Utility** (`test/utils/performance/performance_reporter.dart`)
   - Captures memory usage
   - Measures execution time
   - Tracks scroll performance
   - Compares metrics

2. **Baseline Performance Tests** (`test/features/travel/performance/baseline_performance_test.dart`)
   - Memory usage with 500+ items
   - List rendering performance
   - Scroll performance metrics
   - Data generation speed

3. **Documentation** (`test/utils/performance/BASELINE_DOCUMENTATION.md`)
   - Complete usage guide
   - Performance targets
   - Troubleshooting tips

## Expected Test Results

When you run the tests, you should see output similar to:

```
══╡ EXAMPLE TEST OUTPUT ╞══

I/flutter: Memory usage with 500 trips loaded
I/flutter: Initial memory: 45.23 MB
I/flutter: Memory after loading 500 trips: 52.18 MB
I/flutter: Memory delta: 6.95 MB
I/flutter: BASELINE: Memory for 500 trips = 6.95 MB

I/flutter: List rendering performance with 500 items
I/flutter: List render time: 1247ms
I/flutter: BASELINE: List render time for 500 items = 1247ms

I/flutter: Scroll performance with 500 items
I/flutter: Scroll performance:
I/flutter:   Total time: 2341ms
I/flutter:   Janky frames: 2/20
I/flutter:   Janky percentage: 10.0%
I/flutter:   Average FPS: 56.2
I/flutter: BASELINE: Scroll janky frames = 10.0%
I/flutter: BASELINE: Scroll FPS = 56.2

I/flutter: COMPREHENSIVE PERFORMANCE BASELINE
I/flutter: ─────────────────────────────────────────
I/flutter: PERFORMANCE BASELINE SUMMARY:
I/flutter: ────────────────────────────────────────
I/flutter: Dataset Size: 500 trips, 500 photos
I/flutter:
I/flutter: Memory Usage:
I/flutter:   Trip objects: 6.95 MB
I/flutter:   Photo metadata: 12.34 MB
I/flutter:   Total: 19.29 MB
I/flutter:
I/flutter: Data Generation Speed:
I/flutter:   Total time: 87ms
I/flutter:   Average per item: 0.09ms
I/flutter:
I/flutter: Targets:
I/flutter:   ✓ Memory < 200 MB: PASS
I/flutter:   ✓ Generation < 200ms: PASS
I/flutter: ══════════════════════════════════════════

All tests passed!
```

## Recording Baseline Results

After running tests, record the key metrics in the table below:

### Baseline Metrics (Phase 1 - Before Optimization)

| Test | Metric | Baseline Value | Target | Status |
|------|--------|----------------|--------|--------|
| **Memory - 500 Trips** | Usage | ___ MB | < 200 MB | ⏳ |
| **Memory - 500 Photos** | Usage | ___ MB | < 200 MB | ⏳ |
| **Memory - Total** | Usage | ___ MB | < 200 MB | ⏳ |
| **List Render** | Time (500 items) | ___ ms | < 3000 ms | ⏳ |
| **List Render (Complex)** | Time (500 items) | ___ ms | < 5000 ms | ⏳ |
| **Scroll** | FPS | ___ | ≥ 55 | ⏳ |
| **Scroll** | Janky Frames | ___ % | < 10% | ⏳ |
| **Data Generation** | Time (500+500) | ___ ms | < 200 ms | ⏳ |
| **Memory Stress** | 1000 trips | ___ MB | < 100 MB | ⏳ |

### Test Environment Details

- **Date:** ___
- **Flutter Version:** ___
- **Dart Version:** ___
- **Test Device:** ___
- **OS Version:** ___
- **Mode:** [ ] Debug [ ] Profile [ ] Release

## Post-Test Checklist

- [ ] All tests pass
- [ ] Baseline metrics recorded above
- [ ] Results documented in build-progress.txt
- [ ] Any anomalies or failures noted
- [ ] implementation_plan.json updated with completed status

## Common Issues & Solutions

### Issue: "VM service protocol not available"
**Solution:**
```bash
flutter test --enable-vm-service test/features/travel/performance/baseline_performance_test.dart
```

### Issue: Tests timeout
**Solution:**
```bash
flutter test --timeout=120s test/features/travel/performance/baseline_performance_test.dart
```

### Issue: Inconsistent results between runs
**Solution:**
- Close other apps to free up memory
- Run in profile mode: `flutter test --profile`
- Run 3-5 times and take the average

### Issue: Memory usage shows 0
**Solution:**
- Ensure VM service is enabled
- Try running in profile mode
- Check if test environment supports memory profiling

## Next Steps After Test Execution

1. **Document Results:** Copy the console output to a file
2. **Update build-progress.txt:** Add baseline metrics section
3. **Update implementation_plan.json:** Mark subtask-2 as completed
4. **Commit Changes:**
   ```bash
   git add .
   git commit -m "auto-claude: phase-1-subtask-2 - Measure current app performance with large datasets"
   ```

## Integration with CI/CD

To add to your CI pipeline:

```yaml
# .github/workflows/performance-baseline.yml
name: Performance Baseline Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  performance-baseline:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Run baseline tests
        run: |
          flutter test test/features/travel/performance/baseline_performance_test.dart \
            --reporter expanded \
            | tee baseline-results.txt

      - name: Upload results
        uses: actions/upload-artifact@v3
        with:
          name: baseline-results
          path: baseline-results.txt

      - name: Comment PR with results
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const results = fs.readFileSync('baseline-results.txt', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## Performance Baseline Results\n\n\`\`\`\n${results}\n\`\`\``
            });
```

## Performance Monitoring Over Time

### Setting Up Baseline Tracking

1. **Create baseline history file:**
   ```bash
   mkdir -p test/results
   echo "Date,StartupTime,MemoryUsage,ListRender,ScrollFPS,JankyPercent" > test/results/baseline_history.csv
   ```

2. **After each test run, append results:**
   ```bash
   ./scripts/record_baseline.sh
   ```

3. **Generate trend report:**
   ```bash
   ./scripts/generate_trend_report.sh
   ```

### Example Baseline History CSV

```csv
Date,StartupTime,MemoryUsage,ListRender,ScrollFPS,JankyPercent
2024-01-04T10:00:00Z,0,19.29,1247,56.2,10.0
2024-01-05T14:30:00Z,0,18.50,1150,58.5,8.5
2024-01-10T09:15:00Z,0,17.20,980,60.1,5.2
```

## Advanced Profiling

### Using Flutter DevTools

For deeper analysis, use Flutter DevTools:

1. Run app in profile mode:
   ```bash
   flutter run --profile
   ```

2. Open DevTools:
   ```bash
   flutter devtools
   ```

3. Connect to your app session

4. Record performance traces:
   - **Memory:** Track heap growth over time
   - **Performance:** Identify slow frames
   - **Network:** Check API call times

### Automated Profiling Script

```bash
#!/bin/bash
# profile_baseline.sh

echo "Starting profiling session..."

# Start app with profiling
flutter run --profile --dart-define=PROFILING=true &
APP_PID=$!

# Wait for app to initialize
sleep 5

# Collect baseline metrics
curl http://localhost:8080/metrics > baseline_metrics.json

# Trigger performance test scenario
# ... your test commands here ...

# Collect post-test metrics
curl http://localhost:8080/metrics > post_test_metrics.json

# Cleanup
kill $APP_PID

echo "Profiling complete. Results saved to *.json files"
```

## Contact & Support

For questions or issues with the baseline tests:
- Check: `test/utils/performance/BASELINE_DOCUMENTATION.md`
- Review: `test/features/travel/performance/baseline_performance_test.dart`
- File issues in the project tracker

---

**Last Updated:** 2024-01-04
**Spec:** 006-performance-optimization-for-large-trips
**Phase:** 1 - Setup & Infrastructure
**Subtask:** 2 - Establish Performance Baseline
