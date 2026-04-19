# SoloAdventurer — Complete Running Cost Analysis
**Generated:** 2026-04-18 (v3 — revised with venture-scale strategy, realistic adjustments, sensitivity analysis)
**Scope:** Mobile (Flutter) + Web (Next.js) — all services, all planned features, AI/ML costs, profit margins, growth strategy

---

## Complete Service Inventory

### Mobile App (Flutter) — 12 external services
| # | Service | Usage | Cost Model | Status |
|---|---|---|---|---|
| 1 | Supabase Pro | PostgreSQL, Auth, Realtime, Storage, 12 Edge Functions, pgvector | $25/mo + usage | Active |
| 2 | Google Places API | Location search, place details, geocoding | $200 free credit, then per-call | Active |
| 3 | Google Maps SDK | Map display in mobile app | Free (SDK only) | Active |
| 4 | Viator Transactional API | Tours & activities booking | Commission (revenue, not cost) | Active |
| 5 | Onfido | Identity verification (KYC) | ~$3.50/check | Simulated (going live Sprint 7.5) |
| 6 | Firebase Cloud Messaging | Push notifications | Free | Active |
| 7 | Sentry Team | Error monitoring | $26/mo | Active |
| 8 | Twilio | SMS safety alerts to trusted contacts | Per SMS (~$0.05-0.10/msg) | Active |
| 9 | Resend | Transactional emails (safety alerts) | Free tier then per-email | Active |
| 10 | Xenova/Transformers | AI profile embeddings (runs in Edge Function) | Free (local model) | Active |
| 11 | OpenRouter | LLM API (GPT-4 via proxy) | Per-token | Configured, not yet calling |
| 12 | OpenAI | Embeddings (text-embedding-3-small) | Per-token | Configured, not yet calling |

### Web App (Next.js)
| # | Service | Usage | Cost Model | Status |
|---|---|---|---|---|
| 13 | Vercel | Hosting & deployment | $0-20/mo | Not yet deployed |
| 14 | Mapbox GL JS | Web map display | Free up to 50K loads | Active |
| 15 | Supabase | Same instance as mobile (shared) | Already counted | Active |

### Planned / Stub Services
| # | Service | Usage | Cost Model | Status |
|---|---|---|---|---|
| 16 | Weather API | Itinerary weather optimization | TBD (~$0.01-0.05/call) | Stub (_StubWeatherService) |
| 17 | Apple App Store | iOS subscription payments | 30% yr1, 15% after | Sprint 7.5 |
| 18 | Google Play Store | Android subscription payments | 15% | Sprint 7.5 |
| 19 | Stripe | Web subscription payments | 2.9% + $0.30/txn | Sprint 7.5 |
| 20 | RevenueCat (recommended) | Cross-platform subscription mgmt | 1% after $2,500 revenue | Not integrated |
| 21 | Domain | soloadventurer.com | ~$12/year | Active |

---

## Detailed Service Pricing (verified 2026-04-18)

### 1. Supabase — $25/mo base + usage overages

**Pro Plan: $25/month** (includes $10 compute credits)

| Resource | Pro Included | Overage Rate |
|---|---|---|
| Database | 8 GB | $0.125/GB |
| Storage | 100 GB | $0.021/GB/mo |
| MAUs | 100,000 | $0.00325/user |
| Edge Function invocations | 2,000,000 | $2.00/million |
| Bandwidth | 250 GB | $0.09/GB |
| Realtime connections | 500 concurrent | Included |
| Realtime messages | 2,000,000/mo | Included |
| pgvector (embeddings) | Included | Included |
| Database backups | 7-day retention | Included |

**12 Edge Functions deployed:**
find-overlapping-trips, find-potential-matches-semantic, generate-profile-embedding, notify-new-match, notify-new-message, process-checkin, process-safety-alert, request-connection, respond-connection, send-push-notification, trigger-sos, verify-with-onfido

### 2. Google Maps Platform — $200/mo free credit, then pay-per-use

| API | Free Monthly | Cost per 1,000 |
|---|---|---|
| Places — Text Search | $200 credit (~6K calls) | $32.00 |
| Places — Nearby Search | $200 credit (~6K calls) | $32.00 |
| Places — Place Details | $200 credit (~12K calls) | $17.00 |
| Places — Place Photos | $200 credit | $7.00 |
| Maps SDK (mobile) | Unlimited free | Free |
| Geocoding API | $200 credit (~40K calls) | $5.00 |

The $200 monthly credit is shared across all Google Maps SKUs.

### 3. Mapbox (Web maps only)

| Product | Free Tier | Overage |
|---|---|---|
| Mapbox GL JS (web) | 50,000 loads/month | $5.00/1,000 loads |

Mobile uses Google Maps SDK (free), not Mapbox.

### 4. Onfido (Identity Verification) — Per check

| Check Type | Est. Cost |
|---|---|
| Document + Facial similarity combined | ~$3.50/check |
| Enterprise volume (>500/mo) | ~$2.00-2.50/check |

### 5. Viator Transactional API — Commission model (REVENUE, not cost)

| Model | Rate |
|---|---|
| Viator commission | 15-25% (Viator keeps) |
| Your revenue share | 75-85% of booking value |
| API access | Free |

### 6. Firebase Cloud Messaging — FREE
Push notifications: **$0** — unlimited messages, unlimited topics.

### 7. Sentry — $26/mo
Team plan: 50K errors, 5M spans, 5GB logs included.

### 8. Twilio — Per SMS (NEW, was missed)
Used by `process-safety-alert` and `trigger-sos` Edge Functions to send SMS to trusted contacts.

| Type | Cost |
|---|---|
| SMS (US/UK) | ~$0.05-0.10 per message |
| Phone number (UK) | ~$1.00-1.50/mo |
| Expected volume | 0-500 SMS/mo (safety alerts only) |

### 9. Resend — Transactional emails (NEW, was missed)
Used by `process-safety-alert` for email alerts to trusted contacts.

| Plan | Price | Included |
|---|---|---|
| Free | $0/mo | 3,000 emails/mo, 100 emails/day |
| Pro | $20/mo | 50,000 emails/mo |

Safety alert emails will stay well within free tier limits.

### 10. AI / ML Services (NEW, was missed)

#### 10a. Xenova/Transformers — Profile Embeddings (FREE)
- Model: `Xenova/all-MiniLM-L6-v2` (384-dim embeddings)
- Runs **locally inside the Supabase Edge Function**
- No external API cost — uses Edge Function compute time only
- Called by `generate-profile-embedding` function
- Stored in `profiles.profile_embedding` column (pgvector)

#### 10b. Matching Algorithm — Semantic Search (FREE)
- Uses Supabase `pgvector` for similarity search
- `find-potential-matches-semantic` RPC: 40% semantic, 25% date overlap, 15% activities, 10% destination, 10% age
- No external AI API calls — all compute happens in Supabase
- Cost: included in Supabase Pro plan

#### 10c. OpenRouter — LLM API (CONFIGURED, not yet active)
- API endpoint: `https://openrouter.ai/api/v1`
- Models configured: `REASONER_MODEL=gpt-4`, `PRIMARY_MODEL=gpt-4`
- **Currently NOT called from any Dart code**
- Planned for: AI itinerary generation, smart suggestions, AI trip planning

| Model | Est. Cost | Use Case |
|---|---|---|
| GPT-4 (via OpenRouter) | ~$10-30/1M input tokens | AI itinerary generation |
| GPT-4o-mini (cheaper alternative) | ~$0.15/1M input tokens | Smart suggestions, trip tips |

