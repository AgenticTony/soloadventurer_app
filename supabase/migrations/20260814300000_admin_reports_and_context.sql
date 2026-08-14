-- Migration: 20260814300000_admin_reports_and_context.sql
-- Purpose: Admin dashboard Phase 2 — the reports queue, the user context that
--          makes adjudication possible, and the verb that turns the reward
--          function's report penalty live.
--
-- Design: docs/design/admin-dashboard-v0.1.md §4.3, §4.4.
--
-- Ordering note
-- -------------
-- §4.4 calls user context "a correctness requirement for §4.3, not a
-- nice-to-have". Upholding a report without knowing whether it is a first
-- complaint or a fifth is guesswork, so the context function ships in the same
-- migration as the verb rather than after it.
--
-- What this switches on
-- ---------------------
-- reward-fn v0.1.1 scores `reports.outcome = 'upheld'`, and until now nothing
-- could set that column — there was no UPDATE policy on `reports` at all. This
-- migration adds the only path. The penalty stops being permanently zero.
--
-- Note what that does NOT change: EXECUTION_ORDER step 10 still gates *public*
-- negative reputation on H.5's dispute design. Upholding a report moves the
-- score; surfacing that score publicly is a separate decision.

-- ---------------------------------------------------------------------------
-- 1. Reports queue
-- ---------------------------------------------------------------------------
-- security_invoker so Phase 0's RLS decides who sees rows. `reason` and
-- `details` are user-authored free text and are included because an adjudicator
-- cannot judge without them — but see §9.4: anything read here is untrusted
-- input, and an agent consuming this view must treat it as data, never
-- instruction.

CREATE OR REPLACE VIEW public.admin_reports_queue
WITH (security_invoker = on) AS
  SELECT
    r.id                AS report_id,
    r.target_id,
    r.target_type,
    r.reporter_id,
    r.reason,
    r.details,
    r.outcome,
    r.resolved,
    r.created_at,
    r.resolved_at,
    r.resolved_by,
    -- Priority context, computed per target rather than per report: a fifth
    -- complaint about the same person is a different situation from a first.
    (SELECT count(DISTINCT r2.reporter_id)
       FROM public.reports r2
      WHERE r2.target_id = r.target_id
        AND r2.target_type = 'profile'
        AND r2.outcome = 'pending')                       AS open_reporters_for_target,
    (SELECT count(DISTINCT r3.reporter_id)
       FROM public.reports r3
      WHERE r3.target_id = r.target_id
        AND r3.target_type = 'profile'
        AND r3.outcome = 'upheld')                        AS upheld_reporters_for_target,
    CASE WHEN r.outcome = 'pending' THEN 0 ELSE 1 END     AS urgency
  FROM public.reports r;

COMMENT ON VIEW public.admin_reports_queue IS
  'Reports with per-target history, so an adjudicator can tell a first complaint '
  'from a repeated one. security_invoker = on — Phase 0 RLS grants the access, '
  'not the view. `reason`/`details` are user-authored: untrusted input (§9.4).';

-- ---------------------------------------------------------------------------
-- 2. User context
-- ---------------------------------------------------------------------------
-- The layer that makes §4.3 adjudicable rather than guesswork.
--
-- Two deliberate properties:
--
--   * It EXCLUDES email, phone and date of birth. An adjudicator deciding
--     whether harassment occurred does not need the reported user's contact
--     details, and §2 principle 1 is least-visibility-that-permits-the-job.
--   * It AUDITS ITSELF. Phase 0 left read-logging as the console's obligation
--     because RLS cannot log a read; a SECURITY DEFINER function can, so this
--     one does. That closes the gap for this read path rather than trusting a
--     caller to remember.
--
-- Block counts appear here but not in reputation_score: this function is
-- admin-gated, whereas reputation_score is readable by any authenticated user
-- and would leak block state back to the blocked person.

