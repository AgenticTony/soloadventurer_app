# SoloAdventurer Matching Feature Specification

**Version:** 1.0  
**Status:** Draft  
**Author:** Product Manager  
**Date:** 2026-04-01  
**Scope:** Layer 1 (MVP)

---

## 1. Problem Statement

### The Core Problem

Solo travelers want to meet other solo travelers spontaneously, but existing solutions don't work:

- **Dating apps** create romantic expectations and safety concerns
- **Social networks** require pre-existing connections and don't surface people nearby NOW
- **Travel forums** are asynchronous and require planning ahead
- **Hostel common rooms** only work if you're staying there, and require being in the same place at the same time

### User Pain Points

1. **Loneliness on the road** - "I'm in Paris for 3 days and haven't talked to anyone except waiters"
2. **Missed connections** - "Found out later that someone from my hometown was at the same café yesterday"
3. **Safety concerns** - Women especially worry about meeting strangers from apps with romantic undertones
4. **High friction** - Existing solutions require extensive profiles, swiping, and back-and-forth messaging
5. **Time zone/plan mismatches** - "We connected but our schedules didn't align"

### The Opportunity

Solo travelers are already motivated to meet others. They just need a **low-friction, safe way to discover who's nearby and interested in the same activities RIGHT NOW**.

---

## 2. User Stories

### Primary Personas

**Persona A: Alex (28, female, solo backpacker)**
- 3-week Europe trip
- Wants to meet other women for coffee, museums, walking tours
- Safety is priority #1
- Not looking to plan everything in advance

**Persona B: Marcus (34, male, digital nomad)**
- Working remotely while traveling
- Flexible schedule
- Wants hiking buddies or people to grab dinner with
- Comfortable with spontaneity

**Persona C: Priya (41, female, career-break traveler)**
- 6-month sabbatical trip
- Wants meaningful conversations and shared experiences
- Prefers smaller groups (2-4 people)
- Values quality over quantity of connections

### Core User Stories

**US-1: Enter My Trip**
> As a solo traveler, I want to enter my destination and dates so that the app knows where I'll be and when.

**US-2: Discover Nearby Travelers**
> As a solo traveler, I want to automatically see other solo travelers who overlap with my location and dates so that I can potentially meet up.

**US-3: See Activity Suggestions**
> As a solo traveler, I want to see activity suggestions as icebreakers so I have an easy, low-pressure way to propose meeting up.

**US-4: Enable Women-Only Mode**
> As a female solo traveler, I want to opt into women-only matching so I feel safer about meeting strangers.

**US-5: Initiate Contact**
> As a solo traveler, I want to send a simple message through the app so I can propose meeting without sharing personal contact info.

**US-6: Have a Conversation**
> As a solo traveler, I want to chat in-app to coordinate details so we can plan our meetup.

---

## 3. Feature Breakdown

### Priority Definitions

- **P0 (Critical):** Must have for MVP launch
- **P1 (Important):** Should have if possible
- **P2 (Nice to have):** Can defer to post-MVP

---

### P0 Features (MVP Required)

#### F-001: Trip Entry
**Description:** Users can create a trip with destination and date range.  
**Priority:** P0  
**Story:** US-1

**Requirements:**
- User can enter a city/region as destination
- User can enter start and end dates
- User can have multiple concurrent trips
- Trip must have at least 1 day duration
- Maximum trip duration: 90 days (prevent stale data)

#### F-002: Automatic Traveler Matching
**Description:** System automatically finds travelers with overlapping dates in same location.  
**Priority:** P0  
**Story:** US-2

**Requirements:**
- Match on geographic overlap (same city/region OR within configurable radius)
- Match on date overlap (any shared day between trips)
- Display matched travelers in a list view
- Show basic info: first name, age range, home country, trip dates
- Sort by relevance (e.g., most overlap days, closest distance)

#### F-003: Activity Suggestions (Icebreakers)
**Description:** System suggests activities as conversation starters.  
**Priority:** P0  
**Story:** US-3

