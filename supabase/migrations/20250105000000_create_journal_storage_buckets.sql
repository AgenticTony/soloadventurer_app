-- Travel Journal with Media - Storage Buckets
-- Migration: Create storage buckets for photos, videos, and thumbnails
-- This migration sets up secure storage with RLS policies for media management

-- ============================================================================
-- STORAGE BUCKETS
-- ============================================================================

-- Insert storage buckets
-- Note: These INSERT statements create the buckets in Supabase Storage
-- Bucket IDs must be unique and follow DNS naming conventions

-- Photos bucket for high-resolution images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'journal-photos',
  'journal-photos',
  false,  -- Private bucket - access controlled via RLS
  10485760,  -- 10MB limit per file
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/heic', 'image/heif']
)
ON CONFLICT (id) DO NOTHING;

-- Videos bucket for video uploads
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'journal-videos',
  'journal-videos',
  false,  -- Private bucket - access controlled via RLS
  104857600,  -- 100MB limit per file
  ARRAY['video/mp4', 'video/quicktime', 'video/x-msvideo', 'video/webm']
)
ON CONFLICT (id) DO NOTHING;

-- Thumbnails bucket for optimized thumbnails and previews
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'journal-thumbnails',
  'journal-thumbnails',
  false,  -- Private bucket - access controlled via RLS
  524288,  -- 512KB limit per file
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STORAGE FOLDERS
-- ============================================================================

-- Create folder structure for organized storage
-- Each user will have their own folder: /user_id/
-- This helps with:
-- 1. Logical separation of user data
-- 2. Easier cleanup and migration
-- 3. Better performance for listing operations

-- Note: Folders are created implicitly when files are uploaded
-- No explicit folder creation needed in Supabase Storage

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES FOR STORAGE
-- ============================================================================

-- Run storage.objects DDL as the admin role (owner is supabase_storage_admin)
-- NOTE: storage.objects DDL skipped — the table is owned by supabase_storage_admin and the
-- migration user cannot SET ROLE to any admin role in the CI/local stack. RLS policies on
-- storage.objects are managed by Supabase's base schema; these per-bucket policies are applied
-- via the Supabase dashboard in production. See issue #9 for the full CI repair context.

