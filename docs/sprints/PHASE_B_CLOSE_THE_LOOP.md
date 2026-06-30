# Phase B — Close the Loop

> FOUNDATIONS §4, §9 (Phase B) · Repo: mobile · Safety-sensitive: NO (core matching logic)
> Status: queued after Phase A. This is the "could not exist in 2015" bar (AI Leverage 2→3).

## Goal
Close the serve → log → train loop: replace static, self-described profile embeddings with **outcome-derived behavioral vectors**, and replace the hand-tuned matching heuristics with an **outcome-trained ranker**. Matches now improve from results.

## Scope
**IN:** wire match outcomes into the matcher; outcome-derived behavioral embeddings (extend L1); outcome-trained ranker replacing the heuristic weights in `find-potential-matches-semantic` (L2).
**OUT:** agents (Phase C); reputation UI (Phase D).
**Guardrails (§4, §7.5):** the reward function is the moat; the metric you optimize is the behavior you get.

## Stories

### Story B.1 — Outcome-capture wired into the matcher
- [ ] Emit outcome events (accepted / rejected / met / no-show / blocked) from the match flow → L0
- [ ] Verify the loop: serve → log → available for re-rank

### Story B.2 — Outcome-derived behavioral embeddings (L1)
- [ ] Extend the embedding pipeline (`generate-profile-embedding`) to incorporate behavioral signal
- [ ] A user's vector reflects *who they actually met/got-along-with*, not just profile text
- [ ] pgvector re-index strategy; backfill plan

### Story B.3 — Outcome-trained ranker (L2)
- [ ] Replace the hand-tuned weights in `supabase/functions/find-potential-matches-semantic/index.ts`
      (country +0.5, destination 0.10, exact 1.0, etc.) with outcome-trained scoring
- [ ] Keep the structured *features* (date/activity/destination overlap) as model inputs; learn the weights
- [ ] A/B guardrail: new ranker must not regress `meetups_completed` rate vs heuristic baseline

## Definition of Done / Acceptance Criteria
- [ ] Matcher re-orders based on outcomes (measurable on a held-out set)
- [ ] Embeddings updated from outcomes, not just profile text
- [ ] Heuristic weights removed/replaced; features retained
- [ ] `meetups_completed` rate ≥ baseline; `flutter analyze` clean; tests green

## Dependencies
Phase A (L0 outcomes + reward fn). Feeds Phase C (concierge uses the better matcher).
