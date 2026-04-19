# Payment Platform Planning (Sprint 6.6.10)

## Mobile vs Web Payment Split

| Platform | SDK | Commission | Integration Sprint |
|----------|-----|-----------|-------------------|
| **iOS** | StoreKit 2 | 15% (auto-renew) / 30% (first year) | Sprint 7.5 |
| **Android** | Google Play Billing Library | 15% | Sprint 7.5 |
| **Web** | Stripe | 2.9% + $0.30 | Sprint 7.5 |

## Subscription Entitlement Verification

### Option A: RevenueCat (Recommended for launch)
- Single SDK for iOS + Android + Web
- Server-side entitlement verification
- Cross-platform subscription restore
- Analytics dashboard included
- Free tier covers up to 2.5k monthly active users
- Cost: $0 until scale, then usage-based

### Option B: Custom Server-Side Validation
- StoreKit 2 Server API (iOS)
- Google Play Developer API (Android)
- Stripe Webhooks (Web)
- Requires backend endpoint for receipt validation
- More control but higher engineering cost

### Decision: Start with RevenueCat for Sprint 7.5
- Faster integration (days vs weeks)
- Proven cross-platform receipt validation
- Built-in paywall A/B testing
- Can migrate to custom later if cost warrants

## Mock Payment Flow (Current Sprint)
- `SubscriptionLocalDataSource` uses SharedPreferences
- `SubscriptionRepositoryImpl` writes to local + Supabase profile
- No real payment SDK yet — all purchases are simulated
- `platform` field tracks: 'trial', 'mock', 'apple', 'google', 'stripe'

## Implementation Plan (Sprint 7.5)
1. Add `purchases_flutter` (RevenueCat SDK) dependency
2. Configure RevenueCat project with Apple/Google product IDs
3. Replace `SubscriptionLocalDataSource` with RevenueCat calls
4. Add server-side entitlement check via Supabase Edge Function
5. Add Stripe integration for web (if web app exists)
6. Test sandbox purchases on both platforms
7. Verify receipt validation end-to-end

## Product IDs
- `com.soloadventurer.explorer.monthly` — $9.99/mo
- `com.soloadventurer.explorer.annual` — $59.99/yr
- `com.soloadventurer.id_verification.onetime` — $4.99 (one-time add-on)

## Pricing Guardrails
- Annual must be at least 20% cheaper than 12x monthly (Apple requirement)
- Free trial must be clearly labeled with auto-renewal terms
- Cancel anytime — no dark patterns per Sprint 6.6 principles
