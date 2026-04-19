// ============================================================
// SoloAdventurer — Edge Function: process-safety-alert
//
// Triggered via Supabase Realtime webhook when meetup_checkins
// status transitions to 'alerted' or 'sos'.
//
// Sends SMS via Twilio + email via Resend to the trusted contact.
// Writes immutable record to safety_alerts.
// Sends in-app notification to the user.
//
// NEVER called directly by client — service_role only.
// Deploy: supabase functions deploy process-safety-alert
// ============================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

interface CheckinRecord {
  id: string
  user_id: string
  trusted_contact_id: string
  meetup_time: string
  location_name: string | null
  status: string
  last_known_point: unknown
  last_known_at: string | null
}

interface WebhookPayload {
  type: 'UPDATE'
  table: string
  record: CheckinRecord
  old_record: CheckinRecord
}

Deno.serve(async (req: Request) => {
  try {
    if (req.headers.get('x-webhook-secret') !== Deno.env.get('WEBHOOK_SECRET')) {
      return new Response('Unauthorized', { status: 401 })
    }

    const { record, old_record }: WebhookPayload = await req.json()

    if (record.status !== 'alerted' && record.status !== 'sos') {
      return new Response('Not an alert transition', { status: 200 })
    }
    if (old_record.status === record.status) {
      return new Response('No status change', { status: 200 })
    }

    const isSOSAlert = record.status === 'sos'

    // Load user profile (existing profiles table)
    const { data: user } = await supabase
      .from('profiles')
      .select('full_name, display_name, username')
      .eq('id', record.user_id)
      .single()

    const userName = user?.display_name || user?.full_name || user?.username || 'A traveller'

    // Load trusted contact (existing trusted_contacts table)
    // Phone/email may be in contact_phone_enc (encrypted) or legacy phone/email columns
    const { data: contact } = await supabase
      .from('trusted_contacts')
      .select('name, phone, email, contact_phone_enc, contact_email_enc')
      .eq('id', record.trusted_contact_id)
      .single()

    if (!contact) throw new Error('Trusted contact not found')

    // Prefer encrypted columns; fall back to legacy plaintext columns
    // In production, decrypt contact_phone_enc via Vault RPC
    const contactPhone = contact.phone    // TODO: decrypt contact_phone_enc when Vault is configured
    const contactEmail = contact.email    // TODO: decrypt contact_email_enc when Vault is configured
    const contactName  = contact.name

    const locationText = record.location_name
      ? `Last known location: ${record.location_name}`
      : 'No location was shared'

    const message = isSOSAlert
      ? `EMERGENCY: ${userName} has triggered an emergency alert on SoloAdventurer.\n\n${locationText}\n\nPlease contact them immediately and consider contacting emergency services.`
      : `Safety alert: ${userName} set a meetup check-in and has not confirmed they are safe.\n\n${locationText}\n\nPlease try to contact them to confirm they are safe.`

    const deliveryRefs: string[] = []

    if (contactPhone) {
      const ref = await sendSMS(contactPhone, message)
      deliveryRefs.push(`sms:${ref}`)
    }

    if (contactEmail) {
      const ref = await sendEmail(
        contactEmail, contactName,
        isSOSAlert ? `Emergency Alert — ${userName}` : `Safety Alert — ${userName}`,
        message, userName
      )
      deliveryRefs.push(`email:${ref}`)
    }

    // Write immutable audit record
    await supabase.from('safety_alerts').insert({
      checkin_id:       record.id,
      user_id:          record.user_id,
      alert_type:       isSOSAlert ? 'sos' : 'escalation',
      last_known_point: record.last_known_point,
      last_known_at:    record.last_known_at,
      delivery_channel: deliveryRefs.map(r => r.split(':')[0]).join(','),
      delivery_ref:     deliveryRefs.join('|'),
      sent_at:          new Date().toISOString()
    })

    // In-app notification to the user
    await supabase.from('notifications').insert({
      user_id:      record.user_id,
      type:         isSOSAlert ? 'sos_sent' : 'safety_alert_sent',
      object_id:    record.id,
      object_type:  'meetup_checkin',
      body:         isSOSAlert
        ? `Emergency alert sent to ${contactName}.`
        : `No check-in received. ${contactName} has been notified.`
    })

    return new Response(JSON.stringify({ ok: true, refs: deliveryRefs }), {
      headers: { 'Content-Type': 'application/json' }
    })

  } catch (err) {
    console.error('process-safety-alert error:', err)
    const errorMessage = err instanceof Error ? err.message : 'Internal server error'
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 500, headers: { 'Content-Type': 'application/json' }
    })
  }
})

async function sendSMS(to: string, body: string): Promise<string> {
  const sid   = Deno.env.get('TWILIO_ACCOUNT_SID')!
  const token = Deno.env.get('TWILIO_AUTH_TOKEN')!
  const from  = Deno.env.get('TWILIO_FROM_NUMBER')!

  const res  = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${sid}/Messages.json`, {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${btoa(`${sid}:${token}`)}`,
      'Content-Type':  'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({ To: to, From: from, Body: body })
  })
  const data = await res.json()
  if (!res.ok) throw new Error(`Twilio: ${data.message}`)
  return data.sid
}

async function sendEmail(
  to: string, toName: string, subject: string, text: string, travelerName: string
): Promise<string> {
  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${Deno.env.get('RESEND_API_KEY')!}`,
      'Content-Type':  'application/json'
    },
    body: JSON.stringify({
      from:    'SoloAdventurer Safety <safety@soloadventurer.com>',
      to:      [{ email: to, name: toName }],
      subject,
      text,
      html: `<div style="font-family:sans-serif;max-width:600px;margin:0 auto">
        <div style="background:#dc2626;color:#fff;padding:24px;border-radius:8px 8px 0 0">
          <h1 style="margin:0;font-size:20px">${subject}</h1>
        </div>
        <div style="background:#f9f9f9;padding:24px;border-radius:0 0 8px 8px">
          <p>Hi ${toName},</p>
          <p style="white-space:pre-line">${text}</p>
          <hr style="border:none;border-top:1px solid #e5e5e5;margin:24px 0"/>
          <p style="color:#666;font-size:13px">Sent by SoloAdventurer on behalf of ${travelerName},
          who listed you as a trusted safety contact.</p>
        </div>
      </div>`
    })
  })
  const data = await res.json()
  if (!res.ok) throw new Error(`Resend: ${JSON.stringify(data)}`)
  return data.id
}
