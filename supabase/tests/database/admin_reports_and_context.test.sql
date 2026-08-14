-- pgTAP — admin dashboard Phase 2: reports queue, user context, adjudication.
-- Run: `supabase test db`
--
-- Proves migration 20260814300000. The assertions that matter:
--
--   * adjudication is the switch that makes the reward-fn penalty live —
--     upholding must actually move the score
--   * nobody adjudicates a case they are party to
--   * a note is mandatory, and 'pending' is not a valid verdict
--   * support can read but cannot adjudicate
--   * admin_user_context excludes PII and audits its own read
--
-- Refs: docs/design/admin-dashboard-v0.1.md §4.3, §4.4 ·
--       docs/reward-function-v0.1.md

begin;
select plan(17);

-- ---------------------------------------------------------------------------
-- Fixtures
-- ---------------------------------------------------------------------------
insert into auth.users (id, email) values
  ('d0000000-0000-0000-0000-000000000001', 'target@test.io'),
  ('d0000000-0000-0000-0000-000000000002', 'reporter@test.io'),
  ('d0000000-0000-0000-0000-000000000003', 'support@test.io'),
  ('d0000000-0000-0000-0000-000000000004', 'moderator@test.io'),
  ('d0000000-0000-0000-0000-000000000005', 'modwhoreported@test.io')
on conflict (id) do nothing;

insert into public.profiles (id, username) values
  ('d0000000-0000-0000-0000-000000000001', 'target'),
  ('d0000000-0000-0000-0000-000000000002', 'reporter'),
  ('d0000000-0000-0000-0000-000000000003', 'supportadmin'),
  ('d0000000-0000-0000-0000-000000000004', 'moderatoradmin'),
  ('d0000000-0000-0000-0000-000000000005', 'conflicted')
on conflict (id) do nothing;

insert into public.admin_users (user_id, role) values
  ('d0000000-0000-0000-0000-000000000003', 'support'),
  ('d0000000-0000-0000-0000-000000000004', 'moderator'),
  ('d0000000-0000-0000-0000-000000000005', 'moderator');

insert into public.reports (id, reporter_id, target_id, target_type, reason, outcome) values
  ('e0000000-0000-0000-0000-00000000000a',
   'd0000000-0000-0000-0000-000000000002',
   'd0000000-0000-0000-0000-000000000001',
   'profile', 'Reported for Harassment — repeated unwanted contact', 'pending'),
  -- A case the conflicted moderator filed themselves.
  ('e0000000-0000-0000-0000-00000000000b',
   'd0000000-0000-0000-0000-000000000005',
   'd0000000-0000-0000-0000-000000000001',
   'profile', 'Reported for Spam — bulk unsolicited messages', 'pending');

-- ---------------------------------------------------------------------------
-- 1. Schema + visibility (3)
-- ---------------------------------------------------------------------------
select has_view('public', 'admin_reports_queue', 'reports queue view exists');

select ok(
  (select c.reloptions::text like '%security_invoker=on%'
     from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relname = 'admin_reports_queue'),
  'the reports queue is security_invoker'
);

set local role authenticated;
set local request.jwt.claims = '{"sub":"d0000000-0000-0000-0000-000000000002"}';

select is(
  (select count(*)::int from public.admin_reports_queue),
  1,
  'a non-admin reporter sees only their own report, via the pre-existing policy'
);

-- ---------------------------------------------------------------------------
-- 2. Per-target history is what makes a queue adjudicable (2)
-- ---------------------------------------------------------------------------
set local request.jwt.claims = '{"sub":"d0000000-0000-0000-0000-000000000003"}';

select is(
  (select count(*)::int from public.admin_reports_queue),
  2,
  'a support admin sees every report'
);

select is(
  (select distinct open_reporters_for_target::int from public.admin_reports_queue
    where target_id = 'd0000000-0000-0000-0000-000000000001'),
  2,
  'the queue shows TWO distinct open reporters — a fifth complaint is a different situation from a first'
);

