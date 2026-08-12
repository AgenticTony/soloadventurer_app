-- Migration: 20260812030000_revoke_anon_secdef.sql
-- Purpose: Revoke EXECUTE from anon on SECURITY DEFINER functions.
--
-- The audit (2026-08-12, P2) found 17 SECURITY DEFINER functions callable
-- by anon. The most critical are the 4 SOS lifecycle verbs.
-- PostGIS functions (st_estimatedextent) are excluded — system internals.
--
-- Refs: Full audit 2026-08-12, Section 03, P2 finding.

-- ── SOS lifecycle verbs (safety-critical) ─────────────────────────────────
REVOKE EXECUTE ON FUNCTION public.trigger_sos(p_user_id uuid, p_latitude double precision, p_longitude double precision, p_accuracy double precision, p_altitude double precision, p_address text, p_message text, p_battery_level integer, p_trip_id uuid) FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.get_active_sos_alert(p_user_id uuid) FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.resolve_sos_alert(p_alert_id uuid) FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.acknowledge_sos_alert(p_alert_id uuid, p_contact_id uuid) FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.cancel_sos_alert(p_alert_id uuid) FROM anon, public;

-- ── Messaging / typing indicators ─────────────────────────────────────────
REVOKE EXECUTE ON FUNCTION public.clear_typing_indicator(p_chat_id text, p_user_id uuid) FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.get_typing_users(p_chat_id text) FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.set_typing_indicator(p_chat_id text, p_user_id uuid) FROM anon, public;

-- ── Notification counts ───────────────────────────────────────────────────
REVOKE EXECUTE ON FUNCTION public.get_unread_message_count() FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.get_unread_notification_count() FROM anon, public;

-- ── Match notification ────────────────────────────────────────────────────
REVOKE EXECUTE ON FUNCTION public.notify_new_match() FROM anon, public;

-- ── Reaction sync ─────────────────────────────────────────────────────────
REVOKE EXECUTE ON FUNCTION public.sync_reaction_count() FROM anon, public;

-- ── Default record creators (called by triggers, not direct) ──────────────
REVOKE EXECUTE ON FUNCTION public.create_default_content_privacy() FROM anon, public;
REVOKE EXECUTE ON FUNCTION public.create_default_verification() FROM anon, public;

-- ── Ensure authenticated retains access ──────────────────────────────────
GRANT EXECUTE ON FUNCTION public.trigger_sos(p_user_id uuid, p_latitude double precision, p_longitude double precision, p_accuracy double precision, p_altitude double precision, p_address text, p_message text, p_battery_level integer, p_trip_id uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_active_sos_alert(p_user_id uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.resolve_sos_alert(p_alert_id uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.acknowledge_sos_alert(p_alert_id uuid, p_contact_id uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.cancel_sos_alert(p_alert_id uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.clear_typing_indicator(p_chat_id text, p_user_id uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_typing_users(p_chat_id text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.set_typing_indicator(p_chat_id text, p_user_id uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_unread_message_count() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_unread_notification_count() TO authenticated;
GRANT EXECUTE ON FUNCTION public.notify_new_match() TO authenticated;
GRANT EXECUTE ON FUNCTION public.sync_reaction_count() TO authenticated;
