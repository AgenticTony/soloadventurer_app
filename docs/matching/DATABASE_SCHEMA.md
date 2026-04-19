# Database Schema: SoloAdventurer Matching Feature

**Version:** 1.0  
**Date:** 2026-04-01  
**Author:** CTO / Architecture Lead  
**Database:** PostgreSQL 15+ with PostGIS

---

## Overview

This schema supports the SoloAdventurer matching feature with:
- Trip management with spatial data
- Automatic matching based on geographic and temporal overlap
- Real-time messaging
- Women-only mode with server-side enforcement via RLS
- Offline-first sync support

---

## Core Tables

### 1. `users`

Stores user profile information and settings.

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  first_name TEXT NOT NULL,
  age_range TEXT NOT NULL CHECK (age_range IN ('18-24', '25-34', '35-44', '45-54', '55+')),
  home_country TEXT NOT NULL,  -- ISO 3166-1 alpha-2 code (e.g., 'US', 'DE')
  gender TEXT NOT NULL CHECK (gender IN ('male', 'female', 'non-binary', 'prefer-not-to-say')),
  avatar_url TEXT,
  women_only_mode_enabled BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- For gender change audit (security)
  gender_updated_at TIMESTAMPTZ,
  previous_gender TEXT,
  
  CONSTRAINT women_only_requires_female CHECK (
    women_only_mode_enabled = false 
    OR gender = 'female'
  )
);

-- Index for women-only mode queries
CREATE INDEX idx_users_gender ON users(gender) WHERE gender = 'female';
CREATE INDEX idx_users_women_only ON users(id) WHERE women_only_mode_enabled = true;

-- Trigger to track gender changes
CREATE OR REPLACE FUNCTION track_gender_change()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.gender IS DISTINCT FROM NEW.gender THEN
    NEW.gender_updated_at := NOW();
    NEW.previous_gender := OLD.gender;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_track_gender_change
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION track_gender_change();

-- Trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
```

**Notes:**
- `women_only_mode_enabled` can only be true if `gender = 'female'` (constraint enforced)
- Gender changes are tracked for audit purposes
- `age_range` is bucketized for privacy

---

### 2. `trips`

Stores user trips with destination and date range.

```sql
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE trips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Location data
  destination_name TEXT NOT NULL,  -- Human-readable (e.g., "Paris, France")
  location GEOGRAPHY(POINT, 4326) NOT NULL,  -- PostGIS point (lon, lat)
  location_precision TEXT NOT NULL DEFAULT 'city' CHECK (location_precision IN ('city', 'neighborhood', 'exact')),
  
  -- Date range
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  
  -- Status
  is_active BOOLEAN NOT NULL DEFAULT true,
  
  -- Metadata
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT valid_date_range CHECK (end_date >= start_date),
  CONSTRAINT valid_duration CHECK (end_date - start_date <= 90)  -- Max 90 days
);

-- Spatial index for matching queries (CRITICAL for performance)
CREATE INDEX idx_trips_location ON trips USING GIST(location);

-- Index for active trips queries
CREATE INDEX idx_trips_active ON trips(user_id, start_date, end_date) WHERE is_active = true;

-- Index for user's trips
CREATE INDEX idx_trips_user_id ON trips(user_id);

-- Trigger to auto-update updated_at
CREATE TRIGGER trigger_trips_updated_at
  BEFORE UPDATE ON trips
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Function to auto-archive expired trips (run daily via cron)
CREATE OR REPLACE FUNCTION archive_expired_trips()
RETURNS void AS $$
BEGIN
  UPDATE trips
  SET is_active = false
  WHERE is_active = true
    AND end_date < CURRENT_DATE;
END;
$$ LANGUAGE plpgsql;
```

**Notes:**
- `location` is stored as PostGIS GEOGRAPHY point (SRID 4326)
- `location_precision` allows future expansion for exact location sharing
- Trips auto-archive when end date passes
- Spatial index on `location` is **critical** for matching performance

---

### 3. `matches`

Tracks matches between users (derived from trip overlap).

```sql
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_a_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_b_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Match details
  match_type TEXT NOT NULL DEFAULT 'geographic_overlap',
  
  -- Overlap info (for relevance scoring)
  overlap_start_date DATE NOT NULL,
  overlap_end_date DATE NOT NULL,
  overlap_days INTEGER NOT NULL,
  
  -- Status
  is_active BOOLEAN NOT NULL DEFAULT true,
  
  -- Metadata
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT unique_match UNIQUE (user_a_id, user_b_id),
  CONSTRAINT no_self_match CHECK (user_a_id != user_b_id)
);

