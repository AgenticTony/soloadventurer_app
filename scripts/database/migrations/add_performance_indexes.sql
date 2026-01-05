-- Performance Optimization Migration
-- Add database indexes for commonly queried fields to improve query performance
-- with large datasets (500+ activities, 1000+ photos, 200+ trips)
--
-- Migration: add_performance_indexes
-- Created: 2026-01-05
-- Author: SoloAdventurer Performance Optimization

-- ============================================================================
-- ACTIVITIES TABLE INDEXES
-- ============================================================================

-- Index for querying activities by trip and user (most common query pattern)
-- Supports: getActivitiesCursor, getActivitiesOffset, countActivities
-- Query pattern: WHERE tripId = ? AND userId = ?
CREATE INDEX IF NOT EXISTS idx_activities_trip_user
  ON activities(tripId, userId);

-- Index for querying user activities chronologically
-- Supports: getUpcomingActivities, getActivitiesInDateRange
-- Query pattern: WHERE userId = ? ORDER BY startDateTime
CREATE INDEX IF NOT EXISTS idx_activities_user_start_datetime
  ON activities(userId, startDateTime DESC)
  WHERE startDateTime IS NOT NULL;

-- Index for filtering by category and completion status
-- Supports: getActivitiesByCategory, getCompletedActivities, getPriorityActivities
-- Query pattern: WHERE tripId = ? AND category = ? AND isCompleted = ?
CREATE INDEX IF NOT EXISTS idx_activities_trip_category_completed
  ON activities(tripId, category, isCompleted);

-- Index for completed activities across all user's trips
-- Query pattern: WHERE userId = ? AND isCompleted = ?
CREATE INDEX IF NOT EXISTS idx_activities_user_completed
  ON activities(userId, isCompleted);

-- Index for priority activities
-- Query pattern: WHERE tripId = ? AND isPriority = ?
CREATE INDEX IF NOT EXISTS idx_activities_trip_priority
  ON activities(tripId, isPriority)
  WHERE isPriority = true;

-- Partial index for activities with scheduled time (most activities have this)
-- Optimizes queries filtering by date range
-- Query pattern: WHERE startDateTime >= ? AND startDateTime <= ?
CREATE INDEX IF NOT EXISTS idx_activities_start_datetime
  ON activities(startDateTime DESC)
  WHERE startDateTime IS NOT NULL;

-- Index for activity creation time sorting (for pagination fallback)
-- Query pattern: ORDER BY createdAt DESC
CREATE INDEX IF NOT EXISTS idx_activities_created_at
  ON activities(createdAt DESC);

-- Composite index for user's activities in a trip sorted by time
-- Supports most list view queries
-- Query pattern: WHERE userId = ? AND tripId = ? ORDER BY startDateTime ASC
CREATE INDEX IF NOT EXISTS idx_activities_user_trip_datetime
  ON activities(userId, tripId, startDateTime ASC);

-- ============================================================================
-- PHOTOS TABLE INDEXES
-- ============================================================================

-- Index for querying photos by trip (most common pattern)
-- Supports: photo gallery loading, trip photo counts
-- Query pattern: WHERE tripId = ?
CREATE INDEX IF NOT EXISTS idx_photos_trip
  ON photos(tripId);

-- Composite index for trip photos sorted by when they were taken
-- Supports: chronological photo display, time-based queries
-- Query pattern: WHERE tripId = ? ORDER BY takenAt DESC
CREATE INDEX IF NOT EXISTS idx_photos_trip_taken_at
  ON photos(tripId, takenAt DESC);

-- Index for photos with location data (for map features)
-- Query pattern: WHERE latitude IS NOT NULL AND longitude IS NOT NULL
CREATE INDEX IF NOT EXISTS idx_photos_location
  ON photos(tripId, latitude, longitude)
  WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- Index for photo creation time (for upload history)
-- Query pattern: ORDER BY createdAt DESC
CREATE INDEX IF NOT EXISTS idx_photos_created_at
  ON photos(createdAt DESC);

-- ============================================================================
-- TRIPS TABLE INDEXES
-- ============================================================================

