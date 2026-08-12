// ============================================================
// SoloAdventurer — Edge Function: verify-with-shuftipro
//
// Purpose: Verify user identity/gender using the Shufti Pro API.
//   - Called by the Flutter client after the Shufti SDK completes an
//     onsite verification (document capture + selfie + liveness).
//   - Fetches the verification result from Shufti's /status endpoint.
//   - Verifies the Shufti response signature (double-SHA256).
//   - Stores the result in verification_records.
//   - For approved gender verifications, sets profiles.gender_verified = true.
//
// Called by: Flutter client (Mode A, authenticated)
//            Shufti callback (Mode B, signed — async backstop)
//
// Deploy: supabase functions deploy verify-with-shuftipro
//
// Required env vars (set via `supabase secrets set`):
//   SHUFTIPRO_CLIENT_ID   — Shufti account Client ID
//   SHUFTIPRO_SECRET_KEY  — Shufti account Secret Key (also used for signature)
//   SUPABASE_URL          — (auto-set by Supabase)
//   SUPABASE_SERVICE_ROLE_KEY — (auto-set by Supabase)
//
// Refs: SHUFTI_MIGRATION_PLAN.md §4.1
//   Shufti /status docs: https://developers.shuftipro.com/docs/verification_endpoints/status
//   Shufti signature docs: https://developers.shuftipro.com/docs/verification_endpoints/responses
//   Algorithm proven against live response 2026-08-12 (see §4.1.3a)
// ============================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { createHash } from "node:crypto";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const SHUFTI_API_URL = "https://api.shuftipro.com";

// Read secrets lazily (at request time, not module-load time).
// The Supabase edge runtime injects env vars per-worker; reading them at the
// top level can race with worker initialization.
function getShuftiCreds(): { clientId: string; secretKey: string } {
  const clientId = Deno.env.get("SHUFTIPRO_CLIENT_ID");
  const secretKey = Deno.env.get("SHUFTIPRO_SECRET_KEY");
  if (!clientId || !secretKey) {
    throw new Error("SHUFTIPRO_CLIENT_ID or SHUFTIPRO_SECRET_KEY is not defined");
  }
  return { clientId, secretKey };
}

// ---------------------------------------------------------------------------
// CORS
// ---------------------------------------------------------------------------
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, signature",
};

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------
interface ClientRequest {
  verification_type: "gender" | "age" | "identity";
  shufti_reference?: string;
  // Mode C (submit): base64-encoded images from the Flutter app
  document_front?: string; // data:image/...;base64,...  or raw base64
  document_back?: string;
  selfie?: string;
  country?: string;
}

// Result of submitting a verification to Shufti
interface ShuftiSubmitResult {
  reference: string;
  event: string;
  verification_url?: string;
}

interface ShuftiProof {
  gender?: string; // "M" | "F"
  dob?: string;
  first_name?: string;
  last_name?: string;
  nationality?: string;
  document_number?: string;
  [key: string]: unknown;
}

interface ShuftiResponse {
  reference: string;
  event: string; // "verification.accepted" | "verification.declined" | ...
  verification_result?: {
    document?: { gender?: number };
  };
  additional_data?: {
    document?: { proof?: ShuftiProof };
  };
  declined_reason?: string;
  declined_codes?: string[];
}

// ---------------------------------------------------------------------------
// Signature verification (SECURITY-CRITICAL)
// Shufti uses double-SHA256: SHA256(rawBody + SHA256(secretKey))
// NOT HMAC. Proven against live response 2026-08-12.
// Docs: https://developers.shuftipro.com/docs/verification_endpoints/responses
// ---------------------------------------------------------------------------
function verifyShuftiSignature(
  rawBody: string,
  signatureHeader: string | null,
): boolean {
  if (!signatureHeader) return false;
  const { secretKey } = getShuftiCreds();
  const hashedSecret = createHash("sha256")
    .update(secretKey)
    .digest("hex");
  const calculated = createHash("sha256")
    .update(rawBody + hashedSecret)
    .digest("hex");
  return calculated === signatureHeader;
}

