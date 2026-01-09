# SoloAdventurer - Incomplete Tasks Tracker

This document tracks all incomplete work and remaining TODOs across merged worktree branches.

**Last Updated:** 2026-01-05
**Main Branch Commit:** 02160dd

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
**Latest Update:** 2026-01-05 (commit `02160dd`)
**Implementation Status:** ~75% Complete

### Overview

Safety check-in and location sharing features have been merged and partially fixed. Data layer now uses freezed entities directly, but presentation layer still has provider architecture issues.

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

5. **Data Layer Architecture** - FIXED ✅:
   - Implemented Option 1: Use freezed entities directly with JSON serialization
   - Deleted all model classes (`check_in_model.dart`, `trusted_contact_model.dart`, etc.)
   - Updated all data sources to use entities directly
   - Fixed field name mismatches throughout
   - Generated JSON serialization code with build_runner

6. **Syntax Errors** - FIXED ✅:
   - Fixed `network_reachability.dart:179` missing closing brace
   - Fixed `Value.null()` → `Value(null)` in `sync_queue_dao.dart`
   - Fixed syntax errors in `check_in_home_screen.dart` and `location_sharing_screen.dart`
   - Fixed const constructor issue in `safety_remote_data_source_impl.dart`

7. **Field Name Mismatches** - FIXED ✅:
   - `acknowledgedBy` → `acknowledgedByContactIds`
   - `timestamp` → `createdAt` (for LocationUpdate)
   - `SafetyAlertStatus.active` → `sent` or `acknowledged`

### Remaining Issues ⚠️

**1. Presentation Layer Provider Architecture** (CRITICAL - ~43 errors)

The presentation layer uses an outdated Riverpod 1.x `StateNotifier` pattern that doesn't work correctly with Riverpod 2.x's `@riverpod` annotation.

**Issues:**
- State providers expect `TrustedContactsState` but get `TrustedContactsNotifier`
- Providers try to access properties like `notifier.contacts` but should use `notifier.state.contacts`
- The `@riverpod` annotation generates providers that return the NOTIFIER, not the STATE

**Affected Files:**
- `lib/features/safety/presentation/providers/safety_providers.dart`
- `lib/features/safety/presentation/notifiers/*.dart`

**Required Fix:**
Two options:

**Option A - Access `.state` property:**
Change state providers to access `notifier.state`:
```dart
final trustedContactsStateProvider = Provider<TrustedContactsState>((ref) {
  return ref.watch(trustedContactsNotifierProvider.notifier).state;
});
```

**Option B - Use proper Riverpod 2.x AsyncNotifier pattern:**
Migrate from `StateNotifier<T>` to `AsyncNotifier<T>`:
- Replace `StateNotifier<TrustedContactsState>` with `AsyncNotifier<TrustedContactsState>`
- Use `@riverpod` annotation directly on the notifier class
- Update state management to use `AsyncValue` pattern

**2. Data Layer Providers** (NON-CRITICAL - can be removed for now)

`lib/features/safety/data/repositories/safety_providers.dart` references non-existent files:
- `SafetyLocalDataSourceImpl` - implementation exists but isn't being found
- `MockSafetyRemoteDataSource` - needs proper registration
- Import `package:soloadventurer/core/error/failures.dart` doesn't exist

**Workaround:** This file can be removed or commented out - the safety feature doesn't use GetIt, it uses Riverpod providers.

**3. Service Implementations** (NON-CRITICAL - placeholder services needed)

`lib/features/safety/presentation/providers/safety_providers.dart` lines 42-74:
- `LocationServiceImpl` - not defined
- `NotificationServiceImpl` - not defined
- `BackgroundCheckInServiceImpl` - not defined
- `MissedCheckInDetectorImpl` - not defined

**Workaround:** Create placeholder implementations or remove these providers for now.

### Summary

**Progress:**
- Data layer: ✅ Complete (uses freezed entities directly)
- Domain layer: ✅ Complete (entities and use cases defined)
- Presentation layer: ⚠️ ~50% (UI exists, providers need Riverpod 2.x migration)

**Next Steps:**
1. Fix presentation layer provider architecture (choose Option A or B above)
2. Remove or fix non-critical data layer providers
3. Create placeholder service implementations
4. Run `flutter analyze` and `flutter test` to verify fixes

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
