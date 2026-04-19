-- SoloAdventurer Matching Feature - Women-Only Mode
-- Migration: 20260401_women_only_mode.sql
-- Created: 2026-04-01
-- Purpose: Women-only mode with Onfido verification, spaces, and gender audit
-- FIXED: Updated to use existing profiles table instead of user_profiles

-- ============================================================================
-- 1. VERIFICATION RECORDS (Onfido result storage) - NEW TABLE
-- ============================================================================

CREATE TABLE verification_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  
  -- Verification type
  verification_type TEXT NOT NULL CHECK (verification_type IN ('gender', 'age', 'identity')),
  
  -- Onfido integration
  onfido_check_id TEXT UNIQUE,  -- Onfido check ID
  onfido_workflow_run_id TEXT,  -- Onfido workflow run ID (if using workflows)
  
  -- Status
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_review', 'approved', 'declined', 'expired')),
  
  -- Onfido results (stored as JSONB for flexibility)
  onfido_result JSONB,  -- Full check result from Onfido
  onfido_breakdown JSONB,  -- Detailed breakdown of checks performed
  
  -- Extracted data
  verified_gender TEXT,  -- Gender extracted from document
  verified_date_of_birth DATE,  -- DOB from document
  verified_nationality TEXT,  -- Nationality from document
  
  -- Admin review (for edge cases)
  reviewed_by UUID,  -- Admin user who reviewed
  reviewed_at TIMESTAMPTZ,
  review_notes TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ,  -- Verification expiration (e.g., 1 year)
  
  -- Constraints
  CONSTRAINT unique_pending_verification UNIQUE NULLS NOT DISTINCT (user_id, verification_type, status) 
    DEFERRABLE INITIALLY DEFERRED
);

-- Indexes for verification_records
CREATE INDEX idx_verification_records_user ON verification_records(user_id);
CREATE INDEX idx_verification_records_type_status ON verification_records(verification_type, status);
CREATE INDEX idx_verification_records_onfido ON verification_records(onfido_check_id);
CREATE INDEX idx_verification_records_approved ON verification_records(user_id, verification_type) 
  WHERE status = 'approved';

-- Trigger for updated_at (using existing function from migration 009)
CREATE TRIGGER trigger_verification_records_updated_at
  BEFORE UPDATE ON verification_records
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- 2. PROFILES TABLE - Add women-only mode columns
-- ============================================================================

-- Add women-only mode columns to existing profiles table
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS women_only_mode_enabled BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS women_only_mode_enabled_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS verification_required BOOLEAN DEFAULT false;

-- Constraint: women_only_mode can only be enabled by verified females
-- Use DO block to avoid error if constraint already exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'women_only_requires_verified_female' 
    AND conrelid = 'profiles'::regclass
  ) THEN
    ALTER TABLE profiles 
    ADD CONSTRAINT women_only_requires_verified_female CHECK (
      women_only_mode_enabled = false 
      OR (gender = 'female' AND gender_verified = true)
    );
  END IF;
END $$;

-- ============================================================================
-- 3. WOMEN-ONLY SPACES (Creator-controlled groups/rooms) - NEW TABLE
-- ============================================================================

CREATE TABLE women_only_spaces (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id UUID NOT NULL,  -- Must be verified female
  
  -- Space info
  name TEXT NOT NULL,
  description TEXT,
  
  -- Location (optional - for location-specific spaces)
  location_name TEXT,
  location GEOGRAPHY(POINT, 4326),
  radius_meters INTEGER DEFAULT 10000,  -- 10km default radius
  
  -- Dates (optional - for trip-specific spaces)
  start_date DATE,
  end_date DATE,
  
  -- Settings
  is_public BOOLEAN DEFAULT true,  -- Public spaces are discoverable
  max_members INTEGER DEFAULT 20,
  require_approval BOOLEAN DEFAULT false,  -- Creator must approve join requests
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT valid_space_dates CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)
);

-- Indexes for women_only_spaces
CREATE INDEX idx_women_only_spaces_creator ON women_only_spaces(creator_id);
CREATE INDEX idx_women_only_spaces_active ON women_only_spaces(is_active) WHERE is_active = true;
CREATE INDEX idx_women_only_spaces_public ON women_only_spaces(is_public, is_active) WHERE is_public = true AND is_active = true;

-- Trigger for updated_at
CREATE TRIGGER trigger_women_only_spaces_updated_at
  BEFORE UPDATE ON women_only_spaces
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- 4. WOMEN-ONLY SPACE MEMBERS - NEW TABLE
-- ============================================================================

CREATE TABLE women_only_space_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  space_id UUID NOT NULL REFERENCES women_only_spaces(id) ON DELETE CASCADE,
  user_id UUID NOT NULL,  -- Must be verified female
  
  -- Role
  role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('creator', 'admin', 'member')),
  
  -- Status
  status TEXT NOT NULL DEFAULT 'approved' CHECK (status IN ('pending', 'approved', 'rejected', 'removed')),
  
  -- Timestamps
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT unique_space_member UNIQUE (space_id, user_id)
);

-- Indexes for women_only_space_members
CREATE INDEX idx_women_only_space_members_space ON women_only_space_members(space_id);
CREATE INDEX idx_women_only_space_members_user ON women_only_space_members(user_id);
CREATE INDEX idx_women_only_space_members_approved ON women_only_space_members(space_id, user_id) 
  WHERE status = 'approved';