-- SET ROLE supabase_admin;
-- 
-- -- Enable RLS on storage objects
-- ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
-- 
-- -- ============================================================================
-- -- RLS POLICIES: JOURNAL-PHOTOS BUCKET
-- -- ============================================================================
-- 
-- -- Users can SELECT (read) their own photos
-- CREATE POLICY "Users can read own journal photos"
--   ON storage.objects
--   FOR SELECT
--   TO authenticated
--   USING (
--     bucket_id = 'journal-photos'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   );
-- 
-- -- Users can INSERT (upload) their own photos
-- CREATE POLICY "Users can upload own journal photos"
--   ON storage.objects
--   FOR INSERT
--   TO authenticated
--   WITH CHECK (
--     bucket_id = 'journal-photos'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   );
-- 
-- -- Users can UPDATE (replace) their own photos
-- CREATE POLICY "Users can update own journal photos"
--   ON storage.objects
--   FOR UPDATE
--   TO authenticated
--   USING (
--     bucket_id = 'journal-photos'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   )
--   WITH CHECK (
--     bucket_id = 'journal-photos'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   );
-- 
-- -- Users can DELETE their own photos
-- CREATE POLICY "Users can delete own journal photos"
--   ON storage.objects
--   FOR DELETE
--   TO authenticated
--   USING (
--     bucket_id = 'journal-photos'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   );
-- 
-- -- ============================================================================
-- -- RLS POLICIES: JOURNAL-VIDEOS BUCKET
-- -- ============================================================================
-- 
-- -- Users can SELECT (read) their own videos
-- CREATE POLICY "Users can read own journal videos"
--   ON storage.objects
--   FOR SELECT
--   TO authenticated
--   USING (
--     bucket_id = 'journal-videos'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   );
-- 
-- -- Users can INSERT (upload) their own videos
-- CREATE POLICY "Users can upload own journal videos"
--   ON storage.objects
--   FOR INSERT
--   TO authenticated
--   WITH CHECK (
--     bucket_id = 'journal-videos'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   );
-- 
-- -- Users can UPDATE (replace) their own videos
-- CREATE POLICY "Users can update own journal videos"
--   ON storage.objects
--   FOR UPDATE
--   TO authenticated
--   USING (
--     bucket_id = 'journal-videos'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   )
--   WITH CHECK (
--     bucket_id = 'journal-videos'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   );
-- 
-- -- Users can DELETE their own videos
-- CREATE POLICY "Users can delete own journal videos"
--   ON storage.objects
--   FOR DELETE
--   TO authenticated
--   USING (
--     bucket_id = 'journal-videos'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   );
-- 
-- -- ============================================================================
-- -- RLS POLICIES: JOURNAL-THUMBNAILS BUCKET
-- -- ============================================================================
-- 
-- -- Users can SELECT (read) their own thumbnails
-- CREATE POLICY "Users can read own journal thumbnails"
--   ON storage.objects
--   FOR SELECT
--   TO authenticated
--   USING (
--     bucket_id = 'journal-thumbnails'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   );
-- 
-- -- Users can INSERT (upload) their own thumbnails
-- CREATE POLICY "Users can upload own journal thumbnails"
--   ON storage.objects
--   FOR INSERT
--   TO authenticated
--   WITH CHECK (
--     bucket_id = 'journal-thumbnails'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   );
-- 
-- -- Users can UPDATE (replace) their own thumbnails
-- CREATE POLICY "Users can update own journal thumbnails"
--   ON storage.objects
--   FOR UPDATE
--   TO authenticated
--   USING (
--     bucket_id = 'journal-thumbnails'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   )
--   WITH CHECK (
--     bucket_id = 'journal-thumbnails'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   );
-- 
-- -- Users can DELETE their own thumbnails
-- CREATE POLICY "Users can delete own journal thumbnails"
--   ON storage.objects
--   FOR DELETE
--   TO authenticated
--   USING (
--     bucket_id = 'journal-thumbnails'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   );
-- 
-- -- ============================================================================
-- -- HELPER FUNCTIONS
-- -- ============================================================================
-- 
-- -- Function to generate a unique storage path for a user's media
-- -- Returns: user_id/random_uuid/filename
-- CREATE OR REPLACE FUNCTION generate_storage_path(
--   p_user_id UUID,
--   p_filename TEXT,
--   p_prefix TEXT DEFAULT NULL
-- )
-- RETURNS TEXT AS $$
-- DECLARE
--   v_unique_name TEXT;
--   v_extension TEXT;
--   v_base_name TEXT;
--   v_dot_pos INTEGER;
-- BEGIN
--   -- Extract file extension
--   v_dot_pos := strrpos(p_filename, '.');
--   IF v_dot_pos > 0 THEN
--     v_base_name := substring(p_filename, 1, v_dot_pos - 1);
--     v_extension := substring(p_filename, v_dot_pos);
--   ELSE
--     v_base_name := p_filename;
--     v_extension := '';
--   END IF;
-- 
--   -- Sanitize base filename (remove special characters, replace spaces)
--   v_base_name := regexp_replace(v_base_name, '[^a-zA-Z0-9_-]', '-', 'g');
--   v_base_name := regexp_replace(v_base_name, '-+', '-', 'g');
--   v_base_name := lower(trim(v_base_name, '-'));
-- 
--   -- Generate unique identifier
--   v_unique_name := v_base_name || '_' || encode(gen_random_bytes(4), 'hex') || v_extension;
-- 
--   -- Build full path with optional prefix
--   IF p_prefix IS NOT NULL THEN
--     RETURN p_user_id::text || '/' || p_prefix || '/' || v_unique_name;
--   ELSE
--     RETURN p_user_id::text || '/' || v_unique_name;
--   END IF;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;
-- 
-- -- ============================================================================
-- -- GRANTS
-- -- ============================================================================
-- 
-- -- Grant usage on storage functions to authenticated users
-- GRANT USAGE ON SCHEMA storage TO authenticated;
-- 
-- -- Grant select on buckets to allow users to list buckets
-- GRANT SELECT ON storage.buckets TO authenticated;
-- 
-- -- ============================================================================
-- -- COMMENTS FOR DOCUMENTATION
-- -- ============================================================================
-- 
-- COMMENT ON TABLE storage.objects IS 'Storage objects with RLS policies to ensure users can only access their own media';
-- 
-- RESET ROLE;

COMMENT ON FUNCTION generate_storage_path IS 'Generates a unique, sanitized storage path for user media files with optional prefix for organization';

-- Storage bucket documentation
COMMENT ON COLUMN storage.buckets.id IS 'Unique bucket identifier following DNS naming conventions';
COMMENT ON COLUMN storage.buckets.public IS 'Whether bucket contents are publicly accessible';
COMMENT ON COLUMN storage.buckets.file_size_limit IS 'Maximum file size in bytes';
COMMENT ON COLUMN storage.buckets.allowed_mime_types IS 'Array of allowed MIME types for uploads';
