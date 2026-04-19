# Sprint 7.5: Production Infrastructure
**Duration:** Weeks 14-15
**Theme:** Wire up every piece of production infrastructure. The app must be shippable after this sprint.
**Depends on:** Sprint 7

## Tasks

### 7.5.1 Android release signing + ProGuard
- [ ] Generate production keystore (`keytool -genkey...`), store securely (not in repo)
- [ ] Create `android/key.properties` (gitignored) with keystore path, passwords, alias
- [ ] Configure `android/app/build.gradle` with release signing via `key.properties`
- [ ] Enable `minifyEnabled true`, `shrinkResources true` in release buildType
- [ ] Create ProGuard rules file (`android/app/proguard-rules.pro`) — keep Flutter/Drift/Supabase classes
- [ ] Change bundle identifier from `com.example.soloadventurer` to production value (both `build.gradle` + `AndroidManifest.xml`)
- [ ] Update `android/app/build.gradle` versionCode and versionName to match `pubspec.yaml`
- [ ] **Test:** `flutter build apk --release` produces signed, minified APK
- [ ] **Test:** `jarsigner -verify app-release.apk` returns "jar verified"
- [ ] **Test:** APK decompilation shows obfuscated code (ProGuard active)

### 7.5.2 iOS distribution setup
- [ ] Create App Store distribution provisioning profile in Apple Developer Portal
- [ ] Configure Xcode project with production team ID and bundle identifier
- [ ] Set `CODE_SIGN_STYLE = Manual` with distribution certificate
- [ ] Add all required permission descriptions to `ios/Runner/Info.plist`:
  - `NSCameraUsageDescription` (photo upload)
  - `NSLocationWhenInUseUsageDescription` + `NSLocationAlwaysAndWhenInUseUsageDescription` (safety, matching)
  - `NSUserNotificationsUsageDescription` (messages, check-ins)
  - `NSContactsUsageDescription` (trusted contacts)
- [ ] Add corresponding permissions to `android/app/src/main/AndroidManifest.xml`
- [ ] **Test:** `flutter build ios --release` succeeds without signing errors
- [ ] **Test:** No missing permission description warnings in build log

### 7.5.3 Environment separation
- [ ] Create separate Supabase project for staging environment
- [ ] Create `.env.staging` and `.env.production` templates — non-secret config only (URLs, feature flags)
- [ ] Use `--dart-define=ENVIRONMENT=staging|production` for build-time config injection
- [ ] Update `lib/core/config/app_config.dart` to read from `--dart-define` instead of `.env` file
- [ ] Remove `.env` file dependency entirely from `pubspec.yaml` and bootstrap
- [ ] **Test:** Staging build connects to staging Supabase; production to production
- [ ] **Test:** App starts correctly with `--dart-define=ENVIRONMENT=production` and no `.env` file

### 7.5.4 SSL certificate pinning
- [ ] Implement certificate pinning using Dio's `HttpClientAdapter` or custom `SecurityContext`
- [ ] Pin Supabase API endpoint (`*.supabase.co`) and backend API (`api.saloadventurer.com`)
- [ ] Add pin bypass for debug builds (`if (kDebugMode) return true;`)
- [ ] Handle pin failure gracefully — show user-facing error, don't crash
- [ ] **Test:** Charles/mitmproxy fails to intercept HTTPS in release build
- [ ] **Test:** Debug builds work without pins (bypass active)

### 7.5.5 Local database encryption
- [ ] Replace `sqflite` dependency with `sqflite_sqlcipher` or enable drift's SQLCipher support
- [ ] Derive encryption key from SecureStorage (not hardcoded, not in `.env`)
- [ ] Update `lib/features/offline/infrastructure/database/database_service.dart` to use encrypted connection
- [ ] Implement migration path: detect unencrypted DB → encrypt in-place → verify
- [ ] Verify all 6 tables encrypted at rest
- [ ] **Test:** `sqlite3 soloadventurer.db "SELECT * FROM trips;"` fails without key
- [ ] **Test:** App migrates existing unencrypted data on update — all records preserved

