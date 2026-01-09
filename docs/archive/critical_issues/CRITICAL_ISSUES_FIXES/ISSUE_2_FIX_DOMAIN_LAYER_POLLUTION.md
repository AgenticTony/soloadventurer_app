# CRITICAL ISSUE #2: Fix Domain Layer Pollution

**Severity:** HIGH
**Estimated Time:** 2-3 hours
**Dependencies:** None
**Can be parallelized:** YES

---

## Problem Summary

`TokenManager` is located in the domain layer but imports infrastructure components, violating Clean Architecture dependency rules:

```dart
// lib/features/auth/domain/services/token_manager.dart
import '../../../core/data/services/connectivity_service_impl.dart';  // ← VIOLATION
import '../../infrastructure/logging/token_audit_logger.dart';         // ← VIOLATION
```

**Why This Matters:**
- Domain layer should have ZERO dependencies on outer layers
- Reduces testability (can't unit test without infrastructure)
- Creates circular dependencies
- Violates the fundamental rule of Clean Architecture

---

## Solution Approach

Move `TokenManager` from `domain/services/` to `infrastructure/services/`

**Before:**
```
lib/features/auth/
├── domain/
│   └── services/
│       └── token_manager.dart  ← WRONG LOCATION
└── infrastructure/
    └── services/
        └── (other services)
```

**After:**
```
lib/features/auth/
├── domain/
│   └── services/
│       └── (domain-only services)
└── infrastructure/
    └── services/
        └── token_manager.dart  ← CORRECT LOCATION
```

---

## Step-by-Step Fix

### Step 1: Create New File in Correct Location

**Create:** `lib/features/auth/infrastructure/services/token_manager.dart`

**Copy the entire contents** from:
`lib/features/auth/domain/services/token_manager.dart`

To the new location.

### Step 2: Update Package Imports

In the new file, update imports to reflect the new location:

**Before:**
```dart
import '../models/auth_session.dart';
import '../../data/providers/auth_data_providers.dart';
import '../../../core/domain/services/connectivity_service.dart';
import '../../../core/data/services/connectivity_service_impl.dart';
import '../services/token_blacklist_manager.dart';
import '../../infrastructure/logging/token_audit_logger.dart';
import '../../infrastructure/security/secure_token_storage.dart';
```

**After:**
```dart
import '../../../domain/models/auth_session.dart';
import '../../../data/providers/auth_data_providers.dart';
import '../../../../core/domain/services/connectivity_service.dart';
import '../../../../core/data/services/connectivity_service_impl.dart';
import '../../../domain/services/token_blacklist_manager.dart';
import '../logging/token_audit_logger.dart';
import '../security/secure_token_storage.dart';
```

### Step 3: Move Provider Definition

If there's a `token_manager_provider.dart` file in the domain layer, move it to infrastructure:

**From:** `lib/features/auth/domain/services/token_manager.dart` (bottom of file with @riverpod)
**To:** `lib/features/auth/infrastructure/providers/token_manager_provider.dart`

Create a new provider file:
```dart
// lib/features/auth/infrastructure/providers/token_manager_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/token_manager.dart';

part 'token_manager_provider.g.dart';

@riverpod
class TokenManager extends _$TokenManager {
  @override
  FeatureAvailability build() {
    // Implementation moved from TokenManager class
    final tokenManager = TokenManager(
      // dependencies
    );
    return tokenManager.state;
  }
}
```

### Step 4: Update All References

Find all files that import TokenManager:

```bash
# Find all imports
grep -r "features/auth/domain/services/token_manager" lib/
grep -r "token_manager.dart" lib/
```

**Update imports in these files:**

**Old import:**
```dart
import 'package:soloadventurer/features/auth/domain/services/token_manager.dart';
```

**New import:**
```dart
import 'package:soloadventurer/features/auth/infrastructure/services/token_manager.dart';
```

**Likely files to update:**
- `lib/features/auth/presentation/providers/auth_providers.dart`
- `lib/features/auth/presentation/providers/token_manager_provider.dart`
- `lib/features/auth/presentation/widgets/silent_token_refresh_handler.dart`
- Any files using `TokenManager` directly

### Step 5: Update Tests

Move tests from:
`test/features/auth/domain/services/token_manager_test.dart`

To:
`test/features/auth/infrastructure/services/token_manager_test.dart`

Update imports in the test file to match new location.

### Step 6: Delete Old File

**Delete:** `lib/features/auth/domain/services/token_manager.dart`

### Step 7: Update Documentation

Update any references in documentation files:

```bash
# Check docs for references
grep -r "TokenManager" docs/
```

Update:
- `docs/AUTH_ARCHITECTURE.md`
- `docs/INCOMPLETE_TASKS.md`
- Any other docs mentioning TokenManager location

---

## Verification Steps

### 1. Run Analyzer
```bash
flutter analyze
```

**Expected:** No errors related to TokenManager imports

### 2. Run Tests
```bash
flutter test test/features/auth/
```

**Expected:** All auth tests pass

### 3. Build Project
```bash
flutter clean
flutter pub get
flutter build apk --debug  # or ios for macOS
```

**Expected:** Build succeeds without errors

### 4. Check for Circular Dependencies
```bash
# Run dependency check
flutter pub deps
```

**Expected:** No circular dependency warnings

---

## Files to Modify

### Move/Rename:
1. `lib/features/auth/domain/services/token_manager.dart`
   → `lib/features/auth/infrastructure/services/token_manager.dart`

2. `test/features/auth/domain/services/token_manager_test.dart`
   → `test/features/auth/infrastructure/services/token_manager_test.dart`

### Update Imports In:
1. `lib/features/auth/presentation/providers/auth_providers.dart`
2. `lib/features/auth/presentation/providers/token_manager_provider.dart`
3. `lib/features/auth/presentation/providers/token_notifier.dart`
4. `lib/features/auth/presentation/widgets/silent_token_refresh_handler.dart`
5. `lib/features/auth/presentation/widgets/token_expired_dialog.dart`
6. `lib/features/auth/infrastructure/services/session_manager.dart`
7. `lib/app/di/modules/auth_module.dart` (if referenced)

---

## Testing Checklist

- [ ] New file created in infrastructure layer
- [ ] All imports updated to new location
- [ ] Old file deleted from domain layer
- [ ] All references updated (grep shows no old imports)
- [ ] Tests moved to infrastructure test folder
- [ ] Test imports updated
- [ ] `flutter analyze` passes
- [ ] `flutter test test/features/auth/` passes
- [ ] App builds successfully
- [ ] Token refresh functionality still works
- [ ] No circular dependencies

---

## Alternative Approach (If Moving is Too Complex)

If moving the file causes too many issues, create a **domain interface**:

### Option B: Create Domain Interface

**1. Create Interface in Domain Layer**
```dart
// lib/features/auth/domain/services/token_manager_interface.dart
abstract class TokenManagerInterface {
  Future<void> initialize();
  Future<void> refreshToken();
  Future<void> clearSession();
  bool get hasValidTokens;
  // ... other public methods
}
```

**2. Make TokenManager Implement Interface**
```dart
// lib/features/auth/infrastructure/services/token_manager.dart
class TokenManager implements TokenManagerInterface {
  // ... existing implementation
}
```

**3. Update Domain Layer to Use Interface**
```dart
// In domain use cases, depend on interface
final TokenManagerInterface _tokenManager;
```

This keeps the file in infrastructure but allows domain layer to reference it through the interface.

---

## Rollback Plan

If something breaks:
1. Restore the file to original location
2. Revert all import changes
3. Identify specific issues and fix incrementally

```bash
# Git commands for rollback
git checkout -- lib/features/auth/domain/services/token_manager.dart
git checkout -- test/features/auth/domain/services/
```

---

## Success Criteria

✅ TokenManager is in infrastructure layer
✅ No imports from domain layer to infrastructure
✅ All tests pass
✅ No analyzer errors
✅ App builds and runs
✅ Token refresh functionality works
✅ Clean architecture dependency rules restored

---

## Why This Fix Is Critical

Clean Architecture depends on the **Dependency Rule**:

> "Dependencies can only point inward."

**Outer layers** (infrastructure, data, presentation) can depend on **inner layers** (domain).
**Inner layers** (domain) CANNOT depend on **outer layers** (infrastructure).

When domain layer imports infrastructure:
- ❌ Breaks the architecture's core principle
- ❌ Makes domain code untestable without infrastructure
- ❌ Creates tight coupling
- ❌ Makes the codebase fragile to changes

**Fixing this restores architectural integrity.**

---

## Notes

- This is a **refactoring** - functionality should not change
- Focus on updating imports correctly
- Run tests frequently during the process
- Coordinate with team working on other issues
- Update any architecture diagrams or documentation