-- Index for finding user's matches
CREATE INDEX idx_matches_user_a ON matches(user_a_id) WHERE is_active = true;
CREATE INDEX idx_matches_user_b ON matches(user_b_id) WHERE is_active = true;

-- Index for match creation (find overlapping trips)
CREATE INDEX idx_matches_created_at ON matches(created_at DESC);
```

**Notes:**
- Matches are symmetric: if A matches B, B matches A
- Store as two rows or use a view to normalize (see below)
- `overlap_days` used for sorting matches by relevance

---

### 4. `user_activities`

Stores user's activity interests (for matching and suggestions).

```sql
CREATE TABLE activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,  -- e.g., "coffee", "hiking", "nightlife"
  category TEXT NOT NULL,  -- e.g., "food", "outdoor", "culture"
  icon TEXT,  -- Emoji or icon identifier
  is_location_specific BOOLEAN DEFAULT false,
  
  -- For location-specific activities (optional)
  location_restriction GEOGRAPHY(POLYGON, 4326),  -- e.g., hiking only in mountains
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Seed data
INSERT INTO activities (name, category, icon) VALUES
  ('coffee', 'food', '☕'),
  ('meal', 'food', '🍽️'),
  ('sightseeing', 'culture', '🏛️'),
  ('hiking', 'outdoor', '🥾'),
  ('nightlife', 'entertainment', '🎉'),
  ('museums', 'culture', '🎨'),
  ('beach', 'outdoor', '🏖️'),
  ('shopping', 'leisure', '🛍️');

CREATE TABLE user_activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  CONSTRAINT unique_user_activity UNIQUE (user_id, activity_id)
);

CREATE INDEX idx_user_activities_user ON user_activities(user_id);
```

---

### 5. `messages`

Stores 1:1 messages between matched users.

```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Message content
  content TEXT NOT NULL CHECK (char_length(content) <= 5000),
  
  -- Context (if message started from activity suggestion)
  activity_id UUID REFERENCES activities(id) ON DELETE SET NULL,
  
  -- Status
  sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  delivered_at TIMESTAMPTZ,
  read_at TIMESTAMPTZ,
  
  -- For offline sync
  client_created_at TIMESTAMPTZ  -- When client created message (may differ from sent_at)
);

-- Index for fetching conversation
CREATE INDEX idx_messages_match ON messages(match_id, sent_at DESC);

-- Index for user's conversations (receiver or sender)
CREATE INDEX idx_messages_sender ON messages(sender_id, sent_at DESC);
CREATE INDEX idx_messages_receiver ON messages(receiver_id, sent_at DESC);

-- Index for unread messages count
CREATE INDEX idx_messages_unread ON messages(receiver_id, read_at) 
  WHERE read_at IS NULL;
```

**Notes:**
- `client_created_at` supports offline sync (client-generated timestamp)
- `activity_id` tracks if message was initiated from activity suggestion
- 5000 character limit prevents abuse

---

### 6. `blocked_users`

Stores user blocks (safety feature).

```sql
CREATE TABLE blocked_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  CONSTRAINT unique_block UNIQUE (blocker_id, blocked_id),
  CONSTRAINT no_self_block CHECK (blocker_id != blocked_id)
);

CREATE INDEX idx_blocked_users_blocker ON blocked_users(blocker_id);
CREATE INDEX idx_blocked_users_blocked ON blocked_users(blocked_id);
```

---

## Row-Level Security (RLS) Policies

RLS is **critical** for security, especially women-only mode. All policies must be enforced server-side.

### Enable RLS on All Tables

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocked_users ENABLE ROW LEVEL SECURITY;
```

### Users Table Policies

```sql
-- Users can read their own profile
CREATE POLICY users_read_own ON users
  FOR SELECT
  USING (auth.uid() = id);

-- Users can read other users' basic info (for matches)
CREATE POLICY users_read_for_matching ON users
  FOR SELECT
  USING (
    -- Only if they have an active match
    EXISTS (
      SELECT 1 FROM matches m
      WHERE m.is_active = true
        AND (m.user_a_id = auth.uid() OR m.user_b_id = auth.uid())
        AND (m.user_a_id = users.id OR m.user_b_id = users.id)
    )
  );

-- Users can update their own profile
CREATE POLICY users_update_own ON users
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
```

### Trips Table Policies

