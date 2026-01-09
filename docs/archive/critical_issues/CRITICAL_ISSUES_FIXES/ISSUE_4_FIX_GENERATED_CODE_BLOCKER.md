# CRITICAL ISSUE #4: Fix Generated Code Blocker

**Severity:** BLOCKING
**Estimated Time:** 2-3 hours
**Dependencies:** Should complete Issue #3 first (safety type mismatches)
**Can be parallelized:** YES (after safety fixes)

---

## Problem Summary

**410 `.g.dart` files** are not being generated due to syntax errors in the codebase, blocking:
- Freezed code generation
- Riverpod provider generation
- JSON serialization generation
- Drift database code generation

### Root Causes

#### 1. Safety Data Layer Type Mismatches (from INCOMPLETE_TASKS.md)
- `lib/features/safety/data/datasources/mock_safety_remote_data_source.dart`
- Methods return wrong types
- Missing required parameters
- Incorrect enum references

#### 2. Invalid Dependency in Worktree 008
- `pubspec.yaml` references `exif: ^0.3.0` which doesn't exist
- Blocks build_runner for entire project

---

## Current State

```bash
# If you run build_runner now, you'll see errors:
dart run build_runner build --delete-conflicting-outputs
```

**Expected errors:**
```
error • lib/features/safety/data/datasources/mock_safety_remote_data_source.dart:line:col •
  The expression 'SafetyAlertStatus.active' doesn't match any enum constant
error • lib/features/safety/data/datasources/mock_safety_remote_data_source.dart:line:col •
  The named parameter 'createdAt' is required but not provided
error • Couldn't resolve 'package:exif/exif.dart'
```

---

## Solution Approach

Fix in order:
1. **Fix safety data layer type mismatches** (enables safety feature build)
2. **Fix invalid dependency** (unlocks entire project build)
3. **Run build_runner** (generates all 410 files)

---

## Step-by-Step Fix

### Step 1: Fix Safety Data Layer Type Mismatches

**File:** `lib/features/safety/data/datasources/mock_safety_remote_data_source.dart`

#### Issue A: Wrong Enum Values

Find and replace incorrect enum references:

**Before:**
```dart
status: SafetyAlertStatus.active,  // ← WRONG
```

**After:**
```dart
status: SafetyAlertStatus.sent,  // ← CORRECT
// OR
status: SafetyAlertStatus.acknowledged,  // ← CORRECT
```

**Enum values in `SafetyAlertStatus`:**
- `draft`
- `sent`
- `acknowledged`
- `resolved`

#### Issue B: Missing Required Parameters

Update mock data to include all required fields:

**Before:**
```dart
return SafetyAlert(
  id: 'alert-1',
  type: SafetyAlertType.emergency,
  message: 'Test alert',
  status: SafetyAlertStatus.sent,
  createdAt: DateTime.now(),  // ← WRONG FIELD NAME
);
```

**After:**
```dart
return SafetyAlert(
  id: 'alert-1',
  type: SafetyAlertType.emergency,
  message: 'Test alert',
  status: SafetyAlertStatus.sent,
  createdAt: DateTime.now(),
  acknowledgedByContactIds: [],  // ← ADD MISSING FIELD
  location: const LocationUpdate(  // ← ADD MISSING NESTED OBJECT
    latitude: 0.0,
    longitude: 0.0,
    timestamp: null,
  ),
);
```

#### Issue C: Entity vs Model Usage

Ensure methods return correct entity types:

**Check method signatures:**
```dart
// Should return entities, not models
Future<List<CheckIn>> getCheckIns() async { ... }
Future<List<TrustedContact>> getTrustedContacts() async { ... }
Future<List<SafetyAlert>> getSafetyAlerts() async { ... }
```

#### Complete Fix Example

Here's a corrected mock method:

```dart
// lib/features/safety/data/datasources/mock_safety_remote_data_source.dart

@override
Future<List<SafetyAlert>> getSafetyAlerts() async {
  await Future.delayed(const Duration(milliseconds: 500));

  return [
    SafetyAlert(
      id: 'alert-1',
      type: SafetyAlertType.emergency,
      message: 'Emergency alert - immediate assistance needed',
      status: SafetyAlertStatus.sent,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      acknowledgedByContactIds: ['contact-1'],
      location: const LocationUpdate(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: null,
      ),
    ),
    SafetyAlert(
      id: 'alert-2',
      type: SafetyAlertType.checkInMissed,
      message: 'Missed check-in - are you okay?',
      status: SafetyAlertStatus.acknowledged,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      acknowledgedByContactIds: ['contact-1', 'contact-2'],
      location: const LocationUpdate(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: null,
      ),
    ),
  ];
}
```

