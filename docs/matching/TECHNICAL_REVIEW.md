# Technical Review: SoloAdventurer Matching Feature

**Reviewer:** CTO / Architecture Lead  
**Date:** 2026-04-01  
**Spec Version:** 1.0  
**Review Type:** Feasibility & Architecture Sign-off

---

## Executive Summary

**Approval Status:** ⚠️ **APPROVED WITH CONDITIONS**

The spec is technically sound and buildable with the proposed stack (Supabase + Flutter). However, there are **critical security considerations** around the Women-Only Mode that require additional architectural decisions before development can proceed safely.

**Recommendation:** Proceed to development AFTER addressing the 3 mandatory conditions below.

---

## 1. Feasibility Assessment

### ✅ Buildable with Current Stack

| Component | Technology | Feasibility | Notes |
|-----------|-----------|-------------|-------|
| Spatial matching | PostGIS | ✅ Proven | Well-documented, performant |
| Real-time messaging | Supabase Realtime | ✅ Proven | Scales to thousands of concurrent connections |
| Offline-first | Flutter + local DB | ✅ Proven | Requires careful architecture (see below) |
| Trip management | PostgreSQL + RLS | ✅ Straightforward | Standard CRUD with spatial queries |
| Activity suggestions | Static + location-based | ✅ Simple | Can be DB-driven or hardcoded MVP |
| Women-only mode | RLS + server validation | ⚠️ **Complex** | Security-critical, needs defense in depth |

### ⚠️ Technical Constraints & Considerations

1. **Supabase Realtime Limits**
   - Free tier: 200 concurrent connections
   - Pro tier: Unlimited (fair use)
   - **Recommendation:** Start on Pro tier ($25/mo) to avoid limits during launch

2. **PostGIS Performance**
   - Spatial indexes essential for <2s match queries
   - Must use GiST indexes on geometry columns
   - Radius queries need `ST_DWithin` with spatial index

3. **Offline Sync Complexity**
   - Flutter requires local database (recommend: Drift/Moor or sqflite)
   - Conflict resolution strategy needed
   - Queue-based message sending required

### 🚫 No Technical Blockers Found

The spec is within the capabilities of the chosen stack. No features require technologies we don't have access to.

---

## 2. Architecture Recommendations

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUTTER APP                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   UI Layer   │  │ State Mgmt   │  │  Local DB    │      │
│  │  (Screens)   │──│ (Riverpod/)  │──│  (Drift)     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │             │
│         └──────────────────┴──────────────────┘             │
│                           │                                  │
│                 ┌─────────▼─────────┐                       │
│                 │   Sync Service    │                       │
│                 │  (Offline Queue)  │                       │
│                 └─────────┬─────────┘                       │
└───────────────────────────┼─────────────────────────────────┘
                            │
                    HTTPS / WebSocket
                            │
┌───────────────────────────┼─────────────────────────────────┐
│                    SUPABASE                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Auth       │  │  Realtime    │  │   Storage    │      │
│  │   (GoTrue)   │  │  (WebSocket) │  │   (S3-like)  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │             │
│         └──────────────────┴──────────────────┘             │
│                           │                                  │
│  ┌──────────────┐  ┌──────▼───────┐  ┌──────────────┐      │
│  │   Edge       │  │  PostgreSQL  │  │   PostGIS    │      │
│  │   Functions  │  │  + RLS       │  │   (Spatial)  │      │
│  │   (Deno)     │  │              │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow Architecture

#### 1. Trip Creation Flow
```
User Input (City Name)
    ↓
Client: Geocode locally OR send city name to server
    ↓
Server: Validate + geocode (if not client-side)
    ↓
Database: Insert trip with coordinates
    ↓
Trigger: Calculate new matches via DB function
    ↓
Realtime: Notify affected users of new match
```

**Recommendation:** Server-side geocoding preferred for security (prevents location spoofing).

#### 2. Matching Query Flow
```
User opens Matches screen
    ↓
Client: Query local cache first
    ↓
If stale (>5 min): Fetch from server
    ↓
Server: 
    SELECT potential_matches()
    WHERE spatial_overlap AND temporal_overlap
    AND women_only_filter_applied
    ↓
Client: Update cache + UI
```

**Recommendation:** On-demand fetching with 5-minute cache. Don't use Realtime for match updates (too chatty).

