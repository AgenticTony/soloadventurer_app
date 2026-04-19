# Sprint 4.5: Security Hardening
**Duration:** Weeks 5-6
**Theme:** Fix every P0 security finding. No feature work continues until secrets are safe.
**Depends on:** Sprint 4

## Tasks

### 4.5.1 Rotate all exposed credentials
- [ ] Rotate AWS Access Key + Secret Key
- [ ] Rotate Twilio Account SID + Auth Token
- [ ] Rotate both OpenAI API keys (`sk-proj-...` + `sk-svcacct-...`)
- [ ] Rotate Resend API key (`re_724dU8u2_...`)
- [ ] Rotate Supabase service key
- [ ] Rotate GitHub + GitLab PATs in `.auto-claude/.env`
- [ ] Rotate Codecov token from `.github/workflows/SETUP_SECRETS.md` (line 13)
- [ ] **Test:** All old keys return 401/403; new keys work
- [ ] **Test:** Twilio test SMS sends successfully with new credentials

> **Note:** Credential rotation requires manual action by the developer in each provider's dashboard. Cannot be automated by code changes.

### 4.5.2 Remove secrets from git history
- [ ] Install `git-filter-repo` (`pip install git-filter-repo`)
- [ ] Purge `.env`, `.auto-claude/.env`, and any other secret blobs from all history
- [ ] Force push cleaned history to origin
- [ ] All contributors re-clone from clean repo
- [ ] **Test:** `git log -p -- .env` returns nothing
- [ ] **Test:** `git grep "sk-proj" $(git rev-list --all)` returns nothing
- [ ] **Test:** `git grep "sk-svcacct" $(git rev-list --all)` returns nothing

> **Note:** Git history cleanup requires manual action. Coordinate with all contributors before force-pushing.

### 4.5.3 Remove `.env` from app bundle
- [x] Remove `.env` from `pubspec.yaml` assets section (lines 201-203)
- [x] Change `.env.example` to contain only non-secret config (URLs, feature flags, placeholder keys)
- [x] Load secrets at runtime from Supabase Edge Function or `--dart-define` for build injection (SecureKeys pattern)
- [x] Verify `.env` is in `.gitignore` and effective
- [ ] **Test:** Build APK, extract assets, verify no `.env` in bundle: `unzip -l app-release.apk | grep env`
- [ ] **Test:** App starts correctly with `--dart-define` config

### 4.5.4 Fix cryptographic vulnerabilities
- [x] Fix PRNG seed in `lib/core/security/encryption_service.dart:394-399` — replace `List.generate(32, (i) => i)` with `Random.secure()` entropy source
- [x] Fix predictable IV in `lib/features/auth/infrastructure/security/secure_token_storage.dart:39-49` — generate random IV, store alongside key in SecureStorage
- [x] **Test:** Verify PRNG seed bytes are non-sequential (not 0,1,2,...,31)
- [x] **Test:** Verify Random.secure() generates unique values

### 4.5.5 Fix auth secrets handling
- [x] Remove SUPABASE_SERVICE_KEY fallback from `lib/core/config/app_config.dart:90-92` — fail loudly with StateError
- [x] Remove token storage from SharedPreferences in `lib/features/auth/data/datasources/auth_local_data_source.dart:192-222` — SecureStorage only
- [x] Change `lib/app/bootstrap.dart:105` from hardcoded `debug: true` to `debug: kDebugMode`
- [x] Guard `lib/config/test_config.dart` with kDebugMode — assertions prevent use in release builds
- [x] Add build-time assert to prevent mock auth data source in release builds — MockAuthRemoteDataSource checks kReleaseMode
- [x] **Test:** `AppConfig.supabaseAnonKey` throws StateError if key missing (no silent fallback to service key)
- [x] **Test:** `AppConfig.supabaseUrl` returns empty when not configured (graceful, no throw)

