-- ============================================================
-- SoloAdventurer — Migration: SOS Alerts Table
-- Created: 2026-04-02
-- Purpose: Dedicated table for direct SOS alerts (distinct from
--          safety_alerts which is tied to meetup_checkins)
-- ============================================================

-- ── SOS Alert Status Enum ─────────────────────────────────────
CREATE TYPE sos_alert_status AS ENUM (
  'active',      -- Alert is active and being tracked
  'acknowledged', -- At least one contact has acknowledged
  'resolved',    -- User confirmed safe
  'cancelled'    -- False alarm / user cancelled
);

-- ── SOS Alerts Table ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sos_alerts (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  
  -- Alert status
  status        sos_alert_status NOT NULL DEFAULT 'active',
  
  -- Location at time of SOS
  location      geography(Point, 4326),
  latitude      double precision,
  longitude     double precision,
  accuracy      double precision,  -- meters
  altitude      double precision,
  address       text,
  place_name    text,
  location_at   timestamptz NOT NULL DEFAULT now(),
  
  -- User-provided context
  message       text,
  
  -- Device state
  battery_level int CHECK (battery_level IS NULL OR battery_level BETWEEN 0 AND 100),
  
  -- Contact notification tracking
  notified_contact_ids    uuid[] NOT NULL DEFAULT '{}',
  acknowledged_contact_ids uuid[] NOT NULL DEFAULT '{}',
  
  -- Timestamps
  triggered_at          timestamptz NOT NULL DEFAULT now(),
  first_acknowledged_at timestamptz,
  resolved_at           timestamptz,
  cancelled_at          timestamptz,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now(),
  
  -- Associated entities
  trip_id               uuid,
  check_in_id           uuid REFERENCES check_ins(id) ON DELETE SET NULL,
  
  -- Additional metadata
  metadata              jsonb DEFAULT '{}'
);

-- Indexes for sos_alerts
CREATE INDEX IF NOT EXISTS idx_sos_alerts_user ON sos_alerts(user_id, triggered_at DESC);
CREATE INDEX IF NOT EXISTS idx_sos_alerts_status ON sos_alerts(status) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_sos_alerts_location ON sos_alerts USING GIST(location) WHERE location IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_sos_alerts_active_user ON sos_alerts(user_id) WHERE status = 'active';

-- Trigger for updated_at
CREATE TRIGGER trigger_sos_alerts_updated_at
  BEFORE UPDATE ON sos_alerts
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- ── RLS Policies ──────────────────────────────────────────────
ALTER TABLE sos_alerts ENABLE ROW LEVEL SECURITY;

-- Users can view their own SOS alerts
CREATE POLICY "Users can view own SOS alerts"
  ON sos_alerts FOR SELECT
  USING (auth.uid() = user_id);

-- Users can create their own SOS alerts
CREATE POLICY "Users can create own SOS alerts"
  ON sos_alerts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own SOS alerts (for cancellation/resolution)
CREATE POLICY "Users can update own SOS alerts"
  ON sos_alerts FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Emergency contacts can view active alerts for users who have them as trusted contacts
CREATE POLICY "Trusted contacts can view active SOS alerts"
  ON sos_alerts FOR SELECT
  USING (
    status = 'active' 
    AND EXISTS (
      SELECT 1 FROM trusted_contacts tc
      WHERE tc.user_id = sos_alerts.user_id
        AND tc.contact_user_id = auth.uid()
        AND tc.is_active = true
        AND tc.receives_emergency_alerts = true
    )
  );

-- Trusted contacts can acknowledge alerts they're notified of
CREATE POLICY "Trusted contacts can acknowledge SOS alerts"
  ON sos_alerts FOR UPDATE
  USING (
    status = 'active'
    AND auth.uid() = ANY(notified_contact_ids)
    OR EXISTS (
      SELECT 1 FROM trusted_contacts tc
      WHERE tc.user_id = sos_alerts.user_id
        AND tc.contact_user_id = auth.uid()
        AND tc.is_active = true
        AND tc.receives_emergency_alerts = true
    )
  );

-- ── Functions for SOS Alert Operations ────────────────────────

