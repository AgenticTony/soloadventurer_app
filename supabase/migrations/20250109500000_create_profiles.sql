-- ============================================================
-- SoloAdventurer — Base profiles table
-- Links each auth.users row to a public profile.
--
-- HISTORICAL GAP: the `profiles` table was created via the Supabase dashboard and had no
-- migration in this repo. Every later migration (010 evolve_existing_tables, RLS, social
-- tables, matching, embeddings, sos_alerts) assumes it already exists, so a fresh local/CI
-- `supabase start` failed at migration 010 with "relation profiles does not exist".
-- This base migration establishes exactly the columns migration 010 lists as pre-existing
-- (email, username, full_name, avatar_url, phone, date_of_birth, bio, location, preferences);
-- later columns are added via ALTER TABLE ADD COLUMN IF NOT EXISTS downstream, and RLS is
-- enabled by migration 20250112000000_rls_policies.sql.
-- CREATE TABLE IF NOT EXISTS makes this a no-op on a prod stack that already has the table.
-- See issue #9.
-- ============================================================

CREATE TABLE IF NOT EXISTS public.profiles (
  id            uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email         text,
  username      text,
  full_name     text,
  avatar_url    text,
  phone         text,
  date_of_birth date,
  bio           text,
  location      text,
  preferences   jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);
