# Sprint 6.6: Monetization + Paywall (v3 — 3-layer verification architecture)
**Duration:** Weeks 14–15
**Theme:** Build minimum monetization experiment. Safety-led paywall with two blockbuster Pro features: ID Verification and Guardian (check-in system, built in Sprint 6.7). Free tier feels complete — Pro is an upgrade, not an unlock. All gates default to open, activated via feature flags post-launch.
**Depends on:** Sprint 6.5
**Status:** COMPLETE — Ready for senior dev review (2026-04-19)

## 3-Layer Verification Architecture

The verification system has three distinct layers answering three different questions. Layers 1+2 are invisible fraud prevention. Layer 3 is the visible trust signal that gets monetized.

| Layer | Question | Method | Badge? | Cost | When |
|---|---|---|---|---|---|
| 1. Liveness | "Are you a real person?" | Selfie + liveness check | No — invisible | ~$0.01 | Mandatory at signup, before discoverability |
| 2. Photo match | "Are you the person in your photos?" | Selfie vs profile photos | No — invisible | ~$0.01 | Mandatory at signup, before discoverability |
| 3. ID Verified | "Is your real-world identity confirmed?" | Government ID via Onfido | Yes — visible badge | $3-4.50 | Pro feature |

**Key principle:** Fraud prevention is invisible infrastructure. Trust signals are visible and earned. The free selfie check is NOT called "verification" — it's a "photo check" or "liveness check." Only Layer 3 earns the word "Verified" and the visible badge.

**Why this matters:** If you give a "Verified Photo" badge away free based on a selfie, users see no reason to pay for ID verification. You've given away your primary Pro conversion driver. The badge must be reserved for the thing that costs real money.

## Guiding Principles
1. **Free tier must feel complete.** Pro is an upgrade to an already-valuable product — not the unlock for it to function.
2. **Lead with safety, not features.** "Get ID Verified" / "Travel with peace of mind" — not "Upgrade to unlock."
3. **ID Verification is the trust product, not a bullet point.** It gets its own hero section on the paywall. Guardian (Sprint 6.7) is the second hero.
4. **No "likes" — use travel framing.** "Travelers interested in connecting" / "Connection requests" — never dating-app language.
5. **All gates open by default.** Activate individually via feature flags in a sequenced rollout post-launch.
6. **Microcopy matters.** Avoid "Unverified user" (say nothing or "New traveler"). Avoid "Upgrade to unlock" (say "Get Verified" / "See who wants to connect"). Free users who passed the photo check show no badge — not "unverified."
7. **Frictionless cancellation.** No dark patterns. One-question exit survey for learning only.
8. **Both genders from day one.** Women who want to filter to verified-only travelers can upgrade. Men who want to appear in verified filters can upgrade. Both sides have a reason to pay.

---

## Tasks

### 6.6.1 — Subscription model scaffold
- [x] Create `lib/features/subscription/` with domain/data/presentation layers
- [x] Domain: `SubscriptionTier` enum (free/explorer/adventurer/vip)
- [x] Domain: `FeatureGate` enum listing all gated features
- [x] Data: `SubscriptionRepository` — checks current tier
- [x] Provider: `subscription_provider.dart` — AsyncValue of current subscription status
- [x] Add `trialStartDate`, `trialEndDate` fields to Subscription entity
- [x] Add `previousTier` field for cancellation degradation (Explorer → Free keeps "Previously verified" status)
- [x] Define annual pricing: $59.99/year (~$5/month effective) alongside $9.99/month
- [x] Add "Notify me" button to Coming Soon tiers for intent data collection

