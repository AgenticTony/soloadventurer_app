-- pgTAP — reward function v0.1.1: block/report penalties.
-- Run: `supabase test db`
--
-- Proves migration 20260814000000. The arithmetic is the easy part; the
-- assertions that matter are the abuse-resistance and privacy properties:
--
--   * an unadjudicated report must not move a score (else reputation is
--     griefable by anyone willing to file one)
--   * a dismissed report must not move a score (else we punish the falsely
--     accused)
--   * repeated reports from one reporter count once (sockpuppet resistance)
--   * blocks must not appear in reputation_score at all (it is
--     authenticated-readable; a block count there leaks block state to the
--     blocked user)
--   * moderation_risk_signal must not be reachable by authenticated/anon
--
-- Refs: docs/reward-function-v0.1.md

begin;
select plan(15);

-- ---------------------------------------------------------------------------
-- Fixtures
-- ---------------------------------------------------------------------------
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'target@test.io'),
  ('22222222-2222-2222-2222-222222222222', 'reporter-a@test.io'),
  ('33333333-3333-3333-3333-333333333333', 'reporter-b@test.io'),
  ('44444444-4444-4444-4444-444444444444', 'blocker-a@test.io')
on conflict (id) do nothing;

-- reports.reporter_id / blocks.* reference `profiles`, not `auth.users`.
insert into public.profiles (id) values
  ('11111111-1111-1111-1111-111111111111'),
  ('22222222-2222-2222-2222-222222222222'),
  ('33333333-3333-3333-3333-333333333333'),
  ('44444444-4444-4444-4444-444444444444')
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- 1. Schema (2)
-- ---------------------------------------------------------------------------
select has_column('public', 'reports', 'outcome', 'reports.outcome exists');

select ok(
  exists (
    select 1 from pg_type t join pg_enum e on e.enumtypid = t.oid
    where t.typname = 'report_outcome' and e.enumlabel = 'upheld'
  ),
  'report_outcome enum includes upheld'
);

-- ---------------------------------------------------------------------------
-- 2. A clean user scores zero (1)
-- ---------------------------------------------------------------------------
select is(
  (public.reputation_score('11111111-1111-1111-1111-111111111111') ->> 'score')::int,
  0,
  'a user with no history scores 0'
);

-- ---------------------------------------------------------------------------
-- 3. Pending reports must NOT penalise (3)
-- ---------------------------------------------------------------------------
insert into public.reports (reporter_id, target_id, target_type, reason, outcome)
values ('22222222-2222-2222-2222-222222222222',
        '11111111-1111-1111-1111-111111111111',
        'profile', 'Reported for Harassment — pending review', 'pending');

select is(
  (public.reputation_score('11111111-1111-1111-1111-111111111111') ->> 'score')::int,
  0,
  'a PENDING report does not move the score — an allegation is not a finding'
);

select is(
  (public.reputation_score('11111111-1111-1111-1111-111111111111') ->> 'upheld_reports')::int,
  0,
  'a pending report is not counted as upheld'
);

-- The griefing case stated plainly: filing reports must not be a weapon.
select is(
  (public.reputation_score('11111111-1111-1111-1111-111111111111') ->> 'score')::int,
  0,
  'reputation cannot be lowered simply by filing a report'
);

-- ---------------------------------------------------------------------------
-- 4. Dismissed reports must NOT penalise (1)
-- ---------------------------------------------------------------------------
update public.reports
   set outcome = 'dismissed', resolved = true, resolved_at = now()
 where target_id = '11111111-1111-1111-1111-111111111111';

select is(
  (public.reputation_score('11111111-1111-1111-1111-111111111111') ->> 'score')::int,
  0,
  'a DISMISSED report does not penalise — the accusation was not upheld'
);

-- ---------------------------------------------------------------------------
-- 5. Upheld reports DO penalise (2)
-- ---------------------------------------------------------------------------
update public.reports
   set outcome = 'upheld'
 where target_id = '11111111-1111-1111-1111-111111111111';

select is(
  (public.reputation_score('11111111-1111-1111-1111-111111111111') ->> 'upheld_reports')::int,
  1,
  'an upheld report is counted'
);

select is(
  (public.reputation_score('11111111-1111-1111-1111-111111111111') ->> 'score')::int,
  -1,
  'an upheld report costs 1 point'
);

-- ---------------------------------------------------------------------------
-- 6. Distinct reporters — repeats from one person count once (1)
-- ---------------------------------------------------------------------------
insert into public.reports (reporter_id, target_id, target_type, reason, outcome)
values ('22222222-2222-2222-2222-222222222222',
        '11111111-1111-1111-1111-111111111111',
        'profile', 'Reported for Harassment — second report, same reporter', 'upheld');

select is(
  (public.reputation_score('11111111-1111-1111-1111-111111111111') ->> 'upheld_reports')::int,
  1,
  'two upheld reports from the SAME reporter count once (sockpuppet resistance)'
);

-- A second, independent reporter is a genuinely stronger signal.
insert into public.reports (reporter_id, target_id, target_type, reason, outcome)
values ('33333333-3333-3333-3333-333333333333',
        '11111111-1111-1111-1111-111111111111',
        'profile', 'Reported for Harassment — independent second reporter', 'upheld');

select is(
  (public.reputation_score('11111111-1111-1111-1111-111111111111') ->> 'upheld_reports')::int,
  2,
  'a second DISTINCT reporter does count'
);

-- ---------------------------------------------------------------------------
-- 7. Blocks must not leak through reputation_score (2)
-- ---------------------------------------------------------------------------
insert into public.blocks (blocker_id, blocked_id)
values ('44444444-4444-4444-4444-444444444444',
        '11111111-1111-1111-1111-111111111111');

select ok(
  not (public.reputation_score('11111111-1111-1111-1111-111111111111') ? 'distinct_blockers'),
  'reputation_score does not expose block counts (it is authenticated-readable)'
);

select is(
  (public.reputation_score('11111111-1111-1111-1111-111111111111') ->> 'score')::int,
  -2,
  'a block does not change the public score — only the two upheld reports do'
);

-- ---------------------------------------------------------------------------
-- 8. The private signal sees blocks, and is not publicly executable (2)
-- ---------------------------------------------------------------------------
select is(
  (public.moderation_risk_signal('11111111-1111-1111-1111-111111111111') ->> 'distinct_blockers')::int,
  1,
  'moderation_risk_signal does see the block'
);

select ok(
  not has_function_privilege('authenticated', 'public.moderation_risk_signal(uuid)', 'EXECUTE'),
  'moderation_risk_signal is NOT executable by authenticated'
);

select * from finish();
rollback;