-- Index for querying user trips (most common pattern)
-- Supports: getTripsCursor, getTripsOffset, countTrips
-- Query pattern: WHERE userId = ?
CREATE INDEX IF NOT EXISTS idx_trips_user
  ON trips(userId);

-- Composite index for user trips sorted by creation date
-- Supports: main trips list view
-- Query pattern: WHERE userId = ? ORDER BY createdAt DESC
CREATE INDEX IF NOT EXISTS idx_trips_user_created_at
  ON trips(userId, createdAt DESC);

-- Index for start date filtering (for upcoming/past trips)
-- Supports: getTripsInDateRange, upcoming trips queries
-- Query pattern: WHERE startDate >= ? AND startDate <= ?
CREATE INDEX IF NOT EXISTS idx_trips_start_date
  ON trips(startDate DESC);

-- Index for trip status filtering
-- Query pattern: WHERE userId = ? AND status = ?
CREATE INDEX IF NOT EXISTS idx_trips_user_status
  ON trips(userId, status);

-- Composite index for date range queries
-- Supports: finding trips within specific timeframes
-- Query pattern: WHERE userId = ? AND startDate >= ? AND endDate <= ?
CREATE INDEX IF NOT EXISTS idx_trips_user_dates
  ON trips(userId, startDate, endDate);

-- ============================================================================
-- INDEX USAGE NOTES
-- ============================================================================

-- 1. These indexes are optimized for the following query patterns:
--    - Pagination with cursor-based and offset-based methods
--    - Filtering by user ID (required for all multi-tenant queries)
--    - Filtering by trip ID (scope queries to specific trips)
--    - Chronological sorting (by startDateTime, takenAt, createdAt)
--    - Status filtering (completed, priority, upcoming)
--
-- 2. Index sizes will grow with data but provide significant performance gains:
--    - Activities: ~8 indexes for common query patterns
--    - Photos: ~4 indexes for gallery and map features
--    - Trips: ~5 indexes for list views and filtering
--
-- 3. Partial indexes (with WHERE clauses) save space and improve performance
--    by indexing only the most relevant rows (e.g., activities with scheduled time)
--
-- 4. Composite indexes support the most common multi-column filter patterns
--    and avoid the need for index intersection
--
-- 5. All indexes are created with IF NOT EXISTS to be safe for re-running

-- ============================================================================
-- PERFORMANCE EXPECTATIONS
-- ============================================================================

-- Before indexes (estimated):
-- - Activity list query: 500-1000ms for 500+ activities
-- - Photo gallery query: 300-600ms for 1000+ photos
-- - Trip list query: 100-300ms for 100+ trips
--
-- After indexes (expected):
-- - Activity list query: 10-50ms for 500+ activities (10-20x faster)
-- - Photo gallery query: 5-30ms for 1000+ photos (10-20x faster)
-- - Trip list query: 5-20ms for 100+ trips (5-15x faster)
--
-- Index maintenance overhead:
-- - Insert operations: +5-10ms per operation
-- - Update operations: +5-15ms per operation (if indexed fields change)
-- - Storage overhead: ~20-30% additional storage

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Run these queries to verify index creation and usage:

-- Check if indexes were created successfully:
-- SELECT
--   schemaname,
--   tablename,
--   indexname,
--   indexdef
-- FROM pg_indexes
-- WHERE tablename IN ('activities', 'photos', 'trips')
--   AND indexname LIKE 'idx_%'
-- ORDER BY tablename, indexname;

-- Check index sizes:
-- SELECT
--   schemaname,
--   tablename,
--   indexname,
--   pg_size_pretty(pg_relation_size(indexrelid::regclass)) AS size
-- FROM pg_stat_user_indexes
-- WHERE tablename IN ('activities', 'photos', 'trips')
--   AND indexname LIKE 'idx_%'
-- ORDER BY tablename, indexname;

-- Analyze query performance with EXPLAIN ANALYZE:
-- EXPLAIN ANALYZE
-- SELECT * FROM activities
-- WHERE tripId = 'trip123' AND userId = 'user123'
-- ORDER BY startDateTime ASC
-- LIMIT 20;
