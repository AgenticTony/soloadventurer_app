-- ============================================================
-- SoloAdventurer — Base journals / trusted_contacts / check_ins tables
--
-- HISTORICAL GAP (same class as 20250109500000_create_profiles.sql): these three
-- tables were created via the Supabase dashboard and had no migration in this repo.
-- Migration 20250110000000_evolve_existing_tables ALTERs all three, so a fresh
-- local/CI `supabase start` fails there ("relation journals does not exist",
-- SQLSTATE 42P01). Base columns only; later columns are added downstream via
-- ALTER TABLE ADD COLUMN IF NOT EXISTS. CREATE TABLE IF NOT EXISTS makes this a
-- no-op on prod. See issue #9 / PR #10.
-- ============================================================

CREATE TABLE IF NOT EXISTS public.journals (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title         text,
  content       text,
  location_name text,
  latitude      double precision,
  longitude     double precision,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_journals_user_id ON public.journals (user_id);

CREATE TABLE IF NOT EXISTS public.trusted_contacts (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  contact_name  text,
  contact_phone text,
  contact_email text,
  is_active     boolean NOT NULL DEFAULT true,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_trusted_contacts_user_id ON public.trusted_contacts (user_id);

CREATE TABLE IF NOT EXISTS public.check_ins (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status        text,
  scheduled_at  timestamptz,
  completed_at  timestamptz,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_check_ins_user_id ON public.check_ins (user_id);
