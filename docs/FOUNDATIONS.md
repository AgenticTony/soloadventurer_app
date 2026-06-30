# SoloAdventurer — FOUNDATIONS

## The product charter and single source of truth

> **Mirror — canonical source: `SoloAdventurerWeb/docs/FOUNDATIONS.md`.** This copy
> is for the mobile team; if the two differ, the **web repo wins**. The 13-part
> research playbook lives at `../SoloAdventurerWeb/docs/research/platform-playbook.md`.

> **Status:** Authoritative. Every PR, sprint, and feature decision is auditable against this document.
> **Created:** 2026-06-30
> **Grounded in:** `../SoloAdventurerWeb/docs/research/platform-playbook.md` (the AI-Native Platform Playbook)
> **Supersedes:** `docs/project/PROJECT.md`, `docs/project/WEB_APP_SPRINTS.md`, `docs/project/WEB_APP_SPRINTS_INDEX.md`, and the MVP-era sprint backlogs as the strategic source of truth. Those documents encode a thesis this charter deliberately rejects (see §1). They are retained only as history.
> **Governs:** Both clients (Flutter mobile, Next.js web) and the shared Supabase backend. Backend migrations/RLS live in the **mobile repo** (`SoloAdventurer_app/`); any change there must be cross-checked against both clients.

---

## 1. The reframe (the one decision everything else inherits)

**SoloAdventurer is not a matching app. It is a vetted, AI-spined trust platform.**

The previous build was converging on a *Tinder-for-travelers* MVP, where the atomic unit is **"a match"** and success is measured in swipes, sessions, and connection counts. That shape is explicitly rejected. It is the exact failure surface the research warns about (Part 10 — "X for Y" trap, vanity metrics, growth-without-retention) and it has no defensible moat (Part 5 — direct matching networks with no persistent layer are commodities).

The new atomic unit is:

> **A verified, real-world meetup that produced a reputation outcome.**

Everything — the data model, the north-star metric, the matching reward, the moat, the monetization — is oriented around producing and capturing that unit. A "match" is not success. A "message" is not success. **A meetup that happened, between verified people, that one or both would repeat — that is success.** This single reframe cascades into every section below.

### The product, in one exclusionary sentence
> *SoloAdventurer is a vetted, AI-spined platform where solo travelers meet verified people in the city they're in right now — and the only thing we optimize is whether a real-world meetup happened and was worth repeating.*

That sentence deliberately **excludes**: unverified/anonymous matching (Tinder), persistent broadcast feeds (Facebook), content-for-scroll (TikTok), ad-funded attention extraction, and matches-as-a-vanity-metric. If a proposed feature serves any of those, it does not belong here.

---

## 2. The winning shape we are building toward

From the playbook (Part 11.21), made specific to SoloAdventurer:

| Property | What it means here |
|---|---|
| **Vetted + vertical** | Onfido ID verification + behavioral reputation. Solo travelers, one tribe, served deeply — not everyone. |
| **AI-moderated at creation** | Messages and meetup proposals screened *before* delivery, not after. Safety is a product feature, not a report queue. |
| **Real-world action as the north star** | `meetups_completed` (and repeat meetups). Never time-in-app, sessions, or scrolls. |
| **Subscription, not ads** | Sprint 6.6 paywall retained. AI value (guardian, concierge, flywheel matches) is the Pro tier. |
| **Referral-distributed** | Growth runs on a referral + content-share loop, not paid acquisition. |
| **Ephemeral-local, persistent-global** | Each city is a two-sided market that turns over in days; the **reputation graph persists across trips**. This is the moat incumbents structurally cannot copy. |

---

## 3. The six pillars of the foundation

