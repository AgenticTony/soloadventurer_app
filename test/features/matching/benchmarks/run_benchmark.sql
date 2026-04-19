-- =============================================================================
-- SoloAdventurer Performance Benchmark
-- =============================================================================
-- 
-- This script generates test data and runs performance benchmarks for the
-- matching algorithm. Target: p95 < 2 seconds at 100K trips.
--
-- Prerequisites:
--   - PostgreSQL with PostGIS extension
--   - SoloAdventurer schema installed
--   - Test database with sufficient storage
--
-- Usage:
--   psql -U postgres -d soloadventurer_test -f run_benchmark.sql
-- =============================================================================

-- Configuration
-- Adjust these values based on your testing needs
\set trip_count 100000
\set user_count 50000
\set iterations 10

\timing on

-- =============================================================================
-- Step 1: Generate Test Data
-- =============================================================================

\echo ''
\echo '========================================='
\echo 'Step 1: Generating Test Data'
\echo '========================================='
\echo ''

-- Clear existing benchmark data
DELETE FROM trips WHERE id LIKE 'bench-trip-%';
DELETE FROM users WHERE id LIKE 'bench-user-%';

\echo "Generating :user_count users..."

-- Generate users
INSERT INTO users (id, email, first_name, gender, age_range, home_country, women_only_mode, created_at)
SELECT 
    'bench-user-' || i,
    'user' || i || '@benchmark.test',
    CASE (i % 15)
        WHEN 0 THEN 'Alex'
        WHEN 1 THEN 'Marcus'
        WHEN 2 THEN 'Priya'
        WHEN 3 THEN 'Emma'
        WHEN 4 THEN 'John'
        WHEN 5 THEN 'Sarah'
        WHEN 6 THEN 'David'
        WHEN 7 THEN 'Lisa'
        WHEN 8 THEN 'Michael'
        WHEN 9 THEN 'Anna'
        WHEN 10 THEN 'James'
        WHEN 11 THEN 'Maria'
        WHEN 12 THEN 'Robert'
        WHEN 13 THEN 'Sophie'
        ELSE 'Tom'
    END,
    CASE WHEN i % 3 = 0 THEN 'male' ELSE 'female' END,
    CASE (i % 7)
        WHEN 0 THEN '18-24'
        WHEN 1 THEN '25-30'
        WHEN 2 THEN '30-35'
        WHEN 3 THEN '35-40'
        WHEN 4 THEN '40-45'
        WHEN 5 THEN '45-50'
        ELSE '50+'
    END,
    CASE (i % 10)
        WHEN 0 THEN 'US'
        WHEN 1 THEN 'UK'
        WHEN 2 THEN 'DE'
        WHEN 3 THEN 'FR'
        WHEN 4 THEN 'IT'
        WHEN 5 THEN 'ES'
        WHEN 6 THEN 'AU'
        WHEN 7 THEN 'CA'
        WHEN 8 THEN 'JP'
        ELSE 'IN'
    END,
    (i % 20 = 0), -- 5% with women-only mode
    NOW() - (random() * 365 || ' days')::interval
FROM generate_series(1, :user_count::int) AS i;

\echo "Generated :user_count users"

\echo "Generating :trip_count trips..."

