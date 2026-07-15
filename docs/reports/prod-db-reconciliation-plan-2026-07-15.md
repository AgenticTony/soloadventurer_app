# Production DB Reconciliation Plan (2026-07-15)

> **⚠ REQUIRES HUMAN SIGN-OFF — every command in §4 touches the production database.**
> Nothing here has been executed. This report was produced by a read-only audit of the
> live Supabase project via MCP (`SELECT`-only queries + advisors). Anthony executes.

**Status: LAUNCH BLOCKER #4** (alongside phantom SOS and the repo `USING (true)`
policy). It **gates any `supabase db push`**.

> **UPDATE 2026-07-15 (same day):**
> - **Credential rotation is CONFIRMED DONE** (Anthony) — the old leaked service-role key is
>   dead, so a `db push` no longer widens exposure. The git-history purge remains a separate,
>   lower-priority cleanup.
> - The repo-side fix for the `USING (true)` blocker shipped as **mobile PR #20** (Story 0.5 /
>   step 9b) — guarded SECURITY DEFINER matchers + drop the policy, pgTAP green. It must land
>   **before** the push (so the push doesn't re-apply the leak) — see §3.
> - Repo-side hardening of the in-repo SECURITY DEFINER functions shipped as **mobile PR #21**
>   (Story H.5 partial) — search_path pinned + anon EXECUTE revoked. So §1.5 below now only
>   concerns the **dashboard-only** functions.
> - Correction to §1.4/§2.4: `get_profile_safe` and `search_profiles` are **in repo migrations**
>   (`20250113000000_rpcs.sql`), not live-only. The live versions may still differ from repo —
>   the `db diff` in §4 step 3 is where that reconciles.

---

## 1. What was found (live project `zyiuajhltmxbsrqplqlx` — verified as the URL both apps use)

### 1.1 Phase A is not deployed

| Object (repo migration) | In repo | Live in prod |
|---|---|---|
| `meetups`, `meetup_outcomes`, `meetup_reviews` (`20260630145537_phase_a_meetups_reputation.sql`) | ✅ | ❌ absent |
| `report_no_show` / `cancel_meetup` RPCs (`20260706100000_phase_a_no_show_cancel.sql`) | ✅ | ❌ absent |
| North-star time indexes (`20260706160000_northstar_time_indexes.sql`) | ✅ | ❌ absent |
| `profiles.embedding` + pgvector index (`20260404100000_profile_embeddings.sql`) | ✅ | ❌ absent (no `embedding` column live) |

Everything "shipped" in PRs #8/#13/#17 is green only in CI's ephemeral pgTAP database.
The north-star metric (`meetup_completed` → `meetup_outcomes`) currently has **no table
to land in** in production.

### 1.2 Foreign project's migrations were applied to this database

Live `supabase_migrations.schema_migrations` contains versions that exist nowhere in
this repo:

| Version | Name | Note |
|---|---|---|
| `20260426115415` | `create_jobs_table` | foreign |
| `20260426115432` | `create_demos_storage_bucket` | foreign — the `demos` bucket **still exists** in `storage.buckets` |
| `20260426115719` | `cleanup_wrong_project` | somebody noticed and partially cleaned up |
| `20260426115811` | `cleanup_storage_policies` | foreign cleanup |
| `20260428190421` | `create_jobs_table_with_agent_columns` | foreign — a **`jobs` table still exists** in `public` |
| `20260428215236` / `20260429065010` | pipeline columns | foreign |

### 1.3 Live history is also missing / mangling repo migrations

- Missing from live history despite the objects existing live (schema was built via
  dashboard, not `db push`): `20250109500000_create_profiles`,
  `20250109600000_create_journal_safety_base_tables`, and **all** repo `202604*`
  migrations (matching, women-only, spatial, RLS, realtime, sos_alerts, embeddings,
  push triggers).
- One malformed entry: version `20260401` named `120000_matching_tables` (a version/name
  split error — likely a hand-run apply).

### 1.4 Live `profiles` RLS does not match any repo migration — and fails CLOSED

Live policy set: `Service role can insert profiles`, `profiles: owner full access`,
`profiles: community visible (filter via RPC)`, `profiles: public visible to
authenticated`, `profiles: visible to accepted followers`, `profiles_read_connected`,
`profiles_read_potential_matches`.

- 5 of 7 SELECT policies have **NULL `polqual`** (anomalous; not producible by the repo's
  `CREATE POLICY ... USING (...)` statements).
- Empirical test: `SET ROLE authenticated` sees **0 of 2** live profiles → prod currently
  **denies cross-user profile reads** at the table level; live RPCs (`get_profile_safe`,
  `search_profiles` — which ARE in repo migration `20250113000000_rpcs.sql`; the LIVE
  definitions may differ from repo, reconciled by the `db diff` in §4 step 3) do the reading.
- Consequence for blocker #2: the `USING (true)` leak
  (`supabase/migrations/20260404100000_profile_embeddings.sql:29`) is a **repo-side**
  defect that would go live **on the first `db push`**. Prod today has the *opposite*
  defect (fails closed / dashboard-era policies). Fix the repo (story 0.5 / step 9b)
  **before** the first push.

### 1.5 Live security-advisor findings

> **Split (2026-07-15):** the **in-repo** SECURITY DEFINER functions are hardened by
> **mobile PR #21** (Story H.5 partial — search_path pinned + anon EXECUTE revoked, via
> `ALTER FUNCTION`). This section now tracks only the **dashboard-only** functions, which a
> repo migration cannot touch and which must be hardened directly against prod (below).

