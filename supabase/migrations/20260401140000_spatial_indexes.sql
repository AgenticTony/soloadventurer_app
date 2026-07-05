-- SoloAdventurer Matching Feature - PostGIS Setup & Spatial Indexes
-- Migration: 20260401_spatial_indexes.sql
-- Created: 2026-04-01
-- Purpose: Enable PostGIS, create spatial indexes, and matching RPC functions
-- FIXED: Updated to use existing profiles table and trips.is_public instead of is_active

-- ============================================================================
-- 1. ENABLE POSTGIS EXTENSION (if not already enabled)
-- ============================================================================

-- PostGIS should already be enabled from migration 004, but safe to re-run
CREATE EXTENSION IF NOT EXISTS postgis;

-- Verify PostGIS is working
DO $$
DECLARE
  postgis_version TEXT;
BEGIN
  SELECT PostGIS_Version() INTO postgis_version;
  RAISE NOTICE 'PostGIS version: %', postgis_version;
EXCEPTION WHEN OTHERS THEN
  RAISE WARNING 'PostGIS extension may not be available. Contact Supabase support if needed.';
END $$;

-- ============================================================================
-- 2. SPATIAL INDEXES FOR TRIPS
-- ============================================================================

-- Add is_active column to trips if it doesn't exist (for backward compatibility)
ALTER TABLE trips ADD COLUMN IF NOT EXISTS is_active BOOLEAN;

-- Backfill is_active based on is_public and end_date
UPDATE trips 
SET is_active = (is_public = true AND (end_date IS NULL OR end_date > NOW()))
WHERE is_active IS NULL;

-- Set default for future inserts
ALTER TABLE trips ALTER COLUMN is_active SET DEFAULT true;

-- GiST spatial index for location-based queries (CRITICAL for performance)
CREATE INDEX IF NOT EXISTS idx_trips_location_gist ON trips USING GIST(location);

-- Index for active trips with location
CREATE INDEX IF NOT EXISTS idx_trips_active_location ON trips USING GIST(location) 
  WHERE (is_active = true OR is_public = true);

-- Index for trips within specific date range (for matching)
CREATE INDEX IF NOT EXISTS idx_trips_active_dates ON trips(start_date, end_date) 
  WHERE (is_active = true OR is_public = true);

-- ============================================================================
-- 3. SPATIAL INDEXES FOR ACTIVITIES
-- ============================================================================

-- Index for location-specific activities (if any)
CREATE INDEX IF NOT EXISTS idx_activities_location_restriction ON activities USING GIST(location_restriction)
  WHERE is_location_specific = true AND location_restriction IS NOT NULL;

-- ============================================================================
-- 4. SPATIAL INDEXES FOR WOMEN-ONLY SPACES
-- ============================================================================

-- Index for location-based women-only spaces
CREATE INDEX IF NOT EXISTS idx_women_only_spaces_location ON women_only_spaces USING GIST(location)
  WHERE location IS NOT NULL AND is_active = true;

-- ============================================================================
-- 5. MATCHING RPC FUNCTIONS
-- ============================================================================

-- Function: Find potential matches for a user based on trip overlap
-- Returns users with overlapping trips within a configurable radius
CREATE OR REPLACE FUNCTION find_potential_matches(
  p_user_id UUID,
  p_radius_meters FLOAT DEFAULT 50000,  -- 50km default
  p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
  user_id UUID,
  first_name TEXT,
  age_range TEXT,
  home_country TEXT,
  gender TEXT,
  gender_verified BOOLEAN,
  trip_id UUID,
  destination_name TEXT,
  trip_start_date TIMESTAMPTZ,
  trip_end_date TIMESTAMPTZ,
  overlap_start_date DATE,
  overlap_end_date DATE,
  overlap_days INTEGER,
  distance_meters FLOAT,
  matching_activities TEXT[]
) AS $$
DECLARE
  v_women_only_enabled BOOLEAN;
