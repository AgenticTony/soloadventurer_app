# Phase 0 — Launch Blockers

> FOUNDATIONS §9 (Phase 0) · Repo: mobile (primary + shared backend) · Safety-sensitive: **YES** (most stories)
> Status: active (`active_sprint` in `.claude/state/sprint-progress.json`). Most stories are `safety`/`needs_human` → the loop flags and stops; this phase is **human-driven**.

## Goal
Remove the hard launch blockers before any growth work: purge the leaked credentials, harden the safety surface to production grade, and stand up analytics + the north-star so we can measure what matters.

> **Updated 2026-07-07:** the full project audit (`docs/reports/full-project-audit-2026-07-07.md`)
> found two NEW launch blockers — the phantom SOS backend (Story 0.4) and the `USING (true)`
> profiles RLS policy (Story 0.5). Both added below; both ⚠ human sign-off.

## Scope
**IN:** credential rotation + history purge; safety hardening (SOS, check-ins, meetup safety) to production; product analytics; lock `meetups_completed` as the north-star event; **audit P0s: real Supabase safety backend (0.4) + profiles RLS repair (0.5)**.
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
> Audit 2026-07-06 (step 7): the safety module is already mature (SOS, check-ins, missed-check-in detector, trusted contacts, meetup check-ins — 17 test files). See `docs/reports/safety-hardening-audit-2026-07-06.md`. Remaining items are human/device-led.
- [x] SOS: end-to-end (trigger → trusted contacts + live location → confirmation) — **implemented + unit-tested**; real on-device delivery validation is human-led (see report).
- [x] Check-ins: scheduled + missed-checkin detector validated — detector **now unit-tested** (was untested); **fixed a `dispose()` bug** (added to a closed StreamController → threw when active).
- [ ] Meetup safety: pre-meetup risk nudge, live-location share, check-in window — implemented; **deeper hardening + tests remain** (human-led).
- [x] Trusted contacts: add/edit/remove flow verified — implemented + tested.
- [ ] Edge/load testing of all safety paths — **NOT done; inherently human/device/infra-led** (device matrix, background execution, notification delivery under load, permission-denied paths). Launch-gating for the safety pillar; needs sign-off + real devices.

### Story 0.3 — Analytics + north-star instrumentation  [needs_human: true]
- [x] Pick analytics provider (docs-grounded) — **PostHog** (product analytics, EU Cloud) + **Sentry** for errors (decided 2026-07-06; see `docs/analytics-v0.1.md`)
- [x] **Lock** `meetups_completed` as the north-star — **RECONCILED**: sourced from **`meetup_outcomes.outcome = 'completed'`** (the Phase A mutual-confirmation atomic unit), **not** `meetup_checkins` (that predated Phase A). Event `meetup_completed` + typed `trackMeetupCompleted` helper shipped; authoritative server-side emitter deferred (see below).
- [x] Privacy/consent gate on analytics (GDPR — opt-in) — SDK starts `optOut`; `ConsentGatedAnalyticsService` blocks all events until consent; persisted flag + Riverpod controller; no PII in events (`beforeSend` scrub). Tests green.
- [ ] Instrument D1/D7/D30 cohort retention — **PostHog dashboard config, not app code** (retention insight from `identify` + events); documented in `docs/analytics-v0.1.md`.

**Deferred follow-ups (tracked in `docs/analytics-v0.1.md`):** (a) server-side authoritative north-star — DB trigger on `meetup_outcomes` insert → PostHog (the client helper is interim; no Dart caller of `complete_meetup` exists yet — Phase A shipped backend-only); (b) Sentry runtime `init` (dep present, not yet initialized); (c) wire funnel event call-sites into UI as each flow is touched.

