# CRITICAL ISSUE #1: Fix Duplicate User Models

**Severity:** CRITICAL
**Estimated Time:** 4-6 hours
**Dependencies:** None
**Can be parallelized:** YES

---

## Problem Summary

Two different `User` classes exist with conflicting schemas, causing:
- DRY principle violation
- Type confusion and runtime errors
- No mapping between domain and data models
- Architecture violation (models incorrectly in domain layer)

---

## Current State

### File 1: `lib/features/auth/domain/entities/user.dart` (KEEP THIS ONE)
```dart
class User extends Equatable {
  final String id;
  final String email;
  final String username;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? accessToken;      // ← Auth tokens included
  final String? idToken;
  final String? refreshToken;
  final DateTime? tokenExpiresAt;
  // ... methods
}
```

### File 2: `lib/features/auth/domain/models/user.dart` (DELETE THIS)
```dart
class User {
  final String id;
  final String username;
  final String email;
  final String? firstName;           // ← Profile data instead
  final String? lastName;
  final String? profilePictureUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  // ... methods (no Equatable, manual copyWith)
}
```

---

## Solution Approach

### Option A: Merge into Domain Entity (RECOMMENDED)

Merge both models into the domain `User` entity, adding profile fields:

**Pros:**
- Single source of truth
- Domain entity has complete user data
- Simpler architecture

**Cons:**
- Domain entity becomes larger
- Mixing auth and profile concerns

### Option B: Separate Profile Entity

Create a separate `Profile` entity for profile data, keep `User` for auth.

**Pros:**
- Better separation of concerns
- Follows single responsibility principle

**Cons:**
- More complex to implement
- Requires more refactoring

---

## Step-by-Step Fix (Option A - RECOMMENDED)

### Step 1: Update Domain User Entity

**File:** `lib/features/auth/domain/entities/user.dart`

Add the missing profile fields:
```dart
class User extends Equatable {
  final String id;
  final String email;
  final String username;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  // Auth tokens (existing)
  final String? accessToken;
  final String? idToken;
  final String? refreshToken;
  final DateTime? tokenExpiresAt;

  // NEW: Profile fields (from models/user.dart)
  final String? firstName;
  final String? lastName;
  final String? profilePictureUrl;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    this.lastLoginAt,
    this.accessToken,
    this.idToken,
    this.refreshToken,
    this.tokenExpiresAt,
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        createdAt,
        lastLoginAt,
        accessToken,
        idToken,
        refreshToken,
        tokenExpiresAt,
        firstName,
        lastName,
        profilePictureUrl,
        updatedAt,
      ];

  // Add to existing copyWith method
  User copyWith({
    String? id,
    String? email,
    String? username,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? accessToken,
    String? idToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
    String? firstName,
    String? lastName,
    String? profilePictureUrl,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      accessToken: accessToken ?? this.accessToken,
      idToken: idToken ?? this.idToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Add fullName getter (from models/user.dart)
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return username;
    }
  }

  // ... keep existing methods (isEmpty, isNotEmpty, hasValidTokens, etc.)
}
```

### Step 2: Delete the Duplicate Model

**Delete:** `lib/features/auth/domain/models/user.dart`

### Step 3: Find and Replace All References

Run these commands to find all files that reference the old model:

```bash
# Find files importing the deleted model
grep -r "features/auth/domain/models/user" lib/
grep -r "models/user.dart" lib/
```

**Files to update:**

1. Update any imports from:
   ```dart
   import 'package:soloadventurer/features/auth/domain/models/user.dart';
   ```
   to:
   ```dart
   import 'package:soloadventurer/features/auth/domain/entities/user.dart';
   ```

2. Update any factory constructors:
   - Replace `User.fromJson()` calls with proper entity creation
   - Create a mapper if needed for API responses

### Step 4: Update Data Sources

Check files like:
- `lib/features/auth/data/datasources/auth_remote_data_source.dart`
- `lib/features/auth/data/datasources/auth_local_data_source.dart`

Ensure they return the domain `User` entity, not the deleted model.

### Step 5: Update Tests

Run and update tests that use the old User model:

```bash
flutter test test/features/auth/
```

Fix any failing tests by using the updated User entity.

### Step 6: Verify Build

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run build_runner
dart run build_runner build --delete-conflicting-outputs

# Run analyzer
flutter analyze
```

---

## Files That Likely Need Updates

Based on the codebase structure:

1. ✅ `lib/features/auth/domain/entities/user.dart` - UPDATE (add fields)
2. ❌ `lib/features/auth/domain/models/user.dart` - DELETE
3. ⚠️ `lib/features/auth/data/datasources/auth_remote_data_source.dart` - Check imports
4. ⚠️ `lib/features/auth/data/datasources/auth_local_data_source.dart` - Check imports
5. ⚠️ `lib/features/auth/data/models/user_model.dart` - May need updates
6. ⚠️ `lib/features/auth/data/repositories/auth_repository_impl.dart` - Check usage
7. ⚠️ Test files in `test/features/auth/` - Update tests

---

## Testing Checklist

- [ ] Domain User entity updated with all fields
- [ ] Duplicate model file deleted
- [ ] All imports updated to use domain entity
- [ ] Data sources return domain User entity
- [ ] Repository updated if needed
- [ ] All tests updated and passing
- [ ] `flutter analyze` shows no errors
- [ ] `flutter test` passes for auth feature
- [ ] App builds successfully

---

## Rollback Plan

If something breaks:
1. Git revert the changes: `git checkout -- lib/features/auth/domain/entities/user.dart`
2. Restore the deleted file from git: `git checkout -- lib/features/auth/domain/models/user.dart`
3. Identify what broke and fix incrementally

---

## Success Criteria

✅ Only one `User` class exists in the codebase (the domain entity)
✅ All references point to the domain User entity
✅ All tests pass
✅ No analyzer errors
✅ App builds and runs successfully
✅ User authentication flow still works

---

## Notes

- This is a **breaking change** - coordinate with team
- The User entity now serves both auth and profile purposes
- Consider future refactor to separate concerns (Option B)
- Update `CLAUDE.md` if entity structure changes significantly