BEGIN
  -- Check if user has women-only mode enabled
  SELECT women_only_mode_enabled INTO v_women_only_enabled
  FROM profiles WHERE id = p_user_id;
  
  RETURN QUERY
  SELECT
    p.id AS user_id,
    p.display_name AS first_name,
    p.age_range,
    p.home_country,
    p.gender,
    p.gender_verified,
    t.id AS trip_id,
    t.destination_name,
    t.start_date AS trip_start_date,
    t.end_date AS trip_end_date,
    GREATEST(mt.start_date::DATE, t.start_date::DATE) AS overlap_start_date,
    LEAST(mt.end_date::DATE, t.end_date::DATE) AS overlap_end_date,
    (LEAST(mt.end_date::DATE, t.end_date::DATE) - GREATEST(mt.start_date::DATE, t.start_date::DATE))::INTEGER AS overlap_days,
    ST_Distance(mt.location::geometry, t.location::geometry) AS distance_meters,
    ARRAY_AGG(DISTINCT a.name) FILTER (WHERE a.name IS NOT NULL) AS matching_activities
  FROM trips t
  JOIN profiles p ON t.user_id = p.id
  CROSS JOIN LATERAL (
    SELECT * FROM trips
    WHERE user_id = p_user_id
      AND (is_active = true OR is_public = true)
      AND start_date <= t.end_date
      AND end_date >= t.start_date
      AND ST_DWithin(location, t.location, p_radius_meters)
    LIMIT 1
  ) mt
  LEFT JOIN user_activities ua ON ua.user_id = p.id
  LEFT JOIN activities a ON a.id = ua.activity_id AND a.is_active = true
  WHERE t.user_id != p_user_id
    AND (t.is_active = true OR t.is_public = true)
    -- Visibility filter
    AND (
      t.visibility = 'everyone'
      OR (t.visibility = 'women-only' AND v_women_only_enabled = true)
    )
    -- Women-only mode filter for requesting user
    AND (
      v_women_only_enabled = false
      OR (p.gender = 'female' AND p.gender_verified = true)
    )
    -- Exclude blocked users
    AND NOT are_users_blocked(p_user_id, t.user_id)
    -- Exclude existing connections
    AND NOT has_active_connection(p_user_id, t.user_id)
  GROUP BY
    p.id, p.display_name, p.age_range, p.home_country, p.gender, p.gender_verified,
    t.id, t.destination_name, t.start_date, t.end_date,
    mt.start_date, mt.end_date, mt.location, t.location
  ORDER BY
    overlap_days DESC,
    distance_meters ASC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- Function: Find trips near a specific location
