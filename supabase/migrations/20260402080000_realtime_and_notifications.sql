-- ============================================================
-- SoloAdventurer — Migration: Realtime & Push Notifications
-- Sprint 2: Real-time Infrastructure
-- Purpose: Enable Realtime for messaging, presence, and push notifications
-- ============================================================

-- ============================================================================
-- 1. ENABLE REALTIME ON MESSAGES TABLE
-- ============================================================================

-- Add messages table to supabase_realtime publication
-- This allows clients to subscribe to new messages in real-time
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- ============================================================================
-- 2. ENABLE REALTIME ON CONNECTIONS TABLE
-- ============================================================================

-- Add connections table for real-time match notifications
ALTER PUBLICATION supabase_realtime ADD TABLE connections;

-- ============================================================================
-- 3. NOTIFICATION TOKENS TABLE (for Push Notifications - FCM/APNs)
-- ============================================================================

CREATE TABLE IF NOT EXISTS notification_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  
  -- Device token from FCM or APNs
  token TEXT NOT NULL,
  
  -- Platform identifier
  platform TEXT NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
  
  -- Device info for targeting
  device_id TEXT,
  device_name TEXT,
  app_version TEXT,
  os_version TEXT,
  
  -- Token status
  is_active BOOLEAN NOT NULL DEFAULT true,
  last_used_at TIMESTAMPTZ,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- One active token per device per user
  CONSTRAINT unique_user_device_token UNIQUE (user_id, device_id)
);

-- Indexes for notification tokens
CREATE INDEX IF NOT EXISTS idx_notification_tokens_user ON notification_tokens(user_id) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_notification_tokens_token ON notification_tokens(token) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_notification_tokens_platform ON notification_tokens(platform);

-- Updated_at trigger
CREATE TRIGGER trg_notification_tokens_updated_at
  BEFORE UPDATE ON notification_tokens
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Enable RLS
ALTER TABLE notification_tokens ENABLE ROW LEVEL SECURITY;

-- Users can manage their own notification tokens
CREATE POLICY notification_tokens_owner_all ON notification_tokens
  FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- ============================================================================
-- 4. TYPING INDICATORS TABLE (Presence/Transient State)
-- ============================================================================

-- Lightweight table to track who is typing in which chat
-- Data is ephemeral - should be cleaned up regularly
CREATE TABLE IF NOT EXISTS typing_indicators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id TEXT NOT NULL,  -- Connection ID used as chat ID
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  
  -- Timestamp for expiration
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '10 seconds'),
  
  -- One typing record per user per chat
  CONSTRAINT unique_typing_user_chat UNIQUE (chat_id, user_id)
);

-- Index for quick lookups. NOW() is STABLE, not IMMUTABLE, so it cannot appear
-- in a partial-index predicate (SQLSTATE 42P17) — queries filter on expires_at
-- at runtime against these plain indexes instead.
CREATE INDEX IF NOT EXISTS idx_typing_chat ON typing_indicators(chat_id, expires_at);
CREATE INDEX IF NOT EXISTS idx_typing_expiry ON typing_indicators(expires_at);

-- Enable RLS
ALTER TABLE typing_indicators ENABLE ROW LEVEL SECURITY;

-- Users can read typing indicators for chats they're part of
CREATE POLICY typing_indicators_read ON typing_indicators
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM connections c
      WHERE c.id::text = typing_indicators.chat_id
        AND c.status = 'accepted'
        AND (c.requester_id = auth.uid() OR c.recipient_id = auth.uid())
    )
  );

-- Users can insert their own typing indicators
CREATE POLICY typing_indicators_insert ON typing_indicators
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Users can update their own typing indicators
CREATE POLICY typing_indicators_update ON typing_indicators
  FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Users can delete their own typing indicators
CREATE POLICY typing_indicators_delete ON typing_indicators
  FOR DELETE
  USING (user_id = auth.uid());

-- ============================================================================
-- 5. CLEANUP EXPIRED TYPING INDICATORS (pg_cron)
-- ============================================================================

SELECT cron.schedule(
  'cleanup-expired-typing-indicators',
  -- pg_cron takes 5-field crontab or 'N seconds'; 6-field (seconds) syntax is invalid
  '5 seconds',
  $$ DELETE FROM typing_indicators WHERE expires_at < NOW(); $$
);

-- ============================================================================
-- 6. FUNCTIONS FOR TYPING PRESENCE
-- ============================================================================