### Step 2: Fix Invalid Dependency in Worktree 008

This is in a separate worktree, but affects the main project if dependencies are shared.

**Option A: Fix in Worktree (if you have access)**

**File:** `.worktrees/auto-claude-008-travel-journal-with-media/pubspec.yaml`

**Find:**
```yaml
dependencies:
  exif: ^0.3.0  # ← INVALID
```

**Replace with:**
```yaml
dependencies:
  exif: ^0.5.0  # ← VALID VERSION (check pub.dev for latest)
  # OR use alternative:
  image: ^4.0.0  # Has EXIF support
```

**Option B: Remove Worktree Reference (if not using 008)**

If worktree 008 is not actively being developed:

```bash
# List worktrees
git worktree list

# Remove the worktree
git worktree remove auto-claude-008-travel-journal-with-media
```

### Step 3: Verify Safety Feature Compiles

Before running build_runner, verify the safety feature has no errors:

```bash
# Analyze safety feature specifically
flutter analyze lib/features/safety/

# Should show: "No issues found"
```

If there are still errors, fix them before proceeding.

### Step 4: Run Build Runner

Now generate all the code:

```bash
# Clean first
flutter clean

# Get dependencies
flutter pub get

# Generate code (this will take a few minutes)
dart run build_runner build --delete-conflicting-outputs
```

**Expected output:**
```
[INFO] Generating build script...
[INFO] Generating build script completed, took 1.2s
[INFO] Precompiling build script...
[INFO] Precompiling build script completed, took 3.4s
[INFO] Initializing inputs
[INFO] Building new asset graph...
[INFO] Building new asset graph completed, took 1.1s
[INFO] Checking for unexpected pre-existing outputs....
[INFO] Deleting 410 generated files
[INFO] Generating 410 files...
[INFO] Generating completed, took 45.2s
```

**Common Issues:**

| Error | Solution |
|-------|----------|
| "Could not resolve some dependencies" | Run `flutter pub get` again |
| "Conflicting outputs" | Already using `--delete-conflicting-outputs` flag |
| "Type mismatch" | Still has type errors - fix first |
| "Stack overflow" | Reduce number of concurrent jobs: `dart run build_runner build --delete-conflicting-outputs -j 1` |

### Step 5: Verify Generated Files

Check that files were generated:

```bash
# Count generated files
find lib -name "*.g.dart" | wc -l
find lib -name "*.freezed.dart" | wc -l

# Should show similar numbers to:
# .g.dart: ~410 files
# .freezed.dart: ~161 files
```

### Step 6: Run Full Analysis

```bash
flutter analyze
```

**Expected:** "No issues found!"

### Step 7: Run Tests

```bash
flutter test
```

**Expected:** All tests pass (or only test failures, no compilation errors)

---

## Files to Fix

### Primary Files:

1. ✅ **`lib/features/safety/data/datasources/mock_safety_remote_data_source.dart`**
   - Fix enum values
   - Add missing required parameters
   - Correct field names

2. ⚠️ **`.worktrees/auto-claude-008-travel-journal-with-media/pubspec.yaml`** (if exists)
   - Fix or remove invalid `exif` dependency

### May Need Fixes (check these too):

3. ⚠️ `lib/features/safety/data/datasources/safety_local_data_source_impl.dart`
4. ⚠️ `lib/features/safety/data/datasources/safety_remote_data_source_impl.dart`
5. ⚠️ `lib/features/safety/data/repositories/safety_repository_impl.dart`

---

## Safety Data Layer - Specific Fixes

### Fix Checklist for `mock_safety_remote_data_source.dart`

Search for these patterns and fix:

| Find | Replace With |
|------|--------------|
| `SafetyAlertStatus.active` | `SafetyAlertStatus.sent` or `SafetyAlertStatus.acknowledged` |
| `timestamp: ` (in LocationUpdate) | Remove or verify correct usage |
| Missing `acknowledgedByContactIds` | Add `acknowledgedByContactIds: []` |
| Missing `location` in SafetyAlert | Add `location: const LocationUpdate(...)` |

### Entity Field Reference

**SafetyAlert:**
```dart
SafetyAlert({
  required String id,
  required SafetyAlertType type,
  required String message,
  required SafetyAlertStatus status,
  required DateTime createdAt,
  required List<String> acknowledgedByContactIds,  // ← REQUIRED
  LocationUpdate? location,  // ← OPTIONAL but commonly used
})
```