CREATE OR REPLACE FUNCTION find_trips_near_location(
  p_location GEOGRAPHY(POINT, 4326),
  p_radius_meters FLOAT DEFAULT 50000,
  p_start_date DATE DEFAULT NULL,
  p_end_date DATE DEFAULT NULL,
  p_limit INTEGER DEFAULT 100
)
RETURNS TABLE (
  trip_id UUID,
  user_id UUID,
  destination_name TEXT,
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  distance_meters FLOAT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    t.id AS trip_id,
    t.user_id,
    t.destination_name,
    t.start_date,
    t.end_date,
    ST_Distance(p_location::geometry, t.location::geometry) AS distance_meters
  FROM trips t
  WHERE (t.is_active = true OR t.is_public = true)
    AND ST_DWithin(t.location, p_location, p_radius_meters)
    AND (p_start_date IS NULL OR t.end_date >= p_start_date)
    AND (p_end_date IS NULL OR t.start_date <= p_end_date)
  ORDER BY distance_meters ASC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- Function: Find women-only spaces near location
CREATE OR REPLACE FUNCTION find_women_only_spaces_nearby(
  p_user_id UUID,
  p_location GEOGRAPHY(POINT, 4326),
  p_radius_meters FLOAT DEFAULT 25000,  -- 25km default
  p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
  space_id UUID,
  name TEXT,
  description TEXT,
  location_name TEXT,
  member_count BIGINT,
  distance_meters FLOAT,
  is_member BOOLEAN
) AS $$
BEGIN
  -- Verify user can access women-only spaces
  IF NOT can_access_women_only_spaces(p_user_id) THEN
    RAISE EXCEPTION 'User not authorized to access women-only spaces';
  END IF;
  
  RETURN QUERY
  SELECT
    wos.id AS space_id,
    wos.name,
    wos.description,
    wos.location_name,
    COUNT(wosm.id) AS member_count,
    ST_Distance(p_location::geometry, wos.location::geometry) AS distance_meters,
    EXISTS (
      SELECT 1 FROM women_only_space_members wosm2
      WHERE wosm2.space_id = wos.id 
        AND wosm2.user_id = p_user_id 
        AND wosm2.status = 'approved'
    ) AS is_member
  FROM women_only_spaces wos
  LEFT JOIN women_only_space_members wosm ON wosm.space_id = wos.id AND wosm.status = 'approved'
  WHERE wos.is_active = true
    AND wos.is_public = true
    AND (wos.location IS NULL OR ST_DWithin(wos.location, p_location, p_radius_meters))
  GROUP BY wos.id, wos.name, wos.description, wos.location_name, wos.location
  ORDER BY distance_meters ASC NULLS LAST
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================================================
-- 6. CONNECTION CREATION RPC
-- ============================================================================

-- Function: Create connection from match
CREATE OR REPLACE FUNCTION create_connection_from_match(
  p_requester_id UUID,
  p_recipient_id UUID,
  p_activity_id UUID DEFAULT NULL,
  p_initial_message TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_connection_id UUID;
  v_requester_trip RECORD;
  v_recipient_trip RECORD;
  v_overlap_start DATE;
  v_overlap_end DATE;
  v_overlap_days INTEGER;
BEGIN
  -- Check if already connected
  IF has_active_connection(p_requester_id, p_recipient_id) THEN
    RAISE EXCEPTION 'Users already have an active connection';
  END IF;
  
  -- Check if blocked
  IF are_users_blocked(p_requester_id, p_recipient_id) THEN
    RAISE EXCEPTION 'Cannot create connection with blocked user';
  END IF;
  
  -- Find overlapping trips
  SELECT t.* INTO v_requester_trip
  FROM trips t
  WHERE t.user_id = p_requester_id
    AND (t.is_active = true OR t.is_public = true)
  LIMIT 1;
  
  SELECT t.* INTO v_recipient_trip
  FROM trips t
  WHERE t.user_id = p_recipient_id
    AND (t.is_active = true OR t.is_public = true)
    AND t.start_date <= v_requester_trip.end_date
    AND t.end_date >= v_requester_trip.start_date
  LIMIT 1;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'No overlapping trips found between users';
  END IF;
  
  -- Calculate overlap
  v_overlap_start := GREATEST(v_requester_trip.start_date::DATE, v_recipient_trip.start_date::DATE);
  v_overlap_end := LEAST(v_requester_trip.end_date::DATE, v_recipient_trip.end_date::DATE);
  v_overlap_days := (v_overlap_end - v_overlap_start)::INTEGER;
  
  -- Create connection
  INSERT INTO connections (
    requester_id,
    recipient_id,
    status,
    requester_trip_id,
    recipient_trip_id,
    activity_id,
    overlap_start_date,
    overlap_end_date,
    overlap_days
  ) VALUES (
    p_requester_id,
    p_recipient_id,
    'pending',
    v_requester_trip.id,
    v_recipient_trip.id,
    p_activity_id,
    v_overlap_start,
    v_overlap_end,
    v_overlap_days
  )
  RETURNING id INTO v_connection_id;
  
  -- Send initial message if provided
  IF p_initial_message IS NOT NULL AND char_length(p_initial_message) > 0 THEN
    INSERT INTO messages (
      connection_id,
      sender_id,
      receiver_id,
      content,
      activity_id
    ) VALUES (
      v_connection_id,
      p_requester_id,
      p_recipient_id,
      p_initial_message,
      p_activity_id
    );
  END IF;
  
  RETURN v_connection_id;
END;
$$ LANGUAGE plpgsql;

-- Function: Accept connection request
CREATE OR REPLACE FUNCTION accept_connection_request(
  p_connection_id UUID,
  p_accepting_user_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
  v_connection RECORD;
BEGIN
  SELECT * INTO v_connection FROM connections WHERE id = p_connection_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Connection not found';
  END IF;
  
  IF v_connection.recipient_id != p_accepting_user_id THEN
    RAISE EXCEPTION 'Only the recipient can accept a connection request';
  END IF;
  
  IF v_connection.status != 'pending' THEN
    RAISE EXCEPTION 'Connection is not in pending state';
  END IF;
  
  UPDATE connections
  SET status = 'accepted',
      responded_at = NOW()
  WHERE id = p_connection_id;
  
  RETURN true;
END;
$$ LANGUAGE plpgsql;

-- Function: Decline connection request
CREATE OR REPLACE FUNCTION decline_connection_request(
  p_connection_id UUID,
  p_declining_user_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
  v_connection RECORD;
BEGIN
  SELECT * INTO v_connection FROM connections WHERE id = p_connection_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Connection not found';
  END IF;
  
  IF v_connection.recipient_id != p_declining_user_id THEN
    RAISE EXCEPTION 'Only the recipient can decline a connection request';
  END IF;
  
  UPDATE connections
  SET status = 'declined',
      responded_at = NOW()
  WHERE id = p_connection_id;
  
  RETURN true;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 7. ANALYTICS/STATS RPC FUNCTIONS
-- ============================================================================

-- Function: Get match statistics for a user
CREATE OR REPLACE FUNCTION get_user_match_stats(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_result JSONB;
BEGIN
  SELECT jsonb_build_object(
    'total_connections', (SELECT COUNT(*) FROM connections WHERE requester_id = p_user_id OR recipient_id = p_user_id),
    'accepted_connections', (SELECT COUNT(*) FROM connections WHERE status = 'accepted' AND (requester_id = p_user_id OR recipient_id = p_user_id)),
    'pending_requests', (SELECT COUNT(*) FROM connections WHERE status = 'pending' AND recipient_id = p_user_id),
    'active_trips', (SELECT COUNT(*) FROM trips WHERE user_id = p_user_id AND (is_active = true OR is_public = true)),
    'women_only_mode_enabled', (SELECT women_only_mode_enabled FROM profiles WHERE id = p_user_id)
  ) INTO v_result;
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================================================
-- 8. SPATIAL HELPER FUNCTIONS
-- ============================================================================

-- Function: Create point from lat/lng
CREATE OR REPLACE FUNCTION make_point(p_lng FLOAT, p_lat FLOAT)
RETURNS GEOGRAPHY(POINT, 4326) AS $$
BEGIN
  RETURN ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function: Get distance between two points in meters
CREATE OR REPLACE FUNCTION distance_between_points(
  p_point1 GEOGRAPHY(POINT, 4326),
  p_point2 GEOGRAPHY(POINT, 4326)
)
RETURNS FLOAT AS $$
BEGIN
  RETURN ST_Distance(p_point1, p_point2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- 9. INDEXES FOR RPC FUNCTIONS
-- ============================================================================

-- Additional indexes to support common query patterns
CREATE INDEX IF NOT EXISTS idx_connections_status_recipient ON connections(status, recipient_id);
CREATE INDEX IF NOT EXISTS idx_connections_status_requester ON connections(status, requester_id);

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON FUNCTION find_potential_matches IS 'Find users with overlapping trips within radius, respecting women-only mode and blocks';
COMMENT ON FUNCTION find_trips_near_location IS 'Find all trips near a geographic point within radius and date range';
COMMENT ON FUNCTION find_women_only_spaces_nearby IS 'Find public women-only spaces near a location (requires verified female)';
COMMENT ON FUNCTION create_connection_from_match IS 'Create a connection request between users with optional initial message';
COMMENT ON FUNCTION make_point IS 'Helper to create PostGIS point from longitude/latitude';
