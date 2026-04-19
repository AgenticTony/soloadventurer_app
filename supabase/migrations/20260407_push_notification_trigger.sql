-- ============================================================
-- Migration: Push notification trigger on new messages
-- Sprint 3.3: Database trigger that calls notify-new-message
-- ============================================================

-- Helper function to call the notify-new-message edge function
CREATE OR REPLACE FUNCTION trigger_notify_new_message()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  service_role_key text;
  supabase_url text;
BEGIN
  service_role_key := current_setting('app.service_role_key', true);
  supabase_url := current_setting('app.supabase_url', true);

  -- Only fire if we have the required settings
  IF service_role_key IS NULL OR supabase_url IS NULL THEN
    RAISE NOTICE 'Push notification trigger: app.service_role_key or app.supabase_url not set';
    RETURN NEW;
  END IF;

  -- Call the edge function asynchronously
  PERFORM net.http_post(
    url := supabase_url || '/functions/v1/notify-new-message',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || service_role_key
    ),
    body := json_build_object('record', row_to_json(NEW))
  );

  RETURN NEW;
END;
$$;

-- Create the trigger on messages table
DROP TRIGGER IF EXISTS on_new_message ON messages;
CREATE TRIGGER on_new_message
  AFTER INSERT ON messages
  FOR EACH ROW EXECUTE FUNCTION trigger_notify_new_message();

-- Store config values (run these with appropriate secrets)
-- ALTER DATABASE your_db SET app.service_role_key = 'your-service-role-key';
-- ALTER DATABASE your_db SET app.supabase_url = 'https://your-project.supabase.co';