-- Trigger SOS and notify emergency contacts
CREATE OR REPLACE FUNCTION trigger_sos(
  p_user_id uuid,
  p_latitude double precision,
  p_longitude double precision,
  p_accuracy double precision DEFAULT NULL,
  p_altitude double precision DEFAULT NULL,
  p_address text DEFAULT NULL,
  p_message text DEFAULT NULL,
  p_battery_level int DEFAULT NULL,
  p_trip_id uuid DEFAULT NULL
) RETURNS uuid AS $$
DECLARE
  v_alert_id uuid;
  v_contact_ids uuid[];
BEGIN
  -- Get all trusted contacts with emergency alerts enabled
  SELECT array_agg(tc.id) INTO v_contact_ids
  FROM trusted_contacts tc
  WHERE tc.user_id = p_user_id
    AND tc.is_active = true
    AND tc.receives_emergency_alerts = true;
  
  -- If no contact_ids found, set to empty array
  IF v_contact_ids IS NULL THEN
    v_contact_ids := '{}';
  END IF;
  
  -- Create the SOS alert
  INSERT INTO sos_alerts (
    user_id,
    location,
    latitude,
    longitude,
    accuracy,
    altitude,
    address,
    message,
    battery_level,
    notified_contact_ids,
    trip_id,
    triggered_at,
    status
  ) VALUES (
    p_user_id,
    ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326),
    p_latitude,
    p_longitude,
    p_accuracy,
    p_altitude,
    p_address,
    p_message,
    p_battery_level,
    v_contact_ids,
    p_trip_id,
    now(),
    'active'
  ) RETURNING id INTO v_alert_id;
  
  RETURN v_alert_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Acknowledge an SOS alert (called by trusted contact)
CREATE OR REPLACE FUNCTION acknowledge_sos_alert(
  p_alert_id uuid,
  p_contact_id uuid
) RETURNS void AS $$
BEGIN
  UPDATE sos_alerts
  SET 
    acknowledged_contact_ids = array_append(acknowledged_contact_ids, p_contact_id),
    first_acknowledged_at = COALESCE(first_acknowledged_at, now()),
    status = CASE WHEN status = 'active' THEN 'acknowledged' ELSE status END
  WHERE id = p_alert_id
    AND p_contact_id = ANY(notified_contact_ids);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Resolve an SOS alert (user is safe)
CREATE OR REPLACE FUNCTION resolve_sos_alert(
  p_alert_id uuid
) RETURNS void AS $$
BEGIN
  UPDATE sos_alerts
  SET 
    status = 'resolved',
    resolved_at = now()
  WHERE id = p_alert_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Cancel an SOS alert (false alarm)
CREATE OR REPLACE FUNCTION cancel_sos_alert(
  p_alert_id uuid
) RETURNS void AS $$
BEGIN
  UPDATE sos_alerts
  SET 
    status = 'cancelled',
    cancelled_at = now()
  WHERE id = p_alert_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get active SOS alert for a user
CREATE OR REPLACE FUNCTION get_active_sos_alert(
  p_user_id uuid
) RETURNS TABLE (
  id uuid,
  status sos_alert_status,
  latitude double precision,
  longitude double precision,
  message text,
  battery_level int,
  triggered_at timestamptz,
  notified_contact_ids uuid[],
  acknowledged_contact_ids uuid[]
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    sa.id,
    sa.status,
    sa.latitude,
    sa.longitude,
    sa.message,
    sa.battery_level,
    sa.triggered_at,
    sa.notified_contact_ids,
    sa.acknowledged_contact_ids
  FROM sos_alerts sa
  WHERE sa.user_id = p_user_id
    AND sa.status IN ('active', 'acknowledged')
  ORDER BY sa.triggered_at DESC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ── Comments for Documentation ────────────────────────────────
COMMENT ON TABLE sos_alerts IS 'Direct SOS emergency alerts with location and contact notification tracking';
COMMENT ON FUNCTION trigger_sos IS 'Creates an SOS alert and returns the alert ID for tracking';
COMMENT ON FUNCTION acknowledge_sos_alert IS 'Records acknowledgment from a trusted contact';
COMMENT ON FUNCTION resolve_sos_alert IS 'Marks an SOS alert as resolved (user is safe)';
COMMENT ON FUNCTION cancel_sos_alert IS 'Cancels an SOS alert (false alarm)';
