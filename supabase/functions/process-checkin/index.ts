// ============================================================
// SoloAdventurer — Edge Function: process-checkin
//
// Purpose: Handle check-in creation, completion, and escalation
// - Create scheduled check-in
// - Mark check-in complete
// - Handle missed check-in escalation (alert contacts after 1hr)
//
// Called by Flutter client and scheduled pg_cron jobs
// Deploy: supabase functions deploy process-checkin
// ============================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

interface CreateCheckInRequest {
  scheduled_time: string
  deadline?: string
  location?: {
    latitude: number
    longitude: number
    accuracy?: number
    address?: string
    place_name?: string
  }
  status_message?: string
  notify_contact_ids?: string[]
  trip_id?: string
  trigger_type?: 'manual' | 'scheduledTime' | 'locationArrival' | 'locationDeparture'
}

interface CompleteCheckInRequest {
  check_in_id: string
  location: {
    latitude: number
    longitude: number
    accuracy?: number
    address?: string
    place_name?: string
  }
  status_message?: string
}

Deno.serve(async (req: Request) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, PUT, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
      }
    })
  }

  try {
    // Verify auth for user-initiated requests
    const authHeader = req.headers.get('authorization')
    const isSystemCall = req.headers.get('x-system-call') === 'true'
    
    let userId: string | null = null
    
    if (authHeader && !isSystemCall) {
      const token = authHeader.replace('Bearer ', '')
      const { data: { user }, error: authError } = await supabase.auth.getUser(token)
      
      if (authError || !user) {
        return new Response(JSON.stringify({ error: 'Invalid or expired token' }), {
          status: 401,
          headers: { 'Content-Type': 'application/json' }
        })
      }
      userId = user.id
    } else if (isSystemCall) {
      // System call from pg_cron - verify secret
      const systemSecret = req.headers.get('x-system-secret')
      if (systemSecret !== Deno.env.get('SYSTEM_SECRET')) {
        return new Response(JSON.stringify({ error: 'Invalid system secret' }), {
          status: 401,
          headers: { 'Content-Type': 'application/json' }
        })
      }
    } else {
      return new Response(JSON.stringify({ error: 'Missing authorization' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    const url = new URL(req.url)
    const action = url.searchParams.get('action') || req.headers.get('x-action')

    switch (action) {
      case 'create':
        return await handleCreateCheckIn(req, userId!)
      case 'complete':
        return await handleCompleteCheckIn(req, userId!)
      case 'escalate':
        return await handleEscalation()
      default:
        return new Response(JSON.stringify({ error: 'Invalid action' }), {
          status: 400,
          headers: { 'Content-Type': 'application/json' }
        })
    }

  } catch (err) {
    console.error('process-checkin error:', err)
    return new Response(JSON.stringify({ 
      error: err instanceof Error ? err.message : 'Internal server error' 
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})

// Create a new scheduled check-in
async function handleCreateCheckIn(req: Request, userId: string): Promise<Response> {
  const body: CreateCheckInRequest = await req.json()
  const { scheduled_time, deadline, location, status_message, notify_contact_ids, trip_id, trigger_type } = body

  // Validate required fields
  if (!scheduled_time) {
    return new Response(JSON.stringify({ error: 'scheduled_time is required' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' }
    })
  }

  // If no contacts specified, get all trusted contacts with check-in notifications enabled
  let contactIds = notify_contact_ids
  if (!contactIds || contactIds.length === 0) {
    const { data: contacts } = await supabase
      .from('trusted_contacts')
      .select('id')
      .eq('user_id', userId)
      .eq('is_active', true)
      .eq('receives_check_ins', true)
    
    contactIds = contacts?.map(c => c.id) || []
  }

  // Create check-in
  const checkInData: Record<string, unknown> = {
    user_id: userId,
    trigger_type: trigger_type || 'scheduledTime',
    status: 'scheduled',
    scheduled_time: new Date(scheduled_time).toISOString(),
    deadline: deadline ? new Date(deadline).toISOString() : null,
    status_message: status_message || null,
    notify_contact_ids: contactIds,
    trip_id: trip_id || null,
    alert_sent: false
  }

  if (location) {
    checkInData.location = {
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: location.accuracy || null,
      address: location.address || null,
      place_name: location.place_name || null,
      timestamp: new Date().toISOString()
    }
  }

  const { data: checkIn, error: insertError } = await supabase
    .from('check_ins')
    .insert(checkInData)
    .select()
    .single()

  if (insertError) {
    console.error('Failed to create check-in:', insertError)
    throw new Error('Failed to create check-in')
  }

  // Create reminder notification for the user
  await supabase.from('notifications').insert({
    user_id: userId,
    type: 'check_in_reminder',
    object_id: checkIn.id,
    object_type: 'check_in',
    body: `Check-in scheduled for ${new Date(scheduled_time).toLocaleString()}. Don't forget to check in!`,
    read: false
  })

  return new Response(JSON.stringify({
    success: true,
    check_in_id: checkIn.id,
    status: checkIn.status,
    scheduled_time: checkIn.scheduled_time,
    notified_contacts_count: contactIds.length
  }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  })
}

// Complete a check-in
async function handleCompleteCheckIn(req: Request, userId: string): Promise<Response> {
  const body: CompleteCheckInRequest = await req.json()
  const { check_in_id, location, status_message } = body

  if (!check_in_id) {
    return new Response(JSON.stringify({ error: 'check_in_id is required' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' }
    })
  }

  // Get the check-in
  const { data: existingCheckIn, error: fetchError } = await supabase
    .from('check_ins')
    .select('*')
    .eq('id', check_in_id)
    .eq('user_id', userId)
    .single()

  if (fetchError || !existingCheckIn) {
    return new Response(JSON.stringify({ error: 'Check-in not found' }), {
      status: 404,
      headers: { 'Content-Type': 'application/json' }
    })
  }

  if (existingCheckIn.status === 'completed') {
    return new Response(JSON.stringify({ error: 'Check-in already completed' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' }
    })
  }

  // Update check-in
  const { data: updatedCheckIn, error: updateError } = await supabase
    .from('check_ins')
    .update({
      status: 'completed',
      completed_at: new Date().toISOString(),
      location: {
        latitude: location.latitude,
        longitude: location.longitude,
        accuracy: location.accuracy || null,
        address: location.address || null,
        place_name: location.place_name || null,
        timestamp: new Date().toISOString()
      },
      status_message: status_message || existingCheckIn.status_message
    })
    .eq('id', check_in_id)
    .select()
    .single()

  if (updateError) {
    console.error('Failed to complete check-in:', updateError)
    throw new Error('Failed to complete check-in')
  }

  // Notify contacts that user is safe
  if (existingCheckIn.notify_contact_ids && existingCheckIn.notify_contact_ids.length > 0) {
    const notifications = existingCheckIn.notify_contact_ids.map((contactId: string) => ({
      user_id: userId,
      type: 'check_in_completed',
      object_id: check_in_id,
      object_type: 'check_in',
      body: status_message 
        ? `Check-in completed: "${status_message}"`
        : 'Check-in completed successfully',
      read: false
    }))

    await supabase.from('notifications').insert(notifications)
  }

  return new Response(JSON.stringify({
    success: true,
    check_in_id: updatedCheckIn.id,
    status: updatedCheckIn.status,
    completed_at: updatedCheckIn.completed_at
  }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  })
}

// Handle missed check-in escalation (called by pg_cron)
async function handleEscalation(): Promise<Response> {
  // Find check-ins that are overdue by more than 1 hour
  const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString()

  const { data: overdueCheckIns, error: fetchError } = await supabase
    .from('check_ins')
    .select('*')
    .eq('status', 'active')
    .lt('deadline', oneHourAgo)
    .eq('alert_sent', false)

  if (fetchError) {
    console.error('Failed to fetch overdue check-ins:', fetchError)
    throw new Error('Failed to fetch overdue check-ins')
  }

  if (!overdueCheckIns || overdueCheckIns.length === 0) {
    return new Response(JSON.stringify({ 
      success: true, 
      message: 'No overdue check-ins found' 
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    })
  }

  const escalationResults = []

  for (const checkIn of overdueCheckIns) {
    try {
      // Mark check-in as missed
      await supabase
        .from('check_ins')
        .update({ 
          status: 'missed',
          alert_sent: true,
          alert_sent_at: new Date().toISOString()
        })
        .eq('id', checkIn.id)

      // Create safety alert for missed check-in
      const { data: safetyAlert } = await supabase
        .from('safety_alerts')
        .insert({
          user_id: checkIn.user_id,
          alert_type: 'escalation',
          last_known_point: checkIn.location 
            ? `POINT(${checkIn.location.longitude} ${checkIn.location.latitude})`
            : null,
          last_known_at: new Date().toISOString(),
          sent_at: new Date().toISOString(),
          delivery_channel: 'push'
        })
        .select()
        .single()

      // Notify contacts about missed check-in
      if (checkIn.notify_contact_ids && checkIn.notify_contact_ids.length > 0) {
        const notifications = checkIn.notify_contact_ids.map((contactId: string) => ({
          user_id: checkIn.user_id,
          type: 'missed_check_in',
          object_id: checkIn.id,
          object_type: 'check_in',
          body: `Missed check-in: User failed to check in by the deadline. Last known location may be available.`,
          read: false
        }))

        await supabase.from('notifications').insert(notifications)
      }

      // Notify user that escalation has occurred
      await supabase.from('notifications').insert({
        user_id: checkIn.user_id,
        type: 'check_in_escalated',
        object_id: checkIn.id,
        object_type: 'check_in',
        body: `Your missed check-in has been escalated to your emergency contacts.`,
        read: false
      })

      escalationResults.push({
        check_in_id: checkIn.id,
        user_id: checkIn.user_id,
        status: 'escalated'
      })

    } catch (err) {
      console.error(`Failed to escalate check-in ${checkIn.id}:`, err)
      escalationResults.push({
        check_in_id: checkIn.id,
        user_id: checkIn.user_id,
        status: 'error',
        error: err instanceof Error ? err.message : 'Unknown error'
      })
    }
  }

  return new Response(JSON.stringify({
    success: true,
    escalated_count: escalationResults.filter(r => r.status === 'escalated').length,
    results: escalationResults
  }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  })
}
