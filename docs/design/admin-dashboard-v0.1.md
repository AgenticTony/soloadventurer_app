# Admin Dashboard — design v0.1

**Status:** §8 decisions answered 2026-08-14. **Phases 0 and 1 shipped**; phases 2–4 not started.
**Date:** 2026-08-14 (v0.2 — decisions folded in, agent triage added)
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

**Decided (§8.1):** admin accounts are **separate identities** from personal user
accounts. An admin browsing cannot act as a user by accident, and revoking admin
never disturbs a real profile.

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

**Decided (§8):** no two-person approval — impractical for a solo operator.
`admin_audit_log.detail` is jsonb, so an `approved_by` can be added later without
migrating the audit shape.

---

## 8. Decisions — answered 2026-08-14

| # | Question | Decision |
|---|---|---|
| 1 | Separate admin identities, or flags on personal accounts? | **Separate identities.** An admin browsing cannot act as a user by accident, and revoking admin never disturbs a real profile. |
| 2 | Separate app, or `/admin` in web? | **Separate app.** Blast-radius isolation; no admin code in the public bundle. |
| 3 | Who moderates, and what is the response expectation? | **AI agent performs initial triage; escalates to a human when it cannot resolve within its parameters.** Designed in §11. |
| 4 | Log reads of PII / location? | **Yes.** Reads are audited as first-class events (§2 principle 2, §5). |
| 5 | Two-person approval for irreversible actions? | **No** — impractical for a solo operator. `admin_audit_log.detail` keeps room for an `approved_by` so this can be added without a migration to the audit shape. |

### 8.1 "Command centre" — one place to look, not one query

The stated goal is a single surface where an admin can see everything. That is in
real tension with §2's least-visibility principle, so the resolution is explicit:

**One place to look; still purpose-shaped underneath.** A single dashboard
aggregates panels — live safety, queues, alerts — and each panel shows the
minimum needed to triage. Full detail (location history, message content, PII) is
a deliberate drill-down, and drilling down is an audited read.

The thing to avoid is not density. It is a surface that hands over everything about
a person because someone glanced at a queue.

## 9. Agent triage and escalation

**Decision (§8.3):** an AI agent performs initial triage and escalates to a human
when it cannot resolve within its parameters.

This is the right shape for the charter — FOUNDATIONS §6.2 requires AI to live in
the core loop (matching, safety, moderation, concierge) rather than be bolted on,
and §4's L3 layer names a moderator agent explicitly. It is also the only honest
answer to "who responds at 02:00" for a solo operator.

Four constraints make the difference between triage that helps and automation that
hurts.

### 9.1 The agent triages; it never adjudicates

Hard line:

| Agent may | Agent may not |
|---|---|
| Classify a report (category, severity) | Set `reports.outcome` |
| Gather context (history, prior reports, block counts) | Change anyone's reputation |
| Rank and route the queue | Suspend, ban, or restrict an account |
| Draft a recommendation with reasoning | Close a report as dismissed |
| Escalate, and page a human | Decide that nothing needs a human |

The reward function is described in FOUNDATIONS §4 as the ethical spine, and
`reports.outcome` is now an input to it (reward-fn v0.1.1). An agent that could
write `outcome` would be issuing automated punishment with no human in the loop.

**Agent proposes, human disposes** — for anything that writes a penalty.

Concretely: the agent writes to a `report_triage` record (classification,
severity, recommendation, reasoning, confidence). `adjudicate_report` stays a
human-only verb. A dismissal is still a decision, so "dismiss" is not the agent's
to make either.

### 9.2 SOS is not triaged

An unacknowledged `sos_alerts` row pages a human **immediately and always**. There
is no version of "the agent investigates first" that is appropriate when someone
has pressed an emergency button.

The agent may *enrich* an SOS — pull location, battery, trip context, which
contacts were notified — but enrichment runs in parallel with the page, never
ahead of it.

### 9.3 Escalation thresholds are the safety design

The parameters are not configuration; they are where this succeeds or fails. Two
failure modes, asymmetric in cost:

