-- ============================================================
-- SoloAdventurer — Migration 012
-- RLS policies + helper functions
-- Applied after all tables exist.
-- ============================================================

-- ── Helper functions ─────────────────────────────────────────

CREATE OR REPLACE FUNCTION auth_user_verification_tier()
RETURNS verification_tier LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT COALESCE(
    (SELECT tier FROM user_verification WHERE user_id = auth.uid()),
    'unverified'::verification_tier
  )
$$;

CREATE OR REPLACE FUNCTION users_are_blocked(user_a uuid, user_b uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1 FROM blocks
    WHERE (blocker_id = user_a AND blocked_id = user_b)
       OR (blocker_id = user_b AND blocked_id = user_a)
  )
$$;

CREATE OR REPLACE FUNCTION viewer_follows(p_viewer uuid, p_target uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1 FROM follows
    WHERE follower_id = p_viewer AND following_id = p_target AND status = 'accepted'
  )
$$;

-- ── Enable RLS on all new and evolved tables ─────────────────

-- New tables
ALTER TABLE user_verification         ENABLE ROW LEVEL SECURITY;
ALTER TABLE profile_privacy_settings  ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_privacy_settings  ENABLE ROW LEVEL SECURITY;
ALTER TABLE follows                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocks                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE reactions                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE feed_items                ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications             ENABLE ROW LEVEL SECURITY;
ALTER TABLE meetup_checkins           ENABLE ROW LEVEL SECURITY;
ALTER TABLE safety_alerts             ENABLE ROW LEVEL SECURITY;

-- Existing tables (enable if not already enabled)
ALTER TABLE profiles          ENABLE ROW LEVEL SECURITY;
ALTER TABLE journals          ENABLE ROW LEVEL SECURITY;
ALTER TABLE trusted_contacts  ENABLE ROW LEVEL SECURITY;

-- ── profiles RLS ─────────────────────────────────────────────

CREATE POLICY "profiles: owner full access"
  ON profiles FOR ALL
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

CREATE POLICY "profiles: public visible to authenticated"
  ON profiles FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND id != auth.uid()
    AND is_active = true
    AND EXISTS (
      SELECT 1 FROM profile_privacy_settings pps
      WHERE pps.user_id = profiles.id AND pps.visibility = 'public'
    )
    AND NOT users_are_blocked(auth.uid(), id)
  );

CREATE POLICY "profiles: community visible (filter via RPC)"
  ON profiles FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND id != auth.uid()
    AND is_active = true
    AND EXISTS (
      SELECT 1 FROM profile_privacy_settings pps
      WHERE pps.user_id = profiles.id
        AND pps.visibility = 'community'
        AND (pps.verified_only = false OR auth_user_verification_tier() = 'id_verified')
    )
    AND NOT users_are_blocked(auth.uid(), id)
  );

-- Accepted followers always see the profile
CREATE POLICY "profiles: visible to accepted followers"
  ON profiles FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND id != auth.uid()
    AND is_active = true
    AND viewer_follows(auth.uid(), id)
    AND NOT users_are_blocked(auth.uid(), id)
  );

-- ── journals RLS ─────────────────────────────────────────────

CREATE POLICY "journals: owner full access"
  ON journals FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "journals: public audience"
  ON journals FOR SELECT
  USING (
    deleted_at IS NULL
    AND audience = 'public'
    AND auth.uid() IS NOT NULL
    AND NOT users_are_blocked(auth.uid(), user_id)
  );

CREATE POLICY "journals: community audience"
  ON journals FOR SELECT
  USING (
    deleted_at IS NULL
    AND audience = 'community'
    AND auth.uid() IS NOT NULL
    AND NOT users_are_blocked(auth.uid(), user_id)
  );

CREATE POLICY "journals: followers audience"
  ON journals FOR SELECT
  USING (
    deleted_at IS NULL
    AND audience = 'followers'
    AND viewer_follows(auth.uid(), user_id)
    AND NOT users_are_blocked(auth.uid(), user_id)
  );

CREATE POLICY "journals: verified audience"
  ON journals FOR SELECT
  USING (
    deleted_at IS NULL
    AND audience = 'verified'
    AND auth_user_verification_tier() = 'id_verified'
    AND viewer_follows(auth.uid(), user_id)
    AND NOT users_are_blocked(auth.uid(), user_id)
  );

