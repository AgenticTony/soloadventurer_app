-- ============================================================================
-- Codify the platform bootstrap grants (CI-hermeticity, the general fix)
--
-- Hosted Supabase bootstraps `GRANT ALL ON ALL TABLES IN SCHEMA public TO
-- anon, authenticated, service_role` (+ matching default privileges); RLS is
-- the row gate. The ephemeral CI stack used by `supabase test db` does NOT
-- replay that bootstrap, so every pgTAP test that touches a new table as
-- `authenticated` fails with "permission denied" — first `reports`
-- (20260717090000), then `blocks`/`connections` (20260717120000), then
-- `profile_privacy_settings` and `trips` (via policy subqueries and direct
-- reads, 2026-07-17 CI run). Chasing these one table at a time is
-- whack-a-mole; this migration replicates the bootstrap explicitly so
-- MIGRATIONS ALONE define access, identically everywhere.
--
-- Verified against live prod before writing: anon/authenticated already hold
-- these table privileges (e.g. anon INSERT on trips is TRUE) — this is a
-- strict prod NO-OP. Whether to TIGHTEN anon's broad grants is a real
-- decision, but it is an H.5 follow-up to be made deliberately, not smuggled
-- into a hermeticity fix.
--
-- ⚠ THE ONE EXCEPTION — profiles PII posture (20260708093000): that migration
-- REVOKEd table-level SELECT on profiles and re-granted per non-PII column.
-- A blanket grant would silently re-widen it, so the revoke is re-applied
-- immediately below. The column-level grants are separate ACL entries and
-- remain in force; profiles_pii_column_privileges.test.sql pins the posture.
--
-- The per-table loop (rather than GRANT ON ALL TABLES) skips tables this
-- role does not own — e.g. postgis's spatial_ref_sys — instead of aborting.
-- ============================================================================

DO $$
DECLARE t record;
BEGIN
  FOR t IN SELECT tablename FROM pg_tables WHERE schemaname = 'public'
  LOOP
    BEGIN
      EXECUTE format(
        'GRANT ALL ON TABLE public.%I TO anon, authenticated, service_role;',
        t.tablename
      );
    EXCEPTION WHEN insufficient_privilege THEN
      RAISE NOTICE 'codify_bootstrap_grants: skipping % (not owner)', t.tablename;
    END;
  END LOOP;
END $$;

-- Restore the Batch-2 PII posture the blanket grant just re-widened.
REVOKE SELECT ON public.profiles FROM authenticated, anon;

-- Sequences + future objects, matching the platform bootstrap.
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;
