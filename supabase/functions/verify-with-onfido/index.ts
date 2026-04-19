// ============================================================
// SoloAdventurer — Edge Function: verify-with-onfido
//
// Purpose: Verify user identity/gender using Onfido API
// - Accept document upload reference
// - Call Onfido API to create check
// - Store verification result
// - Update gender_verified in profiles table
//
// Called by Flutter client
// Deploy: supabase functions deploy verify-with-onfido
//
// Required env vars:
// - ONFIDO_API_TOKEN: Onfido API token
// - ONFIDO_WEBHOOK_SECRET: Secret for webhook verification
// ============================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

const ONFIDO_API_URL = 'https://api.onfido.com/v3.5'

interface StartVerificationRequest {
  verification_type: 'gender' | 'age' | 'identity'
  document_id?: string  // Onfido document ID if already uploaded
  selfie_id?: string    // Onfido selfie ID if already uploaded
}

interface OnfidoCheckResult {
  id: string
  status: string
  result: string
  breakdown?: {
    gender?: {
      result: string
      value?: string
    }
    date_of_birth?: {
      result: string
      value?: string
    }
  }
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

  // Handle Onfido webhook callbacks
  if (req.method === 'POST' && req.headers.get('x-onfido-signature')) {
    return await handleOnfidoWebhook(req)
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

    const body: StartVerificationRequest = await req.json()
    const { verification_type, document_id, selfie_id } = body

    if (!verification_type) {
      return new Response(JSON.stringify({ error: 'verification_type is required' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Get user profile
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('id, email, full_name, display_name')
      .eq('id', user.id)
      .single()

    if (profileError || !profile) {
      return new Response(JSON.stringify({ error: 'Profile not found' }), {
        status: 404,
      headers: { 'Content-Type': 'application/json' }
      })
    }

    // Create or get Onfido applicant
    const applicantId = await getOrCreateOnfidoApplicant(user.id, profile)

    // If document not provided, return upload instructions
    if (!document_id) {
      return new Response(JSON.stringify({
        success: true,
        requires_upload: true,
        applicant_id: applicantId,
        sdk_token: await generateSDKToken(applicantId),
        message: 'Please upload your document using the Onfido SDK'
      }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // Create verification record
    const { data: verificationRecord, error: insertError } = await supabase
      .from('verification_records')
      .insert({
        user_id: user.id,
        verification_type,
        status: 'pending'
      })
      .select()
      .single()

    if (insertError) {
      console.error('Failed to create verification record:', insertError)
      throw new Error('Failed to create verification record')
    }

    // Create Onfido check
    const checkConfig = buildCheckConfig(verification_type)
    const onfidoCheck = await createOnfidoCheck(applicantId, document_id, selfie_id, checkConfig)

    // Update verification record with Onfido check ID
    await supabase
      .from('verification_records')
      .update({
        onfido_check_id: onfidoCheck.id,
        status: 'in_review'
      })
      .eq('id', verificationRecord.id)

    return new Response(JSON.stringify({
      success: true,
      verification_id: verificationRecord.id,
      onfido_check_id: onfidoCheck.id,
      status: 'in_review',
      message: 'Verification check initiated. You will be notified when complete.'
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    })

  } catch (err) {
    console.error('verify-with-onfido error:', err)
    return new Response(JSON.stringify({ 
      error: err instanceof Error ? err.message : 'Internal server error' 
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})

// Get or create Onfido applicant
async function getOrCreateOnfidoApplicant(userId: string, profile: { id: string; email?: string; full_name?: string; display_name?: string }): Promise<string> {
  // Check if we already have an applicant ID stored
  const { data: existingVerification } = await supabase
    .from('verification_records')
    .select('onfido_check_id')
    .eq('user_id', userId)
    .eq('status', 'approved')
    .limit(1)
    .single()

  if (existingVerification?.onfido_check_id) {
    // We might want to reuse the applicant - for now, create new
  }

  // Create new Onfido applicant
  const response = await fetch(`${ONFIDO_API_URL}/applicants`, {
    method: 'POST',
    headers: {
      'Authorization': `Token token=${Deno.env.get('ONFIDO_API_TOKEN')}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      first_name: profile.display_name?.split(' ')[0] || profile.full_name?.split(' ')[0] || 'User',
      last_name: profile.display_name?.split(' ').slice(1).join(' ') || profile.full_name?.split(' ').slice(1).join(' ') || 'User',
      email: profile.email
    })
  })

  if (!response.ok) {
    const error = await response.json()
    console.error('Onfido applicant creation failed:', error)
    throw new Error('Failed to create verification applicant')
  }

  const applicant = await response.json()
  return applicant.id
}

// Generate SDK token for Onfido SDK
async function generateSDKToken(applicantId: string): Promise<string> {
  const response = await fetch(`${ONFIDO_API_URL}/sdk_token`, {
    method: 'POST',
    headers: {
      'Authorization': `Token token=${Deno.env.get('ONFIDO_API_TOKEN')}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      applicant_id: applicantId,
      application_id: 'com.soloadventurer.app'
    })
  })

  if (!response.ok) {
    const error = await response.json()
    console.error('SDK token generation failed:', error)
    throw new Error('Failed to generate SDK token')
  }

  const data = await response.json()
  return data.token
}

// Build check configuration based on verification type
function buildCheckConfig(verificationType: string): Record<string, unknown> {
  switch (verificationType) {
    case 'gender':
      return {
        report_names: ['document', 'facial_similarity_photo']
      }
    case 'age':
      return {
        report_names: ['document', 'facial_similarity_photo']
      }
    case 'identity':
      return {
        report_names: ['document', 'facial_similarity_photo', 'watchlist_standard']
      }
    default:
      return {
        report_names: ['document', 'facial_similarity_photo']
      }
  }
}

// Create Onfido check
async function createOnfidoCheck(
  applicantId: string, 
  documentId: string, 
  selfieId?: string,
  config: Record<string, unknown> = {}
): Promise<OnfidoCheckResult> {
  const checkData: Record<string, unknown> = {
    applicant_id: applicantId,
    ...config
  }

  if (documentId) {
    checkData.document_ids = [documentId]
  }

  if (selfieId) {
    checkData.report_names = [...(config.report_names as string[] || [])]
  }

  const response = await fetch(`${ONFIDO_API_URL}/checks`, {
    method: 'POST',
    headers: {
      'Authorization': `Token token=${Deno.env.get('ONFIDO_API_TOKEN')}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(checkData)
  })

  if (!response.ok) {
    const error = await response.json()
    console.error('Onfido check creation failed:', error)
    throw new Error('Failed to create verification check')
  }

  return await response.json()
}

// Handle Onfido webhook callbacks
async function handleOnfidoWebhook(req: Request): Promise<Response> {
  try {
    const payload = await req.json()
    
    // Verify webhook signature (simplified - in production, use proper signature verification)
    const signature = req.headers.get('x-onfido-signature')
    const webhookSecret = Deno.env.get('ONFIDO_WEBHOOK_SECRET')
    
    if (!signature || !webhookSecret) {
      console.error('Missing webhook signature or secret')
      return new Response('Unauthorized', { status: 401 })
    }

    const { payload: webhookData } = payload
    const { action, object, data } = webhookData

    // Handle check completion
    if (action === 'check.completed' || action === 'check.resumed') {
      const checkId = object.id
      const checkResult = data as OnfidoCheckResult

      // Get verification record
      const { data: verificationRecord } = await supabase
        .from('verification_records')
        .select('*')
        .eq('onfido_check_id', checkId)
        .single()

      if (!verificationRecord) {
        console.error('Verification record not found for check:', checkId)
        return new Response('Not found', { status: 404 })
      }

      // Update verification record with results
      const isApproved = checkResult.result === 'clear'
      const verifiedGender = extractGenderFromResult(checkResult)
      const verifiedDOB = extractDOBFromResult(checkResult)

      await supabase
        .from('verification_records')
        .update({
          status: isApproved ? 'approved' : 'declined',
          onfido_result: checkResult,
          onfido_breakdown: checkResult.breakdown,
          verified_gender: verifiedGender,
          verified_date_of_birth: verifiedDOB,
          reviewed_at: new Date().toISOString()
        })
        .eq('id', verificationRecord.id)

      // If gender verification approved, update profile
      if (isApproved && verificationRecord.verification_type === 'gender' && verifiedGender) {
        await supabase
          .from('profiles')
          .update({
            gender_verified: true,
            gender: verifiedGender.toLowerCase()
          })
          .eq('id', verificationRecord.user_id)

        // Notify user of successful verification
        await supabase.from('notifications').insert({
          user_id: verificationRecord.user_id,
          type: 'verification_approved',
          object_id: verificationRecord.id,
          object_type: 'verification',
          body: 'Your identity has been verified. Women-only mode is now available.',
          read: false
        })
      } else if (!isApproved) {
        // Notify user of declined verification
        await supabase.from('notifications').insert({
          user_id: verificationRecord.user_id,
          type: 'verification_declined',
          object_id: verificationRecord.id,
          object_type: 'verification',
          body: 'Your verification was declined. Please try again with a valid document.',
          read: false
        })
      }
    }

    return new Response('OK', { status: 200 })

  } catch (err) {
    console.error('Webhook handling error:', err)
    return new Response('Error', { status: 500 })
  }
}

// Extract gender from Onfido check result
function extractGenderFromResult(result: OnfidoCheckResult): string | null {
  if (result.breakdown?.gender?.value) {
    return result.breakdown.gender.value.toLowerCase()
  }
  return null
}

// Extract date of birth from Onfido check result
function extractDOBFromResult(result: OnfidoCheckResult): string | null {
  if (result.breakdown?.date_of_birth?.value) {
    return result.breakdown.date_of_birth.value
  }
  return null
}
