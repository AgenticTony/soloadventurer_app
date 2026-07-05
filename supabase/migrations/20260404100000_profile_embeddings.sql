-- Migration: pgvector extension + profile embeddings for semantic traveler matching
-- Depends on: profiles table (earlier migrations), trips table with is_active column

-- =============================================================================
-- 1. Enable pgvector extension
-- =============================================================================
CREATE EXTENSION IF NOT EXISTS vector;

-- =============================================================================
-- 2. Add embedding columns to profiles table
-- =============================================================================
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS profile_embedding vector(384);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS embedding_updated_at TIMESTAMPTZ;

-- =============================================================================
-- 3. Create HNSW index for approximate nearest-neighbor cosine search
-- =============================================================================
CREATE INDEX IF NOT EXISTS idx_profiles_embedding
  ON profiles USING hnsw (profile_embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);

-- =============================================================================
-- 4. RLS policies: allow users to read profile embeddings for matching
-- =============================================================================
-- Allow authenticated users to read embedding data for match queries
CREATE POLICY "profiles_embedding_select_authenticated" ON profiles
  FOR SELECT
  TO authenticated
  USING (true);

-- =============================================================================
-- 5. RPC: find_semantic_matches
-- =============================================================================
-- Finds travelers whose profile embedding is semantically similar to the
-- query user, filtered by active trips and a cosine-similarity threshold.
-- Returns: user_id, display_name, avatar_url, semantic_score,
--          destination_name, start_date, end_date
CREATE OR REPLACE FUNCTION find_semantic_matches(
  p_query_user_id UUID,
  p_match_threshold FLOAT DEFAULT 0.6,
  p_max_results   INT   DEFAULT 20
)
RETURNS TABLE (
  user_id         UUID,
  display_name    TEXT,
  avatar_url      TEXT,
  semantic_score  FLOAT,
  destination_name TEXT,
  start_date      DATE,
  end_date        DATE
)
LANGUAGE sql STABLE
AS $$
  SELECT
    p.id            AS user_id,
    p.display_name,
    p.avatar_url,
    (1 - (p.profile_embedding <=> q.profile_embedding)) AS semantic_score,
    t.destination_name,
    t.start_date,
    t.end_date
  FROM profiles p
  CROSS JOIN LATERAL (
    SELECT profile_embedding FROM profiles WHERE id = p_query_user_id
  ) q
  JOIN trips t ON t.user_id = p.id AND t.is_active = true
  WHERE p.id != p_query_user_id
    AND p.profile_embedding IS NOT NULL
    AND q.profile_embedding IS NOT NULL
    AND (1 - (p.profile_embedding <=> q.profile_embedding)) >= p_match_threshold
  ORDER BY (p.profile_embedding <=> q.profile_embedding) ASC
  LIMIT p_max_results;
$$;

-- =============================================================================
-- 6. RPC: get_profile_embedding
-- =============================================================================
-- Returns the stored profile embedding for a given user.
CREATE OR REPLACE FUNCTION get_profile_embedding(p_user_id UUID)
RETURNS vector
LANGUAGE sql STABLE
AS $$
  SELECT profile_embedding FROM profiles WHERE id = p_user_id;
$$;
