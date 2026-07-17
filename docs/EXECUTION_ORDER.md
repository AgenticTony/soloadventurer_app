# SoloAdventurer — Cross-Repo Execution Order

**One linear sequence across both repos.** The two projects share the FOUNDATIONS §9 phase spine (0 → A → B → C → D → E) but each has its own sprint plan, because they have different jobs (web = acquisition, mobile = product + shared backend). This document flattens both into a single "do this next" order so there's never ambiguity about which repo to work in.

> **Created:** 2026-07-05 · **Last updated:** 2026-07-16 · **Source of truth for _what_:** `docs/FOUNDATIONS.md` §9. This doc governs _order_ only. Mirror it into the mobile repo (like FOUNDATIONS) so both sides read the same sequence — **update both copies in the same change, or neither.**

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
- ✅ **Mobile PR #10** — Supabase CI repair — **merged 2026-07-05**, all 17 checks green, pgTAP passing for the first time (12 pre-existing defects fixed; see the PR's closing comment). ~~⚠ Prod note: run `supabase migration repair --status applied` for the already-live 2026 migrations before the first real `supabase db push`.~~ **OBSOLETE — do NOT do this.** Superseded by the 2026-07-15 repave (below): the live migration history is now clean and complete, so a `repair` would mark migrations applied that the repave already applied for real. The earlier repair plan was caught marking `sos_alerts` / `notification_tokens` as applied when those tables did **not** exist live — which would have skipped their creation on the next `db push` and silently broken the 9a SOS backend.
- ✅ **Landing-page fix** (web Story 0.4) — merged (web PR #17).
- ✅ **Doc-cleanup PRs** (web #15/#16) — merged.
- ✅ **Mobile PR #13 (step 4 — A.4)** — `report_no_show` + `cancel_meetup` RPCs — **merged 2026-07-06**, closes reward-fn v0.1 (no-show penalty now wired + attributed to the absent party). pgTAP 22→36. Phase A backend fully shipped.
- ✅ **Mobile PR #15 (step 5 — 0.3)** — PostHog analytics + consent gate + north-star **`meetup_completed` locked to `meetup_outcomes`** (reconciled from the stale `meetup_checkins`) — **merged 2026-07-06**. `docs/analytics-v0.1.md`.
- ✅ **Web (step 6 — 0.1)** — PostHog-js acquisition funnel + GDPR consent, **same PostHog project** as mobile — **merged 2026-07-06** (web PR #20).
- ✅ **Web (step 8 — 0.2/0.3 privacy/RLS audit)** — **merged 2026-07-06** (web PR #21). No service-role key; anon-key only; **fixed a PII leak** (`select('*')` on profiles → other users' email/phone/DOB) via a non-PII projection. Report: `docs/reports/web-privacy-rls-audit-2026-07-06.md`.
- ✅ **Mobile (step 7 — 0.2 safety audit)** — **merged 2026-07-06** (mobile PR #16). Safety surface is mature; tested the missed-check-in detector + **fixed a `dispose()` bug**. On-device/edge-load safety validation remains **human-led** (launch-gating). Report: `docs/reports/safety-hardening-audit-2026-07-06.md`.
- ✅ **Mobile PR #17 (step 9 — Phase A finish)** — north-star **TIME indexes** — **merged 2026-07-07**. **City cohort deferred** (`trips.destination_city` is a dead column — no city source exists yet); `events` table deferred to Phase B. Scope: `docs/design/step-9-phase-a-finish-scope.md`.
- 🔶 **Mobile 9b (Story 0.5 — RLS/PII repair) — LIVE in prod, 5/6.** Merged 2026-07-15 (PR #20 `USING (true)` drop + guarded SECURITY DEFINER matchers; PR #21 H.5 partial hardening; PR #22 / web PR #25 Batch-2 PII column privileges) and live via the repave. The **leak is dead in production** — verified: `authenticated` can read `username`, not `email`. **⚠ Open: the pgTAP proof is incomplete.** PII is proven (20 assertions), but **block-list and women-only gating have ZERO pgTAP coverage** — the exact gating the audit said `USING (true)` had nullified. The **women-only clause is testable now**; the **block clause is blocked on 9d** (proving block gating is meaningless while nothing can create a block row). **This gates step 10** (see the Stage A note).
- 🔶 **Mobile 9a (Story 0.4 — SOS backend) — blocker cleared, story 3/7.** Merged + deployed 2026-07-16 (PR #23 client wiring → `trigger-sos`; PR #25 edge-function repair: contact columns + notification targeting); prod == `main`. **The audit's P0 is resolved — the SOS button reaches Supabase and reports honestly.** But the phantom stack was **not** deleted: PR #23 patched the SOS method inside the existing data source, so `lib/` still holds **8 `api.soloadventurer.com` references** (DoD demands zero), 4 `_apiClient` calls for check-ins/contacts/location, `MockSafetyRemoteDataSource` in `lib/`, and `profile_repository_impl.dart:167` still POSTing `/graphql`. **Removal → PHASE_H (10c).** **👤 On-device validation still launch-gating.**
- ✅ **Web 9c/W.1a (step 9c — PHASE_W first slice)** — Next 15→16, React 18.2→19.2, ESLint 9 flat config — **merged 2026-07-15** (web PR #24). **PHASE_W overall is 3/24** — see below.
- 🔶 **Credential purge** (mobile 0.1, step 3) — **3/5. Rotation AND revocation are DONE** (service-role key confirmed 2026-07-15; AWS / OpenAI / Resend / Twilio / GitHub+GitLab PATs rotated and old keys revoked at the providers — confirmed by Anthony 2026-07-16). **Git-history purge (~561 commits) still open** — Anthony-owned. Now a **lower-severity cleanup**: history holds only **dead** credentials, so it stopped being a `db push` or launch blocker. Note the scan box **cannot** go green until the purge does, and **CI's GitGuardian check scans the diff, not history** — a green PR check is not evidence history is clean.

> **🚨 NEW LAUNCH BLOCKER 2026-07-16 — step 9d: blocking does not exist.**
> Found while attempting 9b's block pgTAP. **The block feature is non-functional on both surfaces**
> — not buggy, _absent_: web's block code (4 call sites in `src/contexts/PrivacyContext.tsx` +
> `src/components/moderation/BlockDialog.tsx`) writes to **`blocked_users`, a table that does not
> exist** (live prod has `blocks`, confirmed via `information_schema`); web never references `blocks`
> once; `BlockDialog` is imported by nothing; `blockUser` is called only from its own test; and
> mobile has **no block path at all**. The web test passes because it **mocks the Supabase client**.
> **Consequence:** `are_users_blocked()` can never return true in prod, so the block clause in
> `profiles_read_potential_matches` guards an empty table — a user cannot protect themselves from a
> harasser. Launch-gating on a trust platform whose core strategy is women-only mode.
> **Not a leak** (nothing over-exposed; 0 users post-repave) — a missing safety capability.
> **Same failure mode as 9a** (phantom SOS backend): table + policy + component + API + green tests,
> wired to a backend that isn't there. The 2026-07-07 audit caught the pattern for SOS and missed it
> here. **Both repos.** Full detail + acceptance criteria: mobile `PHASE_0_BLOCKERS.md` **Story 0.6**.

> **🚨 NEW LAUNCH BLOCKER 2026-07-16 — step 9e: phantom schema references (the class behind 9a + 9d).**
> Sweeping every `.from()`/`.rpc()` in both repos against the schema found **11 phantom targets across
> 27 call sites** — code querying relations/RPCs that no migration creates and that are **absent from
> prod**. **9a and 9d are two instances of this one defect.** Invisible to CI because the suites
> **mock the Supabase client** — a mock answers to any name you invent.
> **The top three are things FOUNDATIONS names as strategic assets:** `shared_meetups` (§5 KEEP —
> _"the differentiator"_; `ShareMeetupScreen` is a live route and its write fails);
> `message_reports`/`message_moderation` (§5 REFACTOR — _"the incumbent-can't-do wedge"_; **reporting
> a harmful message writes nowhere**); and `chats` in `notify-new-message`, which is **trigger-invoked
> on every message insert** — **push notifications are broken in prod**.
> **This repo's share:** `blocked_users` (4 sites) + **web's entire trip CRUD** — `create_trip`,
> `get_trip_by_id`, `list_my_trips` (`src/lib/api.ts`) are all absent. **That gates step 10's public
> trip pages.**
> **With 9d, three safety controls do not function: block, report, share-meetup.** Not a data leak —
> nothing over-exposed, 0 users post-repave — a **missing-capability** and completion-honesty problem.
> **Fixes:** mobile ships a CI ratchet (`scripts/check-schema-refs.py`); **web's real fix is W.2
> generated types** — a typed client makes all 4 web phantoms `tsc` errors **and** catches column
> defects a scanner cannot. **Second independent argument for doing W.2 first.**
> Report: mobile `docs/reports/phantom-schema-refs-2026-07-16.md` · `PHASE_0_BLOCKERS.md` Story 0.7.

> **🔁 PROD REPAVED 2026-07-15 — the "CI green ≠ deployed" gap is closed.**
> Prod had drifted badly: Phase A was never deployed, another project's migrations sat in the
> live history (stray `jobs` table), and the live `profiles` RLS was dashboard-era. Fixed by a
> clean repave (`supabase db reset --linked`) — **prod now matches the repo** (27 migrations
> applied; Phase A / `sos_alerts` / `notification_tokens` present; foreign `jobs` gone; the
> `USING (true)` leak and the PII REVOKEs are **live, not just in CI**). Blocked once on
> unqualified `uuid_generate_v4()`; fixed via mobile PR #24 (`gen_random_uuid()`), merged so
> `main`/CI carry it. **Cost:** prod data was truncated (`auth.users`, `profiles`, `trips` all 0 —
> was 2 profiles / 5 trips of test data; dumped to `backup_*.sql`). **Test accounts must be
> recreated.** Plan/verification: `docs/reports/prod-db-reconciliation-plan-2026-07-15.md`.
> **Standing rule this cost us:** "merged" ≠ "live" — verify every backend claim against prod.

**Stage 0 closed** (steps 1–8 merged). **Stage 0.5 — the two original audit P0 _blockers_ are cleared,
but neither story is finished (9a is 3/7, 9b is 5/6), and a THIRD blocker (9d) has replaced them as
the open one.** Phase 0 overall: `PHASE_0_BLOCKERS.md` has the per-story table.
**Do not read "blocker cleared" as "story done"** — that conflation is what this doc got wrong on
2026-07-16 and had to correct. **9d is the reason the distinction matters:** it was found only
because someone tried to write 9b's remaining proof and discovered the thing being proven was
unreachable. The unfinished tail of a story is where the next blocker hides.
**Launch-gating remainder = 👤 human-led:** on-device SOS/safety validation (step 7 + 9a) and the
git-history purge (step 3 — keys are **rotated + revoked**, so history holds only dead credentials).
**Open backend follow-ups (⚠, mobile, need sign-off):** 9b's block/women-only pgTAP proof (**gates
step 10**); the north-star **city** cohort + the server-side PostHog trigger, once a real city source
lands (step-9 scope).
**Post-repave advisor backlog → PHASE_H (not blockers):** `check_ins` has **RLS disabled** (unused
legacy table — drop or enable), 5 SECURITY DEFINER views should be INVOKER, 45
`function_search_path_mutable`, avatars bucket listable.

> **⚠ RE-SEQUENCED 2026-07-07 — full project audit** (`docs/reports/full-project-audit-2026-07-07.md`, both repos).
> _Both blockers below are **RESOLVED** as of 2026-07-16 — kept for the rationale._
> Two NEW launch blockers were found and **jumped the queue ahead of step 10**:
> **9a** (mobile ⚠) the Emergency SOS screen is wired to a non-existent GraphQL backend — the SOS button always fails; and
> **9b** (mobile ⚠) a `USING (true)` SELECT policy on `profiles` nullifies PII/block/women-only RLS gating (this absorbs follow-up (a) above).
> The audit also found **step 10 has an unstated prerequisite**: `/profile/[username]` is a client component behind the auth wall — it must become **public + server-rendered** before consuming `reputation_score` has any acquisition value. New sprint docs: mobile `PHASE_H_HARDENING.md` (+ Phase 0 Stories 0.4/0.5), web `PHASE_W_FOUNDATION_UPGRADE.md` + `PHASE_A_PUBLIC_SURFACE.md`.
> **Target: lift the audit scores** (Clean Arch 6, SOLID 5, code quality 6.5, schema 8, security-as-deployed 4) **to ≥8 across the board before Stage B.**

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

### Stage 0.5 — Audit launch blockers _(inserted 2026-07-07 — **blockers cleared 2026-07-16; stories NOT closed**)_

| #   | Repo      | Do                                                                                                                                                                                                                                                                                                                                                                                                             | Depends on | Est.  | Notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| --- | --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 9a  | MOBILE ⚠ | **Story 0.4** — replace the phantom GraphQL safety backend with Supabase; fix `trigger-sos` contact-token join + notification targeting; delete the dead stack                                                                                                                                                                                                                                                 | —          | 3–5 d | 🔶 **Blocker cleared; 3/7.** PRs #23 + #25 merged + deployed — SOS reaches Supabase and reports honestly. **Dead stack NOT deleted** — 8 `api.soloadventurer.com` refs remain in `lib/` (DoD demands zero) → **PHASE_H**. 👤 on-device validation outstanding.                                                                                                                                                                                                                          |
| 9b  | MOBILE ⚠ | **Story 0.5** — drop `USING (true)` on `profiles`; scoped embedding access; public-safe projection (REVOKE email/phone/DOB); pgTAP proof; cross-check web                                                                                                                                                                                                                                                      | —          | 2–3 d | 🔶 **Live in prod; 5/6.** The leak is dead. **⚠ pgTAP proof open:** women-only clause is testable now; the **block clause is blocked on 9d** — a green "block gating holds" would be true of the DB and false of the product. **Gates step 10.**                                                                                                                                                                                                                                       |
| 9d  | BOTH ⚠   | **Story 0.6** — blocking did not exist: web wrote to the phantom `blocked_users`; `BlockDialog` unreachable; mobile had no path; the connected-path policy ignored blocks and the trigger only cleared `follows`                                                                                                                                                                                               | —          | ~1 wk | ✅ **Implemented 2026-07-17 (8/8), ⚠ awaiting sign-off + 👤 live block test.** Single write path → `blocks`; reason → `reports` (`target_type='profile'`); dialog wired to `OtherUserProfile`; migration `20260717120000` severs connections (status→`blocked`) + adds the block clause to `profiles_read_connected`; pgTAP (11) proves both directions incl. the connected path. **Closes 9b box 4's block clause** (women-only clause still open). Mobile block UI deferred (dated). |
| 9e  | BOTH ⚠   | **Story 0.7 (NEW)** — phantom schema refs: code querying relations, RPCs and edge functions that were never created. Remaining: `shared_meetups`, `notify-new-message`'s `chats`+`chat_id`, web's 3 trip RPCs, `get_entries_near_location`, `travel_preferences`, **`delete-user-account` (account deletion broken — GDPR/store)**; 👤 **deploy the 8 undeployed edge functions** (incl. `verify-with-onfido`) | —          | ~1 wk | 🚨 **LAUNCH BLOCKER, 3/12.** The **class** behind 9a + 9d. ✅ 2026-07-17: **message reporting fixed + chat-UI wired** (repointed at `reports`; pgTAP-proven); **photos scaffold deleted**; ratchet extended to `.invoke()`. **Web's fix is W.2 types**. Safety + cross-repo → **sign-off**. `PHASE_0_BLOCKERS.md` Story 0.7.                                                                                                                                                            |

### Stage A — Reputation exists → make it visible _(mobile done → web consumes)_

| #   | Repo      | Do                                                                                                                                                                                  | Depends on | Est.    | Notes                                                                                                                                                                                                                                                                                                                                                                                        |
| --- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 9   | MOBILE    | **Phase A finish** — north-star city/time indexes; decide the deferred `events` table                                                                                               | 4          | ✅ done | PR #17 **merged 2026-07-07**. City cohort + `events` still deferred.                                                                                                                                                                                                                                                                                                                         |
| 9c  | WEB       | **PHASE_W** — stack upgrade (Next 15→16, React 18.2→19.2, Tailwind 3→4); server-first Supabase refactor + generated types; retire `/feed`; reframe landing; test audit              | —          | 1–2 wk  | 🔶 **IN PROGRESS — 3/24.** W.1a (Next 16 + React 19) merged; Tailwind 4 + `date-fns` v4 open. **W.2 is now the priority** (see note under the table).                                                                                                                                                                                                                                        |
| 10  | WEB ⚠    | **PHASE_A_PUBLIC_SURFACE** — make `/profile/[username]` **public + SSR**, consume `reputation_score`, public trip pages, `generateMetadata`/OG, sitemap/robots                      | 9b + 9c    | ~2 wk   | 0/23. **⚠ 9b is NOT fully satisfied** — the block/women-only pgTAP proof is missing, and this step makes profiles **public** on that exact schema. Treat **9b box 4 as a hard gate on 10**, alongside 9c. Prerequisite also still unmet: `/profile/[username]` renders a `'use client'` child and `middleware.ts` walls `/profile`. Privacy sign-off; no-show data stays private (see H.5). |
| 10b | WEB ⚠    | **Funnel + viral groundwork** — install CTA everywhere public (`install_click` live), `referral_landing` wired, smart-banner config, Loop-1 (trusted-contact page) design           | 10         | 3–5 d   | In `PHASE_A_PUBLIC_SURFACE.md` (Stories A-web.3/4). Store links = 👤 Anthony's release train (waitlist interim).                                                                                                                                                                                                                                                                             |
| 10c | MOBILE ⚠ | **PHASE_H** — audit hardening: test the product core, error spine, women-only extraction, no-Supabase-in-UI, SECURITY DEFINER backfill, no-show dispute design, deps + Flutter 3.44 | 9a + 9b    | 2–3 wk  | **Unblocked** (9a + 9b both done). Runs **parallel** with 9c/10/10b (different repo). H.5's dispute design gates public negative reputation (10). Absorbs the post-repave advisor backlog.                                                                                                                                                                                                   |

> **⚠ Cross-repo seam, live now — do W.2 first (added 2026-07-16).** The repave put mobile's Story 0.5
> schema — including **column-level REVOKEs on `profiles` (email/phone/DOB)** — into production. Web
> still has **no generated types** (`src/types/database.types.ts` does not exist) and reads rows through
> `Record<string, unknown>` casts in `src/lib/api.ts`, so **nothing type-checks web against the schema it
> actually queries**. This is exactly the `get_reputation` / `reputation_score` class of drift that §10's
> seam rule exists to prevent. W.2's type generation is the highest-value web story and should precede
> the remaining W.1 majors.

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

## Timeline (added 2026-07-07 — solo dev + loop, human-merged PRs; estimates, not promises)

> **Week 1 is done (2026-07-16), and it ran ahead on mobile / behind on web.** Mobile did Week 1's
> scope **plus** an unplanned prod repave: step 9 merged, 9a + 9b merged and live, rotation confirmed.
> Web got W.1a only, so **9c is the critical path now** — it is the sole remaining gate on step 10.
> Weeks below are unrenumbered; read them as sequence, not dates.

| When          | Mobile lane                                                                                                     | Web lane                                                                  | 👤 Anthony (not automatable)                                                                 |
| ------------- | --------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| **Week 1** ✅ | ~~Merge PR #17 (step 9)~~ · ~~**9a** SOS backend ⚠~~ · ~~**9b** RLS repair ⚠~~ — all merged; **prod repaved** | **9c** PHASE_W started (W.1a only — Next 16 + React 19)                   | ~~Rotation~~ ✅ done · history purge open · 9a/9b sign-off open                              |
| **Week 2**    | **10c** PHASE_H starts (H.1 core tests, H.2 error spine) — **unblocked**                                        | 9c finishes (**W.2 first**, W.1 majors, W.3 feed/landing, W.4 test audit) | On-device SOS validation (with 9a) · **recreate prod test accounts** (repave truncated them) |
| **Week 3–4**  | PHASE_H continues (H.3 women-only ⚠, H.4 no-UI-Supabase, H.5 backend ⚠)                                       | **10** public SSR profile + reputation + trip pages + SEO ⚠              | Privacy sign-offs (10) · store-listing prep (gates 10b full CTA)                             |
| **Week 5**    | PHASE_H closes (H.6 deps/Flutter 3.44, H.7 TODOs) · **re-score the audit**                                      | **10b** install CTA + referral + Loop-1 design ⚠                         | Dispute-path sign-off (H.5) · merge backlog                                                  |
| **Week 6+**   | Stage B (step 11) **only when real meetup volume exists**                                                       | Stage B web (step 12) after 11                                            | Launch call: blockers 3/9a/9b closed + safety validated                                      |

**Definition of "scores fixed":** re-run the audit rubric after Week 5 — target Clean Architecture ≥ 8, SOLID ≥ 8, code quality ≥ 8.5, backend security ≥ 8 (schema already 8). Anything still below 8 gets a named follow-up story, not a shrug.

## What can run in parallel

- **The 2026-07-07 wave:** 9a/9b (mobile) ⟂ 9c (web) — different repos, no shared tables. 10c (mobile PHASE_H) ⟂ 10/10b (web) — the only cross-repo seams are 9b's migration (cross-check web types) and H.5's dispute design (gates 10's public negative reputation).
- **Stage 0** is the most parallel: steps 1 (PR #10), 2 (web landing), 3 (secrets, Anthony), and 5/7 (mobile analytics/safety) have no dependencies on each other.
- **Within each of Stages A–E:** once the mobile step of a phase ships, its web step and the _next_ phase's mobile prep can overlap.
- **Serial choke points:** PR #10 (step 1) gates all later backend work; mobile Phase B (step 11) gates Stages C–E; the credential purge (step 3) gates real-user launch regardless of dev progress.

## The dependency rationale in one paragraph

The backend lives in the mobile repo and the web repo only reads it, so any capability appears in mobile first and in web second — that's why the order alternates mobile→web within every phase from A onward. Phase 0 is the exception because its tasks (landing fix, analytics, secrets, safety) don't cross the repo boundary. And because neither repo's loop/verifier can see the other, **every backend change must be cross-checked against web's typed consumers before it merges** (the `get_reputation`/`reputation_score` drift was exactly this class of bug). Keep the shared coupling map in mobile's `sprint-progress.json` (`web_integration`) current as the single place that records the seam.
