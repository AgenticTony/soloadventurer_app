# Sprint 7: Polish + Edge Cases
**Duration:** Weeks 12-14
**Theme:** No blank screens. No unhandled errors. Clean architecture. Everything feels right under your thumb.
**Depends on:** Sprint 6

## Tasks

### 7.1 Audit all screens for loading/error/empty states
- [ ] Go through every screen systematically
- [ ] Loading: spinner or shimmer on every AsyncValue
- [ ] Error: user-friendly message + retry button
- [ ] Empty: informative message + CTA ("Create your first trip!")
- [ ] **Test:** Each screen has 3-state widget test

### 7.2 Offline graceful degradation
- [ ] Cached data loads when offline
- [ ] Sync indicator visible (last synced: X min ago)
- [ ] Queued operations show "pending" status
- [ ] No crashes or blank screens when Supabase unreachable
- [ ] **Test:** Offline mode test: turn off network, verify cached data loads

### 7.3 Navigation edge cases
- [ ] Back button behavior consistent (no orphan screens)
- [ ] Deep links work from push notifications
- [ ] Cold start restores correct navigation state
- [ ] Auth redirect doesn't lose intended destination
- [ ] **Test:** Navigation test for each case

### 7.4 Performance optimization
- [ ] Image loading: caching, lazy loading, placeholders
- [ ] List scrolling: smooth with 500+ items (ListView.builder)
- [ ] Startup time: <3 seconds cold start
- [ ] **Test:** Performance benchmark test

### 7.5 Accessibility
- [ ] Semantic labels on all interactive elements
- [ ] Sufficient color contrast
- [ ] Touch targets >= 44x44 points
- [ ] Screen reader navigable
- [ ] **Test:** Accessibility audit test

### 7.6 Architecture cleanup — remove duplicates
- [ ] Remove duplicate use-case pairs in `lib/features/auth/domain/usecases/`:
  - `login.dart` / `login_use_case.dart` (keep `LoginUseCase`)
  - `sign_up.dart` / `register_use_case.dart` (keep `RegisterUseCase`)
  - `sign_out.dart` / `logout_use_case.dart` (keep `LogoutUseCase`)
  - `get_current_user.dart` / `get_current_user_use_case.dart` (keep `GetCurrentUserUseCase`)
- [ ] Remove legacy `ApiClient` at `lib/core/network/api_client.dart` (keep `lib/core/api/client/api_client.dart`)
- [ ] Remove duplicate `dioProvider` at `lib/core/network/network_providers.dart` (keep `lib/core/providers/api_providers.dart` — has interceptors)
- [ ] Consolidate 3 ConnectivityService implementations into one in `lib/core/services/`
- [ ] Remove legacy `lib/core/error/` directory (keep `lib/core/errors/` with sealed Failure pattern)
- [ ] Remove `lib/utils/` — consolidate into `lib/core/services/` and `lib/core/monitoring/`
- [ ] Move `lib/test_utils/` to `test/utils/` and `lib/config/test_config.dart` to `test/test_config.dart`
- [ ] Remove orphaned `lib/screens/forgot_password_screen.dart` (duplicate of auth feature version)
- [ ] Standardize layer naming: use `data/` + `domain/` + `presentation/` consistently (remove `infrastructure/` and `application/` aliases)
- [ ] **Test:** `flutter analyze` — 0 errors after consolidation
- [ ] **Test:** All existing tests still pass after consolidation

