# SoloAdventurer - Incomplete Tasks Tracker

This document tracks all incomplete work and remaining TODOs across merged worktree branches.

**Last Updated:** 2026-01-04
**Main Branch Commit:** f7f4bae

---

## Table of Contents

1. [001: Offline-First Core Architecture](#001-offline-first-core-architecture)
2. [004: Safety Check-in & Location Sharing](#004-safety-check-in--location-sharing)
3. [008: Travel Journal with Media](#008-travel-journal-with-media)
4. [General Tasks](#general-tasks)

---

## 001: Offline-First Core Architecture

**Branch:** `auto-claude/001-offline-first-core-architecture`
**Merge Commit:** `17471bf`
**Implementation Status:** ~75% Complete

### Overview

The offline-first architecture provides local SQLite database, sync queue, connectivity monitoring, and conflict resolution. Core infrastructure is complete but auth integration and repository wrapping remain incomplete.

### TODO 1: Fix Hardcoded User IDs ✅ COMPLETED

**Location:** `lib/app/di/modules/offline_module.dart` lines 193, 207

**Problem:**
`DownloadSync` and `IncrementalSync` were registered with hardcoded user IDs:
```dart
userId: 'current-user-id', // TODO: Get from auth service
```

**Root Cause:**
GetIt service locator doesn't have access to Riverpod's ProviderContainer at registration time.

**Solution Implemented:**
Made `userId` a required parameter in sync methods instead of constructor:

1. Updated `lib/features/offline/infrastructure/sync/download_sync.dart`:
   - Removed `userId` from constructor
   - Added `required String userId` to all sync methods (`syncServerChanges`, `syncTrips`, `syncJournals`, `syncUserProfile`)
   - Replaced `_userId` references with method parameter

2. Updated `lib/features/offline/infrastructure/sync/incremental_sync.dart`:
   - Removed `userId` from constructor
   - Added `required String userId` to all sync methods
   - Replaced `_userId` references with method parameter

3. Updated `lib/features/offline/infrastructure/sync/sync_manager_impl.dart`:
   - Added `String Function() _getCurrentUserId` callback
   - Get userId from callback in `startSync()` method
   - Pass userId to download sync methods

4. Updated `lib/app/di/modules/offline_module.dart`:
   - Removed hardcoded userId from DownloadSync registration
   - Removed hardcoded userId from IncrementalSync registration
   - Added placeholder `getCurrentUserId` callback (returns empty string)

5. Created `lib/features/offline/presentation/providers/sync_manager_provider.dart`:
   - Created Riverpod provider for SyncManager
   - Provides `getCurrentUserId` callback that reads from auth state
   - Exported in `offline_providers.dart`

**Status:** ✅ Completed - The hardcoded userIds have been removed from the sync services. The SyncManager now gets the userId from the auth state via a callback function.

### TODO 2: Implement Offline-Aware Repositories

**Location:** `lib/app/di/modules/offline_module.dart` lines 231-241

**Problem:**
Existing repositories (TripRepository, JournalRepository, ProfileRepository) don't have offline capabilities.

**Required Implementation:**

1. Create base class `OfflineAwareRepositoryBase<T>` in `lib/features/offline/data/repositories/`

2. Implement offline-aware repositories:
   - `OfflineAwareTripRepository`
   - `OfflineAwareJournalRepository`
   - `OfflineAwareProfileRepository`

3. Each should:
   - Extend `OfflineAwareRepositoryBase<T>`
   - Wrap remote repository implementation
   - Inject local database, sync queue service, connectivity service
   - Use `OfflineInterceptor` for automatic queueing

4. Register in `lib/app/di/modules/offline_module.dart`

5. Update provider overrides to use offline-aware versions

### TODO 3: Implement Sync Notification Service

**Location:** `lib/app/di/modules/offline_module.dart` line 263

**Problem:**
No user notifications when sync operations complete/fail.

**Required Implementation:**

1. Create `lib/features/offline/infrastructure/sync/sync_notification_service.dart`

2. Implement methods:
   - `showNotification()` for sync events (started, completed, failed, retrying)
   - Use `flutter_local_notifications` package

3. Register in `lib/app/di/modules/offline_module.dart`

4. Wire up in `SyncManagerImpl` to call notifications at appropriate times

5. Update offline_module SyncManager registration to include notification service

### Additional Issues

**Missing Generated Code:**
- Many `.g.dart` files not generated (Drift, Freezed, Riverpod)
- Blocked by syntax errors in worktrees 004 and 008
- Run `dart run build_runner build --delete-conflicting-outputs` after fixing

**Missing Enums:**
- `EntityType` (trip, journal, userProfile, travelPreference)
- `ConflictResolutionStrategy` (lastWriteWins, serverWins, clientWins, manual)
- Define in `lib/features/offline/domain/services/conflict_resolver.dart`

---

## 004: Safety Check-in & Location Sharing

**Branch:** `auto-claude/004-safety-check-in-location-sharing`
**Status:** ✅ Merged to main (2026-01-05)
**Merge Commit:** `9f9adde`
**Implementation Status:** ~70% Complete

### Overview

Safety check-in and location sharing features have been merged, combining offline sync indicators with safety functionality. Core UI and navigation are complete, but data layer has type mismatches that need fixing.

### Completed Features ✅

1. **UI Components**: All safety screens and widgets merged
   - Safety Hub, Check-In Home, Emergency SOS
   - Location Sharing, Trusted Contacts screens
   - Quick SOS button on home screen

2. **Navigation**: Routes integrated with app router
   - Safety routes (`/safety/*`) properly configured
   - Navigation providers updated

3. **Platform Permissions**: Android and iOS configured
   - Location permissions (fine, coarse, background)
   - Background modes for location tracking
   - Notification permissions

4. **Home Screen**: Merged offline banners with safety cards
   - OfflineBanner and SyncStatusBanner from 001
   - Safety Hub, Check-In, Emergency cards from 004

### TODO: Fix Data Layer Type Mismatches

**Status:** PARTIALLY FIXED - Mock data source fixed, but architectural issue remains

**Location:** Multiple model files in `lib/features/safety/data/models/`

**Problems:**

1. **ARCHITECTURAL ISSUE - Models Extending Freezed Entities**:
   - Models like `CheckInModel`, `TrustedContactModel`, `LocationUpdateModel`, etc. try to extend freezed entities
   - Freezed entities only have factory constructors, so they cannot be extended
   - This causes errors like:
     ```
     The class 'CheckInModel' can't extend 'CheckIn' because 'CheckIn' only has factory constructors
     ```

2. **Mock Data Source - FIXED** ✅:
   - Fixed all incorrect field names (`contactSource` → `source`, `alertType` → `type`)
   - Fixed enum values (`CheckInTriggerType.scheduled` → `CheckInTriggerType.scheduledTime`)
   - Fixed enum values (`LocationSharingStatus.stopped` → `LocationSharingStatus.ended`)
   - Wrapped `copyWith` results with `Model.fromEntity()` where needed
   - Added missing required parameters (`timestamp` for SafetyStatusModel, etc.)

**Root Cause:**

The safety feature uses an invalid pattern where:
```dart
// WRONG - Can't extend freezed entities
class CheckInModel extends CheckIn {
  const CheckInModel({required super.id, ...});
}
```

Freezed generates immutable classes with only factory constructors, so they cannot be extended with generative constructors.

**Required Fix (Architecture Decision Needed):**

**Option 1 - Remove Models, Use Entities Directly**:
- Delete all model classes
- Use freezed entities everywhere
- Add `toJson`/`fromJson` directly to entities via freezed's `@JsonSerializable`
- Simpler, less boilerplate

**Option 2 - Change Models to Composition**:
- Models don't extend entities, they contain them
- Add conversion methods
- More separation between layers

**Option 3 - Don't Use Freezed for Entities**:
- Convert entities to regular classes
- Lose freezed benefits (copyWith, equality, pattern matching)
- More code to maintain

**Recommendation:** Option 1 - Use freezed entities directly with JSON serialization. This is the standard Flutter/Dart pattern and eliminates the need for separate model classes.

### TODO: Fix Integration Tests

**Location:** `integration_test/features/safety/safety_flow_test.dart`

**Issues:**
- Missing test helpers (`safety_test_helpers.dart`)
- API parameter mismatches
- Provider conflicts

**Status:** Non-blocking - can be fixed after data layer works

---

## 008: Travel Journal with Media

**Branch:** `auto-claude/008-travel-journal-with-media`
**Status:** Dependency issue

### Issues

**Invalid Dependency:**
- `exif: ^0.3.0` doesn't exist on pub.dev

**Required Fix:**
1. Check correct version of `exif` package on pub.dev
2. Update `pubspec.yaml` in 008 worktree with correct version
3. May need to use different package (e.g., `image` package has EXIF support)

---

## General Tasks

### Task 1: Fix Safety Data Layer Type Mismatches

**Location:** `lib/features/safety/data/datasources/mock_safety_remote_data_source.dart`

**Required:**
1. Update data source methods to return models instead of entities
2. Fix missing required parameters in model constructors
3. Fix enum constant references
4. Run `flutter analyze` to verify no errors

### Task 2: Run Build Runner

**Blocker:** Data layer errors must be fixed first

**Required:**
1. Fix safety data layer type mismatches
2. Fix dependency in worktree 008
3. Run `dart run build_runner build --delete-conflicting-outputs`
4. Verify all `.g.dart` files generated

### Task 3: Clean up macOS Resource Files

**Status:** Ongoing issue

**Current:**
- `._*` files keep appearing (macOS resource forks)
- Already added `.worktrees/` to `.gitignore`

**Recommended:**
1. Add to `.gitignore`:
   ```
   ._*
   .DS_Store
   .AppleDouble
   .LSOverride
   ```
2. Add pre-commit hook to clean these files

### Task 4: Git Remote Repository

**Issue:** Repository `PhoenixTiger007/SoloAdventurer_app` doesn't exist on GitHub

**Required:**
1. Create repository on GitHub OR
2. Update remote URL to correct repository
3. Push local commits

---

## Testing Checklist

### Offline Functionality (001)
- [ ] Create entity while offline
- [ ] Verify queued in sync queue
- [ ] Verify local database updated
- [ ] Go online, verify auto-sync
- [ ] Verify conflict resolution works

### Safety Features (004)
- [ ] Fix data layer type mismatches
- [ ] Create check-in while offline
- [ ] Trigger SOS while offline
- [ ] Share location while offline
- [ ] Verify location updates sync when online

### Media Features (008)
- [ ] Fix invalid dependency
- [ ] Add photo to journal while offline
- [ ] Verify EXIF data extracted
- [ ] Verify photo syncs when online

---

## Worktree Status

| Worktree | Status | Completion |
|----------|--------|------------|
| 001 - Offline-First | Merged | ~75% - userIds fixed, missing repos |
| 004 - Safety | Merged | ~70% - UI complete, data layer broken |
| 008 - Travel Journal | Not merged | Blocked by invalid dependency |
| 002-003, 005-007, 009-012 | Not started | - |

---

## Recommended Implementation Order

1. ~~**Fix syntax errors in worktree 004**~~ ✅ **COMPLETED**
2. ~~**Fix hardcoded userIds in 001**~~ ✅ **COMPLETED**
3. **Fix data layer type mismatches in 004** (HIGH PRIORITY)
4. **Fix dependency in worktree 008** (quick win)
5. **Run build_runner** (unlocks all generated code)
6. **Complete offline TODO 3** (notifications - nice to have)
7. **Complete offline TODO 2** (offline-aware repositories - complex)
8. **Test all features**
9. **Fix and merge remaining worktrees**

---

## Related Documentation

- **Architecture:** `docs/ARCHITECTURE.md`
- **Offline Architecture:** `docs/OFFLINE_FIRST_ARCHITECTURE.md`
- **Riverpod Patterns:** `docs/RIVERPOD_PATTERNS.md`
- **Auth Architecture:** `docs/AUTH_ARCHITECTURE.md`
- **Build Configuration:** `build.yaml`

---

## Progress Tracking

| Date | Worktree | Action | Status |
|------|----------|--------|--------|
| 2026-01-04 | 001 | Merged to main | ✅ Complete |
| 2026-01-04 | 001 | Created UserIdProvider | ✅ Complete |
| 2026-01-04 | 001 | Registered OfflineInterceptor | ✅ Complete |
| 2026-01-04 | 001 | Documented remaining TODOs | ✅ Complete |
| 2026-01-04 | 001 | Fix hardcoded userIds | ✅ Complete |
| 2026-01-05 | 004 | Fixed syntax errors in screens | ✅ Complete |
| 2026-01-05 | 004 | Merged to main | ✅ Complete |
| 2026-01-05 | 004 | Documented data layer issues | ✅ Complete |
| Pending | 004 | Fix data layer type mismatches | ⏳ TODO |
| Pending | 001 | Implement offline-aware repos | ⏳ TODO |
| Pending | 001 | Implement sync notifications | ⏳ TODO |
| Pending | 008 | Fix dependency | ⏳ TODO |
| Pending | All | Run build_runner | ⏳ Blocked |
