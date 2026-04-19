# Sprint 8: Integration Tests + App Store
**Duration:** Weeks 15-16
**Theme:** Ship it. Prove every critical path works. Submit to stores.
**Depends on:** Sprint 7.5

## Tasks

### 8.1 Integration test: signup → verify → profile setup
- [ ] Test opens app, navigates to signup
- [ ] Enters email + password, submits
- [ ] Verifies email (mock or test mode)
- [ ] Completes profile setup
- [ ] Arrives at home screen authenticated
- [ ] **Test:** Passes on iOS + Android physical device

### 8.2 Integration test: trip → match → chat → real-time message
- [ ] User A creates trip to Paris
- [ ] User B creates overlapping trip to Paris
- [ ] User A sees User B in matches
- [ ] User A accepts match / sends message
- [ ] User B receives message in real-time
- [ ] User B replies, User A receives reply
- [ ] **Test:** Passes on iOS + Android physical device

### 8.3 Integration test: check-in → reminder → SOS → contact notified
- [ ] Schedule check-in for 1 minute from now
- [ ] Verify reminder notification appears
- [ ] Trigger SOS
- [ ] Trusted contact receives push notification
- [ ] **Test:** Passes on iOS + Android physical device

### 8.4 App Store preparation
- [ ] Set proper app version and build number in `pubspec.yaml`
- [ ] Add all required permission descriptions to `ios/Runner/Info.plist`:
  - Camera (photo upload)
  - Location (safety, matching)
  - Notifications (messages, check-ins)
  - Contacts (trusted contacts)
- [ ] Add permissions to `android/app/src/main/AndroidManifest.xml`
- [ ] Configure app icons and splash screens
- [ ] Write App Store description and screenshots
- [ ] **Test:** No missing permission descriptions

### 8.5 Sentry error reporting in production
- [ ] Configure Sentry with production DSN
- [ ] Verify errors appear in Sentry dashboard
- [ ] Set up source maps for readable stack traces
- [ ] **Test:** Trigger test error, confirm in Sentry dashboard

### 8.6 Submit to TestFlight + Google Play Internal Testing
- [ ] Build release: `flutter build ios --release`
- [ ] Upload to App Store Connect
- [ ] Submit to TestFlight
- [ ] Build release: `flutter build apk --release`
- [ ] Upload to Google Play Console
- [ ] Submit to Internal Testing track
- [ ] **Test:** Both platforms accept submission without rejection

### 8.7 Database encryption migration verification
- [ ] Test upgrade path from unencrypted v0.1 to encrypted v1.0 on real device
- [ ] Verify all user data preserved after migration (trips, journals, itineraries)
- [ ] **Test:** Existing test data readable after encryption migration

### 8.8 Final security verification
- [ ] Run OWASP Mobile Top 10 checklist against release build
- [ ] Verify no secrets in app bundle (binary analysis with `strings` command)
- [ ] Verify no secrets in git history (`git grep "sk-" $(git rev-list --all)`)
- [ ] Verify certificate pinning blocks MITM on release build
- [ ] Verify database encrypted at rest
- [ ] Verify tokens only in SecureStorage (not SharedPreferences)
- [ ] Verify PRNG uses proper entropy (not deterministic seed)
- [ ] Verify AuthInterceptor has retry guard (no infinite loop)
- [ ] **Test:** All OWASP checklist items green

### 8.9 Test coverage gate
- [ ] Verify line coverage >= 50% (`flutter test --coverage` + `lcov --summary`)
- [ ] Verify all feature modules have minimum domain layer tests
- [ ] Verify social feature has full test coverage (from Sprint 6)
- [ ] Verify matching feature has full test coverage (from Sprint 1a)
- [ ] **Test:** `lcov --summary coverage/lcov.info` shows >= 50% line coverage

### 8.10 Test framework cleanup
- [ ] Standardize on mocktail — remove mockito from `pubspec.yaml`, migrate 17 `.mocks.dart` files
- [ ] Remove deprecated StateNotifier test utilities from `test/utils/provider_test_helpers.dart`
- [ ] Replace `Future.delayed` timing in tests with proper async patterns (`expectLater`, completers)
- [ ] Centralize mock definitions (one mock per interface, shared across test files)
- [ ] Remove duplicate mock definitions (e.g., `MockAuthRepository` defined in 3+ places)
- [ ] **Test:** All tests pass with single mocking framework (mocktail only)

## Definition of Done
- [ ] 3 critical path integration tests pass on both iOS and Android
- [ ] App accepted by TestFlight
- [ ] App accepted by Google Play Internal Testing
- [ ] Sentry captures errors in production
- [ ] All tests pass: `flutter test` + `flutter test integration_test/`
- [ ] **Manual QA:** Final walkthrough on both platforms

## Verification
```bash
flutter analyze
flutter test
flutter test integration_test/
flutter build ios --release
flutter build apk --release
```
