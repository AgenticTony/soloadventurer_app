---
description: Fix all critical code issues systematically
---

# Fix Critical Issues

I'll systematically fix all critical code issues in the project.

## Priority Order:

### 1. Fix Drift Schema Index Syntax
File: `lib/features/offline/infrastructure/database/schema.dart`

**Problem:** Old Drift Index API syntax
```dart
// OLD (incorrect)
Index([column1, column2])
```

**Solution:** Update to new API
```dart
// NEW (correct)
Index(columns: [column1, column2])
```

### 2. Fix Undefined Types in Tests
File: `test/utils/test_data.dart`

**Problem:** Missing domain types like `TravelStyle`, `AccommodationType`

**Solution:**
- Run `dart fix --apply` to add missing imports
- Create missing domain type definitions
- Update test utilities

### 3. Fix Integration Test Errors
**Problem:** Missing parameters, undefined functions

**Solution:**
- Update test helpers to match current API
- Fix parameter mismatches
- Remove deprecated test code

### 4. Apply All Automatic Fixes
```bash
dart fix --apply
dart format .
flutter pub get
```

### 5. Verify Fixes
```bash
flutter analyze
flutter test
```

## Executing...

Starting with critical fixes now.
