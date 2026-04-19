// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the follow remote data source backed by Supabase

@ProviderFor(followRemoteDataSource)
const followRemoteDataSourceProvider = FollowRemoteDataSourceProvider._();

/// Provides the follow remote data source backed by Supabase

final class FollowRemoteDataSourceProvider extends $FunctionalProvider<
    FollowRemoteDataSource,
    FollowRemoteDataSource,
    FollowRemoteDataSource> with $Provider<FollowRemoteDataSource> {
  /// Provides the follow remote data source backed by Supabase
  const FollowRemoteDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'followRemoteDataSourceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$followRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<FollowRemoteDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FollowRemoteDataSource create(Ref ref) {
    return followRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FollowRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FollowRemoteDataSource>(value),
    );
  }
}

String _$followRemoteDataSourceHash() =>
    r'2ea07237df601483307d669ba6e61fb717f83841';

/// Provides the follow repository implementation

@ProviderFor(followRepository)
const followRepositoryProvider = FollowRepositoryProvider._();

/// Provides the follow repository implementation

final class FollowRepositoryProvider extends $FunctionalProvider<
    FollowRepository,
    FollowRepository,
    FollowRepository> with $Provider<FollowRepository> {
  /// Provides the follow repository implementation
  const FollowRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'followRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$followRepositoryHash();

  @$internal
  @override
  $ProviderElement<FollowRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FollowRepository create(Ref ref) {
    return followRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FollowRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FollowRepository>(value),
    );
  }
}

String _$followRepositoryHash() => r'c9b493fa0a7f2ed5829234e6d1b4785e9b31a3c0';

/// Provides the follow user use case

@ProviderFor(followUserUseCase)
const followUserUseCaseProvider = FollowUserUseCaseProvider._();

/// Provides the follow user use case

final class FollowUserUseCaseProvider extends $FunctionalProvider<
    FollowUserUseCase,
    FollowUserUseCase,
    FollowUserUseCase> with $Provider<FollowUserUseCase> {
  /// Provides the follow user use case
  const FollowUserUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'followUserUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$followUserUseCaseHash();

  @$internal
  @override
  $ProviderElement<FollowUserUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FollowUserUseCase create(Ref ref) {
    return followUserUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FollowUserUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FollowUserUseCase>(value),
    );
  }
}

String _$followUserUseCaseHash() => r'f2c11e14de8859d75105e0fa3d4d0950460108b7';

/// Provides the unfollow user use case

@ProviderFor(unfollowUserUseCase)
const unfollowUserUseCaseProvider = UnfollowUserUseCaseProvider._();

/// Provides the unfollow user use case

final class UnfollowUserUseCaseProvider extends $FunctionalProvider<
    UnfollowUserUseCase,
    UnfollowUserUseCase,
    UnfollowUserUseCase> with $Provider<UnfollowUserUseCase> {
  /// Provides the unfollow user use case
  const UnfollowUserUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'unfollowUserUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$unfollowUserUseCaseHash();

  @$internal
  @override
  $ProviderElement<UnfollowUserUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UnfollowUserUseCase create(Ref ref) {
    return unfollowUserUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnfollowUserUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnfollowUserUseCase>(value),
    );
  }
}

String _$unfollowUserUseCaseHash() =>
    r'9733a313e8fcee9849642679731006b6e2bd100f';

/// Provides the accept follow use case

@ProviderFor(acceptFollowUseCase)
const acceptFollowUseCaseProvider = AcceptFollowUseCaseProvider._();

/// Provides the accept follow use case

final class AcceptFollowUseCaseProvider extends $FunctionalProvider<
    AcceptFollowUseCase,
    AcceptFollowUseCase,
    AcceptFollowUseCase> with $Provider<AcceptFollowUseCase> {
  /// Provides the accept follow use case
  const AcceptFollowUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'acceptFollowUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$acceptFollowUseCaseHash();

  @$internal
  @override
  $ProviderElement<AcceptFollowUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AcceptFollowUseCase create(Ref ref) {
    return acceptFollowUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AcceptFollowUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AcceptFollowUseCase>(value),
    );
  }
}

String _$acceptFollowUseCaseHash() =>
    r'bca37a55d794b1f38a6bfcd0317101053a3282cb';

/// Provides the decline follow use case

@ProviderFor(declineFollowUseCase)
const declineFollowUseCaseProvider = DeclineFollowUseCaseProvider._();

/// Provides the decline follow use case

