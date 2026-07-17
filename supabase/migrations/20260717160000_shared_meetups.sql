-- ============================================================================
-- Story 0.7 — create `shared_meetups` (the table FOUNDATIONS §5 KEEPs)
--
-- ⚠ SAFETY-SENSITIVE. §5 names this table, by name, inside the safety pillar
-- — "the differentiator" — yet no migration ever created it. ShareMeetupScreen
-- is a LIVE route (go_router_config.dart:320) whose insert has always failed:
-- telling a trusted contact where you are meeting a stranger did not work.
--
-- Shape is derived from the screen's existing insert payload
-- (share_meetup_screen.dart:290) — the client contract predates the table.
-- `shared_with_contact_ids` holds trusted_contacts ROW ids (not user ids);
-- a contact who is also a registered user (trusted_contacts.contact_user_id)
-- can read shares addressed to them — that visibility is the feature.
--
-- Grants: covered by the default privileges from 20260717150000 (this is the
-- first table created after it; the pgTAP pins that the mechanism worked).
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.shared_meetups (
  id                        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                   uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  meeting_with              text NOT NULL CHECK (char_length(meeting_with) BETWEEN 1 AND 200),
  location_name             text NOT NULL CHECK (char_length(location_name) BETWEEN 1 AND 300),
  meetup_time               timestamptz NOT NULL,
  notes                     text CHECK (notes IS NULL OR char_length(notes) <= 2000),
  shared_with_contact_ids   uuid[] NOT NULL DEFAULT '{}',
  created_at                timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_shared_meetups_user    ON public.shared_meetups (user_id);
CREATE INDEX IF NOT EXISTS idx_shared_meetups_time    ON public.shared_meetups (meetup_time);
CREATE INDEX IF NOT EXISTS idx_shared_meetups_contacts ON public.shared_meetups USING gin (shared_with_contact_ids);

ALTER TABLE public.shared_meetups ENABLE ROW LEVEL SECURITY;

-- Owner: full control of their own shares.
CREATE POLICY shared_meetups_owner_all ON public.shared_meetups
  FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- A registered trusted contact can READ a share addressed to them. The check
-- resolves trusted_contacts rows via a SECURITY DEFINER helper (the policy
-- must see the sharer's contact rows, which the contact's own RLS view would
-- hide — the exact caller-RLS lesson from are_users_blocked, 20260717140000).
CREATE OR REPLACE FUNCTION public.is_share_recipient(contact_row_ids uuid[], reader uuid)
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM trusted_contacts tc
    WHERE tc.id = ANY(contact_row_ids)
      AND tc.contact_user_id = reader
      AND tc.is_active = true
  );
$$;
REVOKE EXECUTE ON FUNCTION public.is_share_recipient(uuid[], uuid) FROM anon, public;
GRANT  EXECUTE ON FUNCTION public.is_share_recipient(uuid[], uuid) TO authenticated, service_role;

CREATE POLICY shared_meetups_contact_read ON public.shared_meetups
  FOR SELECT
  USING (is_share_recipient(shared_with_contact_ids, auth.uid()));

COMMENT ON TABLE public.shared_meetups IS
  'Meetup details shared with trusted contacts (safety pillar, FOUNDATIONS §5). Created 2026-07-17 — the client wrote here since Sprint-era but the table never existed (Story 0.7).';
