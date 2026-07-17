-- ============================================================================
-- Fix: RLS policy recursion on profiles/trips + one-directional block check
--
-- ⚠ SAFETY-SENSITIVE: this touches the women-only enforcement path and the
-- block check. Semantics are preserved verbatim (and in two cases repaired to
-- what they were always intended to be); only the EVALUATION MECHANISM changes.
--
-- WHAT WAS BROKEN (found 2026-07-17 when blocks_sever_and_gate.test.sql did
-- the first-ever direct `SELECT FROM profiles` as `authenticated`; confirmed
-- against LIVE PROD, which throws the same error):
--
--   ERROR 42P17: infinite recursion detected in policy for relation "profiles"
--
-- 1. `profiles_read_potential_matches` (a policy ON profiles) contains
--    `SELECT .. FROM profiles` — direct self-recursion — and
--    `SELECT .. FROM trips`, whose own policy selects from profiles again:
--    a mutual cycle. `trips_read_for_matching` likewise selects from both.
--    EVERY direct authenticated read of profiles or trips fails in prod.
--    This was armed by Story 0.5's (correct) drop of the blanket USING(true)
--    policy: while that existed, the OR constant-folded to true and the
--    recursive branches were never evaluated. Nothing noticed because prod
--    has zero users and all earlier tests went through SECURITY DEFINER RPCs.
--
-- 2. `are_users_blocked()` ran as the CALLER under RLS. The blocks policy is
--    "owner all" (blocker_id = auth.uid()), so the BLOCKED user cannot see
--    the blocker's row — the deliberately symmetric check silently degraded
--    to one direction. The severing trigger (20260717120000) masked this.
--
-- THE FIX — the standard idiom: policy predicates become SECURITY DEFINER
-- helper functions (STABLE, pinned search_path, EXECUTE revoked from anon and
-- public per H.5). SECURITY DEFINER is not a loosening here — it is the
-- CORRECT semantics for a policy predicate: the women-only / overlap / block
-- facts must be evaluated against the actual data, not against the caller's
-- RLS-filtered view of it (which is what caused both defects above).
-- ============================================================================

-- ── 1. are_users_blocked: same signature, now direction-proof ──────────────
CREATE OR REPLACE FUNCTION public.are_users_blocked(user_a UUID, user_b UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM blocks
    WHERE (blocker_id = user_a AND blocked_id = user_b)
       OR (blocker_id = user_b AND blocked_id = user_a)
  );
END;
$$;
REVOKE EXECUTE ON FUNCTION public.are_users_blocked(UUID, UUID) FROM anon, public;
GRANT  EXECUTE ON FUNCTION public.are_users_blocked(UUID, UUID) TO authenticated, service_role;

-- ── 2. Predicate helpers (replace the recursive subqueries verbatim) ───────
CREATE OR REPLACE FUNCTION public.wants_women_only(check_user UUID)
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    (SELECT women_only_mode_enabled FROM profiles WHERE id = check_user),
    false
  );
$$;

CREATE OR REPLACE FUNCTION public.is_verified_female(check_user UUID)
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = check_user AND gender = 'female' AND gender_verified = true
  );
$$;

CREATE OR REPLACE FUNCTION public.users_have_trip_overlap(user_a UUID, user_b UUID)
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM trips t1, trips t2
    WHERE t1.user_id = user_a
      AND t2.user_id = user_b
      AND (t1.is_active = true OR t1.is_public = true)
      AND (t2.is_active = true OR t2.is_public = true)
      AND t1.start_date <= t2.end_date
      AND t1.end_date >= t2.start_date
  );
$$;

CREATE OR REPLACE FUNCTION public.caller_trip_overlaps(check_user UUID, range_start TIMESTAMPTZ, range_end TIMESTAMPTZ)
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM trips t
    WHERE t.user_id = check_user
      AND (t.is_active = true OR t.is_public = true)
      AND t.start_date <= range_end
      AND t.end_date >= range_start
  );
$$;

REVOKE EXECUTE ON FUNCTION public.wants_women_only(UUID)                    FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.is_verified_female(UUID)                  FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.users_have_trip_overlap(UUID, UUID)       FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.caller_trip_overlaps(UUID, TIMESTAMPTZ, TIMESTAMPTZ)    FROM anon, public;
GRANT  EXECUTE ON FUNCTION public.wants_women_only(UUID)                    TO authenticated, service_role;
GRANT  EXECUTE ON FUNCTION public.is_verified_female(UUID)                  TO authenticated, service_role;
GRANT  EXECUTE ON FUNCTION public.users_have_trip_overlap(UUID, UUID)       TO authenticated, service_role;
GRANT  EXECUTE ON FUNCTION public.caller_trip_overlaps(UUID, TIMESTAMPTZ, TIMESTAMPTZ)    TO authenticated, service_role;

-- ── 3. profiles_read_potential_matches — semantics verbatim, no recursion ──
DROP POLICY IF EXISTS profiles_read_potential_matches ON public.profiles;
CREATE POLICY profiles_read_potential_matches ON public.profiles
  FOR SELECT
  USING (
    auth.uid() != id
    AND (
      NOT wants_women_only(auth.uid())
      OR (gender = 'female' AND gender_verified = true)
    )
    AND NOT are_users_blocked(auth.uid(), id)
    AND users_have_trip_overlap(auth.uid(), profiles.id)
  );
COMMENT ON POLICY profiles_read_potential_matches ON public.profiles IS
  'Users can see basic info of potential matches, respecting women-only mode (recursion-free since 20260717140000)';

-- ── 4. trips_read_for_matching — semantics verbatim, no recursion ──────────
DROP POLICY IF EXISTS trips_read_for_matching ON public.trips;
CREATE POLICY trips_read_for_matching ON public.trips
  FOR SELECT
  USING (
    auth.uid() != user_id
    AND (is_active = true OR is_public = true)
    AND (
      visibility = 'everyone'
      OR (visibility = 'women-only' AND is_verified_female(auth.uid()))
    )
    AND (
      NOT wants_women_only(auth.uid())
      OR is_verified_female(trips.user_id)
    )
    AND caller_trip_overlaps(auth.uid(), trips.start_date, trips.end_date)
    AND NOT are_users_blocked(auth.uid(), trips.user_id)
  );
COMMENT ON POLICY trips_read_for_matching ON public.trips IS
  'Users can see trips for matching, filtered by visibility and women-only mode (recursion-free since 20260717140000)';
