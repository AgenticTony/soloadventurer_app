// ============================================================
// SoloAdventurer — Edge Function: dispatch-escalations
//
// Admin dashboard Phase 1, the half that matters most: this is what reaches a
// human when nobody is looking at the dashboard.
//
// A command centre nobody is watching at 02:00 does not answer the question the
// admin design exists for (docs/design/admin-dashboard-v0.1.md §9.5). This
// drains the escalation queue and pages the on-call admins.
//
// Why a queue and not a direct call
// ---------------------------------
// `pg_net` is not installed, so pg_cron cannot call HTTP. The cron job
// `enqueue-safety-escalations` writes durable rows into `admin_escalations`; this
// function drains them. That is the better shape regardless: a dispatch failure
// leaves a visible, retryable row instead of vanishing into a fire-and-forget
// call, which is not a property you want on a safety page.
//
// Called by: a scheduler (see below). Authenticates with WEBHOOK_SECRET, the same
// pattern process-safety-alert already uses.
//
// Scheduling: this needs an external trigger — Supabase scheduled functions, or
// any cron that can POST. pg_cron alone cannot reach it without pg_net.
//
// Required env:
//   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY  (auto-set)
//   WEBHOOK_SECRET                            shared secret for the caller
//   ADMIN_PAGE_SMS_TO                         comma-separated E.164 numbers
//   ADMIN_PAGE_EMAIL_TO                       comma-separated addresses
//   TWILIO_ACCOUNT_SID / TWILIO_AUTH_TOKEN / TWILIO_FROM_NUMBER
//   RESEND_API_KEY
// ============================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

interface Escalation {
  id: string;
  kind: "sos" | "checkin";
  subject_id: string;
  user_id: string;
  reason: string;
  enqueued_at: string;
  attempts: number;
}

/** Recipients are env-configured so paging targets change without a deploy. */
function recipients(key: string): string[] {
  return (Deno.env.get(key) ?? "")
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);
}

function pageText(e: Escalation): { subject: string; body: string } {
  const waited = Math.round(
    (Date.now() - new Date(e.enqueued_at).getTime()) / 60000,
  );
  const subject =
    e.kind === "sos"
      ? "🚨 SOS UNANSWERED — SoloAdventurer"
      : "⚠️ Missed check-in — SoloAdventurer";

  // Deliberately no PII beyond the user id: a page lands on a phone, possibly a
  // lock screen. It carries enough to act on and nothing more. Detail lives
  // behind the console, where reading it is authenticated and audited.
  const body = [
    subject,
    e.reason,
    `user: ${e.user_id}`,
    `ref: ${e.kind}/${e.subject_id}`,
    `waiting: ${waited}m`,
  ].join("\n");

  return { subject, body };
}

async function sendSMS(to: string, body: string): Promise<void> {
  const sid = Deno.env.get("TWILIO_ACCOUNT_SID");
  const token = Deno.env.get("TWILIO_AUTH_TOKEN");
  const from = Deno.env.get("TWILIO_FROM_NUMBER");
  if (!sid || !token || !from) throw new Error("Twilio env not configured");

  const res = await fetch(
    `https://api.twilio.com/2010-04-01/Accounts/${sid}/Messages.json`,
    {
      method: "POST",
      headers: {
        Authorization: `Basic ${btoa(`${sid}:${token}`)}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({ To: to, From: from, Body: body }),
    },
  );
  if (!res.ok) throw new Error(`Twilio ${res.status}: ${await res.text()}`);
}

async function sendEmail(
  to: string,
  subject: string,
  text: string,
): Promise<void> {
  const key = Deno.env.get("RESEND_API_KEY");
  if (!key) throw new Error("RESEND_API_KEY not configured");

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${key}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: "SoloAdventurer Safety <safety@soloadventurer.com>",
      to: [to],
      subject,
      text,
    }),
  });
  if (!res.ok) throw new Error(`Resend ${res.status}: ${await res.text()}`);
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  if (req.headers.get("x-webhook-secret") !== Deno.env.get("WEBHOOK_SECRET")) {
    return new Response("Unauthorized", { status: 401 });
  }

  const { data: claimed, error } = await supabase.rpc(
    "claim_pending_escalations",
    {
      p_limit: 20,
    },
  );

  if (error) {
    console.error("claim_pending_escalations failed:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  const escalations = (claimed ?? []) as Escalation[];
  const smsTo = recipients("ADMIN_PAGE_SMS_TO");
  const emailTo = recipients("ADMIN_PAGE_EMAIL_TO");

  let dispatched = 0;
  let failed = 0;

  for (const e of escalations) {
    const { subject, body } = pageText(e);

    // Both channels are attempted. A page is worth sending twice; the failure
    // mode to avoid is silence, not duplication.
    const results = await Promise.allSettled([
      ...smsTo.map((to) => sendSMS(to, body)),
      ...emailTo.map((to) => sendEmail(to, subject, body)),
    ]);

    const anyDelivered = results.some((r) => r.status === "fulfilled");
    const errors = results
      .filter((r): r is PromiseRejectedResult => r.status === "rejected")
      .map((r) => String(r.reason));

    if (anyDelivered) {
      // Partial success still counts as dispatched: a human was reached. The
      // failing channel is recorded rather than causing a re-page.
      await supabase.rpc("mark_escalation_dispatched", {
        p_id: e.id,
        p_error: errors.length ? errors.join(" | ").slice(0, 500) : null,
      });
      dispatched++;
    } else {
      // Nothing landed. Leave dispatched_at null so the next run retries;
      // `attempts` is already incremented by the claim, and caps at 5.
      await supabase.rpc("mark_escalation_dispatched", {
        p_id: e.id,
        p_error: (errors.join(" | ") || "no recipients configured").slice(
          0,
          500,
        ),
      });
      failed++;
      console.error(`escalation ${e.id} undelivered:`, errors);
    }
  }

  if (escalations.length > 0 && smsTo.length === 0 && emailTo.length === 0) {
    // Loud, because this is the configuration mistake that silently turns paging
    // off entirely.
    console.error(
      "ADMIN_PAGE_SMS_TO and ADMIN_PAGE_EMAIL_TO are both empty — " +
        `${escalations.length} escalation(s) could not be delivered to anyone.`,
    );
  }

  return new Response(
    JSON.stringify({ claimed: escalations.length, dispatched, failed }),
    { status: 200, headers: { "Content-Type": "application/json" } },
  );
});