#### 3. Messaging Flow
```
User sends message
    ↓
Client: 
    - Generate UUID
    - Save to local DB with status='pending'
    - Add to offline queue
    - Update UI optimistically
    ↓
If online:
    - Send via Realtime channel
    - Server validates match exists
    - Server persists to messages table
    - Server broadcasts to recipient
    - Client updates status='sent'
If offline:
    - Keep in queue with status='pending'
    - Retry when connection restored
```

#### 4. Women-Only Mode Flow
```
User enables women-only mode
    ↓
Client: Update user.women_only_mode_enabled = true
    ↓
Server (RLS Policy):
    - On SELECT: Only show users where gender='female'
    - On SELECT: Only show to users where gender='female'
    - VALIDATE: User.gender must be 'female' to enable
    ↓
Database: Update user record
    ↓
Realtime: Refresh match list with new filters
```

**CRITICAL:** RLS policies MUST enforce this server-side. Client-side checks are insufficient.

---

## 3. Risk Assessment

### 🔴 CRITICAL RISKS

#### Risk 1: Women-Only Mode Bypass
**Description:** Malicious users could change their gender to "female" to access women-only matching, putting women at risk.

**Likelihood:** HIGH  
**Impact:** CRITICAL (safety incident, legal liability, brand destruction)

**Mitigations:**
1. ✅ **Mandatory:** RLS policies enforced at database level (cannot be bypassed by client)
2. ✅ **Mandatory:** Gender field immutable after account creation OR requires 7-day cooldown + support review
3. ✅ **Mandatory:** Server-side validation in Edge Functions for all match queries
4. 🟡 Recommended: Audit logging for all gender changes
5. 🟡 Recommended: Rate limit match queries (prevent scraping)
6. 🔵 Future: Photo verification or ID verification for women-only mode

**Decision Needed:** Which combination of mitigations will we implement for MVP?

#### Risk 2: Location Spoofing
**Description:** Users could fake GPS coordinates to appear in locations they're not, potentially to access women-only spaces or mislead matches.

**Likelihood:** MEDIUM  
**Impact:** HIGH (trust erosion, safety risk)

**Mitigations:**
1. ✅ **Recommended:** Don't accept raw coordinates from client; accept city name and server geocodes
2. ✅ **Recommended:** Rate limit trip creation (e.g., max 5 trips per day)
3. 🟡 Optional: Anomaly detection for impossible travel patterns (e.g., Paris → Sydney in 1 hour)
4. 🔵 Future: IP geolocation cross-check (weak but adds friction)

**Decision Needed:** Do we server-side geocode or trust client coordinates?

### 🟡 HIGH RISKS

#### Risk 3: Low User Density (Business/Technical)
**Description:** Not enough users in the same location at the same time, making the app feel empty.

**Likelihood:** HIGH (especially at launch)  
**Impact:** HIGH (users churn, app fails)

**Mitigations:**
1. ✅ Launch strategy: Focus on 1-2 high-traffic destinations first (e.g., Bangkok, Lisbon)
2. ✅ Wider default matching radius (50km instead of same-city)
3. ✅ "Upcoming trips" feature: Show matches for future trips, not just current
4. ✅ Set expectations in onboarding: "X travelers will be in Paris during your trip"

**Not a technical blocker, but critical for success.**

#### Risk 4: Real-time Performance at Scale
**Description:** With thousands of concurrent users, Realtime connections could become slow or drop.

**Likelihood:** LOW (at MVP scale)  
**Impact:** MEDIUM

**Mitigations:**
1. ✅ Use presence for online status (throttled to 30s updates)
2. ✅ Use broadcast for messages (not postgres changes)
3. ✅ Connection pooling via Supabase
4. 🔵 Monitor: Set up alerts for Realtime latency

**Acceptable for MVP.**

### 🟢 MEDIUM RISKS

#### Risk 5: Offline Sync Conflicts
**Description:** Messages sent offline could conflict with server state when syncing.

**Likelihood:** MEDIUM  
**Impact:** LOW (user experience issue, not data loss)

**Mitigations:**
1. ✅ Client-generated UUIDs for messages (no ID conflicts)
2. ✅ Last-write-wins with server timestamps
3. ✅ Clear UI indicators for sync status (pending, sent, delivered, failed)
4. 🟡 Retry logic with exponential backoff

**Manageable with proper architecture.**

#### Risk 6: Spam/Harassment
**Description:** Users send unwanted messages or create fake accounts.

**Likelihood:** MEDIUM  
**Impact:** MEDIUM

**Mitigations:**
1. ✅ Rate limiting: Max 50 messages/day to unique users
2. ✅ Easy blocking mechanism
3. ✅ Report functionality
4. 🟡 Auto-detection of spam patterns (repeated messages)
5. 🔵 Future: Phone verification

