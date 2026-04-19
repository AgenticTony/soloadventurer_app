// ============================================================
// SoloAdventurer — Edge Function: find-overlapping-trips
//
// Finds travelers with overlapping trips for potential matching.
// Calls the find_potential_matches() RPC function.
// Respects women-only mode filtering.
//
// Called by: Authenticated users looking for travel buddies
// Deploy: supabase functions deploy find-overlapping-trips
// ============================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

interface PotentialMatch {
  user_id: string
  first_name: string
  age_range: string | null
  home_country: string | null
  gender: string | null
  gender_verified: boolean | null
  trip_id: string
  destination_name: string | null
  trip_start_date: string
  trip_end_date: string
  overlap_start_date: string
  overlap_end_date: string
  overlap_days: number
  distance_meters: number
  matching_activities: string[] | null
}

interface RequestBody {
  radius_meters?: number  // Default: 50000 (50km)
  limit?: number          // Default: 50, Max: 100
  offset?: number         // For pagination
}

Deno.serve(async (req: Request) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
      }
    })
  }

  try {
    // Validate authorization
    const authHeader = req.headers.get('authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Missing authorization header' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Extract user ID from JWT
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)
    
    if (authError || !user) {
      return new Response(JSON.stringify({ error: 'Invalid or expired token' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    const userId = user.id
    console.log(`[find-overlapping-trips] Request from user: ${userId}`)

    // Parse request body
    let body: RequestBody = {}
    try {
      const text = await req.text()
      if (text) {
        body = JSON.parse(text)
      }
    } catch {
      // Body is optional, use defaults
    }

    // Validate and clamp parameters
    const radiusMeters = Math.min(Math.max(body.radius_meters ?? 50000, 1000), 500000) // 1km - 500km
    const limit = Math.min(Math.max(body.limit ?? 50, 1), 100) // 1 - 100
    const offset = Math.max(body.offset ?? 0, 0)

    console.log(`[find-overlapping-trips] Params: radius=${radiusMeters}m, limit=${limit}, offset=${offset}`)

    // Check if user has women-only mode enabled
    const { data: userProfile, error: profileError } = await supabase
      .from('profiles')
      .select('women_only_mode_enabled')
      .eq('id', userId)
      .single()

    if (profileError) {
      console.error('[find-overlapping-trips] Error fetching user profile:', profileError)
      return new Response(JSON.stringify({ error: 'Failed to fetch user profile' }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    const womenOnlyMode = userProfile?.women_only_mode_enabled ?? false
    console.log(`[find-overlapping-trips] Women-only mode: ${womenOnlyMode}`)

    // Call the RPC function to find potential matches
    const { data: matches, error: rpcError } = await supabase
      .rpc('find_potential_matches', {
        p_user_id: userId,
        p_radius_meters: radiusMeters,
        p_limit: limit
      })

    if (rpcError) {
      console.error('[find-overlapping-trips] RPC error:', rpcError)
      return new Response(JSON.stringify({ 
        error: 'Failed to find potential matches',
        details: rpcError.message 
      }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Apply pagination (RPC handles limit, but we handle offset here)
    const paginatedMatches = (matches as PotentialMatch[])?.slice(offset, offset + limit) ?? []

    console.log(`[find-overlapping-trips] Found ${paginatedMatches.length} matches (total: ${matches?.length ?? 0})`)

    // Transform response for client
    const response = {
      matches: paginatedMatches.map(m => ({
        user: {
          id: m.user_id,
          display_name: m.first_name,
          age_range: m.age_range,
          home_country: m.home_country,
          gender: m.gender,
          gender_verified: m.gender_verified
        },
        trip: {
          id: m.trip_id,
          destination_name: m.destination_name,
          start_date: m.trip_start_date,
          end_date: m.trip_end_date
        },
        overlap: {
          start_date: m.overlap_start_date,
          end_date: m.overlap_end_date,
          days: m.overlap_days
        },
        distance_meters: Math.round(m.distance_meters),
        matching_activities: m.matching_activities ?? []
      })),
      pagination: {
        total: matches?.length ?? 0,
        limit,
        offset,
        has_more: (matches?.length ?? 0) > offset + limit
      },
      filters: {
        women_only_mode: womenOnlyMode,
        radius_meters: radiusMeters
      }
    }

    return new Response(JSON.stringify(response), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      }
    })

  } catch (err) {
    console.error('[find-overlapping-trips] Unhandled error:', err)
    return new Response(JSON.stringify({ 
      error: 'Internal server error',
      details: err instanceof Error ? err.message : 'Unknown error'
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})
