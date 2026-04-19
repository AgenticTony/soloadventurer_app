# Week 1 Test Plan - SoloAdventurer Matching Feature

**QA Lead:** qa-lead  
**Sprint:** Week 1 (April 6-10, 2026)  
**Created:** April 1, 2026  
**Status:** Ready for Review

---

## 1. Test Scope Overview

### Week 1 Development Focus
- Database schema implementation with PostGIS
- RLS (Row Level Security) policies
- Basic Supabase Edge Functions
- Matching algorithm (spatial queries)
- Trip management APIs

### Features Under Test
Based on SPEC.md P0 features covered in Week 1:

| Feature ID | Feature Name | Priority | Test Coverage |
|------------|--------------|----------|---------------|
| F-001 | Trip Entry | P0 | ✅ Full coverage |
| F-002 | Automatic Traveler Matching | P0 | ✅ Full coverage |
| F-005 | Women-Only Mode | P0 | 🔒 Security-critical |

### Out of Scope for Week 1
- F-003: Activity Suggestions (Week 7)
- F-004: In-App Messaging (Week 5-6)
- Offline sync testing (Week 12)
- Flutter UI testing (Week 5+)

---

## 2. Backend Test Categories

### 2.1 Matching Algorithm Tests

#### Spatial Query Tests

| Test ID | Test Case | Input | Expected Result | Priority |
|---------|-----------|-------|-----------------|----------|
| MA-001 | Match users in same city | User A: Paris Apr 10-15, User B: Paris Apr 12-18 | Match returned | P0 |
| MA-002 | No match without date overlap | User A: Paris Apr 1-5, User B: Paris Apr 10-15 | No match | P0 |
| MA-003 | Match within 50km radius | User A: Paris, User B: 40km away | Match returned | P0 |
| MA-004 | No match beyond 50km radius | User A: Paris, User B: 100km away | No match | P1 |
| MA-005 | Match with partial date overlap | User A: Apr 10-15, User B: Apr 14-20 | Match returned (1 day overlap) | P0 |
| MA-006 | Single day overlap match | User A: Apr 10-10, User B: Apr 10-15 | Match returned | P1 |
| MA-007 | No match for same user | User with trip to Paris | Self not in matches | P0 |
| MA-008 | Match sorting by distance | Multiple matches in different locations | Sorted by distance ascending | P1 |
| MA-009 | Match sorting by overlap days | Multiple matches same distance | Sorted by overlap days descending | P1 |
| MA-010 | Exclude inactive trips | User B: trip archived (end date passed) | No match | P0 |

#### Performance Tests (100K Trips Benchmark)

| Test ID | Test Case | Metric | Target | Priority |
|---------|-----------|--------|--------|----------|
| MA-P01 | Query time at 100K trips | p50 latency | <1.0s | P0 |
| MA-P02 | Query time at 100K trips | p95 latency | <2.0s | P0 |
| MA-P03 | Query time at 100K trips | p99 latency | <3.0s | P0 |
| MA-P04 | Spatial index hit rate | Index usage | >95% | P0 |
| MA-P05 | RLS policy overhead | Added latency | <200ms | P1 |
| MA-P06 | Concurrent queries (50) | All complete | <3s | P0 |
| MA-P07 | Concurrent queries (100) | All complete | <5s | P1 |

#### Women-Only Mode Tests (CRITICAL SECURITY)

| Test ID | Test Case | Input | Expected Result | Priority |
|---------|-----------|-------|-----------------|----------|
| WO-001 | Female user with women-only ON sees only females | Female user A (women-only ON) | Only female matches returned | P0 |
| WO-002 | Female user with women-only ON not visible to males | Male user B views matches | User A not visible | P0 |
| WO-003 | Male user cannot enable women-only mode | Male user attempts toggle | Toggle disabled/blocked | P0 |
| WO-004 | Women-only toggle OFF shows all genders | Female user disables mode | All matches visible | P0 |
| WO-005 | Women-only mode persists across sessions | Female user enables, logs out | Mode still enabled on login | P0 |

---

### 2.2 RLS Policy Tests

#### Trip Visibility Tests

