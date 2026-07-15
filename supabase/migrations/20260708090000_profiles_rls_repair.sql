-- ============================================================================
-- Phase 0 Story 0.5 — Profiles RLS repair (execution-order step 9b; audit P0 #2)
-- ============================================================================
-- REQUIRES HUMAN SIGN-OFF — RLS + women-only-mode gating (safety-sensitive).
--
-- DEFECT: 20260404100000_profile_embeddings.sql created
--   CREATE POLICY "profiles_embedding_select_authenticated" ON profiles
--     FOR SELECT TO authenticated USING (true);
-- Postgres ORs permissive policies, so ANY authenticated user could SELECT
-- EVERY profiles row — including PII (email, phone, date_of_birth) — and the
-- block-list / women-only gating in 20250112000000 + 20260401150000 was
-- nullified for direct table reads.
--
-- WHY IT EXISTED: find_semantic_matches / get_profile_embedding were
-- SECURITY INVOKER, so the calling user needed read access to all rows.
-- FIX: recreate both functions as SECURITY DEFINER with explicit guards
-- INSIDE the SQL (caller identity, is_active, blocked pairs, women-only
-- mode), then drop the USING (true) policy.
--
-- Docs grounded (pinned URLs → PR "Sources"):
--   • https://supabase.com/docs/guides/database/functions
--       — SECURITY DEFINER REQUIRES `set search_path`; restrict execute
--         (revoke from public + anon, grant to the intended roles).
--   • https://supabase.com/docs/guides/database/postgres/column-level-security
--       — column-level privileges; "Restricted roles cannot use the wildcard
--         operator (*) on the affected table."
--   • https://www.postgresql.org/docs/current/ddl-priv.html
--       — table-level and column-level privileges are additive.
--
-- DURABLE PII COLUMN FIX (step-8 web finding) — ships in the FOLLOW-UP migration
-- 20260708093000_profiles_pii_column_privileges.sql, AFTER both clients' profiles
-- `select('*')` reads are converted to explicit column lists (this session:
-- web PR + mobile PR). Doing the REVOKE SELECT (email,phone,date_of_birth) here
-- would break every star-select on profiles (web authService/userService, mobile
-- upload_sync RETURNING *) and strand dashboard-only columns. Until that lands,
-- PII exposure is bounded by the row-level policies RESTORED here: another user's
-- row (and its PII) is only reachable via an explicit, block-list-aware
-- visibility path (owner / public+active / community / follower / connection /
-- potential-match) — never the blanket USING(true) read.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Recreate find_semantic_matches as SECURITY DEFINER with in-function guards.
--    Signature unchanged (p_query_user_id, p_match_threshold, p_max_results;
--    same OUT columns) so CREATE OR REPLACE swaps it in place.
--    search_path includes `extensions` in case the vector operators live there.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.find_semantic_matches(
  p_query_user_id UUID,
  p_match_threshold FLOAT DEFAULT 0.6,
  p_max_results   INT   DEFAULT 20
)
RETURNS TABLE (
  user_id          UUID,
  display_name     TEXT,
  avatar_url       TEXT,
  semantic_score   FLOAT,
  destination_name TEXT,
  start_date       DATE,
  end_date         DATE
)
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_caller_women_only         BOOLEAN;
  v_caller_is_verified_female BOOLEAN;
BEGIN
  -- Caller identity: authenticated users may only query for themselves.
  -- auth.uid() IS NULL for service_role (edge functions) — allowed through;
  -- anon/public have no EXECUTE grant at all (revoked below).
  IF auth.uid() IS NOT NULL AND auth.uid() <> p_query_user_id THEN
    RAISE EXCEPTION 'find_semantic_matches: can only query matches for yourself';
  END IF;

  SELECT COALESCE(c.women_only_mode_enabled, false),
         COALESCE(c.gender = 'female' AND c.gender_verified, false)
    INTO v_caller_women_only, v_caller_is_verified_female
    FROM public.profiles c
   WHERE c.id = p_query_user_id;

  IF NOT FOUND THEN
    RETURN;  -- no such profile → no matches
  END IF;

  RETURN QUERY
  SELECT
    p.id                                                        AS user_id,
    p.display_name,
    p.avatar_url,
    (1 - (p.profile_embedding <=> q.profile_embedding))::FLOAT  AS semantic_score,
    t.destination_name,
    t.start_date::DATE,
    t.end_date::DATE
  FROM public.profiles p
  CROSS JOIN LATERAL (
    SELECT profile_embedding FROM public.profiles WHERE id = p_query_user_id
  ) q
  JOIN public.trips t ON t.user_id = p.id AND t.is_active = true
  WHERE p.id <> p_query_user_id
    AND p.is_active = true
    AND p.profile_embedding IS NOT NULL
    AND q.profile_embedding IS NOT NULL
    AND (1 - (p.profile_embedding <=> q.profile_embedding)) >= p_match_threshold
    -- SECURITY DEFINER bypasses RLS → re-apply the gating explicitly:
    -- (a) blocked pairs never match (mirrors profiles_read_potential_matches)
    AND NOT public.are_users_blocked(p_query_user_id, p.id)
    -- (b) caller in women-only mode sees only verified women
    AND (NOT v_caller_women_only
         OR (p.gender = 'female' AND p.gender_verified = true))
    -- (c) a member in women-only mode is only surfaced to verified women
    AND (COALESCE(p.women_only_mode_enabled, false) = false
         OR v_caller_is_verified_female)
  ORDER BY (p.profile_embedding <=> q.profile_embedding) ASC
  LIMIT p_max_results;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.find_semantic_matches(UUID, FLOAT, INT) FROM public, anon;
GRANT  EXECUTE ON FUNCTION public.find_semantic_matches(UUID, FLOAT, INT) TO authenticated, service_role;

COMMENT ON FUNCTION public.find_semantic_matches(UUID, FLOAT, INT) IS
  'Semantic match candidates for the CALLING user only (auth.uid() enforced; '
  'service_role exempt for edge functions). SECURITY DEFINER with explicit '
  'is_active / block-list / women-only guards — replaces the USING(true) '
  'profiles policy dropped by 20260708090000_profiles_rls_repair.';

-- ----------------------------------------------------------------------------
-- 2. Recreate get_profile_embedding as SECURITY DEFINER, own-row only.
--    No callers in mobile lib/ or supabase/functions/ today (verified by grep);
--    restricting to the caller's own embedding is the safe projection.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_profile_embedding(p_user_id UUID)
RETURNS vector
LANGUAGE plpgsql STABLE
SECURITY DEFINER
SET search_path = public, extensions
AS $$
BEGIN
  IF auth.uid() IS NOT NULL AND auth.uid() <> p_user_id THEN
    RAISE EXCEPTION 'get_profile_embedding: can only read your own embedding';
  END IF;
  RETURN (SELECT profile_embedding FROM public.profiles WHERE id = p_user_id);
END;
$$;

REVOKE EXECUTE ON FUNCTION public.get_profile_embedding(UUID) FROM public, anon;
GRANT  EXECUTE ON FUNCTION public.get_profile_embedding(UUID) TO authenticated, service_role;

COMMENT ON FUNCTION public.get_profile_embedding(UUID) IS
  'Own profile embedding only (auth.uid() enforced; service_role exempt). '
  'SECURITY DEFINER — no longer needs a permissive profiles SELECT policy.';

-- ----------------------------------------------------------------------------
-- 3. Drop the USING (true) policy — the functions above no longer need it.
--    Remaining SELECT paths on profiles are the intended, gated ones:
--    owner / public+active / community / accepted-follower (20250112000000)
--    and connected / potential-match with women-only + block gating
--    (20260401150000).
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "profiles_embedding_select_authenticated" ON public.profiles;
