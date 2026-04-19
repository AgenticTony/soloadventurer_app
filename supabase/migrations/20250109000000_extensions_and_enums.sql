-- ============================================================
-- SoloAdventurer — Migration 009
-- Extensions and ENUMs
-- Numbered 009+ to follow your existing 3 migrations.
-- All additive — zero changes to existing tables.
-- ============================================================

-- Extensions (safe to re-run with IF NOT EXISTS)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_cron";
CREATE EXTENSION IF NOT EXISTS "pgsodium";

-- ── ENUMs ────────────────────────────────────────────────────

CREATE TYPE verification_tier AS ENUM (
  'unverified',
  'email',
  'id_verified'
);

CREATE TYPE profile_visibility AS ENUM (
  'hidden',       -- nobody can find you; you initiate connections
  'community',    -- visible to users who pass your privacy filters
  'public'        -- fully visible; indexed on web
);

CREATE TYPE content_audience AS ENUM (
  'public',       -- anyone including unauthenticated web visitors
  'community',    -- all logged-in users passing visibility rules
  'followers',    -- accepted followers only
  'verified',     -- id_verified users only
  'private'       -- author only
);

CREATE TYPE comment_permission AS ENUM (
  'all',
  'followers',
  'verified',
  'none'
);

CREATE TYPE follow_status AS ENUM (
  'pending',
  'accepted'
);

CREATE TYPE report_target_type AS ENUM (
  'profile',
  'post',
  'comment',
  'message'
);

-- Extends existing check_ins.status — new table uses this enum
CREATE TYPE checkin_status AS ENUM (
  'scheduled',
  'active',
  'checked_in',
  'alerted',
  'sos',
  'cancelled'
);

CREATE TYPE alert_type AS ENUM (
  'reminder',
  'escalation',
  'sos'
);

CREATE TYPE feed_verb AS ENUM (
  'posted',
  'followed',
  'reacted',
  'commented'
);

CREATE TYPE reaction_type AS ENUM (
  'like',
  'love',
  'inspire',   -- "this inspires me to visit"
  'helpful'    -- useful tip or advice
);

-- ── Shared trigger: auto-update updated_at ───────────────────
-- Safe to create even if it already exists (used by new tables)
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;
