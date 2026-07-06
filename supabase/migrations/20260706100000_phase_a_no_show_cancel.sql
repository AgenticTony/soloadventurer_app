-- ============================================================================
-- Phase A Story A.4 — close reward-fn v0.1: no-show + proposer-cancel paths
-- ============================================================================
-- docs/sprints/PHASE_A_LAY_THE_SPINE.md (Story A.4) · docs/reward-function-v0.1.md
-- The reward fn penalizes no-shows (−1 each) but nothing wrote a `no_show`
-- outcome until now, so that term was structurally always 0.
--
-- Attribution fix: `meetup_outcomes` had no record of WHO no-showed, and
-- `reputation_score` counted a no_show against BOTH parties — the traveler who
-- showed up would take the −1. `no_show_user_id` scopes the penalty to the
-- absent party only.
--
-- Docs grounded (→ PR "Sources"):
--   • https://supabase.com/docs/guides/database/functions
--       — SECURITY DEFINER requires `set search_path`; revoke execute from
--         public/anon, grant to authenticated (same pattern as Phase A RPCs).
--   • https://supabase.com/docs/guides/auth/row-level-security
--       — writes stay denied at the table; all mutations via SECURITY DEFINER RPCs.
-- ============================================================================

-- 1. Attribution column ------------------------------------------------------
alter table public.meetup_outcomes
  add column if not exists no_show_user_id uuid;

-- A no_show outcome must name the absent party; a completed outcome must not.
do $$ begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'meetup_outcomes_no_show_attributed'
      and conrelid = 'public.meetup_outcomes'::regclass
  ) then
    alter table public.meetup_outcomes
      add constraint meetup_outcomes_no_show_attributed
      check ((outcome = 'no_show') = (no_show_user_id is not null));
  end if;
end $$;

create index if not exists idx_meetup_outcomes_no_show
  on public.meetup_outcomes (no_show_user_id)
  where no_show_user_id is not null;

-- 2. report_no_show ----------------------------------------------------------
-- The caller (a party who showed up) reports that the OTHER party did not.
-- Guards: party-only · meetup must be confirmed · meetup_time must have passed ·
-- blocked once either party has tapped "we met" (contradicts a no-show claim).
-- Terminalizes the meetup (cancelled) so it cannot later be completed while the
-- L0 outcome says no_show.
create or replace function public.report_no_show(p_meetup_id uuid)
returns void
language plpgsql security definer set search_path = public as $$
declare m record;
begin
  select * into m from public.meetups where id = p_meetup_id for update;
  if not found then raise exception 'Meetup not found'; end if;
  if auth.uid() is null or auth.uid() not in (m.user_a_id, m.user_b_id) then
    raise exception 'Not a party to this meetup';
  end if;
  if m.status <> 'confirmed' then
    raise exception 'No-shows can only be reported on confirmed meetups';
  end if;
  if m.meetup_time > now() then
    raise exception 'Cannot report a no-show before the meetup time';
  end if;
  if m.a_met_at is not null or m.b_met_at is not null then
    raise exception 'A party has already confirmed this meetup happened';
  end if;

  insert into public.meetup_outcomes (meetup_id, user_a_id, user_b_id, outcome, no_show_user_id)
  values (p_meetup_id, m.user_a_id, m.user_b_id, 'no_show',
          case when auth.uid() = m.user_a_id then m.user_b_id else m.user_a_id end);

  update public.meetups
     set status = 'cancelled', cancelled_at = now()
   where id = p_meetup_id;
end; $$;
revoke execute on function public.report_no_show(uuid) from public, anon;
grant  execute on function public.report_no_show(uuid) to authenticated;

-- 3. cancel_meetup -----------------------------------------------------------
-- Either party may cancel while proposed/confirmed (closes the gap where only
-- the invited party could decline, via respond_meetup). No-fault in v0.1: a
-- cancellation writes NO outcome row and carries no reputation penalty.
create or replace function public.cancel_meetup(p_meetup_id uuid)
returns void
language plpgsql security definer set search_path = public as $$
declare m record;
begin
  select * into m from public.meetups where id = p_meetup_id for update;
  if not found then raise exception 'Meetup not found'; end if;
  if auth.uid() is null or auth.uid() not in (m.user_a_id, m.user_b_id) then
    raise exception 'Not a party to this meetup';
  end if;
  if m.status not in ('proposed', 'confirmed') then
    raise exception 'Only proposed or confirmed meetups can be cancelled';
  end if;

  update public.meetups
     set status = 'cancelled', cancelled_at = now()
   where id = p_meetup_id;
end; $$;
revoke execute on function public.cancel_meetup(uuid) from public, anon;
grant  execute on function public.cancel_meetup(uuid) to authenticated;

-- 4. reputation_score — attribute the no-show penalty to the absent party only.
-- Formula unchanged (reward fn v0.1): 2×completed + floor(vouch_pct/10) − no_shows.
create or replace function public.reputation_score(p_user_id uuid)
returns jsonb
language sql stable security definer set search_path = public as $$
  with completed as (
    select count(*)::int as n
    from public.meetup_outcomes
    where p_user_id in (user_a_id, user_b_id) and outcome = 'completed'
  ),
  reviews as (
    select count(*)::int as n,
           coalesce(round(avg(rating)::numeric, 2), 0) as avg_rating,
           coalesce(round(100.0 * count(*) filter (where would_meet_again)
                          / nullif(count(*), 0))::numeric, 0) as vouch_pct
    from public.member_reviews
    where reviewed_id = p_user_id
  ),
  no_shows as (
    select count(*)::int as n
    from public.meetup_outcomes
    where outcome = 'no_show' and no_show_user_id = p_user_id
  )
  select jsonb_build_object(
    'user_id', p_user_id,
    'meetups_completed', (select n from completed),
    'review_count',      (select n from reviews),
    'avg_rating',        (select avg_rating from reviews),
    'vouch_pct',         (select vouch_pct from reviews),
    'no_shows',          (select n from no_shows),
    'score',             (select n from completed) * 2
                         + floor(coalesce((select vouch_pct from reviews)::int, 0) / 10.0)::int
                         - (select n from no_shows)
  );
$$;
revoke execute on function public.reputation_score(uuid) from public, anon;
grant  execute on function public.reputation_score(uuid) to authenticated;
