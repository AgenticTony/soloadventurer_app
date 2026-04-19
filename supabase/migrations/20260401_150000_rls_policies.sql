-- SoloAdventurer Matching Feature - Row-Level Security Policies
-- Migration: 20260401_rls_policies.sql
-- Created: 2026-04-01
-- Purpose: RLS policies for data access control, women-only space enforcement
-- FIXED: Updated to use existing profiles table and compatible with existing schema

-- ============================================================================
-- OVERVIEW
-- ============================================================================
-- RLS policies enforce security at the database level:
-- 1. Users can only see their own data
-- 2. Women-only mode is enforced server-side
-- 3. Verification-gated actions are protected
-- 4. Connected users can see each other's profiles

-- ============================================================================
-- 1. ENABLE RLS ON ALL NEW TABLES
-- ============================================================================

-- Note: profiles, trips already have RLS enabled from earlier migrations
ALTER TABLE connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE women_only_spaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE women_only_space_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE gender_change_audit_log ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 2. PROFILES POLICIES (add to existing policies)
-- ============================================================================

-- Users can read basic info of users they're connected to
CREATE POLICY profiles_read_connected ON profiles
  FOR SELECT
  USING (
    auth.uid() != id
    AND has_active_connection(auth.uid(), id)
  );

-- Users can read profiles of potential matches (for discovery)
-- But women-only mode must be respected
CREATE POLICY profiles_read_potential_matches ON profiles
  FOR SELECT
  USING (
    auth.uid() != id
    AND (
      -- Requesting user doesn't have women-only mode
      NOT EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.id = auth.uid() AND p.women_only_mode_enabled = true
      )
      OR
      -- Or the target is a verified female
      (gender = 'female' AND gender_verified = true)
    )
    AND NOT are_users_blocked(auth.uid(), id)
    AND EXISTS (
      -- Must have some trip overlap potential
      SELECT 1 FROM trips t1, trips t2
      WHERE t1.user_id = auth.uid()
        AND t2.user_id = profiles.id
        AND (t1.is_active = true OR t1.is_public = true)
        AND (t2.is_active = true OR t2.is_public = true)
        AND t1.start_date <= t2.end_date
        AND t1.end_date >= t2.start_date
    )
  );

-- ============================================================================
-- 3. TRIPS POLICIES (add to existing policies)
-- ============================================================================

-- Users can read trips for matching (with visibility and women-only filters)
CREATE POLICY trips_read_for_matching ON trips
  FOR SELECT
  USING (
    auth.uid() != user_id
    AND (is_active = true OR is_public = true)
    -- Visibility check
    AND (
      visibility = 'everyone'
      OR (
        visibility = 'women-only'
        AND EXISTS (
          SELECT 1 FROM profiles p
          WHERE p.id = auth.uid()
            AND p.gender = 'female'
            AND p.gender_verified = true
        )
      )
    )
    -- Women-only mode check for requesting user
    AND (
      NOT EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.id = auth.uid() AND p.women_only_mode_enabled = true
      )
      OR EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.id = trips.user_id
          AND p.gender = 'female'
          AND p.gender_verified = true
      )
    )
    -- Must have date overlap with user's own trips
    AND EXISTS (
      SELECT 1 FROM trips t
      WHERE t.user_id = auth.uid()
        AND (t.is_active = true OR t.is_public = true)
        AND t.start_date <= trips.end_date
        AND t.end_date >= trips.start_date
    )
    -- Not blocked
    AND NOT are_users_blocked(auth.uid(), trips.user_id)
  );

-- ============================================================================
-- 4. CONNECTIONS POLICIES - NEW TABLE
-- ============================================================================

-- Users can read their own connections (as requester or recipient)
CREATE POLICY connections_read_own ON connections
  FOR SELECT
  USING (auth.uid() = requester_id OR auth.uid() = recipient_id);

-- Users can create connections (request connection)
CREATE POLICY connections_create_own ON connections
  FOR INSERT
  WITH CHECK (
    auth.uid() = requester_id
    AND auth.uid() != recipient_id
    AND NOT are_users_blocked(auth.uid(), recipient_id)
    -- Women-only mode enforcement
    AND (
      NOT EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.id = auth.uid() AND p.women_only_mode_enabled = true
      )
      OR EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.id = recipient_id
          AND p.gender = 'female'
          AND p.gender_verified = true
      )
    )
  );

