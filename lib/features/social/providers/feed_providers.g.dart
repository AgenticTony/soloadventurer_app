// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the feed remote data source backed by Supabase

@ProviderFor(feedRemoteDataSource)
const feedRemoteDataSourceProvider = FeedRemoteDataSourceProvider._();

/// Provides the feed remote data source backed by Supabase

final class FeedRemoteDataSourceProvider extends $FunctionalProvider<
    FeedRemoteDataSource,
    FeedRemoteDataSource,
    FeedRemoteDataSource> with $Provider<FeedRemoteDataSource> {
  /// Provides the feed remote data source backed by Supabase
  const FeedRemoteDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'feedRemoteDataSourceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$feedRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<FeedRemoteDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedRemoteDataSource create(Ref ref) {
    return feedRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedRemoteDataSource>(value),
    );
  }
}

String _$feedRemoteDataSourceHash() =>
    r'a5d7ddb1604bce2aae5fe8165b135dd8ef9dfa3b';

/// Provides the feed repository implementation

@ProviderFor(feedRepository)
const feedRepositoryProvider = FeedRepositoryProvider._();

/// Provides the feed repository implementation

final class FeedRepositoryProvider
    extends $FunctionalProvider<FeedRepository, FeedRepository, FeedRepository>
    with $Provider<FeedRepository> {
  /// Provides the feed repository implementation
  const FeedRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'feedRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$feedRepositoryHash();

  @$internal
  @override
  $ProviderElement<FeedRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedRepository create(Ref ref) {
    return feedRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedRepository>(value),
    );
  }
}

String _$feedRepositoryHash() => r'6c4f9381155ebde1dd99e1ec886fcae2b0019fcb';

/// Provides the get feed use case

@ProviderFor(getFeedUseCase)
const getFeedUseCaseProvider = GetFeedUseCaseProvider._();

/// Provides the get feed use case

final class GetFeedUseCaseProvider
    extends $FunctionalProvider<GetFeedUseCase, GetFeedUseCase, GetFeedUseCase>
    with $Provider<GetFeedUseCase> {
  /// Provides the get feed use case
  const GetFeedUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getFeedUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getFeedUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetFeedUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetFeedUseCase create(Ref ref) {
    return getFeedUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetFeedUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetFeedUseCase>(value),
    );
  }
}

String _$getFeedUseCaseHash() => r'9ff6b827764b6c6930b6ac03be22ed69c4741c22';

/// AsyncNotifier managing the social feed with pagination and realtime updates
///
/// - Initial load fetches 20 items via [get_user_feed] RPC
/// - [loadMore] appends the next page using cursor pagination
/// - [refresh] reloads from scratch
/// - Subscribes to Supabase Realtime on the `feed_items` table and
///   prepends new items as they arrive

@ProviderFor(SocialFeed)
const socialFeedProvider = SocialFeedProvider._();

/// AsyncNotifier managing the social feed with pagination and realtime updates
///
/// - Initial load fetches 20 items via [get_user_feed] RPC
/// - [loadMore] appends the next page using cursor pagination
/// - [refresh] reloads from scratch
/// - Subscribes to Supabase Realtime on the `feed_items` table and
///   prepends new items as they arrive
final class SocialFeedProvider
    extends $AsyncNotifierProvider<SocialFeed, List<FeedItem>> {
  /// AsyncNotifier managing the social feed with pagination and realtime updates
  ///
  /// - Initial load fetches 20 items via [get_user_feed] RPC
  /// - [loadMore] appends the next page using cursor pagination
  /// - [refresh] reloads from scratch
  /// - Subscribes to Supabase Realtime on the `feed_items` table and
  ///   prepends new items as they arrive
  const SocialFeedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'socialFeedProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$socialFeedHash();

  @$internal
  @override
  SocialFeed create() => SocialFeed();
}

String _$socialFeedHash() => r'394a472213394970c07afb2621390c351c32675d';

/// AsyncNotifier managing the social feed with pagination and realtime updates
///
/// - Initial load fetches 20 items via [get_user_feed] RPC
/// - [loadMore] appends the next page using cursor pagination
/// - [refresh] reloads from scratch
/// - Subscribes to Supabase Realtime on the `feed_items` table and
///   prepends new items as they arrive

abstract class _$SocialFeed extends $AsyncNotifier<List<FeedItem>> {
  FutureOr<List<FeedItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<FeedItem>>, List<FeedItem>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<FeedItem>>, List<FeedItem>>,
        AsyncValue<List<FeedItem>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
