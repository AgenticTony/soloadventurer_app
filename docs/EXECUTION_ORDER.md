# SoloAdventurer — Cross-Repo Execution Order

**One linear sequence across both repos.** The two projects share the FOUNDATIONS §9 phase spine (0 → A → B → C → D → E) but each has its own sprint plan, because they have different jobs (web = acquisition, mobile = product + shared backend). This document flattens both into a single "do this next" order so there's never ambiguity about which repo to work in.

> **Created:** 2026-07-05 · **Source of truth for _what_:** `docs/FOUNDATIONS.md` §9. This doc governs _order_ only. Mirror it into the mobile repo (like FOUNDATIONS) so both sides read the same sequence.

---

## How to read this

- Each step is tagged **[MOBILE]**, **[WEB]**, or **[BOTH]**.
- Steps are in dependency order — do them top to bottom. Where two adjacent steps have no dependency between them, they can run **in parallel** (noted).
- **The one cross-repo rule:** for phases A–E, **mobile builds the capability, web consumes it.** So mobile's phase of a given letter precedes web's phase of the same letter. Phase 0 is the exception — its web and mobile work are largely independent.
- **Sequencing decision (2026-07-05):** keep FOUNDATIONS §9 order — the AI flywheel (Phase B) is built before the growth surface (Phase E). Consequence: referral/SEO arrive late, on purpose. Not re-litigated here.
- ⚠ = safety-sensitive or human-gated (needs sign-off; the loop must not auto-ship it).
- After each step is done, commit, push to GitHub, and merge the PR. Make sure all checks pass first b4 you merge.
- Make sure all docs are up-to-date (see `docs/` folder). after each step is done. /Users/anthonyforan/Desktop/SoloAdventurerWeb/docs/sprints
- Reference all docs before completing tasks. /Users/anthonyforan/Desktop/SoloAdventurerWeb/docs/
- Use all the tools, skills, mcp servers and pluggins available to you.
- ALWAYS REFERENCE OFFICIAL DOCUMENTATION BEFORE COMPLETING ANY TASKS USING WEB SEARCH TOOLS AVAILABLE TO YOU.

## Current status (start line)

