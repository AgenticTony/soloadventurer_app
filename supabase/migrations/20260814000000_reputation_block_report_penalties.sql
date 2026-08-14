-- Migration: 20260814000000_reputation_block_report_penalties.sql
-- Purpose: Wire the block/report penalties into reputation (reward fn v0.1.1).
--
-- Context
-- -------
-- `reward-function-v0.1.md` deferred these penalties "pending table
-- confirmation", naming `blocked_users` and `message_reports` — both phantoms.
-- The real tables (`blocks`, `reports`) shipped in Stories 0.6/0.7, so the
-- dependency has been satisfied for weeks (corrected 2026-08-13).
--
-- Wiring them naively would have shipped two defects into a safety product, so
-- this migration does the enabling work first.
--
-- 1. Reports had no adjudication outcome
--    `reports.resolved` is a boolean meaning "a moderator closed this", not
--    "the target was at fault". Penalising on `resolved` would punish people
--    whose reports were *dismissed* — the opposite of the intent. Worse,
--    penalising on *unresolved* reports would make reputation trivially
--    griefable: anyone could file reports to tank a stranger's score.
--    This adds `reports.outcome` so the signal can be adjudicated, and scores
--    only `upheld`. Today that evaluates to zero for everyone, because no
--    moderation path sets it yet. That is the correct starting state: the
--    signal is wired and inert, rather than live and abusable.
--
-- 2. Blocks must not reach a publicly-readable score
--    `reputation_score` is EXECUTE-able by `authenticated`, so any signed-in
--    user can call it for any user id. Putting a block count in that payload
--    would let a blocked person infer they had been blocked — exactly what
--    blocks are designed not to reveal, on the feature a harassed user depends
--    on. Blocks therefore feed a separate `moderation_risk_signal()`, readable
--    by `service_role` only.
--
-- Griefing resistance: both signals count DISTINCT actors, so one determined
-- person (or one person with sockpuppets they control) cannot compound a
-- penalty by acting repeatedly.
--
-- Refs: docs/reward-function-v0.1.md · FOUNDATIONS §4 (reward = outcomes)
--       EXECUTION_ORDER step 10 gates *public* negative reputation on H.5's
--       dispute design; this migration wires the signal, it does not surface it.

-- ---------------------------------------------------------------------------
-- 1. Adjudication outcome for reports
-- ---------------------------------------------------------------------------

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'report_outcome') THEN
    CREATE TYPE public.report_outcome AS ENUM ('pending', 'upheld', 'dismissed');
  END IF;
END$$;

ALTER TABLE public.reports
  ADD COLUMN IF NOT EXISTS outcome public.report_outcome NOT NULL DEFAULT 'pending';

COMMENT ON COLUMN public.reports.outcome IS
  'Adjudication result. `resolved` only records that a moderator closed the '
  'report; this records whether the target was actually at fault. Only '
  '`upheld` feeds reputation — scoring `resolved` would penalise dismissed '
  'reports, and scoring unresolved ones would make reputation griefable.';

-- A closed report with no explicit verdict is not evidence of wrongdoing, so
-- existing rows stay 'pending' rather than being read as upheld.

CREATE INDEX IF NOT EXISTS idx_reports_upheld_target
  ON public.reports (target_id)
  WHERE outcome = 'upheld';

-- ---------------------------------------------------------------------------
-- 2. reputation_score — add the upheld-report penalty
-- ---------------------------------------------------------------------------
-- v0.1.1 = 2×meetups_completed + floor(vouch_pct/10) − no_shows − upheld_reports
--
-- Weight rationale: an upheld report is at least as serious as a no-show, so it
-- carries the same −1. Severity weighting is deferred until report categories
-- carry a severity of their own; a flat weight is honest about what we can
-- currently distinguish.

