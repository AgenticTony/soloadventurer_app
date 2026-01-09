---
description: Update dependencies safely with compatibility checks
---

# Update Dependencies

I'll help you update dependencies safely, handling breaking changes.

## Strategy:

### Phase 1: Safe Updates (Non-Breaking)
Updates that won't break code:
- http: 1.3.0 → 1.6.0
- dio: 5.8.0+1 → 5.9.0
- drift: 2.28.2 → 2.30.0
- flutter_map: 8.1.0 → 8.2.2
- google_maps_flutter: 2.10.1 → 2.14.0
- mockito: 5.4.5 → 5.6.1

### Phase 2: Major Updates (Breaking Changes - REQUIRE MIGRATION)
⚠️ These need code changes:
- **flutter_riverpod: 2.6.1 → 3.1.0** - Major API changes
- **riverpod_annotation: 2.6.1 → 4.0.0** - Breaking changes
- **riverpod_generator: 2.6.4 → 4.0.0+1** - Breaking changes
- **freezed: 2.5.8 → 3.2.4** - Requires migration
- **freezed_annotation: 2.4.4 → 3.1.0** - Breaking changes
- **geolocator: 13.0.2 → 14.0.2** - API changes
- **get_it: 8.0.3 → 9.2.0** - Breaking changes
- **flutter_local_notifications: 16.3.3 → 19.5.0** - Major breaking
- **workmanager: 0.5.2 → 0.9.0+3** - Breaking changes
- **flutter_lints: 3.0.2 → 6.0.0** - New lint rules

### Phase 3: Stable Release
- flutter_secure_storage: 10.0.0-beta.4 → 10.0.0

## Recommendations:

**For NOW (Phase 1 only):**
Update safe dependencies, fix critical issues first.

**LATER (Phase 2 & 3):**
Plan major migrations separately:
1. Create a feature branch
2. Update one major package at a time
3. Run tests after each update
4. Follow migration guides

## What I'll Do Now:

1. Check pubspec.yaml for current versions
2. Identify safe updates only
3. Run `flutter pub upgrade` for safe versions
4. Run tests to verify

⚠️ **Skipping major breaking updates** - These need dedicated migration work.

Starting with safe updates...