- ✅ **Mobile PR #8** — Phase A backend (meetups/outcomes/reputation) merged.
- ✅ **Mobile PR #10** — Supabase CI repair — **merged 2026-07-05**, all 17 checks green, pgTAP passing for the first time (12 pre-existing defects fixed; see the PR's closing comment). ⚠ Prod note: run `supabase migration repair --status applied` for the already-live 2026 migrations before the first real `supabase db push`.
- ✅ **Landing-page fix** (web Story 0.4) — merged (web PR #17).
- ✅ **Doc-cleanup PRs** (web #15/#16) — merged.
- ✅ **Mobile PR #13 (step 4 — A.4)** — `report_no_show` + `cancel_meetup` RPCs — **merged 2026-07-06**, closes reward-fn v0.1 (no-show penalty now wired + attributed to the absent party). pgTAP 22→36. Phase A backend fully shipped.
- 🔶 **Credential purge** (mobile 0.1, step 3) — in progress, Anthony-owned. Still gates launch.

**Start here:** step 9 (mobile Phase A finish — north-star city/time indexes; decide the deferred `events` table) unblocks now. Steps 5 (mobile analytics ⚠), 7 (mobile safety ⚠), 8 (web privacy/RLS audit ⚠) remain human-gated per the ⚠ rule. Step 9's city index needs a data-model decision first (`meetups` has no city column — where does city come from: meetup location geocode vs. a new column?).

---

## The master order

### Stage 0 — Right to launch + make it measurable _(do now)_

| #   | Repo      | Do                                                                                   | Depends on                  | Notes                                                                 |
| --- | --------- | ------------------------------------------------------------------------------------ | --------------------------- | --------------------------------------------------------------------- |
| 1   | MOBILE    | Merge **PR #10** (Supabase CI repair)                                                | —                           | Unblocks every future backend/migration PR.                           |
| 2   | WEB       | **Story 0.4** — remove the `/`→`/discover` redirect (landing reachable)              | —                           | ~1 hr, independent. Parallel with 1 & 3.                              |
| 3   | MOBILE ⚠ | **0.1** — purge/rotate leaked credentials                                            | —                           | P0. Blocks _launch_, not _dev_. Anthony-owned, in progress. Parallel. |
| 4   | MOBILE ⚠ | **A.4** — `report_no_show` + proposer-cancel RPCs (close reward-fn v0.1)             | 1 (it's a migration)        | Finishes Phase A backend.                                             |
| 5   | MOBILE ⚠ | **0.3** — analytics + lock `meetups_completed` north-star                            | —                           | Instrument _before_ users.                                            |
| 6   | WEB       | **0.1** — web analytics: visits→install→meetup funnel                                | 5 (shared north-star event) | Parallel with 7.                                                      |
| 7   | MOBILE ⚠ | **0.2** — production-grade safety (SOS / check-ins / meetup safety)                  | —                           | Before strangers meet offline.                                        |
| 8   | WEB ⚠    | **0.2 + 0.3** — public-page privacy/RLS audit; confirm web holds no service-role key | 2                           | Before web goes public.                                               |

### Stage A — Reputation exists → make it visible _(mobile done → web consumes)_

| #   | Repo   | Do                                                                                                    | Depends on       | Notes                                       |
| --- | ------ | ----------------------------------------------------------------------------------------------------- | ---------------- | ------------------------------------------- |
| 9   | MOBILE | **Phase A finish** — north-star city/time indexes; decide the deferred `events` table                 | 4                | Backend mostly shipped (PR #8).             |
| 10  | WEB ⚠ | **Phase A** — consume `reputation_score` on public `/profile/[username]`; scaffold public share pages | 9 (tables exist) | **Now unblocked.** Read-only, RLS-verified. |

### Stage B — Close the AI loop _(§9: moat before growth)_

| #   | Repo   | Do                                                                                | Depends on                        | Notes                                                                         |
| --- | ------ | --------------------------------------------------------------------------------- | --------------------------------- | ----------------------------------------------------------------------------- |
| 11  | MOBILE | **Phase B** — outcome-trained ranker (L1 behavioral vectors + L2 learned weights) | Real Phase-A outcomes to train on | Don't start until meetup volume exists; heuristic matcher is fine until then. |
| 12  | WEB    | **Phase B** — social proof from real outcomes; thin matcher consume on discover   | 10 + 11                           | No fake counts (§6).                                                          |

### Stage C — Agent layer

| #   | Repo      | Do                                                             | Depends on           | Notes                                       |
| --- | --------- | -------------------------------------------------------------- | -------------------- | ------------------------------------------- |
| 13  | MOBILE ⚠ | **Phase C** — concierge → guardian → moderation-at-creation    | 11                   | Safety-sensitive (guardian, moderation).    |
| 14  | WEB       | **Phase C** — concierge lead-capture (top-of-funnel → install) | 13 + reputation data | Teaser only; no real matches to anon users. |

### Stage D — Trust made visible

| #   | Repo      | Do                                                                                                                        | Depends on | Notes                                                                                                               |
| --- | --------- | ------------------------------------------------------------------------------------------------------------------------- | ---------- | ------------------------------------------------------------------------------------------------------------------- |
| 15  | MOBILE ⚠ | **Phase D** — reputation surfacing; scam/anomaly detection; persistent memory                                             | 9 + 13     | Safety-sensitive.                                                                                                   |
| 16  | WEB ⚠    | **Phase D** — reputation/verified badges on profiles; OG share previews; **trusted-contact check-in page (viral Loop 1)** | 15         | Loop 1 (D.3) can start earlier — it needs only the existing safety pillar, not later phases. Signed/expiring links. |

### Stage E — Open the growth taps _(last, per §9)_

| #   | Repo      | Do                                                                                               | Depends on         | Notes                                                                                             |
| --- | --------- | ------------------------------------------------------------------------------------------------ | ------------------ | ------------------------------------------------------------------------------------------------- |
| 17  | WEB ⚠    | **Phase E** — SEO city pages; referral landing (status/utility, not cash); indexable share pages | Real data from A–D | Thin programmatic pages die post-Google-HCU; these must be backed by real reputation/meetup data. |
| 18  | MOBILE ⚠ | **Phase E** — conversational discovery; city-by-city GTM; agent-to-agent reputation              | 17 + A–D           | GTM _uses_ the web referral/SEO surface, so web E precedes it.                                    |

---

## What can run in parallel

- **Stage 0** is the most parallel: steps 1 (PR #10), 2 (web landing), 3 (secrets, Anthony), and 5/7 (mobile analytics/safety) have no dependencies on each other.
- **Within each of Stages A–E:** once the mobile step of a phase ships, its web step and the _next_ phase's mobile prep can overlap.
- **Serial choke points:** PR #10 (step 1) gates all later backend work; mobile Phase B (step 11) gates Stages C–E; the credential purge (step 3) gates real-user launch regardless of dev progress.

## The dependency rationale in one paragraph

The backend lives in the mobile repo and the web repo only reads it, so any capability appears in mobile first and in web second — that's why the order alternates mobile→web within every phase from A onward. Phase 0 is the exception because its tasks (landing fix, analytics, secrets, safety) don't cross the repo boundary. And because neither repo's loop/verifier can see the other, **every backend change must be cross-checked against web's typed consumers before it merges** (the `get_reputation`/`reputation_score` drift was exactly this class of bug). Keep the shared coupling map in mobile's `sprint-progress.json` (`web_integration`) current as the single place that records the seam.
