// ============================================================
// SoloAdventurer — Edge Function: generate-profile-embedding
//
// Generates a 384-dim embedding for a user's profile using
// Xenova/all-MiniLM-L6-v2 and stores it in profiles.profile_embedding.
//
// Called by: Internal triggers after profile updates
// Deploy: supabase functions deploy generate-profile-embedding
// ============================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { pipeline } from 'https://cdn.jsdelivr.net/npm/@xenova/transformers@2.17.2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

// Singleton pipeline — cached across warm invocations
let embedder: any = null

async function getEmbedder() {
  if (!embedder) {
    embedder = await pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2')
  }
  return embedder
}

interface Profile {
  display_name: string | null
  bio: string | null
  age_range: string | null
  gender: string | null
  travel_style: string | null
  personality_traits: string[] | null
  languages: string[] | null
  interests: string[] | null
  preferred_destinations: string[] | null
}

interface ActivityRow {
  activities: { name: string; category: string } | null
}

function buildProfileText(profile: Profile, activities: ActivityRow[]): string {
  const parts: string[] = []

  if (profile.age_range) parts.push(`Age range: ${profile.age_range}`)
  if (profile.gender) parts.push(`Gender: ${profile.gender}`)
  if (profile.personality_traits?.length) {
    parts.push(`Personality traits: ${profile.personality_traits.join(', ')}`)
  }
  if (profile.travel_style) parts.push(`Travel style: ${profile.travel_style}`)
  if (profile.bio) parts.push(profile.bio)
  if (profile.interests?.length) {
    parts.push(`Interests: ${profile.interests.join(', ')}`)
  }
  if (activities.length) {
    const actTexts = activities
      .filter((a) => a.activities)
      .map((a) => `${a.activities!.name} (${a.activities!.category})`)
    if (actTexts.length) parts.push(`Activities: ${actTexts.join(', ')}`)
  }
  if (profile.preferred_destinations?.length) {
    parts.push(`Preferred destinations: ${profile.preferred_destinations.join(', ')}`)
  }
  if (profile.languages?.length) {
    parts.push(`Languages: ${profile.languages.join(', ')}`)
  }

  return parts.join('. ')
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  try {
    const { user_id } = await req.json()

    if (!user_id || typeof user_id !== 'string') {
      return new Response(JSON.stringify({ error: 'Missing or invalid user_id' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Fetch profile
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select(
        'display_name, bio, age_range, gender, travel_style, personality_traits, languages, interests, preferred_destinations'
      )
      .eq('id', user_id)
      .single()

    if (profileError || !profile) {
      return new Response(
        JSON.stringify({ error: 'Profile not found', details: profileError?.message }),
        { status: 404, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Fetch user activities with activity details
    const { data: activities, error: activitiesError } = await supabase
      .from('user_activities')
      .select('activities(name, category)')
      .eq('user_id', user_id)

    if (activitiesError) {
      return new Response(
        JSON.stringify({ error: 'Failed to fetch activities', details: activitiesError.message }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Build profile text
    const profileText = buildProfileText(profile, activities || [])

    if (!profileText.trim()) {
      return new Response(
        JSON.stringify({ error: 'Profile is empty, cannot generate embedding' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Generate embedding
    const embedderPipeline = await getEmbedder()
    const output = await embedderPipeline(profileText, {
      pooling: 'mean',
      normalize: true,
    })

    const embedding = Array.from(output.data) as number[]

    // Store embedding
    const { error: updateError } = await supabase
      .from('profiles')
      .update({
        profile_embedding: embedding,
        embedding_updated_at: new Date().toISOString(),
      })
      .eq('id', user_id)

    if (updateError) {
      return new Response(
        JSON.stringify({ error: 'Failed to store embedding', details: updateError.message }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ success: true, dimensions: embedding.length }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    console.error('Embedding generation failed:', err)
    return new Response(
      JSON.stringify({ error: 'Internal server error', details: String(err) }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