**Requirements:**
- Predefined activity categories: coffee, meal, sightseeing, hiking, nightlife, etc.
- User can indicate interest in activities (optional)
- Activity suggestions appear on matched traveler cards
- User can tap activity to start conversation with that context
- Activities are location-appropriate (e.g., "hiking" available in nature areas)

#### F-004: In-App Messaging
**Description:** Users can send and receive messages within the app.  
**Priority:** P0  
**Story:** US-5, US-6

**Requirements:**
- 1:1 messaging between matched travelers
- Real-time message delivery (via Supabase Realtime)
- Message history persists
- Basic message status: sent, delivered (optional: read)
- Can only message travelers you've matched with
- No group messaging in MVP

#### F-005: Women-Only Mode
**Description:** Female users can opt to only match with other women.  
**Priority:** P0  
**Story:** US-4

**Requirements:**
- Toggle in settings or onboarding
- Once enabled, user ONLY appears to other women
- User ONLY sees other women in matches
- Can toggle off at any time
- Clear visual indicator when mode is active

---

### P1 Features (Important but Deferrable)

#### F-006: Location Precision Control
**Description:** Users can control how precisely their location is shown.  
**Priority:** P1

**Requirements:**
- Three levels: city only, neighborhood, exact location (for activity)
- Default: city only
- Exact location only shared when user initiates meetup suggestion

#### F-007: Trip Visibility Control
**Description:** Users can control who sees their trips.  
**Priority:** P1

**Requirements:**
- Options: everyone, women-only (if female), no one (pause matching)
- Default: everyone (or women-only if mode enabled)

#### F-008: Match Preferences
**Description:** Users can set basic preferences for matches.  
**Priority:** P1

**Requirements:**
- Age range preference
- Language preference (optional)
- Activity interests (optional)
- Preferences are soft filters, not hard blocks

---

### P2 Features (Post-MVP)

#### F-009: Profile Enhancement
**Description:** More detailed user profiles.  
**Priority:** P2

**Note:** Defer to avoid high friction on signup. MVP keeps profiles minimal.

#### F-010: Group Formation
**Description:** Allow users to form small groups.  
**Priority:** P2

**Note:** Groups add complexity. Start with 1:1.

#### F-011: Activity Calendar
**Description:** Users can share specific availability windows.  
**Priority:** P2

**Note:** Adds scheduling complexity. Keep MVP simple with date ranges.

---

## 4. Acceptance Criteria

### AC-001: Trip Entry

| ID | Given | When | Then |
|----|-------|------|------|
| 001.1 | User is logged in | User enters "Paris, France" as destination and selects dates April 10-15, 2026 | Trip is created and saved |
| 001.2 | User has existing trip to Paris April 10-15 | User creates new trip to "Berlin, Germany" April 12-18 | Both trips coexist; overlapping dates don't cause error |
| 001.3 | User enters trip with end date before start date | User submits trip | System shows validation error |
| 001.4 | User enters trip with 0 days duration | User submits trip | System shows validation error |
| 001.5 | User enters trip with >90 days duration | User submits trip | System shows validation error or auto-caps at 90 days |

### AC-002: Traveler Matching

| ID | Given | When | Then |
|----|-------|------|------|
| 002.1 | User A has trip to Paris April 10-15; User B has trip to Paris April 12-18 | Both users are active | User A sees User B in matches (and vice versa) |
| 002.2 | User A has trip to Paris April 1-5; User B has trip to Paris April 10-15 | Both users are active | Users do NOT see each other in matches (no date overlap) |
| 002.3 | User A has trip to Paris; User B has trip to Lyon (150km away) | Both users are active | Users see each other IF radius setting allows; otherwise not |
| 002.4 | User A has women-only mode ON; User B is male | User A views matches | User B does NOT appear in User A's matches |
| 002.5 | User A has women-only mode ON; User B is female | User A views matches | User B DOES appear in User A's matches |
| 002.6 | User A is male; User B has women-only mode ON | User A views matches | User B does NOT appear in User A's matches |

