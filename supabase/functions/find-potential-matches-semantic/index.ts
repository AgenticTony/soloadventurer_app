// ============================================================
// SoloAdventurer — Edge Function: find-potential-matches-semantic
//
// Composite scoring system combining semantic similarity (pgvector)
// with structured signals (dates, activities, destination, age).
//
// Called by: Authenticated users looking for travel buddies
// Deploy: supabase functions deploy find-potential-matches-semantic
// ============================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const WEIGHTS = {
  semantic: 0.4,
  date_overlap: 0.25,
  activities: 0.15,
  destination: 0.1,
  age: 0.1,
} as const;

interface SemanticCandidate {
  id: string;
  display_name: string | null;
  avatar_url: string | null;
  bio: string | null;
  age_range: string | null;
  gender: string | null;
  similarity: number;
}

interface RequestBody {
  user_id: string;
  limit?: number;
}

// --- Scoring helpers ---

function computeDateOverlap(
  reqStart: string | null,
  reqEnd: string | null,
  canStart: string | null,
  canEnd: string | null,
): number {
  if (!reqStart || !reqEnd || !canStart || !canEnd) return 0;
  const rs = new Date(reqStart).getTime();
  const re = new Date(reqEnd).getTime();
  const cs = new Date(canStart).getTime();
  const ce = new Date(canEnd).getTime();
  const overlapStart = Math.max(rs, cs);
  const overlapEnd = Math.min(re, ce);
  if (overlapEnd <= overlapStart) return 0;
  const overlapDays = (overlapEnd - overlapStart) / (1000 * 60 * 60 * 24);
  const reqDays = (re - rs) / (1000 * 60 * 60 * 24);
  return reqDays > 0 ? Math.min(overlapDays / reqDays, 1) : 0;
}

function computeActivityJaccard(setA: Set<number>, setB: Set<number>): number {
  if (setA.size === 0 && setB.size === 0) return 0;
  let intersection = 0;
  for (const id of setA) {
    if (setB.has(id)) intersection++;
  }
  const union = setA.size + setB.size - intersection;
  return union > 0 ? intersection / union : 0;
}

function computeDestinationScore(a: string | null, b: string | null): number {
  if (!a || !b) return 0.2;
  if (a.toLowerCase() === b.toLowerCase()) return 1.0;
  // Naive country extraction — last comma-separated part
  const countryA = a.split(",").pop()?.trim().toLowerCase();
  const countryB = b.split(",").pop()?.trim().toLowerCase();
  if (countryA && countryB && countryA === countryB) return 0.5;
  return 0.2;
}

const AGE_ORDER = ["18-24", "25-34", "35-44", "45-54", "55-64", "65+"];

function computeAgeScore(a: string | null, b: string | null): number {
  if (!a || !b) return 0.3;
  if (a === b) return 1.0;
  const idxA = AGE_ORDER.indexOf(a);
  const idxB = AGE_ORDER.indexOf(b);
  if (idxA === -1 || idxB === -1) return 0.3;
  return Math.abs(idxA - idxB) <= 1 ? 0.7 : 0.3;
}

// --- CORS helpers ---

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...corsHeaders },
  });
}

