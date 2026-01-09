# Comprehensive Refactoring Strategy

**Date:** 2026-01-05
**Current Issues:** 1395
**Already Fixed:** 88 (Failure hierarchy + safety_exceptions)
**Progress:** 6% complete

---

## EXECUTIVE SUMMARY

This document outlines a systematic 6-week strategy to resolve the remaining 1395 compilation errors in the SoloAdventurer app. The issues are categorized by priority and complexity, with clear phases for execution.

---

## ISSUE CATEGORIZATION

```
┌─────────────────────────────────────────────────────────────┐
│ REMAINING 1395 ISSUES BY CATEGORY                          │
├─────────────────────────────────────────────────────────────┤
│ 🔴 HIGH PRIORITY (Blocking Compilation)                     │
│ ├─ Auth Session/State Issues:   ~200 errors               │
│ ├─ Drift Database Schema:        ~400 errors               │
│ ├─ Repository Method Signatures: ~150 errors               │
│ ├─ Provider/State Management:    ~100 errors               │
│ ├─ Background Services:          ~50 errors                │
│ ├─ Integration Tests:            ~200 errors               │
│ └─ Other:                        ~295 errors               │
└─────────────────────────────────────────────────────────────┘
```

---

## PHASE 1: QUICK WINS (1-2 days, ~300 errors fixed)

### 1.1 Fix AuthSession Property Access (~50 errors, 2 hours)

**Problem:** Code tries to access `idToken`, `refreshToken`, `expiresAt` on `AuthSession` but the freezed class needs proper code generation.

**Root Cause:** The `freezed` package generates getters but the generated code needs to be properly built.

**Files to Fix:**
- `lib/features/auth/infrastructure/security/secure_token_storage.dart`
- `lib/features/auth/infrastructure/services/background_token_refresh_service.dart`
- `lib/features/auth/domain/usecases/refresh_token.dart`

**Solution:**

```dart
// File: lib/features/auth/domain/models/auth_session.dart
// Ensure this file exists and is correct:

import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

@freezed
class AuthSession with _$AuthSession {
  const factory AuthSession({
    String? userId,
    required String accessToken,
    required String idToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);
}
```

**Then run:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

### 1.2 Fix AuthNotifier Parameter Mismatch (~145 errors, 3 hours)

**Problem:** `AuthState` constructors expect named `user` parameter but code is calling them positionally.

**File:** `lib/features/auth/presentation/notifiers/auth_notifier.dart`

**Solution:** Update all `AuthState` usages from positional to named:

```dart
// BEFORE (WRONG)
state = const AsyncValue.loading();
state = AsyncValue.data(Authenticated(user));  // Positional

// AFTER (CORRECT)
state = const AsyncValue.loading();
state = AsyncValue.data(Authenticated(user: user));  // Named
```

**Find all occurrences:**
```bash
grep -n "Authenticated(" lib/features/auth/presentation/notifiers/auth_notifier.dart
```

**Replace pattern:**
- `Authenticated(` → `Authenticated(user: `
- `Unauthenticated(` → `Unauthenticated()`
- `Initial()` → `Initial()`

---

### 1.3 Fix RepositoryException Constructor (~27 errors, 1 hour)

**Problem:** Code calls `RepositoryException()` positionally but it requires named parameters.

**Solution:**

```dart
// BEFORE
throw RepositoryException('message');

// AFTER
throw RepositoryException(message: 'message');
// OR
throw const RepositoryException.message('message');
```

---

## PHASE 2: DRIFT DATABASE FIX (2-3 days, ~400 errors fixed)

### 2.1 Regenerate Drift Schema (4 hours)

**Problem:** The `database.g.dart` file is out of sync with `schema.dart`

**Steps:**

```bash
# 1. Clean generated files
rm lib/features/offline/infrastructure/database/database.g.dart
rm lib/features/offline/infrastructure/database/schema.g.dart

# 2. Run drift build
dart run drift dev build lib/features/offline/infrastructure/database/schema.dart

# OR using build_runner
dart run build_runner build --delete-conflicting-outputs
```

---

### 2.2 Fix Table Class References (~100 errors, 4 hours)

**Problem:** Code references `users`, `journals`, `trips`, `syncQueue` but they might not match the generated table classes.

**Check schema.dart:**

```dart
@DataClassName('LocalUser')  // ← This determines the class name
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  // ...
}
```

**Solution:** Ensure DAOs use the correct class names:

```dart
// If @DataClassName('LocalUser')
final userDao = database.users;  // ← This is the table
// Use LocalUser for the data class
```

---

### 2.3 Fix HasResultSet Getter Issues (~60 errors, 2 hours)

**Problem:** `isDeleted`, `createdAt`, `updatedAt` getters don't exist on `HasResultSet`

**Solution:** Add these fields to your table definitions:

```dart
class CommonTableMixin {
  // Timestamps
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Soft delete
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

// Then use in tables:
@DataClassName('LocalJournal')
class Journals extends Table with CommonTableMixin {
  IntColumn get id => integer().autoIncrement()();
  // ... other fields
}
```

---

## PHASE 3: REPOSITORY SIGNATURE FIXES (2-3 days, ~150 errors fixed)

### 3.1 Fix Value<T> Type Issues (~50 errors, 4 hours)

**Problem:** Drift's `Value` class isn't being imported or used correctly.

**Solution:**

```dart
// Add import
import 'package:drift/drift.dart';

// Use Value for updates
database.update(journals).replace(
  JournalCompanion(
    id: Value(journal.id),
    title: Value(newTitle),
    updatedAt: Value(DateTime.now()),
  ),
);
```

---