-- Generate trips with realistic distribution
INSERT INTO trips (id, user_id, destination, location, start_date, end_date, is_active, created_at)
SELECT 
    'bench-trip-' || i,
    'bench-user-' || ((i % :user_count::int) + 1),
    CASE (i % 15)
        WHEN 0 THEN 'Paris, France'
        WHEN 1 THEN 'London, UK'
        WHEN 2 THEN 'Berlin, Germany'
        WHEN 3 THEN 'Rome, Italy'
        WHEN 4 THEN 'Barcelona, Spain'
        WHEN 5 THEN 'Bangkok, Thailand'
        WHEN 6 THEN 'Tokyo, Japan'
        WHEN 7 THEN 'Singapore'
        WHEN 8 THEN 'Sydney, Australia'
        WHEN 9 THEN 'New York, USA'
        WHEN 10 THEN 'Amsterdam, Netherlands'
        WHEN 11 THEN 'Vienna, Austria'
        WHEN 12 THEN 'Prague, Czech Republic'
        WHEN 13 THEN 'Lisbon, Portugal'
        ELSE 'Dubrovnik, Croatia'
    END,
    ST_SetSRID(ST_MakePoint(
        CASE (i % 15)
            WHEN 0 THEN 2.3522   -- Paris
            WHEN 1 THEN -0.1276  -- London
            WHEN 2 THEN 13.4050  -- Berlin
            WHEN 3 THEN 12.4964  -- Rome
            WHEN 4 THEN 2.1734   -- Barcelona
            WHEN 5 THEN 100.5018 -- Bangkok
            WHEN 6 THEN 139.6917 -- Tokyo
            WHEN 7 THEN 103.8198 -- Singapore
            WHEN 8 THEN 151.2093 -- Sydney
            WHEN 9 THEN -74.0060 -- New York
            WHEN 10 THEN 4.9041  -- Amsterdam
            WHEN 11 THEN 16.3738 -- Vienna
            WHEN 12 THEN 14.4378 -- Prague
            WHEN 13 THEN -9.1393 -- Lisbon
            ELSE 18.0944         -- Dubrovnik
        END,
        CASE (i % 15)
            WHEN 0 THEN 48.8566
            WHEN 1 THEN 51.5074
            WHEN 2 THEN 52.5200
            WHEN 3 THEN 41.9028
            WHEN 4 THEN 41.3851
            WHEN 5 THEN 13.7563
            WHEN 6 THEN 35.6895
            WHEN 7 THEN 1.3521
            WHEN 8 THEN -33.8688
            WHEN 9 THEN 40.7128
            WHEN 10 THEN 52.3676
            WHEN 11 THEN 48.2082
            WHEN 12 THEN 50.0755
            WHEN 13 THEN 38.7223
            ELSE 42.6507
        END
    ), 4326),
    CURRENT_DATE + (i % 365),
    CURRENT_DATE + (i % 365) + (1 + (i % 90)),
    (i % 5 != 0), -- 80% active
    NOW() - (random() * 90 || ' days')::interval
FROM generate_series(1, :trip_count::int) AS i;

\echo "Generated :trip_count trips"

-- =============================================================================
-- Step 2: Verify Spatial Indexes
-- =============================================================================

\echo ''
\echo '========================================='
\echo 'Step 2: Verifying Spatial Indexes'
\echo '========================================='
\echo ''

-- Check if spatial index exists
SELECT 
    indexname, 
    indexdef 
FROM pg_indexes 
WHERE tablename = 'trips' 
AND indexname LIKE '%location%';

-- Create spatial index if not exists (should already exist from migrations)
CREATE INDEX IF NOT EXISTS idx_trips_location ON trips USING GIST (location);

