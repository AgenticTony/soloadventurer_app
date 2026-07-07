# Phase H — Audit Hardening (mobile)

> Source: `docs/reports/full-project-audit-2026-07-07.md` · Repo: mobile · Safety-sensitive: **partially** (per-story flags)
> Status: eligible after PHASE_0 Stories 0.4/0.5 ship. Runs **in parallel with web Stage A work** (no shared tables with the web lane except where flagged).
> **Purpose: raise the audit scores** — Clean Architecture 6→8+, SOLID 5→8, code quality 6.5→8.5+, backend security 4→8 (with Phase 0 P0s). Each story names the score it lifts.

## Goal
Pay down the audit's P1/P2 findings so the product core (matching, safety, meetups) is tested, diagnosable, and structurally sound before the AI flywheel (Phase B) builds on top of it.

## Scope
**IN:** test coverage on the product core; error-handling spine; women-only-mode extraction; presentation→Supabase removal; SECURITY DEFINER hardening; no-show dispute design; dependency + convention cleanup; shipped-TODO closure; Flutter upgrade.
**OUT:** new features; anything Phase B+ (ranker, agents); web-lane work (own phase docs).
**Guardrails (FOUNDATIONS §6/§10):** women-only mode is core strategy — its extraction story is safety-gated; never weaken tests to pass; green count never drops below `test_baseline`.

## Stories

