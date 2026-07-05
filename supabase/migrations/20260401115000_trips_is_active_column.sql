-- ============================================================
-- SoloAdventurer — trips.is_active ordering fix
--
-- ORDERING BUG (not a dashboard gap): 20260401_120000_matching_columns builds
-- partial indexes on trips.is_active (idx_trips_active_matching /
-- idx_trips_dates_matching), but the column is only added two migrations later
-- in 20260401_140000_spatial_indexes. Prod never hit this because its trips
-- table already had the column; a fresh local/CI `supabase start` dies with
-- SQLSTATE 42703 "column is_active does not exist". Add the bare column here;
-- backfill + DEFAULT stay in 20260401_140000 (its ADD COLUMN IF NOT EXISTS
-- becomes a no-op). No-op on prod. See issue #9 / PR #10.
-- ============================================================

ALTER TABLE trips ADD COLUMN IF NOT EXISTS is_active BOOLEAN;
