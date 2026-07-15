-- pgTAP tests for Phase 0 Story 0.5 — profiles RLS repair (step 9b; audit P0 #2).
-- Docs: https://supabase.com/docs/guides/database/testing + /extensions/pgtap
-- Run: `supabase test db`
--
-- Proves: the USING(true) blanket SELECT policy is gone, the two embedding RPCs
-- are SECURITY DEFINER with a pinned search_path and anon-revoked EXECUTE, and
-- the caller-identity guard actually raises for cross-user queries.
--
-- Auth simulation (see meetups_reputation.test.sql): auth.uid() reads the JWT
-- `sub`, so we impersonate with `set local role authenticated` +
-- set_config('request.jwt.claims', '{"sub":"<uuid>","role":"authenticated"}', true).
-- RAISE EXCEPTION → SQLSTATE P0001.

begin;
select plan(12);

-- ============================================================================
-- 1. The blanket USING(true) policy is dropped (3)
-- ============================================================================
select ok(
  NOT EXISTS (
    SELECT 1 FROM pg_policies
     WHERE schemaname = 'public' AND tablename = 'profiles'
       AND policyname = 'profiles_embedding_select_authenticated'
  ),
  'USING(true) embedding SELECT policy is dropped from profiles'
);
-- RLS still enabled on profiles (the gated policies remain in force)
select ok(
  (SELECT relrowsecurity FROM pg_class WHERE oid = 'public.profiles'::regclass),
  'RLS remains enabled on profiles'
);
-- The intended, gated potential-match policy still exists (not collateral-dropped)
select ok(
  EXISTS (
    SELECT 1 FROM pg_policies
     WHERE schemaname = 'public' AND tablename = 'profiles'
       AND policyname = 'profiles_read_potential_matches'
  ),
  'the gated potential-match SELECT policy is preserved'
);

-- ============================================================================
-- 2. Both RPCs are SECURITY DEFINER with a pinned search_path (4)
-- ============================================================================
select ok(
  (SELECT prosecdef FROM pg_proc WHERE oid = 'public.find_semantic_matches(uuid,float,int)'::regprocedure),
  'find_semantic_matches is SECURITY DEFINER'
);
select ok(
  EXISTS (
    SELECT 1 FROM pg_proc
     WHERE oid = 'public.find_semantic_matches(uuid,float,int)'::regprocedure
       AND array_to_string(proconfig, ',') LIKE '%search_path%'
  ),
  'find_semantic_matches has a pinned search_path'
);
select ok(
  (SELECT prosecdef FROM pg_proc WHERE oid = 'public.get_profile_embedding(uuid)'::regprocedure),
  'get_profile_embedding is SECURITY DEFINER'
);
select ok(
  EXISTS (
    SELECT 1 FROM pg_proc
     WHERE oid = 'public.get_profile_embedding(uuid)'::regprocedure
       AND array_to_string(proconfig, ',') LIKE '%search_path%'
  ),
  'get_profile_embedding has a pinned search_path'
);

-- ============================================================================
-- 3. EXECUTE is revoked from anon, granted to authenticated (3)
-- ============================================================================
select ok(
  NOT has_function_privilege('anon', 'public.find_semantic_matches(uuid,float,int)', 'EXECUTE'),
  'anon CANNOT execute find_semantic_matches'
);
select ok(
  has_function_privilege('authenticated', 'public.find_semantic_matches(uuid,float,int)', 'EXECUTE'),
  'authenticated CAN execute find_semantic_matches'
);
select ok(
  NOT has_function_privilege('anon', 'public.get_profile_embedding(uuid)', 'EXECUTE'),
  'anon CANNOT execute get_profile_embedding'
);

-- ============================================================================
-- 4. The caller-identity guard raises on cross-user queries (2)
-- ============================================================================
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'rls_a@test.local'),
  ('22222222-2222-2222-2222-222222222222', 'rls_b@test.local');
insert into public.profiles (id, username) values
  ('11111111-1111-1111-1111-111111111111', 'rls_user_a'),
  ('22222222-2222-2222-2222-222222222222', 'rls_user_b');

set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}', true);

select throws_ok(
  $$ select * from public.find_semantic_matches('22222222-2222-2222-2222-222222222222'::uuid) $$,
  'P0001',
  'find_semantic_matches: can only query matches for yourself',
  'authenticated caller cannot query semantic matches for another user'
);

select lives_ok(
  $$ select * from public.find_semantic_matches('11111111-1111-1111-1111-111111111111'::uuid) $$,
  'authenticated caller CAN query semantic matches for themselves'
);

reset role;
select * from finish();
rollback;
