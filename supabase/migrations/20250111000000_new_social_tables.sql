-- ============================================================
-- SoloAdventurer — Migration 011
-- New social tables
-- All brand new — no conflicts with existing schema.
-- ============================================================

-- ── user_verification ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_verification (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  tier          verification_tier NOT NULL DEFAULT 'unverified',
  provider      text,                -- 'onfido' | 'stripe_identity'
  provider_ref  text,                -- provider reference ID only; never store documents
  verified_at   timestamptz,
  expires_at    timestamptz,
  revoked_at    timestamptz,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT verified_requires_timestamp CHECK (
    tier = 'unverified' OR verified_at IS NOT NULL
  )
);

CREATE INDEX IF NOT EXISTS idx_user_verification_user_id ON user_verification (user_id);
CREATE INDEX IF NOT EXISTS idx_user_verification_tier    ON user_verification (tier);

CREATE TRIGGER trg_user_verification_updated_at
  BEFORE UPDATE ON user_verification
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Auto-create verification row on profile creation
CREATE OR REPLACE FUNCTION create_default_verification()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO user_verification (user_id) VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_profile_create_verification') THEN
    CREATE TRIGGER trg_profile_create_verification
      AFTER INSERT ON profiles
      FOR EACH ROW EXECUTE FUNCTION create_default_verification();
  END IF;
END;
$$;

-- Backfill for existing profiles
INSERT INTO user_verification (user_id)
SELECT id FROM profiles
WHERE id NOT IN (SELECT user_id FROM user_verification)
ON CONFLICT DO NOTHING;