### AC-003: Activity Suggestions

| ID | Given | When | Then |
|----|-------|------|------|
| 003.1 | User A views matched traveler User B | User A taps "Coffee" activity suggestion | Chat opens with pre-filled message: "Want to grab coffee?" (or similar) |
| 003.2 | User A has not set activity interests | User A views matched travelers | Default activity suggestions appear (e.g., Coffee, Sightseeing) |
| 003.3 | User A has set interest in "Hiking" and "Food Tours" | User A views matched travelers | Activity suggestions prioritize "Hiking" and "Food Tours" |
| 003.4 | User A is in a location with no hiking options (e.g., Singapore) | User A views activity suggestions | "Hiking" suggestion is not shown |

### AC-004: In-App Messaging

| ID | Given | When | Then |
|----|-------|------|------|
| 004.1 | User A and User B have matched | User A sends message "Hey, want to explore the Louvre?" | User B receives message in real-time |
| 004.2 | User A and User B have NO date overlap | User A attempts to message User B | Message cannot be sent (no match exists) |
| 004.3 | User A and User B have ended their trips (no current overlap) | User A views chat history | Chat history remains visible but no new messages allowed |
| 004.4 | User A sends message to User B | User B is offline | Message is delivered when User B comes online; User A sees "sent" status |
| 004.5 | User A is in chat with User B | User A closes app and reopens | Chat history is preserved and visible |

### AC-005: Women-Only Mode

| ID | Given | When | Then |
|----|-------|------|------|
| 005.1 | User A is female | User A enables women-only mode | User A only sees female travelers in matches |
| 005.2 | User A is female with women-only mode ON | User B (male) views matches | User A does NOT appear in User B's matches |
| 005.3 | User A has women-only mode ON | User A disables women-only mode | User A immediately sees all travelers (male and female) in matches |
| 005.4 | User A has women-only mode ON | User A views settings | Clear visual indicator shows mode is active |

### AC-006: Offline Support

| ID | Given | When | Then |
|----|-------|------|------|
| 006.1 | User A is viewing matched travelers list | User A loses internet connection | Cached list remains visible |
| 006.2 | User A is offline | User A sends message | Message is queued locally and sent when connection restored |
| 006.3 | User A is offline | User A opens app | App loads with cached data; shows offline indicator |
| 006.4 | User A was offline, now online | App syncs | New matches and messages appear; queued messages send |

---

## 5. User Flows

### Flow 1: New User Onboarding + First Trip

```
[Open App]
    ↓
[Sign Up / Log In]
    ↓
[Welcome Screen: "Find fellow solo travelers nearby"]
    ↓
[Optional: Set Women-Only Mode] ← Female users only
    ↓
[Create First Trip]
    ├── Enter Destination (autocomplete search)
    ├── Select Start Date
    └── Select End Date
    ↓
[Save Trip]
    ↓
[View Matches Screen] ← Shows travelers with overlapping trips
    ↓
[User can browse, tap activity, or start chat]
```

### Flow 2: Discovering and Contacting a Match

```
[View Matches Screen]
    ↓
[Scroll through list of matched travelers]
    ↓
[See User B in list]
    ├── Photo/avatar
    ├── First name, age range, home country
    ├── Trip dates overlap
    └── Activity suggestions: [Coffee] [Sightseeing] [Food]
    ↓
[Tap "Coffee" activity]
    ↓
[Chat opens with pre-filled message: "Want to grab coffee?"]
    ↓
[User can edit or send as-is]
    ↓
[Send message]
    ↓
[Message delivered to User B in real-time]
    ↓
[Conversation continues in chat]
```

### Flow 3: Women-Only Mode Activation

```
[Settings Screen]
    ↓
[Toggle: "Women-Only Mode"]
    ↓
[Enable]
    ↓
[Confirmation dialog: "You'll only see and be seen by other women"]
    ↓
[Confirm]
    ↓
[Mode active - visual indicator appears]
    ↓
[Matches list updates to show only female travelers]
```