final class DeclineFollowUseCaseProvider extends $FunctionalProvider<
    DeclineFollowUseCase,
    DeclineFollowUseCase,
    DeclineFollowUseCase> with $Provider<DeclineFollowUseCase> {
  /// Provides the decline follow use case
  const DeclineFollowUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'declineFollowUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$declineFollowUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeclineFollowUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeclineFollowUseCase create(Ref ref) {
    return declineFollowUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeclineFollowUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeclineFollowUseCase>(value),
    );
  }
}

String _$declineFollowUseCaseHash() =>
    r'09521104dc05d825855f2254e32a311d86b102f9';

/// Provides the get followers use case

@ProviderFor(getFollowersUseCase)
const getFollowersUseCaseProvider = GetFollowersUseCaseProvider._();

/// Provides the get followers use case

final class GetFollowersUseCaseProvider extends $FunctionalProvider<
    GetFollowersUseCase,
    GetFollowersUseCase,
    GetFollowersUseCase> with $Provider<GetFollowersUseCase> {
  /// Provides the get followers use case
  const GetFollowersUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getFollowersUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getFollowersUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetFollowersUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetFollowersUseCase create(Ref ref) {
    return getFollowersUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetFollowersUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetFollowersUseCase>(value),
    );
  }
}

String _$getFollowersUseCaseHash() =>
    r'3a302070676edc681367413b8e10e24415dde166';

/// Provides the get following use case

@ProviderFor(getFollowingUseCase)
const getFollowingUseCaseProvider = GetFollowingUseCaseProvider._();

/// Provides the get following use case

final class GetFollowingUseCaseProvider extends $FunctionalProvider<
    GetFollowingUseCase,
    GetFollowingUseCase,
    GetFollowingUseCase> with $Provider<GetFollowingUseCase> {
  /// Provides the get following use case
  const GetFollowingUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getFollowingUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getFollowingUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetFollowingUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetFollowingUseCase create(Ref ref) {
    return getFollowingUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetFollowingUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetFollowingUseCase>(value),
    );
  }
}

String _$getFollowingUseCaseHash() =>
    r'3cbe430830325ff145b4ec0e7a809b2ccbd4e73a';

/// Provides the get pending requests use case

@ProviderFor(getPendingRequestsUseCase)
const getPendingRequestsUseCaseProvider = GetPendingRequestsUseCaseProvider._();

/// Provides the get pending requests use case

final class GetPendingRequestsUseCaseProvider extends $FunctionalProvider<
    GetPendingRequestsUseCase,
    GetPendingRequestsUseCase,
    GetPendingRequestsUseCase> with $Provider<GetPendingRequestsUseCase> {
  /// Provides the get pending requests use case
  const GetPendingRequestsUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getPendingRequestsUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getPendingRequestsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPendingRequestsUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetPendingRequestsUseCase create(Ref ref) {
    return getPendingRequestsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPendingRequestsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPendingRequestsUseCase>(value),
    );
  }
}

String _$getPendingRequestsUseCaseHash() =>
    r'37370ce3d5bf02a7c85fde74dccb325524172e6a';

/// Provides the is-following use case

@ProviderFor(isFollowingUseCase)
const isFollowingUseCaseProvider = IsFollowingUseCaseProvider._();

/// Provides the is-following use case

final class IsFollowingUseCaseProvider extends $FunctionalProvider<
    IsFollowingUseCase,
    IsFollowingUseCase,
    IsFollowingUseCase> with $Provider<IsFollowingUseCase> {
  /// Provides the is-following use case
  const IsFollowingUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isFollowingUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isFollowingUseCaseHash();

  @$internal
  @override
  $ProviderElement<IsFollowingUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IsFollowingUseCase create(Ref ref) {
    return isFollowingUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IsFollowingUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IsFollowingUseCase>(value),
    );
  }
}

String _$isFollowingUseCaseHash() =>
    r'1900a69361bb000f135614351501321db535b0a4';

/// AsyncNotifier that tracks the follow status for a specific target user.
///
/// Usage: `ref.watch(followStatusProvider(targetId))`

@ProviderFor(FollowStatusNotifier)
const followStatusProvider = FollowStatusNotifierFamily._();

