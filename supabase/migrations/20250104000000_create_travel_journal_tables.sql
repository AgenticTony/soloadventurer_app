-- Travel Journal with Media - Database Schema
-- Migration: Create tables for journal_entries, media_items, trips, and tags
-- This migration supports offline-first architecture with sync capabilities

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";  -- For location/geospatial queries

-- ============================================================================
-- TABLES
-- ============================================================================

-- trips table: Organizes journal entries into trips
CREATE TABLE IF NOT EXISTS trips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  cover_image_url VARCHAR(2048),
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ,
  destination VARCHAR(255),
  is_public BOOLEAN DEFAULT FALSE,
  sync_status VARCHAR(20) DEFAULT 'synced' CHECK (sync_status IN ('synced', 'pending', 'conflict', 'offline_only')),
  last_synced_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- journal_entries table: Main journal entries with rich text content
CREATE TABLE IF NOT EXISTS journal_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  trip_id UUID REFERENCES trips(id) ON DELETE SET NULL,
  title VARCHAR(500) NOT NULL,
  content TEXT NOT NULL,  -- Rich text content (HTML/Markdown)
  mood VARCHAR(50),  -- e.g., "happy", "adventurous", "tired"
  location_name VARCHAR(255),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  location_accuracy DECIMAL(10, 2),  -- Accuracy in meters
  entry_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  weather_data JSONB,  -- Store weather information
  is_favorite BOOLEAN DEFAULT FALSE,
  sync_status VARCHAR(20) DEFAULT 'synced' CHECK (sync_status IN ('synced', 'pending', 'conflict', 'offline_only')),
  last_synced_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- media_items table: Photos and videos attached to journal entries
CREATE TABLE IF NOT EXISTS media_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  journal_entry_id UUID NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
  media_type VARCHAR(20) NOT NULL CHECK (media_type IN ('photo', 'video')),
  storage_path VARCHAR(2048) NOT NULL,  -- Path in Supabase Storage
  original_filename VARCHAR(255),
  file_size BIGINT,  -- Size in bytes
  mime_type VARCHAR(100),
  width INTEGER,
  height INTEGER,
  duration INTEGER,  -- For videos (in seconds)
  thumbnail_path VARCHAR(2048),  -- Path to thumbnail image
  caption TEXT,
  upload_status VARCHAR(20) DEFAULT 'pending' CHECK (upload_status IN ('pending', 'uploading', 'completed', 'failed')),
  upload_progress INTEGER DEFAULT 0 CHECK (upload_progress >= 0 AND upload_progress <= 100),
  exif_data JSONB,  -- EXIF metadata from photos
  is_cover BOOLEAN DEFAULT FALSE,  -- Whether this is the cover image for entry
  order_index INTEGER DEFAULT 0,  -- For ordering media in entry
  sync_status VARCHAR(20) DEFAULT 'synced' CHECK (sync_status IN ('synced', 'pending', 'conflict', 'offline_only')),
  last_synced_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- tags table: Custom tags for categorizing entries
CREATE TABLE IF NOT EXISTS tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  name VARCHAR(100) NOT NULL,
  color VARCHAR(7),  -- Hex color code for display
  icon VARCHAR(50),  -- Icon name/emoji
  usage_count INTEGER DEFAULT 0,  -- Track how many times tag is used
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, name)
);

-- journal_tags table: Many-to-many relationship between entries and tags
CREATE TABLE IF NOT EXISTS journal_tags (
  journal_entry_id UUID NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (journal_entry_id, tag_id)
);