-- Create additional indexes for performance
CREATE INDEX IF NOT EXISTS idx_trips_user_id ON trips(user_id);
CREATE INDEX IF NOT EXISTS idx_trips_dates ON trips(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_trips_active ON trips(is_active) WHERE is_active = true;

\echo "Spatial indexes verified"

-- =============================================================================
-- Step 3: Run Benchmark Tests
-- =============================================================================

\echo ''
\echo '========================================='
\echo 'Step 3: Running Benchmark Tests'
\echo '========================================='
\echo ''

-- Store results
CREATE TEMP TABLE benchmark_results (
    test_name TEXT,
    iteration INT,
    execution_time_ms FLOAT,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- BENCH-1: Single user match query
\echo ''
\echo 'BENCH-1: Single user match query at 100K trips'
\echo 'Target: <2000ms'
\echo ''

-- Pick a test user with a trip in Paris
DO $$
DECLARE
    test_user_id TEXT;
    test_trip RECORD;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    exec_time_ms FLOAT;
BEGIN
    SELECT user_id INTO test_user_id 
    FROM trips 
    WHERE destination = 'Paris, France' 
    AND is_active = true 
    LIMIT 1;
    
    FOR i IN 1..:iterations LOOP
        start_time := clock_timestamp();
        
        -- Execute match query
        PERFORM * FROM trips t
        WHERE t.user_id != test_user_id
        AND t.is_active = true
        AND ST_DWithin(t.location, ST_SetSRID(ST_MakePoint(2.3522, 48.8566), 4326)::geography, 50000)
        AND t.start_date <= CURRENT_DATE + 5
        AND t.end_date >= CURRENT_DATE
        ORDER BY ST_Distance(t.location, ST_SetSRID(ST_MakePoint(2.3522, 48.8566), 4326));
        
        end_time := clock_timestamp();
        exec_time_ms := EXTRACT(MILLISECONDS FROM end_time - start_time);
        
        INSERT INTO benchmark_results (test_name, iteration, execution_time_ms)
        VALUES ('BENCH-1', i, exec_time_ms);
        
        RAISE NOTICE 'BENCH-1 Iteration %: % ms', i, exec_time_ms;
    END LOOP;
END $$;

-- BENCH-2: Women-only match query
\echo ''
\echo 'BENCH-2: Match query with women-only filter'
\echo 'Target: <2500ms'
\echo ''

DO $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    exec_time_ms FLOAT;
BEGIN
    FOR i IN 1..:iterations LOOP
        start_time := clock_timestamp();
        
        -- Execute match query with women-only filter
        PERFORM t.*, u.gender
        FROM trips t
        JOIN users u ON t.user_id = u.id
        WHERE t.is_active = true
        AND u.gender = 'female'
        AND ST_DWithin(t.location, ST_SetSRID(ST_MakePoint(2.3522, 48.8566), 4326)::geography, 50000)
        AND t.start_date <= CURRENT_DATE + 5
        AND t.end_date >= CURRENT_DATE;
        
        end_time := clock_timestamp();
        exec_time_ms := EXTRACT(MILLISECONDS FROM end_time - start_time);
        
        INSERT INTO benchmark_results (test_name, iteration, execution_time_ms)
        VALUES ('BENCH-2', i, exec_time_ms);
        
        RAISE NOTICE 'BENCH-2 Iteration %: % ms', i, exec_time_ms;
    END LOOP;
END $$;

-- BENCH-3: Count total trips (baseline)
\echo ''
\echo 'BENCH-3: Count total trips (baseline)'
\echo ''

SELECT COUNT(*) as total_trips FROM trips;
SELECT COUNT(*) as active_trips FROM trips WHERE is_active = true;
SELECT COUNT(*) as total_users FROM users WHERE id LIKE 'bench-user-%';

-- =============================================================================
-- Step 4: Calculate Statistics
-- =============================================================================

\echo ''
\echo '========================================='
\echo 'Step 4: Benchmark Results Summary'
\echo '========================================='
\echo ''

SELECT 
    test_name,
    COUNT(*) as iterations,
    ROUND(AVG(execution_time_ms)::numeric, 2) as avg_ms,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY execution_time_ms)::numeric, 2) as p50_ms,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY execution_time_ms)::numeric, 2) as p95_ms,
    ROUND(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY execution_time_ms)::numeric, 2) as p99_ms,
    ROUND(MIN(execution_time_ms)::numeric, 2) as min_ms,
    ROUND(MAX(execution_time_ms)::numeric, 2) as max_ms
FROM benchmark_results
GROUP BY test_name
ORDER BY test_name;

-- =============================================================================
-- Step 5: Pass/Fail Report
-- =============================================================================

\echo ''
\echo '========================================='
\echo 'Step 5: Pass/Fail Report'
\echo '========================================='
\echo ''

SELECT 
    test_name,
    CASE 
        WHEN ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY execution_time_ms)::numeric, 2) < 2000 
        THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY execution_time_ms)::numeric, 2) as p95_ms,
    2000 as target_ms
FROM benchmark_results
GROUP BY test_name
ORDER BY test_name;

-- =============================================================================
-- Step 6: Cleanup (Optional)
-- =============================================================================

\echo ''
\echo '========================================='
\echo 'Step 6: Cleanup'
\echo '========================================='
\echo ''

\echo 'To clean up benchmark data, run:'
\echo '  DELETE FROM trips WHERE id LIKE '\''bench-trip-%'\'';'
\echo '  DELETE FROM users WHERE id LIKE '\''bench-user-%'\'';'
\echo ''
\echo 'To keep data for further testing, skip this step.'

-- Uncomment to auto-cleanup:
-- DELETE FROM trips WHERE id LIKE 'bench-trip-%';
-- DELETE FROM users WHERE id LIKE 'bench-user-%';

\echo ''
\echo '========================================='
\echo 'Benchmark Complete'
\echo '========================================='
