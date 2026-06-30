# SoloAdventurer — PRODUCT

## The product narrative: what it is, and how it works for a user

> **Mirror — canonical source: `SoloAdventurerWeb/docs/PRODUCT.md`.** If the two
> differ, the **web repo wins**. Strategy research lives in the sibling web repo
> (`../SoloAdventurerWeb/docs/research/`).

> **Companion to:** `docs/FOUNDATIONS.md` (the internal engineering charter / source of truth).
> **Audience:** anyone who needs to understand the product in human terms — founders, designers, new contributors, investors.
> **Status:** living document; describes the product as chartered in FOUNDATIONS (some layers shipped, some in active build — see FOUNDATIONS §5, §9).

*FOUNDATIONS.md decides what we build and why. This document describes what it **feels like** to use it.*

---

## 1. What it is

**SoloAdventurer is a vetted, AI-spined platform where solo travelers meet verified people in the city they're in right now — and the only thing it optimizes is whether a real-world meetup happened and was worth repeating.**

It is deliberately **not** either of the two categories people reach for first:

- **Not a content platform** (Facebook / Instagram / TikTok). There is no broadcast feed, no scroll-for-attention, no content-as-the-product. That model inverts into strangers-and-outrage and collapses trust (FOUNDATIONS §6; Playbook Part 2.12).
- **Not a "meetup app" or "Tinder-for-travelers."** A bare matching utility is a commodity with no moat. Meetups are the *unit of value* here, but the product is a **trust platform**: vetted + AI-matched + reputation-bound + safety-native.

The atomic unit — the thing the whole product exists to produce and capture — is **a verified, real-world meetup that generated a reputation outcome.** A "match" is not success. A message is not success. *Two verified people actually met, and one or both would do it again* — that is success.

> **One line for the deck:** *SoloAdventurer turns "I'm traveling alone" into "I'm having dinner with someone verified tonight" — and turns that dinner into trust that follows you everywhere.*

---

## 2. How it works — the core loop

The product is a closed loop. The app's job is to produce the loop and then get out of the way:

```
   arrive in a city  →  AI finds your verified people
        →  concierge removes the awkward first message
             →  guardian keeps the meetup safe
                  →  you meet, in the real world
                       →  the outcome becomes reputation + trains the next match
                            →  (next city, the loop runs faster)
```

Three AI systems do the work, on a foundation of trust:

- **The brain** — matches you to verified people in your city *now*, ranked on overlapping itinerary and complementary intent. Learns from outcomes, so it gets sharper every meetup.
- **The concierge** — drafts the first message and proposes the actual plan. Removes the activation energy of saying hello, which is where matching apps die.
- **The guardian** — risk-scores every meetup, screens messages before delivery, arms check-ins and SOS. Safety is the substrate, not a feature page.
- **The moat** — Onfido ID verification + behavioral reputation + real-capture photo provenance. The thing AI makes scarce by making fakes abundant.

*(Architecture detail in FOUNDATIONS §4.)*

---

## 3. A night in Seoul (the primary scenario)

It's a Tuesday. You're solo in Seoul. You don't want to eat alone tonight.

