-- ============================================================================
-- 20260813100000_create_waitlist_entries.sql
-- Waitlist capture for the web landing page (soloadventurer.com/waitlist).
--
-- Visitors are NOT authenticated, so the anon role needs to insert.
-- All PII reads go through SECURITY DEFINER functions, never through client
-- queries. No client SELECT/UPDATE/DELETE — ever.
-- ============================================================================

-- NOTE (2026-08-14): this migration originally opened with
--   drop table if exists public.waitlist_entries cascade;
-- to clear a partial state from a first attempt that failed on gen_random_bytes.
-- That cleanup has long since happened, and the DROP became a live hazard: the
-- table exists in production with real signups, and this file was never applied
-- through the migration ledger, so `supabase db push` would have replayed the
-- DROP and destroyed them. Removed and made idempotent instead.
--
-- The function drops are likewise gone: `create or replace` below handles them,
-- and dropping a SECURITY DEFINER function briefly removes its grants.

create table if not exists public.waitlist_entries (
  id               uuid primary key default gen_random_uuid(),
  email            text not null unique,
  first_name       text,
  city             text,
  referral_code    text not null default upper(substring(md5(random()::text || clock_timestamp()::text) from 1 for 8)),
  referred_by_code text,
  created_at       timestamptz not null default now()
);

create index if not exists idx_waitlist_referral_code on public.waitlist_entries(referral_code);
create index if not exists idx_waitlist_referred_by  on public.waitlist_entries(referred_by_code);
create index if not exists idx_waitlist_created_at   on public.waitlist_entries(created_at desc);

-- ----------------------------------------------------------------------------
-- RLS: anon can INSERT only. No SELECT/UPDATE/DELETE from client.
-- The rank/count and referral resolution all go through SECURITY DEFINER
-- functions below, which bypass RLS safely.
-- ----------------------------------------------------------------------------
alter table public.waitlist_entries enable row level security;

drop policy if exists "waitlist_anon_insert" on public.waitlist_entries;
create policy "waitlist_anon_insert"
  on public.waitlist_entries
  for insert
  to anon, authenticated
  with check (true);

-- ----------------------------------------------------------------------------
-- SECURITY DEFINER: join the waitlist atomically.
-- Inserts (or returns existing row if email already registered), resolves
-- the referral code, and returns { referral_code, rank, total }.
-- No PII is returned beyond what the visitor themselves submitted.
-- ----------------------------------------------------------------------------
create or replace function public.join_waitlist(
  p_email text,
  p_first_name text default null,
  p_city text default null,
  p_referred_by_code text default null
)
returns table(
  referral_code text,
  rank bigint,
  total bigint,
  is_new boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_existing_code text;
  v_existing_created timestamptz;
  v_new_code text;
  v_ref text;
  v_is_new boolean := true;
begin
  p_email := lower(trim(p_email));
  if p_email !~ '^\S+@\S+\.\S+$' then
    raise exception 'Invalid email';
  end if;

  -- Check for existing entry
  select referral_code, created_at
    into v_existing_code, v_existing_created
    from public.waitlist_entries
    where email = p_email
    limit 1;

  if found then
    v_is_new := false;
    return query
      select
        v_existing_code,
        (select count(*) + 1 from public.waitlist_entries where created_at < v_existing_created)::bigint,
        (select count(*) from public.waitlist_entries)::bigint,
        false;
    return;
  end if;

  -- Resolve referrer code (must exist to count)
  v_ref := null;
  if p_referred_by_code is not null then
    select 1 into v_ref
      from public.waitlist_entries
      where referral_code = upper(trim(p_referred_by_code));
    if v_ref is not null then
      v_ref := upper(trim(p_referred_by_code));
    end if;
  end if;

  -- Insert with server-generated referral code
  v_new_code := upper(substring(md5(random()::text || clock_timestamp()::text) from 1 for 8));

  insert into public.waitlist_entries (email, first_name, city, referral_code, referred_by_code)
  values (p_email, p_first_name, p_city, v_new_code, v_ref);

  return query
    select
      v_new_code,
      (select count(*)::bigint from public.waitlist_entries),
      (select count(*)::bigint from public.waitlist_entries),
      true;
end;
$$;

-- ----------------------------------------------------------------------------
-- SECURITY DEFINER: returns only the total count (for the live counter).
-- ----------------------------------------------------------------------------
create or replace function public.get_waitlist_count()
returns integer
language sql stable
security definer
set search_path = public
as $$
  select count(*)::integer from public.waitlist_entries;
$$;

comment on table public.waitlist_entries is
  'Email capture for the landing-page waitlist. Anon INSERT only; all reads via SECURITY DEFINER functions.';

-- ----------------------------------------------------------------------------
-- Ledger note
-- ----------------------------------------------------------------------------
-- These objects were applied to production out of band and this file was never
-- committed, so production carried schema that existed in no migration — a repave
-- would have silently dropped the waitlist. Committing it closes that gap.
--
-- Because the objects are already live, mark this version applied rather than
-- letting `db push` replay it:
--
--   supabase migration repair --status applied 20260813100000
--
-- The file is now idempotent either way, so a replay is survivable rather than
-- destructive.
