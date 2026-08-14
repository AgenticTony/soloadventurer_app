-- Migration: 20260814200000_admin_live_safety.sql
-- Purpose: Admin dashboard Phase 1 — the live-safety queue, its verbs, and the
--          escalation channel.
--
-- Design: docs/design/admin-dashboard-v0.1.md §4.1, §9.2, §10.
--
-- The gap in concrete terms
-- -------------------------
-- A pg_cron job (`escalate-overdue-checkins`) already flips a missed check-in to
-- `alerted` every minute. Nothing consumes that state. The detection has existed
-- all along; what was missing is that `alerted` reaches nobody. The same is true
-- of an SOS whose trusted contact never acknowledges it.
--
-- Phase 1 therefore ships two things, and the second matters more than the first:
--   1. a queue an admin can look at, and
--   2. an escalation that reaches a human whether or not anyone is looking.
--
-- §9.2 is absolute: an unacknowledged SOS pages a human immediately and always.
-- There is no agent triage in front of it.
--
-- Transport note
-- --------------
-- `pg_net` is not installed, so pg_cron cannot call an HTTP endpoint directly.
-- The pattern is therefore enqueue-and-drain: cron writes durable rows into
-- `admin_escalations`, and an edge function drains them through the Twilio/Resend
-- transports `process-safety-alert` already uses. A durable queue is the better
-- shape anyway — a failed dispatch stays visible and retryable instead of being
-- lost in a fire-and-forget call.

-- ---------------------------------------------------------------------------
-- 1. The live-safety queue
-- ---------------------------------------------------------------------------
-- `security_invoker = on` is load-bearing. A SECURITY DEFINER view would return
-- rows regardless of who asked, bypassing the RLS that Phase 0 established — and
-- the 2026-08-12 audit already flagged five SECDEF views as a defect to fix, not
-- a pattern to copy.

CREATE OR REPLACE VIEW public.admin_live_safety_queue
WITH (security_invoker = on) AS
  SELECT
    'sos'::text                       AS kind,
    s.id                              AS subject_id,
    s.user_id,
    s.status::text                    AS status,
    s.triggered_at                    AS occurred_at,
    s.address,
    s.latitude,
    s.longitude,
    s.accuracy,
    s.battery_level,
    coalesce(array_length(s.notified_contact_ids, 1), 0)     AS contacts_notified,
    coalesce(array_length(s.acknowledged_contact_ids, 1), 0) AS contacts_acknowledged,
    -- The dangerous case is not an SOS. It is an SOS nobody answered.
    (s.status = 'active' AND coalesce(array_length(s.acknowledged_contact_ids, 1), 0) = 0)
                                      AS unanswered,
    CASE
      WHEN s.status = 'active'
       AND coalesce(array_length(s.acknowledged_contact_ids, 1), 0) = 0 THEN 0  -- loudest
      WHEN s.status = 'active'                                          THEN 1
      ELSE 3
    END                               AS urgency
  FROM public.sos_alerts s
  WHERE s.status IN ('active', 'acknowledged')

  UNION ALL

  SELECT
    'checkin'::text                   AS kind,
    c.id                              AS subject_id,
    c.user_id,
    c.status::text                    AS status,
    coalesce(c.alerted_at, c.meetup_time) AS occurred_at,
    c.location_name                   AS address,
    NULL::double precision            AS latitude,
    NULL::double precision            AS longitude,
    NULL::double precision            AS accuracy,
    NULL::integer                     AS battery_level,
    0                                 AS contacts_notified,
    0                                 AS contacts_acknowledged,
    true                              AS unanswered,
    2                                 AS urgency
  FROM public.meetup_checkins c
  WHERE c.status IN ('alerted', 'sos')
    AND c.checked_in_at IS NULL
    AND c.cancelled_at IS NULL;

COMMENT ON VIEW public.admin_live_safety_queue IS
  'Open safety events for the admin console, lowest `urgency` first. '
  'security_invoker = on, so Phase 0 RLS decides who sees rows — the view grants '
  'nothing on its own. Coordinates are included because an operator responding to '
  'an SOS needs them; reading this view is a privileged read and the console must '
  'log it (design §2).';

-- ---------------------------------------------------------------------------
-- 2. Escalation queue
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.admin_escalations (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  kind           text NOT NULL CHECK (kind IN ('sos', 'checkin')),
  subject_id     uuid NOT NULL,
  user_id        uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reason         text NOT NULL,
  enqueued_at    timestamptz NOT NULL DEFAULT now(),
  dispatched_at  timestamptz,
  dispatch_error text,
  attempts       int NOT NULL DEFAULT 0,
  acknowledged_at    timestamptz,
  acknowledged_by    uuid REFERENCES public.profiles(id)
);