1. **Outcome-centric data model (L0).** Every entity exists to produce or capture a real-world outcome. A unified event/outcome store is the foundation everything compounds on. `meetups_completed` is the north-star.
2. **The reward function (L2) is a first-class artifact.** Explicit, versioned, owned. It optimizes *outcomes*, never engagement. It is simultaneously the moat and the ethical spine (Parts 7.5, 7.19).
3. **Reputation is a first-class entity.** Bilateral, meetup-gated (you can only review someone you verifiably met), derived from the same outcome store as the AI flywheel. Reputation and the matching brain are **one system**.
4. **The closed AI spine.** serve → log → train → serve. Embeddings + a learned ranker + agents. The loop is the product; an open loop is just a feature (Part 7.22).
5. **Two distinct client roles.** Mobile = daily-use / safety / matching brain. Web = acquisition / share / SEO / concierge surface. Different jobs, by design — *not* a feature port.
6. **Framework-as-spec.** The Founder's Evaluation Framework (Part 13) drives prioritization. Its 11 dimensions, the 1.5× weights on Retention / Network Effects / AI Leverage, and the **veto rule** (a 0 on any of those three kills the product) govern what we build.

---

## 4. The AI spine (architecture)

The spine is **a closed loop, not a model**. Five layers, all on the existing Supabase stack:

```
   ┌───────────────────────────────────────────────────────────┐
   │  L4 — TRUST / MOAT   reputation score · verified-human     │
   │                       provenance · scam/anomaly detection  │
   └──────────────────────────┬────────────────────────────────┘
                              │ reads
   ┌──────────────────────────┴────────────────────────────────┐
   │  L3 — AGENTS (the UX)   concierge · guardian · moderator  │
   │         Edge Functions + LLM, Pro-gated                    │
   └──────────────────────────┬────────────────────────────────┘
                              │ serves / logs
   ┌──────────────────────────┴────────────────────────────────┐
   │  L2 — MODEL / REWARD   ←  THE MOAT                         │
   │     learned ranker; reward = real-world outcome            │
   └──────┬──────────────────────────────────────┬─────────────┘
          │ trains on                             │ updates
   ┌──────┴──────────────────┐     ┌──────────────┴────────────┐
   │  L1 — EMBEDDING STORE   │     │  L0 — SIGNAL / EVENT LOG  │
   │  (exists; extend)       │     │  ← MISSING FOUNDATION     │
   │  pgvector: profiles +   │     │  unified outcomes +       │
   │  trips + journal +      │     │  north-star (meetups_done)│
   │  OUTCOME vectors        │     │                           │
   │  MiniLM, zero-cost      │     │                           │
   └─────────────────────────┘     └───────────────────────────┘
```

**L0 → L2 → L1 → L3 → L0.** A meetup completes → logged in L0 → updates the reward (L2) and the behavioral embedding (L1) → the concierge/guardian (L3) serve better next time → more meetups. That closure is what makes the product "could not have existed in 2015" (Part 13.12, the AI-Leverage score-3 bar).

### The reward function — v0.1 (the IP; version this, don't hand-wave it)

```
REWARD (v0.1) — optimize OUTCOMES, never engagement

  + meetup completed                         (the north-star itself)
  + positive bilateral vouch / review        (meetup-gated)
  + repeat meetup with the same connection
  + connection retained > 30 days with activity
  − block / report / flag                    (severity-weighted)
  − no-show on a scheduled meetup
  − match accepted → 0 messages within 48h
  − uninstall within 7 days of first match

  NEVER an input to the reward:
    session length, scrolls, taps, time-in-app, feed impressions
```

This is the Facebook-MSI lesson made structural (Part 7.5): the metric you optimize is the behavior you get. Optimizing engagement produces outrage and burnout; optimizing meetups produces a product aligned with the user (Part 11.2).

---

## 5. Keep / Refactor / Dispose charter

A durable decision log. Verdicts are grounded in the thesis; confidence in parentheses.