-- ---------------------------------------------------------------------------
-- 3. Role gate (1)
-- ---------------------------------------------------------------------------
select throws_ok(
  $$ select public.adjudicate_report('e0000000-0000-0000-0000-00000000000a', 'upheld', 'clear pattern') $$,
  '42501',
  'moderator role required',
  'support can read the queue but CANNOT adjudicate'
);

-- ---------------------------------------------------------------------------
-- 4. Input guards (2)
-- ---------------------------------------------------------------------------
set local request.jwt.claims = '{"sub":"d0000000-0000-0000-0000-000000000004"}';

select throws_ok(
  $$ select public.adjudicate_report('e0000000-0000-0000-0000-00000000000a', 'pending', 'not sure') $$,
  '22023',
  'outcome must be upheld or dismissed',
  'pending is not a verdict — adjudication is a decision'
);

select throws_ok(
  $$ select public.adjudicate_report('e0000000-0000-0000-0000-00000000000a', 'upheld', '  ') $$,
  '22023',
  'an adjudication note is required',
  'upholding without a written account is refused'
);

-- ---------------------------------------------------------------------------
-- 5. Conflict of interest (1)
-- ---------------------------------------------------------------------------
set local request.jwt.claims = '{"sub":"d0000000-0000-0000-0000-000000000005"}';

select throws_ok(
  $$ select public.adjudicate_report('e0000000-0000-0000-0000-00000000000b', 'upheld', 'my own report') $$,
  '42501',
  'cannot adjudicate a report you are party to',
  'a moderator cannot adjudicate a report they filed themselves'
);

-- ---------------------------------------------------------------------------
-- 6. Adjudication is the switch on the reward function (4)
-- ---------------------------------------------------------------------------
set local request.jwt.claims = '{"sub":"d0000000-0000-0000-0000-000000000004"}';

select is(
  (public.reputation_score('d0000000-0000-0000-0000-000000000001') ->> 'score')::int,
  0,
  'before adjudication the target scores 0 — a pending report costs nothing'
);

select lives_ok(
  $$ select public.adjudicate_report('e0000000-0000-0000-0000-00000000000a', 'upheld', 'sustained pattern across three chats') $$,
  'a moderator can uphold with a note'
);

select is(
  (public.reputation_score('d0000000-0000-0000-0000-000000000001') ->> 'score')::int,
  -1,
  'upholding MOVES the score — this is the switch that makes the v0.1.1 penalty live'
);

select is(
  (select outcome::text from public.reports where id = 'e0000000-0000-0000-0000-00000000000a'),
  'upheld',
  'the outcome is recorded'
);

-- ---------------------------------------------------------------------------
-- 7. Dismissal closes without penalty (1)
-- ---------------------------------------------------------------------------
select lives_ok(
  $$ select public.adjudicate_report('e0000000-0000-0000-0000-00000000000b', 'dismissed', 'no evidence of bulk sending') $$,
  'a moderator can dismiss'
);

-- ---------------------------------------------------------------------------
-- 8. Adjudication is audited (1)
-- ---------------------------------------------------------------------------
select is(
  (select count(*)::int from public.admin_audit_log
    where action = 'report.adjudicate'
      and subject_id = 'd0000000-0000-0000-0000-000000000001'),
  2,
  'both adjudications are audited against the target'
);

-- ---------------------------------------------------------------------------
-- 9. User context: no PII, and it logs its own read (2)
-- ---------------------------------------------------------------------------
set local request.jwt.claims = '{"sub":"d0000000-0000-0000-0000-000000000003"}';

select ok(
  not (public.admin_user_context('d0000000-0000-0000-0000-000000000001')
         -> 'account' ? 'email'),
  'user context excludes email — least visibility that permits the job'
);

select is(
  (select count(*)::int from public.admin_audit_log
    where action = 'user.context.view'
      and subject_id = 'd0000000-0000-0000-0000-000000000001'),
  1,
  'reading user context logs ITSELF — the console cannot forget'
);

select * from finish();
rollback;
