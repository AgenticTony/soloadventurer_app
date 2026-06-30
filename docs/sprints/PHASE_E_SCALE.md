# Phase E — Scale

> FOUNDATIONS §9 (Phase E), §12 · Repo: mobile · Safety-sensitive: varies
> Status: queued after Phase D. Scale + future-proofing. Some stories are exploratory.

## Goal
Scale the product and harden it for the next platform shift: city-by-city atomic-network GTM, conversational discovery, agent-to-agent reputation, and AI community management (once groups exist).

## Scope
**IN:** conversational discovery; agent-to-agent reputation (exploratory); AI community manager (post group-formation).
**OUT:** the core loop (Phases A–D must be solid first).
**Guardrails (§6, §12):** agent-readable surfaces (MCP/API) so assistants don't disintermediated us; no synthetic liquidity.

## Stories

### Story E.1 — Conversational discovery
- [ ] Natural-language matching ("a hiking partner in Lisbon this week") → AI assembles matches
- [ ] Replaces the passive browse with an active ask (FOUNDATIONS §7.14)

### Story E.2 — Agent-to-agent reputation (exploratory)  [needs_human: true]
- [ ] Machine-readable reputation layer (so users' agents can act on it)
- [ ] Prototype only — the reputation/identity layer for agents is unowned infrastructure (§12.5)

### Story E.3 — AI community manager  [needs_human: true]
- [ ] Once group-formation surfaces ship (Reed's Law, §5): AI onboarding, thread summaries, introductions
- [ ] Legible + contestable governance (§8.4, §12.9)

### Story E.4 — City-by-city atomic-network GTM  [needs_human: true]
- [ ] Per-city launch discipline (seed supply → trigger demand → saturate → next city)
- [ ] Local-liquidity dashboard (FOUNDATIONS §11.7, §10.2 — atomic network per city)

## Definition of Done / Acceptance Criteria
- [ ] Conversational discovery returns relevant matches
- [ ] Agent reputation prototype demonstrable
- [ ] GTM playbook + per-city density metric defined
- [ ] `flutter analyze` clean; tests green

## Dependencies
Phases A–D. This phase is open-ended / exploratory; stories may re-scope as the product matures.
