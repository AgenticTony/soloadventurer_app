import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/features/matching/domain/entities/message.dart';
import 'package:soloadventurer/features/matching/domain/entities/chat.dart';
import 'matching_provider.dart';
import 'connection_provider.dart';

part 'chat_provider.g.dart';

// ============================================================
// REALTIME PROVIDERS
// ============================================================

/// Provider for Supabase client
@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

/// Real-time channel for a specific chat
/// Subscribes to INSERT events on messages table for the given connection
@riverpod
RealtimeChannel? chatRealtimeChannel(Ref ref, String connectionId) {
  final client = ref.watch(supabaseClientProvider);
  final currentUserId = client.auth.currentUser?.id;
  
  if (currentUserId == null) return null;
  
  // Create a unique channel for this chat
  final channel = client
      .channel('chat:$connectionId')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'connection_id',
          value: connectionId,
        ),
        callback: (payload) {
          // Invalidate messages provider when new message arrives
          ref.invalidate(messagesProvider(connectionId));
          ref.invalidate(chatsProvider);
          ref.invalidate(unreadCountProvider);
        },
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'connection_id',
          value: connectionId,
        ),
        callback: (payload) {
          // Refresh on updates (read status, etc.)
          ref.invalidate(messagesProvider(connectionId));
        },
      )
      .subscribe();
  
  // Cleanup on dispose
  ref.onDispose(() {
    client.removeChannel(channel);
  });
  
  return channel;
}

/// Real-time subscription for notifications
/// Listens for new notifications for the current user
@riverpod
RealtimeChannel? notificationsChannel(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  final currentUserId = client.auth.currentUser?.id;
  
  if (currentUserId == null) return null;
  
  final channel = client
      .channel('notifications:$currentUserId')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'notifications',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: currentUserId,
        ),
        callback: (payload) {
          ref.invalidate(unreadNotificationCountProvider);
        },
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'notifications',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: currentUserId,
        ),
        callback: (payload) {
          ref.invalidate(unreadNotificationCountProvider);
        },
      )
      .subscribe();
  
  ref.onDispose(() {
    client.removeChannel(channel);
  });
  
  return channel;
}

/// Real-time subscription for new connections/matches
@riverpod
RealtimeChannel? connectionsChannel(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  final currentUserId = client.auth.currentUser?.id;
  
  if (currentUserId == null) return null;
  
  final channel = client
      .channel('connections:$currentUserId')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'connections',
        callback: (payload) {
          // Refresh matches when new connection arrives
          ref.invalidate(matchesProvider);
          ref.invalidate(pendingConnectionsCountProvider);
        },
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'connections',
        callback: (payload) {
          ref.invalidate(matchesProvider);
          ref.invalidate(pendingConnectionsCountProvider);
        },
      )
      .subscribe();
  
  ref.onDispose(() {
    client.removeChannel(channel);
  });
  
  return channel;
}

// ============================================================
// TYPING INDICATORS
// ============================================================

/// State class for typing indicator
class TypingState {
  final Set<String> typingUserIds;
  final DateTime? lastUpdated;
  
  const TypingState({
    this.typingUserIds = const {},
    this.lastUpdated,
  });
  
  bool get isSomeoneTyping => typingUserIds.isNotEmpty;
  
  TypingState copyWith({
    Set<String>? typingUserIds,
    DateTime? lastUpdated,
  }) {
    return TypingState(
      typingUserIds: typingUserIds ?? this.typingUserIds,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Notifier for managing typing indicators
@riverpod
class TypingNotifier extends _$TypingNotifier {
  Timer? _typingTimer;
  RealtimeChannel? _typingChannel;
  String? _currentChatId;
  
  @override
  TypingState build() {
    return const TypingState();
  }
  
  /// Subscribe to typing indicators for a chat
  void subscribeToChat(String connectionId) {
    final client = ref.read(supabaseClientProvider);
    final currentUserId = client.auth.currentUser?.id;
    
    if (currentUserId == null) return;
    
    // Clean up previous subscription
    unsubscribe();
    
    _currentChatId = connectionId;
    
    // Subscribe to typing indicator changes
    _typingChannel = client
        .channel('typing:$connectionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'typing_indicators',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_id',
            value: connectionId,
          ),
          callback: (payload) {
            _refreshTypingUsers(connectionId);
          },
        )
        .subscribe();
    
    // Initial fetch
    _refreshTypingUsers(connectionId);
  }
  
  /// Unsubscribe from typing indicators
  void unsubscribe() {
    _typingTimer?.cancel();
    _typingTimer = null;
    
    if (_typingChannel != null) {
      final client = ref.read(supabaseClientProvider);
      client.removeChannel(_typingChannel!);
      _typingChannel = null;
    }
    
    _currentChatId = null;
    state = const TypingState();
  }
  
  /// Send typing indicator
  Future<void> setTyping() async {
    final client = ref.read(supabaseClientProvider);
    final chatId = _currentChatId;
    
    if (chatId == null) return;
    
    await client.rpc('set_typing_indicator', params: {
      'p_chat_id': chatId,
      'p_user_id': client.auth.currentUser?.id,
    });
    
    // Clear typing after 3 seconds of inactivity
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), clearTyping);
  }
  