COMMENT ON TABLE public.admin_escalations IS
  'Durable paging queue. One open row per (kind, subject_id): an unacknowledged '
  'SOS must page once and keep paging until a human takes it, not once per cron '
  'tick. Rows survive dispatch failure so a page that did not land stays visible '
  'and retryable rather than being lost.';

-- Idempotency: at most one OPEN escalation per subject.
CREATE UNIQUE INDEX IF NOT EXISTS uq_admin_escalations_open
  ON public.admin_escalations (kind, subject_id)
  WHERE acknowledged_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_admin_escalations_pending
  ON public.admin_escalations (enqueued_at)
  WHERE dispatched_at IS NULL AND acknowledged_at IS NULL;

ALTER TABLE public.admin_escalations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_escalations: admin read"
  ON public.admin_escalations FOR SELECT
  TO authenticated
  USING (public.is_admin('support'));

-- No INSERT/UPDATE/DELETE policies: writes go through the functions below.

-- ---------------------------------------------------------------------------
-- 3. Enqueue (cron-driven)
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.enqueue_safety_escalations()
RETURNS int
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_count int := 0;
BEGIN
  -- SOS: active and unacknowledged by any trusted contact. §9.2 — no delay,
  -- no triage. The moment a contact has not answered, a human is owed a page.
  INSERT INTO public.admin_escalations (kind, subject_id, user_id, reason)
  SELECT 'sos', s.id, s.user_id, 'SOS active with no contact acknowledgement'
  FROM public.sos_alerts s
  WHERE s.status = 'active'
    AND coalesce(array_length(s.acknowledged_contact_ids, 1), 0) = 0
  ON CONFLICT DO NOTHING;

  GET DIAGNOSTICS v_count = ROW_COUNT;

  -- Missed check-ins: the cron job already marks these `alerted`; until now
  -- nothing consumed that state.
  INSERT INTO public.admin_escalations (kind, subject_id, user_id, reason)
  SELECT 'checkin', c.id, c.user_id, 'Meetup check-in overdue and not checked in'
  FROM public.meetup_checkins c
  WHERE c.status IN ('alerted', 'sos')
    AND c.checked_in_at IS NULL
    AND c.cancelled_at IS NULL
  ON CONFLICT DO NOTHING;

  RETURN v_count;
END;
$function$;

REVOKE ALL ON FUNCTION public.enqueue_safety_escalations() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.enqueue_safety_escalations() FROM anon;
REVOKE ALL ON FUNCTION public.enqueue_safety_escalations() FROM authenticated;

-- Every minute, matching the cadence of the existing safety crons.
SELECT cron.schedule(
  'enqueue-safety-escalations',
  '* * * * *',
  $$ SELECT public.enqueue_safety_escalations(); $$
);

-- ---------------------------------------------------------------------------
-- 4. Dispatch surface (for the edge function, service_role only)
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.claim_pending_escalations(p_limit int DEFAULT 20)
RETURNS SETOF public.admin_escalations
LANGUAGE sql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
  UPDATE public.admin_escalations e
     SET attempts = e.attempts + 1
   WHERE e.id IN (
     SELECT id FROM public.admin_escalations
      WHERE dispatched_at IS NULL
        AND acknowledged_at IS NULL
        AND attempts < 5          -- stop retrying forever; the row stays visible
      ORDER BY enqueued_at
      LIMIT p_limit
      FOR UPDATE SKIP LOCKED      -- safe if two dispatchers ever run at once
   )
  RETURNING e.*;
$function$;

CREATE OR REPLACE FUNCTION public.mark_escalation_dispatched(
  p_id uuid, p_error text DEFAULT NULL
)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
  UPDATE public.admin_escalations
     SET dispatched_at  = CASE WHEN p_error IS NULL THEN now() ELSE NULL END,
         dispatch_error = p_error
   WHERE id = p_id;
$function$;

REVOKE ALL ON FUNCTION public.claim_pending_escalations(int) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.claim_pending_escalations(int) FROM anon;
REVOKE ALL ON FUNCTION public.claim_pending_escalations(int) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.claim_pending_escalations(int) TO service_role;

