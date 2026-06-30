# Phase A — Lay the Spine

> FOUNDATIONS §4, §9 (Phase A) · Repo: mobile (owns the shared backend) · Safety-sensitive: **YES** (RLS)
> Status: queued after Phase 0. **Mostly schema + a reward-function artifact — not ML.**

## Goal
Build the foundation every later phase compounds on: the L0 event/outcome store, the reward-function v0.1, and the meetup-gated bilateral reputation entity. This is what flips AI from decorative to structural (FOUNDATIONS §4 — the spine is a closed loop, and L0 is the missing foundation).

## Scope
**IN:** `events`/`meetup_outcomes` tables (migration + RLS); reward-function v0.1 (spec + scoring RPC); bilateral `member_reviews` entity (migration + RLS + RPCs), gated to verified meetups.
**OUT:** outcome-trained ranker (Phase B); agents (Phase C); UI surfacing (Phase D).
**Guardrails (§4, §6):** reward = outcomes, never engagement; no synthetic/fake liquidity.

## Stories

### Story A.1 — L0 event/outcome store  [safety: true]
- [ ] Migration: `meetup_outcomes` + unified `events` log tables
- [ ] RLS: only participants write their own outcome; reads per reputation rules
- [ ] Indexes for north-star queries (`meetups_completed` by cohort / city / time)
- [ ] Cross-check web client read paths (shared backend — FOUNDATIONS §10)

### Story A.2 — Reward function v0.1  [needs_human: true]
- [ ] Author the reward-fn spec (FOUNDATIONS §4 v0.1 weights) as a **versioned artifact** in `docs/`
- [ ] Scoring RPC `reputation_score(user_id)` derived from outcomes
- [ ] Tests: reward reflects outcomes; engagement inputs (sessions/scrolls) are **never** inputs

### Story A.3 — Bilateral reputation entity (meetup-gated)  [safety: true]
- [ ] Migration: `member_reviews` (bilateral, tied to `meetup_checkin` proof)
- [ ] RLS: a review requires a verified co-located meetup; cannot review a stranger never met
- [ ] RPCs: `submit_review`, `get_reputation`
- [ ] Tests: gating logic — no verified meetup → no review possible

## Definition of Done / Acceptance Criteria
- [ ] Migrations applied; RLS tested (positive + negative cases)
- [ ] Reward fn documented; scoring RPC returns correct values
- [ ] Reputation entity is meetup-gated; bilateral review enforced
- [ ] `flutter analyze` clean; new tests green; baseline not regressed
- [ ] Web client cross-checked for shared-backend changes

## Dependencies
Phase 0 (analytics + secrets) unblocks. Phase B consumes these tables; Phase D surfaces reputation.
