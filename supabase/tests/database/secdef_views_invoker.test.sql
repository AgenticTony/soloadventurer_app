-- pgTAP — Security Advisor security_definer_view fix.
-- Run: `supabase test db`
--
-- Proves migration 20261020120000. The assertions that matter:
--
--   * all five flagged views are security_invoker, so they grant nothing on
--     their own and the underlying RLS decides
--   * behaviourally: a stranger reading trip_summaries no longer sees someone
--     else's private trip (the leak the definer view caused)
--   * rls_policy_summary is not readable by anon/authenticated at all

begin;
select plan(9);

-- ---------------------------------------------------------------------------
-- Fixtures
-- ---------------------------------------------------------------------------
insert into auth.users (id, email) values
  ('d0000000-0000-0000-0000-000000000001', 'owner@test.io'),
  ('d0000000-0000-0000-0000-000000000002', 'stranger@test.io')
on conflict (id) do nothing;

insert into public.profiles (id) values
  ('d0000000-0000-0000-0000-000000000001'),
  ('d0000000-0000-0000-0000-000000000002')
on conflict (id) do nothing;

insert into public.trips (user_id, name, start_date, end_date, is_active, is_public) values
  ('d0000000-0000-0000-0000-000000000001', 'secdef private trip', '2026-11-01', '2026-11-10', true, false);

-- ---------------------------------------------------------------------------
-- 1. Every flagged view is security_invoker (5)
-- ---------------------------------------------------------------------------
select ok(
  (select coalesce(c.reloptions::text like '%security_invoker=on%', false)
     from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relname = v),
  v || ' is security_invoker'
)
from unnest(array[
  'trip_summaries', 'journal_entries_with_media', 'shared_links_with_trips',
  'verified_women', 'rls_policy_summary'
]) as v;

-- ---------------------------------------------------------------------------
-- 2. rls_policy_summary is closed to client roles (2)
-- ---------------------------------------------------------------------------
select ok(
  not has_table_privilege('anon', 'public.rls_policy_summary', 'select'),
  'anon cannot read rls_policy_summary'
);
select ok(
  not has_table_privilege('authenticated', 'public.rls_policy_summary', 'select'),
  'authenticated cannot read rls_policy_summary'
);

-- ---------------------------------------------------------------------------
-- 3. Behaviour: the private-trip leak is closed, the owner still sees it (2)
-- ---------------------------------------------------------------------------
-- Hosted Supabase's default privileges grant views to authenticated; the CI
-- stack's codify_bootstrap_grants loop only covers pg_tables. Replicate prod so
-- this proves RLS does the gating, not a missing grant.
grant select on public.trip_summaries to authenticated;

set local role authenticated;

select set_config('request.jwt.claims',
  '{"sub":"d0000000-0000-0000-0000-000000000002","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.trip_summaries where name = 'secdef private trip'),
  0,
  'a stranger no longer sees another user''s private trip via trip_summaries'
);

select set_config('request.jwt.claims',
  '{"sub":"d0000000-0000-0000-0000-000000000001","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.trip_summaries where name = 'secdef private trip'),
  1,
  'the owner still sees their own private trip via trip_summaries'
);

reset role;

select * from finish();
rollback;
