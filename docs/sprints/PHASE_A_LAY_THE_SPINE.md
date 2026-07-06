# Phase A — Lay the Spine

> FOUNDATIONS §4, §9 (Phase A) · Repo: mobile (owns the shared backend) · Safety-sensitive: **YES** (RLS)
> Status: **backend shipped via PR #8 (2026-06-30)** — meetups / outcomes / reputation live. Remaining: A.4 (no-show + cancel RPCs) + deferred `events` table + north-star city/time indexes. `active_sprint` stays PHASE_0 (blockers outstanding). **Mostly schema + a reward-function artifact — not ML.**

## Goal
Build the foundation every later phase compounds on: the L0 event/outcome store, the reward-function v0.1, and the meetup-gated bilateral reputation entity. This is what flips AI from decorative to structural (FOUNDATIONS §4 — the spine is a closed loop, and L0 is the missing foundation).

## Scope
**IN:** `meetup_outcomes` table (migration + RLS); reward-function v0.1 (spec + scoring RPC); bilateral `member_reviews` entity (migration + RLS + RPCs), gated to verified meetups. *(Unified `events` log table deferred — see A.1.)*
**OUT:** outcome-trained ranker (Phase B); agents (Phase C); UI surfacing (Phase D).
**Guardrails (§4, §6):** reward = outcomes, never engagement; no synthetic/fake liquidity.

## Stories

### Story A.1 — L0 event/outcome store  [safety: true]
- [x] Migration: `meetup_outcomes` table (shipped PR #8, 2026-06-30)
- [ ] Unified `events` log table — **deferred to Phase B** (only `meetup_outcomes` was built; a general event log is an L1/ranker concern — build with the feature store, step 11, not before; see `docs/design/step-9-phase-a-finish-scope.md`)
- [x] RLS: outcome writes go through the SECURITY DEFINER RPCs (no direct write policy); reads scoped to parties
- [x] Indexes for north-star queries — **TIME cohort shipped** (step 9, `20260706160000`: completed-over-time + outcome/status time indexes + pgTAP). **CITY cohort DEFERRED**: `trips.destination_city` is a dead column (never written) and no normalized city source exists, so a city index would index NULL with no reader — lands when a real city source arrives (client-supplied city on `propose_meetup`, or geocoding `location_point`). See the scope doc.
- [x] Cross-check web client read paths (shared backend — FOUNDATIONS §10) — done in the 2026-07-05 two-repo review

### Story A.2 — Reward function v0.1  [needs_human: true]
- [x] Author the reward-fn spec (FOUNDATIONS §4 v0.1 weights) as a **versioned artifact** in `docs/` (`docs/reward-function-v0.1.md`)
- [x] Scoring RPC `reputation_score(user_id)` derived from outcomes
- [x] Tests: reward reflects outcomes; engagement inputs (sessions/scrolls) are **never** inputs (pgTAP)

### Story A.3 — Bilateral reputation entity (meetup-gated)  [safety: true]
- [x] Migration: `member_reviews` (bilateral) — gated on a **mutually-confirmed** completed meetup (both parties tap "we met"); co-location / `meetup_checkin` gate deferred to Phase C (see migration header)
- [x] RLS: a review requires a **completed (mutually-confirmed)** meetup; cannot review a stranger never met
- [x] RPCs: `submit_review`, `reputation_score`
- [x] Tests: gating logic — no completed meetup → no review possible (pgTAP)

### Story A.4 — Close reward-fn v0.1: no-show + cancel paths  [safety: true]  *(added 2026-07-05)*
- [x] RPC `report_no_show` — writes `meetup_outcomes.outcome = 'no_show'` with **attribution** (`no_show_user_id`, new column + CHECK) so the −1 lands on the absent party only, not both; guards: party-only, confirmed status, meetup_time passed, blocked once either party tapped "we met"; terminalizes the meetup (migration `20260706100000`)
- [x] RPC `cancel_meetup` — **either party** may cancel while proposed/confirmed (superset of proposer-only; flagged for sign-off in the PR); no-fault in v0.1 (no outcome row, no penalty)
- [x] Tests: no_show write path + attribution; before-time / unconfirmed / non-party / double-report rejections; cancel authorization + completed-is-immutable; `reputation_score` penalty on the no-shower only (pgTAP 22 → 36)
- [x] Cross-check web client (shared backend — FOUNDATIONS §10) — web has **zero** Phase A consumers yet (step 10 not started; verified by grep 2026-07-06), so the `reputation_score` JSON change is safe

## Definition of Done / Acceptance Criteria
- [x] Migrations applied; RLS tested (positive + negative cases) — PR #8 (pgTAP)
- [x] Reward fn documented; scoring RPC returns correct values
- [x] Reputation entity is meetup-gated; bilateral review enforced
- [ ] `flutter analyze` clean; new tests green; baseline not regressed — pending A.4
- [x] Web client cross-checked for shared-backend changes (2026-07-05 review)

## Dependencies
Phase 0 (analytics + secrets) unblocks. Phase B consumes these tables; Phase D surfaces reputation.
