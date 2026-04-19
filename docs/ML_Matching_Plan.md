# SoloAdventurer — ML-Powered Matching with MiniLM Embeddings

> Status: **Planned** (not yet in development)
> Created: 2026-04-03
> Target Sprint: Post Sprint 3 (after test migration complete)
> Priority: "Could Have" — enhances matching quality, not blocking for MVP

---

## Overview

Replace/augment the current rule-based matching algorithm with semantic similarity matching using `sentence-transformers/all-MiniLM-L6-v2` embeddings. This enables matching travelers based on *meaning* rather than exact keyword overlap — "loves hiking and outdoor adventures" matches "enjoys mountain trekking and nature" even with zero word overlap.

---

## Why MiniLM

| Model | Dimensions | Params | Downloads | Best For |
|-------|-----------|--------|-----------|----------|
| `all-MiniLM-L6-v2` | 384 | 22.7M | 152M+ | **Our choice** — fast, high quality, small |
| `all-mpnet-base-v2` | 768 | 110M | 24.8M | Higher quality, slower |
| `BAAI/bge-large-en-v1.5` | 1024 | 335M | 8.2M | Best accuracy, heaviest |
| `BAAI/bge-m3` | 1024 | 568M | 8.2M | Multilingual (100+ languages) |

**Why MiniLM wins for us:**
- 384-dim embeddings = fast pgvector search, low storage
- Runs in Supabase Edge Function via `@xenova/transformers` (Deno/WASM)
- Zero external API calls = zero marginal cost
- 152M+ downloads = battle-tested in production
- Can upgrade to `bge-m3` later if multilingual matching is needed

---

## Alternative Models Considered

### Tier 2 — Fine-tune from profile-matching model
**`recruitco/embedding_criteria_profile_summary_matching_qa_minilm_v1`**
- Trained on 3.19M profile-to-criteria pairs (job matching)
- 0.96 Pearson cosine correlation on validation
- Same MiniLM backbone (384-dim)
- Fine-tune with traveler compatibility data: job criteria → travel preferences, candidate profiles → traveler profiles
- URL: https://huggingface.co/recruitco/embedding_criteria_profile_summary_matching_qa_minilm_v1

### Tier 3 — Custom two-tower model
**`chenbowen184/instacart-two-tower-sbert`** (architectural reference)
- Two-tower SBERT architecture for user-to-item matching
- Train dual-encoder: Tower A = traveler A profile, Tower B = traveler B profile
- Add structured features (budget overlap, destination overlap, date proximity)
- Use `bge-reranker-large` as cross-encoder to re-rank top-K matches
- URL: https://huggingface.co/chenbowen184/instacart-two-tower-sbert

### When to upgrade tiers:
- **Tier 1 (MiniLM out-of-the-box):** Ship immediately, no training data needed
- **Tier 2 (fine-tuned recruitco):** After collecting 1K+ swipe/rating data points
- **Tier 3 (custom two-tower):** After 10K+ labeled compatibility pairs

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter App                               │
│  matching_provider.dart → findMatches()                      │
│         │                                                    │
│         ▼                                                    │
│  Supabase Edge Function: find-potential-matches              │
│         │                                                    │
│         ├─► Step 1: pgvector candidate search (fast filter)  │
│         │    WHERE embedding <-> query_embedding < threshold  │
│         │    AND dates overlap                               │
│         │    AND gender/matching preferences satisfied        │
│         │                                                    │
│         ├─► Step 2: Re-rank with structured + semantic score  │
│         │    score = 0.4 * semantic_sim                      │
│         │         + 0.25 * date_overlap                      │
│         │         + 0.15 * activity_overlap                  │
│         │         + 0.1 * destination_similarity             │
│         │         + 0.1 * age_compatibility                  │
│         │                                                    │
│         └─► Step 3: Return top-K ranked matches              │
└─────────────────────────────────────────────────────────────┘

Embedding Generation (triggered on profile update):