**Estimated cost when active:**
- AI itinerary generation: ~2,000 tokens/call × $10/1M = ~$0.02/itinerary
- 1,000 AI itineraries/mo = ~$20/mo
- Switch to GPT-4o-mini: same volume = ~$0.30/mo

#### 10d. OpenAI Embeddings (CONFIGURED, not yet active)
- Model: `text-embedding-3-small`
- **Currently NOT called** — profile embeddings use free Xenova model
- Could be upgraded for better matching quality

| Model | Cost |
|---|---|
| text-embedding-3-small | $0.02/1M tokens |
| Per user embedding (~500 tokens) | ~$0.00001 |

Negligible cost even at scale.

#### 10e. Itinerary Optimizer — Rules-based (FREE)
- Analyzes weather, geographic clustering, timing, travel time
- No AI/LLM calls — pure algorithm
- Uses: Weather API (stub), Location Service, Places Service

#### 10f. Recommendation Engine — Scoring algorithm (FREE)
- 6-signal scoring: interest match (40pts), weather fit (25), ratings (15), proximity (10), solo popularity (5), availability (5)
- No AI/LLM calls — deterministic scoring

### 11. Weather API (PLANNED — stub now)
- `WeatherService` is a stub (`_StubWeatherService`)
- Will need: OpenWeatherMap, WeatherAPI, or similar

| Provider | Free Tier | Cost |
|---|---|---|
| OpenWeatherMap | 1,000 calls/day | $0.0015/call after |
| WeatherAPI.com | 1M calls/mo free | $0.003/call after |

At 10K users checking weather: ~1,000 calls/day = stays free.

### 12. Vercel (Web hosting) — $0-20/mo

| Plan | Price | Included |
|---|---|---|
| Hobby | Free | 100GB bandwidth |
| Pro | $20/mo | 1TB bandwidth, analytics |

### 13. Payment Processing (Revenue concern, not direct cost)

| Platform | Fee |
|---|---|
| Apple App Store (iOS) | 30% year 1, 15% renewal |
| Google Play Store (Android) | 15% on subscriptions |
| Stripe (Web) | 2.9% + $0.30/transaction |
| RevenueCat (recommended) | Free until $2,500 revenue, then 1% |

---

## Cost Scenarios (UPDATED with all services)

### Scenario 1: Soft Launch — 1,000 MAU
**Monthly Cost: ~$52-102**

| Service | Cost | Notes |
|---|---|---|
| Supabase Pro | $25 | Well within limits |
| Google Maps Platform | $0 | $200 free credit sufficient |
| Mapbox (web) | $0 | Under 50K free loads |
| Onfido | $0 | Still simulated |
| Firebase FCM | $0 | Free |
| Sentry Team | $26 | Sufficient |
| Twilio SMS | ~$2 | ~20 safety alerts/mo |
| Resend emails | $0 | Under 3,000 free emails/mo |
| AI/ML (Xenova embeddings) | $0 | Runs free in Edge Functions |
| AI/ML (OpenRouter) | $0 | Not active yet |
| Weather API | $0 | Stub, not active |
| Vercel Hobby | $0 | Under bandwidth limits |
| Domain | ~$1/mo | |
| **TOTAL** | **~$54/mo** | **Mobile + Web** |

### Scenario 2: Growth — 10,000 MAU
**Monthly Cost: ~$400-500**

| Service | Cost | Notes |
|---|---|---|
| Supabase Pro + compute | $35 | May need slight compute upgrade |
| Supabase overages | $0-50 | Edge Functions, bandwidth |
| Google Maps Platform | $100-200 | Beyond free credit |
| Mapbox (web) | $0-25 | Likely still free |
| Onfido | $700 | 200 checks/mo × $3.50 |
| Firebase FCM | $0 | Free |
| Sentry Team | $26 | Sufficient |
| Twilio SMS | ~$10 | ~100-200 safety alerts/mo |
| Resend emails | $0 | Still under free tier |
| AI/ML (OpenRouter — if active) | $20-50 | AI itineraries for Explorer users |
| Weather API | $0 | Under 1K calls/day free tier |
| Vercel Pro | $20 | Upgrade for analytics |
| Domain | ~$1/mo | |
| **TOTAL** | **~$912-1,117/mo** | |

**Optimized (use GPT-4o-mini, fewer map calls, negotiate Onfido): ~$400-500/mo**

### Scenario 3: Scale — 100,000 MAU
**Monthly Cost: ~$4,000-6,000**

| Service | Cost | Notes |
|---|---|---|
| Supabase Pro + compute | $125 | Larger instances |
| Supabase overages | $325 | 100K MAU at quota + Edge Function overages |
| Google Maps Platform | $500-1,500 | Heavy place search usage |
| Mapbox (web) | $100-250 | 20K-50K loads beyond free |
| Onfido | $2,000 | ~570 checks/mo at negotiated $3.50 |
| Firebase FCM | $0 | Free |
| Sentry Team | $26-80 | May need higher limits |
| Twilio SMS | ~$50 | ~500-1,000 safety alerts/mo |
| Resend (may need Pro) | $0-20 | Safety alert emails |
| AI/ML (OpenRouter) | $100-200 | AI itineraries at scale |
| Weather API | $0-15 | May exceed free tier |
| Vercel Pro | $20 | |
| Domain | ~$1/mo | |
| **TOTAL** | **~$3,247-4,686/mo** | |

---

## Cost Per User Analysis (UPDATED)

### Variable Costs Per User

| Cost Driver | Per-User Cost | Frequency |
|---|---|---|
| Supabase (at 100K MAU) | $0.00325/user/mo | After 100K included |
| Google Places (10 searches/user/mo) | ~$0.32/user/mo | Text Search @ $32/1K |
| Onfido verification | $3.50 | One-time per check |
| Twilio SMS (safety alerts) | ~$0.001/user/mo | Only when alerts triggered |
| AI itinerary (OpenRouter) | ~$0.02/user/mo | If using GPT-4 |
| AI itinerary (GPT-4o-mini) | ~$0.0003/user/mo | Cheaper alternative |
| Mapbox web (50% web users) | $0.005/user/mo | After 50K free loads |
| OpenAI embedding | ~$0.00001/user | One-time per profile update |
| Weather API | ~$0.001/user/mo | Negligible |

### Total Variable Cost Per User Per Month (at 10K MAU)
- **Without AI itineraries:** ~$0.32/user/mo (dominated by Google Places)
- **With AI itineraries (GPT-4o-mini):** ~$0.33/user/mo
- **With AI itineraries (GPT-4):** ~$0.35/user/mo

### Break-Even Analysis (Explorer @ $9.99/mo)

| Scenario | Revenue/mo (after fees) | Covers |
|---|---|---|
| 100 paying (1% of 10K) | $699 (Apple) / $849 (Google) | Full 10K MAU infrastructure |
| 500 paying (0.5% of 100K) | $3,495 | Full 100K MAU infrastructure + AI |
| 1,000 paying (1% of 100K) | $6,990 | Everything + profit margin |

---

## AI/ML Cost Deep Dive

### Current AI Architecture (FREE)
```
Profile text → Xenova/all-MiniLM-L6-v2 (Edge Function, local) → 384-dim embedding
                                                                          ↓
User searches for matches → pgvector cosine similarity → composite score → ranked results
```
**Cost: $0** — runs inside Supabase Edge Function, no external API calls.

### Planned AI Features (when activated)
| Feature | Service | Model | Est. Cost/Call | Trigger |
|---|---|---|---|---|
| AI itinerary generation | OpenRouter | GPT-4o-mini | $0.002 | Explorer subscriber creates trip |
| Smart trip suggestions | OpenRouter | GPT-4o-mini | $0.001 | User browses destinations |
| AI chat assistant | OpenRouter | GPT-4o-mini | $0.005 | In-app help |
| Enhanced embeddings | OpenAI | text-embedding-3-small | $0.00001 | Profile update |