-- Users can update connections they're part of (accept/decline)
CREATE POLICY connections_update_own ON connections
  FOR UPDATE
  USING (auth.uid() = requester_id OR auth.uid() = recipient_id)
  WITH CHECK (auth.uid() = requester_id OR auth.uid() = recipient_id);

-- ============================================================================
-- 5. ACTIVITIES POLICIES - NEW TABLE
-- ============================================================================

-- Activities are public read
CREATE POLICY activities_read_all ON activities
  FOR SELECT
  USING (is_active = true);

-- No direct user insert/update/delete on activities (admin only)
-- These would be managed via service role or migrations

-- ============================================================================
-- 6. USER_ACTIVITIES POLICIES - NEW TABLE
-- ============================================================================

-- Users can read their own activity interests
CREATE POLICY user_activities_read_own ON user_activities
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can see activity interests of connected users
CREATE POLICY user_activities_read_connected ON user_activities
  FOR SELECT
  USING (has_active_connection(auth.uid(), user_id));

-- Users can create their own activity interests
CREATE POLICY user_activities_create_own ON user_activities
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own activity interests
CREATE POLICY user_activities_delete_own ON user_activities
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- 7. MESSAGES POLICIES - NEW TABLE
-- ============================================================================

-- Users can read messages they sent or received
CREATE POLICY messages_read_own ON messages
  FOR SELECT
  USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- Users can send messages to accepted connections
CREATE POLICY messages_create_own ON messages
  FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id
    AND EXISTS (
      SELECT 1 FROM connections c
      WHERE c.id = messages.connection_id
        AND c.status = 'accepted'
        AND (c.requester_id = auth.uid() OR c.recipient_id = auth.uid())
    )
    AND NOT are_users_blocked(auth.uid(), receiver_id)
  );

-- Users can update message status (delivered_at, read_at) for messages they received
CREATE POLICY messages_update_received ON messages
  FOR UPDATE
  USING (auth.uid() = receiver_id)
  WITH CHECK (auth.uid() = receiver_id);

-- ============================================================================
-- 8. VERIFICATION_RECORDS POLICIES - NEW TABLE
-- ============================================================================

-- Users can read their own verification records
CREATE POLICY verification_records_read_own ON verification_records
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users cannot create verification records directly (Onfido webhook/edge function)
-- No INSERT policy for authenticated users

-- Users cannot update verification records directly
-- No UPDATE policy for authenticated users

-- ============================================================================
-- 9. WOMEN_ONLY_SPACES POLICIES - NEW TABLE
-- ============================================================================

-- Verified women can read public spaces they could join
CREATE POLICY women_only_spaces_read_eligible ON women_only_spaces
  FOR SELECT
  USING (
    is_active = true
    AND (
      -- Creator can always see their spaces
      auth.uid() = creator_id
      OR
      -- Or it's public and user is verified female
      (
        is_public = true
        AND can_access_women_only_spaces(auth.uid())
      )
      OR
      -- Or user is already a member
      EXISTS (
        SELECT 1 FROM women_only_space_members wosm
        WHERE wosm.space_id = women_only_spaces.id
          AND wosm.user_id = auth.uid()
          AND wosm.status = 'approved'
      )
    )
  );

-- Only verified women can create spaces
CREATE POLICY women_only_spaces_create_verified ON women_only_spaces
  FOR INSERT
  WITH CHECK (
    auth.uid() = creator_id
    AND can_access_women_only_spaces(auth.uid())
  );

-- Only creator can update spaces
CREATE POLICY women_only_spaces_update_creator ON women_only_spaces
  FOR UPDATE
  USING (auth.uid() = creator_id)
  WITH CHECK (auth.uid() = creator_id);

-- Only creator can delete spaces
CREATE POLICY women_only_spaces_delete_creator ON women_only_spaces
  FOR DELETE
  USING (auth.uid() = creator_id);

-- ============================================================================
-- 10. WOMEN_ONLY_SPACE_MEMBERS POLICIES - NEW TABLE
-- ============================================================================

