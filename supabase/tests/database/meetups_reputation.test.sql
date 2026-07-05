-- pgTAP tests for Phase A (meetups + outcomes + reputation).
-- Docs: https://supabase.com/docs/guides/database/testing + /extensions/pgtap
-- Run: `supabase test db`
--
-- Auth simulation: auth.uid() reads the JWT `sub`, so we impersonate a user with
--   set local role authenticated;
--   select set_config('request.jwt.claims', '{"sub":"<uuid>","role":"authenticated"}', true);
-- The Phase A tables hold user ids as plain uuids, but inserting into connections
-- fires trg_notify_new_match (20260402080000), which writes notifications rows whose
-- user_id/actor_id FK-reference profiles — so the test users are seeded in
-- auth.users + profiles below (rolled back with the rest of the transaction).
--
-- NOTE: PL/pgSQL `RAISE EXCEPTION` → SQLSTATE P0001; a unique-constraint violation → 23505.

begin;
select plan(22);

-- Seed the test users (see header note: the notify trigger FK-references profiles).
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'a@test.local'),
  ('22222222-2222-2222-2222-222222222222', 'b@test.local'),
  ('44444444-4444-4444-4444-444444444444', 'd@test.local');
insert into public.profiles (id, username) values
  ('11111111-1111-1111-1111-111111111111', 'user_a'),
  ('22222222-2222-2222-2222-222222222222', 'user_b'),
  ('44444444-4444-4444-4444-444444444444', 'user_d');

-- :a  = 11111111-1111-1111-1111-111111111111  (requester / user_a)
-- :b  = 22222222-2222-2222-2222-222222222222  (recipient / user_b)
-- :c  = 33333333-3333-3333-3333-333333333333  (accepted connection)
-- :nc = 55555555-5555-5555-5555-555555555555  (a non-accepted connection)
-- :d  = 44444444-4444-4444-4444-444444444444  (non-party)

-- ============================================================================
-- 1. SCHEMA (5)
-- ============================================================================
select has_table('public', 'meetups', 'table meetups exists');
select has_table('public', 'meetup_outcomes', 'table meetup_outcomes exists');
select has_table('public', 'member_reviews', 'table member_reviews exists');
select has_column('public', 'meetups', 'a_met_at', 'meetups.a_met_at exists (mutual confirm A)');
select has_column('public', 'meetups', 'b_met_at', 'meetups.b_met_at exists (mutual confirm B)');

-- ============================================================================
-- 2. RLS POLICIES EXIST (read-only; writes forced through RPCs) (2)
-- ============================================================================
select policies_are(
  'public', 'meetups',
  ARRAY['meetups: parties read'],
  'meetups has exactly the parties-read policy'
);
select policies_are(
  'public', 'member_reviews',
  ARRAY['member_reviews: reviewer + reviewed read'],
  'member_reviews has exactly the read policy (no direct write policy)'
);

-- ============================================================================
-- 3. reputation_score — seed directly (test role bypasses RLS), assert aggregation. (4)
-- ============================================================================
insert into public.meetups (id, user_a_id, user_b_id, proposed_by, meetup_time, status, a_met_at, b_met_at, completed_at)
values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        '11111111-1111-1111-1111-111111111111',
        '22222222-2222-2222-2222-222222222222',
        '11111111-1111-1111-1111-111111111111',
        '2030-01-01', 'completed', now(), now(), now());

insert into public.meetup_outcomes (meetup_id, user_a_id, user_b_id, outcome, completed_at)
values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        '11111111-1111-1111-1111-111111111111',
        '22222222-2222-2222-2222-222222222222',
        'completed', now());

-- One positive review of user A by user B.
insert into public.member_reviews (meetup_id, reviewer_id, reviewed_id, rating, would_meet_again, content)
values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        '22222222-2222-2222-2222-222222222222',
        '11111111-1111-1111-1111-111111111111',
        5, true, 'great hike');

