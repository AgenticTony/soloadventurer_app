-- Migration: 20260812010000_expand_provider_check.sql
-- Purpose: Expand the provider CHECK constraint to support future vendor swaps
--          without requiring a schema migration.
--
-- The original 20260812000000_shufti_rebrand.sql added:
--   CHECK (provider IN ('shuftipro'))
-- which only allows one vendor. The plan (§2.3) states "future vendor swaps
-- are first-class." This migration drops the restrictive CHECK and replaces
-- it with one that allows known identity-verification vendors.
--
-- To add a new vendor in the future, update this CHECK — or remove it
-- entirely once the set of providers stabilizes.

ALTER TABLE public.verification_records
  DROP CONSTRAINT IF EXISTS verification_records_provider_check;

ALTER TABLE public.verification_records
  ADD CONSTRAINT verification_records_provider_check
  CHECK (provider IN ('shuftipro', 'onfido', 'stripe_identity', 'persona', 'veriff'));