-- Function to set typing indicator (upsert)
CREATE OR REPLACE FUNCTION set_typing_indicator(p_chat_id TEXT, p_user_id UUID)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO typing_indicators (chat_id, user_id, started_at, expires_at)
  VALUES (p_chat_id, p_user_id, NOW(), NOW() + INTERVAL '10 seconds')
  ON CONFLICT (chat_id, user_id) 
  DO UPDATE SET 
    started_at = NOW(),
    expires_at = NOW() + INTERVAL '10 seconds';
END;
$$;

-- Function to clear typing indicator
CREATE OR REPLACE FUNCTION clear_typing_indicator(p_chat_id TEXT, p_user_id UUID)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  DELETE FROM typing_indicators 
  WHERE chat_id = p_chat_id AND user_id = p_user_id;
END;
$$;

-- Function to get typing users in a chat
CREATE OR REPLACE FUNCTION get_typing_users(p_chat_id TEXT)
RETURNS TABLE (user_id UUID, started_at TIMESTAMPTZ) 
LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  SELECT ti.user_id, ti.started_at
  FROM typing_indicators ti
  WHERE ti.chat_id = p_chat_id
    AND ti.expires_at > NOW()
    AND ti.user_id != auth.uid();  -- Don't return own typing indicator
END;
$$;

-- ============================================================================
-- 7. EDGE FUNCTION TRIGGER: NEW MATCH NOTIFICATION
-- ============================================================================

-- Function to be called by trigger or directly
-- Creates notification for new connection
CREATE OR REPLACE FUNCTION notify_new_match()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  -- Only notify for new pending connections
  IF NEW.status = 'pending' AND (TG_OP = 'INSERT' OR OLD.status IS NULL) THEN
    INSERT INTO notifications (user_id, type, actor_id, object_id, object_type, body)
    VALUES (
      NEW.recipient_id,
      'new_match',
      NEW.requester_id,
      NEW.id,
      'connection',
      'You have a new travel match!'
    );
  END IF;
  
  RETURN NEW;
END;
$$;

-- Trigger on connections table
DROP TRIGGER IF EXISTS trg_notify_new_match ON connections;
CREATE TRIGGER trg_notify_new_match
  AFTER INSERT OR UPDATE ON connections
  FOR EACH ROW
  WHEN (NEW.status = 'pending')
  EXECUTE FUNCTION notify_new_match();

-- ============================================================================
-- 8. RPC FOR UNREAD MESSAGE COUNT
-- ============================================================================

CREATE OR REPLACE FUNCTION get_unread_message_count()
RETURNS INTEGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  count INTEGER;
BEGIN
  SELECT COUNT(*) INTO count
  FROM messages m
  JOIN connections c ON c.id = m.connection_id
  WHERE m.receiver_id = auth.uid()
    AND m.read_at IS NULL
    AND c.status = 'accepted';
  
  RETURN count;
END;
$$;

-- ============================================================================
-- 9. RPC FOR UNREAD NOTIFICATION COUNT
-- ============================================================================

CREATE OR REPLACE FUNCTION get_unread_notification_count()
RETURNS INTEGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  count INTEGER;
BEGIN
  SELECT COUNT(*) INTO count
  FROM notifications
  WHERE user_id = auth.uid() AND read = false;
  
  RETURN count;
END;
$$;

-- ============================================================================
-- 10. INDEXES FOR PERFORMANCE
-- ============================================================================

-- Additional indexes for real-time queries
CREATE INDEX IF NOT EXISTS idx_messages_realtime ON messages(connection_id, sent_at DESC) 
  INCLUDE (sender_id, receiver_id, content, read_at);

-- ============================================================================
-- 11. GRANT PERMISSIONS
-- ============================================================================

-- Allow authenticated users to use the RPC functions
GRANT EXECUTE ON FUNCTION set_typing_indicator TO authenticated;
GRANT EXECUTE ON FUNCTION clear_typing_indicator TO authenticated;
GRANT EXECUTE ON FUNCTION get_typing_users TO authenticated;
GRANT EXECUTE ON FUNCTION get_unread_message_count TO authenticated;
GRANT EXECUTE ON FUNCTION get_unread_notification_count TO authenticated;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE notification_tokens IS 'FCM/APNs device tokens for push notifications';
COMMENT ON TABLE typing_indicators IS 'Ephemeral typing presence for real-time chat';
COMMENT ON FUNCTION set_typing_indicator IS 'Set or update typing indicator for a user in a chat';
COMMENT ON FUNCTION clear_typing_indicator IS 'Clear typing indicator when user stops typing';
COMMENT ON FUNCTION get_typing_users IS 'Get list of users currently typing in a chat';
COMMENT ON FUNCTION notify_new_match IS 'Creates in-app notification for new match requests';
