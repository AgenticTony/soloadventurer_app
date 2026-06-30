# Reward Function — v0.1

> Status: **Active** · Implemented by `public.reputation_score(p_user_id)` in `supabase/migrations/20260630145537_phase_a_meetups_reputation.sql`.
> Authority: `docs/FOUNDATIONS.md` §4 (reward = outcomes, never engagement).
> This is a **versioned artifact** — change the version when the formula changes. Reputation is derived; it is the IP and the ethical spine.

## Purpose
The single rule that decides which behavior the platform rewards. Optimizing an
engagement proxy produces addiction + enshittification (FOUNDATIONS §6, §7.5); this
function optimizes **real-world outcomes** only.

## Inputs (v0.1 — wired now)
| Signal | Source | Weight |
|---|---|---|
| Meetup completed | `meetup_outcomes.outcome = 'completed'` | **+2** each |
| Vouch rate | `member_reviews.would_meet_again` (share of reviews) | **+(vouch_pct / 10)** |
| Review rating | `member_reviews.rating` (1–5) | reported (avg), not yet weighted into score |
| No-show | `meetup_outcomes.outcome = 'no_show'` | **−1** each |

**v0.1 score** = `2 × meetups_completed + floor(vouch_pct / 10) − no_shows`.

## NEVER inputs (hard rule)
Session length · scrolls · taps · feed impressions · DAU · time-in-app · any
engagement proxy. These are **banned** from the reward function (FOUNDATIONS §6).

## Deferred to v0.1.1 (pending table confirmation)
- **− blocks** (`blocked_users`) and **− reports** (`reports` / `message_reports`):
  penalty weighted by severity. Wiring deferred until those tables are confirmed
  in the mobile schema and added to `reputation_score()`.
- **+ repeat meetups** (same pair meeting again): a stronger positive signal than a
  first meetup. Needs a "repeat pair" count over `meetup_outcomes`.

## Why this is the moat
Incumbents cannot retrain on meetup outcomes — they don't have this data. Every
completed meetup + vouch makes the next match better and the reputation more
trustworthy (FOUNDATIONS §4: serve → log → train). The reward function is how we
encode "we optimize for hikes taken, not minutes scrolled."

## Verification (see migration tests)
`supabase/tests/database/meetups_reputation.test.sql` asserts `reputation_score`
returns sane values for a fixture user (meetups_completed, vouch_pct, score).
