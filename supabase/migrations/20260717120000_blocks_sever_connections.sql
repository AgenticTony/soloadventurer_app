-- ============================================================================
-- Story 0.6 — make blocking actually gate visibility (backend half)
--
-- CONTEXT (docs/reports/phantom-schema-refs-2026-07-16.md, PHASE_0 Story 0.6):
-- the block feature was non-functional — web wrote to a phantom `blocked_users`
-- table — and even with rows in `blocks`, two defects meant a block would not
-- have hidden the blocker from a connected user:
--
--   1. `profiles_read_connected` granted SELECT purely on
--      has_active_connection(); permissive policies OR together, so it
--      overrode the block clause in `profiles_read_potential_matches`.
--   2. The AFTER INSERT ON blocks trigger cleared `follows` but left the
--      `connections` row `accepted` — so has_active_connection() stayed true.
--
-- Decisions (2026-07-17, per §5/§6 — flagged for human sign-off in the PR):
--   * a block severs the connection: status -> 'blocked' (the CHECK constraint
--     has allowed 'blocked' since the table was created — the state machine
--     anticipated this) AND the policy re-checks are_users_blocked(), so the
--     read gate holds even if some future path recreates a connection.
--   * block "reason" lives in `reports` (target_type='profile'), not as a
--     column here — a reasoned block is a block plus a report, and both are
--     reward-function signals (§4). No schema change needed for that.
-- ============================================================================

-- 1. Severing trigger — mirrors remove_follows_on_block (20250111000000).
--    SECURITY DEFINER + pinned search_path per H.5 (20260708091000).
CREATE OR REPLACE FUNCTION public.sever_connections_on_block()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.connections
     SET status = 'blocked',
         updated_at = now()
   WHERE status IN ('pending', 'accepted')
     AND (
       (requester_id = NEW.blocker_id AND recipient_id = NEW.blocked_id) OR
       (requester_id = NEW.blocked_id AND recipient_id = NEW.blocker_id)
     );
  RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.sever_connections_on_block() FROM anon, authenticated, public;

DROP TRIGGER IF EXISTS trg_block_sever_connections ON public.blocks;
CREATE TRIGGER trg_block_sever_connections
  AFTER INSERT ON public.blocks
  FOR EACH ROW EXECUTE FUNCTION public.sever_connections_on_block();

-- 2. The connected-path policy re-checks the block list.
--    Recreated verbatim from 20260401150000 plus the block clause.
DROP POLICY IF EXISTS profiles_read_connected ON public.profiles;
CREATE POLICY profiles_read_connected ON public.profiles
  FOR SELECT
  USING (
    auth.uid() != id
    AND has_active_connection(auth.uid(), id)
    AND NOT are_users_blocked(auth.uid(), id)
  );
COMMENT ON POLICY profiles_read_connected ON public.profiles IS
  'Connected users can read each other — unless either has blocked the other (Story 0.6).';

-- 3. Explicit grants (CI-hermeticity, same lesson as 20260717090000): prod
--    holds these via platform bootstrap defaults; the ephemeral CI stack does
--    not, and the pgTAP for this migration does direct DML as authenticated.
--    Additive-only — a strict no-op on prod. RLS remains the row gate
--    ("blocks: owner all"; connections_read_own).
grant insert, select, delete on public.blocks to authenticated;
grant select on public.connections to authenticated;