-- ── profile_privacy_settings ─────────────────────────────────
CREATE TABLE IF NOT EXISTS profile_privacy_settings (
  id                          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                     uuid NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  visibility                  profile_visibility NOT NULL DEFAULT 'hidden',
  min_viewer_age              int CHECK (min_viewer_age IS NULL OR min_viewer_age BETWEEN 18 AND 99),
  verified_only               boolean NOT NULL DEFAULT false,
  gender_filter               text[],   -- null = all; e.g. ARRAY['female','non-binary']
  show_location               boolean NOT NULL DEFAULT false,
  discoverable_by_destination boolean NOT NULL DEFAULT false,
  created_at                  timestamptz NOT NULL DEFAULT now(),
  updated_at                  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_profile_privacy_user_id    ON profile_privacy_settings (user_id);
CREATE INDEX IF NOT EXISTS idx_profile_privacy_visibility ON profile_privacy_settings (visibility);

CREATE TRIGGER trg_profile_privacy_updated_at
  BEFORE UPDATE ON profile_privacy_settings
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE OR REPLACE FUNCTION create_default_privacy()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO profile_privacy_settings (user_id) VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_profile_create_privacy') THEN
    CREATE TRIGGER trg_profile_create_privacy
      AFTER INSERT ON profiles
      FOR EACH ROW EXECUTE FUNCTION create_default_privacy();
  END IF;
END;
$$;

INSERT INTO profile_privacy_settings (user_id)
SELECT id FROM profiles
WHERE id NOT IN (SELECT user_id FROM profile_privacy_settings)
ON CONFLICT DO NOTHING;

-- ── content_privacy_settings ─────────────────────────────────
CREATE TABLE IF NOT EXISTS content_privacy_settings (
  id                          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                     uuid NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  default_post_audience       content_audience NOT NULL DEFAULT 'followers',
  allow_comments_from         comment_permission NOT NULL DEFAULT 'followers',
  allow_reshares              boolean NOT NULL DEFAULT false,
  include_in_destination_feed boolean NOT NULL DEFAULT true,
  created_at                  timestamptz NOT NULL DEFAULT now(),
  updated_at                  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_content_privacy_user_id ON content_privacy_settings (user_id);

CREATE TRIGGER trg_content_privacy_updated_at
  BEFORE UPDATE ON content_privacy_settings
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE OR REPLACE FUNCTION create_default_content_privacy()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO content_privacy_settings (user_id) VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_profile_create_content_privacy') THEN
    CREATE TRIGGER trg_profile_create_content_privacy
      AFTER INSERT ON profiles
      FOR EACH ROW EXECUTE FUNCTION create_default_content_privacy();
  END IF;
END;
$$;

INSERT INTO content_privacy_settings (user_id)
SELECT id FROM profiles
WHERE id NOT IN (SELECT user_id FROM content_privacy_settings)
ON CONFLICT DO NOTHING;

-- ── follows ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS follows (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  follower_id   uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  following_id  uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status        follow_status NOT NULL DEFAULT 'pending',
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT no_self_follow  CHECK (follower_id != following_id),
  CONSTRAINT unique_follow   UNIQUE (follower_id, following_id)
);

CREATE INDEX IF NOT EXISTS idx_follows_follower_id         ON follows (follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following_id        ON follows (following_id);
CREATE INDEX IF NOT EXISTS idx_follows_following_accepted  ON follows (following_id, status) WHERE status = 'accepted';

CREATE TRIGGER trg_follows_updated_at
  BEFORE UPDATE ON follows
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ── blocks ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS blocks (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  blocker_id  uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  blocked_id  uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at  timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT no_self_block  CHECK (blocker_id != blocked_id),
  CONSTRAINT unique_block   UNIQUE (blocker_id, blocked_id)
);

CREATE INDEX IF NOT EXISTS idx_blocks_blocker_id ON blocks (blocker_id);
CREATE INDEX IF NOT EXISTS idx_blocks_blocked_id ON blocks (blocked_id);
CREATE INDEX IF NOT EXISTS idx_blocks_pair       ON blocks (blocker_id, blocked_id);

-- Remove follows in both directions when a block is created
CREATE OR REPLACE FUNCTION remove_follows_on_block()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  DELETE FROM follows
  WHERE (follower_id = NEW.blocker_id AND following_id = NEW.blocked_id)
     OR (follower_id = NEW.blocked_id AND following_id = NEW.blocker_id);
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_block_remove_follows
  AFTER INSERT ON blocks
  FOR EACH ROW EXECUTE FUNCTION remove_follows_on_block();

-- ── reports ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reports (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id   uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  target_id     uuid NOT NULL,
  target_type   report_target_type NOT NULL,
  reason        text NOT NULL CHECK (char_length(reason) BETWEEN 10 AND 1000),
  details       text,
  resolved      boolean NOT NULL DEFAULT false,
  resolved_at   timestamptz,
  resolved_by   uuid REFERENCES profiles(id),
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_reports_reporter_id ON reports (reporter_id);
CREATE INDEX IF NOT EXISTS idx_reports_target      ON reports (target_id, target_type);
CREATE INDEX IF NOT EXISTS idx_reports_unresolved  ON reports (resolved) WHERE resolved = false;

-- ── comments ─────────────────────────────────────────────────
-- References journals(id) — your existing content table
CREATE TABLE IF NOT EXISTS comments (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  journal_id  uuid NOT NULL REFERENCES journals(id) ON DELETE CASCADE,
  author_id   uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  parent_id   uuid REFERENCES comments(id) ON DELETE CASCADE,
  body        text NOT NULL CHECK (char_length(body) BETWEEN 1 AND 2000),
  deleted_at  timestamptz,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_comments_journal_id ON comments (journal_id, created_at);
CREATE INDEX IF NOT EXISTS idx_comments_author_id  ON comments (author_id);
CREATE INDEX IF NOT EXISTS idx_comments_parent_id  ON comments (parent_id) WHERE parent_id IS NOT NULL;

CREATE TRIGGER trg_comments_updated_at
  BEFORE UPDATE ON comments
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Keep journals.comment_count in sync
CREATE OR REPLACE FUNCTION sync_comment_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.deleted_at IS NULL THEN
    UPDATE journals SET comment_count = comment_count + 1 WHERE id = NEW.journal_id;
  ELSIF TG_OP = 'UPDATE' AND OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
    UPDATE journals SET comment_count = GREATEST(comment_count - 1, 0) WHERE id = NEW.journal_id;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_sync_comment_count
  AFTER INSERT OR UPDATE ON comments
  FOR EACH ROW EXECUTE FUNCTION sync_comment_count();

-- ── reactions ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reactions (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  target_id    uuid NOT NULL,
  target_type  text NOT NULL CHECK (target_type IN ('journal', 'comment')),
  reaction     reaction_type NOT NULL DEFAULT 'like',
  created_at   timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT unique_reaction UNIQUE (user_id, target_id, target_type)
);

CREATE INDEX IF NOT EXISTS idx_reactions_target  ON reactions (target_id, target_type);
CREATE INDEX IF NOT EXISTS idx_reactions_user_id ON reactions (user_id);

-- Keep journals.reaction_count in sync
CREATE OR REPLACE FUNCTION sync_reaction_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.target_type = 'journal' THEN
    UPDATE journals SET reaction_count = reaction_count + 1 WHERE id = NEW.target_id;
  ELSIF TG_OP = 'DELETE' AND OLD.target_type = 'journal' THEN
    UPDATE journals SET reaction_count = GREATEST(reaction_count - 1, 0) WHERE id = OLD.target_id;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_sync_reaction_count
  AFTER INSERT OR DELETE ON reactions
  FOR EACH ROW EXECUTE FUNCTION sync_reaction_count();

-- ── feed_items ───────────────────────────────────────────────
-- Fan-out on write: one row per follower per action.
-- Feeds are pre-computed; reads are O(1).
CREATE TABLE IF NOT EXISTS feed_items (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id    uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  actor_id    uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  verb        feed_verb NOT NULL,
  object_id   uuid NOT NULL,       -- journal_id, follow_id, etc.
  object_type text NOT NULL,       -- 'journal' | 'follow' | 'reaction'
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_feed_owner_created ON feed_items (owner_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_feed_actor_object  ON feed_items (actor_id, object_id);

-- RPC: fan out a new journal/post to all followers' feeds
CREATE OR REPLACE FUNCTION fanout_post_to_feeds(p_journal_id uuid, p_author_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO feed_items (owner_id, actor_id, verb, object_id, object_type)
  SELECT f.follower_id, p_author_id, 'posted', p_journal_id, 'journal'
  FROM follows f
  WHERE f.following_id = p_author_id AND f.status = 'accepted'
  ON CONFLICT DO NOTHING;

  -- Author sees their own posts in their feed
  INSERT INTO feed_items (owner_id, actor_id, verb, object_id, object_type)
  VALUES (p_author_id, p_author_id, 'posted', p_journal_id, 'journal')
  ON CONFLICT DO NOTHING;
END;
$$;

-- ── notifications ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notifications (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type        text NOT NULL,
  actor_id    uuid REFERENCES profiles(id) ON DELETE SET NULL,
  object_id   uuid,
  object_type text,
  body        text,
  read        boolean NOT NULL DEFAULT false,
  read_at     timestamptz,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications (user_id, created_at DESC) WHERE read = false;
CREATE INDEX IF NOT EXISTS idx_notifications_all    ON notifications (user_id, created_at DESC);

-- ── meetup_checkins (new safety state machine) ───────────────
-- Separate from existing check_ins — this is the social meetup
-- safety feature. Link back via check_ins.meetup_checkin_id.
CREATE TABLE IF NOT EXISTS meetup_checkins (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  trusted_contact_id    uuid NOT NULL REFERENCES trusted_contacts(id) ON DELETE CASCADE,
  meetup_time           timestamptz NOT NULL,
  location_name         text,
  meeting_note          text,          -- private; never shared with contact
  checkin_buffer_mins   int NOT NULL DEFAULT 120
    CHECK (checkin_buffer_mins BETWEEN 30 AND 480),
  status                checkin_status NOT NULL DEFAULT 'scheduled',
  activated_at          timestamptz,
  checked_in_at         timestamptz,
  alerted_at            timestamptz,
  cancelled_at          timestamptz,
  sos_triggered_at      timestamptz,
  last_known_point      geography(Point, 4326),
  last_known_at         timestamptz,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_meetup_user_id      ON meetup_checkins (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_meetup_active       ON meetup_checkins (status) WHERE status IN ('scheduled','active');

CREATE TRIGGER trg_meetup_updated_at
  BEFORE UPDATE ON meetup_checkins
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- State transition enforcement + auto-timestamps
CREATE OR REPLACE FUNCTION enforce_checkin_transitions()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.status IN ('checked_in','alerted','cancelled') AND NEW.status != OLD.status AND NEW.status != 'sos' THEN
    RAISE EXCEPTION 'Cannot transition from terminal state % to %', OLD.status, NEW.status;
  END IF;
  IF NEW.status = 'active'     AND OLD.status = 'scheduled' THEN NEW.activated_at    = now(); END IF;
  IF NEW.status = 'checked_in' AND OLD.status = 'active'    THEN NEW.checked_in_at   = now(); END IF;
  IF NEW.status = 'alerted'    AND OLD.status = 'active'    THEN NEW.alerted_at      = now(); END IF;
  IF NEW.status = 'cancelled'                               THEN NEW.cancelled_at    = now(); END IF;
  IF NEW.status = 'sos'                                     THEN NEW.sos_triggered_at = now(); END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_checkin_state_transition
  BEFORE UPDATE ON meetup_checkins
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION enforce_checkin_transitions();

-- Add FK from check_ins to meetup_checkins now that table exists
ALTER TABLE check_ins
  ADD CONSTRAINT fk_check_ins_meetup_checkin
  FOREIGN KEY (meetup_checkin_id) REFERENCES meetup_checkins(id)
  ON DELETE SET NULL;

-- ── safety_alerts (immutable audit log) ──────────────────────
CREATE TABLE IF NOT EXISTS safety_alerts (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  checkin_id        uuid NOT NULL REFERENCES meetup_checkins(id),
  user_id           uuid NOT NULL REFERENCES profiles(id),
  alert_type        alert_type NOT NULL,
  last_known_point  geography(Point, 4326),
  last_known_at     timestamptz,
  sent_at           timestamptz NOT NULL DEFAULT now(),
  delivered_at      timestamptz,
  resolved_at       timestamptz,
  delivery_channel  text NOT NULL DEFAULT 'push',
  delivery_ref      text
);

CREATE INDEX IF NOT EXISTS idx_safety_alerts_checkin ON safety_alerts (checkin_id);
CREATE INDEX IF NOT EXISTS idx_safety_alerts_user    ON safety_alerts (user_id, sent_at DESC);

-- ── pg_cron: activate and escalate meetup check-ins ──────────
SELECT cron.schedule(
  'activate-meetup-checkins',
  '* * * * *',
  $$ UPDATE meetup_checkins SET status = 'active'
     WHERE status = 'scheduled' AND meetup_time <= now(); $$
);

SELECT cron.schedule(
  'escalate-overdue-checkins',
  '* * * * *',
  $$ UPDATE meetup_checkins SET status = 'alerted', last_known_at = now()
     WHERE status = 'active'
       AND (meetup_time + (checkin_buffer_mins || ' minutes')::interval) <= now(); $$
);