// --- Main handler ---

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  try {
    // Auth
    const authHeader = req.headers.get("authorization");
    if (!authHeader)
      return jsonResponse({ error: "Missing authorization header" }, 401);

    const token = authHeader.replace("Bearer ", "");
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser(token);
    if (authError || !user)
      return jsonResponse({ error: "Invalid or expired token" }, 401);

    // Parse body
    let body: RequestBody;
    try {
      body = await req.json();
    } catch {
      return jsonResponse({ error: "Invalid JSON body" }, 400);
    }

    const { user_id: requestedUserId, limit: rawLimit } = body;
    const callerId = user.id;

    // Allow self-query or verify caller matches requested user_id
    const targetUserId = requestedUserId ?? callerId;
    if (targetUserId !== callerId) {
      return jsonResponse(
        { error: "Can only query matches for yourself" },
        403,
      );
    }

    const limit = Math.min(Math.max(rawLimit ?? 20, 1), 100);
    console.log(
      `[find-potential-matches-semantic] user=${callerId} limit=${limit}`,
    );

    // Step 1: Call semantic RPC to get candidates
    const { data: candidates, error: rpcError } = await supabase.rpc(
      "find_semantic_matches",
      {
        query_user_id: callerId,
        match_threshold: 0.5,
        max_results: 100,
      },
    );

    if (rpcError) {
      console.error("[find-potential-matches-semantic] RPC error:", rpcError);
      // Check if it's a missing embedding scenario
      if (
        rpcError.message?.includes("embedding") ||
        rpcError.message?.includes("vector")
      ) {
        return jsonResponse(
          {
            error:
              "Profile embedding not found. Please generate your profile embedding first.",
            code: "NO_EMBEDDING",
          },
          400,
        );
      }
      return jsonResponse(
        { error: "Failed to find semantic matches", details: rpcError.message },
        500,
      );
    }

    const typedCandidates = (candidates ?? []) as SemanticCandidate[];
    if (typedCandidates.length === 0) {
      return jsonResponse({ matches: [], total: 0 });
    }

    const candidateIds = typedCandidates.map((c) => c.id);

    // Step 2: Fetch structured data for requestor and candidates
    const [
      reqProfileRes,
      reqTripsRes,
      reqActivitiesRes,
      canTripsRes,
      canActivitiesRes,
    ] = await Promise.all([
      // Requestor profile (age_range for age scoring)
      supabase.from("profiles").select("age_range").eq("id", callerId).single(),
      // Requestor active trips
      supabase
        .from("trips")
        .select("destination_name, start_date, end_date")
        .eq("user_id", callerId)
        .eq("is_active", true)
        .order("start_date", { ascending: true }),
      // Requestor activities
      supabase
        .from("user_activities")
        .select("activity_id, activities(name)")
        .eq("user_id", callerId),
      // Candidate active trips
      supabase
        .from("trips")
        .select("user_id, destination_name, start_date, end_date")
        .in("user_id", candidateIds)
        .eq("is_active", true)
        .order("start_date", { ascending: true }),
      // Candidate activities
      supabase
        .from("user_activities")
        .select("user_id, activity_id, activities(name)")
        .in("user_id", candidateIds),
    ]);

    const reqAgeRange = reqProfileRes.data?.age_range ?? null;
    const reqTrips = reqTripsRes.data ?? [];
    const reqActivityRows = (reqActivitiesRes.data ?? []) as unknown as Array<{
      activity_id: number;
      activities: { name: string } | null;
    }>;
    const reqActivityIds = new Set(reqActivityRows.map((r) => r.activity_id));
    const reqActivityNames = new Map<number, string>();
    for (const r of reqActivityRows) {
      if (r.activities?.name)
        reqActivityNames.set(r.activity_id, r.activities.name);
    }

    // Index candidate trips and activities by user_id
    const canTripsMap = new Map<
      string,
      Array<{
        destination_name: string | null;
        start_date: string | null;
        end_date: string | null;
      }>
    >();
    for (const t of canTripsRes.data ?? []) {
      const arr = canTripsMap.get(t.user_id) ?? [];
      arr.push({
        destination_name: t.destination_name,
        start_date: t.start_date,
        end_date: t.end_date,
      });
      canTripsMap.set(t.user_id, arr);
    }

    const canActivitiesMap = new Map<
      string,
      { ids: Set<number>; names: Map<number, string> }
    >();
    for (const r of (canActivitiesRes.data ?? []) as unknown as Array<{
      user_id: string;
      activity_id: number;
      activities: { name: string } | null;
    }>) {
      const entry = canActivitiesMap.get(r.user_id) ?? {
        ids: new Set<number>(),
        names: new Map<number, string>(),
      };
      entry.ids.add(r.activity_id);
      if (r.activities?.name) entry.names.set(r.activity_id, r.activities.name);
      canActivitiesMap.set(r.user_id, entry);
    }

    // Step 3: Compute composite scores
    const matches = typedCandidates.map((candidate) => {
      const canTrips = canTripsMap.get(candidate.id) ?? [];
      const canActs = canActivitiesMap.get(candidate.id) ?? {
        ids: new Set<number>(),
        names: new Map<number, string>(),
      };

      // Date overlap — best across all trip pairings
      let bestDateScore = 0;
      let bestOverlapDays = 0;
      let bestTrip: {
        destination_name: string | null;
        start_date: string | null;
        end_date: string | null;
      } | null = null;

      for (const rt of reqTrips) {
        for (const ct of canTrips) {
          const score = computeDateOverlap(
            rt.start_date,
            rt.end_date,
            ct.start_date,
            ct.end_date,
          );
          if (score > bestDateScore) {
            bestDateScore = score;
            bestTrip = ct;
            // Calculate actual overlap days
            if (rt.start_date && rt.end_date && ct.start_date && ct.end_date) {
              const os = Math.max(
                new Date(rt.start_date).getTime(),
                new Date(ct.start_date).getTime(),
              );
              const oe = Math.min(
                new Date(rt.end_date).getTime(),
                new Date(ct.end_date).getTime(),
              );
              bestOverlapDays =
                oe > os ? Math.round((oe - os) / (1000 * 60 * 60 * 24)) : 0;
            }
          }
        }
      }

      // Activity overlap
      const activityScore = computeActivityJaccard(reqActivityIds, canActs.ids);

      // Shared activity names
      const sharedActivities: string[] = [];
      for (const id of reqActivityIds) {
        if (canActs.ids.has(id)) {
          sharedActivities.push(
            reqActivityNames.get(id) ??
              canActs.names.get(id) ??
              `Activity ${id}`,
          );
        }
      }

      // Destination
      const reqDest = reqTrips[0]?.destination_name ?? null;
      const canDest =
        bestTrip?.destination_name ?? canTrips[0]?.destination_name ?? null;
      const destScore = computeDestinationScore(reqDest, canDest);

      // Age
      const ageScore = computeAgeScore(reqAgeRange, candidate.age_range);

      // Semantic from RPC
      const semanticScore = Math.max(0, Math.min(1, candidate.similarity));

      const compositeScore =
        WEIGHTS.semantic * semanticScore +
        WEIGHTS.date_overlap * bestDateScore +
        WEIGHTS.activities * activityScore +
        WEIGHTS.destination * destScore +
        WEIGHTS.age * ageScore;

      return {
        user_id: candidate.id,
        display_name: candidate.display_name,
        avatar_url: candidate.avatar_url,
        bio: candidate.bio,
        age_range: candidate.age_range,
        gender: candidate.gender,
        semantic_score: Math.round(semanticScore * 100) / 100,
        trip_destination: canDest,
        trip_start: bestTrip?.start_date ?? canTrips[0]?.start_date ?? null,
        trip_end: bestTrip?.end_date ?? canTrips[0]?.end_date ?? null,
        overlap_days: bestOverlapDays,
        shared_activities: sharedActivities,
        composite_score: Math.round(compositeScore * 1000) / 1000,
        match_percentage: `${Math.round(compositeScore * 100)}%`,
        _scores: {
          semanticScore,
          dateScore: bestDateScore,
          activityScore,
          destScore,
          ageScore,
        },
      };
    });

    // Step 4: Sort and trim
    matches.sort((a, b) => b.composite_score - a.composite_score);
    const topMatches = matches
      .slice(0, limit)
      .map(({ _scores, ...rest }) => rest);

    console.log(
      `[find-potential-matches-semantic] Returning ${topMatches.length} matches for user ${callerId}`,
    );

    return jsonResponse({ matches: topMatches, total: matches.length });
  } catch (err) {
    console.error("[find-potential-matches-semantic] Unhandled error:", err);
    return jsonResponse(
      {
        error: "Internal server error",
        details: err instanceof Error ? err.message : "Unknown error",
      },
      500,
    );
  }
});
