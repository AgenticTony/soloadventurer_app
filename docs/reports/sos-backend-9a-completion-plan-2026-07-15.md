# Emergency SOS Backend (9a / Story 0.4) — Completion Plan (2026-07-15)

> **⚠ SAFETY-CRITICAL — REQUIRES HUMAN SIGN-OFF + ON-DEVICE VALIDATION.**
> This documents what the SOS path needs to actually work end-to-end. The client
> half is done (this PR); the backend half is **gated on the prod reconciliation
> (blocker #4)** and is Anthony-led. Nothing here has been run against prod.

## TL;DR

The audit said "the SOS button is wired to a phantom GraphQL host." True — **and
worse**: even the *real* Supabase `trigger-sos` edge function is **non-functional
against the live database** because the tables and columns it depends on aren't
deployed. So SOS fails on **both** ends. This PR fixes the **client** end; the
**backend** end can only be finished as part of the prod reconciliation.

## What this PR fixes (client — verified)

`SafetyRemoteDataSourceImpl.triggerEmergencySOS` now calls the deployed
`trigger-sos` Edge Function via `supabase.functions.invoke('trigger-sos', …)`
instead of the dead `api.soloadventurer.com` GraphQL host. Payload =
lat/lon/accuracy/altitude/address/message/battery_level/trip_id; response
`alert_id`/`status`/`triggered_at` → `SafetyAlert`. 4 unit tests
(`sos_trigger_edge_function_test.dart`); existing 59 safety-repo tests still pass.

This is correct **regardless** of the backend outcome and is a prerequisite for a
working SOS. But end-to-end SOS will still fail until the backend items below land.

## The three-way drift (verified live via Supabase MCP, project `zyiuajhltmxbsrqplqlx`)

The `trigger-sos` edge function (deployed, ACTIVE, v1) reads/writes objects that
disagree across repo migrations, the live DB, and the function's own code:

| Object | Repo migration | LIVE prod DB | `trigger-sos` uses |
|---|---|---|---|
| `sos_alerts` table | defined (`20260402080100`) | **ABSENT** | inserts into it → **fails** |
| `notification_tokens` table | defined (push trigger migration) | **ABSENT** | queries it → **fails** |
| `trusted_contacts` emergency flag | `receives_emergency_alerts` | **`notify_on_emergency`** | `.eq('receives_emergency_alerts', true)` → **column error** |
| `trusted_contacts` contact→user link | `contact_user_id` | **absent** (contacts are phone/email only) | `c.user_id \|\| c.id` for push → **can't target contacts** |
| `trusted_contacts` name cols | `contact_name/contact_phone/contact_email` | `name/phone/email` | selects `name/phone/email` (matches LIVE) |
| `safety_alerts` table | defined | **present** | insert works |

**Consequence:** against the live DB, `trigger-sos` errors at the first
`trusted_contacts` filter (unknown column `receives_emergency_alerts`), and even
past that would fail inserting into the absent `sos_alerts`. It returns 500.

## What must happen to finish 9a (backend — Anthony-led, ordered)

1. **Prod reconciliation (blocker #4, PR #19 runbook) — creates the missing
   tables.** The `db push` applies `20260402080100_sos_alerts_table.sql` and the
   push-notification migration, so `sos_alerts` + `notification_tokens` exist.
   **9a's backend cannot complete before this.**
2. **Decide the canonical `trusted_contacts` schema** (repo vs live) — this is the
   §2.1 canonical-schema decision applied to a specific table. The repo design
   (`contact_name`, `contact_user_id`, `receives_emergency_alerts`) supports
   push-to-registered-contacts; the live design (`name`, `notify_on_emergency`, no
   `contact_user_id`) supports only SMS/email delivery. **Recommendation:** adopt
   the repo design so contacts who are app users can receive push; keep SMS/email
   (via `safety_alerts` → `process-safety-alert`) as the channel for non-app
   contacts.
3. **Correct + redeploy the `trigger-sos` edge function** to the reconciled schema:
   - contacts filter → the canonical emergency flag (`receives_emergency_alerts`
     if repo wins);
   - select `contact_user_id`; push-token join on `contact_user_id` (registered
     contacts only), NOT `c.user_id`/`c.id`;
   - notifications rows target the **contact's** `user_id` (registered), not the
     victim's;
   - `supabase functions deploy trigger-sos`.
4. **On-device validation (👤 Anthony — not automatable):** trigger a real SOS on a
   physical device and confirm (a) the `sos_alerts` row is created, (b) a
   registered trusted contact receives the push, (c) SMS/email fires via
   `process-safety-alert`, (d) background/locked-screen delivery works, (e) the
   button surfaces success/failure correctly. See
   `docs/reports/safety-hardening-audit-2026-07-06.md` for the broader on-device
   safety checklist.

## Out of scope (tracked under PHASE_H)

The other ~36 methods of `SafetyRemoteDataSource` (trusted-contact CRUD,
check-ins, location sharing, settings) still use the phantom `ApiClient`. Migrating
them to Supabase is **PHASE_H Story H.4-adjacent**, not this launch-blocker fix.
They are not on the SOS-trigger path.

## Sources
- Supabase Dart `functions.invoke`: https://supabase.com/docs/reference/dart/functions-invoke
- Live schema/functions: Supabase MCP (`list_edge_functions`, `information_schema`) 2026-07-15.
- Deploy edge functions: https://supabase.com/docs/guides/functions/deploy