select is(
  (public.reputation_score('11111111-1111-1111-1111-111111111111') ->> 'meetups_completed')::int,
  1,
  'reputation_score counts 1 completed meetup'
);
select is(
  (public.reputation_score('11111111-1111-1111-1111-111111111111') ->> 'review_count')::int,
  1,
  'reputation_score counts 1 review'
);
select is(
  (public.reputation_score('11111111-1111-1111-1111-111111111111') ->> 'vouch_pct')::int,
  100,
  'reputation_score vouch_pct = 100 (the one review vouched)'
);
select is(
  (public.reputation_score('11111111-1111-1111-1111-111111111111') ->> 'score')::int,
  12,  -- 2*completed(1)=2 + floor(100/10)=10 - no_shows(0) = 12
  'reputation_score v0.1 score = 2*completed + vouch/10 - no_shows'
);

-- ============================================================================
-- 4. GATE LOGIC via RPCs (mutual confirmation + review gating) (11)
-- ============================================================================
insert into public.connections (id, requester_id, recipient_id, status)
values ('33333333-3333-3333-3333-333333333333',
        '11111111-1111-1111-1111-111111111111',
        '22222222-2222-2222-2222-222222222222',
        'accepted');
insert into public.connections (id, requester_id, recipient_id, status)
values ('55555555-5555-5555-5555-555555555555',
        '11111111-1111-1111-1111-111111111111',
        '44444444-4444-4444-4444-444444444444',
        'pending');

-- (a) propose as a non-party → error
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"44444444-4444-4444-4444-444444444444","role":"authenticated"}', true);
select throws_ok(
  $$ select public.propose_meetup('33333333-3333-3333-3333-333333333333', '2030-02-02', 'x') $$,
  'P0001',
  'non-party cannot propose a meetup'
);

-- (b) propose on a NON-accepted connection → error
select set_config('request.jwt.claims', '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}', true);
select throws_ok(
  $$ select public.propose_meetup('55555555-5555-5555-5555-555555555555', '2030-02-02', 'x') $$,
  'P0001',
  'cannot propose a meetup from a non-accepted connection'
);

-- (c) propose on the accepted connection → success; capture the meetup id
create temp table _m as
  select public.propose_meetup('33333333-3333-3333-3333-333333333333', '2030-02-02', 'Cafe') as meetup_id;

-- (d) respond as the invited party (B) → confirmed
select set_config('request.jwt.claims', '{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}', true);
select lives_ok(
  $$ select public.respond_meetup((select meetup_id from _m), true) $$,
  'invited party can accept → confirmed'
);

-- (e) A confirms "we met" — NOT completed yet (needs both)
select set_config('request.jwt.claims', '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}', true);
select lives_ok(
  $$ select public.complete_meetup((select meetup_id from _m)) $$,
  'first party can confirm we-met'
);
select is(
  (select status::text from public.meetups where id = (select meetup_id from _m)),
  'confirmed',
  'meetup still confirmed (not completed) until BOTH parties confirm'
);

-- (f) submit_review BEFORE completion → error (gate)
select throws_ok(
  $$ select public.submit_review((select meetup_id from _m), 5, true, 'pre') $$,
  'P0001',
  'cannot review until meetup is completed (gate)'
);

-- (g) B confirms "we met" → both confirmed → completed + outcome written
select set_config('request.jwt.claims', '{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}', true);
select lives_ok(
  $$ select public.complete_meetup((select meetup_id from _m)) $$,
  'second party confirms we-met'
);
select is(
  (select status::text from public.meetups where id = (select meetup_id from _m)),
  'completed',
  'meetup completed once BOTH confirm'
);
select is(
  (select count(*)::int from public.meetup_outcomes where meetup_id = (select meetup_id from _m)),
  1,
  'meetup_outcomes row written on completion'
);

-- (h) review now succeeds (completed) for A
select set_config('request.jwt.claims', '{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}', true);
select lives_ok(
  $$ select public.submit_review((select meetup_id from _m), 5, true, 'good') $$,
  'party can review a completed meetup'
);

-- (i) double-review by same party → unique violation
select throws_ok(
  $$ select public.submit_review((select meetup_id from _m), 4, false, 'dup') $$,
  '23505',
  'a party cannot review the same meetup twice'
);

select * from finish();
rollback;
