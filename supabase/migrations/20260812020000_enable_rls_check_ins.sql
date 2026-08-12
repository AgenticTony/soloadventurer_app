-- Migration: 20260812020000_enable_rls_check_ins.sql
-- Purpose: Enable RLS on check_ins with owner-scoped policies.
--
-- The audit (2026-08-12) identified check_ins as having RLS disabled —
-- fully exposed to anon (readable and writable by anyone with the public
-- anon key). This defeats the missed-check-in safety escalation because
-- an attacker can mark a check-in complete.
--
-- Policies:
--   - Owner can SELECT, INSERT, UPDATE their own check_ins
--   - Anon gets no access
--   - Service role bypasses RLS (used by process-checkin edge function)
--
-- Safety-sensitive: requires human sign-off per CLAUDE.md.
-- Refs: Full audit 2026-08-12, Section 03, P1 finding.

-- 1. Enable RLS
ALTER TABLE public.check_ins ENABLE ROW LEVEL SECURITY;

-- 2. Owner-scoped SELECT policy
DROP POLICY IF EXISTS check_ins_owner_select ON public.check_ins;
CREATE POLICY check_ins_owner_select
  ON public.check_ins
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- 3. Owner-scoped INSERT policy
DROP POLICY IF EXISTS check_ins_owner_insert ON public.check_ins;
CREATE POLICY check_ins_owner_insert
  ON public.check_ins
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- 4. Owner-scoped UPDATE policy (e.g., marking a check-in complete)
DROP POLICY IF EXISTS check_ins_owner_update ON public.check_ins;
CREATE POLICY check_ins_owner_update
  ON public.check_ins
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- 5. No DELETE policy — check_ins are safety audit records and should
--    not be deletable by the owner. Only service_role can delete (bypasses RLS).