1. **Open → "Who's in Seoul tonight."** Not a feed. The Connect surface shows a **curated list of verified travelers** (and vetted locals) in Seoul *right now* — say six people — ranked by the brain on overlapping intent (they also want dinner or drinks) and itinerary. You're seeing your real options for tonight, not scrolling content.
2. **Each person is a match card, not a post.** Face photo + **verified badge** + a reputation line (*"vouched for by 4 travelers," "2 repeat meetups"*) + intent (*"here till Friday, wants a food companion"*) + why-you (*"both into food markets, both free tonight"*). Quality over volume.
3. **Tap to assess.** Her profile opens — real, **provenance-verified** photos (EXIF/geocode confirm they're genuinely her, genuinely recent), ID-verification status, reputation detail, the trips she's on. This is the moment you decide who's worth meeting.
4. **The trust check.** Verified ✓ · reputation ✓ · mutual vouches (*"you both know Sarah"* ) ✓ · women-only mode on ✓ · the guardian's read on a public-evening meetup = low risk ✓. You decide with evidence, not vibes.
5. **Connect — the concierge drafts it.** No cold *"hey."* *"You and Min are both free tonight, both want an evening out — Hongdae, 7pm? Draft invite ready — edit or send."* The hardest step is gone.
6. **Meet, safely.** Guardian armed — live location shared with your trusted contact, a 10pm check-in window, SOS ready, public spot. You meet. The app steps back.
7. **After → reputation.** A bilateral vouch + a real shared photo from the evening = proof. Your reputation grows; the brain learns what works for you. In the next city, the loop runs faster.

---

## 4. The loop in other moments

**Day one, Lisbon.** You land alone. A location-aware nudge or your own curiosity opens the app. The brain has already matched you to verified travelers arriving the same week with overlapping plans. The concierge has a draft "anyone want to split a pastel de nata crawl tomorrow?" before you've unpacked. By evening one, you have a plan and a person.

**Six months later, Bangkok.** You arrive and the platform already knows you're vouched-for — by the traveler you hiked with in Sintra, by the crew you had dinner with in Seoul. Trust is pre-loaded. Matches arrive warmer, faster, because your reputation traveled with you. *That persistence — ephemeral locally, permanent globally — is the moat incumbents structurally cannot copy* (FOUNDATIONS §2; Playbook Part 11.7).

**After every meetup — the memory.** A real photo from the evening becomes a shared memory between you, and (with consent) a piece of social proof for the next person considering a meetup. It also feeds your journal — your private travel record that quietly trains the brain to know your taste.

---

## 5. "But how do I see who I'm meeting?" — photos without a feed

This is the question that decides whether "no feed" works. The answer: **the profile is the unit of presentation now, not the post.** Killing the global scroll didn't remove photos — it relocated them to exactly where they do trust work.

Photos live on four surfaces, none of which is a broadcast feed:

| Surface | What it shows | Why it beats a feed for "should I meet this person" |
|---|---|---|
| **The match card** | Face + verified badge + reputation snippet, in the list | Real options at a glance, not 500 strangers' content |
| **The verified profile** (tap) | Real, provenance-verified photos + ID verification + reputation + trips | One verified person, deeply — not scattered strangers |
| **The "tonight in [city]" board** | City-scoped, action-oriented meetup proposals with photos ("dinner companion wanted") | Scoped to your city, turns over daily, exists to *produce meetups* — not impressions |
| **Post-meetup shared memory** | The real photo from the meetup, shared between you (and optionally as cohort proof) | Becomes reputation evidence and the warm payoff |

**The line that matters:** *we killed the global scroll, not the photo.* A feed showed your photos to people who'd never meet you. The profile shows photos to exactly the person deciding whether to meet you — wrapped in verification, reputation, and mutual vouches. For "I need to see who I'm meeting," the verified profile is the right tool; the newsfeed never was.

*(Policy detail in FOUNDATIONS §7: photos are real, provenance-verified captures — no AI-fake travel photos. That rule is itself a competitive advantage.)*

---

## 6. Built for the traveler who needs it most

The *"I want to see who I'm meeting, especially as a woman"* need isn't an edge case. **It's the wedge.** The entire stack exists to serve the safety-conscious solo traveler — disproportionately women — and that is why the product wins where dating apps and social platforms fail:

- **Real, provenance-verified photos** — not catfish. EXIF/geocode confirm the photo is really her, really recent.
- **ID verification** (Onfido) — she is who she says she is.
- **Reputation** — vouches from other travelers (weighted toward vouches from other women), repeat-meetup rate, flag history.
- **Mutual vouches** — *"you both know Sarah, and Sarah vouches for her."*
- **Women-only mode** — restrict the network to verified female travelers. Not a niche toggle; a core strategy.
- **The guardian** — risk-scores every proposed meetup *before* it happens; live location, check-in windows, and SOS *during*.

No feed-based or swipe-based app offers this, because they optimize for matches and sessions, not *safe, verified, real-world meetups*. That is the entire reason this product exists instead of another Tinder-for-travelers.

---

## 7. What fills the app, then

The hidden worry: *if there's no feed, does the app feel empty?* No — because **the variable reward moved from the scroll to the match.** The thing that pulls you back isn't *"what new content appeared"* — it's *"who can I actually meet tonight?"* That's a tighter, higher-stakes hook than any feed (Playbook Part 1).

The app feels like a **curated room of real, verified people in your city right now** — which is exactly what a solo traveler on a Tuesday evening wants. Profiles, the city board, and memories fill that room; they exist to produce meetups, not to keep you scrolling.

---

## 8. Two surfaces, two jobs

A user usually meets the product in two stages:

- **Web — the front door.** They find SoloAdventurer through search (*"meet solo travelers in Seoul"*) or a shared trip/profile link with a rich preview. Public, photo-rich pages capture intent and convert to a mobile install. The web's job is to be **found and shared** — it is the funnel.
- **Mobile — where it happens.** The loop in §2–§4 runs here: matching, the concierge, the guardian, meetups, reputation. The mobile's job is to **deliver real-world meetups** — it is the product.

Web sends the world to mobile; mobile sends users back to the real world. *(Client-role detail in FOUNDATIONS §3.5, §7.)*

---

## 9. What success looks like

Not downloads. Not DAU. Not matches. Not messages.

**Meetups completed — and meetups repeated.** That is the only north star. Every design choice is auditable against it: if a feature produces meetups and reputation, it belongs; if it produces scrolls, it does not (FOUNDATIONS §6).

---

## 10. See also

- **`docs/FOUNDATIONS.md`** — the internal charter: the reframe, the AI spine architecture, the keep/refactor/dispose decisions, the guardrails, the build sequence. The engineering source of truth.
- **`../SoloAdventurerWeb/docs/research/platform-playbook.md`** — the AI-Native Platform Playbook (13 parts). The research this product is grounded in; Part 11.7 is the SoloAdventurer wedge, Part 13 is the evaluation framework.

---

*If you can describe SoloAdventurer to a friend as "a feed" or "a dating app," this document has failed. It is a vetted, AI-spined trust platform whose unit of value is a real-world meetup — and everything above exists to make that meetup safe, likely, and worth repeating.*