### Story 0.4 — Replace the phantom safety backend  [safety: true] [needs_human: true]
> **Audit 2026-07-07 (P0 — launch blocker).** The Emergency SOS screen is wired to a GraphQL
> backend that does not exist: `api_providers.dart:45` hardcodes `https://api.soloadventurer.com`;
> `safety_providers.dart:23` injects `SafetyRemoteDataSourceImpl(apiClient: ...)` into the
> production `safetyRepositoryProvider`; `safety_repository_impl.dart:459` throws on the
> inevitable network failure — **the SOS button always errors.** A real, JWT-authenticated
> Supabase `trigger-sos` edge function exists but only the meetup-check-in path reaches it.
> Report: `docs/reports/full-project-audit-2026-07-07.md` §1.
- [ ] Implement a Supabase-backed `SafetyRemoteDataSource` (SOS via `trigger-sos` edge fn; check-ins / trusted contacts / location via the existing tables + RLS) — docs-grounded (supabase.com/docs)
- [ ] Rewire `safetyRepositoryProvider` to the Supabase data source; delete the GraphQL stack (`SafetyRemoteDataSourceImpl`, `MockSafetyRemoteDataSource` in lib/, the phantom `dioProvider`/`apiClientProviderFull` base URL) once no consumer remains
- [ ] Fix `trigger-sos/index.ts:166` contact push-token join — `contacts.map(c => c.user_id || c.id)` falls back to trusted-contact row ids because the query never selects `user_id`; contact pushes can never match a token
- [ ] Fix `trigger-sos` in-app notification rows — inserted with `user_id: user.id` (the victim) instead of each contact's user id
- [ ] Behavior test: tapping SOS (past the countdown) reaches the Supabase path and surfaces success/failure honestly — no silent degradation
- [ ] Audit the other consumers of the dead stack (`profile_repository_impl.dart:167-226`, `missed_checkin_detector_impl.dart`) and migrate or delete
- [ ] 👤 On-device validation of SOS → trusted-contact delivery (ties into Story 0.2's device-led item)

### Story 0.5 — Profiles RLS: drop `USING (true)` + public-safe projection  [safety: true] [needs_human: true]
> **Audit 2026-07-07 (P0 — launch blocker).** `20260404100000_profile_embeddings.sql:26` added
> `USING (true)` FOR SELECT on `profiles`. Permissive policies OR together, so any authenticated
> user can read EVERY profile row — `email`, `phone`, `date_of_birth` — and the block-list and
> **women-only discovery gating** in `20260401150000_rls_policies.sql` are dead letters for direct
> reads. Durable fix for the step-8 web PII finding. **Cross-check the web app before merging**
> (web `getProfileByUsername` + types). Report: audit §2.
- [ ] Migration: drop policy `profiles_embedding_select_authenticated`
- [ ] Serve match-embedding reads via a scoped path instead (SECURITY DEFINER RPC with `set search_path`, or a dedicated non-PII view) — `find_semantic_matches` must keep working
- [ ] Public-safe `profiles` projection: column-level `REVOKE` on `email, phone, date_of_birth` for `authenticated` (own-row access via RPC/view), or a `public_profiles` view — per `docs/reports/web-privacy-rls-audit-2026-07-06.md`
- [ ] pgTAP: another authed user CANNOT read email/phone/DOB; blocked users CANNOT read the blocker's row; women-only gating holds on direct table reads
- [ ] Cross-app verification: web `getProfileByUsername` / `searchUsers` and mobile profile reads still work (anon key, non-PII columns)
- [ ] Correct the stale comment in web `src/lib/api.ts:156` ("RLS enforces this server-side too") once it becomes true

## Definition of Done / Acceptance Criteria
- [ ] No secrets in history (scan clean); all keys rotated and old ones revoked
- [ ] Safety flows pass end-to-end + integration tests green
- [ ] `meetups_completed` event firing in analytics; cohort dashboard live
- [ ] `flutter analyze` errors-only clean; test baseline not regressed
- [ ] **SOS reaches Supabase end-to-end; zero references to `api.soloadventurer.com` remain in lib/** (audit P0 #1)
- [ ] **pgTAP proves profiles PII/block/women-only gating holds for direct table reads** (audit P0 #2)

## Dependencies
None — this is first. Unblocks Phase A. (The loop will stop on these `safety`/`needs_human` stories; a human flips `active_sprint` to `PHASE_A_LAY_THE_SPINE` once unblocked.)
