# Phase C — Agent Layer

> FOUNDATIONS §4 (L3), §9 (Phase C) · Repo: mobile · Safety-sensitive: **YES** (guardian + moderation)
> Status: queued after Phase B. The AI-native UX. (Supersedes the old `SPRINT_6.7` safety-enhancement scope — guardian stays `safety:true`, loop never auto-touches.)

## Goal
Ship the three agent surfaces that make the product AI-native: the **concierge** (removes the cold-start "hello"), the **guardian** (AI safety around meetups), and **moderation at creation** (screen before delivery, not after).

## Scope
**IN:** concierge Edge Function (draft intro + suggest meetup from overlap); guardian (meetup risk-scoring + active-safety); moderation moved server-side, pre-delivery.
**OUT:** reputation surfacing UI (Phase D); conversational discovery (Phase E).
**Guardrails (§6):** no decorative AI — these are in the core loop, not a chatbot tab; safety is the substrate.

## Stories

### Story C.1 — Concierge (draft intro + suggest meetup)  [needs_human: true]
- [ ] Edge Function: from overlapping itinerary + complementary intent → propose a plan + draft invite
- [ ] UX: user reviews/edits/sends (never auto-send)
- [ ] Tests: drafts are grounded in real overlap; no hallucinated facts

### Story C.2 — Guardian (meetup risk-scoring)  [safety: true]
- [ ] Risk-score every proposed meetup (new connection + remote + off-hours → nudge location-share / check-in / trusted-contact)
- [ ] Integrate with the existing safety pillar (SOS, check-ins, live location)
- [ ] Tests: risk thresholds behave; never blocks, only nudges + arms safety

### Story C.3 — Moderation at creation (server-side, pre-delivery)  [safety: true]
- [ ] Move moderation from client (`message_moderation_service`) to a server Edge Function, **pre-delivery**
- [ ] Screen messages + meetup proposals for scam / harassment / grooming before they land
- [ ] Appeal path (FOUNDATIONS §8.4 — "show me why this was removed")

## Definition of Done / Acceptance Criteria
- [ ] Concierge drafts reviewable intros grounded in real overlap
- [ ] Guardian risk-scores before every meetup; safety features armed
- [ ] Moderation screens pre-delivery with an explainable appeal path
- [ ] `flutter analyze` clean; tests green; no regression to baseline

## Dependencies
Phase B (better matcher feeds the concierge). Feeds Phase D (trust surfacing).
