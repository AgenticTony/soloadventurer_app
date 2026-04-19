# SoloAdventurer: Roadmap to Production Excellence

**Date:** 2026-04-09
**Purpose:** Reference document mapping the gap between current v1.0 (post-sprint) and industry-leading social/matching apps (Tinder, Bumble, Hinge). Honest assessment with phased approach to close each gap.

---

## Current State (Post-Sprint 8)

After completing Sprints 1a through 8, SoloAdventurer will be:

- A shippable app on TestFlight + Google Play
- Real auth with MFA, encrypted storage, certificate pinning
- Working chat with realtime messaging, push notifications, typing indicators
- Safety features (SOS, check-ins, location sharing) with real hardware
- Offline-first with sync conflict resolution
- Clean architecture with consistent Riverpod patterns
- ~50%+ test coverage, CI gates, Sentry monitoring
- Google Places + Viator booking integration
- Activity-based matching with shared-interest icebreakers

**This is a legitimate, launchable product.** Many successful apps started with less.

---

## The Gap: What Industry Leaders Have

The table below maps what Match Group, Bumble, and Hinge have that SoloAdventurer does not, organized by priority and feasibility for a solo/small team.

### Tier 1: Must-Have Before Scale (Blocks Growth)

| Category | What They Have | What We Have | What It Takes to Close |
|----------|---------------|--------------|----------------------|
| **Photo Verification** | Selfie + face match against profile photos. Bumble requires it. Tinder has optional "Photo Verified" badge. Manual review queue for edge cases. | Profile photo upload to Supabase Storage. No verification. | **Implementation:** Add selfie-capture flow during onboarding. Use a face comparison API (e.g., AWS Rekognition, Azure Face API, or open-source FaceNet via Supabase Edge Function). Store verification status in `profiles` table. Show verified badge on match cards. **Effort:** 1-2 sprints. **Cost:** ~$0.001/verification via cloud API. |
| **Content Reporting + Moderation** | User reports flow into moderation queue. AI auto-flags nudity/harassment. Human reviewers handle edge cases. Automated bans escalate. | Nothing. Users cannot report other users, messages, or content. | **Implementation:** Add "Report" button on profiles, messages, and journal entries. Create `reports` table in Supabase with status workflow (pending → reviewed → actioned). Supabase Edge Function for auto-flagging (profanity filter, image NSFW check via API). Admin dashboard (simple web app) for manual review. Automated warnings/bans after threshold. **Effort:** 2 sprints (reporting + moderation queue + admin). |
| **GDPR/CCPA Compliance** | Data Protection Officer, consent management, automated data export (JSON), right-to-deletion with 30-day enforcement, cookie/banner tracking, data retention policies, privacy impact assessments. | Basic RLS policies. Account deletion via Supabase Edge Function. No data export, no consent management, no retention policies. | **Implementation:** (1) Privacy policy + terms of service (legal review). (2) Data export endpoint: Edge Function that queries all user tables and returns JSON download. (3) Consent management: track consent timestamps for location, notifications, marketing. (4) Data retention: scheduled Edge Function that purges old data per policy. (5) Age verification: require birthdate during signup, block under 18. **Effort:** 1 sprint for technical + legal review. **Cost:** Legal review varies ($2-10K). |
| **Bot/Fraud Detection** | Device fingerprinting, behavioral analysis (swipe speed, message patterns), catfish detection via reverse image search, coordinate fraud ring detection, phone number verification. | Phone number available via Supabase auth. No behavioral analysis. | **Implementation:** (1) Require phone verification during signup (Supabase auth supports SMS OTP). (2) Rate-limit matching actions (max 100 swipes/day for free tier). (3) Flag accounts with suspicious patterns (mass messaging, identical messages to multiple users). (4) Block known disposable email domains. (5) Store device fingerprint (platform, OS version, install ID) and flag duplicates. **Effort:** 1 sprint for basics. ML-based detection comes later. |

