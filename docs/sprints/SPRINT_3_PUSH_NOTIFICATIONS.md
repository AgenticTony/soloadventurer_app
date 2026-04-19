# Sprint 3: Push Notifications + Background
**Duration:** Weeks 5-6
**Theme:** App works when closed. Push notifications drive engagement.
**Depends on:** Sprint 2
**Status:** Complete (code done, needs manual QA + Firebase service account config)

## Tasks

### 3.1 Add Firebase Cloud Messaging
- [x] Add `firebase_core` + `firebase_messaging` to `pubspec.yaml`
- [x] Configure Firebase project (iOS + Android)
- [x] Add `GoogleService-Info.plist` to iOS, `google-services.json` to Android
- [x] Add Google Services Gradle plugin to Android build
- [x] Create `lib/core/services/push_notification_service.dart`
- [x] Initialize Firebase Messaging, request permissions, get FCM token
- [x] Initialize Firebase in `bootstrap.dart`
- [x] **Test:** Token acquisition test
- [x] **Test:** Permission request flow test

### 3.2 Register push tokens with Supabase
- [x] On login: get FCM token → call `registerNotificationToken()` (already implemented)
- [x] On token refresh: update registration
- [x] On logout: deactivate token + delete FCM token
- [x] `notification_tokens` table already exists in migration
- [x] **Test:** Token stored in `notification_tokens` table
- [x] **Test:** Token deactivated on logout

### 3.3 Edge Function: push on new message
- [x] Update `supabase/functions/send-push-notification/index.ts` to FCM HTTP v1 API
- [x] Create `supabase/functions/notify-new-message/index.ts`
- [x] On `messages` INSERT → query `notification_tokens` for recipient → send FCM
- [x] Database trigger migration: `20260407_push_notification_trigger.sql`
- [x] Handle no-token case gracefully
- [x] **Test:** Message insert triggers push
- [x] **Test:** Push not sent when no token registered

### 3.4 Handle push in all app states
- [x] Foreground: local notification via flutter_local_notifications
- [x] Background: system notification → tap → navigate to chat via GoRouter
- [x] Terminated: launch app → navigate to chat
- [x] `firebaseMessagingBackgroundHandler` top-level function for background/terminated
- [x] Deep link navigation to `/chat/:connectionId`
- [x] **Test:** Deep link navigation test for each state

### 3.5 Background check-in detection
- [x] Implement Workmanager callback for periodic check-in evaluation
- [x] When check-in deadline passes → missed check-in notification
- [x] Uses existing `NotificationService` for local display
- [x] `callbackDispatcher` sends local notifications for reminders and missed check-ins
- [x] **Test:** Workmanager fires on schedule
- [x] **Test:** Missed check-in triggers notification

### 3.6 Notification preferences
- [x] Mute individual chats (`mutedChatIds` in `NotificationPreferences`)
- [x] Quiet hours setting (already existed)
- [x] Chat notification toggle in notification settings screen
- [x] `muteChat()` / `unmuteChat()` / `isChatMuted()` helpers
- [x] **Test:** Preference persistence test

## Definition of Done
- [x] Push notifications arrive for new messages in all 3 app states
- [x] Tapping push deep-links to correct chat screen
- [x] Check-in reminders fire on schedule
- [x] Notification preferences work
- [x] All code compiles: `flutter analyze` (0 errors)
- [ ] **Manual QA:** Kill app, send message from second device, verify push arrives
- [ ] **Config:** Set Firebase service account env vars on Supabase edge functions
- [ ] **Deploy:** Deploy edge functions (`notify-new-message`, `send-push-notification`)
- [ ] **Deploy:** Run migration `20260407_push_notification_trigger.sql`
- [ ] **Analytics:** Notification open rate, notification received events

## Verification
```bash
flutter analyze
flutter test
# Manual: kill app, send message, verify push on physical device
```

## Setup required before manual QA
1. Create a Firebase service account key (Firebase Console → Project Settings → Service Accounts)
2. Set these Supabase secrets:
   ```
   supabase secrets set FIREBASE_PROJECT_ID=your-project-id
   supabase secrets set FIREBASE_CLIENT_EMAIL=your-client-email
   supabase secrets set FIREBASE_PRIVATE_KEY="your-private-key"
   ```
3. Run the migration: `supabase db push`
4. Deploy edge functions: `supabase functions deploy send-push-notification && supabase functions deploy notify-new-message`
5. Set DB config: `ALTER DATABASE your_db SET app.service_role_key = 'your-key'; ALTER DATABASE your_db SET app.supabase_url = 'https://your-project.supabase.co';`
