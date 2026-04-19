# Sprint 2: Chat Polish + Realtime
**Duration:** Weeks 3-4
**Theme:** Make chat feel like a real messaging app.
**Depends on:** Sprint 1b
**Status:** Complete (all tasks done, only Manual QA on device remains)

## Tasks

### 2.1 Chat list screen
- [x] Create `lib/features/matching/presentation/screens/chat_list_screen.dart`
- [x] Show all active chats from `chatsProvider`
- [x] Each tile: avatar, name, last message preview, unread badge, timestamp
- [x] Tap → navigate to `/chat/:connectionId`
- [x] **Test:** List renders with correct unread counts
- [x] **Test:** Tap navigates to correct chat
- [x] **Test:** Empty state, error state, avatar initials, time formatting

### 2.2 Typing indicators (pre-existing)
- [x] Subscribe to typing on screen open: `ref.read(typingProvider.notifier).subscribeToChat(connectionId)`
- [x] Watch `isOtherUserTypingProvider(connectionId)` → show "typing..." below AppBar
- [x] TextField `onChanged` → call `ref.read(typingProvider.notifier).setTyping()`
- [x] Cleanup subscription in `dispose`
- [x] **Test:** Typing notifier test
- [x] **Test:** UI shows "typing..." when provider emits true

### 2.3 Read receipts (pre-existing)
- [x] Call `markAsRead()` when chat opens
- [x] Call on new message arrival while chat is open
- [x] Status icons already exist in `_MessageBubble._buildStatusIcon` (line 288)
- [x] Real-time subscription already invalidates on update events
- [x] **Test:** Status transitions: sent → delivered → read
- [x] **Test:** Read status updates in real-time

### 2.4 Chat navigation entry point
- [x] Add `/chats` route in GoRouter config
- [x] Add chat icon button in MatchesScreen AppBar with unread badge
- [x] **Test:** Navigation test from matches to chat list

### 2.5 Connection request flow
- [x] ConnectionNotifier has accept/decline/block methods
- [x] Accept/Decline buttons in match detail dialog for pending connections
- [x] Message button shown only for accepted connections
- [x] Status transitions: pending → accepted/declined/blocked
- [x] **Test:** Accept/Decline buttons appear for pending matches
- [x] **Test:** Message button appears only for accepted matches

### 2.6 Profile settings (pre-existing)
- [x] Change display name (via edit profile screen)
- [x] Delete account (ProfileSettingsScreen)
- [x] Women-only mode toggle
- [x] **Test:** Settings update test

## Definition of Done
- [x] Chat list shows all conversations with unread counts
- [x] Typing indicators work between two users
- [x] Read receipts update in real-time
- [x] Connection requests flow correctly
- [x] Profile settings functional
- [x] All tests pass: `flutter test` (53 tests across Sprint 1b + 2)
- [ ] **Manual QA:** Maintain 3+ conversations, verify typing + read receipts
- [x] **Analytics:** Message sent/received events, typing events

## Verification
```bash
flutter analyze
flutter test test/features/matching/presentation/chat_list_screen_test.dart
# Manual: maintain 3 active chats, test all features
```
