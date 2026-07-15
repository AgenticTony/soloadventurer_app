-- ============================================================================
-- Durable PII fix — profiles column-level privileges (audit blocker #2 / step-8)
-- ============================================================================
-- REQUIRES HUMAN SIGN-OFF — RLS/privilege change on PII (safety-sensitive).
--
-- The row-level fix (drop USING(true), 20260708090000) stops blanket profile
-- reads. This is the DURABLE, column-level backstop: even a permissive policy or
-- a stray `select('*')` can never return email / phone / date_of_birth to a
-- client role, because the privilege is removed at the column level.
--
-- Approach: Postgres can't revoke a single column's SELECT while a table-level
-- SELECT grant stands, so we REVOKE the table-level SELECT and re-GRANT SELECT on
-- every NON-PII column. Done DYNAMICALLY from information_schema so it is
-- schema-agnostic — it also covers prod's dashboard-only columns
-- (subscription_tier, subscription_created_at, ...) that this repo's migrations
-- don't declare, without stranding them.
--
-- service_role is untouched (edge functions / admin). Writes are untouched —
-- profile edit still works (UPDATE needs no SELECT; RETURNING was removed from
-- the one client that used it, upload_sync).
--
-- DEPLOY ORDER (⚠): both clients must be converted off `select('*')` on profiles
-- and DEPLOYED before this is `db push`ed —
--   web  PR: fix/profiles-pii-explicit-columns (authService/userService)
--   mobile: this branch also carries the upload_sync `.select()` -> `.select('id')` fix
-- Nothing reads phone/date_of_birth anywhere (verified web+mobile); email is
-- always sourced from the auth session, so no owner-read RPC is required.
--
-- Docs grounded (→ PR "Sources"):
--   • https://supabase.com/docs/guides/database/postgres/column-level-security
--   • https://www.postgresql.org/docs/current/ddl-priv.html  (column privileges)
-- ============================================================================

DO $$
DECLARE
  v_nonpii text;
BEGIN
  SELECT string_agg(quote_ident(column_name), ', ' ORDER BY ordinal_position)
    INTO v_nonpii
    FROM information_schema.columns
   WHERE table_schema = 'public'
     AND table_name   = 'profiles'
     AND column_name NOT IN ('email', 'phone', 'date_of_birth');

  IF v_nonpii IS NULL THEN
    RAISE EXCEPTION 'profiles has no non-PII columns — aborting privilege change';
  END IF;

  -- authenticated: no blanket table SELECT; column SELECT on non-PII only.
  EXECUTE 'REVOKE SELECT ON public.profiles FROM authenticated';
  EXECUTE format('GRANT SELECT (%s) ON public.profiles TO authenticated', v_nonpii);

  -- anon: same (public profile reads are RLS-gated and go via get_profile_safe,
  -- a SECURITY DEFINER RPC that is unaffected by these client-role grants).
  EXECUTE 'REVOKE SELECT ON public.profiles FROM anon';
  EXECUTE format('GRANT SELECT (%s) ON public.profiles TO anon', v_nonpii);
END $$;

COMMENT ON COLUMN public.profiles.email IS
  'PII — SELECT revoked from anon/authenticated (column privileges). Own email is '
  'read from the auth session, not this column; service_role/RPCs may still read it.';