### 6.6.2 — Paywall screen (safety-led redesign with ID verification as hero)
- [x] Redesign `PaywallScreen` hero section:
  - Hero: "Travel with peace of mind" headline
  - Show the ID Verified badge mockup (the badge they'd earn — shield + checkmark)
  - "Connect with travelers who've verified their government ID" — the core promise
  - Testimonial-style quote area (placeholder: "I only meet verified travelers" — solo traveler)
  - Guardian preview: "Plus — Guardian check-ins that watch your back during meetups" (ties to Sprint 6.7)
- [x] Feature comparison section (below hero):
  - **ID Verification** — dedicated row with badge icon, not a bullet (this IS the product). "Verify your government ID — show travelers you're the real deal"
  - **Guardian Check-Ins** — second hero row. "Advanced safety check-ins during meetups — multiple contacts, location sharing"
  - Unlimited connection messages (Free: 5/day)
  - See travelers interested in you (NOT "likes")
  - ID Verified-only filter (appears in Discover for Pro users)
  - Advanced filters (age, gender, language, travel dates)
  - Priority discovery
  - Read receipts
- [x] Pricing: monthly ($9.99/mo) + annual ($59.99/yr, "~$5/mo, save 50%") toggle
- [x] "Get ID Verified · Start 7-day free trial" CTA (no CC required for trial)
- [x] Free tier row shows current benefits, no negative framing. Free tier includes: basic Guardian (1 contact), photo-checked users (invisible — just how the platform works), messaging, discovery
- [x] VIP and Adventurer rows greyed out with "Coming Soon" + "Notify me" button
- [x] Screen-reader accessible (aria labels, semantic structure)
- [x] Copy externalized for localization (l10n keys)

### 6.6.3 — Blurred connection requests grid (renamed from "likes")
- [x] Rename: "Travelers interested in connecting with you" — NOT "likes"
- [x] `ConnectionRequestsScreen` — grid of blurred profile avatars with "X travelers want to connect" header
- [x] Tap a blurred card → contextual paywall modal: "See who wants to travel with you — start your free trial"
- [x] Free users see blurred; Explorer users see clear + can connect
- [x] Backend query for users who sent connection requests to current user

### 6.6.4 — Feature gate provider (all gates OPEN by default)
- [x] Create `FeatureGateProvider` — checks subscription tier + feature flags
- [x] All gates default to OPEN — nothing blocked for users yet
- [x] Infrastructure live and ready to activate via feature flags
- [x] Gated features with contextual modal copy (NOT generic "Upgrade to unlock"):

| Trigger | Contextual Copy |
|---|---|
| Tap blurred connection request | "See who wants to travel with you — start your free trial" |
| Toggle ID Verified-only filter (free user) | "Connect only with ID-verified travelers — upgrade for peace of mind" |
| Hit daily message cap | "You've sent 5 messages today — keep connecting with Explorer" |
| Try advanced filters | "Filter by age, language, and more — unlock with Explorer" |
| Try Guardian Pro features (2nd contact, location sharing) | "Add more emergency contacts and share your location — unlock with Explorer" |
| Try boost | "Get seen by more travelers nearby — coming soon" |
| Try read receipts | "See when your messages are read — unlock with Explorer" |
| Tap "Get ID Verified" from profile | Leads to Onfido ID verification — included with Pro, or one-time $4.99 add-on |
| Try ID verification as free user | "Verify your government ID — show travelers you're the real deal. Included with Explorer." |

- [x] Lock icon on ID Verified-only filter toggle for free users (opens upgrade modal on tap)
- [x] Daily message cap: Free = 5/day, Explorer = unlimited (start generous, tighten via flags)
- [x] "Kill switch" — `deactivateAllGates` flag that opens everything in under 60 seconds

### 6.6.5 — Multi-signal trust display
- [x] Profile page (self view): Trust & Verification section showing:
  - Email confirmed ✓ (already exists from Supabase Auth — invisible infrastructure, not a "trust signal")
  - Photo checked ✓ (from signup liveness check — invisible, just shows the platform is working)
  - **ID Verified ✓** (from Onfido government ID — the visible, badged trust signal)
  - Profile completeness % (calculated from bio, avatar, interests, trip)
  - "Get ID Verified · Explorer" CTA with mockup of the badge they'd earn (if not yet verified)
- [x] Other-user profiles: only show ID Verified badge (if they have it). No badge = no badge shown. Never show "Unverified" or negative framing. Accounts < 7 days old can optionally show "New traveler"
- [x] Free users who passed photo check: show no badge. The photo check is invisible infrastructure, not a status marker.
- [x] ID Verified badge: use reserved accent color (gold/teal), not just green. This badge is a premium visual signal.
- [x] This is the highest-ROI design element in the entire upgrade funnel — invest real design time here

### 6.6.6 — Chat safety banners
- [x] ID Verified user chat: subtle "This traveler is ID Verified ✓" banner at top of conversation (appears once)
- [x] Non-ID-Verified user chat: no negative banner. Users who passed photo check are real people — just not ID-verified. Show nothing, or a neutral "Remember: meet in public places and trust your instincts" (same for all users, not tied to verification status)
- [x] Banners are informational, not alarming — reinforce Pro value without shaming free users or implying non-ID-verified users are unsafe

### 6.6.7 — Subscription management screen
- [x] `SubscriptionManagementScreen` — current plan, manage/cancel
- [x] Shows: next renewal date, price, tier benefits, trial end date (if in trial)
- [x] "Change plan" option (monthly ↔ annual)
- [x] "Cancel subscription" — frictionless:
  - Single confirmation (no dark patterns, no 5-step gauntlet)
  - One-question exit survey: "Why are you cancelling?" (optional, free text + preset reasons)
  - On cancel: degrade to Free tier, keep "Previously verified" status, lose active Verified badge
- [x] Accessed from Profile Settings → Subscription
- [x] Mock payment flow (StoreKit/Play Billing integration deferred — plan the split now)

### 6.6.8 — Analytics / telemetry for monetization funnel
- [x] Track full funnel events:
  - `paywall_viewed` (with source: which friction point triggered it)
  - `paywall_cta_tapped` (with tier: monthly vs annual)
  - `trial_started` / `trial_ended` / `trial_converted`
  - `subscription_started` / `subscription_cancelled` / `subscription_renewed`
  - `feature_gate_blocked` (which gate, which user tier)
  - `connection_requests_viewed` (blurred vs revealed)
  - `verified_filter_toggled` (by tier)
  - `daily_message_cap_reached`
- [x] Funnel tracking: impression → trial → paid → retained (30/60/90 day)
- [x] Without this, the feature-flag rollout is flying blind

### 6.6.9 — Sequenced rollout plan (post-launch, not in this sprint)
Document the plan now, execute after launch:
- Week 1: Turn on blurred connection requests grid only (lowest churn risk, highest conversion)
- Week 3: Turn on verified-only filter gate (requires network density)
- Week 6: Turn on daily message cap (after measuring free-user engagement levels)
- Week 10+: Advanced filters, boost, read receipts
- Never flip all gates at once — you'll never know what caused conversion shifts or free-tier churn

### 6.6.10 — Payment platform planning
- [x] Document the mobile-vs-web payment split:
  - **Mobile (iOS):** StoreKit 2 for subscriptions (Apple takes 15–30%)
  - **Mobile (Android):** Google Play Billing Library (Google takes 15%)
  - **Web:** Stripe for direct subscriptions
- [x] Design subscription entitlement verification: RevenueCat or custom server-side validation
- [x] This sprint uses mock payments; real SDK integration is a separate sprint (Sprint 7.5)

---

## Test Plan
- [x] Unit: FeatureGateProvider returns correct values for each tier
- [x] Unit: Subscription entity handles trial dates, cancellation, degradation
- [x] Widget: PaywallScreen renders correctly for free/explorer tiers
- [x] Widget: ConnectionRequestsScreen shows blurred for free, clear for explorer
- [x] Widget: Chat safety banners show correct copy per verification status
- [x] Widget: Profile trust section shows all signals
- [x] Integration: free user taps blurred card → paywall appears
- [x] Integration: explorer user taps blurred card → reveals connection request
- [x] Integration: free user hits message cap → contextual upgrade modal
- [x] Kill switch test: `deactivateAllGates` flag opens all features in < 60 seconds
- [x] Snapshot: paywall screen in both light/dark themes
- [x] `flutter analyze` — no errors
- [x] `flutter test` — all tests pass

## Verification
```bash
flutter analyze   # No issues found (0 errors, 0 warnings, 0 infos)
flutter test      # 59/59 tests passed
# Manual: view paywall (safety hero), blurred connection requests, chat banners, trust section, cancellation flow
```

## Definition of Done
- [x] Paywall leads with safety hero (verification), not feature bullets
- [x] "Likes" renamed to travel-appropriate framing everywhere
- [x] Blurred connection requests grid works (free=blurred, explorer=clear)
- [x] Feature gate provider with all gates open by default
- [x] Contextual modal copy for each friction point (NOT generic)
- [x] Multi-signal trust display on profile (email, photo, ID, completeness %)
- [x] Chat safety banners for verified and unverified conversations
- [x] Daily message cap (5/day free) enforced but generous
- [x] Lock icon on verified-only filter for free users
- [x] Subscription management with frictionless cancellation + exit survey
- [x] Cancellation degrades to "Previously verified" status
- [x] Annual pricing tier defined alongside monthly
- [x] Analytics events for full monetization funnel
- [x] Mobile vs web payment split documented
- [x] Sequenced rollout plan documented
- [x] Screen-reader accessible paywall and modals
- [x] All copy externalized for localization
- [x] All tests pass: `flutter test` — 59/59
- [x] `flutter analyze` — no issues found
