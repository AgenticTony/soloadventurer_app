-- Migration: 20260814100000_admin_foundation.sql
-- Purpose: Admin dashboard Phase 0 — identity, authorisation, audit.
--
-- Design: docs/design/admin-dashboard-v0.1.md (v0.2, decisions signed off
-- 2026-08-14). This ships the foundation only. No admin *verbs* yet
-- (adjudicate_report, resolve_sos_alert_admin, override_verification) — those
-- land with the surfaces that need them, in phases 1–3.
--
-- Why this exists: every safety table is scoped to the people involved, so
-- nobody at the company can see an SOS alert, a missed check-in, a declined
-- verification, or a report. This is the layer that makes an operator possible.
--
-- Two decisions from §8 shape the whole design:
--
--   * The dashboard never holds `service_role`. Reads are granted by RLS keyed
--     on the admin's own JWT via is_admin(); writes will be named SECURITY
--     DEFINER verbs. A compromised admin session is bounded by role, not handed
--     a key that bypasses RLS entirely.
--   * Privileged READS are audited, not just writes. On this surface, looking is
--     the sensitive act — an admin browsing location history would otherwise
--     leave no trace.

-- ---------------------------------------------------------------------------
-- 1. Roles
-- ---------------------------------------------------------------------------
-- Deliberately few, and ordered: owner > moderator > support. The enum order is
-- load-bearing — is_admin() compares against it for the hierarchy check, so new
-- roles must be added in the correct position, not appended.

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'admin_role') THEN
    CREATE TYPE public.admin_role AS ENUM ('support', 'moderator', 'owner');
  END IF;
END$$;

-- ---------------------------------------------------------------------------
-- 2. Admin identity
-- ---------------------------------------------------------------------------
-- A table rather than `profiles.is_admin`, because:
--   * roles are not a boolean — support reads, moderator acts, owner grants;
--   * grant and revoke become auditable events with an actor;
--   * admin state stays off the row ordinary matching reads, so it can never
--     leak through a profile projection.
--
-- Admin accounts are SEPARATE identities from personal user accounts (§8.1), so
-- an admin browsing cannot act as a user by accident.

CREATE TABLE IF NOT EXISTS public.admin_users (
  user_id     uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  role        public.admin_role NOT NULL,
  granted_by  uuid REFERENCES public.profiles(id),
  granted_at  timestamptz NOT NULL DEFAULT now(),
  revoked_at  timestamptz,
  note        text
);

COMMENT ON TABLE public.admin_users IS
  'Admin roster. Revocation is `revoked_at`, never DELETE — the grant history is '
  'itself evidence. Not readable by `authenticated`: who holds admin is not '
  'public information.';

CREATE INDEX IF NOT EXISTS idx_admin_users_active
  ON public.admin_users (user_id) WHERE revoked_at IS NULL;

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

-- No policies for anon/authenticated at all: the roster is invisible to the app.
-- is_admin() reads it as SECURITY DEFINER, which bypasses RLS; that is the only
-- intended read path. Disclosing the admin roster would hand an attacker a
-- target list.

-- ---------------------------------------------------------------------------
-- 3. Authorisation
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.is_admin(min_role public.admin_role DEFAULT 'support')
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
  select exists (
    select 1
    from public.admin_users a
    where a.user_id = auth.uid()
      and a.revoked_at is null
      -- Enum ordering gives the hierarchy: owner >= moderator >= support.
      and a.role >= min_role
  );
$function$;

COMMENT ON FUNCTION public.is_admin(public.admin_role) IS
  'True when the CURRENT caller holds an unrevoked admin role at or above '
  'min_role. Takes no user_id parameter deliberately — a function that could '
  'answer "is X an admin" for arbitrary X would leak the roster.';

REVOKE ALL ON FUNCTION public.is_admin(public.admin_role) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.is_admin(public.admin_role) FROM anon;
GRANT EXECUTE ON FUNCTION public.is_admin(public.admin_role) TO authenticated;

-- ---------------------------------------------------------------------------
-- 4. Audit log
-- ---------------------------------------------------------------------------
-- Append-only. Follows the shape of gender_change_audit_log, which already
-- records ip_address and user_agent alongside the change.
--
-- `actor_id` is nullable so an AGENT can be the actor (design §9.5): agent
-- entries carry model / prompt version / confidence in `detail`, so a
-- systematically bad batch can be found and re-triaged.

