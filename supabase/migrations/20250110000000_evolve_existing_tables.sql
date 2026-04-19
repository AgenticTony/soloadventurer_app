-- ============================================================
-- SoloAdventurer — Migration 010
-- Evolve existing tables
-- ONLY uses ALTER TABLE ADD COLUMN / ADD CONSTRAINT.
-- Zero destructive changes. Existing data untouched.
-- ============================================================

-- ── profiles ─────────────────────────────────────────────────
-- Add missing columns needed for social platform.
-- Existing columns (email, username, full_name, avatar_url,
-- phone, date_of_birth, bio, location, preferences) untouched.

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS home_country   text,         -- ISO 3166-1 alpha-2
  ADD COLUMN IF NOT EXISTS website_url    text,
  ADD COLUMN IF NOT EXISTS is_active      boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS display_name   text          -- social display name, separate from full_name
                                                        -- defaults to full_name via trigger below
;

-- Backfill display_name from full_name for existing rows
UPDATE profiles SET display_name = full_name WHERE display_name IS NULL AND full_name IS NOT NULL;

-- Auto-set display_name from full_name on insert if not provided
CREATE OR REPLACE FUNCTION default_display_name()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.display_name IS NULL THEN
    NEW.display_name := COALESCE(NEW.full_name, NEW.username, 'Traveller');
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_profiles_display_name
  BEFORE INSERT ON profiles
  FOR EACH ROW EXECUTE FUNCTION default_display_name();

-- Full-text search vector (generated column — auto-maintained)
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS search_vector tsvector
    GENERATED ALWAYS AS (
      to_tsvector('english',
        COALESCE(username,     '') || ' ' ||
        COALESCE(display_name, '') || ' ' ||
        COALESCE(full_name,    '') || ' ' ||
        COALESCE(bio,          '') || ' ' ||
        COALESCE(home_country, '')
      )
    ) STORED;

CREATE INDEX IF NOT EXISTS idx_profiles_search
  ON profiles USING GIN (search_vector)
  WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_profiles_username
  ON profiles (username);

-- ── journals → social posts evolution ────────────────────────
-- The journals table becomes the posts/content layer.
-- Existing journal entries default to private audience.
-- New social posts use content_type = 'post', audience = 'followers'.

ALTER TABLE journals
  -- Social content controls
  ADD COLUMN IF NOT EXISTS content_type   text NOT NULL DEFAULT 'journal'
    CHECK (content_type IN ('journal', 'post', 'tip', 'photo')),
  ADD COLUMN IF NOT EXISTS audience       content_audience NOT NULL DEFAULT 'private',
  ADD COLUMN IF NOT EXISTS body           text,   -- alias for content; content stays for compatibility

  -- Location upgrade: float columns stay, PostGIS point added for geo queries
  ADD COLUMN IF NOT EXISTS location_point geography(Point, 4326),
  ADD COLUMN IF NOT EXISTS country_code   text,   -- ISO 3166-1 alpha-2

  -- Denormalised counters (maintained by triggers in migration 012)
  ADD COLUMN IF NOT EXISTS reaction_count int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS comment_count  int NOT NULL DEFAULT 0,

  -- Soft delete
  ADD COLUMN IF NOT EXISTS deleted_at     timestamptz
;

-- Backfill body from content for existing rows (keep content for Flutter compat)
UPDATE journals SET body = content WHERE body IS NULL;

-- Backfill location_point from existing lat/lon floats
UPDATE journals
SET location_point = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
WHERE latitude IS NOT NULL AND longitude IS NOT NULL AND location_point IS NULL;

-- Spatial index for destination discovery
CREATE INDEX IF NOT EXISTS idx_journals_location
  ON journals USING GIST (location_point)
  WHERE location_point IS NOT NULL AND deleted_at IS NULL;

-- Index for social feed queries
CREATE INDEX IF NOT EXISTS idx_journals_author_audience
  ON journals (user_id, audience, created_at DESC)
  WHERE deleted_at IS NULL;

-- Full-text search on posts
ALTER TABLE journals
  ADD COLUMN IF NOT EXISTS search_vector tsvector
    GENERATED ALWAYS AS (
      to_tsvector('english',
        COALESCE(body,          '') || ' ' ||
        COALESCE(content,       '') || ' ' ||
        COALESCE(location_name, '') || ' ' ||
        COALESCE(country_code,  '')
      )
    ) STORED;

CREATE INDEX IF NOT EXISTS idx_journals_search
  ON journals USING GIN (search_vector)
  WHERE deleted_at IS NULL;

-- ── trusted_contacts ─────────────────────────────────────────
-- Existing table has phone/email in plaintext.
-- Add encrypted shadow columns; Flutter app migrates values
-- via Edge Function. Existing phone column kept for compatibility
-- until migration is complete, then deprecated.

ALTER TABLE trusted_contacts
  ADD COLUMN IF NOT EXISTS contact_phone_enc  text,   -- encrypted via Supabase Vault
  ADD COLUMN IF NOT EXISTS contact_email_enc  text,   -- encrypted via Supabase Vault
  ADD COLUMN IF NOT EXISTS max_contacts_check boolean -- placeholder; enforced by trigger below
;

-- Remove placeholder column immediately (was just for comment anchor)
ALTER TABLE trusted_contacts DROP COLUMN IF EXISTS max_contacts_check;

-- Enforce max 5 active trusted contacts per user
CREATE OR REPLACE FUNCTION enforce_max_trusted_contacts()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF (
    SELECT COUNT(*) FROM trusted_contacts
    WHERE user_id = NEW.user_id AND is_active = true
  ) >= 5 THEN
    RAISE EXCEPTION 'Maximum of 5 active trusted contacts allowed per user';
  END IF;
  RETURN NEW;
END;
$$;

-- Only add trigger if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_max_trusted_contacts'
  ) THEN
    CREATE TRIGGER trg_max_trusted_contacts
      BEFORE INSERT ON trusted_contacts
      FOR EACH ROW EXECUTE FUNCTION enforce_max_trusted_contacts();
  END IF;
END;
$$;

-- ── check_ins (existing safety table) ────────────────────────
-- Add link to new meetup_checkins for the state machine bridge.
-- Existing check_ins data and behaviour untouched.

ALTER TABLE check_ins
  ADD COLUMN IF NOT EXISTS meetup_checkin_id uuid  -- FK added after meetup_checkins table exists (migration 011)
;