┌──────────────────────────────────────────┐
│  Edge Function: generate-profile-embedding │
│                                             │
│  1. Fetch profile + activities + trips      │
│  2. Build rich text representation          │
│  3. Run @xenova/transformers MiniLM         │
│  4. Store 384-dim vector in profiles table  │
└──────────────────────────────────────────┘
```

---

## Implementation Details

### 1. Database Migration — pgvector + embeddings

```sql
-- Migration: add_profile_embeddings.sql

-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Add embedding column to profiles
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS profile_embedding vector(384);

-- Add embedding updated timestamp
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS embedding_updated_at TIMESTAMPTZ;

-- HNSW index for fast approximate nearest neighbor search
-- m=16, ef_construction=64 — good balance of speed/accuracy for 384-dim
CREATE INDEX IF NOT EXISTS idx_profiles_embedding
ON profiles USING hnsw (profile_embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- Partial index — only index profiles that have embeddings
CREATE INDEX IF NOT EXISTS idx_profiles_embedding_active
ON profiles USING hnsw (profile_embedding vector_cosine_ops)
WHERE profile_embedding IS NOT NULL
  AND id IN (SELECT user_id FROM trips WHERE is_active = true);

-- Function to find similar profiles using cosine distance
CREATE OR REPLACE FUNCTION find_semantic_matches(
  query_user_id UUID,
  match_threshold FLOAT DEFAULT 0.6,
  max_results INT DEFAULT 20
)
RETURNS TABLE (
  user_id UUID,
  display_name TEXT,
  avatar_url TEXT,
  semantic_score FLOAT,
  destination_name TEXT,
  start_date DATE,
  end_date DATE
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.id AS user_id,
    p.display_name,
    p.avatar_url,
    1 - (p.profile_embedding <=> (
      SELECT profile_embedding FROM profiles WHERE id = query_user_id
    )) AS semantic_score,
    t.destination_name,
    t.start_date,
    t.end_date
  FROM profiles p
  JOIN trips t ON t.user_id = p.id
  WHERE p.id != query_user_id
    AND p.profile_embedding IS NOT NULL
    AND t.is_active = true
    AND 1 - (p.profile_embedding <=> (
      SELECT profile_embedding FROM profiles WHERE id = query_user_id
    )) > match_threshold
  ORDER BY p.profile_embedding <=> (
    SELECT profile_embedding FROM profiles WHERE id = query_user_id
  )
  LIMIT max_results;
END;
$$ LANGUAGE plpgsql;
```

### 2. Edge Function: generate-profile-embedding

```typescript
// supabase/functions/generate-profile-embedding/index.ts

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
// @xenova/transformers runs MiniLM in Deno/WASM — no external API needed
import { pipeline } from 'https://cdn.jsdelivr.net/npm/@xenova/transformers@2.17.2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

// Singleton pipeline — cached across warm invocations
let embedder: any = null

async function getEmbedder() {
  if (!embedder) {
    embedder = await pipeline(
      'feature-extraction',
      'Xenova/all-MiniLM-L6-v2'
    )
  }
  return embedder
}

interface ProfileData {
  display_name: string
  bio: string
  age_range: string
  gender: string
  travel_style: string
  personality_traits: string[]
  languages: string[]
  interests: string[]
  preferred_destinations: string[]
  activities: { name: string; category: string }[]
}

function buildProfileText(profile: ProfileData): string {
  const parts: string[] = []

  // Demographics
  if (profile.age_range) parts.push(`${profile.age_range} ${profile.gender || 'traveler'}`)

  // Personality
  if (profile.personality_traits?.length) {
    parts.push(`Personality: ${profile.personality_traits.join(', ')}`)
  }

  // Travel style
  if (profile.travel_style) parts.push(`Travel style: ${profile.travel_style}`)

  // Bio (raw text — MiniLM understands natural language)
  if (profile.bio) parts.push(profile.bio)

  // Interests
  if (profile.interests?.length) {
    parts.push(`Interests: ${profile.interests.join(', ')}`)
  }

  // Activities
  if (profile.activities?.length) {
    const activityNames = profile.activities.map(a => a.name).join(', ')
    parts.push(`Activities enjoyed: ${activityNames}`)
  }

  // Destinations
  if (profile.preferred_destinations?.length) {
    parts.push(`Preferred destinations: ${profile.preferred_destinations.join(', ')}`)
  }

  // Languages
  if (profile.languages?.length) {
    parts.push(`Languages: ${profile.languages.join(', ')}`)
  }

  return parts.join('. ') + '.'
}

Deno.serve(async (req) => {
  const { user_id } = await req.json()

  // 1. Fetch profile + activities + preferences
  const { data: profile } = await supabase
    .from('profiles')
    .select('display_name, bio, age_range, gender, travel_style, personality_traits, languages, interests, preferred_destinations')
    .eq('id', user_id)
    .single()

  const { data: activities } = await supabase
    .from('user_activities')
    .select('activities(name, category)')
    .eq('user_id', user_id)

  // 2. Build rich text representation
  const profileText = buildProfileText({
    ...profile,
    activities: activities?.map((a: any) => a.activities) || []
  })

  // 3. Generate embedding
  const embedder = await getEmbedder()
  const output = await embedder(profileText, {
    pooling: 'mean',
    normalize: true,
  })

  // 4. Store embedding
  const embedding = Array.from(output.data)
  await supabase
    .from('profiles')
    .update({
      profile_embedding: embedding,
      embedding_updated_at: new Date().toISOString(),
    })
    .eq('id', user_id)

  return new Response(JSON.stringify({ success: true, dimensions: embedding.length }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

### 3. Edge Function: find-potential-matches (semantic + structured)

```typescript
// supabase/functions/find-potential-matches/index.ts

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

// Scoring weights
const WEIGHTS = {
  semantic:     0.40,  // Embedding cosine similarity
  date_overlap: 0.25,  // Trip date overlap percentage
  activities:   0.15,  // Shared activity interests
  destination:  0.10,  // Destination proximity/similarity
  age:          0.10,  // Age range compatibility
}

interface MatchCandidate {
  user_id: string
  display_name: string
  avatar_url: string
  bio: string
  age_range: string
  gender: string
  semantic_score: number
  trip_destination: string
  trip_start: string
  trip_end: string
  overlap_days: number
  shared_activities: string[]
  composite_score: number
}

Deno.serve(async (req) => {
  const { user_id, limit = 20 } = await req.json()

  // Step 1: Fast pgvector candidate search
  const { data: candidates } = await supabase.rpc('find_semantic_matches', {
    query_user_id: user_id,
    match_threshold: 0.5,
    max_results: 100,  // Over-fetch for re-ranking
  })

  if (!candidates?.length) {
    return new Response(JSON.stringify({ matches: [] }), {
      headers: { 'Content-Type': 'application/json' },
    })
  }

  // Step 2: Enrich with structured data
  const candidateIds = candidates.map((c: any) => c.user_id)

  // Fetch requestor's data
  const { data: requestor } = await supabase
    .from('profiles')
    .select('age_range, gender')
    .eq('id', user_id)
    .single()

  const { data: requestorActivities } = await supabase
    .from('user_activities')
    .select('activity_id')
    .eq('user_id', user_id)

  const { data: requestorTrips } = await supabase
    .from('trips')
    .select('start_date, end_date, destination_name')
    .eq('user_id', user_id)
    .eq('is_active', true)

  // Fetch candidate activities
  const { data: candidateActivities } = await supabase
    .from('user_activities')
    .select('user_id, activity_id')
    .in('user_id', candidateIds)

  // Step 3: Compute composite scores
  const requestorActivityIds = new Set(requestorActivities?.map((a: any) => a.activity_id) || [])
  const requestorStart = requestorTrips?.[0]?.start_date
  const requestorEnd = requestorTrips?.[0]?.end_date
  const requestorTripDays = requestorStart && requestorEnd
    ? (new Date(requestorEnd).getTime() - new Date(requestorStart).getTime()) / (1000 * 60 * 60 * 24)
    : 0

  const scored: MatchCandidate[] = candidates.map((c: any) => {
    // Semantic score (from pgvector)
    const semanticScore = c.semantic_score

    // Date overlap score
    let dateOverlapScore = 0
    if (requestorStart && requestorEnd && c.start_date && c.end_date) {
      const overlapStart = Math.max(new Date(requestorStart).getTime(), new Date(c.start_date).getTime())
      const overlapEnd = Math.min(new Date(requestorEnd).getTime(), new Date(c.end_date).getTime())
      const overlapDays = Math.max(0, (overlapEnd - overlapStart) / (1000 * 60 * 60 * 24))
      dateOverlapScore = requestorTripDays > 0 ? Math.min(overlapDays / requestorTripDays, 1) : 0
    }

    // Activity overlap score
    const candidateActs = (candidateActivities || [])
      .filter((a: any) => a.user_id === c.user_id)
      .map((a: any) => a.activity_id)
    const sharedActs = candidateActs.filter((id: string) => requestorActivityIds.has(id))
    const activityScore = requestorActivityIds.size > 0
      ? sharedActs.length / Math.max(requestorActivityIds.size, candidateActs.length)
      : 0

    // Destination score (same destination = 1.0, same country = 0.5, else 0.2)
    const destScore = c.destination_name === requestorTrips?.[0]?.destination_name
      ? 1.0
      : 0.2

    // Age compatibility (same range = 1.0, adjacent = 0.7, else 0.3)
    const ageScore = c.age_range === requestor?.age_range ? 1.0 : 0.5

    // Composite score
    const compositeScore =
      WEIGHTS.semantic * semanticScore +
      WEIGHTS.date_overlap * dateOverlapScore +
      WEIGHTS.activities * activityScore +
      WEIGHTS.destination * destScore +
      WEIGHTS.age * ageScore

    return {
      user_id: c.user_id,
      display_name: c.display_name,
      avatar_url: c.avatar_url,
      bio: c.bio || '',
      age_range: c.age_range || '',
      gender: c.gender || '',
      semantic_score: Math.round(semanticScore * 100) / 100,
      trip_destination: c.destination_name || '',
      trip_start: c.start_date,
      trip_end: c.end_date,
      overlap_days: c.overlap_days || 0,
      shared_activities: sharedActs,
      composite_score: Math.round(compositeScore * 100) / 100,
    }
  })

  // Step 4: Sort by composite score, return top-K
  scored.sort((a, b) => b.composite_score - a.composite_score)
  const matches = scored.slice(0, limit)

  return new Response(JSON.stringify({ matches }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

### 4. Flutter Side — Minimal Wiring

```dart
// Changes to matching_remote_data_source_impl.dart

// In findMatches(), replace RPC call:
Future<List<Connection>> findMatches() async {
  // OLD: await _client.rpc('find_potential_matches', params: {})
  // NEW: Call Edge Function
  final response = await _client.functions.invoke(
    'find-potential-matches',
    body: {'user_id': _currentUserId, 'limit': 20},
  );

  return (response.data['matches'] as List)
      .map((m) => ConnectionModel.fromMatchingJson(m))
      .toList();
}

// Trigger embedding generation on profile update:
Future<void> updateProfile(Map<String, dynamic> updates) async {
  await _client.from('profiles').update(updates).eq('id', _currentUserId);

  // Regenerate embedding in background
  _client.functions.invoke(
    'generate-profile-embedding',
    body: {'user_id': _currentUserId},
  );
}
```

### 5. Connection Entity — Add matchScore

```dart
// Add to connection.dart / connection_model.dart
class Connection {
  final String id;
  final String userId;
  final String displayName;
  // ... existing fields ...

  final double? matchScore;       // NEW: composite ML score (0.0-1.0)
  final double? semanticScore;    // NEW: pure semantic similarity
  final int? sharedActivityCount; // NEW: number of shared activities

  // Display helper
  String get matchPercentage => matchScore != null
    ? '${(matchScore! * 100).round()}%'
    : 'New';
}
```

---

## Profile Embedding Format

Each traveler profile is serialized into a rich text string before embedding:

```
"28-year-old female. Personality: outgoing, spontaneous, adventurous.
Travel style: budget backpacking. Love exploring hidden gems and local
street food. Interests: hiking, photography, street food, cultural
immersion. Activities enjoyed: hiking, photography, coffee, sightseeing,
beach. Preferred destinations: Southeast Asia, South America. Languages:
English, basic Spanish."
```

This format captures:
- Demographics (age, gender)
- Personality traits
- Travel style
- Free-text bio (raw natural language)
- Structured interests and activities
- Destination preferences
- Language capabilities

MiniLM encodes all of this into a single 384-dim vector that captures *semantic meaning* — not just keywords.

---

## Scoring Breakdown

| Signal | Weight | Source | Description |
|--------|--------|--------|-------------|
| Semantic similarity | 40% | MiniLM embedding + cosine | Overall profile compatibility |
| Date overlap | 25% | Trip start/end dates | % of trip dates that overlap |
| Activity overlap | 15% | user_activities join | Jaccard similarity of activity IDs |
| Destination match | 10% | Trip destination_name | Same destination = 1.0, else 0.2 |
| Age compatibility | 10% | Profile age_range | Same range = 1.0, adjacent = 0.7 |

Weights are configurable — tune based on user feedback and match acceptance rates.

---

## Trigger Strategy — When to Generate Embeddings

| Event | Action |
|-------|--------|
| User creates/updates profile | Regenerate embedding |
| User adds/removes activities | Regenerate embedding |
| User updates travel preferences | Regenerate embedding |
| User creates new active trip | Regenerate embedding (captures new destination) |
| Daily cron (optional) | Regenerate stale embeddings (>7 days old) |

Embedding generation is async and non-blocking — profile update returns immediately, embedding generates in background.

---

## Performance Characteristics

| Metric | Value |
|--------|-------|
| Embedding generation | ~100ms per profile (MiniLM inference) |
| Similarity search (pgvector HNSW) | ~5ms for 100K profiles |
| Edge Function cold start | ~2s (model download on first call) |
| Edge Function warm call | ~150ms total |
| Storage per embedding | 384 floats × 4 bytes = 1.5 KB |
| Storage for 1M profiles | ~1.5 GB |
| Cost | $0 — no external API calls |

---

## Effort Estimate

| Task | Size | Description |
|------|------|-------------|
| pgvector migration | Small | Add extension, column, index, RPC function |
| `generate-profile-embedding` Edge Function | Medium | Profile text builder + @xenova/transformers |
| `find-potential-matches` Edge Function | Medium | pgvector search + composite scoring |
| Flutter wiring | Small | Point findMatches() to new Edge Function |
| Connection entity update | Small | Add matchScore fields |
| Testing | Medium | Unit tests for scoring, integration tests for E2E |
| **Total** | **~1 sprint** | |

---

## Upgrade Path

```
Tier 1 (now)           Tier 2 (after 1K data)       Tier 3 (after 10K data)
┌──────────────┐    ┌──────────────────────┐    ┌─────────────────────────┐
│ all-MiniLM   │    │ recruitco fine-tuned  │    │ Custom two-tower        │
│ out-of-box   │ →  │ on travel data       │ →  │ dual-encoder + reranker │
│ 384-dim      │    │ 384-dim              │    │ 384-dim + cross-encoder │
│ Cosine sim   │    │ CosineSimilarityLoss │    │ Contrastive learning    │
│ No training  │    │ 1K labeled pairs     │    │ 10K+ labeled pairs      │
└──────────────┘    └──────────────────────┘    └─────────────────────────┘
```

Each tier is a drop-in replacement — the pgvector index and Edge Function interface stay the same, only the embedding model changes.

---

## Dependencies

- **pgvector**: PostgreSQL extension for vector similarity search (available on Supabase)
- **@xenova/transformers**: Runs HuggingFace models in Deno/Edge Function runtime
- **all-MiniLM-L6-v2**: 22.7M param sentence-transformer model (384-dim embeddings)

No external API keys, no per-call costs, no vendor lock-in.

---

## References

- [pgvector GitHub](https://github.com/pgvector/pgvector)
- [@xenova/transformers](https://huggingface.co/docs/transformers.js)
- [all-MiniLM-L6-v2](https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2)
- [recruitco profile matching model](https://huggingface.co/recruitco/embedding_criteria_profile_summary_matching_qa_minilm_v1)
- [chenbowen184 two-tower reference](https://huggingface.co/chenbowen184/instacart-two-tower-sbert)
- [BAAI/bge-m3 (multilingual option)](https://huggingface.co/BAAI/bge-m3)
