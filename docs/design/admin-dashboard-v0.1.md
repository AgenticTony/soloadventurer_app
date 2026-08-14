# Admin Dashboard — design v0.1

**Status:** Decision document. Not implemented. Needs sign-off on §8 before build.
**Date:** 2026-08-14
**Safety-sensitive:** Yes — this is the one surface that can see everything.
**Related:** `docs/design/no-show-dispute-v0.1.1.md` (its Phase 2 human review lands here) ·
`docs/reward-function-v0.1.md` (the report penalty is inert until §4.3 ships) ·
`docs/RELEASE.md` · FOUNDATIONS §10 (safety-sensitive governance)

---

## 1. Why this exists

Not "moderation needs a UI". The finding is broader, and it was found by reading
RLS rather than by reading the roadmap:

**No one at SoloAdventurer can see anything operationally.** Every safety table is
scoped to the people involved, with no operator visibility of any kind.

| Table | Who can read it | What that means |
|---|---|---|
| `sos_alerts` | the user, and their trusted contacts (active only) | **An SOS reaches nobody at the company.** If a user has no trusted contact configured, or theirs does not respond, the alert is seen by no one who can act institutionally. You would not know it happened. |
| `meetup_checkins` | owner only | A missed check-in — the escalation the safety pillar is built on — is visible only to the person who missed it. `alerted_at` and `sos_triggered_at` exist and nobody watches them. |
| `verification_records` | `read_own` only | A wrongly-declined user has no recourse and nobody can view the record. The table already has `reviewed_by`, `reviewed_at`, `review_notes` — **the schema anticipated a reviewer that was never built.** |
| `reports` | `read own` (the reporter) | No UPDATE policy exists at all, so nothing can set `outcome`. The report penalty wired in reward-fn v0.1.1 is permanently zero until this changes. |

This is a product whose thesis is that *someone is watching*. Right now nobody is,
and the gap is structural rather than a missing screen.

### Non-goals

Naming these so scope does not drift into "internal tool for everything":

- **Not an analytics product.** PostHog owns funnels and north-star reporting.
  This surface answers "what is happening to this person right now", not "how is
  the business doing".
- **Not a CRM.** No campaigns, no segments, no outreach.
- **Not a general SQL console.** The Supabase dashboard already exists for that,
  and every action here should be a named, audited verb rather than free-form SQL.
- **Not a growth surface.** Nothing here is user-facing.

---

## 2. The security posture is the design

This surface can, by construction, see PII, safety data and location history for
every user. That makes it the highest-value target in the system, and on a product
selling trust an admin console with a soft auth model is a worse liability than
having no console at all.

Three principles, in priority order:

1. **Least visibility that still permits the job.** An admin reviewing a report
   does not need the reporter's home address. Views are purpose-shaped, not
   `select *`.
2. **Every privileged read is logged, not just writes.** The usual instinct is to
   audit mutations. Here, *looking* is the sensitive act — an admin browsing
   location history leaves no trace unless we make one.
3. **No unilateral irreversible action.** Deletion, verification override and
   permanent bans are the actions most likely to be wrong or coerced; see §7.

---

## 3. Authentication and authorisation

### 3.1 Moderator identity

No admin/moderator concept exists in the schema today (the only `admin` string is
`women_only_space_members.role`, unrelated).

Proposal — a dedicated table rather than a boolean on `profiles`:

```sql
create table public.admin_users (
  user_id     uuid primary key references public.profiles(id) on delete cascade,
  role        admin_role not null,          -- 'support' | 'moderator' | 'owner'
  granted_by  uuid references public.profiles(id),
  granted_at  timestamptz not null default now(),
  revoked_at  timestamptz
);
```

Why a table and not `profiles.is_admin`:

- Roles are not a boolean — a support agent who can read a report should not be
  able to override a verification.
- Grant and revoke are themselves auditable events, with an actor.
- It keeps admin state off the row that ordinary matching reads, so an admin flag
  can never leak through a profile projection.

