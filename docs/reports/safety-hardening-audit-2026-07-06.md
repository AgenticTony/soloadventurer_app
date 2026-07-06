# Safety Surface Hardening Audit — 2026-07-06

> Phase 0 / Story 0.2 (`docs/sprints/PHASE_0_BLOCKERS.md`) · execution-order step 7.
> **Safety-sensitive** (SOS / check-ins / meetups). Per root `CLAUDE.md`, safety never
> ships from automation alone — this pass is an audit + a bounded, tested fix; the
> remaining hardening is human/device-led (flagged below).

## What already exists (assessed — mature)

The `lib/features/safety` module is a full clean-architecture feature, not a stub:

- **SOS** — `trigger_sos_usecase` / `trigger_emergency_sos` → `SafetyRepository.triggerEmergencySOS`
  with `notifyContactIds`, location, battery. UI: `emergency_sos_screen`, `sos_button_widget`.
  Guard: `NoTrustedContactsException` when none configured. Tested (3 files).
- **Check-ins** — scheduled/manual creation, `check_in` providers/screens, scheduler,
  and a **`MissedCheckInDetector`** that flags overdue check-ins past a grace period and
  escalates to trusted contacts with last-known location. Tested (create/notifier/screen).
- **Trusted contacts** — add/edit/remove screens + providers; `receivesCheckIns` /
  `receivesEmergencyAlerts` flags. Tested (add/entity).
- **Meetup safety** — `meetup_checkin_providers`, meetup check-in repository, shared-meetup.

17 safety test files already exist.

## Finding — bug fixed (this PR)

**`MissedCheckInDetector` had no test**, and adding one surfaced a real defect:
`MissedCheckInDetectorImpl.dispose()` closed the status `StreamController` and *then*
called `_updateStatus(stopped)`, which adds an event to the now-closed controller →
throws **"Cannot add event after closing"** whenever the detector had been active
(the common case — the provider `initialize()`s it on creation). A throwing disposer can
surface as an unhandled error on teardown of a safety component.

**Fix:** emit the final `stopped` transition **before** closing the controller. Two-line
reorder in `dispose()`; no change to detection/escalation logic. New test:
`test/features/safety/infrastructure/services/missed_checkin_detector_impl_test.dart`
(9 tests) locks the safety-critical `isCheckInMissed` grace-period guard and the
init/dispose lifecycle.

## Story 0.2 status vs. acceptance criteria

| Criterion | State |
|---|---|
| SOS end-to-end (trigger → contacts + location → confirmation) | Implemented + unit-tested. **Real delivery** (push/SMS to a contact's device) needs device/integration validation — human-led. |
| Check-ins: scheduled + **missed-checkin detector validated** | Implemented; detector **now unit-tested** (was not); dispose bug fixed. |
| Meetup safety: pre-meetup nudge, live-location, check-in window — hardened + tested | Implemented; deeper hardening + tests remain. |
| Trusted contacts: add/edit/remove verified | Implemented + tested. |
| **Edge/load testing of all safety paths** | **Not done — inherently human/infra-led** (device matrix, background execution, notification delivery under load, permission-denied paths). |

## Remaining hardening — human/device-led (do NOT automate)

1. **Delivery validation** — confirm a trusted contact actually *receives* SOS / missed-check-in
   alerts on a real device (push + any SMS path), including app-backgrounded / killed states.
2. **Permission & degraded paths** — location-permission denied, no network, low battery:
   verify graceful escalation (the code already best-efforts these; needs device proof).
3. **Background execution** — the missed-check-in scan must run when the app is backgrounded;
   validate the scheduling mechanism on iOS + Android.
4. **Edge/load** — many concurrent check-ins/alerts; dedupe (the `alertSent` guard) under load.
5. **Escalation timing review** — the 5-minute grace period + escalation policy is a
   product/safety decision to confirm with the team.

These are launch-gating for the safety pillar and require human sign-off + real devices.