### AI Cost Scenarios (per month)
| Scenario | Users | Calls/mo | GPT-4o-mini | GPT-4 |
|---|---|---|---|---|
| Soft launch | 100 AI users | 1,000 | $2 | $30 |
| Growth | 1,000 AI users | 10,000 | $20 | $300 |
| Scale | 10,000 AI users | 100,000 | $200 | $3,000 |

**Recommendation:** Use GPT-4o-mini for production. Same quality for travel itineraries at 1/100th the cost.

---

## Annual Cost Projection (UPDATED)

| Phase | MAU | Monthly | Annual |
|---|---|---|---|
| Soft Launch (mo 1-6) | 500-2K | $54-102 | $648-1,224 |
| Growth (mo 7-12) | 5K-15K | $400-500 | $4,800-6,000 |
| **Year 1 Total** | | | **~$5,448-7,224** |
| Scale (Year 2) | 30K-100K | $3,000-4,700 | $36,000-56,400 |

---

## Cost Optimization Recommendations

1. **Google Places is the #1 variable cost.** Cache aggressively, use autocomplete ($5/1K) instead of Text Search ($32/1K) where possible.

2. **Use GPT-4o-mini, not GPT-4.** For travel itineraries and suggestions, the quality difference is negligible. Cost savings: 100x.

3. **Keep Xenova embeddings (free).** The 384-dim local model works well for matching. Only upgrade to OpenAI embeddings if you need significantly better quality.

4. **Negotiate Onfido enterprise pricing.** At 500+ checks/mo, ask for $2.00-2.50/check.

5. **Twilio SMS is cheap.** ~$0.05-0.10 per safety alert. Not worth optimizing — this is a safety feature.

6. **Resend stays free.** 3,000 emails/mo is generous. Safety alerts won't exceed this until 50K+ MAU.

7. **Weather API stays free.** OpenWeatherMap's 1,000 calls/day free tier covers most usage.

8. **Consider RevenueCat.** $0 until $2,500 revenue, then 1%. Simplifies cross-platform subscriptions enormously.

9. **Supabase Edge Functions at $2/million is excellent.** 12 functions with AI embeddings and matching queries at scale = still under $10/mo in overages.

---

## Summary: Complete Running Cost

| | Monthly | Annual |
|---|---|---|
| **Soft launch (1K MAU, no AI, simulated Onfido)** | **$54** | **$648** |
| **Growth (10K MAU, 200 Onfido checks, AI itineraries)** | **$400-500** | **$4,800-6,000** |
| **Scale (100K MAU, full AI, real Onfido)** | **$3,000-4,700** | **$36,000-56,400** |

**Top 3 cost drivers at scale:**
1. Onfido verification ($2,000/mo at 570 checks/mo)
2. Google Places API ($500-1,500/mo)
3. Supabase + overages ($450/mo at 100K MAU)

**Everything else is cheap or free:** FCM, Xenova embeddings, pgvector matching, Twilio SMS, Resend email, Mapbox, Weather API, OpenAI embeddings.

---

## Matching Algorithm Assessment

### Current Implementation

```
Profile text → Xenova/all-MiniLM-L6-v2 (Edge Function, local) → 384-dim embedding
                                                                          ↓
User searches for matches → pgvector cosine similarity → composite score → ranked results
```

**Composite scoring weights:**
- 40% semantic similarity (text embeddings)
- 25% date overlap (trip dates)
- 15% activity overlap (Jaccard similarity)
- 10% destination match (country/city)
- 10% age range proximity

### Is This the Right Approach?

**Short answer:** It works for launch. The architecture is sound but the weights and signals need tuning.

**The real issue:** `all-MiniLM-L6-v2` is a general-purpose sentence similarity model — it was trained for duplicate question detection, not interpersonal compatibility. It matches people who **wrote similar bios**, not people who would **enjoy traveling together**.

Travel compatibility is actually driven by:
- **Pace alignment** (relax-on-beach vs pack-every-hour)
- **Budget compatibility** (hostels vs 5-star)
- **Social energy** (introvert recharge vs extrovert always-out)
- **Independence level** (stick together vs meet-for-dinner)
- **Shared dates and destination** (logistical necessity)

None of these are captured well by text embeddings — they're **structured profile fields**.

### Current Approach: Pros & Cons

| Aspect | Assessment |
|---|---|
| Cost | **Excellent** — free, runs in Edge Function |
| Speed | **Good** — pgvector queries are fast |
| Architecture | **Good** — composite scoring is the right pattern |
| Semantic signal quality | **Adequate** — catches soft bio/personality similarity |
| Missing signals | **Weak** — no budget, pace, social energy, independence |
| Weight balance | **Needs work** — semantic is overweighted at 40% |

### Recommended Evolution Path

| Phase | Change | Cost Impact | Timeline |
|---|---|---|---|
| **Launch (now)** | Rebalance weights: 15% semantic, 30% date overlap, 25% activities, 15% destination, 15% age | $0 | 1 day |
| **Post-launch (Sprint 7)** | Add structured profile fields: budget range, pace, social energy, independence level | $0 | 1-2 days |
| **Post-launch (Sprint 8)** | Upgrade to OpenAI text-embedding-3-small (1536-dim) for better semantic signal | ~$5/mo | 1 day |
| **With data (Sprint 9+)** | Build collaborative filtering on actual match outcomes | $0 (Supabase) | 2-3 weeks |
| **Future** | Fine-tune custom embedding model on travel match data | Training cost only | 4-6 weeks |

### Upgrade Cost Analysis

| Approach | Monthly Cost (10K MAU) | Monthly Cost (100K MAU) | Quality |
|---|---|---|---|
| **Current (Xenova, local)** | $0 | $0 | Adequate |
| OpenAI text-embedding-3-small | $1-2 | $5-10 | Better |
| OpenAI text-embedding-3-large | $3-5 | $15-30 | Best |
| Custom fine-tuned model | Training: $200-500 one-time | $0 (local inference) | Optimal |

**Recommendation:** Launch with current approach + weight rebalance. Upgrade to OpenAI text-embedding-3-small post-launch for ~$5/mo. The structured profile fields will have 10x more impact on match quality than any embedding upgrade.

---

## Profit Margin Analysis

### Subscription Pricing (from Sprint 6.6)

| Tier | Monthly | Annual | Effective Monthly |
|---|---|---|---|
| Explorer | $9.99/mo | $59.99/yr | ~$5.00/mo |
| Adventurer | TBD (Coming Soon) | TBD | TBD |
| VIP | TBD (Coming Soon) | TBD | TBD |

### Net Revenue Per Subscriber (after all payment fees)

#### Monthly Plan ($9.99/mo)

| Platform | Gross | Platform Fee | RevenueCat (1%) | Net Revenue | Net Margin |
|---|---|---|---|---|---|
| **iOS Year 1** | $9.99 | -$3.00 (30%) | -$0.07 | **$6.92** | 69% |
| **iOS Year 2+** | $9.99 | -$1.50 (15%) | -$0.08 | **$8.41** | 84% |
| **Android** | $9.99 | -$1.50 (15%) | -$0.08 | **$8.41** | 84% |
| **Web (Stripe)** | $9.99 | -$0.59 (2.9%+$0.30) | -$0.09 | **$9.31** | 93% |

#### Annual Plan ($59.99/yr)