```sql
-- Users can read their own trips
CREATE POLICY trips_read_own ON trips
  FOR SELECT
  USING (user_id = auth.uid());

-- Users can read trips of potential matches (with women-only filter)
CREATE POLICY trips_read_for_matching ON trips
  FOR SELECT
  USING (
    user_id != auth.uid()
    AND is_active = true
    AND EXISTS (
      -- Must have overlapping trip
      SELECT 1 FROM trips t
      WHERE t.user_id = auth.uid()
        AND t.is_active = true
        AND t.start_date <= trips.end_date
        AND t.end_date >= trips.start_date
        AND ST_DWithin(t.location, trips.location, 50000)  -- 50km
    )
    AND (
      -- Women-only mode filter
      NOT EXISTS (
        SELECT 1 FROM users u
        WHERE u.id = auth.uid() AND u.women_only_mode_enabled = true
      )
      OR EXISTS (
        SELECT 1 FROM users u
        WHERE u.id = trips.user_id AND u.gender = 'female'
      )
    )
  );

-- Users can create their own trips
CREATE POLICY trips_create_own ON trips
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Users can update their own trips
CREATE POLICY trips_update_own ON trips
  FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Users can delete their own trips
CREATE POLICY trips_delete_own ON trips
  FOR DELETE
  USING (user_id = auth.uid());
```

### Matches Table Policies

```sql
-- Users can read their own matches (user_a or user_b)
CREATE POLICY matches_read_own ON matches
  FOR SELECT
  USING (user_a_id = auth.uid() OR user_b_id = auth.uid());

-- Matches are created by system (Edge Function), not directly by users
-- No INSERT policy for authenticated users

-- Users can update their own matches (e.g., hide/unhide)
CREATE POLICY matches_update_own ON matches
  FOR UPDATE
  USING (user_a_id = auth.uid() OR user_b_id = auth.uid());
```

### Messages Table Policies

```sql
-- Users can read messages they sent or received
CREATE POLICY messages_read_own ON messages
  FOR SELECT
  USING (sender_id = auth.uid() OR receiver_id = auth.uid());

-- Users can send messages to their matches
CREATE POLICY messages_create_own ON messages
  FOR INSERT
  WITH CHECK (
    sender_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM matches m
      WHERE m.id = messages.match_id
        AND m.is_active = true
        AND (m.user_a_id = auth.uid() OR m.user_b_id = auth.uid())
    )
  );

-- Users can update message status (delivered_at, read_at) for messages they received
CREATE POLICY messages_update_received ON messages
  FOR UPDATE
  USING (receiver_id = auth.uid())
  WITH CHECK (receiver_id = auth.uid());
```

### Blocked Users Table Policies

```sql
-- Users can read their own blocks
CREATE POLICY blocked_read_own ON blocked_users
  FOR SELECT
  USING (blocker_id = auth.uid());

-- Users can block others
CREATE POLICY blocked_create_own ON blocked_users
  FOR INSERT
  WITH CHECK (blocker_id = auth.uid());

-- Users can unblock others
CREATE POLICY blocked_delete_own ON blocked_users
  FOR DELETE
  USING (blocker_id = auth.uid());
```

---

## Database Functions

### 1. `find_matches(user_id UUID)`

Find all potential matches for a user based on trip overlap.

```sql
CREATE OR REPLACE FUNCTION find_matches(p_user_id UUID)
RETURNS TABLE (
  user_id UUID,
  first_name TEXT,
  age_range TEXT,
  home_country TEXT,
  gender TEXT,
  trip_start_date DATE,
  trip_end_date DATE,
  overlap_days INTEGER,
  distance_meters FLOAT,
  destination_name TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    u.id,
    u.first_name,
    u.age_range,
    u.home_country,
    u.gender,
    t.start_date,
    t.end_date,
    (LEAST(t.end_date, mt.end_date) - GREATEST(t.start_date, mt.start_date))::INTEGER AS overlap_days,
    ST_Distance(t.location::geometry, mt.location::geometry) AS distance_meters,
    t.destination_name
  FROM trips t
  JOIN users u ON t.user_id = u.id
  CROSS JOIN LATERAL (
    SELECT * FROM trips
    WHERE user_id = p_user_id
      AND is_active = true
      AND start_date <= t.end_date
      AND end_date >= t.start_date
      AND ST_DWithin(location, t.location, 50000)  -- 50km
    LIMIT 1
  ) mt
  WHERE t.user_id != p_user_id
    AND t.is_active = true
    -- Women-only mode filter
    AND (
      NOT EXISTS (
        SELECT 1 FROM users
        WHERE id = p_user_id AND women_only_mode_enabled = true
      )
      OR u.gender = 'female'
    )
    -- Exclude blocked users
    AND NOT EXISTS (
      SELECT 1 FROM blocked_users
      WHERE blocker_id = p_user_id AND blocked_id = t.user_id
    )
    AND NOT EXISTS (
      SELECT 1 FROM blocked_users
      WHERE blocker_id = t.user_id AND blocked_id = p_user_id
    )
  ORDER BY
    overlap_days DESC,
    distance_meters ASC;
END;
$$ LANGUAGE plpgsql STABLE;
```

