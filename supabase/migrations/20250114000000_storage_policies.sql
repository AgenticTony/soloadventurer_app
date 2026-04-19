-- ============================================================
-- SoloAdventurer — Migration 014
-- Storage bucket policies
-- Run AFTER creating buckets in Supabase dashboard:
--   - avatars    (public)
--   - post-media (private)
-- ============================================================

-- ── avatars (public bucket) ──────────────────────────────────

CREATE POLICY "avatars: public read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "avatars: owner upload"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "avatars: owner update"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "avatars: owner delete"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- ── post-media (private bucket) ──────────────────────────────
-- Authenticated read only. Use signed URLs for non-public posts.
-- Path convention: {user_id}/{journal_id}/{filename}

CREATE POLICY "post-media: authenticated read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'post-media' AND auth.uid() IS NOT NULL);

CREATE POLICY "post-media: owner upload"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'post-media'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "post-media: owner delete"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'post-media'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );
