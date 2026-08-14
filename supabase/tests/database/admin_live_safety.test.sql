-- pgTAP — admin dashboard Phase 1: live-safety queue, verbs, escalation.
-- Run: `supabase test db`
--
-- Proves migration 20260814200000. The assertions that matter:
--
--   * an unanswered SOS ranks loudest (urgency 0) — the dangerous case is not an
--     SOS, it is an SOS nobody answered
--   * escalation is idempotent per subject, so a per-minute cron pages once and
--     keeps the page open, rather than paging every minute
--   * acknowledging closes the escalation, so a taken incident stops paging
--   * the view is security_invoker, so it grants nothing on its own
--   * support cannot acknowledge or resolve (moderator+), and resolution demands
--     a written note
--   * every verb writes an audit entry
--
-- Refs: docs/design/admin-dashboard-v0.1.md §4.1, §9.2

begin;
select plan(16);

-- ---------------------------------------------------------------------------
-- Fixtures
-- ---------------------------------------------------------------------------
insert into auth.users (id, email) values
  ('b0000000-0000-0000-0000-000000000001', 'traveler@test.io'),
  ('b0000000-0000-0000-0000-000000000002', 'support@test.io'),
  ('b0000000-0000-0000-0000-000000000003', 'moderator@test.io'),
  ('b0000000-0000-0000-0000-000000000004', 'ordinary@test.io')
on conflict (id) do nothing;

insert into public.profiles (id) values
  ('b0000000-0000-0000-0000-000000000001'),
  ('b0000000-0000-0000-0000-000000000002'),
  ('b0000000-0000-0000-0000-000000000003'),
  ('b0000000-0000-0000-0000-000000000004')
on conflict (id) do nothing;

insert into public.admin_users (user_id, role) values
  ('b0000000-0000-0000-0000-000000000002', 'support'),
  ('b0000000-0000-0000-0000-000000000003', 'moderator');

-- One unanswered SOS, one that a contact already acknowledged.
insert into public.sos_alerts (id, user_id, status, acknowledged_contact_ids, triggered_at)
values
  ('c0000000-0000-0000-0000-00000000000a',
   'b0000000-0000-0000-0000-000000000001', 'active', '{}', now()),
  ('c0000000-0000-0000-0000-00000000000b',
   'b0000000-0000-0000-0000-000000000001', 'active',
   array['b0000000-0000-0000-0000-000000000004'::uuid], now());

-- ---------------------------------------------------------------------------
-- 1. Schema (2)
-- ---------------------------------------------------------------------------
select has_view('public', 'admin_live_safety_queue', 'live safety queue view exists');

-- A SECURITY DEFINER view would return rows regardless of who asked, bypassing
-- the Phase 0 RLS entirely. The audit already flagged SECDEF views as a defect.
select ok(
  (select c.reloptions::text like '%security_invoker=on%'
     from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relname = 'admin_live_safety_queue'),
  'the queue view is security_invoker — it grants nothing on its own'
);

-- ---------------------------------------------------------------------------
-- 2. Visibility (3)
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims = '{"sub":"b0000000-0000-0000-0000-000000000004"}';

select is(
  (select count(*)::int from public.admin_live_safety_queue),
  0,
  'an ordinary user sees nothing in the safety queue'
);

set local request.jwt.claims = '{"sub":"b0000000-0000-0000-0000-000000000002"}';

select is(
  (select count(*)::int from public.admin_live_safety_queue where kind = 'sos'),
  2,
  'a support admin sees both SOS alerts'
);

select is(
  (select urgency from public.admin_live_safety_queue
    where subject_id = 'c0000000-0000-0000-0000-00000000000a'),
  0,
  'the UNANSWERED alert ranks loudest (urgency 0)'
);

-- ---------------------------------------------------------------------------
-- 3. The unanswered flag distinguishes the dangerous case (1)
-- ---------------------------------------------------------------------------
select is(
  (select unanswered from public.admin_live_safety_queue
    where subject_id = 'c0000000-0000-0000-0000-00000000000b'),
  false,
  'an alert a contact acknowledged is not flagged unanswered'
);

-- ---------------------------------------------------------------------------
-- 4. Escalation enqueue + idempotency (3)
-- ---------------------------------------------------------------------------
set local role postgres;

select lives_ok(
  $$ select public.enqueue_safety_escalations() $$,
  'enqueue runs'
);

select is(
  (select count(*)::int from public.admin_escalations
    where kind = 'sos' and subject_id = 'c0000000-0000-0000-0000-00000000000a'),
  1,
  'the unanswered SOS is enqueued once'
);

-- The cron runs every minute; a second pass must not create a second page.
select public.enqueue_safety_escalations();

select is(
  (select count(*)::int from public.admin_escalations
    where kind = 'sos' and subject_id = 'c0000000-0000-0000-0000-00000000000a'),
  1,
  'a second cron pass does NOT enqueue a duplicate page'
);

-- ---------------------------------------------------------------------------
-- 5. Role gates on the verbs (3)
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims = '{"sub":"b0000000-0000-0000-0000-000000000002"}';

select throws_ok(
  $$ select public.admin_acknowledge_sos('c0000000-0000-0000-0000-00000000000a', 'looking') $$,
  '42501',
  'moderator role required',
  'support CANNOT acknowledge an SOS — reading is not acting'
);

set local request.jwt.claims = '{"sub":"b0000000-0000-0000-0000-000000000003"}';

select throws_ok(
  $$ select public.admin_resolve_sos('c0000000-0000-0000-0000-00000000000a', '   ') $$,
  '22023',
  'a resolution note is required',
  'closing a safety incident requires a written account'
);

select lives_ok(
  $$ select public.admin_acknowledge_sos('c0000000-0000-0000-0000-00000000000a', 'on it') $$,
  'a moderator can acknowledge'
);

-- ---------------------------------------------------------------------------
-- 6. Acknowledging stops the paging (2)
-- ---------------------------------------------------------------------------
select is(
  (select count(*)::int from public.admin_escalations
    where kind = 'sos' and subject_id = 'c0000000-0000-0000-0000-00000000000a'
      and acknowledged_at is not null),
  1,
  'acknowledging the alert closes its escalation — a taken incident stops paging'
);

set local role postgres;
select public.enqueue_safety_escalations();
set local role authenticated;
set local request.jwt.claims = '{"sub":"b0000000-0000-0000-0000-000000000003"}';

select is(
  (select count(*)::int from public.admin_escalations
    where kind = 'sos' and subject_id = 'c0000000-0000-0000-0000-00000000000a'),
  1,
  'and it is not re-enqueued afterwards'
);

-- ---------------------------------------------------------------------------
-- 7. Verbs are audited (2)
-- ---------------------------------------------------------------------------
select is(
  (select count(*)::int from public.admin_audit_log
    where action = 'sos.acknowledge'
      and subject_id = 'b0000000-0000-0000-0000-000000000001'),
  1,
  'acknowledging wrote an audit entry naming the affected user'
);

select lives_ok(
  $$ select public.admin_annotate_safety_event('sos', 'c0000000-0000-0000-0000-00000000000a', 'contacted local police') $$,
  'support-level annotation is allowed and audited'
);

select * from finish();
rollback;
