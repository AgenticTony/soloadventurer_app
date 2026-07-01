-- ============================================================================
-- Phase A: meetups (the atomic unit) + L0 outcomes + bilateral reputation
-- ============================================================================
-- FOUNDATIONS §4 (AI spine — L0/L2/L4) and §9 (Phase A).
-- Review gate: MUTUAL CONFIRMATION (both travelers tap "we met").
-- Scope: backend-only (tables + RPCs + RLS + triggers). No client changes.
--
-- Docs grounded (pinned URLs → PR "Sources"):
--   • https://supabase.com/docs/guides/database/functions
--       — SECURITY DEFINER REQUIRES `set search_path`; restrict execute
--         (revoke from public/anon, grant to authenticated).
--   • https://supabase.com/docs/guides/auth/row-level-security
--       — enable RLS on exposed-schema tables; `(select auth.uid())`; `TO authenticated`;
--         index the uid columns; direct writes denied here (no INSERT/UPDATE policy)
--         to force all writes through the SECURITY DEFINER RPCs.
--   • https://supabase.com/docs/guides/database/testing + /extensions/pgtap
--       — pgTAP via `supabase test db`.
-- Reward function spec: docs/reward-function-v0.1.md
-- ============================================================================

-- 1. ENUM --------------------------------------------------------------------
do $$ begin
  if not exists (
    select 1 from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'meetup_status' and n.nspname = 'public'
  ) then
    create type public.meetup_status as enum ('proposed', 'confirmed', 'completed', 'cancelled');
  end if;
end $$;

-- 2. TABLES ------------------------------------------------------------------

-- The atomic unit: a meetup between two connected travelers.
create table if not exists public.meetups (
  id             uuid primary key default gen_random_uuid(),
  connection_id  uuid references public.connections(id) on delete set null,
  user_a_id      uuid not null,   -- connection.requester_id
  user_b_id      uuid not null,   -- connection.recipient_id
  proposed_by    uuid not null,
  meetup_time    timestamptz not null,
  location_name  text,
  location_point geography(Point, 4326),  -- reserved for the Phase C co-location gate
  a_met_at       timestamptz,             -- mutual confirmation: user_a taps "we met"
  b_met_at       timestamptz,             -- mutual confirmation: user_b taps "we met"
  status         public.meetup_status not null default 'proposed',
  completed_at   timestamptz,
  cancelled_at   timestamptz,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  constraint meetups_pair_diff check (user_a_id <> user_b_id)
);
create index if not exists idx_meetups_user_a on public.meetups (user_a_id);
create index if not exists idx_meetups_user_b on public.meetups (user_b_id);
create index if not exists idx_meetups_status  on public.meetups (status);

-- L0 outcome store: one factual outcome per meetup.
create table if not exists public.meetup_outcomes (
  id           uuid primary key default gen_random_uuid(),
  meetup_id    uuid not null unique references public.meetups(id) on delete cascade,
  user_a_id    uuid not null,
  user_b_id    uuid not null,
  outcome      text not null check (outcome in ('completed', 'no_show')),
  completed_at timestamptz,
  created_at   timestamptz not null default now()
);
create index if not exists idx_meetup_outcomes_a on public.meetup_outcomes (user_a_id);
create index if not exists idx_meetup_outcomes_b on public.meetup_outcomes (user_b_id);

-- Bilateral, directional reviews — gated on a completed meetup.
create table if not exists public.member_reviews (
  id               uuid primary key default gen_random_uuid(),
  meetup_id        uuid not null references public.meetups(id) on delete cascade,
  reviewer_id      uuid not null,
  reviewed_id      uuid not null,
  rating           smallint not null check (rating between 1 and 5),
  would_meet_again boolean   not null,            -- the "vouch"
  content          text check (char_length(content) <= 1000),
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  constraint reviews_pair_diff        check (reviewer_id <> reviewed_id),
  constraint reviews_one_per_direction unique (meetup_id, reviewer_id)
);
create index if not exists idx_reviews_reviewed on public.member_reviews (reviewed_id);
create index if not exists idx_reviews_reviewer on public.member_reviews (reviewer_id);

