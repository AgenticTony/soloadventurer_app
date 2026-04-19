// ============================================================
// SoloAdventurer — Edge Function: notify-new-match
//
// Triggered when a new connection is created.
// Creates in-app notification and optionally sends push notification.
//
// Called by: Database trigger or direct invocation
// Deploy: supabase functions deploy notify-new-match
// ============================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

interface ConnectionRecord {
  id: string
  requester_id: string
  recipient_id: string
  status: string
}

interface Profile {
  id: string
  first_name: string | null
}

interface NotificationToken {
  token: string
  platform: string
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
    const body = await req.json()
    
    // Support both webhook payload and direct invocation
    const connection: ConnectionRecord = body.record || body.connection || body
    
    console.log('[notify-new-match] Processing connection:', connection.id)

    // Validate required fields
    if (!connection.id || !connection.requester_id || !connection.recipient_id) {
      return new Response(JSON.stringify({ error: 'Missing connection data' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Only process pending connections (new match requests)
    if (connection.status !== 'pending') {
      return new Response(JSON.stringify({ 
        message: 'Connection not pending, skipping notification',
        status: connection.status 
      }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Get requester profile for notification content
    const { data: requesterProfile, error: profileError } = await supabase
      .from('profiles')
      .select('id, first_name')
      .eq('id', connection.requester_id)
      .single()

    if (profileError) {
      console.error('[notify-new-match] Error fetching requester profile:', profileError)
    }

    const requesterName = requesterProfile?.first_name || 'Someone'

    // Create in-app notification (handled by trigger, but we do it here too for redundancy)
    const { error: notifError } = await supabase
      .from('notifications')
      .upsert({
        user_id: connection.recipient_id,
        type: 'new_match',
        actor_id: connection.requester_id,
        object_id: connection.id,
        object_type: 'connection',
        body: `${requesterName} wants to connect with you!`,
        read: false
      }, {
        onConflict: 'user_id,object_id,object_type'
      })

    if (notifError) {
      console.error('[notify-new-match] Error creating notification:', notifError)
    }

    // Get recipient's notification tokens for push notification
    const { data: tokens, error: tokensError } = await supabase
      .from('notification_tokens')
      .select('token, platform')
      .eq('user_id', connection.recipient_id)
      .eq('is_active', true)

    if (tokensError) {
      console.error('[notify-new-match] Error fetching tokens:', tokensError)
    }

    // Send push notifications
    if (tokens && tokens.length > 0) {
      console.log(`[notify-new-match] Sending push to ${tokens.length} devices`)
      
      // Call the send-push-notification Edge Function
      const pushResponse = await fetch(`${Deno.env.get('SUPABASE_URL')}/functions/v1/send-push-notification`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')}`
        },
        body: JSON.stringify({
          tokens: tokens,
          notification: {
            title: 'New Travel Match! ✈️',
            body: `${requesterName} wants to connect with you!`,
            data: {
              type: 'new_match',
              connectionId: connection.id,
              requesterId: connection.requester_id
            }
          }
        })
      })

      if (!pushResponse.ok) {
        console.error('[notify-new-match] Push notification failed:', await pushResponse.text())
      }
    }

    console.log('[notify-new-match] Notification sent successfully')

    return new Response(JSON.stringify({ 
      success: true,
      notification_created: true,
      push_sent: tokens && tokens.length > 0
    }), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      }
    })

  } catch (err) {
    console.error('[notify-new-match] Unhandled error:', err)
    return new Response(JSON.stringify({ 
      error: 'Internal server error',
      details: err instanceof Error ? err.message : 'Unknown error'
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})