| Platform | Gross | Platform Fee | RevenueCat (1%) | Net Revenue | Net Monthly |
|---|---|---|---|---|---|
| **iOS Year 1** | $59.99 | -$18.00 (30%) | -$0.42 | **$41.57** | $3.46/mo |
| **iOS Year 2+** | $59.99 | -$9.00 (15%) | -$0.51 | **$50.48** | $4.21/mo |
| **Android** | $59.99 | -$9.00 (15%) | -$0.51 | **$50.48** | $4.21/mo |
| **Web (Stripe)** | $59.99 | -$2.04 (2.9%+$0.30) | -$0.58 | **$57.37** | $4.78/mo |

**Key insight:** Web subscribers via Stripe are worth **35% more** than iOS Year 1 subscribers. Encourage web signups and annual plans.

### Blended Net Revenue (Assumed Platform Mix)

Assuming typical Western market split: **iOS 55% / Android 30% / Web 15%**, all monthly:

| Period | Blended Net/mo/subscriber |
|---|---|
| Year 1 (monthly plan) | **$7.59/subscriber/mo** |
| Year 2+ (monthly plan) | **$8.43/subscriber/mo** |
| Year 1 (annual plan) | **$3.78/subscriber/mo** |
| Year 2+ (annual plan) | **$4.52/subscriber/mo** |

### Profit Margin Scenarios

#### Scenario 1: Soft Launch — 1,000 MAU, 10 paying subscribers (1% conversion)

| Line Item | Monthly | Annual |
|---|---|---|
| **Revenue** | | |
| Gross subscription revenue (10 × $9.99) | $99.90 | $1,199 |
| Less: Platform fees (blended ~24%) | -$24.00 | -$288 |
| Less: RevenueCat (1% after $2.5K) | $0 | $0 |
| **Net Subscription Revenue** | **$75.90** | **$911** |
| | | |
| **Costs** | | |
| Supabase Pro | $25 | $300 |
| Sentry | $26 | $312 |
| Twilio | $2 | $24 |
| Google Maps | $0 | $0 |
| Everything else | $1 | $12 |
| **Total Infrastructure** | **$54** | **$648** |
| | | |
| **Profit/Loss** | **+$21.90/mo** | **+$263/yr** |
| **Profit Margin** | **+29%** | |

**Break-even at 1K MAU:** ~7 paying subscribers covers all infrastructure.

---

#### Scenario 2: Growth — 10,000 MAU, 150 paying subscribers (1.5% conversion)

| Line Item | Monthly | Annual |
|---|---|---|
| **Revenue** | | |
| Gross subscription (150 × $9.99) | $1,499 | $17,988 |
| Viator booking commissions (est. 50 bookings × $40 avg × 12%) | $240 | $2,880 |
| **Gross Revenue** | **$1,739** | **$20,868** |
| | | |
| Less: Platform fees (blended ~22%) | -$330 | -$3,960 |
| Less: RevenueCat (1%) | -$14 | -$168 |
| **Net Revenue** | **$1,395** | **$16,740** |
| | | |
| **Costs** | | |
| Supabase Pro + compute + overages | $85 | $1,020 |
| Google Maps Platform | $150 | $1,800 |
| Onfido (150 checks, ~$2.50 negotiated) | $375 | $4,500 |
| Sentry | $26 | $312 |
| AI/ML (GPT-4o-mini, OpenRouter) | $20 | $240 |
| Twilio SMS | $10 | $120 |
| Vercel Pro | $20 | $240 |
| Everything else (domain, Resend, etc.) | $5 | $60 |
| **Total Infrastructure** | **$691** | **$8,292** |
| | | |
| **Profit/Loss** | **+$704/mo** | **+$8,448/yr** |
| **Profit Margin** | **+50%** | |

---

#### Scenario 3: Scale — 100,000 MAU, 1,500 paying subscribers (1.5% conversion)

| Line Item | Monthly | Annual |
|---|---|---|
| **Revenue** | | |
| Gross subscription (1,500 × $9.99) | $14,985 | $179,820 |
| Viator booking commissions (est. 500 bookings × $50 avg × 12%) | $3,000 | $36,000 |
| **Gross Revenue** | **$17,985** | **$215,820** |
| | | |
| Less: Platform fees (blended ~20%, more Year 2+ users) | -$3,597 | -$43,164 |
| Less: RevenueCat (1%) | -$144 | -$1,728 |
| **Net Revenue** | **$14,244** | **$170,928** |
| | | |
| **Costs** | | |
| Supabase Pro + compute + overages | $450 | $5,400 |
| Google Maps Platform (with caching) | $800 | $9,600 |
| Onfido (400 checks/mo × $2.50 negotiated) | $1,000 | $12,000 |
| Sentry Business | $80 | $960 |
| AI/ML (GPT-4o-mini at scale) | $150 | $1,800 |
| Mapbox web | $150 | $1,800 |
| Twilio SMS | $50 | $600 |
| Vercel Pro | $20 | $240 |
| Weather API | $15 | $180 |
| Everything else | $10 | $120 |
| **Total Infrastructure** | **$2,725** | **$32,700** |
| | | |
| **Profit/Loss** | **+$11,519/mo** | **+$138,228/yr** |
| **Profit Margin** | **+81%** | |

---

### Profit Per Paying Subscriber (at 10K MAU, 150 subscribers)

| Metric | Value |
|---|---|
| Net revenue per subscriber/mo | $9.30 |
| Infrastructure cost per subscriber/mo | $4.61 |
| **Profit per subscriber/mo** | **$4.69** |
| **Profit per subscriber/yr** | **$56.28** |
| Lifetime value (24-mo avg retention) | $112.56 net profit |

### Conversion Rate Impact on Profitability

At 10K MAU with ~$691/mo infrastructure:

| Conversion Rate | Paying Users | Net Revenue/mo | Profit/mo | Margin |
|---|---|---|---|---|
| 0.5% | 50 | $465 | -$226 | **-49% (loss)** |
| 1.0% | 100 | $930 | +$239 | **+26%** |
| 1.5% | 150 | $1,395 | +$704 | **+50%** |
| 2.0% | 200 | $1,860 | +$1,169 | **+63%** |
| 3.0% | 300 | $2,790 | +$2,099 | **+75%** |

**Break-even conversion rate at 10K MAU: ~0.75%** (75 paying subscribers)

### Annual vs Monthly Subscriber Profitability

At 10K MAU, 150 subscribers, mixed monthly/annual:

| Mix | Net Revenue/mo | Profit/mo | Margin |
|---|---|---|---|
| 100% monthly ($9.99) | $1,395 | +$704 | +50% |
| 75% monthly / 25% annual | $1,190 | +$499 | +42% |
| 50% monthly / 50% annual | $986 | +$295 | +30% |
| 25% monthly / 75% annual | $781 | +$90 | +12% |

**Trade-off:** Annual plans have lower margins per subscriber but higher retention and predictability. A 50/50 mix is healthy.

### Viator Booking Revenue (Additional)

| Scale | Bookings/mo | Avg Booking | Your Share (12%) | Annual Revenue |
|---|---|---|---|---|
| 1K MAU | 5 | $40 | $24 | $288 |
| 10K MAU | 50 | $45 | $270 | $3,240 |
| 100K MAU | 500 | $50 | $3,000 | $36,000 |

This is pure margin — no infrastructure cost for Viator (API is free, commission is revenue share).

---

## 5-Year Financial Projection