CREATE TABLE IF NOT EXISTS public.admin_audit_log (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id    uuid REFERENCES public.profiles(id),
  actor_kind  text NOT NULL DEFAULT 'admin' CHECK (actor_kind IN ('admin', 'agent', 'system')),
  action      text NOT NULL,
  subject_id  uuid,
  detail      jsonb NOT NULL DEFAULT '{}'::jsonb,
  ip_address  inet,
  user_agent  text,
  created_at  timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.admin_audit_log IS
  'Append-only record of admin and agent activity, including privileged READS '
  '(§2). No UPDATE or DELETE policy exists for any role — an audit trail that '
  'its subject can edit is not an audit trail.';

COMMENT ON COLUMN public.admin_audit_log.action IS
  'Dotted verb: report.adjudicate, sos.resolve, user.view, pii.read, '
  'admin.grant. Reads are recorded as first-class actions.';

CREATE INDEX IF NOT EXISTS idx_admin_audit_actor   ON public.admin_audit_log (actor_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_admin_audit_subject ON public.admin_audit_log (subject_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_admin_audit_action  ON public.admin_audit_log (action, created_at DESC);

ALTER TABLE public.admin_audit_log ENABLE ROW LEVEL SECURITY;

-- Read: an admin sees their own trail; only `owner` sees everyone's.
CREATE POLICY "admin_audit: read own, owner reads all"
  ON public.admin_audit_log FOR SELECT
  TO authenticated
  USING (
    (public.is_admin('support') AND actor_id = auth.uid())
    OR public.is_admin('owner')
  );

-- Deliberately NO insert / update / delete policies.
-- Writes arrive only through log_admin_action() below (SECURITY DEFINER), which
-- keeps the log append-only even for `owner`.

-- ---------------------------------------------------------------------------
-- 5. The audit writer
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.log_admin_action(
  p_action     text,
  p_subject_id uuid DEFAULT NULL,
  p_detail     jsonb DEFAULT '{}'::jsonb,
  p_ip         inet DEFAULT NULL,
  p_user_agent text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_id uuid;
BEGIN
  IF NOT public.is_admin('support') THEN
    RAISE EXCEPTION 'not an admin' USING ERRCODE = '42501';
  END IF;

  INSERT INTO public.admin_audit_log
    (actor_id, actor_kind, action, subject_id, detail, ip_address, user_agent)
  VALUES
    (auth.uid(), 'admin', p_action, p_subject_id, coalesce(p_detail, '{}'::jsonb), p_ip, p_user_agent)
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$function$;

COMMENT ON FUNCTION public.log_admin_action(text, uuid, jsonb, inet, text) IS
  'Records an admin action or privileged read. The only write path into '
  'admin_audit_log — the table has no INSERT policy, so this cannot be bypassed '
  'from a client.';

REVOKE ALL ON FUNCTION public.log_admin_action(text, uuid, jsonb, inet, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.log_admin_action(text, uuid, jsonb, inet, text) FROM anon;
GRANT EXECUTE ON FUNCTION public.log_admin_action(text, uuid, jsonb, inet, text) TO authenticated;

-- ---------------------------------------------------------------------------
-- 6. Admin read access to the safety tables
-- ---------------------------------------------------------------------------
-- Added as SEPARATE policies rather than by editing the existing ones. Postgres
-- ORs permissive policies together, so this widens access for admins without
-- touching the user-facing rules — and it can be dropped independently if admin
-- access is ever withdrawn.
--
-- These grant READ only. Every admin mutation will be a named verb in a later
-- phase.
--
-- Note the asymmetry with the audit requirement: RLS cannot itself log a read.
-- The dashboard is responsible for calling log_admin_action('...view', subject)
-- alongside each privileged read, and that obligation is enforced by review and
-- by the pgTAP in the surface phases — not by the database. Flagged here so the
-- gap is visible rather than assumed closed.

CREATE POLICY "sos_alerts: admin read"
  ON public.sos_alerts FOR SELECT
  TO authenticated
  USING (public.is_admin('support'));

CREATE POLICY "meetup_checkins: admin read"
  ON public.meetup_checkins FOR SELECT
  TO authenticated
  USING (public.is_admin('support'));

CREATE POLICY "verification_records: admin read"
  ON public.verification_records FOR SELECT
  TO authenticated
  USING (public.is_admin('support'));

CREATE POLICY "reports: admin read"
  ON public.reports FOR SELECT
  TO authenticated
  USING (public.is_admin('support'));

CREATE POLICY "blocks: admin read"
  ON public.blocks FOR SELECT
  TO authenticated
  USING (public.is_admin('support'));