**Roles.** Deliberately few:

| Role | Can | Cannot |
|---|---|---|
| `support` | read the queues, read purpose-scoped user context | change anything |
| `moderator` | adjudicate reports, resolve SOS, action check-ins | override verification, grant admin, delete accounts |
| `owner` | everything, including granting roles | — (but still fully audited) |

### 3.2 Authentication

Supabase Auth, same identity provider as the app, **plus a second factor for any
role above `support`**. An admin session should be short-lived and re-auth'd for
destructive verbs (§7).

**Open question for §8:** whether admin accounts are separate identities from
personal user accounts. Separate is cleaner — an admin browsing as themselves
cannot accidentally act as a user, and revoking admin does not disturb a real
profile — but it is more accounts to manage for a solo operator.

### 3.3 Authorisation in the database

The dashboard must not hold `service_role`. A compromised admin session should be
bounded by role, not handed a key that bypasses RLS entirely.

Pattern, consistent with what the codebase already does for women-only gating:

```sql
create function public.is_admin(min_role admin_role default 'support')
returns boolean language sql stable security definer set search_path = public;
```

- **Reads** — RLS policies on the safety tables gain an `is_admin(...)` clause, so
  an admin's own JWT is what grants access. No shared key.
- **Writes** — never direct. Every mutation is a named `SECURITY DEFINER` RPC
  (`adjudicate_report`, `resolve_sos_alert_admin`, …) that checks the role, writes
  the change, and appends to the audit log in the same transaction. A write that
  cannot be described as a verb does not belong here.

---

## 4. Surfaces, sequenced by what is dangerous not to see

Ordered by consequence-of-blindness, not by build effort.

### 4.1 Live safety *(first — this is the one with real-world consequence)*

- Active `sos_alerts`: who, where (`location`, `address`, `accuracy`), when
  (`triggered_at`), `battery_level`, which contacts were notified
  (`notified_contact_ids`) and which acknowledged.
- **Unacknowledged alerts surfaced most loudly.** The dangerous case is not an
  SOS — it is an SOS nobody answered.
- `meetup_checkins` past `alerted_at` with no `checked_in_at`.
- Verbs: acknowledge, annotate, resolve, escalate. Every one audited.

This is the slice where absence of visibility is measured in hours, and it is why
this document exists.

### 4.2 Verification queue

- `verification_records` where `status` is declined or in review.
- Populates the `reviewed_by` / `reviewed_at` / `review_notes` columns that have
  been sitting unused since the table was created.
- Verb: `override_verification` — `owner` only, requires a written reason, and is
  the single most abuse-prone action in the system (§7).

### 4.3 Reports queue

- `reports` grouped by `target_id`, showing `outcome` and the reporting history.
- Verb: `adjudicate_report(report_id, outcome, note)` — writes `outcome`,
  `resolved`, `resolved_by`, and audits.
- **This is what turns the reward-fn v0.1.1 report penalty from inert to live.**
- Feeds `moderation_risk_signal()` for context: `distinct_blockers`,
  `pending_reports`, `risk_flag`.

### 4.4 User context

The layer that makes the three above *adjudicable* rather than guesswork —
reputation, verification state, meetup history, blocks against, report history.

Without this, upholding a report means judging an incident with no knowledge of
whether it is a first complaint or a fifth. **This is a correctness requirement
for §4.3, not a nice-to-have** — which is the flaw in shipping an adjudication
verb on its own.

---

## 5. Audit

`gender_change_audit_log` is the precedent to follow — it already records
`ip_address` and `user_agent` alongside the change.

```sql
create table public.admin_audit_log (
  id           uuid primary key default gen_random_uuid(),
  actor_id     uuid not null references public.profiles(id),
  action       text not null,        -- 'report.adjudicate', 'sos.resolve', 'user.view'
  subject_id   uuid,                 -- the user acted upon or viewed
  detail       jsonb,                -- before/after, reason text
  ip_address   inet,
  user_agent   text,
  created_at   timestamptz not null default now()
);
```