### 4.5.6 Fix AuthInterceptor security
- [x] Replace raw `Dio()` at `lib/core/api/interceptors/auth_interceptor.dart:90` with handler-provided Dio instance (pass `Dio` via constructor)
- [x] Add retry count guard to prevent infinite refresh loops on 401 — max 1 retry after token refresh
- [x] **Test:** AuthInterceptor requires Dio parameter via constructor
- [x] **Test:** Injected Dio instance preserves base URL

### 4.5.7 Reduce auth logging exposure
- [x] Remove PII (email addresses, session tokens, expiry timestamps) from `debugPrint` calls in `lib/features/auth/data/datasources/auth_remote_data_source_impl.dart`
- [x] Replace with obfuscated identifiers (`_obfuscateEmail()` helper) or remove entirely
- [x] Remove OTP codes from debug output
- [x] Remove session expiry timestamps from debug output
- [x] Fix PII in mock auth data source (`mock_auth_remote_data_source.dart`)
- [x] **Test:** Obfuscated email pattern hides real email — `j***@e***.com` not `john.doe@example.com`
- [x] **Test:** AppConfig dotenv access wrapped in try-catch (NotInitializedError safe)

## Definition of Done
- [ ] All old credentials revoked and new ones in use *(manual — 4.5.1)*
- [ ] `git grep` finds zero secrets in history *(manual — 4.5.2)*
- [x] `.env` not in app bundle (removed from pubspec.yaml assets)
- [x] PRNG uses proper entropy source (Random.secure())
- [x] IV is random per encryption call (stored in SecureStorage)
- [x] Tokens stored in SecureStorage only (not SharedPreferences)
- [x] Supabase initialized with `debug: kDebugMode`
- [x] AuthInterceptor retries are safe (max 1 retry, injected Dio)
- [x] No PII in debug logging (emails obfuscated, OTP/expiry removed)
- [x] All tests pass: `flutter test` (19 Sprint 4.5 tests pass)
- [ ] **Manual QA:** Build release, verify no secrets in APK/IPA assets
- [ ] **Security:** OWASP M1 (Platform Misuse) + M2 (Insecure Data Storage) checklist items resolved

## Verification
```bash
flutter analyze   # ✅ No errors in Sprint 4.5 files
flutter test      # ✅ All 19 Sprint 4.5 tests pass
# Extract APK assets and verify no .env
unzip -l build/app/outputs/flutter-apk/app-release.apk | grep env
# Git history clean
git log -p -- .env
git grep "sk-proj" $(git rev-list --all)
```

## Files Modified
| File | Change |
|------|--------|
| `pubspec.yaml` | Removed `.env` from assets |
| `lib/core/security/encryption_service.dart` | Fixed PRNG seed (Random.secure) |
| `lib/features/auth/infrastructure/security/secure_token_storage.dart` | Random IV stored in SecureStorage |
| `lib/core/config/app_config.dart` | Removed service key fallback, dotenv try-catch, StateError on missing key |
| `lib/app/bootstrap.dart` | `debug: kDebugMode` instead of `debug: true` |
| `lib/features/auth/data/datasources/auth_local_data_source.dart` | SecureStorage only for tokens |
| `lib/core/api/interceptors/auth_interceptor.dart` | Injected Dio, retry guard (max 1) |
| `lib/features/auth/data/datasources/auth_remote_data_source_impl.dart` | PII scrubbed from debugPrint |
| `lib/features/auth/data/datasources/mock_auth_remote_data_source.dart` | Release build guard, PII fix |
| `lib/config/test_config.dart` | kDebugMode guard with assertions |

## New Test Files
| File | Tests |
|------|-------|
| `test/core/security/sprint_45_security_test.dart` | PRNG uniqueness, seed non-sequential, AppConfig throws/empty, SecureKeys graceful, PII obfuscation |
| `test/core/api/auth_interceptor_test.dart` | Constructor injection, retry guard setup, AuthSession model |
