-- ============================================================================
-- Story 0.7 — create `travel_preferences` (offline-sync target)
--
-- The offline pipeline treats travel preferences as a first-class synced
-- entity (upload_sync insert/update, conflict_resolver merge rules,
-- EntityType.travelPreference) and the domain model is fully specified
-- (travel_preference.dart, 13 fields) — but the table was never created, so
-- every queued sync op failed. No UI writes preferences yet; this table gives
-- the already-built pipeline a real destination for when it does.
--
-- Shape mirrors the Freezed model field-for-field (snake_cased). One row per
-- user: the model is a profile-level preference set, and upload_sync updates
-- by id, so UNIQUE(user_id) keeps the pipeline idempotent.
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.travel_preferences (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               uuid NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
  travel_styles         text[] NOT NULL DEFAULT '{}',
  accommodation_types   text[] NOT NULL DEFAULT '{}',
  transportation_types  text[] NOT NULL DEFAULT '{}',
  min_budget            integer NOT NULL DEFAULT 0 CHECK (min_budget >= 0),
  max_budget            integer NOT NULL DEFAULT 0 CHECK (max_budget >= min_budget),
  min_trip_duration     integer NOT NULL DEFAULT 1 CHECK (min_trip_duration >= 1),
  max_trip_duration     integer NOT NULL DEFAULT 1 CHECK (max_trip_duration >= min_trip_duration),
  preferred_destinations text[] NOT NULL DEFAULT '{}',
  avoid_destinations    text[] NOT NULL DEFAULT '{}',
  is_flexible_dates     boolean NOT NULL DEFAULT true,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.travel_preferences ENABLE ROW LEVEL SECURITY;

-- Preferences are private matching input (L1 signal) — owner-only, all verbs.
CREATE POLICY travel_preferences_owner_all ON public.travel_preferences
  FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

COMMENT ON TABLE public.travel_preferences IS
  'Per-user travel preferences (offline-synced; matching input). Created 2026-07-17 — the sync pipeline wrote here since it was built but the table never existed (Story 0.7).';
