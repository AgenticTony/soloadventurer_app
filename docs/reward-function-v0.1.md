# Reward Function — v0.1.1

> Status: **Active** · Implemented by `public.reputation_score(p_user_id)`, defined in
> `supabase/migrations/20260630145537_phase_a_meetups_reputation.sql` and extended by
> `20260814000000_reputation_block_report_penalties.sql` (v0.1.1).
> Authority: `docs/FOUNDATIONS.md` §4 (reward = outcomes, never engagement).
> This is a **versioned artifact** — change the version when the formula changes. Reputation is derived; it is the IP and the ethical spine.

## Purpose
The single rule that decides which behavior the platform rewards. Optimizing an
engagement proxy produces addiction + enshittification (FOUNDATIONS §6, §7.5); this
function optimizes **real-world outcomes** only.

## Inputs (v0.1.1)
| Signal | Source | Weight |
|---|---|---|
| Meetup completed | `meetup_outcomes.outcome = 'completed'` | **+2** each |
| Vouch rate | `member_reviews.would_meet_again` (share of reviews) | **+(vouch_pct / 10)** |
| Review rating | `member_reviews.rating` (1–5) | reported (avg), not yet weighted into score |
| No-show | `meetup_outcomes.outcome = 'no_show'` | **−1** each — **wired (Story A.4, 2026-07-06)** via the `report_no_show` RPC. Attribution: the penalty lands on `meetup_outcomes.no_show_user_id` (the absent party) **only** — the traveler who showed up and reported takes no penalty. Cancellations (`cancel_meetup`) are no-fault in v0.1: no outcome row, no penalty. |
| Upheld report | `reports.outcome = 'upheld'`, `target_type = 'profile'` | **−1** per **distinct reporter** — wired 2026-08-14. Only `upheld` counts (see below). |
| Block | `blocks` | **Not scored.** Feeds `moderation_risk_signal()` instead — see "Why blocks are not in the score". |

**v0.1.1 score** = `2 × meetups_completed + floor(vouch_pct / 10) − no_shows − upheld_reports`.

## NEVER inputs (hard rule)
Session length · scrolls · taps · feed impressions · DAU · time-in-app · any
engagement proxy. These are **banned** from the reward function (FOUNDATIONS §6).

## Why only *upheld* reports count

`reports` carries `resolved` — a moderator closed it — but that is not a verdict.
Scoring it would have penalised people whose reports were **dismissed**, and
scoring *unresolved* reports would have made reputation griefable: anyone willing
to file a report could lower a stranger's score. Migration `20260814000000`
therefore adds `reports.outcome` (`pending` / `upheld` / `dismissed`) and scores
`upheld` only.

Today that evaluates to **zero for everyone**, because no moderation path sets it
yet. That is the intended starting state — the signal is wired and inert, rather
than live and abusable. Building the adjudication UI is what turns it on.

Penalties count **distinct reporters**, so one determined person (or one person
with sockpuppets) cannot compound the penalty by filing repeatedly.

## Why blocks are not in the score

Blocks are a real misconduct signal but a poor *public* one, for three reasons:

1. **They are not adjudicated.** People block for many reasons that are not
   misconduct.
2. **They are trivially griefable.** Unlike a report, nothing reviews a block.
3. **Surfacing them leaks.** `reputation_score()` is `EXECUTE`-able by
   `authenticated`, so any signed-in user can call it for any user id. A block
   count in that payload would let a blocked person infer they had been blocked —
   exactly what blocks are designed not to reveal, on the feature a harassed user
   depends on.

Blocks therefore feed `public.moderation_risk_signal(uuid)`, which is
`service_role` only and reports `distinct_blockers`, `upheld_reports`,
`pending_reports` and an advisory `risk_flag`. Moderation tooling can use it; the
public score cannot see it.

## Still open

- **+ repeat meetups** (same pair meeting again) — a stronger positive signal than
  a first meetup. Needs a "repeat pair" count over `meetup_outcomes`.
- **Severity weighting** for reports. The flat −1 is honest about what we can
  currently distinguish: report categories carry no severity of their own yet.
- **Review rating** is reported (`avg_rating`) but still not weighted into the
  score.

**Sequencing.** No-shows and upheld reports are *negative reputation*, and
`EXECUTION_ORDER` step 10 gates public negative reputation on **H.5's dispute
design**. The signals are wired; surfacing them publicly waits on that sign-off.

## Why this is the moat
Incumbents cannot retrain on meetup outcomes — they don't have this data. Every
completed meetup + vouch makes the next match better and the reputation more
trustworthy (FOUNDATIONS §4: serve → log → train). The reward function is how we
encode "we optimize for hikes taken, not minutes scrolled."

## Verification (see migration tests)
`supabase/tests/database/meetups_reputation.test.sql` asserts `reputation_score`
returns sane values for a fixture user (meetups_completed, vouch_pct, score).