| Year | MAU | Paying (1.5%) | Net Sub Revenue | Viator Revenue | Infrastructure | **Net Profit** | **Margin** |
|---|---|---|---|---|---|---|---|
| **Year 1** | 1K-15K | 10-225 | $9K | $2K | $6K | **+$5K** | +45% |
| **Year 2** | 15K-50K | 225-750 | $68K | $15K | $30K | **+$53K** | +64% |
| **Year 3** | 50K-150K | 750-2,250 | $204K | $50K | $55K | **+$199K** | +78% |
| **Year 4** | 100K-300K | 1.5K-4.5K | $408K | $90K | $80K | **+$418K** | +84% |
| **Year 5** | 200K-500K | 3K-7.5K | $681K | $150K | $120K | **+$711K** | +87% |

**Assumptions:** 1.5% conversion rate, blended monthly+annual, negotiated Onfido at $2.50/check, Google Places cached, GPT-4o-mini for AI. Platform mix improves over time (more web = higher margins).

---

## Summary

### Running Costs

| Phase | Monthly | Annual |
|---|---|---|
| **Soft launch (1K MAU)** | **$54** | **$648** |
| **Growth (10K MAU, AI active)** | **$400-700** | **$4,800-8,400** |
| **Scale (100K MAU, full everything)** | **$2,700-4,700** | **$32,400-56,400** |

### Profit Margins

| Phase | Conversion | Net Revenue/mo | Cost/mo | **Profit/mo** | **Margin** |
|---|---|---|---|---|---|
| Soft launch (1K MAU) | 1.0% | $76 | $54 | **+$22** | **+29%** |
| Growth (10K MAU) | 1.5% | $1,395 | $691 | **+$704** | **+50%** |
| Scale (100K MAU) | 1.5% | $14,244 | $2,725 | **+$11,519** | **+81%** |

### Key Numbers to Remember

- **Break-even at 10K MAU:** 75 paying subscribers (0.75% conversion)
- **Profit per paying subscriber:** ~$4.69/mo or ~$56/yr
- **Best platform for margin:** Web via Stripe (93% net) — push web signups
- **Annual vs monthly:** Annual has 30% lower margin but 2x+ better retention
- **Cheapest path to profit:** Optimize Google Places caching (saves $200+/mo at 10K MAU)
- **Biggest margin lever:** Conversion rate — going from 1% to 2% doubles profit

---

## v3 Revisions — Realistic Adjustments

The v2 profit scenarios were directionally correct but leaned optimistic in several areas. This section corrects those assumptions and adds missing cost categories.

### Adjustments Made

| Assumption | v2 Value | v3 Value | Why |
|---|---|---|---|
| Base conversion rate | 1.5% | 1.0% | Stage-zero consumer social apps typically land at 0.5-1.5%; low end is more common |
| Onfido checks at launch | Steady-state | 3-5x spike first 3 months | Everyone who subscribes verifies immediately; step function, not linear |
| Viator booking rate | 0.5% of MAU | 0.15% of MAU | Most MAU are planning/browsing, not actively booking |
| Monthly/annual mix | 100% monthly | 50/50 split | If pushing annual, margins drop but retention improves |
| Churn/retention | 24-month avg | 12-18 months | 24 months is top-quartile; median consumer subscription is 6-12 months |

### Missing Cost Categories Added

| Category | Monthly Cost (10K MAU) | Monthly Cost (100K MAU) | Notes |
|---|---|---|---|
| Customer acquisition (CAC) | $500-2,000 | $5,000-15,000 | Content/SEO, ASO, influencer seeding, some paid |
| Support tools + staff | $50-200 | $500-2,000 | HelpScout/Intercom + part-time contractor at scale |
| Legal/compliance | ~$200 | $500-1,000 | Privacy policy, GDPR, terms, annual legal review |
| Content moderation | $0 (automated) | $500-2,000 | Automated filters at launch; Hive/Two Hat at scale |
| Founder salary | $0 (bootstrapping) | $3,000-6,000 | Even at $40-80K/yr, this reframes "profit" |
| **Total new costs** | **$750-2,400** | **$9,500-26,000** | |

### Revised Profit Scenarios (with all adjustments)

#### Scenario 1: Soft Launch — 1,000 MAU, 1% conversion (10 subscribers)

| Line Item | Monthly | Annual |
|---|---|---|
| Net subscription revenue (10 × $7.59 blended) | $76 | $911 |
| **Infrastructure** | **$54** | **$648** |
| CAC (content/SEO basics) | $500 | $6,000 |
| Support tools | $50 | $600 |
| **Total Costs** | **$604** | **$7,248** |
| **Profit/Loss** | **-$528/mo** | **-$6,337/yr** |

**Reality:** Soft launch loses money. This is expected — you're investing in community before monetization.

#### Scenario 2: Growth — 10,000 MAU, 1.0% conversion (100 subscribers), 50/50 annual mix

| Line Item | Monthly | Annual |
|---|---|---|
| **Revenue** | | |
| Net subscription (100 sub, blended $5.69/mo with 50/50 mix) | $569 | $6,828 |
| Viator bookings (15 bookings × $50 × 0.15% rate) | $90 | $1,080 |
| **Net Revenue** | **$659** | **$7,908** |
| | | |
| **Infrastructure** (from v2) | $691 | $8,292 |
| CAC (content, ASO, basic paid) | $1,000 | $12,000 |
| Support tools (HelpScout) | $100 | $1,200 |
| Legal/compliance | $200 | $2,400 |
| Content moderation (automated) | $0 | $0 |
| Founder salary ($40K/yr) | $3,333 | $40,000 |
| **Total Costs** | **$5,324** | **$63,892** |
| | | |
| **Profit/Loss** | **-$4,665/mo** | **-$55,984/yr** |

**Reality:** At 10K MAU with 1% conversion, you're still investing. Profitable on operating basis ($659 revenue vs $691 infra = near break-even), but not after acquisition and salary costs.

#### Scenario 2 Optimistic: 10,000 MAU, 1.5% conversion (150 subscribers), 50/50 mix

| Line Item | Monthly |
|---|---|
| Net subscription (150 sub × $5.69) | $854 |
| Viator bookings | $90 |
| **Net Revenue** | **$944** |
| **Total Costs** (same as above) | **$5,324** |
| **Profit/Loss** | **-$4,380/mo** |

**Still investing.** But operating margin (revenue minus infrastructure only) is positive at +$253/mo.

#### Scenario 3: Scale — 100,000 MAU, 1.5% conversion, 50/50 mix

| Line Item | Monthly | Annual |
|---|---|---|
| **Revenue** | | |
| Net subscription (1,500 sub × $5.69) | $8,535 | $102,420 |
| Viator bookings (150 bookings × $50 × 12%) | $900 | $10,800 |
| **Net Revenue** | **$9,435** | **$113,220** |
| | | |
| **Infrastructure** | $2,725 | $32,700 |
| CAC (paid acquisition + content team) | $5,000 | $60,000 |
| Support (tool + part-time staff) | $1,000 | $12,000 |
| Legal/compliance | $500 | $6,000 |
| Content moderation | $1,000 | $12,000 |
| Founder salary ($60K/yr) | $5,000 | $60,000 |
| **Total Costs** | **$15,225** | **$182,700** |
| | | |
| **Profit/Loss** | **-$5,790/mo** | **-$69,480/yr** |

**Reality check:** At 100K MAU with these costs, you need ~2.5% conversion (2,500 subscribers) or significant Viator/booking revenue to be profitable after all costs including salary and acquisition.

#### Scenario 3 Venture-Scale: 100,000 MAU, 2.5% conversion, full transactional layer