-- offline_changes table: Track changes made while offline for sync
CREATE TABLE IF NOT EXISTS offline_changes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  table_name VARCHAR(100) NOT NULL,
  record_id UUID NOT NULL,
  operation VARCHAR(20) NOT NULL CHECK (operation IN ('insert', 'update', 'delete')),
  data JSONB NOT NULL,  -- The changed data
  created_at TIMESTAMPTZ DEFAULT NOW(),
  synced_at TIMESTAMPTZ
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- trips indexes
CREATE INDEX IF NOT EXISTS idx_trips_user_id ON trips(user_id);
CREATE INDEX IF NOT EXISTS idx_trips_dates ON trips(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_trips_sync_status ON trips(sync_status);
CREATE INDEX IF NOT EXISTS idx_trips_created_at ON trips(created_at DESC);

-- journal_entries indexes
CREATE INDEX IF NOT EXISTS idx_journal_entries_user_id ON journal_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_journal_entries_trip_id ON journal_entries(trip_id);
CREATE INDEX IF NOT EXISTS idx_journal_entries_entry_date ON journal_entries(entry_date DESC);
CREATE INDEX IF NOT EXISTS idx_journal_entries_location ON journal_entries(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_journal_entries_mood ON journal_entries(mood);
CREATE INDEX IF NOT EXISTS idx_journal_entries_is_favorite ON journal_entries(is_favorite);
CREATE INDEX IF NOT EXISTS idx_journal_entries_sync_status ON journal_entries(sync_status);
CREATE INDEX IF NOT EXISTS idx_journal_entries_created_at ON journal_entries(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_journal_entries_full_text ON journal_entries USING gin(to_tsvector('english', title || ' ' || content));

-- media_items indexes
CREATE INDEX IF NOT EXISTS idx_media_items_user_id ON media_items(user_id);
CREATE INDEX IF NOT EXISTS idx_media_items_journal_entry_id ON media_items(journal_entry_id);
CREATE INDEX IF NOT EXISTS idx_media_items_media_type ON media_items(media_type);
CREATE INDEX IF NOT EXISTS idx_media_items_upload_status ON media_items(upload_status);
CREATE INDEX IF NOT EXISTS idx_media_items_sync_status ON media_items(sync_status);
CREATE INDEX IF NOT EXISTS idx_media_items_created_at ON media_items(created_at DESC);

-- tags indexes
CREATE INDEX IF NOT EXISTS idx_tags_user_id ON tags(user_id);
CREATE INDEX IF NOT EXISTS idx_tags_usage_count ON tags(usage_count DESC);
CREATE INDEX IF NOT EXISTS idx_tags_name ON tags USING gin(to_tsvector('english', name));

-- journal_tags indexes
CREATE INDEX IF NOT EXISTS idx_journal_tags_journal_entry_id ON journal_tags(journal_entry_id);
CREATE INDEX IF NOT EXISTS idx_journal_tags_tag_id ON journal_tags(tag_id);

-- offline_changes indexes
CREATE INDEX IF NOT EXISTS idx_offline_changes_user_id ON offline_changes(user_id);
CREATE INDEX IF NOT EXISTS idx_offline_changes_table_name ON offline_changes(table_name);
CREATE INDEX IF NOT EXISTS idx_offline_changes_created_at ON offline_changes(created_at ASC);
CREATE INDEX IF NOT EXISTS idx_offline_changes_synced_at ON offline_changes(synced_at) WHERE synced_at IS NULL;

-- ============================================================================
-- FUNCTIONS AND TRIGGERS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
DROP TRIGGER IF EXISTS update_trips_updated_at ON trips;
CREATE TRIGGER update_trips_updated_at
  BEFORE UPDATE ON trips
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_journal_entries_updated_at ON journal_entries;
CREATE TRIGGER update_journal_entries_updated_at
  BEFORE UPDATE ON journal_entries
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_media_items_updated_at ON media_items;
CREATE TRIGGER update_media_items_updated_at
  BEFORE UPDATE ON media_items
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to update tag usage count
CREATE OR REPLACE FUNCTION update_tag_usage_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE tags SET usage_count = usage_count + 1 WHERE id = NEW.tag_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE tags SET usage_count = usage_count - 1 WHERE id = OLD.tag_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Triggers for tag usage
DROP TRIGGER IF EXISTS update_tag_usage_on_journal_tags ON journal_tags;
CREATE TRIGGER update_tag_usage_on_journal_tags
  AFTER INSERT OR DELETE ON journal_tags
  FOR EACH ROW
  EXECUTE FUNCTION update_tag_usage_count();

-- Function to search journal entries by full text
CREATE OR REPLACE FUNCTION search_journal_entries(
  p_user_id UUID,
  p_search_query TEXT,
  p_trip_id UUID DEFAULT NULL,
  p_tag_ids UUID[] DEFAULT NULL,
  p_mood VARCHAR(50) DEFAULT NULL,
  p_start_date TIMESTAMPTZ DEFAULT NULL,
  p_end_date TIMESTAMPTZ DEFAULT NULL,
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  title VARCHAR,
  content TEXT,
  entry_date TIMESTAMPTZ,
  location_name VARCHAR,
  mood VARCHAR,
  trip_id UUID,
  trip_name VARCHAR,
  media_count BIGINT,
  rank REAL
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    je.id,
    je.title,
    je.content,
    je.entry_date,
    je.location_name,
    je.mood,
    je.trip_id,
    t.name AS trip_name,
    COUNT(mi.id) AS media_count,
    ts_rank(je.text_search, plainto_tsquery('english', p_search_query)) AS rank
  FROM journal_entries je
  LEFT JOIN trips t ON je.trip_id = t.id
  LEFT JOIN media_items mi ON je.id = mi.journal_entry_id
  LEFT JOIN journal_tags jt ON je.id = jt.journal_entry_id
  WHERE
    je.user_id = p_user_id
    AND (p_search_query IS NULL OR je.text_search @@ plainto_tsquery('english', p_search_query))
    AND (p_trip_id IS NULL OR je.trip_id = p_trip_id)
    AND (p_tag_ids IS NULL OR jt.tag_id = ANY(p_tag_ids))
    AND (p_mood IS NULL OR je.mood = p_mood)
    AND (p_start_date IS NULL OR je.entry_date >= p_start_date)
    AND (p_end_date IS NULL OR je.entry_date <= p_end_date)
  GROUP BY je.id, t.name
  ORDER BY
    CASE WHEN p_search_query IS NOT NULL THEN rank ELSE 0 END DESC,
    je.entry_date DESC
  LIMIT p_limit OFFSET p_offset;
END;
$$;

-- Add text search column to journal_entries
ALTER TABLE journal_entries ADD COLUMN IF NOT EXISTS text_search tsvector
  GENERATED ALWAYS AS (to_tsvector('english', coalesce(title, '') || ' ' || coalesce(content, ''))) STORED;

-- Create index for text search
CREATE INDEX IF NOT EXISTS idx_journal_entries_text_search ON journal_entries USING gin(text_search);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE media_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE offline_changes ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- RLS POLICIES: TRIPS
-- ============================================================================

-- Users can read their own trips
CREATE POLICY "Users can read own trips"
  ON trips
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Users can insert their own trips
CREATE POLICY "Users can insert own trips"
  ON trips
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own trips
CREATE POLICY "Users can update own trips"
  ON trips
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own trips
CREATE POLICY "Users can delete own trips"
  ON trips
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Public can read public trips
CREATE POLICY "Public can read public trips"
  ON trips
  FOR SELECT
  TO public
  USING (is_public = true);

-- ============================================================================
-- RLS POLICIES: JOURNAL ENTRIES
-- ============================================================================

-- Users can read their own entries
CREATE POLICY "Users can read own journal entries"
  ON journal_entries
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Users can insert their own entries
CREATE POLICY "Users can insert own journal entries"
  ON journal_entries
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own entries
CREATE POLICY "Users can update own journal entries"
  ON journal_entries
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own entries
CREATE POLICY "Users can delete own journal entries"
  ON journal_entries
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- ============================================================================
-- RLS POLICIES: MEDIA ITEMS
-- ============================================================================

-- Users can read their own media
CREATE POLICY "Users can read own media items"
  ON media_items
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Users can insert their own media
CREATE POLICY "Users can insert own media items"
  ON media_items
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own media
CREATE POLICY "Users can update own media items"
  ON media_items
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own media
CREATE POLICY "Users can delete own media items"
  ON media_items
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- ============================================================================
-- RLS POLICIES: TAGS
-- ============================================================================

-- Users can read their own tags
CREATE POLICY "Users can read own tags"
  ON tags
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Users can insert their own tags
CREATE POLICY "Users can insert own tags"
  ON tags
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own tags
CREATE POLICY "Users can update own tags"
  ON tags
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own tags
CREATE POLICY "Users can delete own tags"
  ON tags
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- ============================================================================
-- RLS POLICIES: JOURNAL TAGS
-- ============================================================================

-- Users can read tags for their entries
CREATE POLICY "Users can read own journal tags"
  ON journal_tags
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM journal_entries je
      WHERE je.id = journal_tags.journal_entry_id
      AND je.user_id = auth.uid()
    )
  );

-- Users can insert tags for their entries
CREATE POLICY "Users can insert own journal tags"
  ON journal_tags
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM journal_entries je
      WHERE je.id = journal_tags.journal_entry_id
      AND je.user_id = auth.uid()
    )
    AND EXISTS (
      SELECT 1 FROM tags t
      WHERE t.id = journal_tags.tag_id
      AND t.user_id = auth.uid()
    )
  );

