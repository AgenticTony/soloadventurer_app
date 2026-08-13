# TODO/FIXME Triage — H.7 Box 4

**Date:** 2026-08-13
**Refs:** PHASE_H_HARDENING.md Story H.7 box 4
**Scope:** 66 TODO markers in `lib/` (excluding generated `.g.dart` files)

---

## Triage summary

Every TODO is dispositioned into one of three buckets per the acceptance box:
**story** (sprint work), **issue** (tracked debt), or **delete** (stale).

| Disposition | Count | Action |
|---|---|---|
| **Story** | 10 | Folded into existing/new sprint stories (below) |
| **Issue** | 56 | Filed as 6 tracked GitHub issues by category |
| **Delete** | 0 | None — every TODO had live signal |

---

## Stories (10 TODOs → 3 stories)

### Story P-1: Places API — ship real or feature-flag off (6 TODOs)
`lib/features/recommendations/data/datasources/places_remote_data_source_impl.dart`
- All 6 TODOs are `PRODUCTION TODO: Replace with real Google Places API`
- **Decision needed (👤 Anthony):** ship real Places calls behind the existing key plumbing, or feature-flag the recommendations surface off for launch so no mock data is reachable in prod
- **Disposition:** folds into an existing H.7 box 3 story (already named in the sprint doc)

### Story TM-1: TokenManager deletion audit (2 TODOs)
`lib/features/auth/presentation/providers/token_manager_provider.dart:35,57`
- Both TODOs are in the deprecated presentation-layer TokenManager
- **Disposition:** H.7 box 1 — confirm zero consumers of the unimplemented refresh path, then delete (domain `token_manager.dart` is the keeper)

### Story AI-1: AI suggestion wiring (1 TODO)
`lib/features/travel/presentation/widgets/ai_suggestions_bottom_sheet.dart:117`
- Part of the Phase C agent layer
- **Disposition:** Phase C story (already planned)

### Story SUB-1: Premium check for women-only mode (1 TODO)
`lib/features/matching/presentation/providers/chat_provider.dart:487`
- The `canEnableWomenOnlyMode` premium gate
- **Disposition:** folds into H.3's follow-up (women-only extraction to safety layer)

---

## Issues (56 TODOs → 6 tracked issues)

### Issue 1 — Unimplemented stubs (30 TODOs)
Deferred implementation work across media compression (2), video compression (2), social sharing (3), sync (4), trip repository (3), onboarding screens (3), and 13 others.
**Tracking:** file as `tech-debt: unimplemented stubs`

### Issue 2 — Navigation wiring (11 TODOs)
Stub navigation in profile screens (4), destination discovery screens (4), notification service (1), and 2 others.
**Tracking:** file as `tech-debt: navigation wiring`

### Issue 3 — Cache implementation stubs (5 TODOs)
`lib/features/auth/infrastructure/services/cached_data_provider.dart` — trip caching/CRUD stubs (5).
**Tracking:** file as `tech-debt: caching stubs`

### Issue 4 — Error handling gaps (2 TODOs)
Network error screen and token loading state fallback paths.
**Tracking:** file as `tech-debt: error handling`

### Issue 5 — Platform-specific handling (2 TODOs)
iOS/Android conditional code paths.
**Tracking:** file as `tech-debt: platform handling`

### Issue 6 — General deferred work (6 TODOs)
Offline service providers, journal search, feature flags, and misc.
**Tracking:** file as `tech-debt: general`

---

## Delete (0 TODOs)

No TODOs were pure noise. Every marker represented live deferred work — none were deletable comments referencing completed work.

---

## Follow-up

- The 6 issues above should be filed in GitHub with the `tech-debt` label
- Story P-1 needs Anthony's product decision (ship vs flag-off) before launch
- Story TM-1 needs the consumer audit before deletion
- This triage satisfies H.7 box 4: every TODO is dispositioned
