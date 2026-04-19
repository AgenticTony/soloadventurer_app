-- SoloAdventurer Matching Feature - Core Tables (Columns, Tables, Indexes)
-- Migration: 20260401_120000_matching_columns.sql
-- Created: 2026-04-01
-- Purpose: Core matching tables for profiles, trips, connections, and activities
-- FIXED: Compatible with existing schema (profiles, trips, blocks, follows, journals, check_ins)

-- ============================================================================
-- 1. PROFILES TABLE - Add matching columns to existing table
-- ============================================================================

-- Add matching-specific columns to existing profiles table
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS age_range TEXT CHECK (char_length(age_range) >= 4 AND char_length(age_range) <= 5),
  ADD COLUMN IF NOT EXISTS gender TEXT CHECK (gender IN ('male', 'female', 'non-binary', 'prefer-not-to-say')),
  ADD COLUMN IF NOT EXISTS gender_verified BOOLEAN DEFAULT false;

-- Indexes for matching queries on profiles
CREATE INDEX IF NOT EXISTS idx_profiles_gender ON profiles(gender) WHERE gender IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_profiles_age_range ON profiles(age_range) WHERE age_range IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_profiles_gender_verified ON profiles(gender_verified) WHERE gender_verified = true;

-- ============================================================================
-- 2. TRIPS TABLE - Add matching columns to existing table
-- ============================================================================

-- Add matching-specific columns to existing trips table
ALTER TABLE trips
  ADD COLUMN IF NOT EXISTS destination_name TEXT,
  ADD COLUMN IF NOT EXISTS destination_city TEXT,
  ADD COLUMN IF NOT EXISTS destination_country TEXT,
  ADD COLUMN IF NOT EXISTS location GEOGRAPHY(POINT, 4326),
  ADD COLUMN IF NOT EXISTS visibility TEXT NOT NULL DEFAULT 'everyone' CHECK (visibility IN ('everyone', 'women-only', 'private'));

-- Backfill destination_name from existing destination column
UPDATE trips 
SET destination_name = destination 
WHERE destination_name IS NULL AND destination IS NOT NULL;

-- Indexes for matching on trips
DROP INDEX IF EXISTS idx_trips_user_id;
CREATE INDEX IF NOT EXISTS idx_trips_user_id ON trips(user_id);
CREATE INDEX IF NOT EXISTS idx_trips_active_matching ON trips(user_id, start_date, end_date) WHERE is_active = true OR is_public = true;
CREATE INDEX IF NOT EXISTS idx_trips_dates_matching ON trips(start_date, end_date) WHERE is_active = true OR is_public = true;
CREATE INDEX IF NOT EXISTS idx_trips_visibility ON trips(visibility) WHERE visibility IN ('everyone', 'women-only');

-- ============================================================================
-- 3. CONNECTIONS (Match requests with state machine) - NEW TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id UUID NOT NULL,  -- User who initiated the connection
  recipient_id UUID NOT NULL,  -- User receiving the connection request
  
  -- Status (pending -> accepted/declined/blocked)
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'blocked')),
  
  -- Trip context (which trips overlapped to create this connection)
  requester_trip_id UUID REFERENCES trips(id) ON DELETE SET NULL,
  recipient_trip_id UUID REFERENCES trips(id) ON DELETE SET NULL,
  
  -- Activity icebreaker (optional - what activity started this)
  activity_id UUID,  -- References activities table (defined below)
  
  -- Overlap info for relevance scoring
  overlap_start_date DATE,
  overlap_end_date DATE,
  overlap_days INTEGER,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  responded_at TIMESTAMPTZ,  -- When accepted/declined
  
  -- Constraints
  CONSTRAINT unique_connection UNIQUE (requester_id, recipient_id),
  CONSTRAINT no_self_connection CHECK (requester_id != recipient_id)
);

-- Indexes for connections
CREATE INDEX IF NOT EXISTS idx_connections_requester ON connections(requester_id) WHERE status IN ('pending', 'accepted');
CREATE INDEX IF NOT EXISTS idx_connections_recipient ON connections(recipient_id) WHERE status IN ('pending', 'accepted');
CREATE INDEX IF NOT EXISTS idx_connections_status ON connections(status);
CREATE INDEX IF NOT EXISTS idx_connections_accepted ON connections(requester_id, recipient_id) WHERE status = 'accepted';

-- ============================================================================
-- 4. ACTIVITIES (Icebreaker suggestions) - NEW TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,  -- e.g., "coffee", "hiking", "nightlife"
  display_name TEXT NOT NULL,  -- e.g., "Grab Coffee", "Go Hiking"
  category TEXT NOT NULL,  -- e.g., "food", "outdoor", "culture", "entertainment"
  icon TEXT,  -- Emoji or icon identifier
  description TEXT,
  
  -- Location constraints
  is_location_specific BOOLEAN DEFAULT false,
  location_restriction GEOGRAPHY(POLYGON, 4326),  -- e.g., hiking only in mountains
  
  -- Ordering
  sort_order INTEGER DEFAULT 0,
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Seed activities (use ON CONFLICT to avoid errors on re-run)
INSERT INTO activities (name, display_name, category, icon, sort_order) VALUES
  ('coffee', 'Grab Coffee', 'food', '☕', 1),
  ('meal', 'Have a Meal', 'food', '🍽️', 2),
  ('sightseeing', 'Explore Together', 'culture', '🏛️', 3),
  ('hiking', 'Go Hiking', 'outdoor', '🥾', 4),
  ('nightlife', 'Night Out', 'entertainment', '🎉', 5),
  ('museums', 'Visit Museums', 'culture', '🎨', 6),
  ('beach', 'Beach Day', 'outdoor', '🏖️', 7),
  ('shopping', 'Go Shopping', 'leisure', '🛍️', 8),
  ('photography', 'Photo Walk', 'creative', '📷', 9),
  ('sports', 'Play Sports', 'active', '⚽', 10)
ON CONFLICT (name) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  icon = EXCLUDED.icon,
  sort_order = EXCLUDED.sort_order;

-- User's activity interests (for matching and suggestions) - NEW TABLE
CREATE TABLE IF NOT EXISTS user_activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  CONSTRAINT unique_user_activity UNIQUE (user_id, activity_id)
);

CREATE INDEX IF NOT EXISTS idx_user_activities_user ON user_activities(user_id);
CREATE INDEX IF NOT EXISTS idx_user_activities_activity ON user_activities(activity_id);

-- ============================================================================
-- 5. MESSAGES (1:1 chat between connected users) - NEW TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  connection_id UUID NOT NULL REFERENCES connections(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL,
  receiver_id UUID NOT NULL,
  
  -- Message content
  content TEXT NOT NULL CHECK (char_length(content) >= 1 AND char_length(content) <= 5000),
  
  -- Context (if message started from activity suggestion)
  activity_id UUID REFERENCES activities(id) ON DELETE SET NULL,
  
  -- Status
  sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  delivered_at TIMESTAMPTZ,
  read_at TIMESTAMPTZ,
  
  -- For offline sync
  client_message_id TEXT,  -- Client-generated ID for deduplication
  client_created_at TIMESTAMPTZ  -- When client created message (may differ from sent_at)
);

-- Indexes for messages
CREATE INDEX IF NOT EXISTS idx_messages_connection ON messages(connection_id, sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id, sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_receiver ON messages(receiver_id, sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_unread ON messages(receiver_id, read_at) WHERE read_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_messages_client_id ON messages(client_message_id) WHERE client_message_id IS NOT NULL;