- **Under-escalation** leaves a harassed user unanswered — the exact failure this
  whole document exists to prevent.
- **Over-escalation** pages a human for everything, making the agent pointless.

Under-escalation is far more expensive than over-escalation, so the threshold
should be **deliberately biased toward paging a human**, especially early. Escalate
on any of:

- any report mentioning physical safety, threats, sexual content, or minors —
  regardless of the agent's confidence
- agent confidence below threshold
- a repeat target (a user already carrying upheld reports or `risk_flag`)
- **anything the agent has not seen before** — novelty is a reason to escalate, not
  a reason to guess
- any report where the reporter is in an active or recent meetup with the target

**Time-to-human is the metric to instrument**, not agent resolution rate. A high
resolution rate is as likely to mean the agent is swallowing things as solving
them.

### 9.4 The agent reads attacker-controlled text

Report text, message content and profile bios are **untrusted input**. An agent
that can be talked into dismissing a report by instructions embedded in the report
itself is a real and reachable attack on this product.

Requirements:

- User content is passed as **data, never as instruction**, with clear delimiting.
- The agent has **no destructive tools**. Its capability surface is: read context,
  write a triage record, escalate. Even if fully subverted, the worst it can do is
  misclassify and over-page.
- Content that attempts to instruct the agent is itself an **escalation trigger** —
  someone crafting prompt injection is displaying intent worth a human's attention.
- Triage records are auditable and reversible; a bad prompt version can be
  identified and its whole batch re-triaged.

### 9.5 Agent actions are audited as agent actions

`admin_audit_log.actor_id` assumes a human. Agent entries record the agent as
actor plus, in `detail`: model, prompt version, confidence, and the inputs it
saw. Without prompt version, a systematically bad batch cannot be found and
re-run.

**Paging is a build item, not a dashboard feature.** A command centre nobody is
looking at at 02:00 does not answer the question this section exists for; the
escalation path needs a real channel (push, SMS, PagerDuty) with an
acknowledgement loop. That belongs in Phase 1 alongside the live-safety view.

---

## 10. Proposed sequencing

| Phase | Ships | Why here |
|---|---|---|
| **0 — Foundation** ✅ | `admin_users`, `admin_role`, `is_admin()`, `admin_audit_log`, `log_admin_action()`, admin-read RLS, 18 pgTAP | **Shipped** `20260814100000_admin_foundation.sql`. |
| **1 — Live safety + paging** ✅ *(backend)* | `admin_live_safety_queue`, acknowledge/resolve/annotate verbs, `admin_escalations` queue + cron, `dispatch-escalations` edge function, 16 pgTAP | **Backend shipped** `20260814200000_admin_live_safety.sql`. **The console UI is not built** — paging works without it, which is the point. |
| **2 — Reports + user context** | Adjudication with the context to adjudicate *on* | Turns the v0.1.1 penalty live; 4.4 is a prerequisite for 4.3 being correct |
| **3 — Verification queue** | Review, override with reason | Needs the strictest controls, so it goes last |
| **4 — Agent triage** | Classification, context-gathering, recommendation, escalation (§9) | Needs phases 1–2 to exist first: the agent escalates *into* the human queues, so the queues must be real before the agent routes to them. |

Phase 0 is small and is the prerequisite for everything, including the
report-penalty activation. Phases 1–3 are independently shippable; Phase 4 is not,
since the agent escalates into queues that phases 1–2 create.

---

## 11. Consequences if this is not built

Stated plainly, so deferring is a choice rather than an oversight:

- SOS alerts continue to reach nobody at the company.
- Missed check-ins escalate to no one.
- Declined verifications have no appeal path.
- The reward-fn v0.1.1 report penalty stays permanently zero, so filing a report
  has no effect on reputation.
- `no-show-dispute-v0.1.1.md` Phase 2 (human review) has nowhere to live.
- The agent triage in §9 has nothing to escalate *into*, so the 02:00 answer stays
  theoretical.
