# Analytics & North-Star — v0.1

> Status: **Active** · Story: Phase 0 / 0.3 (`docs/sprints/PHASE_0_BLOCKERS.md`) · execution-order step 5.
> Authority: `docs/FOUNDATIONS.md` §6 (no engagement proxy as a north star) + §4 (the atomic unit).
> Versioned artifact — bump the version when the north-star definition or event taxonomy changes.

## Providers (decided 2026-07-06)
- **PostHog** (product analytics) — funnels, D1/D7/D30 retention cohorts, the north-star event. Flutter SDK `posthog_flutter ^5.30.0`. **EU Cloud** ingestion (`https://eu.i.posthog.com`) for GDPR data residency; host is env-configurable.
- **Sentry** (crash / error monitoring) — already a dependency (`sentry_flutter`). Different job; not the funnel tool. *(Sentry runtime init is a documented follow-up — see "Deferred".)*

## The north-star (locked)
**`meetup_completed`** — a mutually-confirmed, completed meetup.

- **Source of truth:** `public.meetup_outcomes.outcome = 'completed'` (written by the `complete_meetup` RPC when BOTH parties tap "we met"). This is FOUNDATIONS §4's atomic unit — a *verified* meetup, not a tap or a session.
- **NOT** sourced from `meetup_checkins` (the safety check-in state machine). The Phase 0 sprint text predated Phase A; this artifact supersedes it — see the reconciliation note in `PHASE_0_BLOCKERS.md`.
- **Authoritative emission is server-side.** Because the truth lives in `meetup_outcomes`, the canonical north-star event must be emitted from the database on insert of a `completed` outcome (same pattern as `20260407000000_push_notification_trigger.sql` → `net.http_post`), so it fires regardless of which client confirmed and is immune to client opt-out. **This server-side trigger is the deferred follow-up below**; until it lands, the client helper (`AnalyticsService` + `AnalyticsEvents.meetupCompleted`) is the interim emitter, wired to fire when a Dart caller of `complete_meetup` exists (none today — Phase A shipped backend-only).

## Funnel (client-side events)
visits → install → **activation** → **meetup**. The client instruments the in-app legs (the pre-install web legs are the web repo's step 6, keyed on the same north-star event):

| Stage | Event(s) | Notes |
|---|---|---|
| Install / first-open | `captureApplicationLifecycleEvents` (SDK) | app open, install, update |
| Activation | `sign_up`, `login`, `edit_profile`, `create_trip` | existing `AnalyticsEvents` constants |
| Intent | `send_connection_request`, `accept_connection` | connection is the pre-meetup step |
| **North-star** | **`meetup_completed`** | verified meetup (see above) |

Retention **D1/D7/D30** is computed by PostHog from `identify` + events (a PostHog cohort/retention insight) — **dashboard configuration, not app code**. Documented here; set up in the PostHog project.

## Privacy / consent (GDPR — hard rule)
- **Opt-in only.** The SDK initializes with `config.optOut = true`; **nothing is collected** until the user grants consent. Consent flips it via `Posthog().enable()`; withdrawal via `Posthog().disable()`.
- Consent state persists in `SharedPreferences` (`analytics_consent_granted`) behind `AnalyticsConsent` + a Riverpod provider; the app wires the concrete PostHog service through a `ConsentGatedAnalyticsService` decorator so **no event reaches PostHog while consent is absent**, independent of SDK state (defense in depth).
- **No PII in events.** `distinct_id` is the pseudonymous Supabase `auth.uid()`; `beforeSend` scrubs known sensitive keys. Email/phone/name are never event properties.

## NEVER inputs to any north-star or reward signal (FOUNDATIONS §6)
Session length · scrolls · taps · feed impressions · DAU · time-in-app. These may exist as *diagnostic* product metrics but are **banned** as the north-star — the north-star is a real-world outcome (a completed meetup), mirroring the reward function (`docs/reward-function-v0.1.md`).

## Deferred (follow-up stories, tracked in PHASE_0_BLOCKERS.md)
1. **Server-side authoritative north-star** — DB trigger / edge function on `meetup_outcomes` insert (`outcome='completed'`) → PostHog capture. This is the canonical emitter; the client helper is interim.
2. **Sentry runtime init** — `SentryFlutter.init` in bootstrap + route Flutter/zone errors through it (`sentry_flutter` is a dep but not yet initialized).
3. **D1/D7/D30 retention dashboard** — configure the PostHog retention insight (no app code).
4. **Wire funnel events into UI** — the event *constants* exist; call sites (screen views, create_trip, connection request) get instrumented as each feature's flow is touched.