-- ============================================================================
-- 5. GENDER CHANGE AUDIT LOG (Security) - NEW TABLE
-- ============================================================================

CREATE TABLE gender_change_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  
  -- Change details
  old_gender TEXT NOT NULL,
  new_gender TEXT NOT NULL,
  old_gender_verified BOOLEAN,
  new_gender_verified BOOLEAN,
  
  -- Impact tracking
  was_women_only_enabled BOOLEAN DEFAULT false,
  
  -- Context
  change_reason TEXT,  -- User-provided reason (optional)
  ip_address INET,
  user_agent TEXT,
  
  -- Timestamp
  changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for gender change audit
CREATE INDEX idx_gender_change_audit_user ON gender_change_audit_log(user_id);
CREATE INDEX idx_gender_change_audit_timestamp ON gender_change_audit_log(changed_at DESC);

-- ============================================================================
-- 6. TRIGGERS FOR GENDER CHANGE AUDIT
-- ============================================================================

-- Trigger function to log gender changes
CREATE OR REPLACE FUNCTION log_gender_change()
RETURNS TRIGGER AS $$
BEGIN
  -- Only log if gender actually changed
  IF OLD.gender IS DISTINCT FROM NEW.gender THEN
    INSERT INTO gender_change_audit_log (
      user_id,
      old_gender,
      new_gender,
      old_gender_verified,
      new_gender_verified,
      was_women_only_enabled,
      changed_at
    ) VALUES (
      NEW.id,
      OLD.gender,
      NEW.gender,
      OLD.gender_verified,
      NEW.gender_verified,
      OLD.women_only_mode_enabled,
      NOW()
    );
    
    -- If gender changes from female, disable women-only mode
    IF OLD.gender = 'female' AND NEW.gender != 'female' THEN
      NEW.women_only_mode_enabled := false;
      NEW.women_only_mode_enabled_at := NULL;
      NEW.gender_verified := false;  -- Reset verification
    END IF;
    
    -- If gender changes, reset verification
    IF OLD.gender_verified = true THEN
      NEW.gender_verified := false;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to profiles (check if trigger exists first)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_log_gender_change'
  ) THEN
    CREATE TRIGGER trigger_log_gender_change
      BEFORE UPDATE ON profiles
      FOR EACH ROW
      EXECUTE FUNCTION log_gender_change();
  END IF;
END $$;

-- ============================================================================
-- 7. FUNCTIONS FOR WOMEN-ONLY MODE
-- ============================================================================

-- Check if user can access women-only spaces
CREATE OR REPLACE FUNCTION can_access_women_only_spaces(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles
    WHERE id = p_user_id
      AND gender = 'female'
      AND gender_verified = true
  );
END;
$$ LANGUAGE plpgsql STABLE;

-- Check if user can be shown in women-only matching
CREATE OR REPLACE FUNCTION can_be_shown_in_women_only(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles
    WHERE id = p_user_id
      AND gender = 'female'
      AND gender_verified = true
  );
END;
$$ LANGUAGE plpgsql STABLE;

-- Enable women-only mode (requires verification)
CREATE OR REPLACE FUNCTION enable_women_only_mode(p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_profile RECORD;
BEGIN
  SELECT * INTO v_profile FROM profiles WHERE id = p_user_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User profile not found';
  END IF;
  
  -- Must be female and verified
  IF v_profile.gender != 'female' OR v_profile.gender_verified != true THEN
    RETURN false;
  END IF;
  
  UPDATE profiles
  SET women_only_mode_enabled = true,
      women_only_mode_enabled_at = NOW()
  WHERE id = p_user_id;
  
  RETURN true;
END;
$$ LANGUAGE plpgsql;

-- Disable women-only mode
CREATE OR REPLACE FUNCTION disable_women_only_mode(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE profiles
  SET women_only_mode_enabled = false
  WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 8. HELPER VIEWS
-- ============================================================================

-- View of verified women (for admin/analytics)
CREATE OR REPLACE VIEW verified_women AS
SELECT 
  p.id as user_id,
  p.display_name as first_name,
  p.home_country,
  p.women_only_mode_enabled,
  p.women_only_mode_enabled_at,
  vr.created_at as verified_at,
  vr.expires_at as verification_expires_at
FROM profiles p
LEFT JOIN verification_records vr ON vr.user_id = p.id 
  AND vr.verification_type = 'gender' 
  AND vr.status = 'approved'
WHERE p.gender = 'female' AND p.gender_verified = true;

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE verification_records IS 'Onfido verification results for gender/age/identity verification';
COMMENT ON TABLE women_only_spaces IS 'Creator-controlled women-only groups for verified female users only';
COMMENT ON TABLE women_only_space_members IS 'Membership in women-only spaces with role and status tracking';
COMMENT ON TABLE gender_change_audit_log IS 'Immutable audit log of all gender changes for security';
COMMENT ON FUNCTION can_access_women_only_spaces IS 'Returns true if user is verified female and can access women-only spaces';
COMMENT ON FUNCTION enable_women_only_mode IS 'Enables women-only mode for verified female users only';
