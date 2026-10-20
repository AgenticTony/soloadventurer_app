-- pgTAP — PostGIS moved out of `public` into `extensions`.
-- Run: `supabase test db`
--
-- Proves migration 20261020130000. The assertions that matter:
--
--   * PostGIS lives in `extensions`, so spatial_ref_sys & co. are no longer in
--     an API-exposed schema (the rls_disabled_in_public finding is gone)
--   * everything the CASCADE took came back: 8 geography columns, 6 spatial
--     indexes, 4 geography-signature functions
--   * access did not drift: recreated functions keep PUBLIC execute (their
--     pre-move ACL), trigger_sos keeps anon locked out
--   * functions pinned to `public` were re-pinned so ST_* still resolves —
--     proven by calling them, not by reading proconfig alone

begin;
select plan(17);

-- ---------------------------------------------------------------------------
-- 1. The move (3)
-- ---------------------------------------------------------------------------
select is(
  (select extnamespace::regnamespace::text from pg_extension where extname = 'postgis'),
  'extensions',
  'postgis is installed in the extensions schema'
);
select hasnt_table('public', 'spatial_ref_sys', 'spatial_ref_sys is no longer in public');
select hasnt_view('public', 'geometry_columns', 'geometry_columns is no longer in public');

-- ---------------------------------------------------------------------------
-- 2. Cascade victims recreated (3)
-- ---------------------------------------------------------------------------
select set_eq(
  $$ select table_name || '.' || column_name from information_schema.columns
      where table_schema = 'public' and udt_name = 'geography' $$,
  array['activities.location_restriction', 'journals.location_point',
        'meetup_checkins.last_known_point', 'meetups.location_point',
        'safety_alerts.last_known_point', 'sos_alerts.location',
        'trips.location', 'women_only_spaces.location'],
  'all 8 geography columns are back'
);
select set_eq(
  $$ select indexname::text from pg_indexes where schemaname = 'public'
      and indexname in ('idx_activities_location_restriction', 'idx_journals_location',
                        'idx_sos_alerts_location', 'idx_trips_active_location',
                        'idx_trips_location_gist', 'idx_women_only_spaces_location') $$,
  array['idx_activities_location_restriction', 'idx_journals_location',
        'idx_sos_alerts_location', 'idx_trips_active_location',
        'idx_trips_location_gist', 'idx_women_only_spaces_location'],
  'all 6 spatial indexes are back'
);
select set_eq(
  $$ select p.proname::text from pg_proc p
      where p.pronamespace = 'public'::regnamespace
        and p.proname in ('make_point', 'distance_between_points',
                          'find_trips_near_location', 'find_women_only_spaces_nearby') $$,
  array['make_point', 'distance_between_points',
        'find_trips_near_location', 'find_women_only_spaces_nearby'],
  'all 4 geography-signature functions are back'
);

-- ---------------------------------------------------------------------------
-- 3. Access did not drift (4)
-- ---------------------------------------------------------------------------
select ok(has_function_privilege('anon', 'public.make_point(double precision,double precision)', 'execute'),
  'make_point keeps its pre-move PUBLIC execute');
select ok(has_function_privilege('authenticated',
  'public.find_trips_near_location(extensions.geography,double precision,date,date,integer)', 'execute'),
  'find_trips_near_location keeps its pre-move PUBLIC execute');
select ok(not has_function_privilege('anon',
  'public.trigger_sos(uuid,double precision,double precision,double precision,double precision,text,text,integer,uuid)', 'execute'),
  'trigger_sos still denies anon');
select ok(has_function_privilege('authenticated',
  'public.trigger_sos(uuid,double precision,double precision,double precision,double precision,text,text,integer,uuid)', 'execute'),
  'trigger_sos still allows authenticated');

-- ---------------------------------------------------------------------------
-- 4. search_path re-pinned (3)
-- ---------------------------------------------------------------------------
select ok(
  (select 'search_path=public, extensions' = any(proconfig) from pg_proc
    where oid = 'public.get_entries_near_location(uuid,double precision,double precision,double precision)'::regprocedure),
  'get_entries_near_location pinned to public, extensions'
);
select ok(
  (select 'search_path=public, extensions' = any(proconfig) from pg_proc
    where oid = 'public.trigger_sos(uuid,double precision,double precision,double precision,double precision,text,text,integer,uuid)'::regprocedure),
  'trigger_sos pinned to public, extensions'
);
select ok(
  (select 'search_path=public' = any(proconfig) from pg_proc
    where oid = 'public.get_waitlist_count()'::regprocedure),
  'get_waitlist_count (no PostGIS) is left alone'
);

-- ---------------------------------------------------------------------------
-- 5. Behaviour: spatial queries work end-to-end after the move (4)
-- ---------------------------------------------------------------------------
insert into auth.users (id, email) values
  ('e0000000-0000-0000-0000-000000000001', 'geo@test.io')
on conflict (id) do nothing;
insert into public.profiles (id) values ('e0000000-0000-0000-0000-000000000001')
on conflict (id) do nothing;
insert into public.trips (user_id, name, start_date, end_date, is_active, is_public, location)
values ('e0000000-0000-0000-0000-000000000001', 'postgis move trip',
        '2026-11-01', '2026-11-10', true, true, public.make_point(13.0038, 55.6050));

select cmp_ok(
  public.distance_between_points(public.make_point(13.0038, 55.6050), public.make_point(12.5683, 55.6761)),
  '>', 25000::float8,
  'distance_between_points computes a real distance (Malmö → Copenhagen > 25 km)'
);
select is(
  (select count(*)::int from public.find_trips_near_location(public.make_point(13.0, 55.6), 5000)
    where trip_id in (select id from public.trips where name = 'postgis move trip')),
  1,
  'find_trips_near_location finds a trip through the recreated column + index'
);

set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"e0000000-0000-0000-0000-000000000001","role":"authenticated"}', true);
-- Worst case: a caller whose path can't see `extensions` (e.g. a SECURITY
-- DEFINER pinned to public). pgTAP itself needs `extensions`, so run the calls
-- under the narrow path, stash the results, then assert after restoring it.
-- An unresolved ST_* raises and aborts the file — a failure either way.
select set_config('search_path', 'public', true);
select set_config('t.entries', (select count(*)::text from public.get_entries_near_location(
  'e0000000-0000-0000-0000-000000000001', 55.6, 13.0, 10)), true);
select set_config('t.trips', (select count(*)::text from public.find_trips_near_location(
  public.make_point(13.0, 55.6), 5000)), true);
select set_config('search_path', 'public, extensions', true);

select is(current_setting('t.entries'), '0',
  'get_entries_near_location resolves ST_* via its pinned path from a public-only caller');
select ok(current_setting('t.trips')::int >= 1,
  'find_trips_near_location resolves ST_* via its pinned path from a public-only caller');
reset role;

select * from finish();
rollback;