**Acceptable for MVP with basic protections.**

---

## 4. Resource Estimates

### Development Timeline

| Phase | Duration | Dependencies |
|-------|----------|--------------|
| **Phase 1: Database & Auth** | 1.5 weeks | Schema finalized, RLS policies designed |
| **Phase 2: Backend APIs** | 2 weeks | Phase 1 complete |
| **Phase 3: Matching Algorithm** | 1.5 weeks | Phase 1 complete, spatial indexes working |
| **Phase 4: Real-time Messaging** | 1.5 weeks | Phase 2 complete |
| **Phase 5: Flutter UI - Core** | 3 weeks | Phase 2-3 complete |
| **Phase 6: Women-Only Mode** | 1 week | Phase 1 complete (RLS critical) |
| **Phase 7: Offline Sync** | 2 weeks | Phase 4-5 complete |
| **Phase 8: Testing & Polish** | 2 weeks | All phases complete |
| **TOTAL** | **14.5 weeks** | |

**PM's estimate:** 8-12 weeks  
**My estimate:** 12-15 weeks (more realistic given offline-first complexity)

**Recommendation:** Budget for 14 weeks, target 12.

### Infrastructure Costs (Monthly)

| Service | Tier | Cost | Notes |
|---------|------|------|-------|
| Supabase | Pro | $25/mo | Required for Realtime scale |
| PostGIS | Included | $0 | Part of Supabase |
| Edge Functions | Pay-per-use | ~$5-20/mo | Depends on usage |
| Push Notifications (FCM/APNs) | Free tier | $0 | Firebase / Apple Developer |
| Geocoding API | Mapbox/Nominatim | $0-50/mo | Free tier may suffice |
| **TOTAL** | | **$30-100/mo** | Scales with users |

**Acceptable for MVP.**

### Team Requirements

| Role | Commitment | Critical Skills |
|------|-----------|-----------------|
| Backend Engineer | Full-time (14 weeks) | Supabase, PostgreSQL, PostGIS, RLS policies |
| Flutter Engineer | Full-time (14 weeks) | Flutter, state management, **offline-first architecture**, local databases |
| QA Engineer | Part-time (4 weeks) | Manual testing, edge cases |
| Product Designer | Part-time (6 weeks) | UI/UX for mobile |

**Key hiring risk:** Flutter engineer with offline-first experience is critical. Many Flutter devs haven't built robust offline sync systems.

---

## 5. Open Technical Questions

### Decision Required BEFORE Development

#### Q1: Gender Verification for Women-Only Mode (CRITICAL)
**Options:**
- A) Trust user input + audit logs + 7-day cooldown for changes
- B) Photo verification (upload photo, manual review or AI check)
- C) ID verification (upload ID, show only gender)
- D) Social proof (existing verified user vouches)

**Recommendation:** Option A for MVP (fastest), with clear plan to add B or C if abuse occurs.

**Decision needed by:** CEO + Legal

---

#### Q2: Location Trust Model (HIGH)
**Options:**
- A) Client sends GPS coordinates (trust client)
- B) Client sends city name, server geocodes (more secure)
- C) Hybrid: Client geocodes, server validates with IP geolocation

**Recommendation:** Option B for MVP. Prevents GPS spoofing and gives us consistent coordinate format.

**Decision needed by:** CTO (I can decide, but want PM input)

---

#### Q3: Match Update Strategy (MEDIUM)
**Options:**
- A) Real-time push: New matches appear instantly via Realtime
- B) Polling: Client refreshes every 5 minutes
- C) On-demand: User pulls-to-refresh

**Recommendation:** Option C (on-demand) for MVP. Real-time match updates add complexity and churn. Users don't need instant notification of new matches.

**Decision needed by:** PM + CTO

---

#### Q4: Message Retention Policy (LOW)
**Options:**
- A) Indefinite retention
- B) 90-day retention, then auto-delete
- C) User-configurable

**Recommendation:** Option A for MVP. Add retention later if storage becomes issue.

**Decision needed by:** PM (product decision)

---

#### Q5: Gender/Identity Options (MEDIUM)
**Question:** Should non-binary users be allowed in women-only mode?

**Options:**
- A) Women-only = gender='female' only (exclusive)
- B) Women-only = gender='female' OR gender='non-binary' (inclusive)
- C) User-configurable: Non-binary users choose whether to see/be seen in women-only

**Recommendation:** Option B or C, aligned with inclusivity goals. Requires community guidelines input.