### Tier 2: Strong Competitive Advantage (Drives Retention)

| Category | What They Have | What We Have | What It Takes to Close |
|----------|---------------|--------------|----------------------|
| **Matching Algorithm** | Tinder: ELO score + collaborative filtering + 10B+ swipe data + real-time ranking optimization. Bumble: women-first queue + interest matching. Hinge: "designed to be deleted" with prompt-based matching + most-compatible algorithm. | Activity-overlap matching (shared interests from Google Places + Viator). Basic geographic + date overlap. | **Phase 1 (launch):** Current activity-overlap matching is actually differentiated for the travel niche. Lean into it. Add compatibility scoring based on travel style (budget, pace, interests). **Phase 2 (with data):** Implement collaborative filtering ("travelers like you also matched with..."). Track match → chat → meet conversion rates. Optimize for successful connections, not just matches. **Phase 3 (ML):** Train ranking model on conversion data. A/B test matching algorithms. Personalized discovery feeds. **Key insight:** You don't need Tinder's algorithm. You need the *right* algorithm for solo travelers. Focus on trip compatibility (dates, destinations, pace, budget) — that's your moat. |
| **A/B Testing / Feature Flags** | Server-side feature flags. Statistical significance engine. Every UI element tested. Rollouts by percentage. Rollback instantly. | Basic analytics events (Sprint 1a). No feature flags. No experiment tracking. | **Implementation:** Use a feature flag service (LaunchDarkly, Firebase Remote Config, or simple Supabase `feature_flags` table). Start with: matching algorithm variants, onboarding flow variants, notification timing variants. Track conversion per variant. Statistical significance calculator built into analytics dashboard. **Effort:** 1 sprint to integrate Firebase Remote Config (free tier covers most needs). |
| **Push Notification Strategy** | ML-optimized send times per user. Personalized notification content. Re-engagement campaigns for dormant users. Delivery analytics (open rate, conversion). A/B test notification copy. | Basic push on new message (Sprint 3). Scheduled check-in reminders (Sprint 3). No personalization, no re-engagement, no analytics. | **Implementation:** (1) Track notification open rates per type. (2) Segment users: active (last 7 days), at-risk (7-30 days), dormant (30+ days). (3) Create re-engagement campaigns: "New travelers in Barcelona this week!" or "Your trip to Paris is in 3 days — find a travel buddy." (4) A/B test notification timing and copy. (5) Respect quiet hours and mute preferences (already implemented). **Effort:** 1 sprint for segmentation + campaigns. |
| **Photo Infrastructure** | AI photo ranking (which photo gets most right-swipes). Smart cropping to faces. CDN with 50ms global delivery. Lazy loading with progressive blur-up. Profile photo verification. | `cached_network_image` + Supabase Storage. No ranking, no smart crop, no CDN optimization. | **Implementation:** (1) Supabase has a global CDN — enable it for Storage buckets. (2) Add image transformation via Supabase Edge Function (resize, crop to face center using face detection API). (3) Track which profile photos get the most matches — surface "best photo" first. (4) Add progressive JPEG loading with blur placeholder (already partially done with `LazyLoadImage`). **Effort:** 1 sprint. |
| **Onboarding Optimization** | Tinder: 5-step onboarding, <2 minutes, phone + name + birthday + photos + location. A/B tested hundreds of variants. Gamified with "you're almost there!" progress bars. 80%+ completion rate. | Standard signup flow. No optimization data. No A/B testing. | **Implementation:** (1) Measure current funnel: signup start → email verify → profile setup → first trip → first match → first message. (2) Identify biggest drop-off. (3) Reduce friction: pre-fill what you can, defer non-essential fields, show value before asking for effort. (4) Add progress indicator. (5) A/B test variants. **Effort:** Continuous optimization. |

### Tier 3: Scale Infrastructure (Needed at 100K+ Users)