| Line Item | Monthly | Annual |
|---|---|---|
| **Revenue** | | |
| Net subscription (2,500 sub × $5.69) | $14,225 | $170,700 |
| Viator + booking commissions (500 × $50 × 12%) | $3,000 | $36,000 |
| Accommodation affiliate (200 × $100 × 10%) | $2,000 | $24,000 |
| Travel insurance commission (100 × $40 × 25%) | $1,000 | $12,000 |
| **Net Revenue** | **$20,225** | **$242,700** |
| | | |
| **Total Costs** (same) | **$15,225** | **$182,700** |
| | | |
| **Profit/Loss** | **+$5,000/mo** | **+$60,000/yr** |

**This is the crossover.** 100K MAU becomes profitable when you add the transactional marketplace layer AND hit 2.5% conversion. This is the milestone that justifies raising a Series A.

---

## Sensitivity Analysis

### Conversion Rate Impact (10K MAU, infrastructure only — no CAC/salary)

| Conversion | Subscribers | Net Revenue/mo | Infra Cost | Operating Profit |
|---|---|---|---|---|
| 0.5% | 50 | $285 | $691 | **-$406 (loss)** |
| 1.0% | 100 | $569 | $691 | **-$122 (loss)** |
| 1.5% | 150 | $854 | $691 | **+$163** |
| 2.0% | 200 | $1,138 | $691 | **+$447** |
| 3.0% | 300 | $1,707 | $691 | **+$1,016** |

### Retention / LTV Sensitivity

| Avg Retention | LTV per subscriber (monthly $9.99) | LTV per subscriber (annual $59.99) |
|---|---|---|
| 6 months | $45 net | N/A (annual locks 12mo) |
| 12 months | $91 net | $51 net |
| 18 months | $136 net | $51 + $51 = $102 net |
| 24 months | $181 net | $51 + $51 = $102 net |

**Key insight:** Annual subscribers are worth more per month but less total than a 24-month monthly subscriber. Pushing annual is about predictability and cash flow, not maximum LTV.

### Web vs Mobile Signup Mix Impact (at 10K MAU, 100 subscribers)

| Web Signup % | Blended Net/sub/mo | Net Revenue/mo | Delta vs 15% web |
|---|---|---|---|
| 15% web (current assumption) | $7.59 | $759 | Baseline |
| 25% web | $7.79 | $779 | +$20/mo |
| 40% web | $8.08 | $808 | +$49/mo |
| 50% web | $8.28 | $828 | +$69/mo |

Shifting from 15% to 40% web signups is worth more than any infrastructure cost optimization.

---

## Venture-Scale Growth Strategy

### Why Most Solo Travel Apps Fail

The graveyard is real: Backpackr, Tourlina, Travello, Party with a Local, SoloTraveller, GAFFL. They all hit the same walls:

1. **Episodic usage** — users care for 3 weeks, then disappear for 6 months
2. **Geographic cold start** — need density in every city, not just overall
3. **Weak paywall moments** — "see who likes you" is urgent; "see who's in Lisbon" is not
4. **Premature monetization** — charging before community exists kills growth

### The 5 Problems You Must Solve for Venture Scale

#### Problem 1: Between-Trips Retention (CRITICAL)

Without year-round engagement, your ceiling is $10-30M ARR (good business, not billion-dollar).

| Solution | How It Works | When to Build |
|---|---|---|
| Local meetups in home city | "Solo Adventurers London" weekly events | Year 1 |
| Travel content/feed | Pinterest-for-travel dreaming/planning | Year 1 |
| Trip planning tools | Year-round planning activity | Sprint 6-7 (partially built) |
| Community/forum layer | Reddit r/solotravel has 2M members — capture that energy | Year 2 |

#### Problem 2: Geographic Liquidity (City-by-City)

You need simultaneous density in every destination — the "cold start" problem at 100x intensity.

**Strategy:** Uber playbook, not Facebook. Pick 10-20 cities, saturate them.

| Wave | Cities | Strategy |
|---|---|---|
| Wave 1 (Month 1-6) | Lisbon, Bali, Bangkok, Medellín, CDMX | Ambassador program + hostel partnerships |
| Wave 2 (Month 7-12) | Tulum, Porto, Tokyo, Istanbul, Barcelona | Seed from Wave 1 users traveling there |
| Wave 3 (Year 2) | 15-20 more major destinations | Paid acquisition + PR |

**Product feature:** "Where will you be?" — users commit to future destinations, you pre-seed meetups before travelers arrive.

#### Problem 3: Transactional Marketplace Layer

Connection alone doesn't monetize well. Connection + transaction does (Airbnb lesson).

| Revenue Stream | Commission | Est. Revenue at 100K MAU |
|---|---|---|
| Viator tours/activities | 8-12% | $3,000/mo |
| Accommodation affiliate (Booking.com, Hostelworld) | 25-40% | $2,000/mo |
| Travel insurance | 20-40% | $1,000/mo |
| Local experiences marketplace | 15-20% | $2,000/mo |
| Flight affiliate | 1-3% | $500/mo |
| **Total transactional revenue** | | **$8,500/mo ($102K/yr)** |

Transaction revenue overtakes subscription revenue at scale. This is the path to $100M+ ARR.

#### Problem 4: Two-Sided Marketplace

One-sided markets (just solo travelers) scale slowly. Two-sided markets scale faster.

| "Other Side" | Value They Bring | Revenue Model |
|---|---|---|
| Verified local hosts/guides | Coffee meetups, walking tours, dinner | 15-20% commission |
| Hostels/accommodations | Reach solo travelers directly | Listing fee or commission |
| Experience providers | Cooking classes, tours, nightlife | Commission |
| Solo-travel brands (luggage, gear) | Advertising/sponsorship | CPM or sponsored content |

#### Problem 5: Viral Loop

Without structural virality, CAC eats your margin. You need at least one engineered loop:

| Loop Type | Mechanism | Expected K-factor |
|---|---|---|
| Group trip invites | Inviter creates accounts for invitees | 1.2-1.5 |
| Social shareable content | "My Solo Adventurer Year" wrap (Spotify Wrapped style) | 1.1-1.3 |
| City hub invites | "Sarah is in Lisbon next week, join her hub" | 1.0-1.2 |
| Referral rewards | "Invite 3 friends, get a free local tour" | 1.1-1.4 |
| Meetup photos to Instagram/TikTok | App-branded shareables from meetups | 1.0-1.2 |

### Demographic Wedge Strategy

**Don't launch for "all solo travelers."** Pick one wedge and dominate it for 18-24 months.

| Wedge | TAM | Willingness to Pay | Engagement | Recommended? |
|---|---|---|---|---|
| Solo female travelers (25-45) | 25-40M globally | High ($15-20/mo for safety) | High (safety is emotional driver) | **Primary wedge** |
| Digital nomads | 10-15M | Medium ($10-15/mo) | Very high (daily usage) | Secondary, Year 2 |
| Young backpackers (18-25) | 30-50M | Low ($5-10/mo) | Very high | Tertiary, Year 3 |

**Why solo female travelers first:**
- 50-60% of the solo travel market
- Highest safety concern = highest willingness to pay for verification
- Most underserved by existing platforms
- Strongest word-of-mouth in travel communities
- Best CAC efficiency (safety messaging is highly targeted)

### Venture-Scale Financial Roadmap

#### Year 1: Wedge + City Saturation

| Metric | Target |
|---|---|
| MAU | 50-100K (concentrated in 5-10 cities) |
| Paying subscribers | 500-1,500 (1-1.5% conversion) |
| Net revenue | $500K-1M ARR |
| Monthly burn | -$3,000 to -$8,000 (investing in growth) |
| Team | 2-3 people (founder + 1-2 hires/contractors) |
| Funding | Bootstrap or pre-seed ($100-500K) |

#### Year 2: Expansion + Marketplace