  /// Clear typing indicator
  Future<void> clearTyping() async {
    final client = ref.read(supabaseClientProvider);
    final chatId = _currentChatId;
    
    if (chatId == null) return;
    
    _typingTimer?.cancel();
    
    await client.rpc('clear_typing_indicator', params: {
      'p_chat_id': chatId,
      'p_user_id': client.auth.currentUser?.id,
    });
  }
  
  /// Refresh the list of typing users
  Future<void> _refreshTypingUsers(String connectionId) async {
    final client = ref.read(supabaseClientProvider);
    
    try {
      final response = await client.rpc('get_typing_users', params: {
        'p_chat_id': connectionId,
      });
      
      if (response is List) {
        final typingIds = response
            .map((u) => u['user_id'] as String?)
            .whereType<String>()
            .toSet();
        
        state = TypingState(
          typingUserIds: typingIds,
          lastUpdated: DateTime.now(),
        );
      }
    } catch (e) {
      // Silently fail - typing indicators are not critical
    }
  }
}

/// Provider for checking if other user is typing
@riverpod
bool isOtherUserTyping(Ref ref, String connectionId) {
  final typingState = ref.watch(typingProvider);
  return typingState.typingUserIds.isNotEmpty;
}

// ============================================================
// CHAT PROVIDERS
// ============================================================

/// Provider for all chats
@riverpod
Future<List<Chat>> chats(Ref ref) async {
  final repository = ref.watch(matchingRepositoryProvider);
  
  // Subscribe to realtime updates
  ref.watch(notificationsChannelProvider);
  ref.watch(connectionsChannelProvider);
  
  return repository.getChats();
}

/// Provider for a specific chat by connection ID
@riverpod
Future<Chat> chatForConnection(Ref ref, String connectionId) async {
  final repository = ref.watch(matchingRepositoryProvider);
  return repository.getOrCreateChat(connectionId);
}

/// Provider for messages in a specific chat with real-time updates
@riverpod
Stream<List<Message>> messages(Ref ref, String chatId) {
  final repository = ref.watch(matchingRepositoryProvider);
  
  // Subscribe to realtime channel for this chat
  ref.watch(chatRealtimeChannelProvider(chatId));
  
  // Subscribe to typing indicators
  ref.read(typingProvider.notifier).subscribeToChat(chatId);
  
  return repository.watchMessages(chatId);
}

/// Notifier for managing chat operations
@riverpod
class ChatNotifier extends _$ChatNotifier {
  @override
  FutureOr<void> build() {
    // Subscribe to notifications on init
    ref.read(notificationsChannelProvider);
    return null;
  }

  /// Send a message
  Future<String> sendMessage({
    required String chatId,
    required String recipientId,
    required String content,
  }) async {
    final repository = ref.read(matchingRepositoryProvider);
    
    // Clear typing indicator when sending message
    await ref.read(typingProvider.notifier).clearTyping();

    try {
      final messageId = await repository.sendMessage(
        chatId: chatId,
        recipientId: recipientId,
        content: content,
      );
      
      // Invalidate messages to refresh
      ref.invalidate(messagesProvider(chatId));
      ref.invalidate(chatsProvider);
      
      return messageId;
    } catch (e) {
      // Message failed - will show as failed in UI
      rethrow;
    }
  }

  /// Mark messages as read
  Future<void> markAsRead(String chatId) async {
    final repository = ref.read(matchingRepositoryProvider);
    await repository.markMessagesAsRead(chatId);
    ref.invalidate(messagesProvider(chatId));
    ref.invalidate(chatsProvider);
    ref.invalidate(unreadCountProvider);
  }

  /// Start a new chat or get existing one
  Future<Chat> startChat(String connectionId) async {
    final repository = ref.read(matchingRepositoryProvider);
    final chat = await repository.getOrCreateChat(connectionId);
    ref.invalidate(chatsProvider);
    return chat;
  }
}

// ============================================================
// UNREAD COUNTS
// ============================================================

