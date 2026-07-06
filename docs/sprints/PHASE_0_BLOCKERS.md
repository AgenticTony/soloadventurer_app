# Phase 0 — Launch Blockers

> FOUNDATIONS §9 (Phase 0) · Repo: mobile (primary + shared backend) · Safety-sensitive: **YES** (most stories)
> Status: active (`active_sprint` in `.claude/state/sprint-progress.json`). Most stories are `safety`/`needs_human` → the loop flags and stops; this phase is **human-driven**.

## Goal
Remove the hard launch blockers before any growth work: purge the leaked credentials, harden the safety surface to production grade, and stand up analytics + the north-star so we can measure what matters.

## Scope
**IN:** credential rotation + history purge; safety hardening (SOS, check-ins, meetup safety) to production; product analytics; lock `meetups_completed` as the north-star event.
**OUT:** new product features (Phase A+); acquisition/growth (web lane).
**Guardrails (FOUNDATIONS §6):** safety is the substrate, not a feature page; no engagement proxy as a north star.

## Stories

### Story 0.1 — Purge leaked credentials + rotate keys  [needs_human: true] [safety: true]
- [ ] Confirm rotation status of the Supabase **service-role key** (bypasses RLS for both apps)
- [ ] Rotate AWS / OpenAI / Resend / Twilio / GitHub+GitLab PATs
- [ ] Purge secrets from git history (~561 commits) — `git filter-repo` or BFG; coordinated force-push
- [ ] Verify clean: `gitleaks` / GitGuardian scan reports zero findings
- [ ] Revoke old keys only after rotation confirmed live

### Story 0.2 — Production-grade safety surface  [safety: true]
- [ ] SOS: end-to-end (trigger → trusted contacts + live location → confirmation)
- [ ] Check-ins: scheduled + missed-checkin detector validated
- [ ] Meetup safety: pre-meetup risk nudge, live-location share, check-in window — hardened + tested
- [ ] Trusted contacts: add/edit/remove flow verified
- [ ] Edge/load testing of all safety paths

### Story 0.3 — Analytics + north-star instrumentation  [needs_human: true]
- [x] Pick analytics provider (docs-grounded) — **PostHog** (product analytics, EU Cloud) + **Sentry** for errors (decided 2026-07-06; see `docs/analytics-v0.1.md`)
- [x] **Lock** `meetups_completed` as the north-star — **RECONCILED**: sourced from **`meetup_outcomes.outcome = 'completed'`** (the Phase A mutual-confirmation atomic unit), **not** `meetup_checkins` (that predated Phase A). Event `meetup_completed` + typed `trackMeetupCompleted` helper shipped; authoritative server-side emitter deferred (see below).
- [x] Privacy/consent gate on analytics (GDPR — opt-in) — SDK starts `optOut`; `ConsentGatedAnalyticsService` blocks all events until consent; persisted flag + Riverpod controller; no PII in events (`beforeSend` scrub). Tests green.
- [ ] Instrument D1/D7/D30 cohort retention — **PostHog dashboard config, not app code** (retention insight from `identify` + events); documented in `docs/analytics-v0.1.md`.

**Deferred follow-ups (tracked in `docs/analytics-v0.1.md`):** (a) server-side authoritative north-star — DB trigger on `meetup_outcomes` insert → PostHog (the client helper is interim; no Dart caller of `complete_meetup` exists yet — Phase A shipped backend-only); (b) Sentry runtime `init` (dep present, not yet initialized); (c) wire funnel event call-sites into UI as each flow is touched.

## Definition of Done / Acceptance Criteria
- [ ] No secrets in history (scan clean); all keys rotated and old ones revoked
- [ ] Safety flows pass end-to-end + integration tests green
- [ ] `meetups_completed` event firing in analytics; cohort dashboard live
- [ ] `flutter analyze` errors-only clean; test baseline not regressed

## Dependencies
None — this is first. Unblocks Phase A. (The loop will stop on these `safety`/`needs_human` stories; a human flips `active_sprint` to `PHASE_A_LAY_THE_SPINE` once unblocked.)