-- ── user_verification RLS ────────────────────────────────────

CREATE POLICY "user_verification: owner read"
  ON user_verification FOR SELECT
  USING (user_id = auth.uid());
-- Writes via service_role (Edge Function) only

-- ── privacy settings RLS ─────────────────────────────────────

CREATE POLICY "profile_privacy: owner all"
  ON profile_privacy_settings FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "profile_privacy: authenticated read"
  ON profile_privacy_settings FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "content_privacy: owner all"
  ON content_privacy_settings FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- ── follows RLS ──────────────────────────────────────────────

CREATE POLICY "follows: select own relationships"
  ON follows FOR SELECT
  USING (follower_id = auth.uid() OR following_id = auth.uid());

CREATE POLICY "follows: insert as follower"
  ON follows FOR INSERT
  WITH CHECK (follower_id = auth.uid() AND NOT users_are_blocked(auth.uid(), following_id));

CREATE POLICY "follows: update as following (accept/reject)"
  ON follows FOR UPDATE
  USING (following_id = auth.uid())
  WITH CHECK (following_id = auth.uid());

CREATE POLICY "follows: delete own"
  ON follows FOR DELETE
  USING (follower_id = auth.uid() OR following_id = auth.uid());

-- ── blocks RLS ───────────────────────────────────────────────

CREATE POLICY "blocks: owner all"
  ON blocks FOR ALL
  USING (blocker_id = auth.uid())
  WITH CHECK (blocker_id = auth.uid());

-- ── reports RLS ──────────────────────────────────────────────

CREATE POLICY "reports: insert"
  ON reports FOR INSERT
  WITH CHECK (reporter_id = auth.uid());

CREATE POLICY "reports: read own"
  ON reports FOR SELECT
  USING (reporter_id = auth.uid());

-- ── comments RLS ─────────────────────────────────────────────

CREATE POLICY "comments: read if not blocked"
  ON comments FOR SELECT
  USING (
    deleted_at IS NULL
    AND auth.uid() IS NOT NULL
    AND NOT users_are_blocked(auth.uid(), author_id)
  );

CREATE POLICY "comments: insert own"
  ON comments FOR INSERT
  WITH CHECK (
    author_id = auth.uid()
    AND NOT users_are_blocked(
      auth.uid(),
      (SELECT user_id FROM journals WHERE id = journal_id)
    )
  );

CREATE POLICY "comments: update own"
  ON comments FOR UPDATE
  USING (author_id = auth.uid())
  WITH CHECK (author_id = auth.uid());

-- ── reactions RLS ────────────────────────────────────────────

CREATE POLICY "reactions: read any"
  ON reactions FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "reactions: insert own"
  ON reactions FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "reactions: delete own"
  ON reactions FOR DELETE
  USING (user_id = auth.uid());

-- ── feed_items RLS ───────────────────────────────────────────

CREATE POLICY "feed_items: owner only"
  ON feed_items FOR SELECT
  USING (owner_id = auth.uid());

-- ── notifications RLS ────────────────────────────────────────

CREATE POLICY "notifications: owner all"
  ON notifications FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- ── trusted_contacts RLS ─────────────────────────────────────

CREATE POLICY "trusted_contacts: owner all"
  ON trusted_contacts FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- ── meetup_checkins RLS ──────────────────────────────────────
-- Safety data: strict owner-only. Followers cannot see this.

CREATE POLICY "meetup_checkins: owner all"
  ON meetup_checkins FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- ── safety_alerts RLS ────────────────────────────────────────
-- Append-only from Edge Function (service_role).
-- Owner read-only from client.

CREATE POLICY "safety_alerts: owner read"
  ON safety_alerts FOR SELECT
  USING (user_id = auth.uid());

-- ── Realtime publications ────────────────────────────────────
-- Only expose what clients need to subscribe to.
-- Safety tables deliberately excluded.

DROP PUBLICATION IF EXISTS supabase_realtime;
CREATE PUBLICATION supabase_realtime FOR TABLE
  feed_items,
  notifications,
  follows;