### 7.5.6 CI/CD pipeline hardening
- [ ] Update all GitHub Actions from v3 to v4:
  - `actions/checkout@v3` → `actions/checkout@v4`
  - `actions/upload-artifact@v3` → `actions/upload-artifact@v4`
  - `codecov/codecov-action@v3` → `codecov/codecov-action@v4`
- [ ] Update CI Flutter version from `3.19.0` to latest stable in all 3 workflow files
- [ ] Add integration test job (run on macOS with iOS simulator)
- [ ] Add coverage threshold enforcement: fail if line coverage < 50%
- [ ] Set up branch protection on `main`: require `flutter analyze` + `flutter test` to pass before merge
- [ ] Update `.githooks/pre-commit` to run `flutter analyze` + `dart format --set-exit-if-changed` + secret detection
- [ ] Add `.gitignore` entries: `test_failures.txt`, `test_output.txt`, `test_results.json`, `flutter_*.log`, `build_output.log`, `files.zip`
- [ ] Remove committed build artifacts from repo tracking
- [ ] Consolidate `flutter-ci.yml` and `code-coverage.yml` — single job with coverage as artifact
- [ ] **Test:** PR with <50% coverage fails CI
- [ ] **Test:** Push to `main` without passing checks is blocked

### 7.5.7 Sentry initialization + monitoring
- [ ] Add Sentry DSN to `--dart-define` config (not in `.env`)
- [ ] Initialize Sentry in `lib/app/bootstrap.dart` before `runApp`:
  - `dsn`, `environment` (staging/production), `release` (version from pubspec)
  - `tracesSampleRate: 0.2` for performance monitoring
- [ ] Configure source maps for readable stack traces
- [ ] Add anonymized user context to Sentry events (hashed user ID, not email)
- [ ] Remove `sentry_flutter` from pubspec if not used (currently declared but never initialized)
- [ ] **Test:** Trigger test error, confirm event appears in Sentry dashboard
- [ ] **Test:** Release version and environment tag correct in Sentry

### 7.5.8 Deployment automation
- [ ] Install Fastlane: `bundle exec gem install fastlane`
- [ ] Create `ios/fastlane/Fastfile` with lanes: `test`, `build`, `upload_to_testflight`
- [ ] Create `android/fastlane/Fastfile` with lanes: `test`, `build`, `upload_to_play_store`
- [ ] Add GitHub Actions workflow: on tag push (`v*.*.*`) → build + upload
- [ ] Create semantic versioning tags (`v1.0.0` format) from `pubspec.yaml` version
- [ ] Document deployment runbook in `docs/DEPLOYMENT.md`
- [ ] **Test:** `fastlane test` passes on CI
- [ ] **Test:** Tag push triggers build pipeline (dry run)

## Definition of Done
- [ ] Release APK is signed, minified, and has production bundle ID
- [ ] iOS build succeeds with distribution profile
- [ ] Staging and production environments fully separated
- [ ] Certificate pinning blocks MITM on release builds
- [ ] Database encrypted at rest
- [ ] CI enforces coverage (>=50%), analysis, and branch protection
- [ ] Sentry captures errors with correct environment and version
- [ ] Fastlane automates store uploads
- [ ] All tests pass: `flutter test`
- [ ] **Manual QA:** Release build on physical device — verify signing, pins, encryption, environment
- [ ] **Security:** OWASP M3 (Insecure Communication) + M9 (Reverse Engineering) checklist items resolved

## Verification
```bash
flutter analyze
flutter test
flutter build apk --release
flutter build ios --release
# Verify APK signing
jarsigner -verify build/app/outputs/flutter-apk/app-release.apk
# Verify ProGuard active
unzip -l app-release.apk | grep classes.dex
# Verify cert pinning — attempt MITM with proxy tool
# Verify DB encryption
sqlite3 soloadventurer.db "SELECT * FROM trips;"  # should fail
# Verify CI gates — create test PR with failing coverage
```
