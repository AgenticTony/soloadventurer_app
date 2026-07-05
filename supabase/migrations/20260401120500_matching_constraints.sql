-- SoloAdventurer Matching Feature - Constraints, Functions, Triggers
-- Migration: 20260401_120500_matching_constraints.sql
-- Created: 2026-04-01
-- Purpose: Add constraints, functions, triggers after columns/tables exist
-- NOTE: Must run AFTER 20260401_120000_matching_columns.sql

-- ============================================================================
-- 1. PROFILES CONSTRAINTS
-- ============================================================================

-- Create check constraint for valid age_range values
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'valid_age_range' 
    AND conrelid = 'profiles'::regclass
  ) THEN
    ALTER TABLE profiles 
    ADD CONSTRAINT valid_age_range 
    CHECK (age_range IS NULL OR age_range IN ('18-24', '25-34', '35-44', '45-54', '55+'));
  END IF;
END $$;

-- ============================================================================
-- 2. TRIPS CONSTRAINTS
-- ============================================================================

-- Add check constraint for date range
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'valid_trip_duration' 
    AND conrelid = 'trips'::regclass
  ) THEN
    ALTER TABLE trips 
    ADD CONSTRAINT valid_trip_duration 
    CHECK (end_date IS NULL OR (end_date - start_date <= 90));
  END IF;
END $$;

-- ============================================================================
-- 3. CONNECTIONS FK AND TRIGGERS
-- ============================================================================

-- Add FK from connections to activities now that table exists
ALTER TABLE connections
  DROP CONSTRAINT IF EXISTS fk_connections_activity,
  ADD CONSTRAINT fk_connections_activity
  FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE SET NULL;

-- Trigger for updated_at (using existing function from migration 009)
DROP TRIGGER IF EXISTS trigger_connections_updated_at ON connections;
CREATE TRIGGER trigger_connections_updated_at
  BEFORE UPDATE ON connections
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- 4. HELPER FUNCTIONS
-- ============================================================================

-- Function to check if two users have an active connection
CREATE OR REPLACE FUNCTION has_active_connection(user_a UUID, user_b UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM connections
    WHERE status = 'accepted'
      AND (
        (requester_id = user_a AND recipient_id = user_b)
        OR
        (requester_id = user_b AND recipient_id = user_a)
      )
  );
END;
$$ LANGUAGE plpgsql STABLE;

-- Function to check if users are blocked (use existing blocks table)
CREATE OR REPLACE FUNCTION are_users_blocked(user_a UUID, user_b UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM blocks
    WHERE (blocker_id = user_a AND blocked_id = user_b)
       OR (blocker_id = user_b AND blocked_id = user_a)
  );
END;
$$ LANGUAGE plpgsql STABLE;

-- Function to archive expired trips (run daily via cron/edge function)
CREATE OR REPLACE FUNCTION archive_expired_trips()
RETURNS INTEGER AS $$
DECLARE
  archived_count INTEGER;
BEGIN
  -- Note: trips table uses is_public, not is_active
  -- This function sets is_public = false for expired trips
  UPDATE trips
  SET is_public = false, updated_at = NOW()
  WHERE is_public = true
    AND end_date < NOW();
  
  GET DIAGNOSTICS archived_count = ROW_COUNT;
  RETURN archived_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE connections IS 'Connection requests between users with state machine (pending/accepted/declined/blocked)';
COMMENT ON TABLE activities IS 'Icebreaker activity suggestions for meeting up';
COMMENT ON TABLE user_activities IS 'User activity interests for matching';
COMMENT ON TABLE messages IS '1:1 chat messages between connected users';
COMMENT ON FUNCTION has_active_connection IS 'Check if two users have an accepted connection';
COMMENT ON FUNCTION are_users_blocked IS 'Check if either user has blocked the other (uses existing blocks table)';