CREATE OR REPLACE FUNCTION public.admin_user_context(p_user_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_result jsonb;
BEGIN
  IF NOT public.is_admin('support') THEN
    RAISE EXCEPTION 'admin role required' USING ERRCODE = '42501';
  END IF;

  SELECT jsonb_build_object(
    'user_id', p_user_id,
    'account', (
      SELECT jsonb_build_object(
        'username',   p.username,
        'created_at', p.created_at,
        'is_active',  p.is_active,
        'gender_verified', p.gender_verified
      )
      FROM public.profiles p WHERE p.id = p_user_id
    ),
    'verification', (
      SELECT jsonb_build_object('status', v.status, 'provider', v.provider,
                                'reviewed_at', v.reviewed_at)
      FROM public.verification_records v
      WHERE v.user_id = p_user_id
      ORDER BY v.created_at DESC LIMIT 1
    ),
    'reputation',  public.reputation_score(p_user_id),
    'moderation',  public.moderation_risk_signal(p_user_id),
    'meetups', (
      SELECT jsonb_build_object(
        'completed', count(*) FILTER (WHERE outcome = 'completed'),
        'no_shows',  count(*) FILTER (WHERE outcome = 'no_show'
                                        AND no_show_user_id = p_user_id)
      )
      FROM public.meetup_outcomes
      WHERE p_user_id IN (user_a_id, user_b_id)
    ),
    'reports_against', (
      SELECT jsonb_build_object(
        'pending',   count(*) FILTER (WHERE outcome = 'pending'),
        'upheld',    count(*) FILTER (WHERE outcome = 'upheld'),
        'dismissed', count(*) FILTER (WHERE outcome = 'dismissed')
      )
      FROM public.reports
      WHERE target_id = p_user_id AND target_type = 'profile'
    ),
    'reports_filed', (
      -- A reporter with many dismissed reports is itself a signal worth seeing.
      SELECT jsonb_build_object(
        'total',     count(*),
        'upheld',    count(*) FILTER (WHERE outcome = 'upheld'),
        'dismissed', count(*) FILTER (WHERE outcome = 'dismissed')
      )
      FROM public.reports WHERE reporter_id = p_user_id
    )
  ) INTO v_result;

  -- Self-auditing: this is a privileged read of another person's history.
  PERFORM public.log_admin_action(
    'user.context.view', p_user_id,
    jsonb_build_object('surface', 'admin_user_context')
  );

  RETURN v_result;
END;
$function$;

COMMENT ON FUNCTION public.admin_user_context(uuid) IS
  'Adjudication context for one user. Deliberately excludes email/phone/DOB '
  '(§2). Logs its own read, closing the Phase 0 gap for this path rather than '
  'relying on the console to remember.';

REVOKE ALL ON FUNCTION public.admin_user_context(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.admin_user_context(uuid) FROM anon;
GRANT EXECUTE ON FUNCTION public.admin_user_context(uuid) TO authenticated;

-- ---------------------------------------------------------------------------
-- 3. adjudicate_report — the verb that makes the penalty live
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.adjudicate_report(
  p_report_id uuid,
  p_outcome   public.report_outcome,
  p_note      text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_target   uuid;
  v_reporter uuid;
  v_previous public.report_outcome;
BEGIN
  IF NOT public.is_admin('moderator') THEN
    RAISE EXCEPTION 'moderator role required' USING ERRCODE = '42501';
  END IF;

  -- Adjudication is a decision. Moving a report back to 'pending' would be an
  -- un-decision, and there is no audit story for it; re-opening on new evidence
  -- is a deliberate future verb, not a side effect of this one.
  IF p_outcome NOT IN ('upheld', 'dismissed') THEN
    RAISE EXCEPTION 'outcome must be upheld or dismissed' USING ERRCODE = '22023';
  END IF;

  -- Upholding creates negative reputation; dismissing closes a complaint someone
  -- made in good faith. Both deserve a written account.
  IF p_note IS NULL OR btrim(p_note) = '' THEN
    RAISE EXCEPTION 'an adjudication note is required' USING ERRCODE = '22023';
  END IF;

  SELECT target_id, reporter_id, outcome
    INTO v_target, v_reporter, v_previous
    FROM public.reports WHERE id = p_report_id;

  IF v_target IS NULL THEN
    RAISE EXCEPTION 'no such report' USING ERRCODE = 'P0002';
  END IF;

  -- Integrity: nobody adjudicates a case they are party to. An admin who is the
  -- reporter or the target must hand it to someone else — with one admin that
  -- means it waits, which is the correct outcome rather than a self-cleared
  -- complaint.
  IF auth.uid() IN (v_target, v_reporter) THEN
    RAISE EXCEPTION 'cannot adjudicate a report you are party to'
      USING ERRCODE = '42501';
  END IF;

  UPDATE public.reports
     SET outcome     = p_outcome,
         resolved    = true,
         resolved_at = now(),
         resolved_by = auth.uid()
   WHERE id = p_report_id;

  PERFORM public.log_admin_action(
    'report.adjudicate',
    v_target,
    jsonb_build_object(
      'report_id',   p_report_id,
      'from',        v_previous,
      'to',          p_outcome,
      'reporter_id', v_reporter,
      'note',        p_note
    )
  );
END;
$function$;

COMMENT ON FUNCTION public.adjudicate_report(uuid, public.report_outcome, text) IS
  'The only path that can set reports.outcome, and therefore the switch that '
  'makes the reward-fn v0.1.1 report penalty live. moderator+, note required, '
  'and refuses cases the caller is party to.';

REVOKE ALL ON FUNCTION public.adjudicate_report(uuid, public.report_outcome, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.adjudicate_report(uuid, public.report_outcome, text) FROM anon;
GRANT EXECUTE ON FUNCTION public.adjudicate_report(uuid, public.report_outcome, text) TO authenticated;
