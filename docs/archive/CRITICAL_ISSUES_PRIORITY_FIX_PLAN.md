# Critical Issues Priority Fix Plan

**Date:** 2026-01-06
**Status:** 🔴 **BLOCKING ALL BUILDS**
**Priority:** CRITICAL - Must be completed before any feature work

---

## Executive Summary

This plan addresses the **critical build blockers** identified in `LIB_FOLDER_ANALYSIS.md` that prevent the app from building and running. These issues must be resolved **before** any 2026 modernization work can proceed.

### Severity Breakdown

| Severity | Count | Status | Impact |
|----------|-------|--------|--------|
| **P0 - Blocking Build** | 3 | 🔴 Critical | App cannot build at all |
| **P1 - Runtime Crash** | 2 | ⚠️ High | App builds but crashes on launch |
| **P2 - Type Conflicts** | 1 | ⚠️ High | Partial compilation failures |

---

## P0 CRITICAL - Blocking All Builds

### Issue 1: Build Runner Circular Dependency in test/utils/test_data.dart

**Severity:** P0 - BLOCKING ALL BUILDS
**Error:**
```
E mockito:mockBuilder on test/utils/test_data.dart:
  Bad state: Cannot recurse at later or equal phase 8, already running at: [0]
```

**Impact:**
- ❌ Cannot generate ANY `.g.dart` files
- ❌ Cannot generate ANY `.freezed.dart` files
- ❌ Blocks all Riverpod code generation
- ❌ Blocks all Freezed code generation

**Root Cause:** Mockito builder conflict with other builders in test data factory.

**Fix Options:**

**Option A: Remove Mockito from test_data.dart (Recommended - Quick Fix)**
1. Remove `@GenerateMocks` annotations from `test/utils/test_data.dart`
2. Move mock generation to separate test files that actually use mocks
3. Run `dart run build_runner build --delete-conflicting-outputs`

**Option B: Split Test Data (More Comprehensive)**
1. Create `test/mocks/mock_classes.dart` for all mock generation
2. Keep `test/utils/test_data.dart` as simple factory methods only
3. Update imports across test files

**Estimated Time:** 30-60 minutes

**Files Affected:**
- `test/utils/test_data.dart`
- All test files importing from test_data.dart

**Success Criteria:**
- ✅ `dart run build_runner build` completes without errors
- ✅ All `.g.dart` files generated
- ✅ All `.freezed.dart` files generated

---

### Issue 2: lib/core/error/failures.dart Build Runner Failure

**Severity:** P0 - BLOCKING ALL BUILDS
**Status:** ✅ **ALREADY FIXED** (Quick win from LIB_FOLDER_ANALYSIS.md)

**What Was Fixed:**
Replaced Freezed pattern with simple sealed classes to avoid circular dependency.

**Current State:**
```dart
/// Simple Failure classes (replacing freezed due to build_runner circular dependency issue)
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  final dynamic error;
  const ServerFailure({required String message, this.statusCode, this.error}) : super(message);
}

// ... (other Failure types)
```

**Note:** This is a temporary fix. Once build_runner is unblocked, can re-evaluate using Freezed.

---

### Issue 3: Undefined Providers (Missing .g.dart Files)

**Severity:** P0 - BLOCKING ALL BUILDS
**Errors:**
```
error • Undefined name 'syncSettingsNotifierProvider' • lib/app/app_lifecycle_sync_manager.dart
error • Undefined name 'connectivityNotifierProvider' • lib/app/app_lifecycle_sync_manager.dart
error • Undefined name 'syncStatusNotifierProvider' • lib/app/app_lifecycle_sync_manager.dart
error • Undefined name 'tokenManagerProvider' • lib/app/bootstrap.dart:64:26
```

**Root Cause:** Missing `.g.dart` files because build_runner is blocked by Issue #1.

**Fix:** Automatically resolved once Issue #1 is fixed and build_runner runs successfully.

**Files Affected:**
- `lib/app/app_lifecycle_sync_manager.dart`
- `lib/app/bootstrap.dart`
- All files using `@riverpod` annotations (providers without generated .g.dart)