| Test ID | Test Case | User Role | Action | Expected Result | Priority |
|---------|-----------|-----------|--------|-----------------|----------|
| RLS-001 | User can view own trips | Authenticated user | SELECT own trips | Allowed | P0 |
| RLS-002 | User cannot view others' private data | Authenticated user | SELECT all columns from others | Blocked or filtered | P0 |
| RLS-003 | User can create trip | Authenticated user | INSERT trip | Allowed | P0 |
| RLS-004 | User can update own trip | Authenticated user | UPDATE own trip | Allowed | P0 |
| RLS-005 | User cannot update others' trips | Authenticated user | UPDATE other user's trip | Blocked | P0 |
| RLS-006 | User can delete own trip | Authenticated user | DELETE own trip | Allowed | P0 |
| RLS-007 | User cannot delete others' trips | Authenticated user | DELETE other user's trip | Blocked | P0 |
| RLS-008 | Anonymous user cannot access trips | Unauthenticated | SELECT trips | Blocked | P0 |

#### User Profile Visibility Tests

| Test ID | Test Case | User Role | Action | Expected Result | Priority |
|---------|-----------|-----------|--------|-----------------|----------|
| RLS-009 | User can view own full profile | Authenticated user | SELECT own profile | Allowed (all columns) | P0 |
| RLS-010 | User can view limited profile of matches | Authenticated user | SELECT matched user's profile | Allowed (limited columns) | P0 |
| RLS-011 | User cannot view email of others | Authenticated user | SELECT email from others | Blocked or null | P0 |
| RLS-012 | User can update own profile | Authenticated user | UPDATE own profile | Allowed | P0 |

#### Women-Only RLS Enforcement Tests

| Test ID | Test Case | Scenario | Expected Result | Priority |
|---------|-----------|----------|-----------------|----------|
| RLS-013 | Male user queries matches when target has women-only ON | Male user attempts to view female with women-only mode | Not visible in results | P0 |
| RLS-014 | Female user with women-only ON queries matches | Female queries potential matches | Only females returned | P0 |
| RLS-015 | Direct database query bypass attempt | Malicious male user queries trips table directly | RLS blocks visibility | P0 |
| RLS-016 | Women-only filter in match function | Match query includes women-only parameter | RLS enforced at function level | P0 |

---

### 2.3 Edge Function Tests

#### Trip Management Functions

| Test ID | Test Case | Function | Input | Expected Result | Priority |
|---------|-----------|----------|-------|-----------------|----------|
| EF-001 | Create valid trip | create_trip | Valid destination, dates | Trip created with coordinates | P0 |
| EF-002 | Create trip with invalid dates | create_trip | End date before start | Error: validation failed | P0 |
| EF-003 | Create trip >90 days | create_trip | Duration 100 days | Error: max duration exceeded | P0 |
| EF-004 | Create trip with 0 days | create_trip | Same start and end date | Trip created (1 day) | P1 |
| EF-005 | Geocode valid city | create_trip | "Paris, France" | Coordinates returned | P0 |
| EF-006 | Geocode invalid city | create_trip | "InvalidCity, XYZ" | Error: location not found | P0 |
| EF-007 | Update trip dates | update_trip | Valid new dates | Trip updated, matches recalculated | P0 |
| EF-008 | Delete trip | delete_trip | Trip ID | Trip archived/deleted | P0 |

#### Match Query Functions

| Test ID | Test Case | Function | Input | Expected Result | Priority |
|---------|-----------|----------|-------|-----------------|----------|
| EF-009 | Get matches for user | get_matches | User ID, pagination params | Paginated match list | P0 |
| EF-010 | Get matches with women-only filter | get_matches | User ID, women_only=true | Only female matches | P0 |
| EF-011 | Get matches with pagination | get_matches | limit=10, offset=20 | Correct page returned | P1 |
| EF-012 | Match query performance | get_matches | 100K trips in DB | Response <2s | P0 |

#### Validation Functions

| Test ID | Test Case | Function | Input | Expected Result | Priority |
|---------|-----------|----------|-------|-----------------|----------|
| EF-013 | Validate trip dates | validate_trip | Valid dates | Success | P0 |
| EF-014 | Validate trip destination | validate_trip | Valid location | Success | P0 |
| EF-015 | Validate user gender for women-only | validate_women_only | Male user | Error: not allowed | P0 |
| EF-016 | Validate trip duration | validate_trip | 45 days | Success | P1 |

