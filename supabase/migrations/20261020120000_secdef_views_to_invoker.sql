-- ============================================================================
-- Security Advisor: security_definer_view (5 views) → security_invoker
--
-- Views in Postgres run with the privileges of their OWNER by default. These
-- five were created by `postgres` (which bypasses RLS as table owner), so any
-- caller holding the anon key could read through them past RLS:
--
--   trip_summaries              every trip incl. private ones (+ counts)
--   journal_entries_with_media  every journal entry + photo/video storage paths
--   shared_links_with_trips     every share slug, incl. password-less links
--   verified_women              every gender-verified woman + home country
--   rls_policy_summary          every RLS policy's USING / WITH CHECK text
--
-- `security_invoker = on` makes each view evaluate as the querying role, so the
-- underlying tables' RLS and column grants decide what comes back — the view
-- grants nothing on its own (same posture as 20260814200000 / 20260814300000).
--
-- Consumers: none. Neither the Flutter app nor the web app queries any of these
-- views (only generated database.types.ts mentions them), so this is a strict
-- access tightening with no feature behind it to break.
--
-- rls_policy_summary is additionally revoked from anon/authenticated:
-- pg_policies is readable by PUBLIC, so invoker alone would still hand out the
-- policy text — a recon map of every RLS rule. Only service_role keeps it.
--
-- `IF EXISTS` because prod was built dashboard-first; a missing view is not an
-- error worth aborting the deploy over.
-- ============================================================================

alter view if exists public.trip_summaries             set (security_invoker = on);
alter view if exists public.journal_entries_with_media set (security_invoker = on);
alter view if exists public.shared_links_with_trips    set (security_invoker = on);
alter view if exists public.verified_women             set (security_invoker = on);
alter view if exists public.rls_policy_summary         set (security_invoker = on);

do $$
begin
  if to_regclass('public.rls_policy_summary') is not null then
    revoke all on public.rls_policy_summary from anon, authenticated;
  end if;
end $$;