### Flow 4: Receiving a Message

```
[User B has app in background]
    ↓
[User A sends message]
    ↓
[User B receives push notification: "Alex wants to grab coffee"]
    ↓
[User B taps notification]
    ↓
[Chat opens showing message from User A]
    ↓
[User B can reply, ignore, or close chat]
```

### Flow 5: Ending a Trip

```
[User A's trip dates pass (end date reached)]
    ↓
[System automatically archives trip]
    ↓
[User A's matches from that trip no longer appear in active list]
    ↓
[Existing chat history is preserved]
    ↓
[User A can create new trip for next destination]
```

---

## 6. Out of Scope (Explicitly NOT Building)

### Not in MVP (and why)

| Feature | Reason |
|---------|--------|
| **Swipe-based discovery** | Feels like Tinder; creates dating app expectations |
| **Gamification (badges, points, streaks)** | Travel is seasonal; users won't engage frequently enough |
| **Extensive profiles** | High friction on signup; contradicts low-pressure ethos |
| **Group messaging** | Adds complexity; start with 1:1 for simplicity |
| **Video/voice calls** | Requires significant infrastructure; chat is sufficient |
| **Social media integration** | Privacy concerns; not necessary for core use case |
| **Recommendation algorithm** | MVP can use simple geographic/temporal matching |
| **Review/rating system** | Premature optimization; can add if trust issues emerge |
| **Meetup scheduling tools** | Keep it simple; users can coordinate via chat |
| **Paid/premium tier** | Focus on core value first; monetization later |
| **Local business integration** | Out of scope; we're not a booking/discovery platform |
| **Safety check-ins** | Important but complex; defer to v2 |

### Future Considerations (Not MVP)

- Safety features: location sharing with trusted contacts, check-ins
- Group formation for activities (e.g., "Who wants to do a walking tour?")
- Integration with booking platforms (Viator, GetYourGuide)
- Local event integration
- Verification (social media, phone, ID)

---

## 7. Success Metrics

### Primary Metrics (MVP Success Criteria)

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| **Match-to-Message Rate** | >20% of matches result in at least one message | Analytics: matches created → messages sent |
| **Message Reply Rate** | >40% of first messages receive a reply | Analytics: first message sent → reply received |
| **Reported Meetups** | >10% of conversations result in confirmed meetup (self-reported) | In-app prompt: "Did you meet up?" post-conversation |
| **Women-Only Adoption** | >50% of female users enable women-only mode | Settings data |
| **7-Day Retention** | >30% of users return within 7 days of first match | Cohort analysis |
| **App Store Rating** | ≥4.2 stars (iOS/Android) | App store data |

### Secondary Metrics (Monitoring)

| Metric | Target | Notes |
|--------|--------|-------|
| **Average matches per user** | 5-15 per active trip | Too few = low value; too many = overwhelming |
| **Time to first message** | <24 hours after match created | Indicates engagement |
| **Conversation length** | ≥4 messages per conversation | Indicates meaningful interaction |
| **Trip creation completion rate** | >80% | Friction in onboarding if lower |
| **Unmatch/block rate** | <5% | Higher indicates quality/safety issues |
| **Report rate** | <1% | Higher indicates safety problems |

### Anti-Metrics (What We Don't Want)

| Metric | Warning Sign | Threshold |
|--------|--------------|-----------|
| **Session duration** | Users spending too long without action | >15 min avg without message sent |
| **Churn after first match** | Users leaving after seeing matches | >60% churn within 48h |
| **Spam/harassment reports** | Safety issues | >1% of users reported |
| **Fake account creation** | Trust erosion | >5% flagged accounts |

---

## 8. Technical Constraints (for Dev Team)

### Data Model (High-Level)

**Users**
- id, email, first_name, age_range, home_country, gender, created_at, women_only_mode_enabled