---

## 3. Test Cases by P0 Feature

### F-001: Trip Entry

#### Acceptance Criteria Tests

| AC ID | Test Case | Steps | Expected Result |
|-------|-----------|-------|-----------------|
| 001.1 | Create trip with valid data | 1. User logs in<br>2. Enters "Paris, France"<br>3. Selects Apr 10-15 | Trip created and saved |
| 001.2 | Multiple concurrent trips | 1. User has Paris Apr 10-15<br>2. Creates Berlin Apr 12-18 | Both trips exist |
| 001.3 | Invalid date range (end before start) | 1. User enters Apr 15 as start<br>2. Enters Apr 10 as end | Validation error shown |
| 001.4 | Zero day duration | 1. User enters Apr 10 as start<br>2. Enters Apr 10 as end | Trip created (1 day) |
| 001.5 | Trip >90 days | 1. User enters Apr 1 as start<br>2. Enters Jul 15 as end (105 days) | Error or auto-capped |

#### Edge Cases

| Test ID | Test Case | Input | Expected Result |
|---------|-----------|-------|-----------------|
| TE-001 | Trip in past | Start date: yesterday | Error: cannot create past trip |
| TE-002 | Trip >2 years in future | Start date: 800 days ahead | Error: too far in future |
| TE-003 | Destination with special chars | "São Paulo, Brazil" | Trip created correctly |
| TE-004 | Duplicate trip | Same destination, same dates | Allowed (or warning) |
| TE-005 | Trip to same city, different dates | Paris Apr 1-5, Paris Apr 20-25 | Both trips created |
| TE-006 | Maximum trips per user | Create trip #21 | Error or auto-archive oldest |

---

### F-002: Automatic Traveler Matching

#### Acceptance Criteria Tests

| AC ID | Test Case | Setup | Expected Result |
|-------|-----------|-------|-----------------|
| 002.1 | Date overlap match | User A: Paris Apr 10-15<br>User B: Paris Apr 12-18 | Match appears for both |
| 002.2 | No date overlap | User A: Paris Apr 1-5<br>User B: Paris Apr 10-15 | No match |
| 002.3 | Radius match (within 50km) | User A: Paris<br>User B: 40km away | Match (if radius enabled) |
| 002.4 | Women-only: male not visible | User A: Female, women-only ON<br>User B: Male | User B doesn't see User A |
| 002.5 | Women-only: female visible | User A: Female, women-only ON<br>User B: Female | Match appears |
| 002.6 | Women-only: visibility bidirectional | User A: Female, women-only ON<br>User B: Male | Neither sees the other |

#### Match Quality Tests

| Test ID | Test Case | Scenario | Expected Sorting |
|---------|-----------|----------|------------------|
| MQ-001 | Sort by distance | 3 matches at 10km, 25km, 50km | Sorted by distance ASC |
| MQ-002 | Sort by overlap when distance equal | Same city, 5-day vs 1-day overlap | More overlap first |
| MQ-003 | Exclude self from matches | User queries own matches | Self not included |
| MQ-004 | Exclude inactive trips | User B's trip ended | No match |
| MQ-005 | Active trips only | 3 active, 2 archived trips match dates | Only 3 returned |

---

### F-005: Women-Only Mode

#### Acceptance Criteria Tests

| AC ID | Test Case | Steps | Expected Result |
|-------|-----------|-------|-----------------|
| 005.1 | Enable women-only mode (female) | 1. Female user goes to settings<br>2. Enables toggle | Mode active, indicator shown |
| 005.2 | Male cannot enable | 1. Male user goes to settings<br>2. Toggle disabled | Cannot enable |
| 005.3 | Disable women-only mode | 1. Female user with mode ON<br>2. Disables toggle | All matches visible |
| 005.4 | Visual indicator | 1. Mode enabled<br>2. View settings | Clear indicator visible |

#### Security Tests (CRITICAL)

| Test ID | Test Case | Attack Vector | Expected Result |
|---------|-----------|---------------|-----------------|
| WO-SEC1 | Gender field manipulation | Change gender via direct API call | Blocked by RLS/trigger |
| WO-SEC2 | RLS bypass attempt | Direct SQL query to trips table | RLS blocks visibility |
| WO-SEC3 | Edge function bypass | Call match function without women-only filter | RLS still enforces filter |
| WO-SEC4 | Gender change + immediate access | Change gender, immediately query matches | Blocked by cooldown |
| WO-SEC5 | Concurrent request attack | Multiple simultaneous requests to race condition | Atomic enforcement |

