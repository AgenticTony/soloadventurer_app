// ============================================================
// SoloAdventurer — Edge Function: send-push-notification
//
// Sends push notifications via FCM HTTP v1 API (Android + iOS)
// Called by other Edge Functions or directly from client
//
// Deploy: supabase functions deploy send-push-notification
// Environment variables needed:
//   - FIREBASE_PROJECT_ID
//   - FIREBASE_CLIENT_EMAIL (from service account)
//   - FIREBASE_PRIVATE_KEY (from service account)
// ============================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

interface PushNotification {
  title: string
  body: string
  data?: Record<string, string>
  imageUrl?: string
}

interface TokenInfo {
  token: string
  platform: string
}

interface RequestBody {
  tokens: TokenInfo[]
  notification: PushNotification
  userId?: string
}

interface PushResult {
  token: string
  platform: string
  success: boolean
  error?: string
}

// Get OAuth2 access token using service account credentials
async function getAccessToken(): Promise<string> {
  const clientId = Deno.env.get('FIREBASE_CLIENT_EMAIL')!
  const privateKey = Deno.env.get('FIREBASE_PRIVATE_KEY')!.replace(/\\n/g, '\n')
  const projectId = Deno.env.get('FIREBASE_PROJECT_ID')!

  const now = Math.floor(Date.now() / 1000)
  const expiry = now + 3600 // 1 hour

  // Build JWT header and payload
  const header = base64url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }))
  const payload = base64url(JSON.stringify({
    iss: clientId,
    sub: clientId,
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: expiry,
    scope: 'https://www.googleapis.com/auth/firebase.messaging'
  }))

  const signInput = `${header}.${payload}`

  // Sign with RSA-SHA256
  const key = await crypto.subtle.importKey(
    'pkcs8',
    pemToDer(privateKey),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign']
  )

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    key,
    new TextEncoder().encode(signInput)
  )

  const jwt = `${signInput}.${base64url(signature)}`

  // Exchange JWT for access token
  const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`
  })

  const tokenData = await tokenResponse.json()
  if (!tokenData.access_token) {
    throw new Error(`Failed to get access token: ${JSON.stringify(tokenData)}`)
  }

  return tokenData.access_token
}

// Send via FCM HTTP v1 API (handles both Android and iOS)
async function sendFCMNotification(
  token: string,
  notification: PushNotification,
  accessToken: string
): Promise<{ success: boolean; error?: string }> {
  const projectId = Deno.env.get('FIREBASE_PROJECT_ID')

  if (!projectId) {
    console.warn('[send-push] FIREBASE_PROJECT_ID not configured')
    return { success: false, error: 'FCM not configured' }
  }

  try {
    const message: Record<string, unknown> = {
      token,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      android: {
        priority: 'high' as const,
        notification: {
          sound: 'default',
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
          channel_id: 'chat_messages',
        }
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
            'mutable-content': 1,
          }
        }
      },
      data: {
        ...notification.data,
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      }
    }

    if (notification.imageUrl) {
      (message.notification as Record<string, unknown>).image = notification.imageUrl
    }

    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ message })
      }
    )

    if (!response.ok) {
      const errorText = await response.text()
      console.error('[send-push] FCM v1 error:', response.status, errorText)

      // Check for invalid token errors
      if (errorText.includes('UNREGISTERED') ||
          errorText.includes('invalid-registration-token') ||
          response.status === 404) {
        return { success: false, error: 'Token invalid or unregistered' }
      }

      return { success: false, error: errorText }
    }

    return { success: true }
  } catch (err) {
    console.error('[send-push] FCM exception:', err)
    return { success: false, error: String(err) }
  }
}

// Helper: PEM to DER
function pemToDer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN.*?-----/g, '')
    .replace(/-----END.*?-----/g, '')
    .replace(/\s/g, '')
  const binary = atob(b64)
  const bytes = new Uint8Array(binary.length)
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i)
  }
  return bytes.buffer
}

// Helper: base64url encoding
function base64url(data: string | ArrayBuffer): string {
  let b64: string
  if (typeof data === 'string') {
    b64 = btoa(data)
  } else {
    const bytes = new Uint8Array(data)
    let binary = ''
    for (let i = 0; i < bytes.length; i++) {
      binary += String.fromCharCode(bytes[i])
    }
    b64 = btoa(binary)
  }
  return b64.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')
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
    // Verify authorization (service role or authenticated user)
    const authHeader = req.headers.get('authorization')
    const isInternalCall = authHeader?.includes(Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '')

    if (!isInternalCall) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    const body: RequestBody = await req.json()

    // Validate request
    if (!body.tokens || body.tokens.length === 0) {
      return new Response(JSON.stringify({ error: 'No tokens provided' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    if (!body.notification || !body.notification.title || !body.notification.body) {
      return new Response(JSON.stringify({ error: 'Notification title and body required' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    console.log(`[send-push] Sending to ${body.tokens.length} devices`)

    // Get OAuth2 access token once for all sends
    let accessToken: string
    try {
      accessToken = await getAccessToken()
    } catch (err) {
      console.error('[send-push] Failed to get access token:', err)
      return new Response(JSON.stringify({
        error: 'Failed to authenticate with FCM',
        details: err instanceof Error ? err.message : 'Unknown error'
      }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    const results: PushResult[] = []
    const invalidTokens: string[] = []

    // Send to each token via FCM v1 (handles both platforms)
    for (const tokenInfo of body.tokens) {
      const result = await sendFCMNotification(
        tokenInfo.token,
        body.notification,
        accessToken
      )

      results.push({
        token: tokenInfo.token,
        platform: tokenInfo.platform,
        success: result.success,
        error: result.error
      })

      // Track invalid tokens for cleanup
      if (!result.success && result.error?.includes('invalid')) {
        invalidTokens.push(tokenInfo.token)
      }
    }

    // Clean up invalid tokens
    if (invalidTokens.length > 0) {
      console.log(`[send-push] Cleaning up ${invalidTokens.length} invalid tokens`)
      await supabase
        .from('notification_tokens')
        .update({ is_active: false })
        .in('token', invalidTokens)
    }

    // Update last_used_at for successful sends
    const successfulTokens = results
      .filter(r => r.success)
      .map(r => r.token)

    if (successfulTokens.length > 0) {
      await supabase
        .from('notification_tokens')
        .update({ last_used_at: new Date().toISOString() })
        .in('token', successfulTokens)
    }

    const summary = {
      total: results.length,
      successful: results.filter(r => r.success).length,
      failed: results.filter(r => !r.success).length,
      invalid_tokens_cleaned: invalidTokens.length
    }

    console.log('[send-push] Summary:', summary)

    return new Response(JSON.stringify({
      success: true,
      summary,
      results
    }), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      }
    })

  } catch (err) {
    console.error('[send-push] Unhandled error:', err)
    return new Response(JSON.stringify({
      error: 'Internal server error',
      details: err instanceof Error ? err.message : 'Unknown error'
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})
