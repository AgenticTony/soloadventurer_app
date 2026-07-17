-- pgTAP — Story 0.7: get_entries_near_location + travel_preferences.
-- Run: `supabase test db`
--
-- Both were phantoms: the journal datasources have called this RPC since they
-- were written; the offline sync pipeline has written to travel_preferences
-- since it was built. Neither existed. Proves the RPC's self-only guard and
-- geographic filtering (Malmo entry within 10km, Stockholm entry excluded),
-- and travel_preferences' owner-only RLS + one-row-per-user shape.

begin;
select plan(9);

insert into auth.users (id, email) values
  ('aaaaaaaa-0009-0009-0009-aaaaaaaaaaaa', 'geo_a@test.local'),
  ('bbbbbbbb-0009-0009-0009-bbbbbbbbbbbb', 'geo_b@test.local');
insert into public.profiles (id, username) values
  ('aaaaaaaa-0009-0009-0009-aaaaaaaaaaaa', 'geo_user_a'),
  ('bbbbbbbb-0009-0009-0009-bbbbbbbbbbbb', 'geo_user_b');
-- A's entries: one in central Malmo, one in Stockholm (~515 km away).
insert into public.journal_entries (user_id, title, content, latitude, longitude) values
  ('aaaaaaaa-0009-0009-0009-aaaaaaaaaaaa', 'Malmo coffee', 'x', 55.6050, 13.0038),
  ('aaaaaaaa-0009-0009-0009-aaaaaaaaaaaa', 'Stockholm day', 'x', 59.3293, 18.0686);

set local role authenticated;

-- ============================================================================
-- 1. get_entries_near_location (4)
-- ============================================================================
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0009-0009-0009-aaaaaaaaaaaa","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.get_entries_near_location(
     'aaaaaaaa-0009-0009-0009-aaaaaaaaaaaa', 55.6050, 13.0038, 10.0)),
  1,
  'returns the Malmo entry within 10km and excludes Stockholm'
);
select is(
  (select title from public.get_entries_near_location(
     'aaaaaaaa-0009-0009-0009-aaaaaaaaaaaa', 55.6050, 13.0038, 10.0) limit 1),
  'Malmo coffee'::varchar,
  'nearest entry comes back first'
);
select is(
  (select count(*)::int from public.get_entries_near_location(
     'aaaaaaaa-0009-0009-0009-aaaaaaaaaaaa', 55.6050, 13.0038, 600.0)),
  2,
  'a 600km radius reaches Stockholm too'
);
select throws_ok(
  $$select * from public.get_entries_near_location(
      'bbbbbbbb-0009-0009-0009-bbbbbbbbbbbb', 55.6050, 13.0038, 10.0)$$,
  'P0001',
  'get_entries_near_location: can only query your own entries',
  'cross-user queries fail loudly (find_semantic_matches pattern)'
);

-- ============================================================================
-- 2. travel_preferences (5)
-- ============================================================================
select lives_ok(
  $$insert into public.travel_preferences
      (user_id, travel_styles, min_budget, max_budget, min_trip_duration, max_trip_duration)
    values ('aaaaaaaa-0009-0009-0009-aaaaaaaaaaaa', array['backpacking'], 100, 500, 3, 14)$$,
  'owner can insert their preferences'
);
select throws_ok(
  $$insert into public.travel_preferences (user_id, min_budget, max_budget)
    values ('aaaaaaaa-0009-0009-0009-aaaaaaaaaaaa', 0, 0)$$,
  '23505', null,
  'one preferences row per user (UNIQUE user_id — keeps the sync pipeline idempotent)'
);
select throws_ok(
  $$insert into public.travel_preferences (user_id)
    values ('bbbbbbbb-0009-0009-0009-bbbbbbbbbbbb')$$,
  '42501', null,
  'cannot insert preferences for someone else (RLS)'
);
select set_config('request.jwt.claims',
  '{"sub":"bbbbbbbb-0009-0009-0009-bbbbbbbbbbbb","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.travel_preferences),
  0,
  'preferences are private — another user reads nothing (matching input, L1 signal)'
);
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0009-0009-0009-aaaaaaaaaaaa","role":"authenticated"}', true);
select is(
  (select max_budget from public.travel_preferences limit 1),
  500,
  'owner reads their own preferences back'
);

reset role;
select * from finish();
rollback;
