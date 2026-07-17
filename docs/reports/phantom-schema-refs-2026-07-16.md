# Phantom schema references — both repos

> **UPDATE 2026-07-17.** (a) **#2 message reporting: FIXED** — repointed at the existing `reports`
> table (`target_type='message'` was in the enum all along; no migration), errors propagate, wired
> into the chat UI, proven by pgTAP. The scan half was **deleted**; moderation-at-creation is Phase C
> (§9) and will be rebuilt from that design. (b) **#8 `photos`: deleted** (decision: Anthony). The
> `Photo` model and `thumbnail_service.dart` were deliberately kept — see the commit. (c) The ratchet
> now also checks **`.functions.invoke()`**, which immediately found a **12th phantom**:
> `delete-user-account` (auth) — **account deletion is broken** (GDPR + store requirement). (d) A
> related but distinct gap: **8 of the repo's 12 edge functions are not deployed to prod** (incl.
> `verify-with-onfido`, `request-connection`/`respond-connection`, `find-potential-matches-semantic`)
> — "merged ≠ live" applies to edge functions too; the ratchet proves repo-consistency only.
> Current state lives in `PHASE_0_BLOCKERS.md` Story 0.7; the body below is the 2026-07-16 snapshot.

> **Date:** 2026-07-16 · **Scope:** mobile `lib/`, `supabase/functions/`, web `src/` · **Verified against:** live prod (Supabase MCP, `information_schema`) **and** `supabase/migrations/`
> **Status:** findings only — **no fixes applied.** The remediations are safety-sensitive and gated on human sign-off (Story 0.7).
> **Reproduce:** `python3 scripts/check-schema-refs.py` (mobile + edge). Web is scanned by the same logic; its durable fix is Story **W.2** generated types.

## Summary

**11 phantom targets across 27 call sites.** Code queries tables, views and RPCs that **no migration creates and that do not exist in production**.

This is not a collection of unrelated bugs. It is **one failure repeated eleven times**: a feature is built with a table, a policy, a component, an API and passing tests — wired to a backend that was never created. It is the same defect as Story 0.4 (the SOS button called a GraphQL host that did not exist) and Story 0.6 (blocking writes to `blocked_users`; the table is `blocks`).

**Why CI never caught it:** the test suites **mock the Supabase client**. A mock answers to any table name you invent, so a green suite proves the mock, not the schema. `PrivacyContext.test.tsx` is green today and has never touched a real table name. Every one of these was invisible until the code was diffed against the live schema by hand.

**Calibration.** None of this is a data leak; nothing is over-exposed. Prod has **zero users** post-repave, so nobody is currently harmed. What it costs is **capability** — three safety controls do not function — and **credibility of the completion estimate**: features counted as done are scaffolding.

## Ordered by charter impact

Ranked against `docs/FOUNDATIONS.md`, not by call-site count. The three most damaging are things FOUNDATIONS **explicitly names as strategic assets**.

### 1. `shared_meetups` — a named KEEP that does not exist 🚨

FOUNDATIONS §5, Keep/Refactor/Dispose, `(high)` confidence:

> **KEEP** — _"Safety pillar (SOS, check-ins, `meetup_checkins`, **`shared_meetups`**, trusted contacts) — **the differentiator** and the trust scaffold for offline meeting. Elevate into the AI guardian."_

The charter names this table, by name, as **the differentiator**. It was never created.

- `lib/features/safety/presentation/screens/meetup/share_meetup_screen.dart:290` → `.from('shared_meetups').insert(...)`
- `ShareMeetupScreen` **is a registered route** (`lib/app/router/go_router_config.dart:320`) — a user can reach it and the write fails.

**Impact:** telling someone where you are meeting a stranger is a core safety act. It does not work. The KEEP list is describing infrastructure that isn't there.

### 2. `message_reports` + `message_moderation` — the "incumbent-can't-do wedge" does not exist 🚨

FOUNDATIONS §5, `(high)` confidence:

> **REFACTOR** — _"Message moderation — move client-side → server-side, pre-delivery, at-creation (L3). **The incumbent-can't-do wedge.**"_

Both tables are phantom, so the wedge has nothing under it.

- `lib/features/chat_moderation/domain/services/message_moderation_service.dart:106` → `.from('message_reports').insert(...)`
- `lib/features/chat_moderation/domain/services/message_moderation_service.dart:124` → `.from('message_moderation').select(...)`
- Reachable via `lib/features/chat_moderation/presentation/providers/moderation_providers.dart`.

**Impact:** **reporting a harmful message writes nowhere.** With Story 0.6 (blocking) that makes **three non-functional safety controls: block, report, share-meetup.**

### 3. `chats` — an edge function that fails on every message 🚨

- `supabase/functions/notify-new-message/index.ts:104` → `.from("chats")` keyed on `message.chat_id`.
- **Neither exists.** `messages` columns are: `id, connection_id, sender_id, receiver_id, content, activity_id, sent_at, delivered_at, read_at, client_message_id, client_created_at` — there is **no `chat_id`**; the real key is `connection_id`.
- The function is **invoked by a DB trigger on message insert** (`supabase/migrations/20260407000000_push_notification_trigger.sql`) and is **deployed and ACTIVE**.

**Impact:** new-message push notifications are **broken in production** and fail on every single message. Note this is also a **column** defect (`chat_id`), which the scanner cannot see — see Limits.

### 4. `create_trip` · `get_trip_by_id` · `list_my_trips` — web's trip CRUD

