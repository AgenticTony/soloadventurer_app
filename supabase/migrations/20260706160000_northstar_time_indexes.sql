-- ============================================================================
-- Phase A finish (step 9): north-star TIME indexes.
-- ============================================================================
-- FOUNDATIONS §4/§9 · docs/design/step-9-phase-a-finish-scope.md
--
-- The north-star is `meetups_completed` (meetup_outcomes.outcome='completed').
-- This migration indexes the TIME cohort — completed meetups over time — which
-- is real and reliable today (completed_at / created_at are always populated).
--
-- The CITY cohort is DEFERRED: `trips.destination_city` is a dead column (never
-- written) and no normalized city source exists yet, so a city column/index
-- would index NULL with no reader. It lands when a real city source arrives
-- (client-supplied city on propose_meetup, or geocoding location_point) — see
-- the scope doc. The unified `events` table stays deferred to Phase B.
--
-- Additive indexes only — no RLS/RPC/column changes. No web impact.
-- ============================================================================

-- North-star: completed meetups over time. Partial — completed outcomes carry
-- completed_at (no_show rows have it NULL), so this indexes exactly the rows the
-- north-star counts.
create index if not exists idx_meetup_outcomes_completed_at
  on public.meetup_outcomes (completed_at)
  where outcome = 'completed';

-- Outcome cohorts (completed vs no_show) over time. created_at is always set,
-- so this serves both completion-rate and no-show-rate time series.
create index if not exists idx_meetup_outcomes_outcome_created
  on public.meetup_outcomes (outcome, created_at);

-- Meetups by status over time (funnel: proposed/confirmed/completed/cancelled).
create index if not exists idx_meetups_status_completed
  on public.meetups (status, completed_at);
