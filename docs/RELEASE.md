# Release checklist

Covers both repos. The backend (`supabase/migrations/`, `supabase/functions/`)
lives here and is shared with `../SoloAdventurerWeb`, so a backend release is
always a two-repo event.

## Why this exists

The 2026-08-12 audit found three defects that every existing gate was structurally
incapable of seeing, because **every gate reads the repository and none read the
deployed project**:

- `verify-with-onfido` was deleted from the repo and the removal verified with a
  grep gate. Deleting a directory does not undeploy a function. It stayed
  `ACTIVE` in production, still reachable, still carrying a stubbed signature
  check that wrote `profiles.gender_verified` — the flag that admits users to
  women-only mode.
- The Shufti schema was applied through the Management API because `db push`
  wanted a password nobody had. The DDL landed; the ledger row did not. The next
  `db push` from either repo would have replayed the rebrand migration, hit a
  `RENAME COLUMN` on a column that no longer existed, and aborted mid-release.
- `check_ins` — a safety table — had RLS disabled in production, readable and
  writable by anyone holding the public anon key.

Sections 1 and 3 exist specifically to catch that class. Do not skip them because
CI is green; CI cannot see any of it.

---

## 1. Preflight — live vs repo

```bash
python3 scripts/preflight.py
```

Compares the deployed project against the tree: orphaned edge functions, migration
ledger drift, **destructive statements in unapplied migrations**, required and
retired-vendor secrets, RLS coverage, anon-executable `SECURITY DEFINER` functions.

The destructive check exists because drift alone is not the danger — drift *plus*
a `DROP` is. An unapplied migration whose objects are already live will replay
against real rows.

- [ ] Preflight exits `0`
- [ ] **No check reported SKIP.** A skip is not a pass. The RLS and grant checks
      skip silently without a connection string:
      ```bash
      export SUPABASE_DB_URL='postgresql://...'   # Dashboard → Settings → Database
      python3 scripts/preflight.py --strict       # SKIP now fails the run
      ```

## 2. Repo gates

Mobile:

- [ ] `flutter test` — green count ≥ `test_baseline` in `.claude/state/sprint-progress.json`,
      every failure matching a known signature
- [ ] `flutter analyze` — zero **errors** (warnings are tracked debt)
- [ ] `dart run build_runner build --delete-conflicting-outputs` leaves no diff
- [ ] `python3 scripts/check-schema-refs.py`
- [ ] `supabase test db` — pgTAP green

Web:

- [ ] `npm run typecheck` — zero errors
- [ ] `npm run lint` — zero errors
- [ ] `npx jest` — green, **run it three times**. The `useUserSearch` flake
      surfaced roughly 1 run in 3 under parallel load and was invisible to a
      single run.
- [ ] `npm run build`

CI:

- [ ] All checks green on the merge commit, not just the branch
- [ ] **If the PR was ever stacked on another branch, confirm CI actually ran.**
      `ci.yml` triggers only on PRs targeting `main`, and retargeting does not
      fire it — the workflow does not listen for `edited`. A stacked PR shows one
      passing check (GitGuardian) and looks green while having run nothing. Close
      and reopen the PR to trigger the suite.

## 3. Backend deploy — order matters

Client-side column projections must ship **before** any migration that revokes
column access, or existing clients break on their own profile reads.

- [ ] Cross-check the other repo for anything touching the same tables
      (`CLAUDE.md`: this repo's gates cannot see the web app)
- [ ] Snapshot the database — Dashboard → Database → Backups
- [ ] Deploy **client** changes first (web deploy, mobile store release), and
      allow time for adoption before the migration lands
- [ ] `supabase db push`
- [ ] `supabase functions deploy <name>` for each changed function
- [ ] Re-run `python3 scripts/preflight.py` — the ledger and function checks
      should now both pass against the new state
- [ ] Smoke-test each changed function against production

If a migration was applied out-of-band, repair the ledger **before** the next push:

```bash
supabase migration repair --status applied <version>
supabase db diff --linked        # must come back empty
```

## 4. Mobile release

- [ ] Version and build number bumped in `pubspec.yaml`
- [ ] Release build succeeds on both platforms
- [ ] Sentry release created; symbols uploaded
- [ ] Camera / location / notification permission strings current on both
      platforms — the verification flow needs camera and photo library
- [ ] Install the release build on a physical device and run the smoke list in §6

## 5. Web release

- [ ] Environment variables set in the deploy target (never `NEXT_PUBLIC_` for
      anything secret)
- [ ] Preview deploy checked before promoting
- [ ] `src/types/database.types.ts` regenerated if the schema changed:
      ```bash
      supabase gen types typescript --linked > src/types/database.types.ts
      npx tsc --noEmit
      ```

## 6. Smoke test on production

Green tests prove the mocks. These paths have each shipped broken with a green
suite, so exercise them against the real backend:

- [ ] Sign up, sign in, sign out
- [ ] Create a trip; it appears for another account
- [ ] Send and read a chat message — **check the unread count clears**
      (read state is `messages.read_at`; an `is_read` flag never existed)
- [ ] Report a user, and separately report a message — **confirm rows land in
      `reports`** (this wrote to four non-existent columns and failed silently)
- [ ] Block a user; confirm they disappear from discovery and cannot connect
- [ ] Run the ID verification flow end to end — document capture, then selfie,
      then a result that reflects the real outcome
- [ ] Trigger SOS with a trusted contact configured; confirm the alert lands
- [ ] Delete an account and confirm the data is gone (GDPR)

## 7. Safety-sensitive sign-off

`CLAUDE.md` requires a human on: matching, meetups, SOS, check-ins, trusted
contacts, verification, auth, RLS policies, payments, and women-only mode.

- [ ] Every safety-sensitive change in this release names its human sign-off
- [ ] No automation-only merge touched any of the above
- [ ] Women-only gating re-verified: a verified female account can enable it, a
      male account cannot, and `is_verified_female()` still gates matching RLS

## 8. Rollback

Know these before you deploy, not during an incident.

- [ ] **Edge function** — `supabase functions deploy <name>` from the previous
      commit. Fastest path; prefer it.
- [ ] **Migration** — forward-only. There are no down migrations, so a bad
      migration needs a new corrective one. Write it before you push if the
      change is risky.
- [ ] **Web** — redeploy the previous deployment.
- [ ] **Mobile** — no rollback once a build is live. Users stay on the broken
      version until they update, which is why client changes ship before the
      migrations that depend on them.
- [ ] Database restore point noted, with its timestamp

## 9. After release

- [ ] `python3 scripts/preflight.py --strict` clean against the new state
- [ ] Sentry checked for new issue types, not just volume
- [ ] PostHog receiving `meetup_completed` — the north-star metric
      (`docs/FOUNDATIONS.md` §3)
- [ ] `.claude/state/session-handoff.md` updated
- [ ] Test baseline updated if the green count moved

---

## Known outstanding

Not blockers for every release, but re-check each time:

| Item | State |
|---|---|
| Leaked credentials in git history | Rotated 2026-07-15; **history purge still pending**. Do it before any public mirror or open-sourcing. |
| Live Shufti credentials | Sandbox-tier. Production verification needs live keys plus one real-document test — inherently human. |
| `avatars` bucket read policy | Broader than needed; no path or ownership restriction. |
| Leaked-password protection | Off in Auth settings. |
