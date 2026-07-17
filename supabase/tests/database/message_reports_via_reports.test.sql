-- pgTAP — Story 0.7: message reports land in the existing `reports` table.
-- Run: `supabase test db`
--
-- The chat_moderation module used to insert into `message_reports`, a table no
-- migration ever created — reporting a harmful message wrote nowhere, silently.
-- The fix repoints it at `reports` with `target_type = 'message'`, which the
-- enum has supported since 20250109000000_extensions_and_enums.sql. This file
-- proves the path the app now uses: the enum value exists, an authenticated
-- user can file a report for themself and only themself, reads are own-only,
-- and the reason length constraint the client guards against is real.
--
-- Auth simulation (see profiles_rls_repair.test.sql): auth.uid() reads the JWT
-- `sub`; impersonate via `set local role authenticated` + request.jwt.claims.

begin;
select plan(8);

-- ============================================================================
-- 1. Schema facts the repoint relies on (3)
-- ============================================================================
select ok(
  EXISTS (
    SELECT 1 FROM pg_enum e
    JOIN pg_type t ON t.oid = e.enumtypid
    WHERE t.typname = 'report_target_type' AND e.enumlabel = 'message'
  ),
  'report_target_type enum includes ''message'''
);
select ok(
  (SELECT relrowsecurity FROM pg_class WHERE oid = 'public.reports'::regclass),
  'RLS is enabled on reports'
);
select ok(
  EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'reports'
      AND cmd = 'INSERT'
  ),
  'reports has an INSERT policy'
);

-- ============================================================================
-- 2. Functional: insert-own works, forgery and short reasons do not (3)
-- ============================================================================
insert into auth.users (id, email) values
  ('aaaaaaaa-0007-0007-0007-aaaaaaaaaaaa', 'report_a@test.local'),
  ('bbbbbbbb-0007-0007-0007-bbbbbbbbbbbb', 'report_b@test.local');
insert into public.profiles (id, username) values
  ('aaaaaaaa-0007-0007-0007-aaaaaaaaaaaa', 'report_user_a'),
  ('bbbbbbbb-0007-0007-0007-bbbbbbbbbbbb', 'report_user_b');

set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0007-0007-0007-aaaaaaaaaaaa","role":"authenticated"}', true);

-- The exact shape MessageReportService writes (reason is built to satisfy the
-- 10..1000 CHECK; target_id has no FK, it is the reported message's server id).
select lives_ok(
  $$insert into public.reports (reporter_id, target_id, target_type, reason, details)
    values ('aaaaaaaa-0007-0007-0007-aaaaaaaaaaaa',
            'cccccccc-0007-0007-0007-cccccccccccc',
            'message',
            'Chat message reported: Harassment',
            'harassment')$$,
  'authenticated user can file a message report as themself'
);

-- errcode-only: 42501 is the contract; the message text varies by PG version.
select throws_ok(
  $$insert into public.reports (reporter_id, target_id, target_type, reason)
    values ('bbbbbbbb-0007-0007-0007-bbbbbbbbbbbb',
            'cccccccc-0007-0007-0007-cccccccccccc',
            'message',
            'Forged report as another user')$$,
  '42501',
  null,
  'cannot file a report as someone else (RLS)'
);

select throws_ok(
  $$insert into public.reports (reporter_id, target_id, target_type, reason)
    values ('aaaaaaaa-0007-0007-0007-aaaaaaaaaaaa',
            'cccccccc-0007-0007-0007-cccccccccccc',
            'message',
            'short')$$,
  '23514',
  null,
  'reason under 10 chars is rejected by the CHECK constraint'
);

-- ============================================================================
-- 3. Reads are own-only (2)
-- ============================================================================
select is(
  (select count(*)::int from public.reports
    where reporter_id = 'aaaaaaaa-0007-0007-0007-aaaaaaaaaaaa'),
  1,
  'reporter can read their own report'
);

select set_config('request.jwt.claims',
  '{"sub":"bbbbbbbb-0007-0007-0007-bbbbbbbbbbbb","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.reports),
  0,
  'another user cannot read the report'
);

reset role;
select * from finish();
rollback;
