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
**Status:** Syntax errors prevent build

### Issues

**Syntax Errors:**
- `lib/features/safety/presentation/screens/check_in_home_screen.dart:121:46`
- `lib/features/safety/presentation/screens/location_sharing_screen.dart:108:38`

**Root Cause:** Missing closing braces `}`

**Required Fix:**
1. Check lines 121 in check_in_home_screen.dart
2. Check line 108 in location_sharing_screen.dart
3. Add missing closing braces
4. Run `flutter analyze` to verify

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

### Task 1: Run Build Runner

**Blocker:** Worktrees with syntax errors

**Required:**
1. Fix syntax errors in worktrees 004 and 008
2. Ensure `build.yaml` excludes worktrees (already configured)
3. Run `dart run build_runner build --delete-conflicting-outputs`
4. Verify all `.g.dart` files generated

### Task 2: Clean up macOS Resource Files

**Issue:** `._*` files keep appearing (macOS resource forks)

**Required:**
1. Consider adding to `.gitignore`:
   ```
   ._*
   .DS_Store
   .AppleDouble
   .LSOverride
   ```
2. Add pre-commit hook to clean these files

### Task 3: Git Remote Repository

**Issue:** Repository `PhoenixTiger007/SoloAdventurer_app` doesn't exist on GitHub

**Required:**
1. Create repository on GitHub OR
2. Update remote URL to correct repository
3. Push 121 local commits

---

## Testing Checklist

Once all TODOs complete:

### Offline Functionality
- [ ] Create entity while offline
- [ ] Verify queued in sync queue
- [ ] Verify local database updated
- [ ] Go online, verify auto-sync
- [ ] Verify conflict resolution works

### Safety Features (004)
- [ ] Create check-in while offline
- [ ] Trigger SOS while offline
- [ ] Share location while offline
- [ ] Verify location updates sync when online

### Media Features (008)
- [ ] Add photo to journal while offline
- [ ] Verify EXIF data extracted
- [ ] Verify photo syncs when online

---

## Worktree Status

| Worktree | Status | Blocker |
|----------|--------|---------|
| 001 - Offline-First | Merged, 75% complete | Hardcoded userIds, missing repositories |
| 004 - Safety | Not merged | Syntax errors |
| 008 - Travel Journal | Not merged | Invalid dependency |

---

## Recommended Implementation Order

1. **Fix syntax errors in worktree 004** (quick win)
2. **Fix dependency in worktree 008** (quick win)
3. **Run build_runner** (unblocks all)
4. ~~**Complete offline TODO 1** (hardcoded userIds)~~ ✅ **COMPLETED**
5. **Complete offline TODO 3** (notifications - nice to have)
6. **Complete offline TODO 2** (offline-aware repositories - complex)
7. **Test all features**
8. **Merge remaining worktrees**

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
| Pending | 001 | Implement offline-aware repos | ⏳ TODO |
| Pending | 001 | Implement sync notifications | ⏳ TODO |
| Pending | 004 | Fix syntax errors | ⏳ TODO |
| Pending | 008 | Fix dependency | ⏳ TODO |
| Pending | All | Run build_runner | ⏳ Blocked |
