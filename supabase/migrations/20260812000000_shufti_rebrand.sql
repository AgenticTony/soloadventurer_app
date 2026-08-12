-- Migration: 20260812000000_shufti_rebrand.sql
-- Purpose: Rename Onfido-specific columns on verification_records to
--          vendor-neutral names ahead of the Shufti Pro integration.
--
-- Context: The Onfido integration was never deployed (the edge function was
-- never invoked; the Flutter feature used a simulation stub). These columns
-- have never held real production data, so renaming is safe — no data
-- migration, no backfill.
--
-- Refs: SHUFTI_MIGRATION_PLAN.md §3
-- Postgres syntax: https://www.postgresql.org/docs/current/sql-altertable.html
--                  https://www.postgresql.org/docs/current/sql-alterindex.html

-- 1. Rename columns (Onfido → provider-neutral)
ALTER TABLE public.verification_records
  RENAME COLUMN onfido_check_id TO provider_reference;

ALTER TABLE public.verification_records
  RENAME COLUMN onfido_workflow_run_id TO provider_workflow_id;

ALTER TABLE public.verification_records
  RENAME COLUMN onfido_result TO provider_result;

ALTER TABLE public.verification_records
  RENAME COLUMN onfido_breakdown TO provider_breakdown;

-- 2. Add a provider column so future vendor swaps are first-class and auditable
ALTER TABLE public.verification_records
  ADD COLUMN IF NOT EXISTS provider TEXT NOT NULL DEFAULT 'shuftipro'
    CHECK (provider IN ('shuftipro'));

-- 3. Rename the index (column rename does NOT auto-rename the index per PG docs)
ALTER INDEX IF EXISTS public.idx_verification_records_onfido
  RENAME TO idx_verification_records_provider_ref;

-- 4. Update the table comment
COMMENT ON TABLE public.verification_records IS
  'Identity verification results from Shufti Pro (gender/age/identity). '
  'provider_reference is the Shufti verification reference.';

-- 5. Update the user_verification.provider column comment (separate table)
COMMENT ON COLUMN public.user_verification.provider IS
  'Verification provider identifier (e.g. shuftipro).';
