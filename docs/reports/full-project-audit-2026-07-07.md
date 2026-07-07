# SoloAdventurer — Full Project Audit (2026-07-07)

**Scope:** code quality · architecture/SOLID · backend (Supabase schema/RLS/functions) · strategic direction (FOUNDATIONS.md / PRODUCT.md vs the 2025-26 market).
**Method:** four parallel audit agents (architecture, code quality, backend, market research) + independent cross-verification of every load-bearing claim by the lead session (greps, file reads, primary-source web checks). The backend agent was cut short by a platform safeguard; its scope was completed inline by the lead session. Market figures were spot-verified against primary sources (Timeleft ARR, Hostelworld results).

---

## Executive summary

The project is in **better architectural shape than most 213K-line codebases** — the Clean Architecture skeleton is real, the Phase A backend (meetups → outcomes → reputation) is genuinely well-engineered, and the strategy charter is directionally validated by current market data. But the audit found **two launch-blocking defects** neither the test suite nor CI would ever catch, plus a third already tracked:

| # | Launch blocker | Status |
|---|---|---|
| 1 | **Emergency SOS screen is wired to a backend that does not exist** (`api.soloadventurer.com` GraphQL) — the SOS button always fails | NEW — found by this audit |
| 2 | **`USING (true)` RLS policy on `profiles`** nullifies PII protection, block-lists, and women-only gating for direct table reads | NEW severity — root cause of the step-8 PII finding; already listed as follow-up #1 in session-handoff, now confirmed as the mechanism |
| 3 | Leaked credentials in git history | Known P0, Anthony-owned, rotation in progress |

**Scores** (evidence-based, justifications in body):

| Dimension | Score |
|---|---|
| Clean Architecture adherence | 6 / 10 |
| SOLID adherence | 5 / 10 |
| Code quality overall | 6.5 / 10 |
| Backend schema quality (Phase A era) | 8 / 10 |
| Backend security posture (as deployed) | 4 / 10 until blockers 1–2 fixed, then ~7.5 |
| Strategy (FOUNDATIONS/PRODUCT direction) | Right way forward, with 5 adjustments |

---

## 1. Launch blocker #1 — the phantom safety backend (P0)

Verified end-to-end by the lead session:

- `lib/core/providers/api_providers.dart:12,45` hardcodes `baseUrl: 'https://api.soloadventurer.com'` — a GraphQL host that does not exist (the real backend is Supabase).
- `lib/features/safety/data/repositories/safety_providers.dart:23-27` wires the production `safetyRepositoryProvider` to `SafetyRemoteDataSourceImpl(apiClient: apiClientProviderFull)` — the provider comment itself says *"Uses mock implementation for now, should be replaced with real implementation."*
- `emergency_sos_screen.dart:85` → `safetyProvider.triggerEmergencySOS` → `SafetyRepositoryImpl.triggerEmergencySOS` (`safety_repository_impl.dart:459-487`) → the phantom host. On network failure it **throws** — so the Emergency SOS button always errors.
- Consumers of the dead stack: `safety_provider.dart`, `missed_checkin_detector_impl.dart`, `safety_usecase_providers.dart`, plus `profile_repository_impl.dart:167-226`.
- A **real** Supabase SOS backend exists (`supabase/functions/trigger-sos` — proper JWT verification, input validation) but only the meetup-check-in path (`TriggerSOSUseCase` → `MeetupCheckinRepository`) reaches Supabase; the main SOS screen does not call it.
- **Bonus defect inside the real path:** `trigger-sos/index.ts:166` maps contact push tokens via `contacts.map(c => c.user_id || c.id)`, but the contacts query (line 100-105) never selects `user_id` — so the lookup falls back to trusted-contact **row ids**, and contact push notifications will never match a token. The in-app notification rows (line 143-152) are also inserted with `user_id: user.id` (the victim), not the contact's user id.

**Fix shape:** delete the GraphQL stack (`api_providers.dart` Dio/ApiClient, `SafetyRemoteDataSourceImpl`, `MockSafetyRemoteDataSource`), implement a Supabase-backed `SafetyRemoteDataSource`, and repair the `trigger-sos` contact-token join. **Safety-sensitive — requires human sign-off; also requires on-device validation (already flagged in `docs/reports/safety-hardening-audit-2026-07-06.md`).**