### Story H.1 — Test the product core (audit P1 · lifts code quality 6.5→7.5)
> The gap that hid launch-blocker #1: `MatchingRepositoryImpl` (933 lines — offline sync queue,
> women-only filtering) has zero repository tests; `matching_flow_test.dart` asserts against its
> own 400-line hand-rolled mock; `MeetupCheckinRepositoryImpl` (the shipped Supabase check-in
> path) is untested; `emergency_sos_screen_test.dart` is render-smoke only. Model on the standard
> already in-repo: `missed_checkin_detector_impl_test.dart`.
- [ ] `MatchingRepositoryImpl` repository tests: offline/online branch behavior, sync-queue enqueue/flush/retry, women-only filter application, error paths (mock the data sources, test the real repo)
- [ ] `MeetupCheckinRepositoryImpl` + `MeetupCheckinRemoteDataSourceImpl` tests (Supabase client mocked at the boundary)
- [ ] SOS trigger behavior test: countdown-confirmed tap → repository call → success and failure surfaced to the user (complements Story 0.4's proving test)
- [ ] Add the missing `share_meetup` flow test once H.4 moves its Supabase call out of the widget
- [ ] Baseline: new tests all green; `test_baseline` raised accordingly in `sprint-progress.json`

### Story H.2 — Error-handling spine (audit P1 · lifts code quality + SOLID)
> 1,219 `catch (e)` vs 244 `rethrow`; the safety data source discards every original error/stack;
> `matching_repository_impl.dart:86-147` drops remote failures with zero logging. 108 copy-pasted
> `on PostgrestException` mapping blocks.
- [ ] One shared `mapPostgrestError()` (core) — replace the 108 copy-pasted blocks incrementally (top 5 data sources first: journal_optimized 47, matching 22, meetup_checkin 12, tag, social)
- [ ] Catch-alls on sync/safety paths keep cause + stack (`Error.throwWithStackTrace` or logger with stack) — zero silent drops in safety + matching repos
- [ ] Replace surviving `print()` in production paths (`error_handler.dart:271`, `app_start_tracker.dart:141,150`, `logging_service_impl.dart:15-17`) with `AppLogger`
- [ ] Initialize Sentry at runtime (dep present, never `init`-ed — deferred follow-up from Story 0.3) and add breadcrumbs on repo-level catches
- [ ] Decide + document the error-handling convention going forward (Either vs typed exceptions — see H.6); new code follows it

### Story H.3 — Extract women-only mode out of the matching repo  [safety: true] [needs_human: true] (lifts SOLID 5→6.5)
> The audit's worst SRP finding: women-only mode lives inside the 933-line `MatchingRepositoryImpl`
> with **in-memory state** (`_womenOnlyModeEnabled`, line 815) — a core safety control that can
> silently desync from the server. Women-only mode is core strategy (root CLAUDE.md), not a
> matching detail.
- [ ] New `women_only` module under `features/safety/` (or `features/matching/domain` split) owning enable/disable/status — server-authoritative, no in-memory flag as source of truth
- [ ] `chat_provider.dart:486` `canEnableWomenOnlyMode` premium check implemented (the shipped TODO)
- [ ] All read paths (matching, chat, discovery) consume the one provider; RLS remains the enforcement backstop (verified by Story 0.5's pgTAP)
- [ ] Tests: mode flip round-trips through the server; gating respected offline (fail-closed, not fail-open)

### Story H.4 — No Supabase in presentation (audit P1-adjacent · lifts Clean Architecture 6→7.5)
> 12 presentation files call `SupabaseClient`/`Supabase.instance` directly — including the
> safety-critical `share_meetup_screen.dart:286-290` (inserts into `shared_meetups` from the
> widget) and `edit_profile_screen.dart:52-125`.
- [ ] `share_meetup_screen` → repository + use-case (safety surface first)  [safety: true]
- [ ] `edit_profile_screen` auth/update calls → profile repository
- [ ] Remaining 10 files: route through existing repos or thin new data sources; zero `package:supabase_flutter` imports left under `presentation/` (add an `import_lint`/CI grep gate so it stays zero)
- [ ] Same gate for `domain/`: fix the 11 audit-cited breaches (incl. `chat_moderation` domain importing supabase; `profile_repository.dart`/`journal_repository.dart` inheriting `offline/data/offline_aware_repository.dart` — move that base contract to domain or core)

### Story H.5 — Backend hardening follow-ups  [safety: true] [needs_human: true] (lifts backend security 4→8 with Phase 0)
- [ ] Backfill `set search_path` on the 2025-era SECURITY DEFINER RPCs (`20250113000000_rpcs.sql` — `search_profiles`, `get_profile_safe`, feed RPCs) via a hardening migration; pgTAP asserts every SECURITY DEFINER fn pins search_path
- [ ] Design the **no-show dispute path** (unilateral `report_no_show` is a reputation-griefing vector — audit §5) — decision doc for reward-fn v0.1.1 BEFORE reputation is publicly surfaced by web step 10; implementation may land later, the design gate is now
- [ ] Run `mcp get_advisors` (Supabase security + performance advisors) and triage every finding to fixed/accepted-with-reason
- [ ] Cross-check both clients after each migration (FOUNDATIONS §10)

### Story H.6 — Dependencies, conventions, upgrade (audit P2/P3 · lifts code quality + arch)
> Deletion beats upgrading: `http`+`dio` (dio existed for the phantom GraphQL stack — dies with
> Story 0.4), two map stacks, `mockito`+`mocktail`, three crypto packages, `sqflite` alongside
> Drift, token vault on `flutter_secure_storage ^10.0.0-beta.4`.
- [ ] Remove `graphql_flutter`-independent remnants of the dead stack; collapse to ONE http client (keep `dio` only if a real consumer remains, else `http`)
- [ ] `flutter_secure_storage` off the beta (latest stable; docs-grounded migration notes)
- [ ] Pick one map stack (decision doc: `google_maps_flutter` vs `flutter_map`) — implement removal opportunistically per-screen
- [ ] One mocking library for NEW tests (recommend mocktail); document; don't rewrite old tests
- [ ] Consolidate crypto: `backup_service_impl.dart:1051-1066` hand-rolled crypto → `lib/core/security`; drop redundant packages (`encrypt`/`pointycastle` review)
- [ ] `riverpod_lint` → dev_dependencies; drop `sqflite` if Drift covers all callers
- [ ] Flutter 3.38.6 → 3.44.x: CI pin bump + full suite + known-failures re-triage (own PR, nothing else in it)
- [ ] Convention decision doc (`docs/ARCHITECTURE.md` update): `data/` vs `infrastructure/` — pick ONE; `lib/features/core` folds into `lib/core`; error-handling regime (H.2); providers style (@riverpod codegen for new code). Enforced by review checklist, migrated opportunistically — **no big-bang moves**

### Story H.7 — Shipped-TODO closure (audit P2)
- [ ] Delete the deprecated presentation-layer `TokenManager` (`token_manager_provider.dart`) after confirming zero consumers of its unimplemented refresh path; domain `token_manager.dart` is the one true manager
- [ ] `login_screen.dart:152` / `signup_screen.dart:144` — wire real `isLoading` state
- [ ] `places_remote_data_source_impl.dart` — decide: ship real Places calls behind the existing key plumbing, or feature-flag the surface off for launch (no mock data reachable in prod)
- [ ] Sweep the remaining 69 TODO/FIXME markers: each either becomes a story, an issue, or gets deleted

## Definition of Done / Acceptance Criteria
- [ ] `MatchingRepositoryImpl` + `MeetupCheckinRepositoryImpl` covered by real repository tests; SOS has a behavior test
- [ ] Zero `supabase_flutter` imports in `presentation/`+`domain/` (CI-gated); zero `api.soloadventurer.com` references (0.4 DoD)
- [ ] Safety/matching catches preserve cause+stack; Sentry initialized; shared Postgrest error mapper adopted on the top-5 data sources
- [ ] Women-only mode server-authoritative in its own module, premium-gated, tested
- [ ] pgTAP green incl. search_path assertions; advisors triaged; dispute-path decision signed off
- [ ] `flutter analyze` errors-only clean; green count ≥ `test_baseline` (raised by H.1)
- [ ] Re-score against the audit rubric: Clean Architecture ≥ 8, SOLID ≥ 8, code quality ≥ 8.5

## Dependencies
PHASE_0 Stories 0.4 + 0.5 (H.1's SOS test and H.4's gates build on the real backend). H.5's dispute design gates web step 10's public reputation surfacing. Parallel-safe with web PHASE_W / PHASE_A (different repos; the only shared seam is Story 0.5 + H.5 migrations — cross-check web per FOUNDATIONS §10).
