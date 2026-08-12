-- Migration: 20260812010000_expand_provider_check.sql
-- Purpose: Expand the provider CHECK constraint to support future vendor swaps
--          without requiring a schema migration.

ALTER TABLE public.verification_records
  DROP CONSTRAINT IF EXISTS verification_records_provider_check;

ALTER TABLE public.verification_records
  ADD CONSTRAINT verification_records_provider_check
  CHECK (provider IN ('shuftipro', 'onfido', 'stripe_identity', 'persona', 'veriff'));
