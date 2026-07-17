-- ============================================================================
-- Story 0.7 — create `get_entries_near_location` (journal proximity RPC)
--
-- Both journal remote datasources have called this RPC since they were
-- written; it never existed. Signature matches the client exactly
-- (journal_remote_data_source_impl.dart:345): user_id / lat / lng / radius_km,
-- returning journal_entries rows (JournalEntryModel.fromJson parses them).
--
-- SECURITY INVOKER on purpose: journal_entries RLS (owner-only) applies to
-- the caller, and the explicit guard makes cross-user queries fail loudly
-- instead of silently returning nothing (the find_semantic_matches pattern,
-- 20260708090000). Distance uses PostGIS geography (installed since
-- 20250104000000) — correct meters on a sphere, not degree arithmetic.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_entries_near_location(
  user_id   uuid,
  lat       double precision,
  lng       double precision,
  radius_km double precision
)
RETURNS SETOF public.journal_entries
LANGUAGE plpgsql STABLE
SET search_path = public
AS $$
BEGIN
  IF user_id IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'get_entries_near_location: can only query your own entries'
      USING ERRCODE = 'P0001';
  END IF;

  RETURN QUERY
  SELECT je.*
    FROM public.journal_entries je
   WHERE je.user_id = get_entries_near_location.user_id
     AND je.latitude  IS NOT NULL
     AND je.longitude IS NOT NULL
     AND ST_DWithin(
           ST_SetSRID(ST_MakePoint(je.longitude::float8, je.latitude::float8), 4326)::geography,
           ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography,
           radius_km * 1000.0
         )
   ORDER BY ST_Distance(
           ST_SetSRID(ST_MakePoint(je.longitude::float8, je.latitude::float8), 4326)::geography,
           ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography
         );
END;
$$;

REVOKE EXECUTE ON FUNCTION public.get_entries_near_location(uuid, double precision, double precision, double precision) FROM anon, public;
GRANT  EXECUTE ON FUNCTION public.get_entries_near_location(uuid, double precision, double precision, double precision) TO authenticated, service_role;
