-- pgTAP — Story 0.7: shared_meetups exists and its sharing model holds.
-- Run: `supabase test db`
--
-- FOUNDATIONS §5 KEEPs this table by name ("the differentiator") yet it never
-- existed — ShareMeetupScreen's insert (a live route) always failed. Proves:
-- the exact client payload lands; the owner controls their shares; a
-- REGISTERED trusted contact addressed by the share can read it (that
-- visibility is the feature); anyone else cannot. Also pins that the
-- default-privileges mechanism from 20260717150000 granted this
-- post-migration table automatically (no per-table grant exists for it).

begin;
select plan(9);

-- ============================================================================
-- 1. Structure (3)
-- ============================================================================
select ok(
  (SELECT relrowsecurity FROM pg_class WHERE oid = 'public.shared_meetups'::regclass),
  'RLS is enabled on shared_meetups'
);
select ok(
  (SELECT prosecdef FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname='public' AND p.proname='is_share_recipient'),
  'is_share_recipient is SECURITY DEFINER (contact rows are invisible to the reader''s own RLS view)'
);
select ok(
  has_table_privilege('authenticated', 'public.shared_meetups', 'INSERT'),
  'authenticated holds INSERT via the 20260717150000 default privileges (no per-table grant needed)'
);

-- ============================================================================
-- Seed: sharer S, registered contact C (linked via trusted_contacts),
--       bystander X.
-- ============================================================================
insert into auth.users (id, email) values
  ('aaaaaaaa-0008-0008-0008-aaaaaaaaaaaa', 'share_s@test.local'),
  ('bbbbbbbb-0008-0008-0008-bbbbbbbbbbbb', 'share_c@test.local'),
  ('cccccccc-0008-0008-0008-cccccccccccc', 'share_x@test.local');
insert into public.profiles (id, username) values
  ('aaaaaaaa-0008-0008-0008-aaaaaaaaaaaa', 'share_user_s'),
  ('bbbbbbbb-0008-0008-0008-bbbbbbbbbbbb', 'share_user_c'),
  ('cccccccc-0008-0008-0008-cccccccccccc', 'share_user_x');
insert into public.trusted_contacts
  (id, user_id, contact_name, contact_user_id, is_active) values
  ('dddddddd-0008-0008-0008-dddddddddddd',
   'aaaaaaaa-0008-0008-0008-aaaaaaaaaaaa', 'C the contact',
   'bbbbbbbb-0008-0008-0008-bbbbbbbbbbbb', true);

set local role authenticated;

-- ============================================================================
-- 2. Owner: the exact ShareMeetupScreen payload lands (2)
-- ============================================================================
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0008-0008-0008-aaaaaaaaaaaa","role":"authenticated"}', true);
select lives_ok(
  $$insert into public.shared_meetups
      (user_id, meeting_with, location_name, meetup_time, notes, shared_with_contact_ids, created_at)
    values ('aaaaaaaa-0008-0008-0008-aaaaaaaaaaaa', 'Maria from the hostel',
            'Cafe Central, Malmo', '2026-08-01T19:00:00Z', 'back by 22:00',
            array['dddddddd-0008-0008-0008-dddddddddddd']::uuid[], now())$$,
  'the ShareMeetupScreen insert payload lands (it has failed since the screen shipped)'
);
select throws_ok(
  $$insert into public.shared_meetups (user_id, meeting_with, location_name, meetup_time)
    values ('bbbbbbbb-0008-0008-0008-bbbbbbbbbbbb', 'Forged', 'Nowhere', now())$$,
  '42501', null,
  'cannot create a share as someone else (RLS)'
);

-- ============================================================================
-- 3. Visibility: addressed contact yes, bystander no (4)
-- ============================================================================
select set_config('request.jwt.claims',
  '{"sub":"bbbbbbbb-0008-0008-0008-bbbbbbbbbbbb","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.shared_meetups),
  1,
  'the registered trusted contact CAN read the share addressed to them'
);
select is(
  (select meeting_with from public.shared_meetups limit 1),
  'Maria from the hostel',
  'the contact sees the share content'
);
select set_config('request.jwt.claims',
  '{"sub":"cccccccc-0008-0008-0008-cccccccccccc","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.shared_meetups),
  0,
  'a bystander cannot read the share'
);
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0008-0008-0008-aaaaaaaaaaaa","role":"authenticated"}', true);
select is(
  (select count(*)::int from public.shared_meetups),
  1,
  'the owner reads their own share'
);

reset role;
select * from finish();
rollback;