-- Users can delete tags for their entries
CREATE POLICY "Users can delete own journal tags"
  ON journal_tags
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM journal_entries je
      WHERE je.id = journal_tags.journal_entry_id
      AND je.user_id = auth.uid()
    )
  );

-- ============================================================================
-- RLS POLICIES: OFFLINE CHANGES
-- ============================================================================

-- Users can read their own offline changes
CREATE POLICY "Users can read own offline changes"
  ON offline_changes
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Users can insert their own offline changes
CREATE POLICY "Users can insert own offline changes"
  ON offline_changes
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own offline changes
CREATE POLICY "Users can update own offline changes"
  ON offline_changes
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own offline changes
CREATE POLICY "Users can delete own offline changes"
  ON offline_changes
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- ============================================================================
-- GRANTS
-- ============================================================================

-- Grant necessary permissions to service_role for all operations
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO service_role;

-- Grant usage on sequences for auto-incrementing IDs
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO service_role;

-- ============================================================================
-- HELPER VIEWS
-- ============================================================================

-- View: Trip summaries with entry and media counts
CREATE OR REPLACE VIEW trip_summaries AS
SELECT
  t.id,
  t.user_id,
  t.name,
  t.description,
  t.cover_image_url,
  t.start_date,
  t.end_date,
  t.destination,
  t.is_public,
  COUNT(DISTINCT je.id) AS entry_count,
  COUNT(DISTINCT mi.id) AS media_count,
  MIN(je.entry_date) AS first_entry_date,
  MAX(je.entry_date) AS last_entry_date,
  t.created_at,
  t.updated_at