CREATE OR REPLACE FUNCTION public.reputation_score(p_user_id uuid)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
  with completed as (
    select count(*)::int as n
    from public.meetup_outcomes
    where p_user_id in (user_a_id, user_b_id) and outcome = 'completed'
  ),
  reviews as (
    select count(*)::int as n,
           coalesce(round(avg(rating)::numeric, 2), 0) as avg_rating,
           coalesce(round(100.0 * count(*) filter (where would_meet_again)
                          / nullif(count(*), 0))::numeric, 0) as vouch_pct
    from public.member_reviews
    where reviewed_id = p_user_id
  ),
  no_shows as (
    select count(*)::int as n
    from public.meetup_outcomes
    where outcome = 'no_show' and no_show_user_id = p_user_id
  ),
  upheld_reports as (
    -- DISTINCT reporters: repeated reports from one person are one signal, so
    -- a single determined actor cannot compound the penalty.
    select count(distinct reporter_id)::int as n
    from public.reports
    where target_id = p_user_id
      and target_type = 'profile'
      and outcome = 'upheld'
  )
  select jsonb_build_object(
    'user_id', p_user_id,
    'meetups_completed', (select n from completed),
    'review_count',      (select n from reviews),
    'avg_rating',        (select avg_rating from reviews),
    'vouch_pct',         (select vouch_pct from reviews),
    'no_shows',          (select n from no_shows),
    'upheld_reports',    (select n from upheld_reports),
    'score',             (select n from completed) * 2
                         + floor(coalesce((select vouch_pct from reviews)::int, 0) / 10.0)::int
                         - (select n from no_shows)
                         - (select n from upheld_reports)
  );
$function$;

COMMENT ON FUNCTION public.reputation_score(uuid) IS
  'Reward function v0.1.1. Public-safe: readable by any authenticated user, so '
  'it deliberately excludes block data — see moderation_risk_signal(). '
  'Negative components (no-shows, upheld reports) are wired here but must not '
  'be surfaced publicly until H.5''s dispute design ships (EXECUTION_ORDER 10).';

-- ---------------------------------------------------------------------------
-- 3. moderation_risk_signal — private; where blocks live
-- ---------------------------------------------------------------------------
-- Blocks are a real misconduct signal but a poor *public* one: unilateral, not
-- adjudicated, and invisible to the blocked party by design. This function is
-- service_role-only so moderation tooling can use it without creating an
-- inference channel back to the person who was blocked.

CREATE OR REPLACE FUNCTION public.moderation_risk_signal(p_user_id uuid)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
  with blockers as (
    -- DISTINCT blockers: sockpuppet-resistant, and one person blocking and
    -- unblocking repeatedly is still one signal.
    select count(distinct blocker_id)::int as n
    from public.blocks
    where blocked_id = p_user_id
  ),
  reports_upheld as (
    select count(distinct reporter_id)::int as n
    from public.reports
    where target_id = p_user_id and target_type = 'profile' and outcome = 'upheld'
  ),
  reports_pending as (
    select count(distinct reporter_id)::int as n
    from public.reports
    where target_id = p_user_id and target_type = 'profile' and outcome = 'pending'
  )
  select jsonb_build_object(
    'user_id', p_user_id,
    'distinct_blockers', (select n from blockers),
    'upheld_reports',    (select n from reports_upheld),
    'pending_reports',   (select n from reports_pending),
    -- Advisory only. Deliberately not fed into reputation_score: blocks are not
    -- adjudicated, and a public score that moved on them would leak block state.
    'risk_flag', (
      (select n from blockers) >= 3
      or (select n from reports_upheld) >= 1
      or (select n from reports_pending) >= 3
    )
  );
$function$;

COMMENT ON FUNCTION public.moderation_risk_signal(uuid) IS
  'Private moderation signal (service_role only). Includes block counts, which '
  'reputation_score must never expose: it is authenticated-readable, so a block '
  'count there would let a blocked user infer they had been blocked.';

REVOKE ALL ON FUNCTION public.moderation_risk_signal(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.moderation_risk_signal(uuid) FROM anon;
REVOKE ALL ON FUNCTION public.moderation_risk_signal(uuid) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.moderation_risk_signal(uuid) TO service_role;
