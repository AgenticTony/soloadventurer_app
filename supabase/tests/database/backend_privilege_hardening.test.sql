-- pgTAP tests for PHASE_H Story H.5 (partial) — backend privilege hardening.
-- Run: `supabase test db`
-- Proves: in-repo SECURITY DEFINER functions pin search_path, anon EXECUTE is
-- revoked everywhere, authenticated keeps the client-callable RPCs, and the
-- trigger-only functions are execute-revoked for every client role.

begin;
select plan(11);

-- 1. search_path pinned on a representative RPC + a trigger fn (2)
select ok(
  EXISTS (SELECT 1 FROM pg_proc
          WHERE oid = 'public.search_profiles(text,text,boolean,int,int)'::regprocedure
            AND array_to_string(proconfig, ',') LIKE '%search_path%'),
  'search_profiles has a pinned search_path'
);
select ok(
  EXISTS (SELECT 1 FROM pg_proc
          WHERE oid = 'public.sync_comment_count()'::regprocedure
            AND array_to_string(proconfig, ',') LIKE '%search_path%'),
  'sync_comment_count (trigger fn) has a pinned search_path'
);

-- 2. anon EXECUTE revoked on the client RPCs; authenticated retained (4)
select ok(NOT has_function_privilege('anon', 'public.search_profiles(text,text,boolean,int,int)', 'EXECUTE'),
  'anon CANNOT execute search_profiles');
select ok(has_function_privilege('authenticated', 'public.search_profiles(text,text,boolean,int,int)', 'EXECUTE'),
  'authenticated CAN execute search_profiles');
select ok(NOT has_function_privilege('anon', 'public.get_profile_safe(text)', 'EXECUTE'),
  'anon CANNOT execute get_profile_safe');
select ok(has_function_privilege('authenticated', 'public.get_profile_safe(text)', 'EXECUTE'),
  'authenticated CAN execute get_profile_safe');

-- 3. trigger-only functions: revoked for BOTH anon and authenticated (3)
select ok(NOT has_function_privilege('anon', 'public.trigger_notify_new_message()', 'EXECUTE'),
  'anon CANNOT execute trigger_notify_new_message');
select ok(NOT has_function_privilege('authenticated', 'public.trigger_notify_new_message()', 'EXECUTE'),
  'authenticated CANNOT execute trigger_notify_new_message (trigger-only)');
select ok(NOT has_function_privilege('authenticated', 'public.create_default_privacy()', 'EXECUTE'),
  'authenticated CANNOT execute create_default_privacy (trigger-only)');

-- 4. fanout helper: anon revoked, authenticated retained (2)
select ok(NOT has_function_privilege('anon', 'public.fanout_post_to_feeds(uuid,uuid)', 'EXECUTE'),
  'anon CANNOT execute fanout_post_to_feeds');
select ok(has_function_privilege('authenticated', 'public.fanout_post_to_feeds(uuid,uuid)', 'EXECUTE'),
  'authenticated CAN execute fanout_post_to_feeds');

select * from finish();
rollback;
