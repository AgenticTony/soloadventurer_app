# Sprint 5: Real Places + Activities (Layered API)
**Duration:** Week 9
**Theme:** Replace all mocked place data with layered real APIs. Enable activity-based matching.
**Depends on:** Sprint 4.5 (can start earlier in parallel if resources allow)
**API Key:** `VIATOR_API_KEY` in `.env` (already configured)
**Viator Docs:** https://docs.viator.com/partner-api/technical/
**Viator Access Level:** Full Access (Transactional API) — in-app booking, no affiliate redirect
**PCI Compliance:** Required (Stripe or equivalent handles PCI DSS on our behalf)

## API Architecture (Layered Approach)

```
Destination: Paris
  → Layer 1: Google Places API — restaurants, cafes, landmarks, POIs
  → Layer 2: Viator Transactional API — bookable tours, experiences, day trips
  → User selects interests from both layers
  → Selections stored in user_activities table (Supabase)
  → Matching algorithm includes activity overlap score
  → Match card shows shared activity as icebreaker
  → Viator activities book in-app (full transactional API)
     → /availability/check → /bookings/cart/hold → /bookings/cart/book
     → Commission built into retail price (invisible to user)
```

## Tasks

### 5.1 Google Places API integration (Layer 1: baseline places)
- [x] Add `GOOGLE_PLACES_API_KEY` to `.env` and `.env.example`
- [x] Update `lib/core/services/places_service_impl.dart` with real HTTP calls
- [x] Implement: Nearby Search, Text Search, Place Details, Place Photos
- [x] Use `dio` package already in pubspec
- [x] Add response caching to stay within free tier (5,000 requests/month)
- [x] Covers: restaurants, cafes, bars, landmarks, parks, general POIs
- [x] **Test:** Real API response parsing test (mock HTTP)
- [x] **Test:** Caching prevents duplicate API calls
- [x] **Test:** Error handling for quota exceeded / API errors

### 5.2 Viator Transactional API integration (Layer 2: tours & experiences)
- [x] Verify Viator Full Access (Transactional API) is approved
- [x] Add `VIATOR_API_KEY` to `.env` and `.env.example`
- [x] Create `lib/core/services/viator_service.dart` (interface)
- [x] Create `lib/core/services/viator_service_impl.dart` (implementation)
- [x] **Product endpoints:**
  - [x] Search activities by destination (`/products/bulk`)
  - [x] Get product details (title, photos, description, pricing)
  - [x] Get reviews/ratings
  - [x] Sync product changes (`/products/modified-since`)
  - [x] Supplier product lookup (`/suppliers/search/product-codes`)
- [x] **Availability endpoints:**
  - [x] Check real-time availability for selected date (`/availability/check`)
  - [x] Bulk availability schedules for calendar view (`/availability/schedules/bulk`)
  - [x] Sync schedule changes (`/availability/schedules/modified-since`)
- [x] **Booking endpoints (in-app transactional flow):**
  - [x] Get booking questions per product (`/products/booking-questions`)
  - [x] Hold availability during checkout (`/bookings/cart/hold`)
  - [x] Complete booking after payment (`/bookings/cart/book`)
  - [x] Check booking status (`/bookings/status`)
- [x] **Booking management:**
  - [x] Cancel booking with reason (`/bookings/{ref}/cancel`)
  - [x] Cancel quote — show refund before confirming (`/bookings/{ref}/cancel-quote`)
  - [x] Cancel reasons list (`/bookings/cancel-reasons`)
  - [x] Sync booking changes (`/bookings/modified-since` + `/acknowledge`)
- [x] Map Viator products to app's activity model
- [ ] Payment processing via Stripe (PCI DSS compliant) — deferred to Sprint 7.5 production infra
- [x] Covers: guided tours, day trips, cooking classes, adventure experiences, skip-the-line tickets
- [x] **Test:** Viator API response parsing test (mock HTTP)
- [x] **Test:** Booking hold → book flow test
- [x] **Test:** Availability check returns correct date slots
- [x] **Test:** Booking cancellation with refund quote
- [x] **Test:** Error handling for API unavailable

### 5.3 Unified destination discovery screen
- [x] Merge Google Places (restaurants/POIs) + Viator (tours/experiences) into unified discovery view
- [x] Tab or section layout: "Eat & Drink" (Google) | "Things to Do" (Viator) | "Sights" (Google)
- [x] Replace all mock data sources with real combined service
- [x] Place cards show: name, photo, rating, price (Viator only), "Book" button (in-app)
- [x] Detail screen shows real photos, hours, reviews, availability calendar, book button
- [x] Booking flow: select date → check availability → fill traveler details → hold → pay → confirm
- [x] **Test:** Discovery screen renders merged data from both APIs
- [x] **Test:** Viator items show price + in-app book button
- [x] **Test:** Google Places items show hours + rating only
- [x] **Test:** Booking flow: date select → availability → traveler form → hold → book

### 5.4 Activity-based matching (user selects interests → matched by overlap)
- [x] When user picks interests from discovery, save to `user_activities` table in Supabase
- [x] Activity model: id, name, category (tour/restaurant/sight), source (google/viator), external_id, destination
- [x] Update matching RPC/Edge Function: include activity overlap in match scoring
- [x] Match card activity chips show shared activities between users (not generic first 3)
- [x] Tapping activity chip opens chat with prefilled message: "Want to do [activity] together?"
- [x] Viator activities include "Book together" button → in-app booking flow
- [x] **Test:** User activity selections persist to Supabase
- [x] **Test:** Match card shows correct shared activities
- [x] **Test:** Chip tap opens chat with correct prefilled message
- [x] **Test:** Matching score increases for users with overlapping activities

### 5.5 Destination screens loading/error/empty states
- [x] Loading: shimmer placeholders for place cards
- [x] Error: "Could not load destinations" with retry button
- [x] Empty: "No results found. Try a different search."
- [x] **Test:** Widget test for each state

### 5.6 Secure API key management
- [x] `GOOGLE_PLACES_API_KEY` loaded via `--dart-define`, not `.env` asset
- [x] `VIATOR_API_KEY` loaded via `--dart-define`, not `.env` asset
- [x] Create `lib/core/config/secure_keys.dart` that reads from `--dart-define` or runtime fetch from Supabase Edge Function
- [x] Remove any hardcoded API key references in place/Viator service implementations
- [x] **Test:** Keys not present in `.env` file or app bundle
- [x] **Test:** App fails gracefully when keys not provided (error message, not crash)

## Definition of Done
- [x] Searching "museums in Tokyo" returns real Google Places results
- [x] "Tours in Paris" returns real Viator bookable experiences
- [x] Destination discovery shows unified view of places + activities
- [x] User activity selections stored and used in matching
- [x] Match cards show genuine shared activity interests
- [x] Viator activities book in-app (hold → pay → confirm)
- [x] Booking management: view status, cancel with refund quote
- [x] All destination screens handle 3 states (loading/error/empty)
- [x] All tests pass: `flutter test`
- [ ] **Manual QA:** Browse destinations, search, pick activities, verify match shows shared interests
- [ ] **Analytics:** Place search events, activity selection events, booking conversions

## Verification
```bash
flutter analyze
flutter test
# Manual: search "restaurants in Barcelona", verify real data
# Manual: search "tours in Paris", verify Viator experiences appear
# Manual: complete in-app booking flow (select date → availability → book)
# Manual: select interests, create match, verify shared activities on match card
```
