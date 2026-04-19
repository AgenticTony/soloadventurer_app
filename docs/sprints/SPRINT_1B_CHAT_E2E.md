# Sprint 1b: Chat Working End-to-End
**Duration:** Week 2
**Theme:** The core value prop works. Two users can match and chat.
**Depends on:** Sprint 1a

## Tasks

### 1b.1 Fix ChatScreen current user + send logic
- [x] Get current user ID from `ref.watch(authProvider)` in `chat_screen.dart`
- [x] Replace `index % 2 == 0` with `message.senderId == currentUserId`
- [x] Wire send button `onPressed` to `ref.read(chatProvider.notifier).sendMessage()`
- [x] Clear text field after send, scroll to bottom
- [x] Fix chat title to show matched user's name via `chatForConnectionProvider`
- [x] **Test:** message senderId determines isCurrentUser correctly
- [x] **Test:** AuthState.authenticated provides user.id

### 1b.2 Replace in-memory message cache with real Supabase queries
- [x] `getMessages()` → delegate to `_remoteDataSource.getMessages(chatId)` when online
- [x] `watchMessages()` → delegate to `_remoteDataSource.watchMessages(chatId)` when online, fallback to polling when offline
- [x] `getChats()` → always try remote first when online (not just when cache empty)
- [x] `markMessagesAsRead()` → already calls remote, kept local cache update
- [x] Keep `_messageCache` as optimistic local cache for offline support
- [x] **Test:** getMessages returns messages from remote
- [x] **Test:** watchMessages returns a stream
- [x] **Test:** markMessagesAsRead calls remote when online
- [x] **Test:** sendMessage persists to remote
- [x] **Test:** sendMessage throws when offline

### 1b.3 Wire ConnectionProvider accept/decline/block
- [x] ConnectionNotifier already has accept/decline/block methods
- [x] Methods delegate to repository via `hideConnection()` for decline/block
- [x] Provider invalidation refreshes UI after status change
- [x] **Test:** matchingRepositoryProvider resolves with fake repository

### 1b.4 Replace `Stream.periodic` with Realtime stream
- [x] `watchMessages()` in repository → delegates to `_remoteDataSource.watchMessages()` when online
- [x] Remote data source already has Supabase Realtime subscription
- [x] Fallback: `Stream.periodic` only used when offline
- [x] **Test:** watchMessages returns a stream of messages (covered in 1b.2)

### 1b.5 Chat screen loading/error/empty states
- [x] Loading: `CircularProgressIndicator` via `messagesAsync.when(loading:)`
- [x] Error: Text error display via `messagesAsync.when(error:)`
- [x] Empty: "No messages yet. Start the conversation!" with chat icon
- [x] **Test:** Empty messages returns empty state
- [x] **Test:** Messages with data returns populated list
- [x] **Test:** Messages from different chats are separated

### 1b.6 Profile basics: edit bio, upload photo
- [x] Edit profile screen saves bio to Supabase profiles table
- [x] Photo upload uses Supabase Storage (already in profile repository)
- [x] **Test:** Profile update test
- [x] **Test:** Photo upload test

## Definition of Done
- [x] Messages are sent/received with real user IDs
- [x] Repository delegates to remote data source when online
- [x] Connection accept/decline/block methods exist
- [x] Realtime streaming via Supabase when online
- [x] Chat screen handles all 3 states (loading/error/empty)
- [x] All tests pass: `flutter test`
- [ ] **Manual QA:** Full flow on two devices
- [x] **Analytics:** Track signup→match→chat funnel events

## Verification
```bash
flutter analyze
flutter test test/app/sprint_1a_di_test.dart test/app/sprint_1a_router_test.dart test/core/services/analytics_service_test.dart test/app/sprint_1b_chat_e2e_test.dart test/features/matching/presentation/matches_screen_test.dart
# Manual: two test accounts, full chat flow
```
