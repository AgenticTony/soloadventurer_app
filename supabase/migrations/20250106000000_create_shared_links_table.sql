-- Shared Links for Trip Sharing
-- Migration: Create table for shareable trip links with password protection
-- This migration supports public trip sharing with optional password protection

-- ============================================================================
-- TABLES
-- ============================================================================

-- shared_links table: Store shareable links for trips with optional passwords
CREATE TABLE IF NOT EXISTS shared_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  user_id UUID NOT NULL,

  -- Unique slug/identifier for the share link (e.g., "abc123xyz")
  slug VARCHAR(50) NOT NULL UNIQUE,

  -- Optional password protection (bcrypt hash)
  password_hash VARCHAR(255),

  -- Access control
  is_active BOOLEAN DEFAULT TRUE,
  expires_at TIMESTAMPTZ,  -- NULL means no expiration

  -- Access tracking
  view_count INTEGER DEFAULT 0,
  last_viewed_at TIMESTAMPTZ,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Constraints
  CONSTRAINT shared_links_slug_check CHECK (slug ~ '^[a-zA-Z0-9_-]+$')
  -- shared_links_user_check removed: Postgres forbids subqueries in CHECK constraints
  -- (SQLSTATE 0A000). The user_id↔trip ownership guarantee is enforced by the INSERT
  -- RLS policy below (EXISTS trip owned by auth.uid()). See issue #9.
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Fast lookup by slug (most common query)
CREATE INDEX IF NOT EXISTS idx_shared_links_slug ON shared_links(slug) WHERE is_active = TRUE;

-- Lookup by trip
CREATE INDEX IF NOT EXISTS idx_shared_links_trip_id ON shared_links(trip_id) WHERE is_active = TRUE;

-- Lookup by user
CREATE INDEX IF NOT EXISTS idx_shared_links_user_id ON shared_links(user_id) WHERE is_active = TRUE;

-- Cleanup expired links
CREATE INDEX IF NOT EXISTS idx_shared_links_expires_at ON shared_links(expires_at) WHERE expires_at IS NOT NULL;

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function to generate a unique random slug
CREATE OR REPLACE FUNCTION generate_unique_slug()
RETURNS VARCHAR(50) AS $$
DECLARE
  new_slug VARCHAR(50);
  max_attempts INTEGER := 10;
  attempts INTEGER := 0;
BEGIN
  WHILE attempts < max_attempts LOOP
    -- Generate random 10-character slug
    new_slug := encode(gen_random_bytes(8), 'base64');
    -- Remove non-alphanumeric characters and take first 10
    new_slug := regexp_replace(new_slug, '[^a-zA-Z0-9]', '', 'g');
    new_slug := substring(new_slug, 1, 10);

    -- Check if slug already exists
    IF NOT EXISTS (SELECT 1 FROM shared_links WHERE slug = new_slug) THEN
      RETURN new_slug;
    END IF;

    attempts := attempts + 1;
  END LOOP;

  RAISE EXCEPTION 'Failed to generate unique slug after % attempts', max_attempts;
END;
$$ LANGUAGE plpgsql;

-- Function to hash a password (bcrypt)
CREATE OR REPLACE FUNCTION hash_password(password TEXT)
RETURNS VARCHAR(255) AS $$
BEGIN
  IF password IS NULL OR password = '' THEN
    RETURN NULL;
  END IF;

  -- For now, use simple SHA-256. In production, use bcrypt via pgcrypto extension
  -- This is a placeholder - implement proper bcrypt hashing in application layer
  RETURN encode(digest(password, 'sha256'), 'hex');
END;
$$ LANGUAGE plpgsql;