### 7.7 State management migration to AsyncNotifier
- [ ] Migrate `SafetyNotifier` from `Notifier<SafetyState>` to `AsyncNotifier<SafetyState>` — remove manual `isLoading`/`error` fields
- [ ] Migrate `CheckInNotifier` to AsyncNotifier
- [ ] Migrate `TrustedContactsNotifier` to AsyncNotifier
- [ ] Migrate `LocationSharingNotifier` to AsyncNotifier
- [ ] Migrate `ProfileNotifier` to AsyncNotifier — consolidate dual notifiers (`Profile` + `ProfileDomain`) into single canonical provider
- [ ] Migrate `JournalListNotifier` to AsyncNotifier
- [ ] Convert all state classes to `@freezed`: `safety_state.dart`, `profile_state.dart`, `journal_list_provider.dart`, `itinerary_state.dart`
- [ ] Fix `ref.watch()` → `ref.read()` for use-case access in all notifier methods (safety, auth, profile providers)
- [ ] Update all UI screens to use `AsyncValue.when()` for these features
- [ ] Remove `clearError()` workaround methods (no longer needed with AsyncValue)
- [ ] **Test:** Each migrated notifier has build/loading/error/success state tests
- [ ] **Test:** `grep -rn "isLoading" lib/features/*/presentation/state/` returns 0 results
- [ ] **Test:** `grep -rn "String? error" lib/features/*/presentation/state/` returns 0 results

### 7.8 Database performance
- [ ] Add indexes to `lib/features/offline/infrastructure/database/schema.dart` for all 6 tables:
  - `Trips`: userId, status, isSynced
  - `Journals`: tripId, userId, isSynced
  - `Users`: userId
  - `SyncQueue`: status, priority, entityType, isSynced
  - `SyncMetadata`: entityType
  - `Itineraries` + `ItineraryItems`: tripId, userId, isSynced
- [ ] Run schema migration or version bump
- [ ] **Test:** Query plan verification shows index usage for `WHERE userId = ?` and `WHERE status = 'pending'`

### 7.9 Network performance fixes
- [ ] Increase receive timeout from 3s to 10s in `lib/core/providers/api_providers.dart`
- [ ] Fix `CacheManager._getFromDisk()` stub — implement typed deserialization or remove disk cache layer entirely
- [ ] Fix `CacheManager.putJson()` unsafe `as V` cast — use proper type checking
- [ ] Refactor 5 duplicate HTTP methods in `ApiClient` (get/post/put/delete/patch) into single `_request()` template method
- [ ] Throw typed `NetworkConnectivityException` instead of raw `Exception` in offline mode
- [ ] **Test:** Cache round-trip: put typed data → get returns same data (or confirm disk layer removed)
- [ ] **Test:** `flutter analyze` — 0 errors

### 7.10 Debug output cleanup
- [ ] Guard or remove `debugPrint` calls in production code paths — wrap with `if (kDebugMode)` or use structured logger
- [ ] Priority areas: `lib/features/auth/` (543 occurrences), `lib/features/sync/`, `lib/core/database/`
- [ ] Target: <50 unguarded `debugPrint` calls in `lib/`
- [ ] **Test:** `grep -rn "debugPrint" lib/ | grep -v "kDebugMode" | grep -v "// ignore" | wc -l` returns <50

### 7.11 Bootstrap performance
- [ ] Parallelize DB/SharedPreferences/Supabase initialization with `Future.wait()` in `lib/app/bootstrap.dart`
- [ ] Add `autoDispose` to screen-level providers that don't need `keepAlive` (profile screens, settings screens)
- [ ] Initialize WorkManager in bootstrap for background sync scheduling
- [ ] **Test:** Cold start time <3s on mid-range device (measure with `AppStartTracker`)

## Definition of Done
- [ ] Zero blank screens in the entire app
- [ ] Zero unhandled errors visible to user
- [ ] Offline shows cached data with sync indicator
- [ ] App opens in <3 seconds
- [ ] Zero duplicate providers/classes in codebase (single ApiClient, single dioProvider, single ConnectivityService)
- [ ] All features use AsyncNotifier with @freezed states (no manual isLoading/error)
- [ ] Database has indexes on all frequently queried columns
- [ ] <50 unguarded debugPrint calls in lib/
- [ ] All tests pass: `flutter test`
- [ ] **Manual QA:** Airplane mode test, cold start test, accessibility spot check
- [ ] **Analytics:** Performance metrics (startup time, screen load times)

## Verification
```bash
flutter analyze
flutter test
# Manual: airplane mode, cold start, accessibility spot check
```