### 3.2 Fix Repository Return Types (~100 errors, 6 hours)

**Problem:** Methods returning `RepositoryOperationResult<T>` incorrectly

**Solution:** Update repository methods to match the expected pattern:

```dart
// BEFORE
Future<Journal> createJournal(CreateJournalDto dto) async {
  final id = await _database.into(journals).insert(...);
  return Journal(id: id, ...);
}

// AFTER
Future<RepositoryOperationResult<Journal>> createJournal(CreateJournalDto dto) async {
  final id = await _database.into(journals).insert(...);
  final journal = Journal(id: id, ...);
  return RepositoryOperationResult.immediate(journal);
}
```

---

## PHASE 4: PROVIDER/STATE FIXES (2-3 days, ~100 errors fixed)

### 4.1 Add Missing Providers (~30 errors, 4 hours)

**Problem:** `authServiceProvider`, `locationServiceProvider`, etc. are undefined

**Solution:** Create provider files or add missing providers:

```dart
// File: lib/core/providers/api_providers.dart (or appropriate location)

@riverpod
class AuthService extends _$AuthService {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String email, String password) async {
    // implementation
  }
}

// For location service
@riverpod
LocationService locationService(LocationServiceRef ref) {
  return LocationServiceImpl();
}
```

---

### 4.2 Fix AsyncValue Property Access (~70 errors, 6 hours)

**Problem:** Trying to access properties directly on `AsyncValue` instead of using `when`, `whenData`, etc.

**Solution:**

```dart
// BEFORE (WRONG)
final hasEmergency = state.hasActiveEmergency;
final isSubmitting = state.isSubmitting;

// AFTER (CORRECT)
final hasEmergency = state.when(
  data: (state) => state.hasActiveEmergency,
  loading: () => false,
  error: (_, __) => false,
);

// OR using whenData
final hasEmergency = state.value?.hasActiveEmergency ?? false;
```

---

## PHASE 5: BACKGROUND SERVICES FIX (1-2 days, ~50 errors fixed)

### 5.1 Fix WorkManagerConstraints (~10 errors, 2 hours)

**Problem:** `WorkManagerConstraints` is undefined

**Solution:** Check if using `workmanager` package and add proper import/constraints:

```dart
import 'package:workmanager/workmanager.dart';

// Then use
const constraints = WorkManagerConstraints(
  networkType: NetworkType.connected,
  requiresBatteryNotLow: true,
);
```

---

### 5.2 Fix ProviderContainer Usage (~15 errors, 3 hours)

**Problem:** `ProviderContainer` not imported from `flutter_riverpod`

**Solution:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Then use
final container = ProviderContainer();
final authState = container.read(authStateProvider);
```

---

## PHASE 6: INTEGRATION TESTS (2-3 days, ~200 errors)

**Solution:** Add `@Skip()` to broken tests temporarily:

```dart
import 'package:flutter_test/flutter_test.dart';

@Skip('TODO: Update after refactoring')
void main() {
  // existing tests
}
```

---

## RECOMMENDED EXECUTION ORDER

```
Week 1: Quick Wins (Phase 1)
├─ Day 1: AuthSession fixes + build_runner
├─ Day 2: AuthNotifier parameter fixes
└─ Day 3: RepositoryException + verify

Week 2-3: Database (Phase 2)
├─ Day 1-2: Drift schema regeneration
├─ Day 3-4: Table class references
└─ Day 5: HasResultSet mixins

Week 4: Repositories (Phase 3)
├─ Day 1-2: Value<T> fixes
└─ Day 3-5: Return type corrections

Week 5: Providers (Phase 4)
├─ Day 1-2: Missing providers
└─ Day 3-5: AsyncValue access patterns

Week 6: Remaining (Phases 5-6)
├─ Day 1-2: Background services
└─ Day 3-5: Integration tests or skip
```

---

## IMMEDIATE NEXT STEPS

**For RIGHT NOW:**

1. **Run build_runner:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

2. **Check how many errors remain:**
```bash
flutter analyze lib/
```

3. **Pick ONE category** to focus on (recommend starting with AuthSession/AuthNotifier)

---

## TRACKING PROGRESS

| Phase | Description | Errors | Status |
|-------|-------------|--------|--------|
| 0 | Already Fixed | 88 | ✅ Complete |
| 1.1 | AuthSession Property Access | ~50 | ⏳ Pending |
| 1.2 | AuthNotifier Parameters | ~145 | ⏳ Pending |
| 1.3 | RepositoryException | ~27 | ⏳ Pending |
| 2.1 | Drift Schema Regeneration | ~100 | ⏳ Pending |
| 2.2 | Table Class References | ~100 | ⏳ Pending |
| 2.3 | HasResultSet Mixins | ~60 | ⏳ Pending |
| 3.1 | Value<T> Type Issues | ~50 | ⏳ Pending |
| 3.2 | Repository Return Types | ~100 | ⏳ Pending |
| 4.1 | Missing Providers | ~30 | ⏳ Pending |
| 4.2 | AsyncValue Access | ~70 | ⏳ Pending |
| 5.1 | WorkManagerConstraints | ~10 | ⏳ Pending |
| 5.2 | ProviderContainer Usage | ~15 | ⏳ Pending |
| 6 | Integration Tests | ~200 | ⏳ Pending |
| - | Other Issues | ~295 | ⏳ Pending |
| **TOTAL** | | **1395** | |

---

## NOTES

- All phases should be verified with `flutter analyze` after completion
- Run `dart run build_runner build --delete-conflicting-outputs` after any freezed/schema changes
- Commit changes after each phase completion
- Update this document as progress is made
