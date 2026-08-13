# Reward Function — v0.1

> Status: **Active** · Implemented by `public.reputation_score(p_user_id)` in `supabase/migrations/20260630145537_phase_a_meetups_reputation.sql`.
> Authority: `docs/FOUNDATIONS.md` §4 (reward = outcomes, never engagement).
> This is a **versioned artifact** — change the version when the formula changes. Reputation is derived; it is the IP and the ethical spine.

## Purpose
The single rule that decides which behavior the platform rewards. Optimizing an
engagement proxy produces addiction + enshittification (FOUNDATIONS §6, §7.5); this
function optimizes **real-world outcomes** only.

## Inputs (v0.1)
| Signal | Source | Weight |
|---|---|---|
| Meetup completed | `meetup_outcomes.outcome = 'completed'` | **+2** each |
| Vouch rate | `member_reviews.would_meet_again` (share of reviews) | **+(vouch_pct / 10)** |
| Review rating | `member_reviews.rating` (1–5) | reported (avg), not yet weighted into score |
| No-show | `meetup_outcomes.outcome = 'no_show'` | **−1** each — **wired (Story A.4, 2026-07-06)** via the `report_no_show` RPC. Attribution: the penalty lands on `meetup_outcomes.no_show_user_id` (the absent party) **only** — the traveler who showed up and reported takes no penalty. Cancellations (`cancel_meetup`) are no-fault in v0.1: no outcome row, no penalty. |

**v0.1 score** = `2 × meetups_completed + floor(vouch_pct / 10) − no_shows`.

## NEVER inputs (hard rule)
Session length · scrolls · taps · feed impressions · DAU · time-in-app · any
engagement proxy. These are **banned** from the reward function (FOUNDATIONS §6).

## v0.1.1 — unblocked, not yet wired

> **Corrected 2026-08-13.** This section deferred the block/report penalty
> "pending table confirmation" and named `blocked_users` and `message_reports`.
> Those are the **phantom** tables from Stories 0.6 / 0.7 — they never existed.
> The confirmation had already happened; the answer was "these do not exist", and
> the deferral was never revisited against the tables that *do*.
>
> Verified against prod 2026-08-13: `blocks` ✅ · `reports` ✅ ·
> `blocked_users` ❌ · `message_reports` ❌.
>
> **The dependency is therefore satisfied.** Both signals are available now.

- **− blocks** (`public.blocks`) and **− reports** (`public.reports`, polymorphic
  via `target_id` + `target_type`): penalty weighted by severity. Ready to wire
  into `reputation_score()`.
- **+ repeat meetups** (same pair meeting again): a stronger positive signal than a
  first meetup. Needs a "repeat pair" count over `meetup_outcomes`.

**Sequencing note.** The existing `−1` no-show penalty and any new block/report
penalty are *negative reputation*, and `EXECUTION_ORDER` step 10 gates public
negative reputation on **H.5's dispute design**. Wire the signals when ready, but
surfacing them publicly waits on that sign-off.

## Why this is the moat
Incumbents cannot retrain on meetup outcomes — they don't have this data. Every
completed meetup + vouch makes the next match better and the reputation more
trustworthy (FOUNDATIONS §4: serve → log → train). The reward function is how we
encode "we optimize for hikes taken, not minutes scrolled."

## Verification (see migration tests)
`supabase/tests/database/meetups_reputation.test.sql` asserts `reputation_score`
returns sane values for a fixture user (meetups_completed, vouch_pct, score).