**Decision needed by:** CEO + PM + Legal

---

## 6. Conditions for Approval

### ⚠️ APPROVED WITH THE FOLLOWING CONDITIONS:

#### Condition 1: Women-Only Mode Security Plan (MANDATORY)
**Before development starts, we must have:**
- [ ] RLS policy design reviewed and approved by security-knowledgeable engineer
- [ ] Decision on gender immutability vs. cooldown period
- [ ] Audit logging implementation plan
- [ ] Clear escalation path if safety incident occurs

**Rationale:** This is a safety-critical feature. We cannot launch without robust server-side enforcement.

---

#### Condition 2: Offline-First Architecture Spike (MANDATORY)
**Before Flutter development starts, we must:**
- [ ] Build a small proof-of-concept for offline message queue
- [ ] Test conflict resolution scenarios
- [ ] Choose local database technology (Drift vs. sqflite vs. Hive)
- [ ] Document sync strategy

**Rationale:** Offline-first is complex and often underestimated. A 2-3 day spike will de-risk the implementation.

**Owner:** Flutter Engineer  
**Timeline:** Week 1

---

#### Condition 3: Matching Algorithm Benchmarks (RECOMMENDED)
**Before finalizing schema:**
- [ ] Test spatial query performance with 10K+ trips
- [ ] Verify <2s query time with proper indexes
- [ ] Test RLS policy performance impact

**Rationale:** PostGIS is fast, but RLS can add overhead. Better to know now.

**Owner:** Backend Engineer  
**Timeline:** Week 1

---

## 7. Approval Summary

| Aspect | Status | Notes |
|--------|--------|-------|
| **Technical Feasibility** | ✅ Approved | No blockers, proven stack |
| **Architecture Approach** | ✅ Approved | Sound design, scalable |
| **Timeline Estimate** | ⚠️ Revised | 12-15 weeks (vs. 8-12 in spec) |
| **Resource Allocation** | ✅ Approved | Team structure adequate |
| **Risk Mitigation** | ⚠️ Conditions | Women-only mode needs security plan |
| **Database Schema** | ✅ Approved | See DATABASE_SCHEMA.md |

---

## 8. Ready-to-Proceed Recommendation

### ✅ READY TO PROCEED AFTER CONDITIONS MET

**Next Steps:**
1. CEO/Product review this technical review
2. Make decisions on Q1-Q5 (Open Technical Questions)
3. Backend engineer creates schema + RLS policies (Week 1)
4. Flutter engineer runs offline-first spike (Week 1)
5. Re-approve after spike results
6. Begin Phase 1 development

**Estimated start date:** Within 1 week of condition satisfaction  
**Estimated MVP delivery:** 14 weeks from development start

---

## 9. Appendix: Technology-Specific Notes

### Supabase Configuration

```toml
# Required extensions
extensions = [
  "postgis",
  "pgcrypto"  # for UUID generation
]

# Realtime configuration
[realtime]
enabled = true
# Only broadcast messages table
tables = ["messages"]

# RLS must be enabled on all tables
[rls]
enabled = true
```

### Flutter Dependencies (Recommended)

```yaml
dependencies:
  supabase_flutter: ^1.10.0
  drift: ^2.0.0  # Local database (offline-first)
  sqlite3_flutter_libs: ^0.5.0
  riverpod: ^2.0.0  # State management
  connectivity_plus: ^4.0.0  # Network status
  geolocator: ^10.0.0  # GPS (if we trust client)
  # OR
  geocoding: ^2.0.0  # If server-side geocoding
```

### PostGIS Query Example (Matching)

```sql
-- Find matching travelers
SELECT 
  u.id,
  u.first_name,
  u.age_range,
  u.home_country,
  t.start_date,
  t.end_date,
  ST_Distance(t.location, :user_location) as distance
FROM trips t
JOIN users u ON t.user_id = u.id
WHERE 
  t.user_id != :current_user_id
  AND t.is_active = true
  AND ST_DWithin(t.location, :user_location, 50000)  -- 50km radius
  AND t.start_date <= :user_end_date
  AND t.end_date >= :user_start_date
  AND (
    :women_only_enabled = false
    OR u.gender = 'female'
  )
ORDER BY 
  distance ASC,
  (LEAST(t.end_date, :user_end_date) - GREATEST(t.start_date, :user_start_date)) DESC;
```

---

**Document Status:** ✅ Complete  
**Next Review:** After open questions resolved  
**Approver:** CTO / Architecture Lead
