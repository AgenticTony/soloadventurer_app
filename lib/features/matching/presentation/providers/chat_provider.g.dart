// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for Supabase client

@ProviderFor(supabaseClient)
const supabaseClientProvider = SupabaseClientProvider._();

/// Provider for Supabase client

final class SupabaseClientProvider
    extends $FunctionalProvider<SupabaseClient, SupabaseClient, SupabaseClient>
    with $Provider<SupabaseClient> {
  /// Provider for Supabase client
  const SupabaseClientProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'supabaseClientProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$supabaseClientHash();

  @$internal
  @override
  $ProviderElement<SupabaseClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseClient create(Ref ref) {
    return supabaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient>(value),
    );
  }
}

String _$supabaseClientHash() => r'834a58d6ae4b94e36f4e04a10d8a7684b929310e';

/// Real-time channel for a specific chat
/// Subscribes to INSERT events on messages table for the given connection

@ProviderFor(chatRealtimeChannel)
const chatRealtimeChannelProvider = ChatRealtimeChannelFamily._();

/// Real-time channel for a specific chat
/// Subscribes to INSERT events on messages table for the given connection

final class ChatRealtimeChannelProvider extends $FunctionalProvider<
    RealtimeChannel?,
    RealtimeChannel?,
    RealtimeChannel?> with $Provider<RealtimeChannel?> {
  /// Real-time channel for a specific chat
  /// Subscribes to INSERT events on messages table for the given connection
  const ChatRealtimeChannelProvider._(
      {required ChatRealtimeChannelFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'chatRealtimeChannelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$chatRealtimeChannelHash();

  @override
  String toString() {
    return r'chatRealtimeChannelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<RealtimeChannel?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RealtimeChannel? create(Ref ref) {
    final argument = this.argument as String;
    return chatRealtimeChannel(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RealtimeChannel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RealtimeChannel?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatRealtimeChannelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatRealtimeChannelHash() =>
    r'e749d7068e0d4a0966adc68c45bb77184f872aad';

/// Real-time channel for a specific chat
/// Subscribes to INSERT events on messages table for the given connection

final class ChatRealtimeChannelFamily extends $Family
    with $FunctionalFamilyOverride<RealtimeChannel?, String> {
  const ChatRealtimeChannelFamily._()
      : super(
          retry: null,
          name: r'chatRealtimeChannelProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Real-time channel for a specific chat
  /// Subscribes to INSERT events on messages table for the given connection

  ChatRealtimeChannelProvider call(
    String connectionId,
  ) =>
      ChatRealtimeChannelProvider._(argument: connectionId, from: this);

  @override
  String toString() => r'chatRealtimeChannelProvider';
}

/// Real-time subscription for notifications
/// Listens for new notifications for the current user

@ProviderFor(notificationsChannel)
const notificationsChannelProvider = NotificationsChannelProvider._();

/// Real-time subscription for notifications
/// Listens for new notifications for the current user

final class NotificationsChannelProvider extends $FunctionalProvider<
    RealtimeChannel?,
    RealtimeChannel?,
    RealtimeChannel?> with $Provider<RealtimeChannel?> {
  /// Real-time subscription for notifications
  /// Listens for new notifications for the current user
  const NotificationsChannelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationsChannelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationsChannelHash();

  @$internal
  @override
  $ProviderElement<RealtimeChannel?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RealtimeChannel? create(Ref ref) {
    return notificationsChannel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RealtimeChannel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RealtimeChannel?>(value),
    );
  }
}

String _$notificationsChannelHash() =>
    r'44feb80c2a8bf30cd9895aa8f51b4bb654806fac';

/// Real-time subscription for new connections/matches

@ProviderFor(connectionsChannel)
const connectionsChannelProvider = ConnectionsChannelProvider._();

/// Real-time subscription for new connections/matches

final class ConnectionsChannelProvider extends $FunctionalProvider<
    RealtimeChannel?,
    RealtimeChannel?,
    RealtimeChannel?> with $Provider<RealtimeChannel?> {
  /// Real-time subscription for new connections/matches
  const ConnectionsChannelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'connectionsChannelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$connectionsChannelHash();

  @$internal
  @override
  $ProviderElement<RealtimeChannel?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RealtimeChannel? create(Ref ref) {
    return connectionsChannel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RealtimeChannel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RealtimeChannel?>(value),
    );
  }
}

String _$connectionsChannelHash() =>
    r'e418d44cbeeb51b1ea527c11aa5a9aac74f53525';

/// Notifier for managing typing indicators

@ProviderFor(TypingNotifier)
const typingProvider = TypingNotifierProvider._();

/// Notifier for managing typing indicators
final class TypingNotifierProvider
    extends $NotifierProvider<TypingNotifier, TypingState> {
  /// Notifier for managing typing indicators
  const TypingNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'typingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$typingNotifierHash();

  @$internal
  @override
  TypingNotifier create() => TypingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TypingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TypingState>(value),
    );
  }
}

String _$typingNotifierHash() => r'02b758a58316525bccba360a57ea74775cd47d95';

/// Notifier for managing typing indicators

abstract class _$TypingNotifier extends $Notifier<TypingState> {
  TypingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TypingState, TypingState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TypingState, TypingState>, TypingState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

/// Provider for checking if other user is typing

@ProviderFor(isOtherUserTyping)
const isOtherUserTypingProvider = IsOtherUserTypingFamily._();

/// Provider for checking if other user is typing

final class IsOtherUserTypingProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Provider for checking if other user is typing
  const IsOtherUserTypingProvider._(
      {required IsOtherUserTypingFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'isOtherUserTypingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isOtherUserTypingHash();

  @override
  String toString() {
    return r'isOtherUserTypingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isOtherUserTyping(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsOtherUserTypingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isOtherUserTypingHash() => r'9ccd1eb66ce4452e6fb3951902841cb55e42a1b2';

/// Provider for checking if other user is typing

final class IsOtherUserTypingFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  const IsOtherUserTypingFamily._()
      : super(
          retry: null,
          name: r'isOtherUserTypingProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for checking if other user is typing

  IsOtherUserTypingProvider call(
    String connectionId,
  ) =>
      IsOtherUserTypingProvider._(argument: connectionId, from: this);

  @override
  String toString() => r'isOtherUserTypingProvider';
}

/// Provider for all chats

@ProviderFor(chats)
const chatsProvider = ChatsProvider._();

/// Provider for all chats

final class ChatsProvider extends $FunctionalProvider<AsyncValue<List<Chat>>,
        List<Chat>, FutureOr<List<Chat>>>
    with $FutureModifier<List<Chat>>, $FutureProvider<List<Chat>> {
  /// Provider for all chats
  const ChatsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'chatsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$chatsHash();

  @$internal
  @override
  $FutureProviderElement<List<Chat>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Chat>> create(Ref ref) {
    return chats(ref);
  }
}

String _$chatsHash() => r'2250eee984bb22616cd3f4c6f1d7b078d39a3722';

/// Provider for a specific chat by connection ID

@ProviderFor(chatForConnection)
const chatForConnectionProvider = ChatForConnectionFamily._();

/// Provider for a specific chat by connection ID

final class ChatForConnectionProvider
    extends $FunctionalProvider<AsyncValue<Chat>, Chat, FutureOr<Chat>>
    with $FutureModifier<Chat>, $FutureProvider<Chat> {
  /// Provider for a specific chat by connection ID
  const ChatForConnectionProvider._(
      {required ChatForConnectionFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'chatForConnectionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$chatForConnectionHash();

  @override
  String toString() {
    return r'chatForConnectionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Chat> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Chat> create(Ref ref) {
    final argument = this.argument as String;
    return chatForConnection(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatForConnectionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatForConnectionHash() => r'09c9bce201b308eee5666787711f201561ac2962';

/// Provider for a specific chat by connection ID

final class ChatForConnectionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Chat>, String> {
  const ChatForConnectionFamily._()
      : super(
          retry: null,
          name: r'chatForConnectionProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for a specific chat by connection ID

  ChatForConnectionProvider call(
    String connectionId,
  ) =>
      ChatForConnectionProvider._(argument: connectionId, from: this);

  @override
  String toString() => r'chatForConnectionProvider';
}

/// Provider for messages in a specific chat with real-time updates

@ProviderFor(messages)
const messagesProvider = MessagesFamily._();

/// Provider for messages in a specific chat with real-time updates

final class MessagesProvider extends $FunctionalProvider<
        AsyncValue<List<Message>>, List<Message>, Stream<List<Message>>>
    with $FutureModifier<List<Message>>, $StreamProvider<List<Message>> {
  /// Provider for messages in a specific chat with real-time updates
  const MessagesProvider._(
      {required MessagesFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'messagesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$messagesHash();

  @override
  String toString() {
    return r'messagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Message>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Message>> create(Ref ref) {
    final argument = this.argument as String;
    return messages(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messagesHash() => r'b7386428d08eb209a6bf00824fcb657610425180';

/// Provider for messages in a specific chat with real-time updates

final class MessagesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Message>>, String> {
  const MessagesFamily._()
      : super(
          retry: null,
          name: r'messagesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for messages in a specific chat with real-time updates

  MessagesProvider call(
    String chatId,
  ) =>
      MessagesProvider._(argument: chatId, from: this);

  @override
  String toString() => r'messagesProvider';
}

/// Notifier for managing chat operations

@ProviderFor(ChatNotifier)
const chatProvider = ChatNotifierProvider._();

/// Notifier for managing chat operations
final class ChatNotifierProvider
    extends $AsyncNotifierProvider<ChatNotifier, void> {
  /// Notifier for managing chat operations
  const ChatNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'chatProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$chatNotifierHash();

  @$internal
  @override
  ChatNotifier create() => ChatNotifier();
}

String _$chatNotifierHash() => r'a3b08b4698cc923e8b3966a0ea100eb9335a0f20';

/// Notifier for managing chat operations

abstract class _$ChatNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleValue(ref, null);
  }
}

/// Provider for unread message count

@ProviderFor(unreadCount)
const unreadCountProvider = UnreadCountProvider._();

/// Provider for unread message count

final class UnreadCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for unread message count
  const UnreadCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'unreadCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$unreadCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return unreadCount(ref);
  }
}

String _$unreadCountHash() => r'7ce898d4915d38df24e31b42401bcb4c6e9e381b';

/// Provider for unread notification count

@ProviderFor(unreadNotificationCount)
const unreadNotificationCountProvider = UnreadNotificationCountProvider._();

/// Provider for unread notification count

final class UnreadNotificationCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for unread notification count
  const UnreadNotificationCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'unreadNotificationCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$unreadNotificationCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return unreadNotificationCount(ref);
  }
}

String _$unreadNotificationCountHash() =>
    r'e20fcd3ec82aff0789f3e16caf1ba9cc288aff92';

/// Provider for pending connections count (new match requests)

@ProviderFor(pendingConnectionsCount)
const pendingConnectionsCountProvider = PendingConnectionsCountProvider._();

/// Provider for pending connections count (new match requests)

final class PendingConnectionsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for pending connections count (new match requests)
  const PendingConnectionsCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pendingConnectionsCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pendingConnectionsCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return pendingConnectionsCount(ref);
  }
}

String _$pendingConnectionsCountHash() =>
    r'b647d37f1d0efe592b8ad95f9852782847cf1b06';

/// Provider for pending messages count (for sync indicator)

@ProviderFor(pendingMessagesCount)
const pendingMessagesCountProvider = PendingMessagesCountProvider._();

/// Provider for pending messages count (for sync indicator)

final class PendingMessagesCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for pending messages count (for sync indicator)
  const PendingMessagesCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pendingMessagesCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pendingMessagesCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return pendingMessagesCount(ref);
  }
}

String _$pendingMessagesCountHash() =>
    r'd4aeda3b8f39a8bc32428b684c342e5a90e4a40f';

/// Provider for women-only mode status

@ProviderFor(womenOnlyModeEnabled)
const womenOnlyModeEnabledProvider = WomenOnlyModeEnabledProvider._();

/// Provider for women-only mode status

final class WomenOnlyModeEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider for women-only mode status
  const WomenOnlyModeEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'womenOnlyModeEnabledProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$womenOnlyModeEnabledHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return womenOnlyModeEnabled(ref);
  }
}

String _$womenOnlyModeEnabledHash() =>
    r'4fbced387a42d86a8179f1ce3908f53f6db56ba5';

/// Provider for checking if user can enable women-only mode

@ProviderFor(canEnableWomenOnlyMode)
const canEnableWomenOnlyModeProvider = CanEnableWomenOnlyModeProvider._();

/// Provider for checking if user can enable women-only mode

final class CanEnableWomenOnlyModeProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider for checking if user can enable women-only mode
  const CanEnableWomenOnlyModeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'canEnableWomenOnlyModeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$canEnableWomenOnlyModeHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return canEnableWomenOnlyMode(ref);
  }
}

String _$canEnableWomenOnlyModeHash() =>
    r'1ee7a717212c9276cf28867a30f8a41f61fa1ba3';

/// Notifier for managing women-only mode

@ProviderFor(WomenOnlyModeNotifier)
const womenOnlyModeProvider = WomenOnlyModeNotifierProvider._();

/// Notifier for managing women-only mode
final class WomenOnlyModeNotifierProvider
    extends $AsyncNotifierProvider<WomenOnlyModeNotifier, bool> {
  /// Notifier for managing women-only mode
  const WomenOnlyModeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'womenOnlyModeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$womenOnlyModeNotifierHash();

  @$internal
  @override
  WomenOnlyModeNotifier create() => WomenOnlyModeNotifier();
}

String _$womenOnlyModeNotifierHash() =>
    r'bf4f4d269bb4ca523781ba9d3087eba5f2c0775c';

/// Notifier for managing women-only mode

abstract class _$WomenOnlyModeNotifier extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<bool>, bool>,
        AsyncValue<bool>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Notifier for tracking user presence

@ProviderFor(PresenceNotifier)
const presenceProvider = PresenceNotifierProvider._();

/// Notifier for tracking user presence
final class PresenceNotifierProvider
    extends $NotifierProvider<PresenceNotifier, Map<String, UserPresence>> {
  /// Notifier for tracking user presence
  const PresenceNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'presenceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$presenceNotifierHash();

  @$internal
  @override
  PresenceNotifier create() => PresenceNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, UserPresence> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, UserPresence>>(value),
    );
  }
}

String _$presenceNotifierHash() => r'a8f92a177c21f16d629d91de49122c30ecf77910';

/// Notifier for tracking user presence

abstract class _$PresenceNotifier extends $Notifier<Map<String, UserPresence>> {
  Map<String, UserPresence> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<Map<String, UserPresence>, Map<String, UserPresence>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Map<String, UserPresence>, Map<String, UserPresence>>,
        Map<String, UserPresence>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
