// ============================================================
// SoloAdventurer — Edge Function: trigger-sos
//
// Purpose: Trigger an emergency SOS alert
// - Creates SOS alert record
// - Notifies emergency contacts via notifications table
// - Returns alert ID for tracking
//
// Called directly by Flutter client
// Deploy: supabase functions deploy trigger-sos
// ============================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

interface SOSRequest {
  latitude: number
  longitude: number
  accuracy?: number
  altitude?: number
  address?: string
  message?: string
  battery_level?: number
  trip_id?: string
}

interface SOSAlert {
  id: string
  user_id: string
  status: string
  latitude: number
  longitude: number
  accuracy?: number
  altitude?: number
  address?: string
  message?: string
  battery_level?: number
  triggered_at: string
  notified_contact_ids: string[]
  acknowledged_contact_ids: string[]
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
    // Verify auth
    const authHeader = req.headers.get('authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Missing authorization header' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Get user from JWT
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)
    
    if (authError || !user) {
      return new Response(JSON.stringify({ error: 'Invalid or expired token' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    const body: SOSRequest = await req.json()
    const { latitude, longitude, accuracy, altitude, address, message, battery_level, trip_id } = body

    // Validate required fields
    if (typeof latitude !== 'number' || typeof longitude !== 'number') {
      return new Response(JSON.stringify({ error: 'Latitude and longitude are required' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Get trusted contacts with emergency alerts enabled
    const { data: contacts, error: contactsError } = await supabase
      .from('trusted_contacts')
      .select('id, name, phone, email')
      .eq('user_id', user.id)
      .eq('is_active', true)
      .eq('receives_emergency_alerts', true)

    if (contactsError) {
      console.error('Failed to fetch contacts:', contactsError)
      throw new Error('Failed to fetch emergency contacts')
    }

    const notifiedContactIds = contacts?.map(c => c.id) || []

    // Create SOS alert
    const { data: alert, error: insertError } = await supabase
      .from('sos_alerts')
      .insert({
        user_id: user.id,
        status: 'active',
        latitude,
        longitude,
        accuracy: accuracy || null,
        altitude: altitude || null,
        address: address || null,
        message: message || null,
        battery_level: battery_level || null,
        location_at: new Date().toISOString(),
        triggered_at: new Date().toISOString(),
        notified_contact_ids: notifiedContactIds,
        acknowledged_contact_ids: [],
        trip_id: trip_id || null
      })
      .select()
      .single()

    if (insertError) {
      console.error('Failed to create SOS alert:', insertError)
      throw new Error('Failed to create SOS alert')
    }

    // Create notifications for each emergency contact
    if (notifiedContactIds.length > 0) {
      const notifications = notifiedContactIds.map(contactId => ({
        user_id: user.id,
        type: 'emergency_sos',
        object_id: alert.id,
        object_type: 'sos_alert',
        body: message
          ? `Emergency alert: "${message}" - Location: ${latitude.toFixed(4)}, ${longitude.toFixed(4)}`
          : `Emergency alert triggered - Location: ${latitude.toFixed(4)}, ${longitude.toFixed(4)}`,
        read: false
      }))

      const { error: notifError } = await supabase
        .from('notifications')
        .insert(notifications)

      if (notifError) {
        console.error('Failed to create notifications:', notifError)
      }

      // Send push notifications to trusted contacts
      const { data: contactTokens, error: tokensError } = await supabase
        .from('notification_tokens')
        .select('token, platform, user_id')
        .in('user_id', contacts.map(c => c.user_id || c.id))
        .eq('is_active', true)

      if (tokensError) {
        console.error('Failed to fetch contact tokens:', tokensError)
      }

      if (contactTokens && contactTokens.length > 0) {
        try {
          await fetch(`${Deno.env.get('SUPABASE_URL')}/functions/v1/send-push-notification`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')}`
            },
            body: JSON.stringify({
              tokens: contactTokens.map((t: { token: string; platform: string }) => ({
                token: t.token,
                platform: t.platform
              })),
              notification: {
                title: '🆘 EMERGENCY SOS',
                body: message
                  ? `${user.email} needs help! "${message}" - Location: ${latitude.toFixed(4)}, ${longitude.toFixed(4)}`
                  : `${user.email} triggered an emergency SOS! Location: ${latitude.toFixed(4)}, ${longitude.toFixed(4)}`,
                data: {
                  type: 'emergency_sos',
                  alertId: alert.id,
                  latitude: String(latitude),
                  longitude: String(longitude)
                }
              }
            })
          })
          console.log(`[trigger-sos] Push sent to ${contactTokens.length} devices`)
        } catch (pushErr) {
          console.error('[trigger-sos] Push notification failed:', pushErr)
        }
      }
    }

    // Also update safety_alerts table for compatibility with existing safety infrastructure
    // This triggers the process-safety-alert webhook for SMS/email delivery
    const { error: safetyAlertError } = await supabase
      .from('safety_alerts')
      .insert({
        checkin_id: null, // Direct SOS, not from meetup_checkin
        user_id: user.id,
        alert_type: 'sos',
        last_known_point: `POINT(${longitude} ${latitude})`,
        last_known_at: new Date().toISOString(),
        sent_at: new Date().toISOString(),
        delivery_channel: 'push',
        delivery_ref: `sos_${alert.id}`
      })

    if (safetyAlertError) {
      console.error('Failed to create safety_alert record:', safetyAlertError)
      // Don't fail the request, the SOS alert was created
    }

    // Return the alert with tracking ID
    return new Response(JSON.stringify({
      success: true,
      alert_id: alert.id,
      status: alert.status,
      triggered_at: alert.triggered_at,
      notified_contacts_count: notifiedContactIds.length
    }), {
      status: 200,
      headers: { 
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      }
    })

  } catch (err) {
    console.error('trigger-sos error:', err)
    return new Response(JSON.stringify({ 
      error: err instanceof Error ? err.message : 'Internal server error' 
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})