| Category | What They Have | What SoloAdventurer Needs | When |
|----------|---------------|--------------------------|------|
| **Multi-Region Infrastructure** | Tinder: 6 AWS regions, <50ms latency globally. Auto-scaling handles 2M+ concurrent users. | Single Supabase region (likely US-East). | At 50K+ users or when expanding to Asia/Europe. Migrate to Supabase with read replicas or add Cloudflare CDN + edge caching for static assets. |
| **Real-Time at Scale** | Custom WebSocket infrastructure. Millions of concurrent connections. | Supabase Realtime (Postgres-based). | Supabase Realtime handles ~200K concurrent connections per project. Sufficient for 100K+ users. Beyond that, evaluate Ably, Pusher, or custom WebSocket layer. |
| **Database at Scale** | Sharded PostgreSQL, read replicas, connection pooling (PgBouncer), query optimization team. | Single PostgreSQL instance via Supabase. | At 500K+ rows in any table: add Supabase read replicas, optimize queries, add connection pooling. Supabase handles this well up to ~1M MAU. |
| **Search at Scale** | Elasticsearch for profile matching. Geospatial indexing for "who's nearby." | PostgreSQL full-text search via Supabase. | At 100K+ profiles: consider Meilisearch or Supabase pg_trgm for fuzzy search. At 1M+: Elasticsearch. |
| **Cost Optimization** | Reserved instances, spot instances, CDN origin shielding, image format optimization (WebP/AVIF), query caching layers. | Supabase free/paid tier. Pay-per-request Edge Functions. | Monitor Supabase costs weekly. Optimize Edge Function cold starts. Add caching layers when API costs exceed $500/month. |

### Tier 4: Operational Excellence (Needed at Team Scale)

| Category | What They Have | What SoloAdventurer Needs | When |
|----------|---------------|--------------------------|------|
| **SRE / On-Call** | 24/7 on-call rotations. PagerDuty escalation. SLOs: 99.9% uptime, <200ms p99 latency. Incident management runbooks. Post-mortem culture. | Sentry alerts. No SLOs. No on-call. | When you have a team of 3+ engineers. Start with basic SLOs: 99.5% uptime, <500ms p95 API latency. |
| **Device QA Lab** | 200+ device configurations. Automated visual regression tests. Performance budgets per device tier (low/mid/high). Real-device testing cloud (BrowserStack, Firebase Test Lab). | Manual QA on a few devices. | Start with Firebase Test Lab (free tier: 10 tests/day). Add device-tier performance budgets in CI (low-end: <5s cold start, mid: <3s, high: <1.5s). |
| **Security Program** | Dedicated security team. Annual penetration tests ($50-100K). Bug bounty program (HackerOne). Real-time threat detection. SOC 2 Type II compliance. | OWASP checklist pass (Sprint 8). Sentry error monitoring. | Pre-Series A: hire a security consultant for a one-time pen test ($5-15K). Set up a lightweight bug bounty via HackerOne (free tier). SOC 2 when enterprise customers ask for it. |
| **Analytics Platform** | Custom data warehouse (Snowflake/BigQuery). Real-time dashboards (Looker). Event tracking: 500+ event types. Cohort analysis, retention curves, LTV modeling, churn prediction. | Basic analytics service (Sprint 1a). Sentry performance. | Start with PostHog (open-source, self-hosted or cloud, free tier covers 1M events/month). Add Amplitude or Mixpanel for product analytics when you need cohort/funnel analysis. Build a data warehouse when you need ML features. |
| **Internationalization** | 40+ languages. RTL layout support. Localized matching algorithms (different norms per culture). Region-specific features. In-app translation for messages. | English only. | After product-market fit in English-speaking markets. Start with Spanish, French, German, Japanese (key solo travel markets). Use Flutter's built-in `intl` package + Crowdin for translation management. |

---

## Phased Roadmap

### Phase 1: Launch-Ready (Current Sprints 1a → 8)
**Goal:** Ship a secure, tested, production-quality v1.0
**Timeline:** 16 weeks (current sprint plan)
**Outcome:** App on TestFlight + Google Play Internal Testing