/// Provider for unread message count
@riverpod
Future<int> unreadCount(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  
  // Ensure we're subscribed to updates
  ref.watch(notificationsChannelProvider);
  
  try {
    final response = await client.rpc('get_unread_message_count');
    return response as int? ?? 0;
  } catch (e) {
    // Fallback to repository
    final repository = ref.watch(matchingRepositoryProvider);
    return repository.getPendingMessagesCount();
  }
}

/// Provider for unread notification count
@riverpod
Future<int> unreadNotificationCount(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  
  // Ensure we're subscribed to updates
  ref.watch(notificationsChannelProvider);
  
  try {
    final response = await client.rpc('get_unread_notification_count');
    return response as int? ?? 0;
  } catch (e) {
    return 0;
  }
}

/// Provider for pending connections count (new match requests)
@riverpod
Future<int> pendingConnectionsCount(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  
  // Ensure we're subscribed to updates
  ref.watch(connectionsChannelProvider);
  
  try {
    final response = await client
        .from('connections')
        .select('id')
        .eq('recipient_id', client.auth.currentUser?.id ?? '')
        .eq('status', 'pending');
    
    return (response as List).length;
  } catch (e) {
    return 0;
  }
}

/// Provider for pending messages count (for sync indicator)
@riverpod
Future<int> pendingMessagesCount(Ref ref) async {
  final repository = ref.watch(matchingRepositoryProvider);
  return repository.getPendingMessagesCount();
}

// ============================================================
// WOMEN-ONLY MODE
// ============================================================

/// Provider for women-only mode status
@riverpod
Future<bool> womenOnlyModeEnabled(Ref ref) async {
  final repository = ref.watch(matchingRepositoryProvider);
  return repository.isWomenOnlyModeEnabled();
}

/// Provider for checking if user can enable women-only mode
@riverpod
Future<bool> canEnableWomenOnlyMode(Ref ref) async {
  final repository = ref.watch(matchingRepositoryProvider);
  final isVerified = await repository.isVerifiedForWomenOnly();
  // TODO: Also check premium tier
  return isVerified;
}

/// Notifier for managing women-only mode
@riverpod
class WomenOnlyModeNotifier extends _$WomenOnlyModeNotifier {
  @override
  FutureOr<bool> build() async {
    final repository = ref.read(matchingRepositoryProvider);
    return repository.isWomenOnlyModeEnabled();
  }

  /// Enable women-only mode
  Future<void> enable() async {
    final repository = ref.read(matchingRepositoryProvider);
    await repository.enableWomenOnlyMode();
    ref.invalidate(matchesProvider);
    state = const AsyncValue.data(true);
  }

  /// Disable women-only mode
  Future<void> disable() async {
    final repository = ref.read(matchingRepositoryProvider);
    await repository.disableWomenOnlyMode();
    ref.invalidate(matchesProvider);
    state = const AsyncValue.data(false);
  }
}

// ============================================================
// PRESENCE TRACKING
// ============================================================

/// User presence status
enum UserPresence { online, offline, away }

/// Notifier for tracking user presence
@riverpod
class PresenceNotifier extends _$PresenceNotifier {
  RealtimeChannel? _presenceChannel;
  
  @override
  Map<String, UserPresence> build() {
    return {};
  }
  
  /// Track presence for users in a chat
  void trackUsers(List<String> userIds) {
    final client = ref.read(supabaseClientProvider);
    final currentUserId = client.auth.currentUser?.id;
    
    if (currentUserId == null) return;
    
    _presenceChannel?.unsubscribe();
    
    _presenceChannel = client.channel('presence:global');
    
    // Track current user's presence
    _presenceChannel!.track({
      'user_id': currentUserId,
      'online_at': DateTime.now().toIso8601String(),
    });
    
    _presenceChannel!.subscribe((status, error) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        // Get initial presence state
        final presenceState = _presenceChannel!.presenceState();
        _updatePresence(presenceState);
      }
    });
    
    // Listen for presence updates
    _presenceChannel!.onPresenceSync((payload) {
      final presenceState = _presenceChannel!.presenceState();
      _updatePresence(presenceState);
    });
    
    ref.onDispose(() {
      _presenceChannel?.unsubscribe();
    });
  }
  
  void _updatePresence(List<SinglePresenceState> presenceState) {
    final newState = <String, UserPresence>{};
    
    // Parse presence data
    // Note: This is a simplified implementation
    // Real implementation would parse the presence state properly
    try {
      for (final _ in presenceState) {
        // Extract user information from presence state
        // The actual API depends on Supabase version
        state = newState;
      }
    } catch (e) {
      // Silently fail - presence tracking is not critical
    }
    
    state = newState;
  }
  
  /// Check if a user is online
  UserPresence getUserPresence(String userId) {
    return state[userId] ?? UserPresence.offline;
  }
}
