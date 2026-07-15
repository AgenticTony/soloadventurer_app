-- ============================================================================
-- PHASE_H Story H.5 (partial) — backend privilege hardening (audit §5 / live advisors)
-- ============================================================================
-- REQUIRES HUMAN SIGN-OFF — backend privilege/RLS-adjacent (safety-sensitive).
--
-- Scope: the SECURITY DEFINER functions that ARE defined in repo migrations.
-- Two live-advisor findings, fixed without redefining any function body
-- (ALTER FUNCTION only — lowest-risk form):
--   1. function_search_path_mutable — none of these pin search_path → inject
--      via `ALTER FUNCTION ... SET search_path = public` (matches the Phase A
--      convention: SECURITY DEFINER must pin search_path).
--   2. {anon,authenticated}_security_definer_function_executable — REVOKE the
--      default PUBLIC/anon EXECUTE; re-grant only to the roles that legitimately
--      call each function.
--
-- NOT in scope (dashboard-only drift — hardened during prod reconciliation, see
-- docs/reports/prod-db-reconciliation-plan-2026-07-15.md §5): create_trip,
-- update_my_trip, delete_my_trip, get_trip_by_id, list_my_trips, get_my_uid,
-- handle_new_user. A repo migration cannot ALTER a function that no repo
-- migration defines — those are corrected against prod, not here.
--
-- Docs grounded (→ PR "Sources"):
--   • https://supabase.com/docs/guides/database/functions  (SECURITY DEFINER
--     must pin search_path; restrict EXECUTE)
--   • https://www.postgresql.org/docs/current/sql-alterfunction.html
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Pin search_path on every in-repo SECURITY DEFINER function (advisor #1).
--    `public, extensions` so PostGIS/vector operators still resolve.
-- ----------------------------------------------------------------------------
ALTER FUNCTION public.search_profiles(text, text, boolean, int, int)                 SET search_path = public, extensions;
ALTER FUNCTION public.get_profile_safe(text)                                          SET search_path = public, extensions;
ALTER FUNCTION public.get_user_feed(int, timestamptz)                                 SET search_path = public, extensions;
ALTER FUNCTION public.get_destination_posts(float, float, float, int, timestamptz)    SET search_path = public, extensions;
ALTER FUNCTION public.viewer_follows(uuid, uuid)                                      SET search_path = public, extensions;
ALTER FUNCTION public.auth_user_verification_tier()                                   SET search_path = public, extensions;
ALTER FUNCTION public.users_are_blocked(uuid, uuid)                                   SET search_path = public, extensions;
ALTER FUNCTION public.fanout_post_to_feeds(uuid, uuid)                                SET search_path = public, extensions;
ALTER FUNCTION public.create_default_privacy()                                        SET search_path = public, extensions;
ALTER FUNCTION public.sync_comment_count()                                            SET search_path = public, extensions;
ALTER FUNCTION public.remove_follows_on_block()                                       SET search_path = public, extensions;
ALTER FUNCTION public.trigger_notify_new_message()                                    SET search_path = public, extensions;

-- ----------------------------------------------------------------------------
-- 2a. Client-callable RPCs: revoke the blanket anon/PUBLIC grant, keep
--     authenticated (+ service_role for edge functions). (advisor #2)
-- ----------------------------------------------------------------------------
DO $$
DECLARE fn text;
BEGIN
  FOR fn IN SELECT unnest(ARRAY[
    'public.search_profiles(text, text, boolean, int, int)',
    'public.get_profile_safe(text)',
    'public.get_user_feed(int, timestamptz)',
    'public.get_destination_posts(float, float, float, int, timestamptz)',
    'public.viewer_follows(uuid, uuid)',
    'public.auth_user_verification_tier()',
    'public.users_are_blocked(uuid, uuid)'
  ]) LOOP
    EXECUTE format('REVOKE EXECUTE ON FUNCTION %s FROM anon, public;', fn);
    EXECUTE format('GRANT  EXECUTE ON FUNCTION %s TO authenticated, service_role;', fn);
  END LOOP;
END $$;

-- ----------------------------------------------------------------------------
-- 2b. Trigger-only functions (RETURNS TRIGGER): fire from triggers as the table
--     owner — never invoked directly, and PostgREST cannot expose them. Revoke
--     EXECUTE from every client role; the trigger path is unaffected.
-- ----------------------------------------------------------------------------
REVOKE EXECUTE ON FUNCTION public.create_default_privacy()      FROM anon, authenticated, public;
REVOKE EXECUTE ON FUNCTION public.sync_comment_count()          FROM anon, authenticated, public;
REVOKE EXECUTE ON FUNCTION public.remove_follows_on_block()     FROM anon, authenticated, public;
REVOKE EXECUTE ON FUNCTION public.trigger_notify_new_message()  FROM anon, authenticated, public;

-- ----------------------------------------------------------------------------
-- 2c. fanout_post_to_feeds: a fan-out helper (RETURNS void) that writes to many
--     users' feeds. anon must never reach it; keep authenticated (called on the
--     post-creation path) + service_role.
-- ----------------------------------------------------------------------------
REVOKE EXECUTE ON FUNCTION public.fanout_post_to_feeds(uuid, uuid) FROM anon, public;
GRANT  EXECUTE ON FUNCTION public.fanout_post_to_feeds(uuid, uuid) TO authenticated, service_role;
