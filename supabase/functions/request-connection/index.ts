// ============================================================
// SoloAdventurer — Edge Function: request-connection
//
// Request a connection with another traveler.
// Validates both users have active trips and no existing connection.
// Creates connection record with status='pending'.
// Triggers notification to recipient (stub).
//
// Called by: Authenticated users initiating a connection
// Deploy: supabase functions deploy request-connection
// ============================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

interface RequestBody {
  recipient_id: string       // User to connect with
  requester_trip_id?: string // Optional: specific trip that overlapped
  recipient_trip_id?: string // Optional: recipient's trip that overlapped
  activity_id?: string       // Optional: activity icebreaker
  message?: string           // Optional: introduction message (max 500 chars)
  overlap_start_date?: string
  overlap_end_date?: string
  overlap_days?: number
}

interface ConnectionRecord {
  id: string
  requester_id: string
  recipient_id: string
  status: string
  created_at: string
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

  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { 'Content-Type': 'application/json' }
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

    const requesterId = user.id
    console.log(`[request-connection] Request from user: ${requesterId}`)

    // Parse request body
    let body: RequestBody
    try {
      body = await req.json()
    } catch {
      return new Response(JSON.stringify({ error: 'Invalid JSON body' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Validate required fields
    if (!body.recipient_id) {
      return new Response(JSON.stringify({ error: 'recipient_id is required' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Prevent self-connection
    if (body.recipient_id === requesterId) {
      return new Response(JSON.stringify({ error: 'Cannot connect with yourself' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Validate message length
    if (body.message && body.message.length > 500) {
      return new Response(JSON.stringify({ error: 'Message must be 500 characters or less' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Check if requester has an active trip
    const { data: requesterTrips, error: tripsError } = await supabase
      .from('trips')
      .select('id, start_date, end_date')
      .eq('user_id', requesterId)
      .or('is_active.eq.true,is_public.eq.true')
      .limit(1)

    if (tripsError) {
      console.error('[request-connection] Error checking requester trips:', tripsError)
      return new Response(JSON.stringify({ error: 'Failed to verify your trips' }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    if (!requesterTrips || requesterTrips.length === 0) {
      return new Response(JSON.stringify({ 
        error: 'You need an active trip to request a connection' 
      }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Verify recipient exists and is active
    const { data: recipient, error: recipientError } = await supabase
      .from('profiles')
      .select('id, display_name, is_active')
      .eq('id', body.recipient_id)
      .single()

    if (recipientError || !recipient) {
      return new Response(JSON.stringify({ error: 'Recipient not found' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    if (!recipient.is_active) {
      return new Response(JSON.stringify({ error: 'Recipient account is not active' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Check for existing connection (pending or accepted)
    const { data: existingConnection, error: existingError } = await supabase
      .from('connections')
      .select('id, status')
      .or(`and(requester_id.eq.${requesterId},recipient_id.eq.${body.recipient_id}),and(requester_id.eq.${body.recipient_id},recipient_id.eq.${requesterId})`)
      .limit(1)
      .maybeSingle()

    if (existingError) {
      console.error('[request-connection] Error checking existing connection:', existingError)
      return new Response(JSON.stringify({ error: 'Failed to check existing connection' }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    if (existingConnection) {
      const statusMessage = {
        pending: 'A connection request already exists',
        accepted: 'You are already connected',
        declined: 'Previous connection was declined',
        blocked: 'Cannot request connection'
      }
      return new Response(JSON.stringify({ 
        error: statusMessage[existingConnection.status as keyof typeof statusMessage] || 'Connection already exists',
        status: existingConnection.status
      }), {
        status: 409,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Check if users are blocked
    const { data: blocked } = await supabase
      .rpc('are_users_blocked', {
        user_a: requesterId,
        user_b: body.recipient_id
      })

    if (blocked) {
      return new Response(JSON.stringify({ error: 'Cannot request connection with this user' }), {
        status: 403,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Create the connection
    const connectionData = {
      requester_id: requesterId,
      recipient_id: body.recipient_id,
      status: 'pending',
      requester_trip_id: body.requester_trip_id ?? null,
      recipient_trip_id: body.recipient_trip_id ?? null,
      activity_id: body.activity_id ?? null,
      overlap_start_date: body.overlap_start_date ?? null,
      overlap_end_date: body.overlap_end_date ?? null,
      overlap_days: body.overlap_days ?? null
    }

    const { data: connection, error: insertError } = await supabase
      .from('connections')
      .insert(connectionData)
      .select('id, requester_id, recipient_id, status, created_at')
      .single()

    if (insertError) {
      console.error('[request-connection] Error creating connection:', insertError)
      
      // Handle unique constraint violation (race condition)
      if (insertError.code === '23505') {
        return new Response(JSON.stringify({ 
          error: 'Connection request already exists' 
        }), {
          status: 409,
          headers: { 'Content-Type': 'application/json' }
        })
      }
      
      return new Response(JSON.stringify({ 
        error: 'Failed to create connection request' 
      }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    console.log(`[request-connection] Created connection ${connection.id}`)

    // Create notification for recipient (stub - can be enhanced with push/email)
    const { error: notifError } = await supabase
      .from('notifications')
      .insert({
        user_id: body.recipient_id,
        type: 'connection_request',
        actor_id: requesterId,
        object_id: connection.id,
        object_type: 'connection',
        body: `You have a new connection request`
      })

    if (notifError) {
      console.error('[request-connection] Failed to create notification:', notifError)
      // Don't fail the request, just log the error
    }

    // TODO: Send push notification via FCM/APNs
    // TODO: Send email notification if user has email notifications enabled

    return new Response(JSON.stringify({
      success: true,
      connection: {
        id: connection.id,
        status: connection.status,
        created_at: connection.created_at
      }
    }), {
      status: 201,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      }
    })

  } catch (err) {
    console.error('[request-connection] Unhandled error:', err)
    return new Response(JSON.stringify({ 
      error: 'Internal server error',
      details: err instanceof Error ? err.message : 'Unknown error'
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})