- **Append-only.** No UPDATE or DELETE policy, for anyone, including `owner`.
- **Reads are logged too** (`user.view`, `sos.view`) — see §2, principle 2.
- Retention and access: an admin can read the log; only `owner` can read *other*
  admins' entries.

---

## 6. Where it lives

Three options considered:

| Option | For | Against |
|---|---|---|
| Route group in the existing web app (`/admin`) | Reuses auth, deploy, types, components | Ships admin code to the public bundle; one misconfigured middleware exposes it. FOUNDATIONS §5 also re-missions web as *acquisition* — this is not that. |
| **Separate Next.js app, own deploy** | Blast-radius isolation; independent auth posture; can sit behind IP allowlist or VPN; no admin code in the public bundle | Second deploy target; shares the generated types via copy or a package |
| Supabase dashboard only | Zero build | No queue, no audit trail, no purpose-shaped views, and `service_role` for everything — the opposite of §2 |

**Recommendation: a separate app.** The isolation argument is decisive on a
product where the admin surface is the highest-value target, and it keeps
FOUNDATIONS §5's client split honest.

---

## 7. What an admin must not be able to do alone

The actions most likely to be wrong, coerced, or abused:

- **Override an identity verification** — this admits someone to women-only mode.
  `owner` only, written reason required, and it should be reviewable after the fact.
- **Delete a user account** — GDPR deletion is legitimate but irreversible; it
  should be a request-and-confirm flow, not a button.
- **Read location history** without an open incident — allowed, but loudly logged
  and attributable.
- **Grant admin roles** — `owner` only, always audited.

**Open question for §8:** whether any of these should need two-person approval.
For a solo operator that is impractical today; the schema should not preclude it.

---

## 8. Decisions needed before build

1. **Separate admin identities, or admin flags on personal accounts?**
   (§3.2 — separate is safer, more overhead for one person.)
2. **Separate app, or `/admin` in the web app?** (§6 — recommendation is separate.)
3. **Who moderates, and what is the response expectation?** An SOS view is only
   as useful as the person watching it. A solo founder adjudicating harassment
   reports on a women's-safety product is an operational and duty-of-care
   commitment, not just a screen. What is the SLA when someone reports being
   harassed at 02:00 in another timezone?
4. **Do reads of PII/location get logged?** (§2 recommends yes — it costs write
   volume and is unusual, so it should be a conscious choice.)
5. **Two-person approval for irreversible actions?** (§7 — impractical now, but
   decides whether the schema carries an `approved_by`.)

---

## 9. Proposed sequencing

| Phase | Ships | Why here |
|---|---|---|
| **0 — Foundation** | `admin_users`, `admin_role`, `is_admin()`, `admin_audit_log`, RLS clauses, pgTAP | Nothing else can be built safely first. Also unblocks 4.3 from any surface, including a script. |
| **1 — Live safety** | SOS + missed check-in views, acknowledge/resolve verbs | The only slice where blindness has a real-world cost |
| **2 — Reports + user context** | Adjudication with the context to adjudicate *on* | Turns the v0.1.1 penalty live; 4.4 is a prerequisite for 4.3 being correct |
| **3 — Verification queue** | Review, override with reason | Needs the strictest controls, so it goes last |

Phase 0 is small and is the prerequisite for everything, including the
report-penalty activation. Phases 1–3 are independently shippable.

---

## 10. Consequences if this is not built

Stated plainly, so deferring is a choice rather than an oversight:

- SOS alerts continue to reach nobody at the company.
- Missed check-ins escalate to no one.
- Declined verifications have no appeal path.
- The reward-fn v0.1.1 report penalty stays permanently zero, so filing a report
  has no effect on reputation.
- `no-show-dispute-v0.1.1.md` Phase 2 (human review) has nowhere to live.