---

## 4. Pass/Fail Criteria

### Week 1 Test Exit Criteria

| Category | Pass Criteria | Blocking? |
|----------|---------------|-----------|
| **Matching Algorithm** | All 10 spatial query tests pass | ✅ Yes |
| **Matching Performance** | p95 <2s at 100K trips | ✅ Yes |
| **Women-Only Mode** | All 5 functional + 5 security tests pass | ✅ Yes |
| **RLS Policies** | All 16 RLS tests pass | ✅ Yes |
| **Edge Functions** | All 16 edge function tests pass | ✅ Yes |
| **Trip Entry (F-001)** | All 5 AC tests + 6 edge cases pass | ✅ Yes |
| **Matching (F-002)** | All 6 AC tests + 5 quality tests pass | ✅ Yes |

### Blocking Bugs Definition

| Severity | Definition | Action |
|----------|------------|--------|
| **P0 (Blocker)** | Safety feature fails, data leak, security bypass | STOP - Fix immediately |
| **P1 (Critical)** | Core feature broken, no workaround | STOP - Fix same day |
| **P2 (Major)** | Feature partially broken, workaround exists | Document, fix within sprint |
| **P3 (Minor)** | Cosmetic, edge case | Backlog |

### Go/No-Go Decision Matrix

| Scenario | Criteria | Decision |
|----------|----------|----------|
| **GO** | 100% P0 tests pass, 0 P0/P1 bugs | Proceed to Week 2 |
| **CONDITIONAL** | 95% P0 tests pass, 1-2 P1 bugs with plan | Proceed with mitigation |
| **NO-GO** | <95% P0 tests pass, any P0 bug | Block until fixed |

---

## 5. Test Data Requirements

### User Fixtures

```yaml
# test_utils/fixtures/users.yaml
users:
  - id: "user-alex"
    email: "alex@test.com"
    first_name: "Alex"
    gender: "female"
    age_range: "25-30"
    home_country: "US"
    women_only_mode: false
    
  - id: "user-marcus"
    email: "marcus@test.com"
    first_name: "Marcus"
    gender: "male"
    age_range: "30-35"
    home_country: "DE"
    
  - id: "user-priya"
    email: "priya@test.com"
    first_name: "Priya"
    gender: "female"
    age_range: "40-45"
    home_country: "IN"
    women_only_mode: true
```

### Trip Fixtures

```yaml
# test_utils/fixtures/trips.yaml
trips:
  - id: "trip-paris-alex"
    user_id: "user-alex"
    destination: "Paris, France"
    location: "POINT(2.3522 48.8566)"  # PostGIS format
    start_date: "2026-04-10"
    end_date: "2026-04-15"
    is_active: true
    
  - id: "trip-paris-marcus"
    user_id: "user-marcus"
    destination: "Paris, France"
    location: "POINT(2.3522 48.8566)"
    start_date: "2026-04-12"
    end_date: "2026-04-18"
    is_active: true
    
  - id: "trip-lyon-priya"
    user_id: "user-priya"
    destination: "Lyon, France"
    location: "POINT(4.8357 45.7640)"
    start_date: "2026-04-10"
    end_date: "2026-04-15"
    is_active: true
```

### Geographic Test Data

| City | Coordinates | Use Case |
|------|-------------|----------|
| Paris, France | (2.3522, 48.8566) | Primary test city |
| Lyon, France | (4.8357, 45.7640) | 50km radius test (384km away) |
| Brussels, Belgium | (4.3517, 50.8503) | Cross-border match (264km) |
| Central Paris | (2.33, 48.86) | Neighborhood precision |
| 50km from Paris | (2.8, 48.9) | Radius boundary test |

### Benchmark Test Data

```sql
-- Generate 100K synthetic trips for performance testing
-- See: test_utils/generators/benchmark_data.sql
```

**Requirements:**
- 100,000 trips
- 50,000 users
- 50 cities globally distributed
- Date range: 365 days
- Active/inactive ratio: 80/20

