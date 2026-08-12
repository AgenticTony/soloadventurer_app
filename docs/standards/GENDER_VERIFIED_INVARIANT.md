# The `gender_verified` Invariant

**Status:** Load-bearing safety documentation
**Date:** 2026-08-12
**Refs:** Full audit 2026-08-12, Section 04; Story H.3 (extraction to safety layer)

---

## The invariant (read this first)

`profiles.gender_verified` means **"the user's gender was verified against a government ID by Shufti Pro"** — it does **not** mean "verified female." A verified male user will also have `gender_verified = true`.

Women-only mode access requires **two conditions in conjunction**:

```
gender_verified = true  AND  gender = 'female'
```

Neither condition alone is sufficient. The edge function (`verify-with-shuftipro`) sets `gender_verified = true` for **any** approved gender (male, female, non-binary). Only the **conjunction** gates women-only access.

---

## Where this is enforced

### Database layer (the authoritative guard)

1. **`CHECK constraint` `women_only_requires_verified_female`** (migration `20260401130000`):
   ```sql
   women_only_mode_enabled = false
     OR (gender = 'female' AND gender_verified = true)
   ```
   This means the database itself rejects `women_only_mode_enabled = true` unless both conditions hold. It is impossible to enable women-only mode at the DB level without being a verified female.

2. **`is_verified_female(user_id)`** (migration `20260717140000`):
   ```sql
   EXISTS(SELECT 1 FROM profiles WHERE id = p AND gender = 'female' AND gender_verified = true)
   ```
   Used in RLS policies for matching: `profiles_read_potential_matches` and `trips_read_for_matching`.

3. **`trigger log_gender_change()`** (migration `20260401130000`):
   Any gender change away from `'female'` resets `gender_verified = false` and force-disables women-only mode.

### Application layer (`MatchingRepositoryImpl`)

4. **`enableWomenOnlyMode()`** (line 820):
   ```dart
   if (!await isVerifiedForWomenOnly()) throw Exception('...');
   final gender = await getUserGender();
   if (gender?.toLowerCase() != 'female') throw Exception('...');
   ```
   Checks both conditions before proceeding. The DB constraint is the belt; this is the braces.

### Edge function layer (`verify-with-shuftipro`)

5. **Webhook/callback handler** only sets `gender_verified = true` + `gender = verifiedGender` for **approved** gender verifications. For `"M"` → `gender = 'male'`, `gender_verified = true` — the user is verified, but cannot enable women-only mode because the conjunction fails.

---

## Known weaknesses (tracked for Story H.3)

1. **In-memory state divergence:** `_womenOnlyModeEnabled` in `MatchingRepositoryImpl` (line 815) is cached in memory. If the DB write fails (caught and ignored at line 843), the in-memory state diverges from the DB. This means the app might think women-only mode is enabled when the DB doesn't reflect it. **Fix:** extract women-only state to the safety layer with a single source of truth in the DB, no in-memory mirror.

2. **Silent write failures:** The `enableWomenOnlyMode()` and `disableWomenOnlyMode()` catch blocks (lines 843, 862) swallow errors with `// Silently fail`. A prod failure of the women-only toggle is invisible. **Fix:** route through `ErrorMapping.log()` (see `lib/core/utils/error_mapping.dart`).

3. **`getUserGender()` reads from `profiles.gender`:** This is the self-reported gender field, not the verified one. If a user self-reports `'female'` but Shufti verified them as `'male'`, the edge function sets `gender = 'male'` (overriding the self-report). But if the edge function hasn't run yet, `getUserGender()` reads the unverified self-report. **Mitigation:** the `enableWomenOnlyMode()` guard calls `isVerifiedForWomenOnly()` first (reads `gender_verified`), so this is safe as long as that method is called before `getUserGender()` — which the current code does.

---

## Migration path (Story H.3)

The audit recommends extracting women-only mode to the safety layer:

1. **Single source of truth:** Read women-only state from `profiles.women_only_mode_enabled` via `is_verified_female()` — never cache in memory.
2. **No silent failures:** Every toggle writes to the DB with error logging.
3. **Safety-layer ownership:** Move the women-only toggle from the matching feature to the safety feature, since it's a safety control, not a matching preference.

---

## Summary for anyone touching this code

- `gender_verified = true` ≠ female. It means "ID verified, gender extracted."
- Women-only mode = `gender_verified = true` AND `gender = 'female'`.
- The DB CHECK constraint is the authoritative guard. The app guard is defense-in-depth.
- If you change any of these fields, you are modifying a safety-critical control. Treat it with the same scrutiny as RLS policies. **Human sign-off required.**
