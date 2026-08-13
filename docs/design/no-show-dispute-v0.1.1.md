# No-Show Dispute Design — reward-fn v0.1.1

**Status:** Decision document (design gate for web step 10 — public reputation surfacing)
**Date:** 2026-08-13
**Supersedes:** `docs/reward-function-v0.1.md` §A.4 (unilateral report_no_show)
**Safety-sensitive:** Yes — reputation griefing vector

---

## The problem

The current `report_no_show` RPC (migration `20260706100000`) is **unilateral**: either party can brand the other a no-show. Guards narrow but don't close the griefing surface:

- ✅ Meetup must be past `meetup_time + buffer`
- ✅ Meetup must not have a `checked_in` status
- ✅ Penalty (−1) is attributed to `no_show_user_id`
- ❌ **No dispute path** — the accused party has no recourse
- ❌ A malicious user can no-show-report someone who genuinely showed up but didn't use the app to check in

This is acceptable for v0.1 (no public reputation yet). But web step 10 makes reputation public, which means a false no-show mark becomes a **visible reputation scar**. The dispute path must be designed before that surfacing ships.

---

## Decision: two-phase dispute with evidence window

### Phase 1 — Soft flag (v0.1.1, ships with step 10)

A `report_no_show` does NOT immediately affect the public `reputation_score`. Instead:

```
report_no_show() → inserts meetup_outcome with status='pending_dispute'
                   → starts a 48-hour evidence window
                   → notifies the accused party ("X reported you as a no-show")
```

During the 48-hour window:
- The accused can **accept** (the no-show is confirmed) or **dispute** (elevates to review)
- If the accused does nothing in 48 hours, the report **EXPIRES** — no penalty applies
  (decision 2026-08-13: silence must not confirm. A no-show report creates public
  negative reputation, and for travellers silence usually means "didn't see the
  notification" — different timezone, no roaming, phone dead. Auto-confirm would
  bake a false-positive generator into the reputation system, and `report_no_show`
  remains unilateral, so the griefing surface must stay small.)
- **Repeated reported-and-unanswered events feed a private moderation signal**, not
  a public mark — a user who accumulates expired unanswered reports gets flagged for
  moderation review, but nothing appears on their public profile
- The reporter cannot retract (prevents retaliation gaming)

### Phase 2 — Human review (v0.2, post-launch)

If the accused disputes, the outcome moves to `status='under_review'`:
- A human moderator (or a simple rules-engine initially) reviews:
  - Did the accused have location data near the meetup venue?
  - Were there messages exchanged near `meetup_time`?
  - Has the reporter filed disproportionate no-show reports? (rate limit)
- Decision: confirm (penalty stands) or dismiss (penalty dropped, reporter's trust score adjusted)

### Why two phases

Phase 1 is the minimum viable dispute surface — it prevents unilateral marking without requiring a moderation team. Phase 2 adds the review layer once volume justifies it.

---

## Schema changes (for implementation — not in this design gate)

```sql
-- meetup_outcomes.status enum extension
ALTER TYPE meetup_outcome_status ADD VALUE IF NOT EXISTS 'pending_dispute';
ALTER TYPE meetup_outcome_status ADD VALUE IF NOT EXISTS 'under_review';

-- The report_no_show RPC changes:
--   BEFORE: directly sets status='completed', outcome='no_show'
--   AFTER:  sets status='pending_dispute', starts 48h timer
-- A pg_cron job EXPIRES unanswered reports after 48h (status='expired', no penalty)
-- and increments a private moderation counter on the accused.
```

---

## Impact on public reputation (web step 10)

**Rule: only confirmed no-shows (status='completed') affect the public reputation score.**
- `pending_dispute` outcomes are invisible to the public surface
- `under_review` outcomes are invisible to the public surface
- Only `completed` + `outcome='no_show'` reduces reputation

This means the web profile's `reputation_score` only reflects resolved outcomes, never accusations.

---

## Sign-off

✅ **Decided 2026-08-13 (Anthony):**
1. **48 hours** is the evidence window.
2. **Auto-confirm-on-inaction: REJECTED.** Silence expires the report — no public penalty. Repeated reported-and-unanswered events feed a private moderation signal instead.
3. Phase 2 scope deferred to implementation time (manual review first).

This design gate is **CLOSED** — the design is agreed and web step 10 (public reputation surfacing) is unblocked from this side. Implementation lands in Phase B reward-fn v0.1.1.

---

## References

- Current unilateral implementation: `supabase/migrations/20260706100000_phase_a_no_show_cancel.sql`
- Reward function spec: `docs/reward-function-v0.1.md`
- Audit finding: `docs/reports/full-project-audit-2026-07-07.md:93` (P2: "reputation-griefing vector")
- EXECUTION_ORDER gate: `docs/EXECUTION_ORDER.md:142` ("H.5's dispute design gates step 10")