REVOKE ALL ON FUNCTION public.mark_escalation_dispatched(uuid, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.mark_escalation_dispatched(uuid, text) FROM anon;
REVOKE ALL ON FUNCTION public.mark_escalation_dispatched(uuid, text) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.mark_escalation_dispatched(uuid, text) TO service_role;

-- ---------------------------------------------------------------------------
-- 5. Admin verbs
-- ---------------------------------------------------------------------------
-- Named, role-checked, audited in the same transaction as the write. Per design
-- §3.3: a write that cannot be described as a verb does not belong here.

CREATE OR REPLACE FUNCTION public.admin_acknowledge_sos(p_alert_id uuid, p_note text DEFAULT NULL)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE v_user uuid;
BEGIN
  IF NOT public.is_admin('moderator') THEN
    RAISE EXCEPTION 'moderator role required' USING ERRCODE = '42501';
  END IF;

  SELECT user_id INTO v_user FROM public.sos_alerts WHERE id = p_alert_id;
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'no such SOS alert' USING ERRCODE = 'P0002';
  END IF;

  UPDATE public.sos_alerts
     SET status = 'acknowledged',
         first_acknowledged_at = coalesce(first_acknowledged_at, now())
   WHERE id = p_alert_id AND status = 'active';

  -- An acknowledged alert stops paging: a human has taken it.
  UPDATE public.admin_escalations
     SET acknowledged_at = now(), acknowledged_by = auth.uid()
   WHERE kind = 'sos' AND subject_id = p_alert_id AND acknowledged_at IS NULL;

  PERFORM public.log_admin_action(
    'sos.acknowledge', v_user,
    jsonb_build_object('alert_id', p_alert_id, 'note', p_note)
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.admin_resolve_sos(p_alert_id uuid, p_note text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE v_user uuid;
BEGIN
  IF NOT public.is_admin('moderator') THEN
    RAISE EXCEPTION 'moderator role required' USING ERRCODE = '42501';
  END IF;

  -- Resolving closes a safety incident, so it requires a written account of why.
  IF p_note IS NULL OR btrim(p_note) = '' THEN
    RAISE EXCEPTION 'a resolution note is required' USING ERRCODE = '22023';
  END IF;

  SELECT user_id INTO v_user FROM public.sos_alerts WHERE id = p_alert_id;
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'no such SOS alert' USING ERRCODE = 'P0002';
  END IF;

  UPDATE public.sos_alerts
     SET status = 'resolved', resolved_at = now()
   WHERE id = p_alert_id;

  UPDATE public.admin_escalations
     SET acknowledged_at = coalesce(acknowledged_at, now()),
         acknowledged_by = coalesce(acknowledged_by, auth.uid())
   WHERE kind = 'sos' AND subject_id = p_alert_id AND acknowledged_at IS NULL;

  PERFORM public.log_admin_action(
    'sos.resolve', v_user,
    jsonb_build_object('alert_id', p_alert_id, 'note', p_note)
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.admin_annotate_safety_event(
  p_kind text, p_subject_id uuid, p_note text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
BEGIN
  -- Annotation changes no state, so `support` is enough. It is still audited:
  -- what an operator observed during an incident is part of the record.
  IF NOT public.is_admin('support') THEN
    RAISE EXCEPTION 'admin role required' USING ERRCODE = '42501';
  END IF;

  IF p_kind NOT IN ('sos', 'checkin') THEN
    RAISE EXCEPTION 'unknown safety event kind: %', p_kind USING ERRCODE = '22023';
  END IF;

  PERFORM public.log_admin_action(
    p_kind || '.annotate', NULL,
    jsonb_build_object('subject_id', p_subject_id, 'note', p_note)
  );
END;
$function$;

REVOKE ALL ON FUNCTION public.admin_acknowledge_sos(uuid, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.admin_acknowledge_sos(uuid, text) FROM anon;
GRANT EXECUTE ON FUNCTION public.admin_acknowledge_sos(uuid, text) TO authenticated;

REVOKE ALL ON FUNCTION public.admin_resolve_sos(uuid, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.admin_resolve_sos(uuid, text) FROM anon;
GRANT EXECUTE ON FUNCTION public.admin_resolve_sos(uuid, text) TO authenticated;

REVOKE ALL ON FUNCTION public.admin_annotate_safety_event(text, uuid, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.admin_annotate_safety_event(text, uuid, text) FROM anon;
GRANT EXECUTE ON FUNCTION public.admin_annotate_safety_event(text, uuid, text) TO authenticated;
