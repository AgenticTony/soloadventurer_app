// ============================================================
// SoloAdventurer — Edge Function: notify-new-message
//
// Triggered when a new message is inserted into the messages table.
// Looks up recipient's push tokens and sends a push notification.
//
// Called by: Database trigger on messages INSERT
// Deploy: supabase functions deploy notify-new-message
//
// Required DB trigger:
//   CREATE OR REPLACE FUNCTION trigger_notify_new_message()
//   RETURNS trigger AS $$
//   BEGIN
//     PERFORM net.http_post(
//       url := '${SUPABASE_URL}/functions/v1/notify-new-message',
//       headers := jsonb_build_object(
//         'Content-Type', 'application/json',
//         'Authorization', 'Bearer ' || current_setting('app.service_role_key')
//       ),
//       body := json_build_object('record', row_to_json(NEW))
//     );
//     RETURN NEW;
//   END;
//   $$ LANGUAGE plpgsql SECURITY DEFINER;
//
//   CREATE TRIGGER on_new_message
//     AFTER INSERT ON messages
//     FOR EACH ROW EXECUTE FUNCTION trigger_notify_new_message();
// ============================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

interface MessageRecord {
  id: string;
  chat_id: string;
  sender_id: string;
  content: string;
  message_type?: string;
  created_at: string;
}

interface Profile {
  id: string;
  first_name: string | null;
}

interface ChatMember {
  user_id: string;
}

Deno.serve(async (req: Request) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers":
          "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    const body = await req.json();

    // Support both webhook payload (from DB trigger) and direct invocation
    const message: MessageRecord = body.record || body.message || body;

    console.log("[notify-new-message] Processing message:", message.id);

    if (!message.chat_id || !message.sender_id) {
      return new Response(JSON.stringify({ error: "Missing message data" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Get sender profile for notification content
    const { data: senderProfile } = await supabase
      .from("profiles")
      .select("id, first_name")
      .eq("id", message.sender_id)
      .single();

    const senderName = senderProfile?.first_name || "Someone";

    // Get chat members to find the recipient
    // Chat members are stored in the chat record or a junction table
    const { data: chat } = await supabase
      .from("chats")
      .select(
        "id, connection_id, connections!inner(requester_id, recipient_id)",
      )
      .eq("id", message.chat_id)
      .single();

    if (!chat) {
      console.warn("[notify-new-message] Chat not found:", message.chat_id);
      return new Response(JSON.stringify({ error: "Chat not found" }), {
        status: 404,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Determine the recipient (the other person in the chat)
    const connection = chat.connections as unknown as {
      requester_id: string;
      recipient_id: string;
    };
    const recipientId =
      message.sender_id === connection.requester_id
        ? connection.recipient_id
        : connection.requester_id;

    if (!recipientId) {
      return new Response(
        JSON.stringify({ error: "Could not determine recipient" }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    // Truncate message content for notification preview
    const preview =
      message.content.length > 80
        ? message.content.substring(0, 80) + "..."
        : message.content;

    // Create in-app notification
    const { error: notifError } = await supabase.from("notifications").insert({
      user_id: recipientId,
      type: "new_message",
      actor_id: message.sender_id,
      object_id: message.chat_id,
      object_type: "message",
      body: `${senderName}: ${preview}`,
      read: false,
    });

    if (notifError) {
      console.error(
        "[notify-new-message] Error creating notification:",
        notifError,
      );
    }

    // Get recipient's push tokens
    const { data: tokens, error: tokensError } = await supabase
      .from("notification_tokens")
      .select("token, platform")
      .eq("user_id", recipientId)
      .eq("is_active", true);

    if (tokensError) {
      console.error("[notify-new-message] Error fetching tokens:", tokensError);
    }

    // Send push notifications
    if (tokens && tokens.length > 0) {
      console.log(
        `[notify-new-message] Sending push to ${tokens.length} devices`,
      );

      const pushResponse = await fetch(
        `${Deno.env.get("SUPABASE_URL")}/functions/v1/send-push-notification`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
          },
          body: JSON.stringify({
            tokens,
            notification: {
              title: senderName,
              body: preview,
              data: {
                type: "new_message",
                chatId: message.chat_id,
                senderId: message.sender_id,
                messageId: message.id,
              },
            },
          }),
        },
      );

      if (!pushResponse.ok) {
        console.error(
          "[notify-new-message] Push failed:",
          await pushResponse.text(),
        );
      }
    } else {
      console.log(
        "[notify-new-message] No push tokens for recipient, skipping push",
      );
    }

    return new Response(
      JSON.stringify({
        success: true,
        push_sent: tokens && tokens.length > 0,
      }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      },
    );
  } catch (err) {
    console.error("[notify-new-message] Unhandled error:", err);
    return new Response(
      JSON.stringify({
        error: "Internal server error",
        details: err instanceof Error ? err.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      },
    );
  }
});
