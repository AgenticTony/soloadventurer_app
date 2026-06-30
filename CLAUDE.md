# SoloAdventurer (Mobile) — Primary Product

The Flutter app — the **primary product**. SoloAdventurer is a vetted, AI-spined
trust platform for solo travelers (**not** a "matching app" — read
`docs/FOUNDATIONS.md`). The mobile app is where the product lives: the matching
brain, the concierge, the safety guardian, and the meetup→reputation loop all run
here. The web app (`/Users/anthonyforan/Desktop/SoloAdventurerWeb/`) is the
acquisition / share / SEO surface. See `docs/PRODUCT.md` for the user-facing narrative.

> **Strategy source of truth — read `docs/FOUNDATIONS.md` first.** It is the product
> charter (the reframe, the AI spine, keep/refactor/dispose, guardrails, build
> sequence) and **supersedes any older "matching-app MVP" framing** in this file,
> `.claude/CLAUDE.md`, or the sprint docs. `docs/PRODUCT.md` is the narrative; the
> 13-part research playbook is at `../SoloAdventurerWeb/docs/research/platform-playbook.md`.
> Every PR is auditable against FOUNDATIONS.

## This repo owns the shared backend
`supabase/migrations/` (schema + RLS) and `supabase/functions/` (Edge Functions)
live **here** — **same Supabase project as the web app**. A schema / RLS /
migration / function change here affects the web app and vice versa. This repo's
loop/verifier only sees this repo — it will **NOT** catch a cross-app break.
**Cross-check the web app before any backend change.**

## Stack
- Flutter 3.38.6 / Dart ≥3.3 · Clean Architecture · feature-first
- Riverpod 3 (`@riverpod` + codegen) · go_router · Freezed · fpdart (`Either`)
- Supabase (auth, db, realtime, storage, edge functions) · Drift (offline/sync)
- pgvector profile embeddings · Onfido verification · Viator (graphql_flutter)
- Firebase Messaging (push) · Sentry · Google Maps / flutter_map

## Commands
```bash
flutter pub get                                            # install deps
flutter run                                               # run app
flutter test                                              # unit/widget tests
flutter test --coverage
flutter analyze                                           # static analysis (errors-only gate)
dart run build_runner build --delete-conflicting-outputs  # codegen (riverpod/freezed/json/drift)
flutter test integration_test/                            # integration tests
./scripts/run_tests.sh                                    # full runner w/ reporting
```
Generated files (`.g.dart`, `.freezed.dart`) — never hand-edit; regenerate.

## Architecture
Feature-first Clean Architecture: `lib/app` (bootstrap, router, theme), `lib/core`
(cross-cutting), `lib/features/{auth, matching, journal, travel, safety, profile,
verification, subscription, destination_discovery, social, notifications, …}` —
each with `data/ · domain/ · presentation/`.

**Layer rules:** domain depends on nothing (pure business logic); data implements
domain repos and depends only on domain; presentation depends on domain via use-cases.

## Tests & gate
- ~286 test files; green baseline tracked in `.claude/state/session-handoff.md`
  (signature-keyed regression gate — keyed on test name + signature, not filename).
- `flutter analyze` is **errors-only**; warnings/info are tracked non-blocking debt.

## Rules
- **Build to `docs/FOUNDATIONS.md`.** Its guardrails (§6: no broadcast feed, no
  decorative AI, no ad model, no engagement-as-north-star) and the atomic unit
  (a verified meetup + reputation outcome) govern every feature decision.
- Generated files (`.g.dart` / `.freezed.dart`) — don't hand-edit; regenerate.
- Never push to `main` — always a branch + PR. Never auto-merge (`/go` and `/loop`
  produce PRs; a human merges).
- Never weaken / skip / delete tests to make them pass. Green count never drops
  below the state-file baseline.
- Conventional commits (`feat:` / `fix:` / `chore:` / `docs:` / `refactor:`).
  **No Co-Authored-By / AI-attribution** in commits or PRs.
- Loop / automation state in `.claude/state/` is **JSON only** (Markdown corrupts).

## Safety-sensitive areas — flag before editing (REQUIRES HUMAN SIGN-OFF)
Matching, meetups, SOS, check-ins, trusted contacts, verification (Onfido), auth
(Supabase sessions), RLS policies, payments / paywall. Surface the risk before
changing; these never ship from automation alone. **Women-only mode is a core
strategy, not a niche toggle** — treat any change to it as safety-sensitive.

## Known open items
- **🚨 P0 — leaked credentials in git history** (Supabase service-role key, AWS,
  OpenAI, Resend, Twilio, PATs across ~561 commits). Files were untracked but
  **history was never purged; rotation in progress**. This is a launch blocker —
  the service-role key bypasses RLS for **both** apps. Anthony-owned.
  (See `.claude/state/` + memory.)
- **Verifier subagent:** always constrain to **read-only**. It has destroyed source
  via `git checkout` before — forbid restore/checkout/reset/stash/clean and all edits.

## Loop engineering (already configured in `.claude/` — leave intact)
This project runs the Boris-Cherny loop workflow: `implementer` (worktree-isolated)
→ `code-simplifier` → `verifier` (read-only, default FAIL) → `/commit-push-pr` → CI.
Slash commands / skills: `/go` (one-task finish: self-test→simplify→verify→PR),
`/loop` (autonomous PR-production engine — **never merges**), `/review-sprint`.
State in `.claude/state/sprint-progress.json` + `session-handoff.md`. Full process
and walls in `loop.md`. **Do not modify `.claude/` agents / skills / commands /
hooks — they are configured for this workflow and were set up deliberately.**

### Session handoff
Read `.claude/state/session-handoff.md` before starting any work; update it after
each task and before any `/clear` or context reset.

## Docs grounding (non-negotiable)
WebFetch the CURRENT official docs before writing code that touches Supabase,
Riverpod, go_router, Freezed, Drift, Google Maps, Onfido, pgvector, etc. — never
trust training memory for API signatures or SDK versions. Pin the doc URL in the
PR under "Sources".

## Further docs
`docs/FOUNDATIONS.md` (charter) · `docs/PRODUCT.md` (narrative) · `docs/sprints/` ·
`docs/ARCHITECTURE.md` · strategy research in the sibling web repo
(`../SoloAdventurerWeb/docs/research/`).