### Phase 2: Growth Foundation (Post-Launch Sprints 9-12)
**Goal:** Close Tier 1 gaps. Prepare for first 1,000 users.
**Timeline:** 8 weeks post-launch

| Sprint | Theme | Key Deliverables |
|--------|-------|-----------------|
| Sprint 9 | Trust & Safety | Photo verification, content reporting + moderation queue, basic bot detection, phone verification |
| Sprint 10 | Compliance + Legal | GDPR data export, consent management, age verification, privacy policy, terms of service |
| Sprint 11 | Growth Infrastructure | A/B testing (Firebase Remote Config), onboarding funnel optimization, push notification segmentation |
| Sprint 12 | Photo + Discovery | Photo ranking, smart cropping, Supabase CDN optimization, profile photo A/B testing |

### Phase 3: Scale Preparation (At 10K+ Users)
**Goal:** Optimize for growth. Close Tier 2 gaps.
**Timeline:** Ongoing, data-driven

- Matching algorithm optimization based on conversion data
- PostHog analytics integration for cohort/funnel analysis
- Firebase Test Lab for automated device testing
- Push notification re-engagement campaigns
- Performance budgets per device tier
- First external pen test

### Phase 4: Enterprise Grade (At 100K+ Users, Post-Funding)
**Goal:** Match Group engineering quality in our niche.
**Timeline:** Requires dedicated team (5-10 engineers)

- ML-powered matching and recommendations
- Multi-region infrastructure
- Full fraud detection system
- Data warehouse + ML pipeline
- i18n for top 5 markets
- SOC 2 compliance
- SRE team with on-call rotations

---

## Key Insight: Play a Different Game

Tinder, Bumble, and Hinge are **general-purpose dating apps** competing on the same users with the same mechanics. SoloAdventurer is a **travel-specific matching app** — the winning strategy isn't to replicate their infrastructure, it's to:

1. **Own the niche.** Be the undisputed #1 app for solo travelers to find companions. Travel compatibility (dates, destinations, pace, budget) is a harder matching problem than "hot or not" — and it's your moat.

2. **Leverage your differentiators.** Viator booking integration (Sprint 5), destination discovery, activity-based matching — no dating app has this. This is what makes SoloAdventurer unique.

3. **Focus on trust, not scale.** Solo travelers (especially women) care more about safety than about having 10,000 matches. Your safety features (SOS, check-ins, trusted contacts, women-only mode) are more valuable than Tinder's ELO score.

4. **Don't build for 50M users yet.** Build for 1,000 passionate users first. Then 10,000. The infrastructure needs change at each order of magnitude. Supabase handles well up to ~1M MAU — you have time.

The Match Group comparison is useful as a *direction*, not a *destination*. Your v1.0 is the right scope. Ship it, learn from real users, then invest where the data tells you.

---

## Reference: Match Group Scale (Context)

| Metric | Tinder | Bumble | Hinge |
|--------|--------|--------|-------|
| Monthly Active Users | 75M+ | 40M+ | 20M+ |
| Engineering Team | 500+ | 300+ | 150+ |
| Annual R&D Spend | ~$600M | ~$200M | ~$100M |
| Matching Algorithm | ELO + ML + 10B swipes | Women-first + ML | Prompt-based + ML |
| Real-Time Connections | 2M+ concurrent | 1M+ concurrent | 500K+ concurrent |
| Data Points per User | 1,000+ tracked events | 500+ | 300+ |
| Feature Experiments | ~100 concurrent A/B tests | ~50 concurrent | ~30 concurrent |
| Supported Languages | 40+ | 30+ | 20+ |
| Revenue per User | ~$15/year | ~$12/year | ~$18/year |

These numbers exist because they have **hundreds of engineers and hundreds of millions in revenue**. SoloAdventurer's path to this level requires funding, team growth, and most importantly — real user data to drive decisions.