### 2. `create_or_update_match(user_a UUID, user_b UUID)`

Create a match between two users (called by Edge Function).

```sql
CREATE OR REPLACE FUNCTION create_or_update_match(
  p_user_a UUID,
  p_user_b UUID,
  p_overlap_start DATE,
  p_overlap_end DATE
)
RETURNS UUID AS $$
DECLARE
  v_match_id UUID;
  v_overlap_days INTEGER;
BEGIN
  v_overlap_days := (p_overlap_end - p_overlap_start)::INTEGER;
  
  INSERT INTO matches (
    user_a_id, 
    user_b_id, 
    overlap_start_date, 
    overlap_end_date, 
    overlap_days
  )
  VALUES (
    p_user_a, 
    p_user_b, 
    p_overlap_start, 
    p_overlap_end, 
    v_overlap_days
  )
  ON CONFLICT (user_a_id, user_b_id) DO UPDATE SET
    overlap_start_date = p_overlap_start,
    overlap_end_date = p_overlap_end,
    overlap_days = v_overlap_days,
    is_active = true,
    created_at = NOW()
  RETURNING id INTO v_match_id;
  
  RETURN v_match_id;
END;
$$ LANGUAGE plpgsql;
```

---

## Indexes Summary

### Critical for Performance

| Table | Index | Purpose |
|-------|-------|---------|
| `trips` | `idx_trips_location` (GIST) | Spatial matching queries |
| `trips` | `idx_trips_active` | Filter active trips |
| `matches` | `idx_matches_user_a`, `idx_matches_user_b` | Fetch user's matches |
| `messages` | `idx_messages_match` | Fetch conversation |
| `messages` | `idx_messages_unread` | Unread count |
| `users` | `idx_users_gender` | Women-only mode filter |

### Recommended for Analytics

| Table | Index | Purpose |
|-------|-------|---------|
| `trips` | `idx_trips_created_at` | Analytics, dashboards |
| `matches` | `idx_matches_created_at` | Analytics, dashboards |
| `messages` | `idx_messages_sent_at` | Analytics, dashboards |

---

## Migration Plan

### Phase 1: Core Tables (Week 1)
1. Create `users` table
2. Create `trips` table with PostGIS
3. Create spatial indexes
4. Test basic CRUD operations

### Phase 2: Matching (Week 2)
1. Create `matches` table
2. Create `find_matches()` function
3. Test matching algorithm with seed data
4. Benchmark performance with 10K+ trips

### Phase 3: Messaging (Week 3)
1. Create `messages` table
2. Set up RLS policies
3. Test with Supabase Realtime
4. Test offline sync scenarios

### Phase 4: Security Hardening (Week 4)
1. Implement all RLS policies
2. Test women-only mode enforcement
3. Security audit of policies
4. Penetration testing

---

## Performance Considerations

### Spatial Query Performance

- **GiST index** on `location` is critical for sub-second matching
- Use `ST_DWithin` instead of `ST_Distance` for radius queries (uses index)
- Test with realistic data volume (10K+ trips)

### RLS Policy Performance

- RLS adds overhead to queries (policy evaluation)
- Test RLS policies with `EXPLAIN ANALYZE`
- Consider materialized views for complex matching queries

### Realtime Performance

- Supabase Realtime uses PostgreSQL logical replication
- Only enable Realtime on `messages` table (not all tables)
- Use broadcast channels for messages, not postgres changes

---

## Backup & Recovery

### Supabase Automatic Backups

- Daily backups included in Pro plan
- Point-in-time recovery available
- Test restore procedure before launch

### Critical Data to Backup

- All tables (users, trips, matches, messages)
- PostGIS spatial indexes (rebuilt on restore)
- RLS policies (stored in pg_policy)

---

## Future Considerations

### Potential Schema Changes (Post-MVP)

1. **Group chats:** Add `group_chats` and `group_members` tables
2. **Meetup scheduling:** Add `meetups` table with time/location
3. **Reviews:** Add `user_reviews` table for trust building
4. **Verification:** Add `user_verifications` table (phone, ID, photo)

### Scalability

- Current schema supports 100K+ users
- May need partitioning for `messages` table at 1M+ users
- Consider read replicas for analytics queries

---

**Document Status:** ✅ Complete  
**Next Review:** After performance benchmarks  
**Approver:** CTO / Architecture Lead
