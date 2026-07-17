-- pgTAP — policy recursion fix + women-only gating on direct reads.
-- Run: `supabase test db`
--
-- Pins 20260717140000. Before it, EVERY direct authenticated SELECT on
-- profiles or trips threw `42P17 infinite recursion` (confirmed against live
-- prod): the matching policies selected from the very tables they guard.
-- Assertions 5-6 are the regression pin — if anyone reintroduces a
-- self-referential subquery into these policies, they fail loudly.
--
-- Assertions 7-9 are **Story 0.5 box 4's women-only clause**: the audit's
-- P0 #2 claimed `USING (true)` made women-only gating a dead letter for
-- direct reads; this is the first functional proof the gating actually holds
-- now that the policies can be evaluated at all.
--
-- Assertion 11 pins the are_users_blocked symmetry repair: as caller-RLS
-- plpgsql, the BLOCKED user could not see the blocker's row, so the check
-- silently held in one direction only. SECURITY DEFINER restores the
-- documented "either user has blocked the other" semantics.

begin;
select plan(12);

-- ============================================================================
-- 1. Structure (4)
-- ============================================================================
select ok(
  (SELECT prosecdef FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname='public' AND p.proname='are_users_blocked'),
  'are_users_blocked is SECURITY DEFINER (direction-proof under RLS)'
);
select ok(
  (SELECT prosecdef FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname='public' AND p.proname='wants_women_only'),
  'wants_women_only is SECURITY DEFINER'
);
select ok(
  NOT EXISTS (SELECT 1 FROM pg_policies
    WHERE tablename='profiles' AND policyname='profiles_read_potential_matches'
      AND (qual LIKE '%FROM profiles%' OR qual LIKE '%FROM trips%')),
  'profiles matching policy no longer embeds recursive subqueries'
);
select ok(
  NOT EXISTS (SELECT 1 FROM pg_policies
    WHERE tablename='trips' AND policyname='trips_read_for_matching'
      AND (qual LIKE '%FROM profiles%' OR qual LIKE '%FROM trips%')),
  'trips matching policy no longer embeds recursive subqueries'
);

-- ============================================================================
-- Seed: W (verified female, women-only mode ON), M (male, unverified),
--       F (verified female) — all with overlapping public trips.
-- ============================================================================
insert into auth.users (id, email) values
  ('aaaaaaaa-0005-0005-0005-aaaaaaaaaaaa', 'wo_w@test.local'),
  ('bbbbbbbb-0005-0005-0005-bbbbbbbbbbbb', 'wo_m@test.local'),
  ('cccccccc-0005-0005-0005-cccccccccccc', 'wo_f@test.local');
insert into public.profiles (id, username, gender, gender_verified, women_only_mode_enabled) values
  ('aaaaaaaa-0005-0005-0005-aaaaaaaaaaaa', 'wo_user_w', 'female', true,  true),
  ('bbbbbbbb-0005-0005-0005-bbbbbbbbbbbb', 'wo_user_m', 'male',   false, false),
  ('cccccccc-0005-0005-0005-cccccccccccc', 'wo_user_f', 'female', true,  false);
insert into public.trips (user_id, name, start_date, end_date, is_active, is_public) values
  ('aaaaaaaa-0005-0005-0005-aaaaaaaaaaaa', 'w trip', '2026-08-01', '2026-08-10', true, true),
  ('bbbbbbbb-0005-0005-0005-bbbbbbbbbbbb', 'm trip', '2026-08-03', '2026-08-12', true, true),
  ('cccccccc-0005-0005-0005-cccccccccccc', 'f trip', '2026-08-05', '2026-08-15', true, true);

set local role authenticated;

-- ============================================================================
-- 2. The 42P17 regression pin (2)
-- ============================================================================
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0005-0005-0005-aaaaaaaaaaaa","role":"authenticated"}', true);
select lives_ok(
  $$select count(*) from public.profiles$$,
  'direct authenticated SELECT on profiles no longer recurses (was 42P17, incl. in prod)'
);
select lives_ok(
  $$select count(*) from public.trips$$,
  'direct authenticated SELECT on trips no longer recurses'
);

-- ============================================================================
-- 3. Women-only gating holds on direct reads (0.5 box 4) (3)
-- ============================================================================
select is(
  (select count(*)::int from public.profiles
    where id = 'cccccccc-0005-0005-0005-cccccccccccc'),
  1,
  'women-only user CAN see a verified female with trip overlap'
);
select is(
  (select count(*)::int from public.profiles
    where id = 'bbbbbbbb-0005-0005-0005-bbbbbbbbbbbb'),
  0,
  'women-only user CANNOT see an unverified male despite trip overlap'
);
select set_config('request.jwt.claims',
  '{"sub":"cccccccc-0005-0005-0005-cccccccccccc","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.profiles
    where id = 'aaaaaaaa-0005-0005-0005-aaaaaaaaaaaa'),
  1,
  'a user WITHOUT women-only mode sees normally (the mode gates its enabler only)'
);

-- ============================================================================
-- 4. are_users_blocked is symmetric again (2)
-- ============================================================================
select set_config('request.jwt.claims',
  '{"sub":"bbbbbbbb-0005-0005-0005-bbbbbbbbbbbb","role":"authenticated"}', true);
select lives_ok(
  $$insert into public.blocks (blocker_id, blocked_id)
    values ('bbbbbbbb-0005-0005-0005-bbbbbbbbbbbb',
            'aaaaaaaa-0005-0005-0005-aaaaaaaaaaaa')$$,
  'M blocks W'
);
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0005-0005-0005-aaaaaaaaaaaa","role":"authenticated"}', true);
select ok(
  public.are_users_blocked('aaaaaaaa-0005-0005-0005-aaaaaaaaaaaa',
                           'bbbbbbbb-0005-0005-0005-bbbbbbbbbbbb'),
  'the BLOCKED user''s session also sees the block (SECURITY DEFINER; was one-directional under caller RLS)'
);

-- ============================================================================
-- 5. Trips gating works end-to-end post-fix (1)
-- ============================================================================
select is(
  (select count(*)::int from public.trips
    where user_id = 'cccccccc-0005-0005-0005-cccccccccccc'),
  1,
  'women-only user sees the verified female''s overlapping trip'
);

reset role;
select * from finish();
rollback;