- **Dashboard-only SECURITY DEFINER functions still executable by `anon`** — `create_trip`,
  `update_my_trip`, `delete_my_trip`, `get_trip_by_id`, `list_my_trips`, `get_my_uid`,
  `handle_new_user`. Against prod: `REVOKE EXECUTE ... FROM anon, public` (keep
  `authenticated` on the `*_trip` RPCs; revoke all client roles on the `handle_new_user`
  trigger fn), and `ALTER FUNCTION ... SET search_path = public` on the mutable-search_path
  ones (`update_my_trip`, `get_trip_by_id`, `create_trip`). Do this as part of the
  `db diff`-generated reconcile migration (§4 step 3) so it becomes repo-tracked.
- The **in-repo** functions' hardening (PR #21) applies to prod automatically on the §4 push.
- `postgis` extension installed in `public` schema; `spatial_ref_sys` has RLS disabled
  (ERROR-level lint; PostGIS-owned table, standard remediation applies).
- Public `avatars` bucket has a broad SELECT policy on `storage.objects` allowing
  **listing** of all files.
- Auth: leaked-password protection (HaveIBeenPwned) is **off**.

---

## 2. Decisions Anthony must make first

1. **Canonical schema = the repo.** (Recommended — CI/pgTAP test the repo; the dashboard
   schema is untested and partially foreign.) The reconciliation below assumes this.
2. **Foreign objects:** confirm nothing in this product uses the `jobs` table or `demos`
   bucket, then drop them. If they belong to another project of yours, note that that
   project's migrations were pointed at this DB — check that project's config too.
3. **Timing vs. credential rotation:** ✅ **RESOLVED** — Anthony confirmed rotation is done
   (2026-07-15). The old leaked service-role key is dead, so the push no longer widens
   exposure. (Git-history purge is a separate, lower-priority cleanup.)
4. **Live RPC keep-list:** `get_profile_safe` / `search_profiles` ARE in repo migration
   `20250113000000_rpcs.sql` — so no porting is needed; the `db diff` (§4 step 3) reconciles
   any drift between the live and repo definitions. Decide keep/replace there.

## 3. Guardrails