**LocationUpdate:**
```dart
LocationUpdate({
  required double latitude,
  required double longitude,
  DateTime? timestamp,  // ← OPTIONAL (not createdAt)
})
```

**CheckIn:**
```dart
CheckIn({
  required String id,
  required DateTime scheduledTime,
  required DateTime? actualCheckInTime,
  required CheckInStatus status,
  String? note,
})
```

---

## Verification Commands

```bash
# 1. Check for syntax errors
flutter analyze lib/features/safety/

# 2. Count existing generated files (before)
find lib -name "*.g.dart" | wc -l

# 3. Run build_runner
dart run build_runner build --delete-conflicting-outputs

# 4. Count generated files (after)
find lib -name "*.g.dart" | wc -l

# 5. Verify no analyzer errors
flutter analyze

# 6. Run tests
flutter test test/features/safety/

# 7. Build app
flutter build apk --debug
```

---

## Testing Checklist

- [ ] Safety data layer type mismatches fixed
- [ ] Invalid dependency removed or fixed
- [ ] `flutter analyze lib/features/safety/` shows no errors
- [ ] `flutter pub get` succeeds
- [ ] `dart run build_runner build` completes successfully
- [ ] All `.g.dart` files generated (should have ~410)
- [ ] All `.freezed.dart` files generated (should have ~161)
- [ ] `flutter analyze` shows no errors
- [ ] `flutter test` passes
- [ ] App builds successfully

---

## Common Build Runner Errors & Solutions

### Error: "Conflicting outputs"

**Solution:** Already using `--delete-conflicting-outputs` flag, but if it persists:

```bash
# Delete all generated files manually
find lib -name "*.g.dart" -delete
find lib -name "*.freezed.dart" -delete
find .dart_tool -name "*.g.dart" -delete

# Run build_runner again
dart run build_runner build --delete-conflicting-outputs
```

### Error: "Could not find package 'exif'"

**Solution:** Fix worktree 008 dependency or remove worktree

```bash
# Check worktrees
git worktree list

# Remove problematic worktree
git worktree remove auto-claude-008-travel-journal-with-media

# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Error: "Type 'X' is not a subtype of type 'Y'"

**Solution:** Still have type mismatches - check the data sources again

```bash
# Find all type errors
flutter analyze --no-fatal-infos
```

---

## Success Criteria

✅ All syntax errors in safety data layer fixed
✅ Invalid dependency resolved
✅ Build_runner completes successfully
✅ 410+ `.g.dart` files generated
✅ 161+ `.freezed.dart` files generated
✅ `flutter analyze` shows no errors
✅ All tests pass
✅ App builds successfully
✅ Safety feature screens load without errors

---

## Rollback Plan

If build_runner generates invalid code:

```bash
# Delete all generated files
find lib -name "*.g.dart" -delete
find lib -name "*.freezed.dart" -delete

# Revert changes
git checkout HEAD -- lib/features/safety/data/datasources/

# Fix issues incrementally
# Re-run build_runner
```

---

## Post-Generation Steps

After successfully generating code:

### 1. Commit Generated Files

```bash
git add lib/**/*.g.dart
git add lib/**/*.freezed.dart
git commit -m "feat: generate code with build_runner"
```

### 2. Update .gitignore (if needed)

Ensure generated files are tracked (not ignored):

```bash
# .gitignore should NOT have:
# *.g.dart
# *.freezed.dart

# These should be committed to version control
```

### 3. Set Up Watch Mode (optional)

For development:

```bash
# Watch for changes and auto-regenerate
dart run build_runner watch --delete-conflicting-outputs
```

### 4. Update CI/CD (if exists)

Add build_runner step to CI pipeline:

```yaml
# .github/workflows/test.yml
- name: Generate code
  run: dart run build_runner build --delete-conflicting-outputs

- name: Analyze
  run: flutter analyze

- name: Test
  run: flutter test
```

---

## Notes

- This issue **blocks development** - prioritize fixing
- Coordinate with Issue #3 (safety provider architecture)
- Run `flutter analyze` frequently during fixes
- Generated files should be committed to git
- Consider adding pre-commit hook to run build_runner
- Watch mode is useful during active development

---

## Why This Matters

Without generated code:
- ❌ Freezed classes don't work (no copyWith, equality, toString)
- ❌ Riverpod providers don't exist (app won't compile)
- ❌ JSON serialization fails (can't parse API responses)
- ❌ Drift database queries don't work

**Fixing this unlocks the entire codebase.**
