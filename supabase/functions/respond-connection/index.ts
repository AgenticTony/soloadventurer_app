// ============================================================
// SoloAdventurer — Edge Function: respond-connection
//
// Accept or decline a connection request.
// Validates connection exists and user is the recipient.
// Updates status to 'accepted' or 'declined'.
// If accepted, creates initial chat message to enable messaging.
//
// Called by: Authenticated users responding to connection requests
// Deploy: supabase functions deploy respond-connection
// ============================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

interface RequestBody {
  connection_id: string
  response: 'accept' | 'decline'
}

interface ConnectionRecord {
  id: string
  requester_id: string
  recipient_id: string
  status: string
  activity_id: string | null
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

    const userId = user.id
    console.log(`[respond-connection] Request from user: ${userId}`)

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
    if (!body.connection_id) {
      return new Response(JSON.stringify({ error: 'connection_id is required' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    if (!body.response || !['accept', 'decline'].includes(body.response)) {
      return new Response(JSON.stringify({ error: 'response must be "accept" or "decline"' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Fetch the connection
    const { data: connection, error: fetchError } = await supabase
      .from('connections')
      .select('id, requester_id, recipient_id, status, activity_id, created_at')
      .eq('id', body.connection_id)
      .single()

    if (fetchError || !connection) {
      console.error('[respond-connection] Error fetching connection:', fetchError)
      return new Response(JSON.stringify({ error: 'Connection not found' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Validate user is the recipient
    if (connection.recipient_id !== userId) {
      return new Response(JSON.stringify({ 
        error: 'Only the recipient can respond to this connection request' 
      }), {
        status: 403,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Validate connection is in pending state
    if (connection.status !== 'pending') {
      return new Response(JSON.stringify({ 
        error: `Connection already ${connection.status}`,
        current_status: connection.status
      }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    const newStatus = body.response === 'accept' ? 'accepted' : 'declined'
    console.log(`[respond-connection] Updating connection ${connection.id} to ${newStatus}`)

    // Update connection status
    const { data: updatedConnection, error: updateError } = await supabase
      .from('connections')
      .update({
        status: newStatus,
        responded_at: new Date().toISOString()
      })
      .eq('id', body.connection_id)
      .select('id, requester_id, recipient_id, status, responded_at, created_at')
      .single()

    if (updateError) {
      console.error('[respond-connection] Error updating connection:', updateError)
      return new Response(JSON.stringify({ error: 'Failed to update connection' }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // If accepted, create initial chat message and notifications
    if (newStatus === 'accepted') {
      console.log(`[respond-connection] Creating chat for connection ${connection.id}`)

      // Create a system welcome message in the messages table
      // This "initializes" the chat between the two users
      const { error: messageError } = await supabase
        .from('messages')
        .insert({
          connection_id: connection.id,
          sender_id: userId, // The acceptor is the "sender" of the acceptance
          receiver_id: connection.requester_id,
          content: 'Connection accepted! You can now message each other.',
          activity_id: connection.activity_id,
          sent_at: new Date().toISOString()
        })

      if (messageError) {
        console.error('[respond-connection] Error creating initial message:', messageError)
        // Don't fail the request, but log the error
      }

      // Create notification for the requester
      const { error: notifError } = await supabase
        .from('notifications')
        .insert({
          user_id: connection.requester_id,
          type: 'connection_accepted',
          actor_id: userId,
          object_id: connection.id,
          object_type: 'connection',
          body: `Your connection request was accepted!`
        })

      if (notifError) {
        console.error('[respond-connection] Failed to create notification:', notifError)
      }

      // TODO: Send push notification to requester
    } else {
      // Create notification for declined connection (optional - some apps don't notify on decline)
      const { error: notifError } = await supabase
        .from('notifications')
        .insert({
          user_id: connection.requester_id,
          type: 'connection_declined',
          actor_id: userId,
          object_id: connection.id,
          object_type: 'connection',
          body: `Your connection request was declined.`
        })

      if (notifError) {
        console.error('[respond-connection] Failed to create decline notification:', notifError)
      }
    }

    console.log(`[respond-connection] Successfully updated connection ${connection.id} to ${newStatus}`)

    return new Response(JSON.stringify({
      success: true,
      connection: {
        id: updatedConnection.id,
        requester_id: updatedConnection.requester_id,
        recipient_id: updatedConnection.recipient_id,
        status: updatedConnection.status,
        responded_at: updatedConnection.responded_at,
        created_at: updatedConnection.created_at
      }
    }), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      }
    })

  } catch (err) {
    console.error('[respond-connection] Unhandled error:', err)
    return new Response(JSON.stringify({ 
      error: 'Internal server error',
      details: err instanceof Error ? err.message : 'Unknown error'
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})