| Metric | Target |
|---|---|
| MAU | 300-500K (15-20 cities) |
| Paying subscribers | 3,000-7,500 |
| Net revenue | $3-5M ARR |
| Transactional revenue | $500K-1M ARR (emerging) |
| Monthly profit | Approaching break-even |
| Team | 10-15 people |
| Funding | **Series A: $5-10M** |

#### Year 3: Geographic Expansion + Scale

| Metric | Target |
|---|---|
| MAU | 2-3M (most major destinations) |
| Paying subscribers | 20,000-45,000 |
| Net revenue | $15-30M ARR |
| Transactional revenue | $5-10M ARR (growing fast) |
| Monthly profit | $200K-500K/mo |
| Team | 30-50 people |
| Funding | **Series B: $15-25M** |

#### Year 4-5: Default Solo Travel Platform

| Metric | Target |
|---|---|
| MAU | 10-20M globally |
| Total revenue | $100-300M ARR |
| Transactional revenue | Overtakes subscription revenue |
| Profit margin | 60-70% |
| Outcome | Acquisition target (Expedia, Airbnb, Booking.com) or IPO path |

---

## Strategic Levers (Highest Impact First)

### 1. Push Web Signup as Default Path (+35% revenue per user)

| Action | Impact |
|---|---|
| Invest in SEO and travel content marketing | Low-CAC web acquisition |
| Make web → mobile onboarding seamless | Mobile = retention surface, web = conversion surface |
| Blog posts about solo travel destinations | Organic traffic to web |
| Target: 40% web signups by Year 2 | +$49/mo per 100 subscribers over 15% web baseline |

### 2. Gate Verification Behind 3 Months or Annual Plan

At $3.50/check and $6.92 net revenue for iOS Year 1, verification in Month 1 eats 50% of first-month revenue. If the user churns in Month 2, you lost money.

| Approach | Impact |
|---|---|
| Verification earned at Month 3 of continuous subscription | Protects against churn-loss |
| Verification included free with annual plan | Drives annual commitment |
| Verification available immediately for $4.99 add-on | Captures urgency |

### 3. Cache Google Places Relentlessly (-70-90% cost)

Google Places is the #1 variable cost. Most searches are repetitive (travelers search the same hotspots).

| Strategy | Savings |
|---|---|
| Supabase table with TTL for cached place results | -$300-500/mo at 10K MAU |
| Autocomplete ($5/1K) instead of Text Search ($32/1K) | -$200-400/mo |
| Client-side caching with Drift (already built) | -$100-200/mo |

### 4. Build the Between-Trips Product (retention multiplier)

The single highest-ROI product investment. If you can extend average usage from 3 weeks/trip to year-round, your LTV triples.

| Feature | Engagement Impact | Build Cost |
|---|---|---|
| Local meetups in home city | Weekly engagement | 2-3 weeks |
| Travel content feed | Daily engagement | 3-4 weeks |
| Trip planning tools (partially built) | Weekly engagement | 1-2 weeks |
| "Travel Year in Review" shareable | Annual viral moment | 1 week |

### 5. Use GPT-4o-mini Exclusively for AI

$150/mo vs $3,000/mo at scale for indistinguishable quality in travel use cases. Any argument for GPT-4 needs side-by-side A/B test data.

---

## Revised 5-Year Financial Projection

### Conservative (1.0% conversion, bootstrap, organic growth)

| Year | MAU | Sub Revenue | Transaction Rev | Total Costs | **Net Profit** |
|---|---|---|---|---|---|
| 1 | 1-15K | $9K | $1K | $55K | **-$45K** |
| 2 | 15-50K | $80K | $15K | $130K | **-$35K** |
| 3 | 50-100K | $250K | $50K | $200K | **+$100K** |
| 4 | 100-200K | $500K | $150K | $300K | **+$350K** |
| 5 | 200-300K | $700K | $300K | $400K | **+$600K** |

Break-even: Year 3. Profitable every year after. Cumulative 5-year profit: ~$970K.
**This is the bootstrap path. Excellent lifestyle business.**

### Venture-Scale (1.5-2.5% conversion, funded, transactional layer)

| Year | MAU | Sub Revenue | Transaction Rev | Total Costs | **Net Profit** |
|---|---|---|---|---|---|
| 1 | 50-100K | $500K | $50K | $800K | **-$250K** |
| 2 | 300-500K | $3M | $1M | $3.5M | **+$500K** |
| 3 | 2-3M | $15M | $8M | $15M | **+$8M** |
| 4 | 5-10M | $50M | $30M | $40M | **+$40M** |
| 5 | 10-20M | $100M | $80M | $65M | **+$115M** |

Requires: Series A ($5-10M), Series B ($15-25M), team of 50+ by Year 3.
**This is the venture path. Requires funding and aggressive execution.**

---

## The Honest Summary

### Bootstrap Ceiling

Without outside capital, geographic concentration strategy, or a between-trips retention engine:
- **Ceiling:** $5-30M ARR
- **Timeline to profitability:** Year 2-3
- **5-year cumulative profit:** $500K-2M
- **Outcome:** Excellent lifestyle business, potential acquisition by travel company

### Venture Ceiling

With funding, city-by-city saturation, transactional marketplace, and a between-trips product:
- **Ceiling:** $100-300M ARR
- **Timeline to profitability:** Year 2-3 (operating), Year 3-4 (after funding costs)
- **5-year cumulative profit:** $50-150M
- **Outcome:** Acquisition target for Expedia/Airbnb/Booking.com, or independent IPO

### The Choice

| Path | Risk | Reward | Time Commitment | Funding Needed |
|---|---|---|---|---|
| Bootstrap | Low | $500K-3M ARR | 1 person, sustainable pace | $0-50K |
| Venture | High | $50M+ ARR | Full team, 60-80hr weeks | $20-40M over 5 years |

**Both paths share the same foundation:** smart cost structure, healthy unit economics, verification-based trust moat, safety-led positioning. The bootstrap decisions being made now are the right foundation regardless of which path you choose.

**The fork in the road** comes when you hit ~50K MAU and need to decide: stay lean and profitable, or raise money and sprint for venture scale. The data at that point will make the decision clearer.

---

## Home-Mode Strategy — The Retention Engine

### The Core Insight

Solo travel is episodic: users care intensely for 2-4 weeks, then disappear for 6-12 months. This kills retention, LTV, and conversion. But the **same users** have a year-round need: "I want to do things with like-minded people in my own city."

| Mode | Engagement Windows/Year | Conversion Opportunities | LTV Multiplier |
|---|---|---|---|
| Travel only | 3-6 (per trip) | 3-6 | 1x |
| Travel + Home | 52 (weekly) | 52 | **10-17x** |

Same user. Same app. 17x the engagement surface. This is the single highest-ROI strategic insight in the entire business model.

### Product Framing

**Current framing:** "Social platform for solo travelers" — limits TAM, creates episodic usage
**Reframed:** "Safety-first social platform for people who want to do more with company — home or away"