**Estimated Time:** 0 minutes (automatic after Issue #1 fix)

---

## P1 HIGH - Runtime Crashes

### Issue 4: AuthSession.accessToken Property Missing

**Severity:** P1 - RUNTIME CRASH
**Error:**
```
error • The getter 'accessToken' isn't defined for the type 'AuthSession'
```
**Location:** `lib/core/api/interceptors/auth_interceptor.dart:54`

**Current Code:**
```dart
// Line 51-54
final session = await authRepository.refreshToken();
// Get new token from session
final newToken = session.accessToken;  // ❌ Property may not exist
```

**Root Cause:** `AuthSession` freezed class structure has changed or hasn't been regenerated.

**Fix Required:**
1. Check `AuthSession` definition in `lib/features/auth/domain/models/auth_session.dart`
2. Verify correct property name (may be `tokens.accessToken` or similar)
3. Update interceptor to use correct property path
4. Re-run build_runner to regenerate if needed

**Investigation Needed:**
```dart
// Need to verify AuthSession structure - possible patterns:
// Pattern A: session.accessToken
// Pattern B: session.tokens.accessToken
// Pattern C: session.idToken (if accessToken doesn't exist)
```

**Estimated Time:** 30 minutes

**Files Affected:**
- `lib/core/api/interceptors/auth_interceptor.dart` (line 54)
- `lib/features/auth/domain/models/auth_session.dart` (may need update)

**Success Criteria:**
- ✅ Code compiles without error
- ✅ Token refresh flow works correctly
- ✅ No runtime crashes on 401 errors

---

### Issue 5: ProviderLogger API Mismatch (Riverpod 2.x → 3.x)

**Severity:** P1 - RUNTIME WARNINGS/MAYBE CRASH
**Error:**
```
error • The type 'ProviderLogger' must be 'base', 'final' or 'sealed'
error • 'ProviderLogger.didUpdateProvider' isn't a valid override of 'ProviderObserver.didUpdateProvider'
error • Undefined class 'ProviderBase'
```

**Location:** `lib/app/bootstrap.dart:84-87`

**Root Cause:** Using Riverpod 2.x API pattern with Riverpod 3.x codebase.

**Current Code (Likely):**
```dart
class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,  // ❌ Old Riverpod 2.x API
    Object? previousValue,
    Object? newValue,
  ) {
    // ...
  }
}
```

**Required Fix (Riverpod 3.x):**
```dart
final class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext<Object?> context,  // ✅ Riverpod 3.x API
    Object? previousValue,
    Object? newValue,
  ) {
    // Access provider via context.provider if needed
    final provider = context.provider;
    // ... logging implementation
  }
}
```

**Estimated Time:** 15 minutes

**Files Affected:**
- `lib/app/bootstrap.dart` (lines 84-87)

**Success Criteria:**
- ✅ No compilation errors
- ✅ Provider observation works correctly
- ✅ No runtime warnings in debug console

---

## P2 HIGH - Type Conflicts

### Issue 6: Duplicate ConnectivityService Classes

**Severity:** P2 - TYPE CONFLICTS
**Error:**
```
error • The argument type 'ConnectivityService (from features/core/domain/services/...)'
can't be assigned to the parameter type 'ConnectivityService (from features/offline/domain/services/...)'
```

**Root Cause:** Two different `ConnectivityService` classes in different packages with the same name.

**Files Affected:**
- `lib/features/core/domain/services/connectivity_service.dart`
- `lib/features/offline/domain/services/connectivity_service.dart`

**Fix Options:**

**Option A: Rename One (Recommended)**
- Rename `features/offline/domain/services/connectivity_service.dart` to `offline_connectivity_service.dart`
- Update all imports and references

**Option B: Create Shared Interface**
- Create abstract `ConnectivityService` interface in core
- Have both implementations implement it
- More complex but cleaner architecture

**Estimated Time:** 1-2 hours

**Impact:** Multiple provider files need updates

**Success Criteria:**
- ✅ No type conflict errors
- ✅ All providers compile correctly

---

## MEDIUM Priority Issues (Fix After P0-P2)

### Issue 7: Missing or Incorrect Imports

**Severity:** MEDIUM
**Errors:**
```
error • Target of URI doesn't exist: 'package:soloadventurer/core/infrastructure/api/dio_api_service.dart'
error • Target of URI doesn't exist: 'package:soloadventurer/features/travel/infrastructure/repositories/itinerary_repository_impl.dart'
error • Unused import: 'package:path_provider/path_provider.dart'
```

**Files Affected:**
- `lib/app/di/modules/travel_module.dart`
- `lib/app/di/modules/core_module.dart`
- `lib/app/di/modules/offline_module.dart`

**Fix Required:**
1. Remove unused imports
2. Fix incorrect import paths
3. Ensure all referenced files exist

**Estimated Time:** 1 hour

---

## Execution Plan

### Phase 1: Unblock Build Runner (30-60 minutes)

**Goal:** Get build_runner working so all code generation can complete.

1. **Fix test/utils/test_data.dart circular dependency** (Issue #1)
   - Choose Option A or B
   - Run `dart run build_runner build --delete-conflicting-outputs`
   - Verify all `.g.dart` files generated

2. **Verify failures.dart fix is working** (Issue #2)
   - Already fixed, just verify build_runner completes

3. **Check for undefined providers** (Issue #3)
   - Should be auto-resolved after build_runner runs
   - Fix any remaining issues manually

**Exit Criteria:**
- ✅ `dart run build_runner build` completes successfully
- ✅ All `.g.dart` files exist
- ✅ `flutter analyze` shows no "Undefined name" errors for providers

---

### Phase 2: Fix Runtime Crashes (45 minutes)

**Goal:** Fix issues that will crash the app at runtime.

1. **Fix AuthSession.accessToken** (Issue #4)
   - Investigate AuthSession structure
   - Update auth_interceptor.dart
   - Test token refresh flow

2. **Update ProviderLogger to Riverpod 3.x** (Issue #5)
   - Update API signature
   - Verify provider observation works

**Exit Criteria:**
- ✅ No compilation errors
- ✅ App launches without crashing
- ✅ Provider logging works in debug mode

---

### Phase 3: Fix Type Conflicts (1-2 hours)

**Goal:** Resolve type system conflicts.

1. **Fix duplicate ConnectivityService** (Issue #6)
   - Choose Option A or B
   - Rename or refactor
   - Update all references

2. **Fix missing/incorrect imports** (Issue #7)
   - Clean up DI modules
   - Remove unused imports

**Exit Criteria:**
- ✅ `flutter analyze` shows no type conflict errors
- ✅ All imports resolve correctly
- ✅ App compiles cleanly

---

### Phase 4: Validation (30 minutes)

**Goal:** Verify app can build and run.

1. **Run full build:**
   ```bash
   flutter clean
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   flutter analyze
   flutter build apk --debug  # or ios for macOS
   ```

2. **Run app in debug mode:**
   ```bash
   flutter run
   ```

3. **Run tests:**
   ```bash
   flutter test
   ```

**Success Criteria:**
- ✅ App builds successfully
- ✅ App launches without crashing
- ✅ No critical errors in `flutter analyze`
- ✅ Unit tests pass (integration tests can be fixed later)

---

## Priority Order Summary

1. **Issue #1:** test_data.dart circular dependency (P0) - 30-60 min
2. **Issue #3:** Undefined providers (P0) - 0 min (auto-fixed after #1)
3. **Issue #4:** AuthSession.accessToken (P1) - 30 min
4. **Issue #5:** ProviderLogger API (P1) - 15 min
5. **Issue #6:** Duplicate ConnectivityService (P2) - 1-2 hours
6. **Issue #7:** Missing/incorrect imports (Medium) - 1 hour

**Total Estimated Time:** 3-5 hours

---

## Quick Reference Commands

```bash
# Clean build artifacts
flutter clean

# Get dependencies
flutter pub get

# Generate code (after fixing test_data.dart)
dart run build_runner build --delete-conflicting-outputs

# Run static analysis
flutter analyze

# Run unit tests
flutter test

# Run integration tests (skip for now - many failures)
flutter test integration_test/

# Build app
flutter build apk --debug  # Android
flutter build ios --debug  # iOS
flutter build macos --debug  # macOS
```

---

## Next Steps After This Plan

Once these critical issues are resolved, you can proceed with:

1. ✅ **2026 Best Practices Remediation Plan** (`docs/2026_BEST_PRACTICES_REMEDIATION_PLAN.md`)
2. ✅ **Sprint 0:** Riverpod 3.0 features
3. ✅ **Sprint 1-4:** Modernization work

**Current Blocker:** This plan must be completed first.

---

**Plan Created:** 2026-01-06
**Created By:** Claude Code (Critical Issues Analysis)
**Status:** Ready for execution
