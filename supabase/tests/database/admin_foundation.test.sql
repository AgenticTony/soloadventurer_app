-- pgTAP — admin dashboard Phase 0 foundation.
-- Run: `supabase test db`
--
-- Proves migration 20260814100000. The interesting assertions are the negative
-- ones: this surface can see everything, so most of the value is in what it
-- refuses.
--
--   * a non-admin sees nothing new (the RLS clauses widen access for admins ONLY)
--   * a revoked admin loses access immediately
--   * the role hierarchy holds, and support cannot borrow moderator authority
--   * the admin roster is invisible to ordinary users — it is a target list
--   * the audit log cannot be edited or deleted by anyone, including owner
--   * the audit log cannot be written except through log_admin_action()
--
-- Refs: docs/design/admin-dashboard-v0.1.md §2, §3, §5

begin;
select plan(18);

-- ---------------------------------------------------------------------------
-- Fixtures: one ordinary user, one of each admin role, one revoked admin
-- ---------------------------------------------------------------------------
insert into auth.users (id, email) values
  ('a0000000-0000-0000-0000-000000000001', 'ordinary@test.io'),
  ('a0000000-0000-0000-0000-000000000002', 'support@test.io'),
  ('a0000000-0000-0000-0000-000000000003', 'moderator@test.io'),
  ('a0000000-0000-0000-0000-000000000004', 'owner@test.io'),
  ('a0000000-0000-0000-0000-000000000005', 'revoked@test.io'),
  ('a0000000-0000-0000-0000-000000000006', 'subject@test.io')
on conflict (id) do nothing;

insert into public.profiles (id) values
  ('a0000000-0000-0000-0000-000000000001'),
  ('a0000000-0000-0000-0000-000000000002'),
  ('a0000000-0000-0000-0000-000000000003'),
  ('a0000000-0000-0000-0000-000000000004'),
  ('a0000000-0000-0000-0000-000000000005'),
  ('a0000000-0000-0000-0000-000000000006')
on conflict (id) do nothing;

insert into public.admin_users (user_id, role, revoked_at) values
  ('a0000000-0000-0000-0000-000000000002', 'support',   null),
  ('a0000000-0000-0000-0000-000000000003', 'moderator', null),
  ('a0000000-0000-0000-0000-000000000004', 'owner',     null),
  ('a0000000-0000-0000-0000-000000000005', 'owner',     now());  -- revoked

-- A subject row to be read.
insert into public.sos_alerts (user_id, status)
values ('a0000000-0000-0000-0000-000000000006', 'active');

-- ---------------------------------------------------------------------------
-- 1. Schema (3)
-- ---------------------------------------------------------------------------
select has_table('public', 'admin_users', 'admin_users exists');
select has_table('public', 'admin_audit_log', 'admin_audit_log exists');

select ok(
  exists (
    select 1 from pg_type t join pg_enum e on e.enumtypid = t.oid
    where t.typname = 'admin_role' and e.enumlabel = 'owner'
  ),
  'admin_role enum includes owner'
);

-- ---------------------------------------------------------------------------
-- 2. Role hierarchy (4)
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000002"}';

select ok(public.is_admin('support'), 'support satisfies support');
select ok(not public.is_admin('moderator'),
  'support does NOT satisfy moderator — a support agent cannot borrow authority');

set local request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000004"}';
select ok(public.is_admin('moderator'), 'owner satisfies moderator');
select ok(public.is_admin('owner'), 'owner satisfies owner');

-- ---------------------------------------------------------------------------
-- 3. Revocation takes effect immediately (1)
-- ---------------------------------------------------------------------------
set local request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000005"}';
select ok(not public.is_admin('support'),
  'a REVOKED owner has no admin authority at all');

-- ---------------------------------------------------------------------------
-- 4. Ordinary users are unaffected (3)
-- ---------------------------------------------------------------------------
set local request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001"}';

select ok(not public.is_admin('support'), 'an ordinary user is not an admin');

select is(
  (select count(*)::int from public.sos_alerts
    where user_id = 'a0000000-0000-0000-0000-000000000006'),
  0,
  'an ordinary user still cannot read someone else''s SOS alert'
);

-- The roster is a target list; it must not be enumerable.
select is(
  (select count(*)::int from public.admin_users),
  0,
  'an ordinary user cannot enumerate the admin roster'
);

-- ---------------------------------------------------------------------------
-- 5. Admins can read the safety tables (2)
-- ---------------------------------------------------------------------------
set local request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000002"}';

select is(
  (select count(*)::int from public.sos_alerts
    where user_id = 'a0000000-0000-0000-0000-000000000006'),
  1,
  'a support admin CAN read an SOS alert — the point of the whole design'
);

set local request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000005"}';
select is(
  (select count(*)::int from public.sos_alerts
    where user_id = 'a0000000-0000-0000-0000-000000000006'),
  0,
  'a REVOKED admin cannot read the SOS alert'
);

-- ---------------------------------------------------------------------------
-- 6. Audit log: writable only through the function (2)
-- ---------------------------------------------------------------------------
set local request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000003"}';

select lives_ok(
  $$ select public.log_admin_action('user.view', 'a0000000-0000-0000-0000-000000000006', '{"reason":"triage"}'::jsonb) $$,
  'an admin can record an action'
);

-- No INSERT policy exists, so a direct write must fail even for an admin.
select throws_ok(
  $$ insert into public.admin_audit_log (actor_id, action) values (auth.uid(), 'forged.entry') $$,
  '42501',
  null,
  'a direct INSERT into the audit log is refused — log_admin_action is the only path'
);

-- ---------------------------------------------------------------------------
-- 7. Audit log is append-only (2)
-- ---------------------------------------------------------------------------
set local request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000004"}';

-- Owner sees everything, but still cannot rewrite history.
select is(
  (select count(*)::int from public.admin_audit_log where action = 'user.view'),
  1,
  'owner can read another admin''s audit entry'
);

select ok(
  not exists (
    select 1 from pg_policy p
    join pg_class c on c.oid = p.polrelid
    where c.relname = 'admin_audit_log' and p.polcmd in ('w', 'd')
  ),
  'no UPDATE or DELETE policy exists on admin_audit_log, for any role'
);

-- ---------------------------------------------------------------------------
-- 8. Non-admins cannot write to the log (1)
-- ---------------------------------------------------------------------------
set local request.jwt.claims = '{"sub":"a0000000-0000-0000-0000-000000000001"}';

select throws_ok(
  $$ select public.log_admin_action('user.view', null, '{}'::jsonb) $$,
  '42501',
  'not an admin',
  'an ordinary user cannot write an audit entry'
);

select * from finish();
rollback;