/// AsyncNotifier that tracks the follow status for a specific target user.
///
/// Usage: `ref.watch(followStatusProvider(targetId))`
final class FollowStatusNotifierProvider
    extends $AsyncNotifierProvider<FollowStatusNotifier, bool> {
  /// AsyncNotifier that tracks the follow status for a specific target user.
  ///
  /// Usage: `ref.watch(followStatusProvider(targetId))`
  const FollowStatusNotifierProvider._(
      {required FollowStatusNotifierFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'followStatusProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$followStatusNotifierHash();

  @override
  String toString() {
    return r'followStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FollowStatusNotifier create() => FollowStatusNotifier();

  @override
  bool operator ==(Object other) {
    return other is FollowStatusNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followStatusNotifierHash() =>
    r'70a7c346f2c619ac4fccbbf6b23261f8282d129d';

/// AsyncNotifier that tracks the follow status for a specific target user.
///
/// Usage: `ref.watch(followStatusProvider(targetId))`

final class FollowStatusNotifierFamily extends $Family
    with
        $ClassFamilyOverride<FollowStatusNotifier, AsyncValue<bool>, bool,
            FutureOr<bool>, String> {
  const FollowStatusNotifierFamily._()
      : super(
          retry: null,
          name: r'followStatusProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// AsyncNotifier that tracks the follow status for a specific target user.
  ///
  /// Usage: `ref.watch(followStatusProvider(targetId))`

  FollowStatusNotifierProvider call(
    String targetUserId,
  ) =>
      FollowStatusNotifierProvider._(argument: targetUserId, from: this);

  @override
  String toString() => r'followStatusProvider';
}

/// AsyncNotifier that tracks the follow status for a specific target user.
///
/// Usage: `ref.watch(followStatusProvider(targetId))`

abstract class _$FollowStatusNotifier extends $AsyncNotifier<bool> {
  late final _$args = ref.$arg as String;
  String get targetUserId => _$args;

  FutureOr<bool> build(
    String targetUserId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<bool>, bool>,
        AsyncValue<bool>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Provides the list of pending follow requests for the current user

@ProviderFor(pendingFollowRequests)
const pendingFollowRequestsProvider = PendingFollowRequestsProvider._();

/// Provides the list of pending follow requests for the current user

final class PendingFollowRequestsProvider extends $FunctionalProvider<
        AsyncValue<List<Follow>>, List<Follow>, FutureOr<List<Follow>>>
    with $FutureModifier<List<Follow>>, $FutureProvider<List<Follow>> {
  /// Provides the list of pending follow requests for the current user
  const PendingFollowRequestsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pendingFollowRequestsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pendingFollowRequestsHash();

  @$internal
  @override
  $FutureProviderElement<List<Follow>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Follow>> create(Ref ref) {
    return pendingFollowRequests(ref);
  }
}

String _$pendingFollowRequestsHash() =>
    r'69b13f2d4b018eb18c34143a47ae5d42b99c6de4';

/// Provides the follower count for a specific user

@ProviderFor(followerCount)
const followerCountProvider = FollowerCountFamily._();

/// Provides the follower count for a specific user

final class FollowerCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provides the follower count for a specific user
  const FollowerCountProvider._(
      {required FollowerCountFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'followerCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$followerCountHash();

  @override
  String toString() {
    return r'followerCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as String;
    return followerCount(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FollowerCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followerCountHash() => r'b1434fb207025afb5131b600d7a84e4a08e4c153';

/// Provides the follower count for a specific user

final class FollowerCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  const FollowerCountFamily._()
      : super(
          retry: null,
          name: r'followerCountProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provides the follower count for a specific user

  FollowerCountProvider call(
    String userId,
  ) =>
      FollowerCountProvider._(argument: userId, from: this);

  @override
  String toString() => r'followerCountProvider';
}

/// Provides the following count for a specific user

@ProviderFor(followingCount)
const followingCountProvider = FollowingCountFamily._();

/// Provides the following count for a specific user

final class FollowingCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provides the following count for a specific user
  const FollowingCountProvider._(
      {required FollowingCountFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'followingCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$followingCountHash();

  @override
  String toString() {
    return r'followingCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as String;
    return followingCount(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FollowingCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followingCountHash() => r'1d75044afa910ea0b0bc6330adccbcc2cb31babe';

/// Provides the following count for a specific user

final class FollowingCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  const FollowingCountFamily._()
      : super(
          retry: null,
          name: r'followingCountProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provides the following count for a specific user

  FollowingCountProvider call(
    String userId,
  ) =>
      FollowingCountProvider._(argument: userId, from: this);

  @override
  String toString() => r'followingCountProvider';
}