| Use Case | TAM | Frequency | Example |
|---|---|---|---|
| Solo travelers meeting at destinations | 50-80M globally | Episodic | "Who's in Bali in March?" |
| New-to-city meetups | 200M+ (anyone who's relocated) | Weekly | "Moved to Lisbon, who wants to explore?" |
| Interest-based local meetups | 500M+ | Weekly | "My friends don't hike, who does?" |
| Digital nomad community | 10-15M | Daily | "Working from a cafe, anyone nearby?" |
| Introvert-friendly social | 1B+ | Weekly | "Structured social events, no pressure" |

The product architecture (identity, trust, verification, discovery, matching, messaging) generalizes across all of them.

### Dual-Mode Product Design

```
┌─────────────────────────────────────────────────────────────┐
│                    SoloAdventurer                            │
├────────────────────────┬────────────────────────────────────┤
│     HOME MODE          │         TRAVEL MODE                │
│  (default when home)   │   (activated by trip/destination)  │
│                        │                                    │
│  • Local meetups       │  • Destination matching            │
│  • Weekly events       │  • Trip overlap scoring            │
│  • Interest groups     │  • Activity-based discovery        │
│  • Recurring gatherings│  • Itinerary sharing               │
│  • City-based discovery│  • Local experiences/tours         │
├────────────────────────┴────────────────────────────────────┤
│  Shared: Identity • Verification • Trust • Messaging • Safety│
└─────────────────────────────────────────────────────────────┘
```

User seamlessly moves between modes: 10 months in home mode, 2 months in travel mode, always the same app.

### How Home Mode Changes the Financial Model

| Metric | Travel Only | Travel + Home Mode | Delta |
|---|---|---|---|
| Conversion rate | 1.0-1.5% | 3-5% | 3x |
| Avg retention | 6-12 months | 18-24 months | 2-3x |
| LTV per subscriber | $56 | $150-200 | 3x |
| Weekly engagement | 0.5x | 1x | 2x |
| Viral loop K-factor | 1.0-1.2 | 1.3-1.5 | +30% |
| Onfido amortization | 2-6 months | 18-24 months | Better |
| Network effect speed | Slow (geographic) | Fast (city-level) | Much faster |

**Revised profit with home mode (10K MAU, 3% conversion):**

| Line Item | Monthly |
|---|---|
| Net subscription (300 sub × $5.69) | $1,707 |
| Viator + local experiences | $180 |
| **Net Revenue** | **$1,887** |
| **Infrastructure** | $691 |
| CAC (more organic with viral loops) | $800 |
| Support + legal + moderation | $350 |
| Founder salary | $3,333 |
| **Total Costs** | **$5,174** |
| **Profit/Loss** | **-$3,287/mo** |

Still investing at 10K MAU, but operating margin (revenue vs infra) is **+63%** — very healthy. Profitability arrives at ~25K MAU with home mode vs ~75K MAU without.

### Architectural Assessment — Current State

Two specific concerns raised by the strategy review. Both confirmed as issues:

#### Concern 1: Trip model is hardcoded to travel-only

**Current state:** `Trip` entity has `destination` as a **required** field:
```dart
required String destination,  // Line 15, trip.dart
```

There is no `home_city` field on Profile. No concept of "local meetup" vs "travel trip." A meetup in the user's own city cannot be created as a Trip — it requires a separate destination.

**Fix needed:** Add `isLocalMeetup` flag to Trip (or create a unified `Gathering` entity that encompasses both). Allow `destination` to equal the user's home city. Add `home_city` / `home_latitude` / `home_longitude` to Profile.

**Effort:** 1-2 days for the model change. Affects: Trip entity, TripModel, matching queries, Edge Functions.

#### Concern 2: Matching algorithm gracefully handles no-destination

**Current state:** The semantic matching Edge Function handles missing destinations:
```typescript
function computeDestinationScore(a: string | null, b: string | null): number {
  if (!a || !b) return 0.2  // Default score, not zero
```

With 10% weight, no-destination = 0.02 contribution. This means matching works for home mode but the other signals (date overlap at 25%) also default to low values when there's no trip. Home-mode matching becomes: semantic (40%) + activities (15%) + age (10%) + small defaults = **mostly semantic + activities only**.

**Fix needed:** When no trip is active, match on home city proximity instead of destination overlap. Increase activity/interest weight for home-mode matching. This is a scoring adjustment, not a rewrite.

**Effort:** 1 day for the algorithm change.

### Recommended Architecture Changes (Sprint 6.6 or 6.7)

| Change | What | Effort | Impact |
|---|---|---|---|
| Add `home_city` to Profile | New field with lat/lng | 1 day | Enables city-based discovery |
| Add `isLocalMeetup` flag to Trip | Boolean, relaxes destination requirement | 0.5 day | Unifies trips and meetups |
| Add home-mode matching path | When no trip, match on city + interests | 1 day | Better local matching |
| Add `Gathering` entity (future) | Unified concept for trips + meetups + events | 3-5 days | Clean architecture for scale |

**Do the first three now** (2.5 days total). They unblock home mode without requiring a full refactor. The `Gathering` entity can wait until you're ready to build the full home-mode product.

### Launch Strategy for Home Mode

1. **Launch travel-first** (current plan through Sprint 8). Travel is your wedge — it's well-defined, has a clear audience, and validates the core trust/verification/matching stack.

2. **Include basic home-mode from day one.** When a user has no active trip, show "Adventures near you" based on their home city. Let users create local meetups with the same Trip model (using the `isLocalMeetup` flag). Don't market it heavily — let engaged users discover it organically.

3. **Monitor organic usage.** If users who join for travel start using home meetups, you have validation. Expand aggressively.

4. **Seed meetups in launch cities.** Ambassador program creates recurring weekly events (hiking, coffee, dinners). These seed the network effect for home mode.

5. **Reposition at Series A.** Once home mode proves out, the brand evolves: "SoloAdventurer — your solo adventures, from your home town to halfway around the world."

### Home-Mode Revenue Impact on 5-Year Projection

| Year | MAU | Subscribers | Home Mode? | Net Revenue | Net Profit |
|---|---|---|---|---|---|
| 1 | 50K | 750 | Basic (10% usage) | $500K | -$250K |
| 2 | 300K | 6,000 | Growing (30% usage) | $5M | +$500K |
| 3 | 2M | 50,000 | Core product (50% usage) | $40M | +$10M |
| 4 | 8M | 200,000 | Equal to travel | $150M | +$50M |
| 5 | 15M | 450,000 | Primary use case | $300M | +$120M |

**Home mode is the difference between a $30M ARR ceiling and a $300M ARR ceiling.**

### Brand Consideration

"SoloAdventurer" works for both modes — "adventures" can be local or international. A few positioning options:

| Option | Pros | Cons |
|---|---|---|
| Keep "SoloAdventurer" | No rebrand cost, "adventure" is flexible | May feel travel-focused to new users |
| Reframe tagline only | "Your adventures, from home to halfway around the world" | Low cost, tests the message |
| Rebrand at Series A | More accurate for dual-mode product | Expensive, distracting too early |

**Recommendation:** Keep the name. Update the tagline. Rebrand only if home mode becomes the primary use case (Year 2-3 signal).

---

## Full 5-Phase Growth Roadmap

The complete pre-launch through Year 5 roadmap — including phased product work, growth strategy, team/capital milestones, success metrics, 6 foundational decisions, and things to avoid — is documented in:

**[GROWTH_ROADMAP.md](GROWTH_ROADMAP.md)**

Key highlights:
- **Phase 0 (Pre-launch, 6-10 weeks):** Fix 404s, finalize Discover/Profile, build payment architecture, integrate real Onfido, ship analytics + legal
- **Phase 1 (Months 0-6):** Invite-only launch in 3 cities, iterate on connection flow, ship basic home-mode, activate sequenced paywall
- **Phase 2 (Months 6-18):** Expand to 15-20 cities, elevate home mode, build reviews/reputation layer, start transactional marketplace
- **Phase 3 (Months 18-36):** Full transactional marketplace, verified local hosts, AI concierge, B2B, demographic expansion
- **Phase 4 (Months 36-60):** Global dominance, adjacent acquisitions, reputation layer API, ambient AI, $100-300M ARR
