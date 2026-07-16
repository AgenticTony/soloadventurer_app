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
- [x] Confirm rotation status of the Supabase **service-role key** (bypasses RLS for both apps) — **CONFIRMED DONE 2026-07-15**; the old leaked key is dead (`docs/reports/prod-db-reconciliation-plan-2026-07-15.md`).
- [x] Rotate AWS / OpenAI / Resend / Twilio / GitHub+GitLab PATs — **confirmed by Anthony 2026-07-16.**
- [ ] Purge secrets from git history (~561 commits) — `git filter-repo` or BFG; coordinated force-push
- [ ] Verify clean: `gitleaks` / GitGuardian scan reports zero findings
- [x] Revoke old keys only after rotation confirmed live — **confirmed by Anthony 2026-07-16**; old keys are revoked at the providers.

> **Status 2026-07-16: rotation + revocation are DONE; the history purge is not.** The exposure is
> now materially lower — the leaked keys in history are **dead credentials**, so this stopped being
> a `db push` blocker (see EXECUTION_ORDER). What remains is real but lower-severity: ~561 commits
> still contain the old secrets, so box 4 **cannot** go green until box 3 does — a scan of history
> will keep finding them. CI's GitGuardian check scans the **diff**, not history; do not read a green
> PR check as "history is clean". Both remaining boxes are 👤 Anthony's (coordinated force-push).

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
- [x] Fix `trigger-sos/index.ts:166` contact push-token join — `contacts.map(c => c.user_id || c.id)` falls back to trusted-contact row ids because the query never selects `user_id`; contact pushes can never match a token — **PR #25**: now selects `contact_user_id` and pushes via `.in('user_id', contactUserIds)`.
- [x] Fix `trigger-sos` in-app notification rows — inserted with `user_id: user.id` (the victim) instead of each contact's user id — **PR #25**: `user_id: contactUserId`, `actor_id: user.id`.
- [x] Behavior test: tapping SOS (past the countdown) reaches the Supabase path and surfaces success/failure honestly — no silent degradation — `test/features/safety/data/datasources/sos_trigger_edge_function_test.dart`.
- [ ] Audit the other consumers of the dead stack (`profile_repository_impl.dart:167-226`, `missed_checkin_detector_impl.dart`) and migrate or delete
- [ ] 👤 On-device validation of SOS → trusted-contact delivery (ties into Story 0.2's device-led item)

> **Status 2026-07-16 — the BLOCKER is cleared, but the STORY is 3/7. Do not read "SOS works" as "0.4 done".**
> **What shipped (PRs #23 + #25, merged + deployed):** the SOS button now reaches the real
> `trigger-sos` edge function and reports success/failure honestly, and the two edge-function
> targeting defects are fixed. The audit's actual P0 — _"the SOS button always errors"_ — is resolved.
> **What did NOT ship:** the phantom stack is still here. PR #23 patched `triggerEmergencySOS` inside
> the **existing** `SafetyRemoteDataSourceImpl` rather than replacing the data source, so:
> - `lib/` still holds **8 references to `api.soloadventurer.com`** (`core/config/app_config.dart`,
>   `core/providers/api_providers.dart`, `features/core/config/app_config.dart`) — the DoD demands **zero**;
> - that same class still makes **4 `_apiClient` calls** for check-ins / trusted contacts / location
>   (only SOS was migrated — its own docstring defers the rest to PHASE_H);
> - `MockSafetyRemoteDataSource` is still shipped in `lib/`, not `test/`;
> - `profile_repository_impl.dart:167` still POSTs to `/graphql` on the dead host (box 6).
>
> **Consequence:** boxes 1, 2 and 6 are PHASE_H work (H.4 "no Supabase in UI" / dead-stack removal).
> The remaining safety risk is **not** "SOS fails" — it's that a live-looking dead HTTP stack sits
> next to the safety path and can be wired to by accident. 👤 On-device validation (box 7) is still
> the launch gate.

### Story 0.5 — Profiles RLS: drop `USING (true)` + public-safe projection  [safety: true] [needs_human: true]
> **Audit 2026-07-07 (P0 — launch blocker).** `20260404100000_profile_embeddings.sql:26` added
> `USING (true)` FOR SELECT on `profiles`. Permissive policies OR together, so any authenticated
> user can read EVERY profile row — `email`, `phone`, `date_of_birth` — and the block-list and
> **women-only discovery gating** in `20260401150000_rls_policies.sql` are dead letters for direct
> reads. Durable fix for the step-8 web PII finding. **Cross-check the web app before merging**
> (web `getProfileByUsername` + types). Report: audit §2.
- [x] Migration: drop policy `profiles_embedding_select_authenticated` — `20260708090000_profiles_rls_repair.sql:162`. **Live in prod** (2026-07-15 repave).
- [x] Serve match-embedding reads via a scoped path instead (SECURITY DEFINER RPC with `set search_path`, or a dedicated non-PII view) — `find_semantic_matches` must keep working — recreated `SECURITY DEFINER` / `SET search_path = public, extensions` with in-function guards.
- [x] Public-safe `profiles` projection: column-level `REVOKE` on `email, phone, date_of_birth` for `authenticated` (own-row access via RPC/view), or a `public_profiles` view — per `docs/reports/web-privacy-rls-audit-2026-07-06.md` — `20260708093000`: table-level SELECT revoked from `authenticated`+`anon`, re-granted per non-PII column. **Verified live:** `authenticated` can read `username`, cannot read `email`.
- [ ] pgTAP: another authed user CANNOT read email/phone/DOB; blocked users CANNOT read the blocker's row; women-only gating holds on direct table reads
- [x] Cross-app verification: web `getProfileByUsername` / `searchUsers` and mobile profile reads still work (anon key, non-PII columns) — mobile PR #22 + web PR #25; zero `select('*')` on `profiles` remain in web `src/lib/api.ts`; both suites green.
- [x] Correct the stale comment in web `src/lib/api.ts:156` ("RLS enforces this server-side too") — **no edit needed: the comment became TRUE.** RLS + the column REVOKEs now genuinely enforce it server-side, which is exactly the condition the box was waiting on.

> **⚠️ Status 2026-07-16 — 5/6. The one open box is the PROOF, and it has a real hole.**
> The PII half is proven: `profiles_pii_column_privileges.test.sql` (8 assertions) +
> `profiles_rls_repair.test.sql` (12) cover email/phone/DOB and the policy drop.
> **Neither file — nor any pgTAP file — asserts anything about the block-list or women-only gating.**
> A grep for `block` / `blocked` / `women_only` / `gender` across `supabase/tests/database/` returns
> **zero hits**.
>
> That is the precise claim the audit's P0 #2 rested on: `USING (true)` made _"the block-list and
> **women-only discovery gating** dead letters for direct reads"_. Dropping the policy is the
> necessary fix, but **nothing proves the gating actually holds now** — the `USING (true)` policy was
> masking those code paths, so they have never been exercised against a real table read. They are
> currently **assumed** correct.
>
> **Why this is load-bearing, not pedantry:** women-only mode is a core strategy and safety-sensitive
> per `CLAUDE.md`, and **execution-order step 10 makes profiles public + SSR on top of this exact
> schema**. Shipping public profile pages while block/women-only gating is unproven is the risk the
> DoD box exists to prevent. **Recommend: this box gates step 10, not just Phase 0.**

## Definition of Done / Acceptance Criteria
- [ ] No secrets in history (scan clean); all keys rotated and old ones revoked — **keys rotated + revoked ✅ (2026-07-16); history NOT purged** → blocked on Story 0.1 box 3.
- [ ] Safety flows pass end-to-end + integration tests green — **integration tests green in CI ✅; "end-to-end" (real device → real contact delivery) NOT done** → 👤 Story 0.2 box 5 + Story 0.4 box 7.
- [ ] `meetups_completed` event firing in analytics; cohort dashboard live — **cohort dashboard not configured** (Story 0.3 box 4, confirmed 2026-07-16).
- [x] `flutter analyze` errors-only clean; test baseline not regressed — green on `main` (Analyze & Format, Unit & Widget Tests, Coverage Gate 80%, Integration Tests all pass).
- [ ] **SOS reaches Supabase end-to-end; zero references to `api.soloadventurer.com` remain in lib/** (audit P0 #1) — **half met:** SOS reaches Supabase ✅, but **8 references remain in `lib/`** → Story 0.4 boxes 1/2/6, deferred to PHASE_H.
- [ ] **pgTAP proves profiles PII/block/women-only gating holds for direct table reads** (audit P0 #2) — **PII proven ✅; block + women-only have ZERO pgTAP coverage** → Story 0.5 box 4. **This one gates execution-order step 10.**

## Phase 0 status at a glance (2026-07-16)

| Story                        | State | Note                                                                    |
| ---------------------------- | ----- | ----------------------------------------------------------------------- |
| 0.1 Credentials              | 3/5   | Rotated + revoked ✅. History purge open (👤). Box 4 blocked on box 3.  |
| 0.2 Safety surface           | 3/5   | Device/load-led items open (👤) — launch-gating.                        |
| 0.3 Analytics + north-star   | 3/4   | Cohort retention dashboard not configured (PostHog UI, 👤).             |
| 0.4 Phantom safety backend   | 3/7   | **Blocker cleared** (SOS works). Dead-stack removal → PHASE_H.          |
| 0.5 Profiles RLS             | 5/6   | **Live in prod.** Missing: block + women-only pgTAP proof.              |

**Phase 0 is NOT done.** The two audit P0 *blockers* are cleared — the SOS button works and the
`USING (true)` leak is dead in production — but four stories carry real remainders. The two that
gate other work: **0.5 box 4** (block/women-only proof → gates step 10's public profiles) and
**0.4 boxes 1/2/6** (dead-stack removal → PHASE_H). The rest are 👤 Anthony's: history purge,
on-device safety validation, PostHog dashboard.

## Dependencies
None — this is first. Unblocks Phase A. (The loop will stop on these `safety`/`needs_human` stories; a human flips `active_sprint` to `PHASE_A_LAY_THE_SPINE` once unblocked.)
