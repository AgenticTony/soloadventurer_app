# Step 9 — Phase A finish: north-star time index (city deferred) + `events` decision

> Execution-order **step 9** (Stage A) · Phase A Story A.1 leftovers · Repo: mobile (shared backend).
> **Safety-sensitive** (Phase A migration) → PR waits for human sign-off.
> Decided 2026-07-06 after verifying the data reality (below).

## The data reality (verified, not assumed)
- `meetups` has **no city**; `connection_id` and trip FKs are `ON DELETE SET NULL`.
- **`trips.destination_city` is a dead column** — never written by mobile, web, or any trigger
  (`grep` = zero writes). Always NULL.
- The only populated location fields are **free-text**: `trips.destination` ("Tokyo"),
  `meetups.location_name` ("Cafe"). No normalized city, no geocode.
- **No consumer queries meetups by city today** — `meetups_completed` appears only in
  `reputation_score` (totals, not by city) and the pgTAP test.
- Time, by contrast, is real and reliable: `meetup_outcomes.completed_at` / `created_at`.

## Decision 1 — city dimension: **DEFERRED** (was going to be "denormalize from trips")
Denormalizing city from `trips.destination_city` would copy **NULL into every meetup** and
index an empty column with **no reader** — decorative infra (FOUNDATIONS §6). Deferred until a
**real city source** exists. Unblock conditions (do it then, not now):
1. The meetup-creation client is built and captures a **normalized city** → add `p_city` to
   `propose_meetup`, denormalize onto `meetups` at write, copy onto `meetup_outcomes` at
   completion (**this is the correct shape** — write-time denormalization of an immutable
   fact), then add the `(outcome, city, completed_at)` index; **or**
2. reverse-geocode `meetups.location_point` → city (needs a geocoding step).

That same denormalized `city` is what the deferred **server-side PostHog north-star trigger**
(step 5 follow-up) will emit as an event property — so city work should land together with,
or just before, that trigger.

## Decision 2 — unified `events` table: **DEFERRED** (confirmed)
The north-star needs no general events log; `meetup_outcomes` serves it. A unified `events`
store is an L1/behavioral concern for **Phase B** (the outcome-trained ranker, step 11) — build
it when the ranker's feature store is designed, not before (YAGNI, §6).

## What this PR ships (the genuinely-ready part)
The **time cohort** for the north-star — real today, zero data-model risk:
1. **Migration** `20260706160000_northstar_time_indexes.sql`:
   - `idx_meetup_outcomes_completed` — partial `(completed_at)` `WHERE outcome = 'completed'`
     (the north-star: completed meetups over time; also covers no-show rate by time).
   - `idx_meetup_outcomes_outcome_time` — `(outcome, completed_at)` for outcome-split cohorts.
   - `idx_meetups_status_completed` — `(status, completed_at)` for status/time queries.
2. **pgTAP**: assert the three indexes exist (`has_index`).
3. No RPC changes, no new columns → **no web impact** (web has zero Phase A consumers; re-verified).

## Status vs. Phase A Story A.1
- [x] Indexes for north-star queries — **time** shipped here; **city deferred** (documented above).
- [ ] Unified `events` table — deferred to Phase B (documented above).