---

## 6. Test Environment Setup

### Supabase Test Configuration

```bash
# .env.test
SUPABASE_URL=https://test-project.supabase.co
SUPABASE_ANON_KEY=test-anon-key
SUPABASE_SERVICE_ROLE_KEY=test-service-role-key
DATABASE_URL=postgresql://test:test@localhost:54322/postgres
```

### Test Database Setup

```bash
# Start local Supabase for testing
supabase start

# Run migrations
supabase db reset

# Seed test data
psql -f test_utils/fixtures/seed_test_data.sql
```

### Performance Test Infrastructure

| Resource | Specification | Purpose |
|----------|---------------|---------|
| Supabase Local | Docker containers | Unit/integration tests |
| Supabase Pro (2XL) | 16 cores, 64GB RAM | 100K benchmark tests |
| k6 / Artillery | Load testing tool | Concurrent query tests |

---

## 7. Test Execution Schedule

### Week 1 Daily Schedule

| Day | Date | Focus | Test Types |
|-----|------|-------|------------|
| Mon | Apr 6 | Database setup + RLS | RLS-001 to RLS-016 |
| Tue | Apr 7 | Trip APIs | EF-001 to EF-008, TE-001 to TE-006 |
| Wed | Apr 8 | Matching algorithm | MA-001 to MA-010 |
| Thu | Apr 9 | Women-only mode + Security | WO-001 to WO-005, WO-SEC1 to WO-SEC5 |
| Fri | Apr 10 | Performance benchmarks | MA-P01 to MA-P07 |

### Daily Test Cycle

1. **Morning (09:00-12:00)**: Development + unit tests
2. **Afternoon (13:00-16:00)**: Integration tests
3. **EOD (16:00-17:00)**: Regression run + bug reporting

---

## 8. Bug Reporting Template

```markdown
## Bug Report

**Test ID**: [e.g., MA-003]
**Severity**: [P0/P1/P2/P3]
**Feature**: [F-001/F-002/F-005]

### Description
[What happened]

### Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Expected Result
[What should have happened]

### Actual Result
[What actually happened]

### Environment
- Supabase version: [x.x.x]
- Test data: [fixtures used]
- Timestamp: [ISO 8601]

### Evidence
[Logs, screenshots, query output]

### Regression?
[Yes/No/New feature]

### Assignee
[backend-lead / security-lead]
```

---

## 9. Test Metrics Tracking

### Key Metrics

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Test Case Execution Rate | 100% | - | ⏳ |
| Pass Rate (P0 tests) | 100% | - | ⏳ |
| Pass Rate (All tests) | >95% | - | ⏳ |
| P0 Bugs Open | 0 | - | ⏳ |
| P1 Bugs Open | 0 | - | ⏳ |
| P2 Bugs Open | <5 | - | ⏳ |
| Benchmark p95 Latency | <2s | - | ⏳ |

### Daily Progress Tracking

| Day | Tests Planned | Tests Executed | Tests Passed | Bugs Found | Bugs Fixed |
|-----|---------------|----------------|--------------|------------|------------|
| Mon | 16 | - | - | - | - |
| Tue | 14 | - | - | - | - |
| Wed | 10 | - | - | - | - |
| Thu | 10 | - | - | - | - |
| Fri | 7 | - | - | - | - |
| **Total** | **57** | - | - | - | - |

---

## 10. Sign-Off

### Week 1 Test Sign-Off Checklist

- [ ] All P0 test cases executed (40 tests)
- [ ] All P1 test cases executed (17 tests)
- [ ] Pass rate ≥95%
- [ ] 0 P0 bugs open
- [ ] 0 P1 bugs open
- [ ] 100K benchmark passes (p95 <2s)
- [ ] Women-only mode security tests passed
- [ ] RLS policies verified
- [ ] Test report submitted

### Approvals

| Role | Name | Date | Signature |
|------|------|------|-----------|
| QA Lead | qa-lead | - | [ ] |
| Backend Lead | backend-lead | - | [ ] |
| Security Lead | security-lead | - | [ ] |
| CTO | cto | - | [ ] |

---

**Document Status:** ✅ Complete  
**Next Action:** Begin test execution April 6, 2026  
**Weekly Review:** April 10, 2026 (Friday demo)
