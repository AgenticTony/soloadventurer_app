# Quick Spec: Fix 6 Syntax Error Files

## Overview

Fix syntax errors in 6 files blocking code generation in Flutter/Dart codebase. The errors are preventing `dart run build_runner` from executing successfully. All fixes are syntax-only (brackets, terminators, commas) with no logic changes required.

## Workflow Type

**Type:** `simple` - Straightforward syntax fixes in existing files

## Task Scope

### Files to Modify

**FILE 1:** lib/features/auth/presentation/screens/signup_screen.dart
- **Line 302:9** - Missing closing `)`, likely extra closing parenthesis on lines 299-301
- Check widget tree structure, remove duplicate closing parentheses

**FILE 2:** lib/features/journal/presentation/screens/create_journal_entry_screen.dart
- **Lines 475:13, 479:6** - Missing closing `)`
- Check Column/Row children structure, add missing parentheses

**FILE 3:** test/features/auth/integration/background_refresh_integration_test.dart
- **Line 298:66** - Missing closing `});` for AuthSession constructor
- Current: `expiresAt: DateTime.now().add(const Duration(minutes: 2)),`
- Fix: `expiresAt: DateTime.now().add(const Duration(minutes: 2)), });`

**FILE 4:** test/features/destination_discovery/domain/models/personalized_recommendation_test.dart
- **Line 226:5** - Missing comma in test parameters or setup
- **Line 245:7** - Missing closing `)` in test assertion or constructor call

**FILE 5:** test/features/sync/infrastructure/services/sync_history_service_impl_test.dart
- **Lines 384-385** - Missing terminators (`;`, `)`, `}`)
- File ends at line 384 with `}` - likely missing test group closure or function closure

**FILE 6:** test/core/providers/riverpod_optimization_test.dart
- **Line 9** - Invalid `@GenerateMocks` annotation (already fixed in file, appears correct)
- Verify annotation syntax is valid

### Change Details

For each file:
1. Navigate to error line
2. Count opening vs closing brackets `()[]{}`
3. Add missing brackets/terminators or remove extras
4. Common patterns:
   - Missing `});` after constructor calls
   - Missing `)` in nested widget trees
   - Missing `,` between parameters
   - Missing `;` at end of statements

## Success Criteria

- ✓ All 6 files pass `dart analyze` with zero "Expected/Unexpected" errors
- ✓ `dart run build_runner build --delete-conflicting-outputs` completes successfully
- ✓ `flutter analyze` shows 0 syntax errors for the modified files
- ✓ No logic changes - only syntax corrections applied

### Verification

```bash
# Fix each file individually
dart analyze <file_path> 2>&1 | grep -E "Expected|Unexpected"

# After all fixes, verify code generation works
dart run build_runner build --delete-conflicting-outputs

# Final check - should show 0 syntax errors
flutter analyze 2>&1 | tail -20
```

Expected result: No "Expected/Unexpected" errors in any of the 6 files.

## Notes

- Errors are blocking `dart run build_runner` - critical path
- All errors are simple syntax issues (brackets, terminators, commas)
- No logic changes required - only syntax corrections
- Work through files sequentially, verify each with `dart analyze`

## Files to Modify

### FILE 1: lib/features/auth/presentation/screens/signup_screen.dart
- **Line 302:9** - Missing closing `)`, likely extra closing parenthesis on lines 299-301
- Check widget tree structure, remove duplicate closing parentheses

### FILE 2: lib/features/journal/presentation/screens/create_journal_entry_screen.dart
- **Lines 475:13, 479:6** - Missing closing `)`
- Check Column/Row children structure, add missing parentheses

### FILE 3: test/features/auth/integration/background_refresh_integration_test.dart
- **Line 298:66** - Missing closing `});` for AuthSession constructor
- Current: `expiresAt: DateTime.now().add(const Duration(minutes: 2)),`
- Fix: `expiresAt: DateTime.now().add(const Duration(minutes: 2)), });`

### FILE 4: test/features/destination_discovery/domain/models/personalized_recommendation_test.dart
- **Line 226:5** - Missing comma in test parameters or setup
- **Line 245:7** - Missing closing `)` in test assertion or constructor call

### FILE 5: test/features/sync/infrastructure/services/sync_history_service_impl_test.dart
- **Lines 384-385** - Missing terminators (`;`, `)`, `}`)
- File ends at line 384 with `}` - likely missing test group closure or function closure

### FILE 6: test/core/providers/riverpod_optimization_test.dart
- **Line 9** - Invalid `@GenerateMocks` annotation (already fixed in file, appears correct)
- Verify annotation syntax is valid

## Change Details

For each file:
1. Navigate to error line
2. Count opening vs closing brackets `()[]{}`
3. Add missing brackets/terminators or remove extras
4. Common patterns:
   - Missing `});` after constructor calls
   - Missing `)` in nested widget trees
   - Missing `,` between parameters
   - Missing `;` at end of statements

## Verification

```bash
# Fix each file individually
dart analyze <file_path> 2>&1 | grep -E "Expected|Unexpected"

# After all fixes, verify code generation works
dart run build_runner build --delete-conflicting-outputs

# Final check - should show 0 syntax errors
flutter analyze 2>&1 | tail -20
```

Expected result: No "Expected/Unexpected" errors in any of the 6 files.

## Notes

- Errors are blocking `dart run build_runner` - critical path
- All errors are simple syntax issues (brackets, terminators, commas)
- No logic changes required - only syntax corrections
- Work through files sequentially, verify each with `dart analyze`