### ✅ KEEP — serves the thesis or is neutral scaffolding
- **Supabase + pgvector + Edge Functions (Deno)** — ideal spine substrate; zero-cost on-edge AI. *(high)*
- **Riverpod 3 + Clean Architecture + Drift** (mobile) — solid foundation. *(high)*
- **`generate-profile-embedding` (MiniLM 384-dim, on-edge)** — the spine limb. Extend, don't replace. *(high)*
- **Safety pillar** (SOS, check-ins, `meetup_checkins`, `shared_meetups`, trusted contacts) — the differentiator and the trust scaffold for offline meeting. Elevate into the AI guardian. *(high)*
- **Onfido verification** — core to "vetted." *(high)*
- **Subscription paywall** (Sprint 6.6) — matches the thesis. *(high)*
- **`graphql_flutter`** — used by the Viator destination client; scoped external-API use only. *(high, verified)*
- **Viator affiliate** — transaction-monetization seed. *(med)*
- **Drift offline/sync** — neutral-to-positive. *(med)*
- **~4,950 tests (mobile 4487 / web 464)** — an asset. Refactor *around* them; do not throw them away.

### ⚠️ REFACTOR — exists but wrong shape for the thesis
- **Matching ranker** — keep the *features* (date/activity/destination overlap) as model inputs; **replace the hand-tuned weights (`destination: 0.10`, country `0.5`, exact `1.0`) with outcome-trained scoring (L2)**. This is the #1 "AI becomes the spine" move. *(high)*
- **Profile-text-only embeddings (L1)** — extend to trips, journal, and **outcome-derived behavioral vectors**. *(high)*
- **Social module** (follow/feed/comment/reaction) — currently a **broadcast feed = inversion-prone** (Parts 2/4). Repurpose the backend as a **group-formation substrate** (city cohorts, trip-tribes — Reed's Law). **Do not ship a global broadcast feed.** *(high)*
- **Message moderation** — move **client-side → server-side, pre-delivery, at-creation** (L3). The incumbent-can't-do wedge. *(high)*
- **Web app** — stop the 1:1 feature port. Re-mission as **acquisition / share / SEO / concierge surface** (public trip/profile/destination pages as the viral + intent-capture spine). *(med-high)*

### 🗑️ DISPOSE — dead weight or actively conflicting
- **Old MVP-shaped sprint backlogs** (19 web / 14 mobile) — built around "matching-app MVP." Retire as source of truth; re-derive from the Part-13 framework. *(med-high)*
- **Stale docs** — `docs/project/PROJECT.md`, `WEB_APP_SPRINTS*.md`, `ML_Matching_Plan.md` (frames AI as "Could-Have, not blocking"). Rewrite or remove. Zero code risk. *(high)*
- **Country-coarse matching heuristics** — placeholders, not the product. *(high)*
- **Leaked service-role key in git history** — security blocker; bypasses RLS for both apps. **Rotate + purge history before any launch.** *(high)*

---

## 6. What we do NOT build (guardrails)

This list exists to stop the old shape creeping back. If a proposal matches any of these, it is rejected by default.

1. **No broadcast feed.** No global algorithmic feed optimized for engagement. Social surfaces are group- and meetup-scoped (see §7 for the permitted content/media shape). (Parts 2, 4)
2. **No decorative AI.** No "Ask SoloAdventurer" chatbot bolted on. AI lives in the core loop — matching, safety, moderation, concierge — or it doesn't ship. (Part 13.17)
3. **No ad model, ever.** Subscription + transaction only. Ads + lock-in = enshittification. (Parts 6.8, 6.13)
4. **No engagement proxy as a north star.** Session length, scrolls, DAU-as-success are banned from the reward function. (Part 7.19)
5. **No country-coarse matching in production.** Matching is city/radius + itinerary-overlap, or it isn't matching. (Part 11.7)
6. **No 1:1 web feature port.** Web serves growth (share/SEO/concierge); mobile serves daily use + safety. Different jobs.
7. **No "social network for X" framing.** The product is defined by the meetup-and-reputation unit, not by analogy to an incumbent. (Part 10.6)
8. **No AI treated as an enhancer/"Phase 2."** AI is the spine from the first line of new foundation code. (Part 13.12)
9. **No borrowed-graph dependency for the core loop.** Distribution can lean on external surfaces; the graph and reputation we own. (Part 10.13)
10. **No synthetic/fake liquidity.** AI may seed onboarding warmth, but never fake users to mask a cold network — that destroys the trust the product is selling. (Part 10.2)

---

## 7. Content & Media — photos as fuel, not feed

Photos and experiences are shareable — but they are **never the product**. The product is the verified meetup + reputation outcome (§1). Media exists to serve that unit; if a media feature serves the scroll instead, it does not ship.

**The infrastructure already exists — this is a re-shape, not a build.** The full media pipeline is built (`media_upload_service`, image/video compression, picker/gallery/viewer, `media_item` model); storage buckets with RLS are in place (`journal-photos`, `journal-videos`, `avatars` — migration `20250105000000`); EXIF/location handling and live location sharing are present. The work is to change the *surface*, not to add capture.

**The rule: no broadcast feed.** The existing `PostComposer → feed → PostCard/PhotoGrid` surfaces (web `(main)/feed`, mobile `social` module's `feed_items` / `get_user_feed`) are the Instagram-for-travelers shape — the inversion trap (Parts 2.2, 2.4, 4.10) and a §6 violation. They are refactored into the four permitted uses below; they are **not** shipped as a global feed.

**The four permitted uses — media serves the atomic unit:**

| Use | What it is | Spine layer | Research |
|---|---|---|---|
| **Trust / provenance** | Location + time-stamped *real* photos as verification evidence — "this person is genuinely here, doing this." Evidentiary, not aspirational. EXIF/geocode foundation already present. | L4 | 12.8 |
| **Meetup catalyst** | Share a photo/experience to *trigger* a meetup, to a **city cohort** — "view from my hike, anyone tomorrow?" Content as Hook trigger → real-world action. | L0 | 1.5, 11.7 |
| **Post-meetup shared memory** | After a meetup: a shared photo/memory = the warm proof behind a vouch. Reputation fuel + flywheel signal. | L0 / L4 | 3.9, 5.8 |
| **Live location + photo during meetup** | "I'm here, safely, with this verified person." Live location sharing already built. | L3 | 11.2 |

In every permitted use, the photo points *toward* a meetup or *verifies* a person — never toward a scroll.

**The journal's role.** The travel journal is the user's **investment** (Hook — stored value, switching cost) **and the taste-signal source** for matching (journal photos/captions/locations → embeddings → L1). It stays **primarily private** and is selectively surfaced for the uses above. It is not a public grid; feed-ifying it would destroy both its switching-cost value and its signal quality.

**Where AI meets media (per §4):**
- **L1 — matching:** photo / caption / location content feeds the taste embedding → better matches.
- **L4 — trust:** provenance AI — detect AI-generated or fake photos, validate EXIF/geocode. A critical anti-scam surface for a strangers-meet-offline product.
- **L3 — concierge:** photo-similarity → meetup suggestion ("you both shoot hiking terrain and you're both free Thursday — want a trail?").

**Policy edge — real captures only.** In a trust product, AI-generated "travel photos" a user did not take would poison the trust being sold. The policy is therefore the *inverse* of the open internet: **photos must be real, provenance-verified captures.** "Real photos from verified travelers" is the authenticity-as-scarce-good thesis (Part 8.3) enforced as a hard product rule — a defensible position no incumbent can copy without breaking its own engagement model.

**Client split (per §3.5):**
- **Mobile** — trust-photos, meetup-catalyst cohort shares, post-meetup shared memories, live location.
- **Web** — public, photo-rich trip / destination / profile share pages with OG previews: the acquisition + SEO payload. Photos drive *acquisition* here, not retention.

---

## 8. The framework as the spec (Part 13)

Eleven dimensions, scored 0–3. **Retention, Network Effects, and AI Leverage are weighted 1.5×** because they compound. A **0 on any of those three is a veto**, regardless of total.

**Baseline (2026-06-30, pre-launch, shipped product as it stands): 19/33 raw · 22/42 weighted → "Weak" band.** Not damning — diagnostic. The thesis (Part 11.7) scores far higher; the current build has realized roughly 60% of it. No veto fired.

The dimensions to move, in leverage order:

| Move | Lifts | Weighted gain |
|---|---|---|
| Build the bilateral reputation primitive | NFX 2→3, Switching 2→3, Defensibility 2→3, Community 1→2 | **+4.5** → ~27 ("Promising") |
| Close the matching flywheel (outcome-trained L2 + L1) | AI Leverage 2→3 | +1.5 |
| Ship group-formation (not a feed) | Community, NFX (toward Reed) | +1.0+ |
| Add referral + web share/SEO surface | Virality 1→2 | +1.0 |
| Instrument D1/D30 + lock the meetup north star | de-risks Retention | protects the 1.5× weight |

Target: **32/42 ("Strong")** before scale.

---

## 9. Build sequence

| Phase | Build | Why first |
|---|---|---|
| **0 — Blockers** | Rotate/purge the leaked key; harden safety to production-grade; stand up analytics + lock `meetups_completed` as north-star. | Right to launch. |
| **A — Lay the spine** | L0 event/outcome store + define the L2 reward function (v0.1) + the reputation entity (meetup-gated, bilateral). *No fancy ML yet.* | The foundation that makes all future AI compound. Reputation + flywheel + north-star in one build. |
| **B — Close the loop** | L1 outcome-derived vectors + outcome-trained ranker replacing heuristics (L2). | AI Leverage 2→3. The "could not exist in 2015" bar. |
| **C — Agent layer** | Concierge (UX impact) → guardian (differentiator) → moderation-at-creation (server-side, pre-delivery). | The AI-native UX. |
| **D — Trust layer** | Reputation surfacing, scam anomaly detection, persistent memory. | The moat that compounds. |
| **E — Long horizon** | City-by-city atomic-network GTM, conversational discovery, agent-to-agent reputation, AI community manager. | Scale + future-proofing. |

**Phase A is mostly schema + a reward-function document, not ML.** That is deliberate. The research is explicit (Part 7.12) that infrastructure is commoditized; the data and the reward are the asset.

---

## 10. Cross-repo governance & safety

- **Shared backend lives in the mobile repo.** Migrations, RLS, Edge Functions, and RPCs are authored in `SoloAdventurer_app/supabase/`. Neither repo's verifier/loop sees the other app — **cross-check both clients on every backend change.**
- **Safety-sensitive surfaces** (anything matching strangers for offline meetings: matching, meetups, SOS, check-ins, reputation, RLS on `connections`/`meetup_checkins`/new reputation tables) — **flag before editing**, per `CLAUDE.md`.
- **Auth/payment** (Supabase sessions, RLS, Stripe/paywall) — flag before editing.
- **Refactor beats rebuild.** The research's component lens (Part 9) says social products are recombinations of the same blocks. Almost everything in §5 is *refactor toward the thesis*, not delete-and-restart. The only true disposals are docs, the old backlog, stale positioning, and the leaked key.

---

## 11. Sources

- **Primary:** `../SoloAdventurerWeb/docs/research/platform-playbook.md` — the AI-Native Platform Playbook (13 parts). Part 11.7 is the SoloAdventurer wedge; Part 11.21 is the winning shape; Part 13 is the evaluation framework; Parts 7–8 are the AI-stack and role-by-role re-pricing.
- **Foundational references:** Eyal (2014, Hook Model); Fogg (2019, B=MAP); Metcalfe/Reed (network effects); Granovetter (weak ties); Chen (cold-start); Doctorow (enshittification); Cialdini/Berger (influence & virality); Kahneman (prediction error, loss aversion). Full bibliography in the playbook, Part 13.21.

---

*This charter is the guardrail. When in doubt, return to §1 (the reframe), §6 (what we do not build), and §7 (content & media). If a decision serves the meetup-and-reputation unit and the closed AI spine, it belongs; otherwise it does not.*