-- 3. GRANTS (Data API access — reads only; writes go via RPCs) ---------------
grant select on public.meetups, public.meetup_outcomes, public.member_reviews to authenticated;

-- 4. RLS ---------------------------------------------------------------------
alter table public.meetups         enable row level security;
alter table public.meetup_outcomes enable row level security;
alter table public.member_reviews  enable row level security;

create policy "meetups: parties read"
  on public.meetups for select to authenticated
  using ( (select auth.uid()) in (user_a_id, user_b_id) );

create policy "meetup_outcomes: parties read"
  on public.meetup_outcomes for select to authenticated
  using ( (select auth.uid()) in (user_a_id, user_b_id) );

create policy "member_reviews: reviewer + reviewed read"
  on public.member_reviews for select to authenticated
  using ( (select auth.uid()) in (reviewer_id, reviewed_id) );
-- No INSERT/UPDATE/DELETE policies → direct writes are denied → clients MUST use the RPCs.

-- 5. updated_at trigger (Phase-A-local function name to avoid collisions) -----
create or replace function public.phase_a_set_updated_at()
returns trigger language plpgsql set search_path = public as $$
begin
  new.updated_at := now();
  return new;
end; $$;

drop trigger if exists trg_meetups_updated_at on public.meetups;
create trigger trg_meetups_updated_at before update on public.meetups
  for each row execute function public.phase_a_set_updated_at();

drop trigger if exists trg_reviews_updated_at on public.member_reviews;
create trigger trg_reviews_updated_at before update on public.member_reviews
  for each row execute function public.phase_a_set_updated_at();

-- 6. RPCs — SECURITY DEFINER (bypass RLS so the fn can write the rows it has
--    validated). `set search_path = public` is mandatory for SECURITY DEFINER.
--    Every fn asserts auth.uid() is a party; execute is restricted to authenticated.

-- Propose a meetup from an ACCEPTED connection. Returns the new meetup id.
create or replace function public.propose_meetup(
  p_connection_id uuid,
  p_meetup_time   timestamptz,
  p_location_name text default null
) returns uuid
language plpgsql security definer set search_path = public as $$
declare
  v_meetup_id uuid;
  v_conn      record;
begin
  select requester_id, recipient_id, status into v_conn
  from public.connections where id = p_connection_id;
  if not found then
    raise exception 'Connection not found';
  end if;
  if v_conn.status <> 'accepted' then
    raise exception 'Meetups require an accepted connection';
  end if;
  if auth.uid() is null or auth.uid() not in (v_conn.requester_id, v_conn.recipient_id) then
    raise exception 'Not a party to this connection';
  end if;

  insert into public.meetups
    (connection_id, user_a_id, user_b_id, proposed_by, meetup_time, location_name, status)
  values
    (p_connection_id, v_conn.requester_id, v_conn.recipient_id, auth.uid(), p_meetup_time, p_location_name, 'proposed')
  returning id into v_meetup_id;

  return v_meetup_id;
end; $$;
revoke execute on function public.propose_meetup(uuid, timestamptz, text) from public, anon;
grant  execute on function public.propose_meetup(uuid, timestamptz, text) to authenticated;

-- Respond to a proposed meetup (only the invited party).
create or replace function public.respond_meetup(
  p_meetup_id uuid,
  p_accept    boolean
) returns void
language plpgsql security definer set search_path = public as $$
declare m record;
begin
  select * into m from public.meetups where id = p_meetup_id for update;
  if not found then raise exception 'Meetup not found'; end if;
  if m.status <> 'proposed' then raise exception 'Meetup is not in the proposed state'; end if;
  if auth.uid() is null or auth.uid() = m.proposed_by then
    raise exception 'Only the invited party can respond';
  end if;
  if auth.uid() not in (m.user_a_id, m.user_b_id) then
    raise exception 'Not a party to this meetup';
  end if;

  if p_accept then
    update public.meetups set status = 'confirmed' where id = p_meetup_id;
  else
    update public.meetups set status = 'cancelled', cancelled_at = now() where id = p_meetup_id;
  end if;