## 2. Launch blocker #2 — the `USING (true)` profiles policy (P0)

`supabase/migrations/20260404100000_profile_embeddings.sql:26-29`:

```sql
CREATE POLICY "profiles_embedding_select_authenticated" ON profiles
  FOR SELECT TO authenticated USING (true);
```

Postgres ORs permissive policies together and RLS cannot scope columns, so this one policy makes **every row of `profiles` readable by any authenticated user**, silently overriding the carefully built earlier policies:

- **PII**: `profiles` carries `email`, `phone`, `date_of_birth` (`20250109500000_create_profiles.sql:19-24`) → all readable by any logged-in user. This is the durable root cause of the PII leak the web audit (step 8) patched client-side.
- **Blocks**: `users_are_blocked()` checks in the 2025 policies are bypassed — a blocked user can still read the blocker's profile.
- **Women-only mode**: the server-side gating in `20260401150000_rls_policies.sql:44-69` (`profiles_read_potential_matches`) is a dead letter for direct table reads.

**Fix shape** (already sketched as handoff follow-up #1, now urgent): drop the `USING (true)` policy; serve embeddings via a scoped RPC or a dedicated table/view; add a public-safe `profiles` projection (column `REVOKE` on `email, phone, date_of_birth` or a view). **RLS change — requires human sign-off; cross-check the web app (it reads profiles via `getProfileByUsername`).**

## 3. Code quality (verified findings)

**Strengths:** consistent layering intent, doc comments nearly everywhere, clean secrets hygiene in client code (no hardcoded keys; `flutter_secure_storage`; anon-key hard-fail in `app_config.dart`), sensible parallelized bootstrap, `flutter analyze` = 419 issues / **0 errors** (matches tracked baseline; no new debt), 4,487-test green baseline with an honest signature-keyed known-failure gate, pgTAP tests on the reputation core.

**Defects and debt:**

- **Test coverage is mock-shaped exactly where the product lives (P1).** `MatchingRepositoryImpl` (933 lines: offline sync queue, women-only filtering) has zero repository tests — `test/matching/matching_flow_test.dart` asserts against its own 400-line hand-rolled mock. `MeetupCheckinRepositoryImpl` (the shipped Supabase check-in path) is untested. `emergency_sos_screen_test.dart` is 6 render-smoke tests with no trigger-behavior test — which is precisely why blocker #1 was never caught. Counter-example of the right standard: `missed_checkin_detector_impl_test.dart`.
- **Error swallowing at industrial scale (P1).** 1,219 `catch (e)` vs 244 `rethrow`. Every method of the (dead) safety data source discards the original error/stack; `matching_repository_impl.dart:86-147` drops remote failures with zero logging. Production incidents would be undiagnosable.
- **Shipped TODOs on gated paths (P2):** token refresh unimplemented (`token_manager_provider.dart:57` — deprecated provider, but still wired), `chat_provider.dart:486` `canEnableWomenOnlyMode` missing its premium check, login/signup `isLoading` hardcoded, Google Places data source is mock data behind a "PRODUCTION TODO".
- **Duplication (P2/P3):** 108 copy-pasted `on PostgrestException` mapping blocks across data sources (one shared `mapPostgrestError()` would delete hundreds of lines); byte-identical `_query`/`_mutation` in the safety data source.
- **Dependency debt (P2):** `flutter_secure_storage ^10.0.0-beta.4` (token vault on a beta), duplicate HTTP (`http`+`dio`), map (`google_maps_flutter`+`flutter_map`), mocking (`mockito`+`mocktail`), crypto (`encrypt`+`crypto`+`pointycastle`) stacks; `sqflite` alongside `drift`; `riverpod_lint` in dependencies.

## 4. Architecture / SOLID (verified findings)

**The skeleton holds.** Domain is nearly framework-pure (no `flutter/material` anywhere in domain; only ~10-11 files of 871 breach layer rules), data never imports presentation, GetIt is fully gone (docs claiming it are stale), DIP holds at most seams.

**Where it erodes:**

- **SRP failures concentrated in the risk core (top issue).** `safety_remote_data_source_impl.dart` — 1,723 lines, 37 public methods, ~6 responsibilities. `matching_repository_impl.dart` — 933 lines embedding **women-only mode with in-memory state** (`_womenOnlyModeEnabled`, line 815) and a private sync-queue engine duplicating the offline feature. `backup_service_impl.dart` hand-rolls crypto (lines 1051-1066) that belongs in `lib/core/security`. `operation_queue.dart` is a 991-line business engine inside a Riverpod notifier. ISP mirrors it: 36-method `SafetyRepository`/`MatchingRepository` interfaces.
- **Presentation → Supabase directly (P1-adjacent):** 12 presentation files reference `SupabaseClient`/`Supabase.instance`, including `safety/presentation/screens/meetup/share_meetup_screen.dart:286-290` (safety-critical UI inserting into `shared_meetups` straight from the widget) and `edit_profile_screen.dart:52-125`. Untestable, bypasses all three layers.
- **Domain contracts inheriting cross-feature data classes:** `profile/domain/repositories/profile_repository.dart:2` and `travel/domain/repositories/journal_repository.dart:1` both extend from `offline/data/repositories/offline_aware_repository.dart` — domain contracts depending on another feature's data layer.
- **Cross-feature entanglement with cycles:** ~120 cross-feature import edges; cycles `auth↔profile`, `auth↔home`, `travel↔onboarding`, `travel↔offline`. `offline` and `onboarding` act as undeclared shared infrastructure — promote them to `lib/core` or accept and document them as shared.
- **Error-handling fragmentation:** fpdart `Either` covers only **5 of 31** domain repository contracts; safety/matching/auth throw typed exceptions; some methods return nullables. Three regimes coexist; every new feature guesses.
- **Two structural vocabularies:** 7 of 20 features are non-conforming; five features have *both* `data/` and `infrastructure/`; `destination_discovery`/`travel` use hexagonal naming (`application`/`infrastructure`) alongside the standard split; `lib/features/core` duplicates `lib/core`.
- **Charter-vs-code gap:** `chat_moderation/domain/services/message_moderation_service.dart` (a) imports `supabase_flutter` in domain, and (b) documents **post-delivery** moderation ("message delivers immediately → scans in background"), contradicting FOUNDATIONS §5's required pre-delivery, at-creation moderation. The refactor is on the roadmap (Phase C) but the code comment enshrines the wrong shape.

## 5. Backend (Supabase) — beyond the blockers

**The Phase A work is the best code in the repo.** `20260630145537_phase_a_meetups_reputation.sql` + `20260706100000_phase_a_no_show_cancel.sql`: deny-all-writes RLS forcing mutations through SECURITY DEFINER RPCs, `search_path` pinned, execute revoked from `public`/`anon`, party checks on every RPC, mutual-confirmation completion gate, meetup-gated one-per-direction reviews, and the no-show attribution defect caught and fixed with a check constraint. This correctly implements the FOUNDATIONS L0 outcome store + bilateral meetup-gated reputation.

**Remaining backend findings:**

- **Unilateral `report_no_show` is a reputation-griefing vector (P2).** Either party can brand the other a no-show; guards (confirmed status, meetup time passed, no met-confirmations) narrow but don't close it, and there is no dispute path. Fine for v0.1; needs a v0.1.1 answer before reputation is publicly surfaced (step 10 makes this timely).
- **2025-era SECURITY DEFINER RPCs don't pin `search_path`** (e.g. `search_profiles`, `20250113000000_rpcs.sql:27`) — the Phase A convention should be backfilled in a hardening migration (P2).
- Edge functions checked (`trigger-sos`) verify JWTs properly and validate input; the contact-token defect is covered under blocker #1.
- Web-app cross-check: per the 2026-07-06 web audit (web PR #21), no service-role usage in web client code; the client-side PII narrowing is in place — blocker #2 remains the durable fix.

## 6. Strategy — is FOUNDATIONS/PRODUCT the right way forward?

**Verdict: yes — the charter is more right than wrong, and the market data says the alternative is worse.** Key evidence (spot-verified against primary sources):

- **The category FOUNDATIONS rejects is measurably declining.** Match Group FY2025 revenue flat with payers down ~5%; Tinder payers 9.1M→8.6M (price hikes masking decline); Bumble FY2025 revenue −9.9% with a $906.6M net loss. The engagement-monetization model is shedding payers every quarter; 78-79% of users report dating-app fatigue.
- **The outcome-optimized cohort is where the growth is.** Hinge (+25%, $689M, ~6.5% payer conversion — the outcome-positioned brand). **Timeleft: €18M ARR in 20 months, 150K monthly diners, 200+ cities** (verified) — literally running on meetups-completed as the unit. Life360: $489.5M (+32%) proves safety-as-subscription at scale.
- **But the moat claim is being falsified in real time.** Hostelworld has rebranded as "the world's social travel app" (verified: 3M social members, booking-gated city chats, FY2025 €93.8M) and Airbnb added social features to Experiences. Incumbents *can* copy the shallow version. What they can't easily retrofit is the **persistent, bilateral, meetup-gated reputation graph** — which means that primitive (Phase A, already shipped) is the actual moat and should be surfaced fast (step 10).
- **Honest sizing:** no one successfully charges for the social/trust layer itself in travel-social (Hostelworld gives it away; Couchsurfing died trying post-hoc); realistic payer conversion is 5-8%; this is structurally a **€10-50M ARR-class business** on subscription alone — real and defensible, not engagement-app scale. Life360, the safety champion, needed a zero-cold-start family graph and still added an ads/data leg.

**Five de-risking adjustments (thesis intact):**

1. **Adopt the Timeleft mechanic as the liquidity engine.** Scheduled, algorithm-formed small-group city meetups (one format, one weekly slot, pay upfront) as the *first* surface — it manufactures the north-star unit deterministically and hides thin liquidity. "Browse six verified people in Seoul tonight" (PRODUCT §3) exposes emptiness on day one; make it the *earned* surface once a city is liquid. Consistent with §6 guardrails and adds a proven per-event transaction revenue leg.
2. **Move Onfido to the point of value, not the front door.** Selfie-verify at signup; full ID check at first meetup booking or Pro. Price-shop the vendor (comparable checks run $0.30-$1.35 vs Onfido's enterprise pricing) — never pay $2+/check on unactivated signups.
3. **Transactions first, subscription as the margin layer.** Viator affiliate + event fees + venue partnerships will out-earn a 5-7% Pro conversion until well past 100K MAU (Hostelworld/Timeleft evidence).
4. **Women-first, not women-only, as the growth plan.** Keep women-only mode as the safety feature and marketing wedge; don't architect growth on a women-only network reaching liquidity — no precedent has (Tourlina pivoted to mixed; NomadHer ~300K downloads after 6 years). This matches FOUNDATIONS' actual wording (mode, not network) — just don't let it drift.
5. **Name Hostelworld the primary competitor and build against its gap** (its social layer is booking-gated and ephemeral; your persistent reputation is what it can't retrofit). Instrument **repeat-meetup rate** as the moat-proof metric.

## 7. Web app (SoloAdventurerWeb) — joint-project audit

*(Audited inline by the lead session after agent infrastructure became unavailable; every claim below verified by direct file reads. Not covered: web Jest/Cypress test-quality sampling and an exhaustive per-file quality pass — flagged for a follow-up when agent capacity returns.)*

**Mechanical quality is decent.** `tsconfig` is strict; the middleware follows the official @supabase/ssr pattern verbatim and correctly uses `getUser()` (not spoofable `getSession()`) for auth decisions (`src/lib/supabase/middleware.ts:35`); the step-8 PII fix in `getProfileByUsername` holds (non-PII column selection, `src/lib/api.ts:164`); PostHog is consent-gated with a charter-aligned event taxonomy (`src/lib/analytics/events.ts` — `install_click`, `share_click`, `referral_landing`, explicitly citing FOUNDATIONS §6).

**But the charter's web mission is ~90% unbuilt, and the legacy port is still what ships:**

1. **There is no public surface except the static landing page.** `src/middleware.ts:8-21` auth-walls *everything*: `/feed`, `/profile` (including `/profile/[username]`), `/trips`, `/discover`, `/chat`, `/waves`, `/dashboard`… The charter's core web deliverable — public, photo-rich, OG-previewed profile/trip/destination pages as the SEO/viral payload (FOUNDATIONS §7, PRODUCT §8) — does not exist. No `sitemap.ts`; root metadata is static text only.
2. **`/profile/[username]` is structurally un-SEO-able**: a `'use client'` component (`OtherUserProfile.tsx:1`) fetching via an auth-required browser client (`api.ts:55-64` throws without a session). **Step 10 (surface reputation_score on the "public" profile page) has an unstated prerequisite: make the page public + server-rendered first.** Doing step 10 without this ships reputation to logged-in users only — zero acquisition value.
3. **The broadcast feed still ships** (`src/app/(main)/feed/page.tsx` + `PostComposer`) — the exact surface FOUNDATIONS §7 names for refactor. Mitigating: it is **de-linked from primary nav** (LeftNav = Discover/Trips/Messages/Meetups/Saved, `LeftNav.tsx:82-88`) and the nav's feed alias routes to `/discover` — the pivot has visibly started. `/meetups` is a "Coming Soon" placeholder.
4. **The funnel measures legs that don't exist.** The landing page (`src/app/page.tsx`) sells "find your perfect travel companion" — the *rejected* matching-app framing — and its only CTAs are web signup/sign-in. No app-store links, no install CTA, no smart banner found on landing/nav/layout. `install_click` and `share_click` are defined but have nothing to fire them. PRODUCT §8's "web sends the world to mobile" currently sends it to a web signup form.
5. **Cross-repo hazard confirmed:** `api.ts:156` comments that RLS protects profile PII "server-side too" — currently **false** because of mobile-repo blocker #2 (`USING (true)`). The web app's only PII protection today is client-side column selection. The two repos share this fate; fix the policy in the mobile repo.
6. Minor: hand-rolled `Record<string, unknown>` casts instead of generated Supabase types (`api.ts:83-92,186-205`); data fetching is client-side `useEffect` throughout, including pages that should be RSC; stale docs (README "Facebook-inspired three-column layout", AWS/AppSync ADRs) contradict the charter — FOUNDATIONS §5 already lists them for disposal.

**Web verdict:** today the web app is a **cost, not an asset, to the FOUNDATIONS strategy** — it's a competent-quality auth-walled feature port with zero acquisition surface. The single highest-leverage web move is the public SSR profile/trip share page with `generateMetadata` + OG images + sitemap (which is also step 10's prerequisite), followed by an install CTA to make the already-built funnel taxonomy real.

## 8. Prioritized action list

| P | Action | Notes |
|---|---|---|
| P0 | Rotate/purge leaked credentials | Known, Anthony-owned, in progress |
| P0 | Replace phantom GraphQL safety stack with Supabase-backed data source; fix `trigger-sos` contact-token join | Safety-sensitive — human sign-off + on-device validation |
| P0 | Drop `USING (true)` profiles policy; scoped embedding access + public-safe profiles projection | RLS — human sign-off; cross-check web app |
| P1 | Real tests for `MatchingRepositoryImpl`, `MeetupCheckinRepositoryImpl`; behavior test for SOS trigger | The gap that let P0 #2 hide |
| P1 | Centralize error mapping (`mapPostgrestError()`); stop discarding stacks on sync paths | |
| P1 | Extract women-only mode out of `MatchingRepositoryImpl` into its own safety-owned module | Safety-sensitive |
| P1 | WEB: public SSR profile/trip share pages (`generateMetadata` + OG + sitemap) — prerequisite for step 10 and the entire acquisition mission | The highest-leverage web move |
| P2 | WEB: install CTA + store links on landing (makes `install_click` funnel real); retire or cohort-scope the `/feed` surface; fix landing copy ("travel companion" → trust-platform framing) | |
| P2 | Kill presentation→Supabase direct access (12 files, safety screens first) | |
| P2 | Backfill `search_path` on 2025-era SECURITY DEFINER RPCs; design no-show dispute path before step 10 surfaces reputation | |
| P2 | Ship premium check in `canEnableWomenOnlyMode`; wire login/signup loading; decide fate of deprecated token manager | |
| P3 | Pick one convention (`data/` vs `infrastructure/`), fold `lib/features/core` into `lib/core`, standardize on Either or typed exceptions, prune duplicate dependencies | Mechanical, do opportunistically |

**Strategy actions:** adopt adjustments 1-5 above as FOUNDATIONS amendments (they fit the charter's own guardrails); prioritize step 10 (surface reputation) as the moat move.

---

*Method note: every P0/P1 code claim in this report was independently re-verified in the source by the lead session (file:line cites throughout). Market figures verified against primary sources 2026-07-07: timfrin.substack.com / arr.club (Timeleft), hostelworldgroup.com press release & 2025 preliminary results (Hostelworld); remaining figures per the strategy agent's cited sources (Match Group IR, Bumble 8-K, businessofapps, Life360 IR, et al.).*
