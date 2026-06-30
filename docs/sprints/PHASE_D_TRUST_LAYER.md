# Phase D — Trust Layer

> FOUNDATIONS §4 (L4), §9 (Phase D) · Repo: mobile · Safety-sensitive: YES (trust/authenticity)
> Status: queued after Phase C. The moat that compounds.

## Goal
Make trust the visible, scarce good: surface reputation, detect scams/fakes at the edge, and give the product persistent memory. This is where "real, verified, vouched-for" becomes the brand (FOUNDATIONS §1, §8.3, §12.8).

## Scope
**IN:** reputation score on profile + match cards; scam/anomaly detection; persistent "travel AI" memory.
**OUT:** agent-to-agent reputation (Phase E, exploratory); group surfaces (separate group-formation work).
**Guardrails (§7):** photos shown are provenance-verified real captures; "verified human" is first-class.

## Stories

### Story D.1 — Reputation surfacing
- [ ] Reputation score (from Phase A outcomes) on profile + match cards
- [ ] Vouch badges, repeat-meetup rate, mutual-vouch display
- [ ] "Verified human" (Onfido) elevated on match cards

### Story D.2 — Scam / anomaly detection  [safety: true]
- [ ] Behavioral anomaly detection (scammer patterns, fake-account signals)
- [ ] Provenance checks on photos (EXIF/geocode; reject/flag AI-fake travel photos per §7)
- [ ] Human-review queue for flagged accounts

### Story D.3 — Persistent memory (travel AI)
- [ ] Long-term user memory (trips, preferences, past connections) — RAG-style
- [ ] Memory is opt-in / consented; portable-export + delete (FOUNDATIONS §8.8)
- [ ] Memory feeds the matcher + concierge (stateful, not stateless)

## Definition of Done / Acceptance Criteria
- [ ] Reputation visible on profile + match cards; verified-human elevated
- [ ] Anomaly detection flags scams; provenance rejects fake photos
- [ ] Memory persists across sessions; consent + export/delete work
- [ ] `flutter analyze` clean; tests green; baseline not regressed

## Dependencies
Phase A (reputation data) + Phase C (agents consume memory). Feeds Phase E.