end; $$;
revoke execute on function public.respond_meetup(uuid, boolean) from public, anon;
grant  execute on function public.respond_meetup(uuid, boolean) to authenticated;

-- Mutual confirmation: the caller taps "we met". When BOTH parties have confirmed,
-- status → completed and the meetup_outcomes row is written.
create or replace function public.complete_meetup(p_meetup_id uuid)
returns void
language plpgsql security definer set search_path = public as $$
declare m record;
begin
  select * into m from public.meetups where id = p_meetup_id for update;
  if not found then raise exception 'Meetup not found'; end if;
  if m.status not in ('confirmed', 'completed') then
    raise exception 'Meetup must be confirmed before completion';
  end if;
  if auth.uid() is null or auth.uid() not in (m.user_a_id, m.user_b_id) then
    raise exception 'Not a party to this meetup';
  end if;

  if auth.uid() = m.user_a_id and m.a_met_at is null then
    update public.meetups set a_met_at = now() where id = p_meetup_id;
  elsif auth.uid() = m.user_b_id and m.b_met_at is null then
    update public.meetups set b_met_at = now() where id = p_meetup_id;
  end if;

  -- Finalize when both have confirmed.
  update public.meetups
     set status = 'completed', completed_at = now()
   where id = p_meetup_id
     and a_met_at is not null and b_met_at is not null
     and status <> 'completed';

  insert into public.meetup_outcomes (meetup_id, user_a_id, user_b_id, outcome, completed_at)
  select id, user_a_id, user_b_id, 'completed', completed_at
  from public.meetups
  where id = p_meetup_id and status = 'completed'
  on conflict (meetup_id) do nothing;
end; $$;
revoke execute on function public.complete_meetup(uuid) from public, anon;
grant  execute on function public.complete_meetup(uuid) to authenticated;

-- Submit a bilateral review. Gated: party + meetup completed + one review/direction.
create or replace function public.submit_review(
  p_meetup_id        uuid,
  p_rating           smallint,
  p_would_meet_again boolean,
  p_content          text default null
) returns uuid
language plpgsql security definer set search_path = public as $$
declare
  v_id    uuid;
  m       record;
  v_other uuid;
begin
  if p_rating not between 1 and 5 then
    raise exception 'rating must be between 1 and 5';
  end if;
  select * into m from public.meetups where id = p_meetup_id;
  if not found then raise exception 'Meetup not found'; end if;
  if m.status <> 'completed' then
    raise exception 'Can only review completed meetups';
  end if;
  if auth.uid() is null or auth.uid() not in (m.user_a_id, m.user_b_id) then
    raise exception 'Not a party to this meetup';
  end if;
  v_other := case when auth.uid() = m.user_a_id then m.user_b_id else m.user_a_id end;

  insert into public.member_reviews (meetup_id, reviewer_id, reviewed_id, rating, would_meet_again, content)
  values (p_meetup_id, auth.uid(), v_other, p_rating, p_would_meet_again, p_content)
  returning id into v_id;

  return v_id;
end; $$;
revoke execute on function public.submit_review(uuid, smallint, boolean, text) from public, anon;
grant  execute on function public.submit_review(uuid, smallint, boolean, text) to authenticated;

-- reputation_score: implements reward fn v0.1 (docs/reward-function-v0.1.md).
-- Aggregates completed meetups, reviews (avg rating, vouch %, count) and no-shows.
-- (blocks/reports penalties deferred to v0.1.1 — see the spec.)
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
    from public.meetup_outcomes o
    join public.meetups m on m.id = o.meetup_id
    where o.outcome = 'no_show'
      and p_user_id in (m.user_a_id, m.user_b_id)
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
