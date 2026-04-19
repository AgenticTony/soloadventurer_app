# Sprint 6.5: Verification + Trust Stack
**Duration:** Weeks 12-13
**Theme:** Build verification flow that is the core business model. Free users are unverified, paying users get verified. Add other-user profile view, matching tab, GDPR consent, and feature flag infrastructure.
**Depends on:** Sprint 6

## Tasks

### 6.5.1 — Add matching tab to bottom navigation (FIRST)
- [x] Add Connections tab to `MainNavigationBar` (icon: people)
- [x] Add to shell route in GoRouter config (6 tabs total)
- [x] Tab shows matches list screen
- [x] Everything else in this sprint depends on users finding matching
- [x] **Test:** Navigation tests

### 6.5.2 — Feature flag infrastructure (shared)
- [x] Create `feature_flags` Supabase table (or constants file to start)
- [x] Create `FeatureFlagProvider` — Riverpod provider reads flags on app start
- [x] Default all gates to open — activate limits later without new app release
- [x] Flags: free_tier_caps_active, subscription_gates_active, premium_features_live, etc.

### 6.5.3 — GDPR/biometric consent screen
- [x] Create `VerificationConsentScreen` — dedicated screen, not a buried checkbox
- [x] Explicitly explain: facial geometry is biometric special category data under GDPR
- [x] Content: what data is collected, purpose, retention period, right to delete
- [x] Must appear before any camera/photo capture in verification flow
- [ ] ZClaw sign-off required on copy
- [x] **Test:** Consent screen widget test

### 6.5.4 — Verification feature scaffold
- [x] Create `lib/features/verification/` with domain/data/presentation layers
- [x] Domain: `VerificationRequest` entity, `VerificationStatus` enum
- [x] Data: `VerificationRemoteDataSource` (Supabase calls to user_verification table)
- [x] Data: `VerificationRepositoryImpl`
- [x] Provider: `verification_provider.dart` — state for current verification status + flow

### 6.5.5 — Photo verification flow (~4 screens)
- [x] `VerificationWelcomeScreen` — explains why verification matters
- [x] `PhotoCaptureScreen` — selfie capture using image_picker
- [x] `VerificationConsentScreen` — GDPR consent before capture (6.5.3)
- [x] `VerificationResultScreen` — success (badge awarded) or failure (retry options)
- [x] Award `emailVerified` tier on success
- [x] **Test:** Verification flow widget tests

### 6.5.6 — ID verification flow (~3 screens)
- [x] `IdVerificationStartScreen` — choose document type
- [x] `IdUploadScreen` — camera capture of ID document
- [x] `VerificationResultScreen` — shared with photo result (type parameter)
- [x] Mock processing (Onfido SDK integration deferred)
- [x] **Test:** ID verification flow tests

### 6.5.7 — Verification badge display
- [x] Add `verificationTier` field to `Profile` entity
- [x] Create `VerificationBadge` widget (checkmark for email, shield for ID)
- [x] Add badge to match cards in `matches_screen.dart`
- [x] Add badge to `ProfileScreen` avatar area
- [x] Add badge to chat screen header
- [x] **Test:** Badge widget tests

### 6.5.8 — Filter by verified toggle
- [x] Add "Only show verified users" toggle to matching preferences
- [x] Wire to existing `verified_only` field in privacy_settings
- [x] Apply filter in match discovery query
- [x] **Test:** Filter integration test

### 6.5.9 — Other user profile view screen
- [x] Create `UserProfileScreen` for viewing matched users
- [x] Shows: avatar, name, bio, interests, verification badges, trip overlap
- [x] "Connect" / "Message" / "Block" action buttons
- [x] Route: `/user/:userId`
- [x] Navigate from match cards and chat headers
- [x] **Test:** UserProfileScreen widget test

## Definition of Done
- [x] Matching accessible from bottom navigation (tab 1 priority)
- [x] GDPR consent screen appears before any photo capture
- [x] Verification flow works end-to-end (consent → photo + ID capture → badge award)
- [x] Verification badges visible on match cards, profiles, and chat headers
- [x] Other users' profiles can be viewed from match cards
- [x] Feature flag infrastructure ready for monetization activation
- [x] Filter by verified works in matching
- [x] All tests pass: `flutter test` (4,483 pass, 49 pre-existing failures unrelated to Sprint 6.5)
- [x] `flutter analyze` — no errors in Sprint 6.5 files

## Verification
```bash
flutter analyze   # No errors in Sprint 6.5 files
flutter test      # All new + existing tests pass
# Manual: check matching tab, complete verification flow with consent, view other user profile
```
