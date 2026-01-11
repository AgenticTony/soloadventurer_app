# Manual Work Required

**Generated:** Sat Jan 10 23:01:59 CET 2026
**Script:** safe_error_reduction.sh
**Estimated Remaining Manual Work:** 2-3 hours

---

## Summary

The automation script has completed the safe phases. The following tasks
require manual intervention because they are context-dependent or need
human judgment.

---

## Tasks by Phase

### Phase 4

#### Update test imports

Add 'import "package:soloadventurer/test/utils/performance/performance_test_utils.dart";' to test files that need these utilities

---

### Phase 5b

#### Update VerticalSpacing imports

Add 'import "package:soloadventurer/core/widgets/spacing.dart";' to files using VerticalSpacing/HorizontalSpacing. Run: grep -rln "VerticalSpacing" lib/

---

### Phase 5c

#### Fix LatLngBounds imports

Add correct import for LatLngBounds (google_maps_flutter or latlong2). Run: grep -rln "LatLngBounds" lib/

---

### Phase 6

#### Fix repository type casting

Replace 'as int?' with 'JsonHelpers.parseInt()' in repository files. JsonHelpers created at lib/core/utils/json_helpers.dart

---


## Standard Cleanup Tasks

### Run dart fix

After completing manual fixes, run:

```bash
dart fix --dry-run  # Preview
dart fix --apply    # Apply fixes
```

### Format Code

```bash
dart format lib/ test/
```

### Regenerate Code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Final Verification

```bash
flutter analyze 2>&1 | tee final_analysis.txt
tail -20 final_analysis.txt
```

---

## Files Created by Script

- `examples/analysis_options.yaml`
- `examples/README.md`
- `test/utils/performance/performance_test_utils.dart`
- `test/utils/performance/performance_test_data_generator.dart`
- `test/utils/performance/photo_data_generator.dart`
- `test/utils/performance/performance_reporter.dart`
- `lib/core/widgets/spacing.dart`
- `lib/core/core.dart`
- `lib/core/utils/json_helpers.dart`

---

## Files Modified by Script