**Trips**
- id, user_id, destination (text + coordinates), start_date, end_date, created_at, is_active

**Matches**
- id, user_a_id, user_b_id, match_reason (geographic overlap), created_at

**Messages**
- id, sender_id, receiver_id, content, sent_at, delivered_at, read_at

**Activities**
- id, name, category, is_location_specific, location_constraint (geojson or null)

### Spatial Queries (PostGIS)

- Match users with overlapping trip date ranges
- Match users within configurable radius (default: same city or 50km)
- Support for city-level and neighborhood-level precision

### Real-Time Requirements

- Supabase Realtime for instant message delivery
- Optimistic UI updates for messages (show as sent immediately, sync in background)
- Offline queue for messages sent without connectivity

### Performance Targets

- Match list loads in <2 seconds
- Message delivery in <1 second (when both online)
- Offline mode: cached data loads instantly

---

## 9. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Low user density** (not enough travelers in same place) | High | High | Start with popular destinations; allow wider radius matching; communicate realistic expectations |
| **Safety incidents** | Medium | Critical | Women-only mode; easy reporting; clear community guidelines; consider verification in v2 |
| **Spam/harassment** | Medium | High | Rate limiting on messages; blocking; auto-detection of suspicious patterns |
| **Ghosting (no replies)** | High | Medium | Activity suggestions lower friction; prompt users with "quick reply" options |
| **Fake accounts** | Medium | Medium | Monitor for suspicious behavior; consider phone verification |
| **Stale data (old trips not removed)** | Medium | Low | Auto-archive trips after end date; daily cleanup job |

---

## 10. Open Questions (for CEO/Stakeholders)

1. **Radius matching default:** Should we default to same-city only, or expand to 50km/100km? Recommendation: start with city-level, add radius as P1.

2. **Age verification:** Should we verify age, or trust user input? Recommendation: trust input for MVP, verify if issues arise.

3. **Gender options:** Should we support non-binary options for women-only mode? Recommendation: yes, allow non-binary users to opt into women-only matching if they identify with women's spaces.

4. **Minimum profile info:** First name only, or first name + last initial? Recommendation: first name only for privacy.

5. **Push notification strategy:** How aggressively should we notify users of new matches? Recommendation: immediate notification for new matches in current destination, digest for future destinations.

6. **First 1000 users:** How will we seed the platform with initial users? (Critical for density)

---

## 11. Timeline (TBD by Engineering)

**Estimated MVP Scope:** 8-12 weeks (pending technical review)

Suggested phases:
1. **Weeks 1-2:** Trip creation, basic matching (no real-time)
2. **Weeks 3-4:** In-app messaging, Supabase Realtime integration
3. **Weeks 5-6:** Women-only mode, activity suggestions
4. **Weeks 7-8:** Offline support, polish, bug fixes
5. **Weeks 9-10:** Internal testing, QA
6. **Weeks 11-12:** Beta launch in 1-2 cities, iterate

---

## 12. Appendix

### Competitor Analysis

| App | Pros | Cons | Our Differentiator |
|-----|------|------|-------------------|
| **Couchsurfing** | Large community, events | Dating vibes, safety issues, declining quality | No hosting requirement; time-based matching |
| **Meetup** | Activity-focused | Requires planning; not traveler-specific | Spontaneous; travel-specific |
| **Tinder/Bumble** | Large user base | Romantic expectations; safety concerns | Explicitly not dating; women-only mode |
| **Travello** | Traveler community | Complex profiles; social network vibes | Low friction; utility-focused |
| **Facebook Groups** | Free, large reach | No location awareness; async | Real-time, location-aware |

### Glossary

- **Match:** Two travelers with overlapping trips in same location
- **Trip:** A destination + date range entered by a user
- **Activity:** A suggested meetup type (coffee, hiking, etc.)
- **Women-only mode:** Privacy setting limiting visibility to female users only

---

**Document Status:** ✅ Ready for stakeholder review  
**Next Step:** Engineering technical review and timeline estimation
