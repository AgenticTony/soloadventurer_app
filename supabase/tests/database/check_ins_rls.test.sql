-- pgTAP — check_ins RLS enabled with owner-scoped policies.
-- Run: `supabase test db`
--
-- Proves migration 20260812020000:
--   - RLS is enabled on check_ins
--   - Owner-scoped SELECT/INSERT/UPDATE policies exist
--   - No DELETE policy (safety audit records)
--   - No anon/public access

begin;
select plan(6);

-- ============================================================================
-- 1. RLS is enabled
-- ============================================================================
select ok(
  EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'check_ins'
          AND rowsecurity = true),
  'RLS is enabled on check_ins'
);

-- ============================================================================
-- 2. Owner-scoped policies exist (3)
-- ============================================================================
select ok(
  EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'check_ins'
          AND policyname = 'check_ins_owner_select' AND cmd = 'SELECT'
            AND qual = '(user_id = auth.uid())'),
  'owner_select policy: user can only SELECT their own check_ins'
);

select ok(
  EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'check_ins'
          AND policyname = 'check_ins_owner_insert' AND cmd = 'INSERT'
            AND with_check = '(user_id = auth.uid())'),
  'owner_insert policy: user can only INSERT their own check_ins'
);

select ok(
  EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'check_ins'
          AND policyname = 'check_ins_owner_update' AND cmd = 'UPDATE'),
  'owner_update policy exists'
);

-- ============================================================================
-- 3. No DELETE policy (safety audit records are not owner-deletable)
-- ============================================================================
select ok(
  NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'check_ins'
              AND cmd = 'DELETE'),
  'no DELETE policy — safety audit records are not owner-deletable'
);

-- ============================================================================
-- 4. No anon/public access
-- ============================================================================
select ok(
  NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'check_ins'
      AND ('{anon}' = roles OR '{public}' = roles OR 'anon' = ANY (roles) OR 'public' = ANY (roles))
  ),
  'no policies grant access to anon or public roles'
);

select * from finish();