FROM trips t
LEFT JOIN journal_entries je ON t.id = je.trip_id
LEFT JOIN media_items mi ON je.id = mi.journal_entry_id
GROUP BY t.id;

-- View: Journal entries with media preview
CREATE OR REPLACE VIEW journal_entries_with_media AS
SELECT
  je.*,
  t.name AS trip_name,
  t.start_date AS trip_start_date,
  t.end_date AS trip_end_date,
  COUNT(mi.id) AS media_count,
  ARRAY_AGG(
    CASE WHEN mi.media_type = 'photo' THEN mi.storage_path END
    ORDER BY mi.order_index, mi.created_at
  ) FILTER (WHERE mi.media_type = 'photo') AS photo_paths,
  ARRAY_AGG(
    CASE WHEN mi.media_type = 'video' THEN mi.storage_path END
    ORDER BY mi.order_index, mi.created_at
  ) FILTER (WHERE mi.media_type = 'video') AS video_paths,
  ARRAY_AGG(
    tag.name
  ) AS tag_names
FROM journal_entries je
LEFT JOIN trips t ON je.trip_id = t.id
LEFT JOIN media_items mi ON je.id = mi.journal_entry_id
LEFT JOIN journal_tags jt ON je.id = jt.journal_entry_id
LEFT JOIN tags tag ON jt.tag_id = tag.id
GROUP BY je.id, t.name, t.start_date, t.end_date;

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE trips IS 'Organizes journal entries into trips';
COMMENT ON TABLE journal_entries IS 'Main journal entries with rich text content and location data';
COMMENT ON TABLE media_items IS 'Photos and videos attached to journal entries';
COMMENT ON TABLE tags IS 'Custom tags for categorizing journal entries';
COMMENT ON TABLE journal_tags IS 'Many-to-many relationship between journal entries and tags';
COMMENT ON TABLE offline_changes IS 'Tracks offline changes for sync';

COMMENT ON COLUMN journal_entries.sync_status IS 'Tracks sync status: synced, pending, conflict, or offline_only';
COMMENT ON COLUMN media_items.upload_status IS 'Tracks media upload progress: pending, uploading, completed, or failed';
COMMENT ON COLUMN offline_changes.operation IS 'Database operation type: insert, update, or delete';
