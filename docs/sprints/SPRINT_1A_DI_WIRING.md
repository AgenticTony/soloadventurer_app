# Sprint 1a: DI Wiring + Routes
**Duration:** Week 1
**Theme:** Pure plumbing. Wire every UnimplementedError provider. Register routes. Get analytics baseline.

## Tasks

### 1a.1 Wire MatchingRepository into DI
- [x] Create `lib/features/matching/data/datasources/matching_local_data_source_impl.dart` (in-memory MVP)
- [x] Instantiate `MatchingRemoteDataSourceImpl` + `MatchingLocalDataSourceImpl` → `MatchingRepositoryImpl`
- [x] Override `matchingRepositoryProvider` in `lib/app/bootstrap.dart`
- [x] **Test:** Provider resolves correctly without UnimplementedError
- [x] **Test:** MatchingLocalDataSourceImpl CRUD operations

### 1a.2 Wire JournalRepository into DI
- [x] Instantiate `JournalRemoteDataSourceImpl` → `JournalRepositoryImpl`
- [x] Override `journalRepositoryProvider` in `lib/app/bootstrap.dart`
- [x] **Test:** Provider resolves correctly without UnimplementedError

### 1a.3 Register chat route in GoRouter
- [x] Add `/chat/:connectionId` route to `lib/app/router/go_router_config.dart`
- [x] Fix `MatchesScreen` to use `context.push('/chat/$connectionId')` instead of `Navigator.pushNamed`
- [x] Accept `connectionId` as path param, `chatId`/`prefilledMessage` as `extra`
- [x] **Test:** Route extracts path parameters correctly
- [x] **Test:** Route renders screen with path and extra params
- [x] **Test:** Route handles missing extra gracefully
- [x] **Test:** Route receives prefilledMessage from extra

### 1a.4 Add basic analytics
- [x] Create `lib/core/services/analytics_service.dart` with interface + DebugAnalyticsService + TestAnalyticsService
- [x] Create `lib/app/providers/analytics_provider.dart`
- [x] Track screen views via GoRouter redirect callback
- [x] **Test:** TestAnalyticsService track/trackScreenView/identify/reset/setUserProperty
- [x] **Test:** AnalyticsEvents constants exist

### 1a.5 Apply for Viator Affiliate Partner API access
- [ ] Go to https://partner.viator.com and apply for affiliate partner program
- [ ] Approval typically takes 1-3 weeks — apply now so key is ready by Sprint 5
- [ ] Once approved: store API key securely, add `VIATOR_API_KEY` to `.env.example`
- [ ] **Note:** No code task — just the application. Sprint 5 implements the integration.

### 1a.6 Fix loading/error/empty states on Home + Matches screens
- [x] Home screen: AsyncValue.when() for loading, error with retry, empty with CTA
- [x] Matches screen: loading spinner, error with retry, "no trips yet" empty state
- [x] **Test:** Widget test for loading state (existing)
- [x] **Test:** Widget test for error state with retry button (existing)
- [x] **Test:** Widget test for empty state with CTA (existing)

## Definition of Done
- [x] All providers resolve without UnimplementedError
- [x] Routes navigate correctly (home, matches, chat)
- [x] Analytics fires on screen views
- [x] Home and Matches screens handle all 3 states
- [x] All tests pass: `flutter test`
- [ ] **Manual QA:** Tap through home → matches → profile on device

## Verification
```bash
flutter analyze
flutter test
flutter run --dart-define=AUTH_PROVIDER=supabase
```