- `SoloAdventurerWeb/src/lib/api.ts:206, 229, 260` → `.rpc(...)`. All three absent from prod and from migrations.

**Impact:** create, read and list trips — the core product object web is meant to surface publicly at execution-order step 10.

### 5. `blocked_users` — Story 0.6 (already recorded)

- `SoloAdventurerWeb/src/contexts/PrivacyContext.tsx:165, 214, 292`; `src/components/moderation/BlockDialog.tsx:87`.
- Table is `blocks`. Web never references `blocks` once. Full detail + the `profiles_read_connected` gap: `PHASE_0_BLOCKERS.md` Story 0.6.

### 6. `get_entries_near_location` — journal RPC

- `lib/features/journal/data/datasources/journal_remote_data_source_impl.dart:345`
- `lib/features/journal/data/datasources/journal_remote_data_source_optimized.dart:470`

Notable because these are the journal's **real, wired** datasources — the same files that correctly use `media_items`. So this is a live path with one phantom call, not abandoned scaffold.

### 7. `travel_preferences` — offline sync

- `lib/features/offline/infrastructure/sync/upload_sync.dart:442, 457`, reachable via `sync_manager_impl.dart`. Queued offline writes target a table that does not exist.

### 8. `photos` — the only one the charter does **not** want ⬇️

12 call sites in `lib/core/repositories/supabase_photo_repository.dart` — the largest count on this list and **the lowest priority**.

**This one is a different animal.** Everything above is code that **runs and breaks**. This is code that **never runs**:

- `photoRepositoryProvider` — the thing that would inject it — **is never defined**; it exists only in READMEs and a `///` comment.
- `SupabasePhotoRepository` is the sole implementer of `PhotoRepository`; nothing references either.
- `PhotoGalleryScreen` declares `routeName = '/trips/photos'` but **nothing registers it**, and its `_fetchPhotos` does `await Future.delayed(...)` and returns **fake data** under a comment reading _"In a real implementation, this would call a repository method"_.
- It uses camelCase columns (`userId`, `tripId`) against a snake_case schema — it has never executed.

**And the charter is clear that photos matter but this isn't the vehicle.** FOUNDATIONS §7 ("Content & Media — photos as fuel, not feed") says the media pipeline **already exists** — _"this is a re-shape, not a build"_ — naming the `media_item` model and the `journal-photos` / `journal-videos` buckets. That is **`media_items`**, which is live and wired into the journal's real datasources. PRODUCT §5 lists the four surfaces photos live on — match card, verified profile, city board, post-meetup memory — and **a trip photo gallery is not among them**. §7 additionally names `PostCard/PhotoGrid` as part of the forbidden broadcast-feed shape.

**Verdict:** an unwired duplicate of the sanctioned path. Likely deletion (~5 files incl. the orphaned `thumbnail_service.dart`) — **but that is a product call, not a mechanical one.** If a trip gallery is on the roadmap, the scaffold plus `VirtualGridView` is deliberate groundwork. The photo work FOUNDATIONS §7 actually wants — the four permitted uses — is `media_items`/journal work that has not started.

**Not a launch blocker.** It should not sit in the same bucket as the three broken safety controls.

## The fix that stops the next one

**Mobile + edge — `scripts/check-schema-refs.py`, wired into `code-quality.yml` (this change).**
It parses `supabase/migrations/` for every `CREATE TABLE|VIEW|FUNCTION` and compares against every `.from('x')` / `.rpc('x')` in `lib/` and `supabase/functions/`. It is a **ratchet**: the 7 known mobile/edge phantoms are baselined with the story that removes them, **any new phantom fails the build**, and **a baseline entry that gets fixed also fails** until it is deleted — so the list can only shrink. It lives in `code-quality.yml` rather than `supabase-ci.yml` because the latter is path-filtered to `supabase/**` and would not fire on a new phantom `.from()` in `lib/`.

**Web — Story W.2 (generated types) is the real fix, and this raises its priority.**
`supabase gen types typescript` → `database.types.ts` makes a typed client reject `.from('blocked_users')` **at compile time**, and catches **column** errors too (which the scanner cannot). All four web phantoms — `blocked_users` and the three trip RPCs — would have been `tsc` errors. W.2 was already the highest-value web story because the repave moved the schema underneath it; this is the second, independent argument for it.

### Limits — read before trusting a green run

- **String-level only.** A runtime-built name (`.from(tableName)`) is invisible.
- **No column checking.** `notify-new-message`'s `message.chat_id` is a column defect; only its `.from("chats")` is caught. Generated types (W.2) close this for web; Dart has no equivalent.
- **Migrations, not prod.** It proves code agrees with the repo's migrations. Post-repave those match, but "merged ≠ live" still applies.
- **Two false-positive classes are handled structurally**, because both cost real review time on 2026-07-16: `storage.from('avatars')` is a **bucket**, not a table (and the receiver may sit on an earlier line in a wrapped Dart chain); and a `.from()` inside a **comment** is documentation, not a call — `feature_flags` appeared only in a commented-out TODO example.

## Method note

The manual sweep that produced the first draft of this report **undercounted (8, not 11) and produced two false positives**. Both errors came from grepping line-by-line: it missed `.rpc(` with the argument on the next line (`get_entries_near_location`), and it flagged `avatars`/`feature_flags` without checking whether they were buckets or comments. The committed script scans full file text and strips comments, which is why the number moved. **Every finding above was confirmed individually against live prod before being written down.**
