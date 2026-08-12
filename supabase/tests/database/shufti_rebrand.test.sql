-- pgTAP — Shufti rebrand: onfido_* columns renamed to provider-neutral names.
-- Run: `supabase test db`
--
-- Proves migration 20260812000000:
--   - 4 columns renamed (no onfido_* columns remain)
--   - provider column added with CHECK + default 'shuftipro'
--   - index renamed
--   - table comment updated
--
-- Refs: SHUFTI_MIGRATION_PLAN.md §3

begin;
select plan(8);

-- ============================================================================
-- 1. Old onfido_* columns do NOT exist (4)
-- ============================================================================
select ok(
  NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'verification_records'
      AND column_name LIKE 'onfido_%'
  ),
  'no onfido_* columns remain on verification_records'
);

-- ============================================================================
-- 2. New provider-neutral columns DO exist (4)
-- ============================================================================
select ok(
  EXISTS (SELECT 1 FROM information_schema.columns
          WHERE table_schema = 'public' AND table_name = 'verification_records'
            AND column_name = 'provider_reference'),
  'provider_reference column exists (was onfido_check_id)'
);

select ok(
  EXISTS (SELECT 1 FROM information_schema.columns
          WHERE table_schema = 'public' AND table_name = 'verification_records'
            AND column_name = 'provider_workflow_id'),
  'provider_workflow_id column exists (was onfido_workflow_run_id)'
);

select ok(
  EXISTS (SELECT 1 FROM information_schema.columns
          WHERE table_schema = 'public' AND table_name = 'verification_records'
            AND column_name = 'provider_result'),
  'provider_result column exists (was onfido_result)'
);

select ok(
  EXISTS (SELECT 1 FROM information_schema.columns
          WHERE table_schema = 'public' AND table_name = 'verification_records'
            AND column_name = 'provider_breakdown'),
  'provider_breakdown column exists (was onfido_breakdown)'
);

-- ============================================================================
-- 3. provider column with CHECK constraint + default
-- ============================================================================
select ok(
  EXISTS (SELECT 1 FROM information_schema.columns
          WHERE table_schema = 'public' AND table_name = 'verification_records'
            AND column_name = 'provider'
            AND column_default = '''shuftipro''::text'),
  'provider column exists with default shuftipro'
);

select ok(
  EXISTS (SELECT 1 FROM pg_constraint c JOIN pg_namespace n ON n.oid = c.connamespace
          WHERE n.nspname = 'public' AND c.conrelid = 'public.verification_records'::regclass
            AND c.contype = 'c'
            AND pg_get_constraintdef(c.oid) LIKE '%provider = ''shuftipro''%'),
  'provider column has CHECK constraint allowing shuftipro'
);

-- ============================================================================
-- 4. Index renamed
-- ============================================================================
select ok(
  EXISTS (SELECT 1 FROM pg_indexes
          WHERE schemaname = 'public' AND tablename = 'verification_records'
            AND indexname = 'idx_verification_records_provider_ref'),
  'index renamed to idx_verification_records_provider_ref'
);

select * from finish();
