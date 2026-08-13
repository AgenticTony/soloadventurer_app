# Architecture Convention Decisions — PHASE_H

**Date:** 2026-08-13
**Refs:** PHASE_H_HARDENING.md Story H.6 box 8

---

## Decisions

### 1. Directory structure: `data/` over `infrastructure/`

The codebase uses `data/` (datasources, models, repositories) consistently across all features. The `infrastructure/` directory exists in a few features (safety, destination_discovery) but is not the norm. **Decision: standardize on `data/`.** No big-bang move — new features use `data/`, existing `infrastructure/` dirs migrate opportunistically.

### 2. `lib/features/core` folds into `lib/core`

Cross-cutting concerns belong in `lib/core/` (errors, config, monitoring, utils, services, network, api, providers, security, database). Feature-specific code belongs in `lib/features/<feature>/`. The `lib/features/core` pattern is redundant.

### 3. Error handling regime (H.2)

All catch blocks route through `ErrorMapping.log()` (`lib/core/utils/error_mapping.dart`). See H.2 for the migration pattern. No silent catches — every error is diagnosable.

### 4. Provider style: `@riverpod` codegen for new code

New providers use `@riverpod` annotation + codegen (`build_runner`). Existing hand-rolled providers are migrated opportunistically. No new hand-rolled `Notifier` classes.

### 5. Mocking: mocktail for new tests

`mocktail` is the standard for new tests (the safety feature established this pattern). Existing mockito tests are not rewritten.

### 6. HTTP client: `dio` retained

`dio` is used in 5+ core networking files and is the primary HTTP client. `http` is a transitive dependency. **Decision: keep `dio` as the sole HTTP client.** Remove direct `http` usage in new code; existing uses migrate opportunistically.

### 7. Map stack: both retained for now (decision deferred)

`google_maps_flutter` and `flutter_map` serve different screens. A consolidation decision requires UX evaluation. **Deferred to Phase E (scale).**

### 8. Local DB: Drift is the primary

`drift` is used for all offline-first data. `sqflite` is a transitive dependency of `drift`. **Decision: no direct `sqflite` usage in feature code.**

---

## Dependency status

| Package | Current | Decision |
|---|---|---|
| `flutter_secure_storage` | ^10.0.0-beta.4 | ⚠ Move to stable when released (tracking) |
| `mockito` + `mocktail` | Both present | mocktail for new tests (no rewrite) |
| `http` + `dio` | Both present | dio is primary; no new `http` usage |
| `google_maps_flutter` + `flutter_map` | Both present | Deferred to Phase E |
| `sqflite` + `drift` | Both present | Drift is primary |
| `encrypt` + `crypto` + `pointycastle` | Three crypto packages | Consolidate to `crypto` + `pointycastle` (drop `encrypt`) |
| `riverpod_lint` | In dependencies | Move to `dev_dependencies` |
| Flutter SDK | 3.38.6 | Upgrade to 3.44.x in a solo PR |
