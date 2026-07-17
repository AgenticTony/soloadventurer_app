-- pgTAP — Story 0.6: a block severs the connection AND gates profile reads.
-- Run: `supabase test db`
--
-- Also closes the BLOCK clause of Story 0.5 box 4 ("blocked users CANNOT read
-- the blocker's row"), which was unprovable while nothing could create a block
-- row and the connected path bypassed the check. Proves both defenses from
-- 20260717120000:
--   belt   — trg_block_sever_connections flips the pair's connection to
--            'blocked', so has_active_connection() goes false;
--   braces — profiles_read_connected itself re-checks are_users_blocked().
--
-- Auth simulation as in profiles_rls_repair.test.sql.

begin;
select plan(11);

-- ============================================================================
-- 1. Structure: trigger + hardened policy + explicit grant (4)
-- ============================================================================
select ok(
  EXISTS (SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
          WHERE n.nspname = 'public' AND p.proname = 'sever_connections_on_block'
            AND p.prosecdef),
  'sever_connections_on_block exists and is SECURITY DEFINER'
);
select ok(
  EXISTS (SELECT 1 FROM pg_trigger
          WHERE tgname = 'trg_block_sever_connections'
            AND tgrelid = 'public.blocks'::regclass),
  'AFTER INSERT trigger is attached to blocks'
);
select ok(
  EXISTS (SELECT 1 FROM pg_policies
          WHERE schemaname = 'public' AND tablename = 'profiles'
            AND policyname = 'profiles_read_connected'
            AND qual LIKE '%are_users_blocked%'),
  'profiles_read_connected re-checks are_users_blocked'
);
select ok(
  has_table_privilege('authenticated', 'public.blocks', 'INSERT'),
  'authenticated holds INSERT on blocks (explicit grant, not platform default)'
);

-- ============================================================================
-- 2. Functional: connected pair, then a block (7)
-- ============================================================================
insert into auth.users (id, email) values
  ('aaaaaaaa-0006-0006-0006-aaaaaaaaaaaa', 'block_a@test.local'),
  ('bbbbbbbb-0006-0006-0006-bbbbbbbbbbbb', 'block_b@test.local');
insert into public.profiles (id, username) values
  ('aaaaaaaa-0006-0006-0006-aaaaaaaaaaaa', 'block_user_a'),
  ('bbbbbbbb-0006-0006-0006-bbbbbbbbbbbb', 'block_user_b');
insert into public.connections (requester_id, recipient_id, status) values
  ('aaaaaaaa-0006-0006-0006-aaaaaaaaaaaa',
   'bbbbbbbb-0006-0006-0006-bbbbbbbbbbbb', 'accepted');

set local role authenticated;

-- B is connected to A and can read A's row (the pre-block baseline).
select set_config('request.jwt.claims',
  '{"sub":"bbbbbbbb-0006-0006-0006-bbbbbbbbbbbb","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.profiles
    where id = 'aaaaaaaa-0006-0006-0006-aaaaaaaaaaaa'),
  1,
  'connected user CAN read the profile before any block'
);

-- A blocks B.
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0006-0006-0006-aaaaaaaaaaaa","role":"authenticated"}', true);
select lives_ok(
  $$insert into public.blocks (blocker_id, blocked_id)
    values ('aaaaaaaa-0006-0006-0006-aaaaaaaaaaaa',
            'bbbbbbbb-0006-0006-0006-bbbbbbbbbbbb')$$,
  'blocker can insert their own block row'
);
select is(
  (select status from public.connections
    where requester_id = 'aaaaaaaa-0006-0006-0006-aaaaaaaaaaaa'
      and recipient_id = 'bbbbbbbb-0006-0006-0006-bbbbbbbbbbbb'),
  'blocked',
  'the trigger severed the connection (status -> blocked)'
);

-- The gates hold, in both directions.
select set_config('request.jwt.claims',
  '{"sub":"bbbbbbbb-0006-0006-0006-bbbbbbbbbbbb","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.profiles
    where id = 'aaaaaaaa-0006-0006-0006-aaaaaaaaaaaa'),
  0,
  'blocked user can NO LONGER read the blocker (0.5 box 4 block clause)'
);
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0006-0006-0006-aaaaaaaaaaaa","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.profiles
    where id = 'bbbbbbbb-0006-0006-0006-bbbbbbbbbbbb'),
  0,
  'the block is symmetric — blocker cannot read the blocked either'
);

-- Unblock does NOT resurrect the connection: one-way door, by design.
select lives_ok(
  $$delete from public.blocks
    where blocker_id = 'aaaaaaaa-0006-0006-0006-aaaaaaaaaaaa'
      and blocked_id = 'bbbbbbbb-0006-0006-0006-bbbbbbbbbbbb'$$,
  'blocker can remove their own block row'
);
select is(
  (select status from public.connections
    where requester_id = 'aaaaaaaa-0006-0006-0006-aaaaaaaaaaaa'),
  'blocked',
  'unblocking does not resurrect the connection — a new request is required'
);

reset role;
select * from finish();
rollback;
