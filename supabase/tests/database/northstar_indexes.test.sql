-- pgTAP: north-star TIME indexes (step 9, migration 20260706160000).
-- Docs: https://supabase.com/docs/guides/database/testing + /extensions/pgtap

begin;
select plan(3);

select has_index(
  'public', 'meetup_outcomes', 'idx_meetup_outcomes_completed_at',
  'north-star: partial index on completed_at (outcome=completed) exists'
);
select has_index(
  'public', 'meetup_outcomes', 'idx_meetup_outcomes_outcome_created',
  'outcome cohorts over time index (outcome, created_at) exists'
);
select has_index(
  'public', 'meetups', 'idx_meetups_status_completed',
  'meetups status/time index (status, completed_at) exists'
);

select * from finish();
rollback;