- Take a **backup / PITR snapshot first** (Dashboard → Database → Backups).
- Do **not** run `supabase db push` until **story 0.5 (9b) — mobile PR #20 — is merged**;
  it drops/replaces the `USING (true)` policy. Pushing before it merges applies the PII leak.
  (H.5 hardening — PR #21 — should also be merged so its function grants ride the same push.)
- `migration repair` edits **history only** (it never runs SQL) — safe, but do it
  deliberately and re-list after every step.
- Run everything against the linked project from this repo (`supabase link
  --project-ref zyiuajhltmxbsrqplqlx` if not already linked).

## 4. Repair procedure (proposed — sign off before running)

```bash
# 0. Snapshot state
supabase migration list --linked        # save this output before touching anything

# 1. Purge the FOREIGN entries from live history (history-only; objects handled in step 4)
supabase migration repair --status reverted 20260426115415 20260426115432 \
  20260426115719 20260426115811 20260428190421 20260428215236 20260429065010
# also the malformed matching entry:
supabase migration repair --status reverted 20260401

# 2. Mark repo migrations whose OBJECTS already exist live as applied
#    (dashboard-built: profiles, journal/safety base, all April-2026 era)
supabase migration repair --status applied 20250109500000 20250109600000 \
  20260401115000 20260401120000 20260401120500 20260401130000 20260401140000 \
  20260401150000 20260402080000 20260402080100 20260407000000
# NOTE: deliberately NOT marking 20260404100000 (embeddings) applied — its objects
# (embedding column, USING(true) policy) are NOT live. It will apply on push, which is
# why 9b must fix/supersede its policy first.

# 3. See the real remaining drift (dashboard-era objects vs repo definitions)
supabase db diff --linked -f reconcile_drift
# Review the generated migration: it will surface the live-only policies/RPCs
# (get_profile_safe, search_profiles, dashboard profiles policies) vs repo. Decide
# keep/port/drop per §2.4 — this review is the core human judgment step.

# 4. Drop foreign objects (after §2.2 confirmation) — as a repo migration so it's audited:
#    DROP TABLE IF EXISTS public.jobs;
#    DELETE FROM storage.buckets WHERE id = 'demos';  -- after emptying it

# 5. Only after 9b (PR #20) AND H.5 (PR #21) are merged to main:
supabase db push --dry-run   # verify plan: embeddings(fixed by 9b), Phase A, time indexes,
                             #              9b RLS repair, H.5 grants
supabase db push
supabase migration list --linked   # confirm history == repo

# 6. Post-push verification
# - pgTAP against linked (or spot-check): meetups/meetup_outcomes exist; USING(true) gone
# - Re-run MCP get_advisors (security) — expect the in-repo anon-EXECUTE findings gone (H.5);
#   the dashboard-only ones (create_trip etc.) cleared by the step-3 reconcile migration
```

## 5. Follow-ups this creates

- ✅ **9b (PR #20) shipped** — RLS repair + guarded SECURITY DEFINER matchers; pgTAP green.
  No RPC porting was needed (they're already in-repo, §2.4 correction).
- ✅ **H.5 in-repo hardening (PR #21) shipped** — `search_path` pinned + anon EXECUTE revoked
  on the 12 in-repo SECURITY DEFINER functions; pgTAP green.
- **Still open, non-migration (dashboard / auth-console — Anthony):** enable leaked-password
  protection (Auth settings); fix the public `avatars` bucket's broad listing policy; move
  `postgis` out of the `public` schema; RLS on `spatial_ref_sys` (PostGIS-owned — standard
  remediation). None of these are repo migrations.
- **Dashboard-only function hardening** (`create_trip` etc.) — folds into the §4 step-3
  reconcile migration.
- **Durable PII column-`REVOKE`** — gated on converting both apps' `profiles` `select('*')`
  reads to explicit columns first (payments/safety/auth surfaces); tracked separately.
- **Process rule (add to loop docs):** "merged" ≠ "live". Any status doc claiming a
  backend capability shipped must state where it is live (prod push confirmed) or not.

## Sources

- Live queries: Supabase MCP (`list_migrations`, `list_tables`, `get_advisors`,
  read-only `execute_sql` on `pg_policy`, `pg_proc`, `information_schema`,
  `storage.buckets`) — 2026-07-15.
- Migration repair: https://supabase.com/docs/reference/cli/supabase-migration-repair
- DB diff / push: https://supabase.com/docs/reference/cli/supabase-db-diff ·
  https://supabase.com/docs/reference/cli/supabase-db-push
- Database linter remediations: https://supabase.com/docs/guides/database/database-linter