-- Members can see other members in spaces they're part of
CREATE POLICY women_only_space_members_read_member ON women_only_space_members
  FOR SELECT
  USING (
    -- Can see if you're a member
    EXISTS (
      SELECT 1 FROM women_only_space_members wosm
      WHERE wosm.space_id = women_only_space_members.space_id
        AND wosm.user_id = auth.uid()
        AND wosm.status = 'approved'
    )
    -- Or you're the creator
    OR EXISTS (
      SELECT 1 FROM women_only_spaces wos
      WHERE wos.id = women_only_space_members.space_id
        AND wos.creator_id = auth.uid()
    )
  );

-- Verified women can request to join (creates pending membership)
CREATE POLICY women_only_space_members_join ON women_only_space_members
  FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND can_access_women_only_spaces(auth.uid())
    AND EXISTS (
      SELECT 1 FROM women_only_spaces wos
      WHERE wos.id = women_only_space_members.space_id
        AND wos.is_active = true
    )
  );

-- Space creator can update memberships (approve/reject)
CREATE POLICY women_only_space_members_update_admin ON women_only_space_members
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM women_only_spaces wos
      WHERE wos.id = women_only_space_members.space_id
        AND wos.creator_id = auth.uid()
    )
  );

-- Members can leave (delete their membership)
CREATE POLICY women_only_space_members_delete_own ON women_only_space_members
  FOR DELETE
  USING (auth.uid() = user_id);

-- Creator can remove members
CREATE POLICY women_only_space_members_delete_admin ON women_only_space_members
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM women_only_spaces wos
      WHERE wos.id = women_only_space_members.space_id
        AND wos.creator_id = auth.uid()
    )
  );

-- ============================================================================
-- 11. GENDER_CHANGE_AUDIT_LOG POLICIES - NEW TABLE
-- ============================================================================

-- Users can read their own gender change history
CREATE POLICY gender_change_audit_read_own ON gender_change_audit_log
  FOR SELECT
  USING (auth.uid() = user_id);

-- No INSERT/UPDATE/DELETE - only trigger can write to this table

-- ============================================================================
-- 12. SERVICE ROLE BYPASS (For Edge Functions)
-- ============================================================================

-- Allow service role to bypass RLS for:
-- - Verification webhooks from Onfido
-- - Match creation background jobs
-- - Admin operations

-- Note: In Supabase, service role already bypasses RLS by default
-- This is just documentation that we rely on this for background operations

-- ============================================================================
-- 13. POLICY VERIFICATION VIEWS (For Testing)
-- ============================================================================

-- View to check which policies are active on each table
CREATE OR REPLACE VIEW rls_policy_summary AS
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ============================================================================
-- 14. HELPER FUNCTION: Check RLS is enabled
-- ============================================================================

CREATE OR REPLACE FUNCTION verify_rls_enabled()
RETURNS TABLE (
  table_name TEXT,
  rls_enabled BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.relname::TEXT AS table_name,
    c.relrowsecurity AS rls_enabled
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relkind = 'r'
    AND c.relname IN (
      'profiles', 'trips', 'connections', 'activities',
      'user_activities', 'messages', 'blocks',
      'verification_records', 'women_only_spaces', 
      'women_only_space_members', 'gender_change_audit_log'
    )
  ORDER BY c.relname;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================================================
-- 15. BYPASS POLICY FOR AUTHENTICATED USERS (Safety Net)
-- ============================================================================

-- This ensures authenticated users can always read public activities
-- even if other policies somehow fail
CREATE POLICY activities_read_public ON activities
  FOR SELECT
  TO authenticated
  USING (is_active = true);

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON POLICY profiles_read_connected ON profiles IS 'Users can see profiles of people they have accepted connections with';
COMMENT ON POLICY profiles_read_potential_matches ON profiles IS 'Users can see basic info of potential matches, respecting women-only mode';
COMMENT ON POLICY trips_read_for_matching ON trips IS 'Users can see trips for matching, filtered by visibility and women-only mode';
COMMENT ON POLICY connections_create_own ON connections IS 'Enforces women-only mode when creating connections';
COMMENT ON POLICY messages_create_own ON messages IS 'Only allows messages within accepted connections';
COMMENT ON POLICY women_only_spaces_read_eligible ON women_only_spaces IS 'Only verified females can access women-only spaces';
COMMENT ON FUNCTION verify_rls_enabled IS 'Utility to verify RLS is enabled on all protected tables';