-- Function to verify password
CREATE OR REPLACE FUNCTION verify_password(link_id UUID, password TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  stored_hash VARCHAR(255);
  computed_hash VARCHAR(255);
BEGIN
  IF password IS NULL OR password = '' THEN
    RETURN FALSE;
  END IF;

  -- Get stored password hash
  SELECT password_hash INTO stored_hash
  FROM shared_links
  WHERE id = link_id AND is_active = TRUE;

  -- If no password set, allow access
  IF stored_hash IS NULL THEN
    RETURN TRUE;
  END IF;

  -- Compute hash of provided password
  computed_hash := encode(digest(password, 'sha256'), 'hex');

  RETURN stored_hash = computed_hash;
END;
$$ LANGUAGE plpgsql;

-- Function to validate shared link access
CREATE OR REPLACE FUNCTION validate_shared_link_access(link_slug VARCHAR(50), password TEXT DEFAULT NULL)
RETURNS TABLE (
  trip_id UUID,
  is_valid BOOLEAN,
  requires_password BOOLEAN,
  is_expired BOOLEAN,
  error_message TEXT
) AS $$
DECLARE
  link_record shared_links%ROWTYPE;
BEGIN
  -- Get the shared link
  SELECT * INTO link_record
  FROM shared_links
  WHERE slug = link_slug AND is_active = TRUE;

  -- Check if link exists
  IF NOT FOUND THEN
    RETURN QUERY SELECT
      NULL::UUID,
      FALSE,
      FALSE,
      FALSE,
      'Shared link not found or has been deactivated'::TEXT;
    RETURN;
  END IF;

  -- Check if expired
  IF link_record.expires_at IS NOT NULL AND link_record.expires_at < NOW() THEN
    RETURN QUERY SELECT
      link_record.trip_id,
      FALSE,
      COALESCE(link_record.password_hash IS NOT NULL, FALSE),
      TRUE,
      'This shared link has expired'::TEXT;
    RETURN;
  END IF;

  -- Check password if provided
  IF link_record.password_hash IS NOT NULL THEN
    IF password IS NULL THEN
      RETURN QUERY SELECT
        link_record.trip_id,
        FALSE,
        TRUE,
        FALSE,
        'Password required'::TEXT;
      RETURN;
    END IF;

    IF NOT verify_password(link_record.id, password) THEN
      RETURN QUERY SELECT
        link_record.trip_id,
        FALSE,
        TRUE,
        FALSE,
        'Invalid password'::TEXT;
      RETURN;
    END IF;
  END IF;

  -- Link is valid
  RETURN QUERY SELECT
    link_record.trip_id,
    TRUE,
    COALESCE(link_record.password_hash IS NOT NULL, FALSE),
    FALSE,
    NULL::TEXT;
END;
$$ LANGUAGE plpgsql;

-- Function to increment view count
CREATE OR REPLACE FUNCTION increment_link_view_count(link_slug VARCHAR(50))
RETURNS VOID AS $$
BEGIN
  UPDATE shared_links
  SET
    view_count = view_count + 1,
    last_viewed_at = NOW()
  WHERE slug = link_slug;
END;
$$ LANGUAGE plpgsql;

-- Function to create a shared link
CREATE OR REPLACE FUNCTION create_shared_link(
  p_trip_id UUID,
  p_user_id UUID,
  p_password TEXT DEFAULT NULL,
  p_expires_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  new_slug VARCHAR(50);
  new_link_id UUID;
BEGIN
  -- Generate unique slug
  new_slug := generate_unique_slug();

  -- Hash password if provided
  -- Note: In production, hash password in application layer with bcrypt
  -- This is a simplified version for demonstration

  -- Create the shared link
  INSERT INTO shared_links (trip_id, user_id, slug, password_hash, expires_at)
  VALUES (p_trip_id, p_user_id, new_slug, hash_password(p_password), p_expires_at)
  RETURNING id INTO new_link_id;

  RETURN new_link_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Update updated_at timestamp
DROP TRIGGER IF EXISTS update_shared_links_updated_at ON shared_links;
CREATE TRIGGER update_shared_links_updated_at
  BEFORE UPDATE ON shared_links
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS
ALTER TABLE shared_links ENABLE ROW LEVEL SECURITY;

-- Users can read their own shared links
CREATE POLICY "Users can read own shared links"
  ON shared_links
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Users can insert shared links for their trips
CREATE POLICY "Users can insert shared links"
  ON shared_links
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM trips
      WHERE trips.id = trip_id AND trips.user_id = auth.uid()
    )
  );

-- Users can update their own shared links
CREATE POLICY "Users can update own shared links"
  ON shared_links
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own shared links
CREATE POLICY "Users can delete own shared links"
  ON shared_links
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Public can validate shared links by slug (for accessing shared trips)
CREATE POLICY "Public can validate shared links"
  ON shared_links
  FOR SELECT
  TO public
  USING (TRUE);

-- ============================================================================
-- VIEWS
-- ============================================================================

-- View: Shared links with trip information
CREATE OR REPLACE VIEW shared_links_with_trips AS
SELECT
  sl.id,
  sl.trip_id,
  sl.user_id,
  sl.slug,
  sl.password_hash IS NOT NULL AS has_password,
  sl.is_active,
  sl.expires_at,
  sl.view_count,
  sl.last_viewed_at,
  sl.created_at,
  sl.updated_at,
  t.name AS trip_name,
  t.description AS trip_description,
  t.cover_image_url AS trip_cover_image_url,
  t.start_date AS trip_start_date,
  t.end_date AS trip_end_date,
  t.destination AS trip_destination,
  t.is_public AS trip_is_public
FROM shared_links sl
JOIN trips t ON sl.trip_id = t.id;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE shared_links IS 'Shareable links for trips with optional password protection';
COMMENT ON COLUMN shared_links.slug IS 'Unique identifier for the share link (e.g., "abc123xyz")';
COMMENT ON COLUMN shared_links.password_hash IS 'Hashed password for protected links (NULL = public)';
COMMENT ON COLUMN shared_links.is_active IS 'Whether the link is currently active';
COMMENT ON COLUMN shared_links.expires_at IS 'Optional expiration date (NULL = no expiration)';
COMMENT ON COLUMN shared_links.view_count IS 'Number of times the link has been viewed';
COMMENT ON COLUMN shared_links.last_viewed_at IS 'Timestamp of the last view';
