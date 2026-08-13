-- Migration: 20260813000000_pin_search_path_all_secdef.sql
-- Purpose: Pin search_path = public on all SECURITY DEFINER functions.
--
-- The audit (2026-08-12, P2) found 44 functions with mutable search_path.
-- Migration 20260708091000 hardened the Phase A set; this covers the rest.
-- Refs: PHASE_H_HARDENING.md Story H.5 box 1.

ALTER FUNCTION public.acknowledge_sos_alert(p_alert_id uuid, p_contact_id uuid) SET search_path = public;
ALTER FUNCTION public.are_users_blocked(user_a uuid, user_b uuid) SET search_path = public;
ALTER FUNCTION public.auth_user_verification_tier() SET search_path = public;
ALTER FUNCTION public.caller_trip_overlaps(check_user uuid, range_start timestamp with time zone, range_end timestamp with time zone) SET search_path = public;
ALTER FUNCTION public.cancel_meetup(p_meetup_id uuid) SET search_path = public;
ALTER FUNCTION public.cancel_sos_alert(p_alert_id uuid) SET search_path = public;
ALTER FUNCTION public.clear_typing_indicator(p_chat_id text, p_user_id uuid) SET search_path = public;
ALTER FUNCTION public.complete_meetup(p_meetup_id uuid) SET search_path = public;
ALTER FUNCTION public.create_default_content_privacy() SET search_path = public;
ALTER FUNCTION public.create_default_privacy() SET search_path = public;
ALTER FUNCTION public.create_default_verification() SET search_path = public;
ALTER FUNCTION public.fanout_post_to_feeds(p_journal_id uuid, p_author_id uuid) SET search_path = public;
ALTER FUNCTION public.find_semantic_matches(p_query_user_id uuid, p_match_threshold double precision, p_max_results integer) SET search_path = public;
ALTER FUNCTION public.get_active_sos_alert(p_user_id uuid) SET search_path = public;
ALTER FUNCTION public.get_destination_posts(p_lat double precision, p_lon double precision, p_radius_km double precision, p_limit integer, p_before timestamp with time zone) SET search_path = public;
ALTER FUNCTION public.get_profile_embedding(p_user_id uuid) SET search_path = public;
ALTER FUNCTION public.get_profile_safe(p_username text) SET search_path = public;
ALTER FUNCTION public.get_typing_users(p_chat_id text) SET search_path = public;
ALTER FUNCTION public.get_unread_message_count() SET search_path = public;
ALTER FUNCTION public.get_unread_notification_count() SET search_path = public;
ALTER FUNCTION public.get_user_feed(p_limit integer, p_before timestamp with time zone) SET search_path = public;
ALTER FUNCTION public.is_share_recipient(contact_row_ids uuid[], reader uuid) SET search_path = public;
ALTER FUNCTION public.is_verified_female(check_user uuid) SET search_path = public;
ALTER FUNCTION public.notify_new_match() SET search_path = public;
ALTER FUNCTION public.propose_meetup(p_connection_id uuid, p_meetup_time timestamp with time zone, p_location_name text) SET search_path = public;
ALTER FUNCTION public.remove_follows_on_block() SET search_path = public;
ALTER FUNCTION public.report_no_show(p_meetup_id uuid) SET search_path = public;
ALTER FUNCTION public.reputation_score(p_user_id uuid) SET search_path = public;
ALTER FUNCTION public.resolve_sos_alert(p_alert_id uuid) SET search_path = public;
ALTER FUNCTION public.respond_meetup(p_meetup_id uuid, p_accept boolean) SET search_path = public;
ALTER FUNCTION public.search_profiles(p_query text, p_country text, p_verified_only boolean, p_limit integer, p_offset integer) SET search_path = public;
ALTER FUNCTION public.set_typing_indicator(p_chat_id text, p_user_id uuid) SET search_path = public;
ALTER FUNCTION public.sever_connections_on_block() SET search_path = public;
ALTER FUNCTION public.submit_review(p_meetup_id uuid, p_rating smallint, p_would_meet_again boolean, p_content text) SET search_path = public;
ALTER FUNCTION public.sync_comment_count() SET search_path = public;
ALTER FUNCTION public.sync_reaction_count() SET search_path = public;
ALTER FUNCTION public.trigger_notify_new_message() SET search_path = public;
ALTER FUNCTION public.trigger_sos(p_user_id uuid, p_latitude double precision, p_longitude double precision, p_accuracy double precision, p_altitude double precision, p_address text, p_message text, p_battery_level integer, p_trip_id uuid) SET search_path = public;
ALTER FUNCTION public.users_are_blocked(user_a uuid, user_b uuid) SET search_path = public;
ALTER FUNCTION public.users_have_trip_overlap(user_a uuid, user_b uuid) SET search_path = public;
ALTER FUNCTION public.viewer_follows(p_viewer uuid, p_target uuid) SET search_path = public;
ALTER FUNCTION public.wants_women_only(check_user uuid) SET search_path = public;