// ---------------------------------------------------------------------------
// Fetch verification status from Shufti /status endpoint
// Docs: https://developers.shuftipro.com/docs/verification_endpoints/status
// ---------------------------------------------------------------------------
async function fetchShuftiStatus(
  reference: string,
): Promise<{ data: ShuftiResponse | null; rawBody: string; signature: string | null }> {
  const { clientId, secretKey } = getShuftiCreds();
  const basicAuth = btoa(`${clientId}:${secretKey}`);

  const response = await fetch(`${SHUFTI_API_URL}/status`, {
    method: "POST",
    headers: {
      "Authorization": `Basic ${basicAuth}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ reference }),
  });

  const rawBody = await response.text();
  const signature = response.headers.get("signature") ||
    response.headers.get("sp_signature");

  if (!response.ok) {
    console.error("Shufti /status error:", response.status, rawBody);
    return { data: null, rawBody, signature };
  }

  // Verify the signature before trusting the payload
  if (!verifyShuftiSignature(rawBody, signature)) {
    console.error("Shufti signature verification FAILED for reference:", reference);
    return { data: null, rawBody, signature };
  }

  return { data: JSON.parse(rawBody) as ShuftiResponse, rawBody, signature };
}

// ---------------------------------------------------------------------------
// Submit a verification to Shufti with base64 images (Mode C)
// Docs: https://developers.shuftipro.com/docs/verification_endpoints/requests
// ---------------------------------------------------------------------------
async function submitShuftiVerification(
  body: ClientRequest,
  userId: string,
): Promise<ShuftiResponse | null> {
  const { clientId, secretKey } = getShuftiCreds();
  const basicAuth = btoa(`${clientId}:${secretKey}`);

  const reference = `sa_${userId.substring(0, 8)}_${Date.now()}`;
  const country = body.country || "GB";

  // Build the Shufti request payload
  // The Flutter app captures images via image_picker and sends them as base64.
  const payload: Record<string, unknown> = {
    reference,
    callback_url: `${Deno.env.get("SUPABASE_URL")}/functions/v1/verify-with-shuftipro`,
    country,
    language: "EN",
    fetch_enhanced_data: "1",
    verification_mode: "any",
  };

  // Document service (with enhanced data extraction for gender/DOB)
  payload["document"] = {
    proof: body.document_front,
    ...(body.document_back ? { additional_proof: body.document_back } : {}),
    supported_types: ["id_card", "driving_license", "passport"],
    allow_offline: "1",
    allow_online: "1",
  };

  // Face service (selfie + liveness)
  if (body.selfie) {
    payload["face"] = { proof: body.selfie };
  }

  const response = await fetch(SHUFTI_API_URL, {
    method: "POST",
    headers: {
      "Authorization": `Basic ${basicAuth}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  const rawBody = await response.text();
  const signature = response.headers.get("signature") ||
    response.headers.get("sp_signature");

  if (!response.ok) {
    console.error("Shufti submit error:", response.status, rawBody);
    return null;
  }

  // Verify the signature
  if (!verifyShuftiSignature(rawBody, signature)) {
    console.error("Shufti submit signature verification FAILED");
    return null;
  }

  return JSON.parse(rawBody) as ShuftiResponse;
}

// ---------------------------------------------------------------------------
// Extract verified gender from Shufti response
// Shufti returns gender as "M" or "F" in additional_data.document.proof.gender
// ---------------------------------------------------------------------------
function extractGender(data: ShuftiResponse): string | null {
  const gender = data.additional_data?.document?.proof?.gender;
  if (!gender) return null;
  const lower = gender.toLowerCase();
  if (lower === "m" || lower === "male") return "male";
  if (lower === "f" || lower === "female") return "female";
  return null;
}

function extractDOB(data: ShuftiResponse): string | null {
  return data.additional_data?.document?.proof?.dob ?? null;
}

// ---------------------------------------------------------------------------
// Map Shufti event to our DB status vocabulary
// ---------------------------------------------------------------------------
function mapStatus(shuftiEvent: string): string {
  if (shuftiEvent === "verification.accepted") return "approved";
  if (shuftiEvent === "verification.declined") return "declined";
  return "pending";
}

// ---------------------------------------------------------------------------
// Core: process a Shufti verification result
// Idempotent on provider_reference — safe to call from both Mode A and Mode B.
// ---------------------------------------------------------------------------
async function processVerificationResult(
  shuftiData: ShuftiResponse,
  verificationType: string,
  rawBody: string,
): Promise<{ status: string; verifiedGender: string | null }> {
  const reference = shuftiData.reference;
  const status = mapStatus(shuftiData.event);
  const verifiedGender = extractGender(shuftiData);
  const verifiedDOB = extractDOB(shuftiData);

  // 1. Find or create the verification_records row
  const { data: existing } = await supabase
    .from("verification_records")
    .select("id, user_id, status")
    .eq("provider_reference", reference)
    .limit(1)
    .single();

  let recordId: string;
  let userId: string;

  if (existing) {
    // Idempotent: already processed (or in progress). Update with latest.
    recordId = existing.id;
    userId = existing.user_id;

    // If already approved, don't reprocess
    if (existing.status === "approved" && status === "approved") {
      return { status, verifiedGender };
    }
  } else {
    // Mode B (callback) may arrive before Mode A creates the row.
    // We can't create it without a user_id — skip; Mode A will catch it.
    if (!shuftiData.reference) {
      console.error("Cannot create verification_records: no user context");
      return { status, verifiedGender };
    }
    // This branch is rare; normally Mode A creates the row first.
    return { status, verifiedGender };
  }

  // 2. Update verification_records with the result
  await supabase
    .from("verification_records")
    .update({
      status,
      provider_result: shuftiData,
      provider_breakdown: shuftiData.verification_result ?? null,
      verified_gender: verifiedGender,
      verified_date_of_birth: verifiedDOB,
      reviewed_at: new Date().toISOString(),
    })
    .eq("id", recordId);

  // 3. If approved AND gender verification AND gender is female → unlock women-only
  if (
    status === "approved" &&
    verificationType === "gender" &&
    verifiedGender === "female"
  ) {
    await supabase
      .from("profiles")
      .update({
        gender_verified: true,
        gender: verifiedGender,
      })
      .eq("id", userId);

    // Notify the user
    await supabase.from("notifications").insert({
      user_id: userId,
      type: "verification_approved",
      object_id: recordId,
      object_type: "verification",
      body: "Your identity has been verified. Women-only mode is now available.",
      read: false,
    });
  } else if (status === "approved" && verificationType === "gender" && verifiedGender) {
    // Approved but gender is male/non-binary — verify identity but don't unlock women-only
    await supabase
      .from("profiles")
      .update({ gender_verified: true, gender: verifiedGender })
      .eq("id", userId);

    await supabase.from("notifications").insert({
      user_id: userId,
      type: "verification_approved",
      object_id: recordId,
      object_type: "verification",
      body: "Your identity has been verified.",
      read: false,
    });
  } else if (status === "declined") {
    await supabase.from("notifications").insert({
      user_id: userId,
      type: "verification_declined",
      object_id: recordId,
      object_type: "verification",
      body: "Your verification was declined. Please try again with a valid document.",
      read: false,
    });
  }

  return { status, verifiedGender };
}

// ---------------------------------------------------------------------------
// Mode A: Authenticated client call
// ---------------------------------------------------------------------------
async function handleClientCall(req: Request): Promise<Response> {
  // Verify auth
  const authHeader = req.headers.get("authorization");
  if (!authHeader) {
    return jsonError(401, "Missing authorization header");
  }

  const token = authHeader.replace("Bearer ", "");
  const { data: { user }, error: authError } = await supabase.auth.getUser(token);
  if (authError || !user) {
    return jsonError(401, "Invalid or expired token");
  }

  const body: ClientRequest = await req.json();
  const { verification_type, shufti_reference, document_front, selfie } = body;

  if (!verification_type) {
    return jsonError(400, "verification_type is required");
  }

  // ─── Mode C: Submit verification with base64 images ─────────────────────
  // The Flutter app captures photos via image_picker and sends them here.
  // The edge function submits them to Shufti and returns the result.
  if (document_front || selfie) {
    const shuftiData = await submitShuftiVerification(body, user.id);

    if (!shuftiData) {
      return jsonError(502, "Failed to submit verification to Shufti");
    }

    // Create a verification_records row
    const { data: newRecord } = await supabase
      .from("verification_records")
      .insert({
        user_id: user.id,
        verification_type,
        provider_reference: shuftiData.reference,
        provider: "shuftipro",
        status: mapStatus(shuftiData.event),
      })
      .select("id")
      .single();

    // Process the result (writes gender_verified etc.)
    const { status, verifiedGender } = await processVerificationResult(
      shuftiData,
      verification_type,
      JSON.stringify(shuftiData),
    );

    return new Response(
      JSON.stringify({
        success: true,
        verification_id: newRecord?.id ?? null,
        shufti_reference: shuftiData.reference,
        status,
        verified_gender: verifiedGender,
        message: status === "approved"
          ? "Verification complete."
          : status === "declined"
            ? "Verification declined."
            : "Verification is still processing.",
      }),
      { status: 200, headers: { "Content-Type": "application/json", ...corsHeaders } },
    );
  }

  // ─── Mode A: Poll status with an existing reference ─────────────────────
  if (!shufti_reference) {
    return jsonError(400, "Either shufti_reference or document_front+selfie is required");
  }

  if (shufti_reference.length < 6 || shufti_reference.length > 250) {
    return jsonError(400, "shufti_reference must be 6-250 characters");
  }

  // Fetch the result from Shufti
  const { data: shuftiData, rawBody, signature } = await fetchShuftiStatus(
    shufti_reference,
  );

  if (!shuftiData) {
    return jsonError(502, "Failed to fetch verification status from Shufti");
  }

  // Ensure a verification_records row exists for this user + reference
  const { data: existing } = await supabase
    .from("verification_records")
    .select("id")
    .eq("provider_reference", shufti_reference)
    .limit(1)
    .single();

  if (!existing) {
    const { data: newRecord, error: insertError } = await supabase
      .from("verification_records")
      .insert({
        user_id: user.id,
        verification_type,
        provider_reference: shufti_reference,
        provider: "shuftipro",
        status: "pending",
      })
      .select("id")
      .single();

    if (insertError) {
      console.error("Failed to create verification record:", insertError);
      return jsonError(500, "Failed to create verification record");
    }
  }

  // Process the result (idempotent)
  const { status, verifiedGender } = await processVerificationResult(
    shuftiData,
    verification_type,
    rawBody,
  );

  // Get the verification record ID for the response
  const { data: recordRow } = await supabase
    .from("verification_records")
    .select("id")
    .eq("provider_reference", shufti_reference)
    .limit(1)
    .single();

  return new Response(
    JSON.stringify({
      success: true,
      verification_id: recordRow?.id ?? null,
      shufti_reference,
      status,
      verified_gender: verifiedGender,
      message: status === "approved"
        ? "Verification complete."
        : status === "declined"
          ? "Verification declined."
          : "Verification is still processing.",
    }),
    { status: 200, headers: { "Content-Type": "application/json", ...corsHeaders } },
  );
}

// ---------------------------------------------------------------------------
// Mode B: Shufti callback (signed, async backstop)
// ---------------------------------------------------------------------------
async function handleCallback(req: Request): Promise<Response> {
  // Read the raw body FIRST (signature is over raw bytes)
  const rawBody = await req.text();
  const signature = req.headers.get("signature") ||
    req.headers.get("sp_signature");

  // Verify the signature BEFORE parsing
  if (!verifyShuftiSignature(rawBody, signature)) {
    console.error("Callback signature verification failed");
    return new Response("Unauthorized", { status: 401 });
  }

  const shuftiData: ShuftiResponse = JSON.parse(rawBody);

  // Look up the verification record to get user_id + type
  const { data: record } = await supabase
    .from("verification_records")
    .select("id, user_id, verification_type")
    .eq("provider_reference", shuftiData.reference)
    .limit(1)
    .single();

  if (!record) {
    // Callback arrived before Mode A created the row — return 200 so Shufti
    // doesn't retry; Mode A will fetch the result when the client polls.
    console.log("Callback for unknown reference:", shuftiData.reference);
    return new Response("OK", { status: 200 });
  }

  await processVerificationResult(
    shuftiData,
    record.verification_type,
    rawBody,
  );

  return new Response("OK", { status: 200 });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
function jsonError(status: number, message: string): Response {
  return new Response(
    JSON.stringify({ success: false, error: message }),
    { status, headers: { "Content-Type": "application/json", ...corsHeaders } },
  );
}

// ---------------------------------------------------------------------------
// Main handler
// ---------------------------------------------------------------------------
Deno.serve(async (req: Request) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonError(405, "Method not allowed");
  }

  try {
    // Mode B: Shufti callback (has Signature header, no Bearer token)
    const signature = req.headers.get("signature") ||
      req.headers.get("sp_signature");
    const hasBearer = req.headers.get("authorization")?.startsWith("Bearer ");

    if (signature && !hasBearer) {
      return await handleCallback(req);
    }

    // Mode A: Authenticated client call
    return await handleClientCall(req);
  } catch (err) {
    console.error("verify-with-shuftipro error:", err);
    return jsonError(500, err instanceof Error ? err.message : "Internal server error");
  }
});
