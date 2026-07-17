// ============================================================
// SoloAdventurer — Edge Function: delete-user-account
//
// Purpose: GDPR-grade account deletion (also an app-store requirement).
// The client (auth_remote_data_source_impl.dart) has invoked this function
// since the auth feature shipped, but it was never created — account
// deletion always failed (Story 0.7, found 2026-07-17 by the schema-ref
// ratchet's .invoke() check).
//
// Contract (defined by the existing client):
//   POST, caller's JWT in Authorization
//   → { success: true }  or  { error: string }
//
// What it does, in order:
//   1. Verifies the caller's JWT — a user can delete only themself.
//   2. Clears the two FKs that would block the cascade:
//      - reports.resolved_by → NULL  (the report survives; the resolver
//        reference does not)
//      - safety_alerts rows for the user → deleted. These are the only
//        no-cascade rows holding the user's data, and they contain
//        LOCATION POINTS — the erasure right outweighs the audit-log
//        design for personal location data. ⚠ policy call — see PR.
//   3. Deletes the user's storage objects (avatars, journal-photos,
//      journal-videos; all keyed `${userId}/...` by the upload services).
//   4. auth.admin.deleteUser(id) — cascades profiles and every
//      ON DELETE CASCADE table hanging off it.
//
// Deploy: supabase functions deploy delete-user-account
// ============================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

const USER_STORAGE_BUCKETS = ['avatars', 'journal-photos', 'journal-videos']

const json = (body: Record<string, unknown>, status: number) =>
  new Response(JSON.stringify(body), {
    status,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    }
  })

/** Removes every object under `${userId}/` in one bucket (paged). */
async function purgeBucketPrefix(bucket: string, userId: string): Promise<void> {
  // storage.list is not recursive; user content is flat under the prefix
  // (`${userId}/${fileName}` — see media_upload_service_impl / avatar upload).
  for (;;) {
    const { data: objects, error } = await supabase.storage
      .from(bucket)
      .list(userId, { limit: 100 })
    if (error) throw new Error(`list ${bucket}/${userId}: ${error.message}`)
    if (!objects || objects.length === 0) return

    const paths = objects.map((o) => `${userId}/${o.name}`)
    const { error: rmError } = await supabase.storage.from(bucket).remove(paths)
    if (rmError) throw new Error(`remove in ${bucket}: ${rmError.message}`)
    if (objects.length < 100) return
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers':
          'authorization, x-client-info, apikey, content-type'
      }
    })
  }

  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405)
  }

  try {
    const authHeader = req.headers.get('authorization')
    if (!authHeader) {
      return json({ error: 'Missing authorization header' }, 401)
    }

    const token = authHeader.replace('Bearer ', '')
    const {
      data: { user },
      error: authError
    } = await supabase.auth.getUser(token)

    if (authError || !user) {
      return json({ error: 'Invalid or expired token' }, 401)
    }

    // --- 1. Clear the two FKs that would block the profiles cascade -------
    const { error: reportsError } = await supabase
      .from('reports')
      .update({ resolved_by: null })
      .eq('resolved_by', user.id)
    if (reportsError) {
      throw new Error(`clearing reports.resolved_by: ${reportsError.message}`)
    }

    const { error: alertsError } = await supabase
      .from('safety_alerts')
      .delete()
      .eq('user_id', user.id)
    if (alertsError) {
      throw new Error(`deleting safety_alerts: ${alertsError.message}`)
    }

    // --- 2. Storage: the DB cascade does not touch storage objects --------
    for (const bucket of USER_STORAGE_BUCKETS) {
      await purgeBucketPrefix(bucket, user.id)
    }

    // --- 3. The deletion itself; cascades profiles + dependents -----------
    const { error: deleteError } = await supabase.auth.admin.deleteUser(user.id)
    if (deleteError) {
      throw new Error(`auth.admin.deleteUser: ${deleteError.message}`)
    }

    console.log(`[delete-user-account] deleted user ${user.id}`)
    return json({ success: true }, 200)
  } catch (err) {
    console.error('[delete-user-account] error:', err)
    return json(
      { error: err instanceof Error ? err.message : 'Internal server error' },
      500
    )
  }
})
