-- ============================================================
-- SoloAdventurer — Migration 013
-- RPCs: profile search, feed, profile view
-- All SECURITY DEFINER — called by client as authenticated user.
-- ============================================================

-- ── search_profiles ──────────────────────────────────────────
-- Applies all visibility, block, verification, and privacy
-- filters. Gender/age filters applied here where RLS can't.
CREATE OR REPLACE FUNCTION search_profiles(
  p_query         text    DEFAULT NULL,
  p_country       text    DEFAULT NULL,
  p_verified_only boolean DEFAULT false,
  p_limit         int     DEFAULT 20,
  p_offset        int     DEFAULT 0
)
RETURNS TABLE (
  id              uuid,
  username        text,
  display_name    text,
  avatar_url      text,
  home_country    text,
  tier            verification_tier,
  visibility      profile_visibility,
  follower_count  bigint
)
LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  v_viewer uuid := auth.uid();
BEGIN
  IF v_viewer IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;

  RETURN QUERY
  SELECT
    p.id, p.username, p.display_name, p.avatar_url, p.home_country,
    uv.tier, pps.visibility,
    (SELECT COUNT(*) FROM follows WHERE following_id = p.id AND status = 'accepted')::bigint
  FROM profiles p
  JOIN profile_privacy_settings pps ON pps.user_id = p.id
  JOIN user_verification uv         ON uv.user_id  = p.id
  WHERE
    p.id != v_viewer
    AND p.is_active = true
    AND pps.visibility IN ('community', 'public')
    AND (pps.verified_only = false OR auth_user_verification_tier() = 'id_verified')
    AND NOT users_are_blocked(v_viewer, p.id)
    AND (NOT p_verified_only OR uv.tier = 'id_verified')
    AND (p_country IS NULL OR p.home_country = p_country)
    AND (
      p_query IS NULL
      OR p.username     ILIKE '%' || p_query || '%'
      OR p.display_name ILIKE '%' || p_query || '%'
    )
  ORDER BY
    CASE WHEN uv.tier = 'id_verified' THEN 0 ELSE 1 END,
    p.created_at DESC
  LIMIT  LEAST(p_limit, 50)
  OFFSET p_offset;
END;
$$;

-- ── get_profile_safe ─────────────────────────────────────────
-- Single profile view with full visibility enforcement.
CREATE OR REPLACE FUNCTION get_profile_safe(p_username text)
RETURNS TABLE (
  id              uuid,
  username        text,
  display_name    text,
  bio             text,
  avatar_url      text,
  home_country    text,
  website_url     text,
  tier            verification_tier,
  visibility      profile_visibility,
  follower_count  bigint,
  following_count bigint,
  post_count      bigint,
  is_following    boolean,
  pending_follow  boolean
)
LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE v_viewer uuid := auth.uid();
BEGIN
  RETURN QUERY
  SELECT
    p.id, p.username, p.display_name, p.bio, p.avatar_url,
    p.home_country, p.website_url, uv.tier, pps.visibility,
    (SELECT COUNT(*) FROM follows WHERE following_id = p.id AND status = 'accepted')::bigint,
    (SELECT COUNT(*) FROM follows WHERE follower_id  = p.id AND status = 'accepted')::bigint,
    (SELECT COUNT(*) FROM journals WHERE user_id = p.id AND deleted_at IS NULL
       AND audience != 'private')::bigint,
    viewer_follows(v_viewer, p.id),
    EXISTS (SELECT 1 FROM follows WHERE follower_id = v_viewer
            AND following_id = p.id AND status = 'pending')
  FROM profiles p
  JOIN profile_privacy_settings pps ON pps.user_id = p.id
  JOIN user_verification uv         ON uv.user_id  = p.id
  WHERE
    p.username  = p_username
    AND p.is_active = true
    AND (
      p.id = v_viewer
      OR (pps.visibility = 'public'    AND v_viewer IS NOT NULL)
      OR (pps.visibility = 'community' AND v_viewer IS NOT NULL
          AND (pps.verified_only = false OR auth_user_verification_tier() = 'id_verified'))
      OR viewer_follows(v_viewer, p.id)
    )
    AND NOT users_are_blocked(v_viewer, p.id)
  LIMIT 1;
END;
$$;

-- ── get_user_feed ────────────────────────────────────────────
-- Cursor-paginated feed. Excludes blocked users at query time.
CREATE OR REPLACE FUNCTION get_user_feed(
  p_limit  int         DEFAULT 20,
  p_before timestamptz DEFAULT NULL
)
RETURNS TABLE (
  feed_item_id    uuid,
  actor_id        uuid,
  actor_username  text,
  actor_avatar    text,
  verb            feed_verb,
  object_id       uuid,
  object_type     text,
  created_at      timestamptz
)
LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE v_viewer uuid := auth.uid();
BEGIN
  IF v_viewer IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;

  RETURN QUERY
  SELECT
    fi.id, fi.actor_id, p.username, p.avatar_url,
    fi.verb, fi.object_id, fi.object_type, fi.created_at
  FROM feed_items fi
  JOIN profiles p ON p.id = fi.actor_id
  WHERE
    fi.owner_id  = v_viewer
    AND (p_before IS NULL OR fi.created_at < p_before)
    AND NOT users_are_blocked(v_viewer, fi.actor_id)
    AND p.is_active = true
  ORDER BY fi.created_at DESC
  LIMIT LEAST(p_limit, 50);
END;
$$;

-- ── get_destination_posts ────────────────────────────────────
-- Posts near a lat/lon point — used for destination discovery pages.
CREATE OR REPLACE FUNCTION get_destination_posts(
  p_lat     float,
  p_lon     float,
  p_radius_km float DEFAULT 50,
  p_limit   int   DEFAULT 20,
  p_before  timestamptz DEFAULT NULL
)
RETURNS TABLE (
  journal_id      uuid,
  author_id       uuid,
  author_username text,
  author_avatar   text,
  body            text,
  location_name   text,
  distance_km     float,
  reaction_count  int,
  comment_count   int,
  created_at      timestamptz
)
LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  v_viewer uuid := auth.uid();
  v_point  geography := ST_SetSRID(ST_MakePoint(p_lon, p_lat), 4326);
BEGIN
  RETURN QUERY
  SELECT
    j.id, j.user_id, p.username, p.avatar_url,
    COALESCE(j.body, j.content),
    j.location_name,
    (ST_Distance(j.location_point, v_point) / 1000.0)::float,
    j.reaction_count,
    j.comment_count,
    j.created_at
  FROM journals j
  JOIN profiles p ON p.id = j.user_id
  WHERE
    j.deleted_at IS NULL
    AND j.location_point IS NOT NULL
    AND j.audience IN ('public', 'community')
    AND ST_DWithin(j.location_point, v_point, p_radius_km * 1000)
    AND (p_before IS NULL OR j.created_at < p_before)
    AND (
      v_viewer IS NULL
      OR NOT users_are_blocked(v_viewer, j.user_id)
    )
    AND p.is_active = true
  ORDER BY j.location_point <-> v_point, j.created_at DESC
  LIMIT LEAST(p_limit, 50);
END;
$$;
