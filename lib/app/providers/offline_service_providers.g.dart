// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncQueueDaoHash() => r'95aec30f102c3f1776139137e1577c4b3695026b';

/// Provider for SyncQueueDao
///
/// Provides access to sync queue database operations.
///
/// Copied from [syncQueueDao].
@ProviderFor(syncQueueDao)
final syncQueueDaoProvider = Provider<SyncQueueDao>.internal(
  syncQueueDao,
  name: r'syncQueueDaoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncQueueDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncQueueDaoRef = ProviderRef<SyncQueueDao>;
String _$userDaoHash() => r'46593c2743833cbec31bb9ba6b39656bfbfa03a8';

/// Provider for UserDao
///
/// Provides access to user profile database operations.
///
/// Copied from [userDao].
@ProviderFor(userDao)
final userDaoProvider = Provider<UserDao>.internal(
  userDao,
  name: r'userDaoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserDaoRef = ProviderRef<UserDao>;
String _$tripDaoHash() => r'e30e79bfc6f51bc84047a33248d1f515aa6904c4';

/// Provider for TripDao
///
/// Provides access to trip database operations.
///
/// Copied from [tripDao].
@ProviderFor(tripDao)
final tripDaoProvider = Provider<TripDao>.internal(
  tripDao,
  name: r'tripDaoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tripDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TripDaoRef = ProviderRef<TripDao>;
String _$journalDaoHash() => r'a5133fea0423f59741e5fd2aeb1dfe92806564a5';

/// Provider for JournalDao
///
/// Provides access to journal database operations.
///
/// Copied from [journalDao].
@ProviderFor(journalDao)
final journalDaoProvider = Provider<JournalDao>.internal(
  journalDao,
  name: r'journalDaoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$journalDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef JournalDaoRef = ProviderRef<JournalDao>;
String _$itineraryDaoHash() => r'2d6963ea4ae7d9f77bb8c65afa3414c169d24822';

/// Provider for ItineraryDao
///
/// Provides access to itinerary database operations.
///
/// Copied from [itineraryDao].
@ProviderFor(itineraryDao)
final itineraryDaoProvider = Provider<ItineraryDao>.internal(
  itineraryDao,
  name: r'itineraryDaoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$itineraryDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ItineraryDaoRef = ProviderRef<ItineraryDao>;
String _$connectivityServiceHash() =>
    r'2b88e30a3a8dfbdde312d73997566f26b0e2083c';

/// Provider for ConnectivityService
///
/// Monitors device connectivity state changes with debouncing.
///
/// Copied from [connectivityService].
@ProviderFor(connectivityService)
final connectivityServiceProvider =
    Provider<core_connectivity.ConnectivityService>.internal(
  connectivityService,
  name: r'connectivityServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityServiceRef
    = ProviderRef<core_connectivity.ConnectivityService>;
String _$networkReachabilityServiceHash() =>
    r'2dd8b1d9c35c810484b67ea78842e146c6ed79bd';

/// Provider for NetworkReachabilityService
///
/// Tests actual API server reachability beyond just device connectivity.
///
/// Copied from [networkReachabilityService].
@ProviderFor(networkReachabilityService)
final networkReachabilityServiceProvider =
    Provider<NetworkReachabilityService>.internal(
  networkReachabilityService,
  name: r'networkReachabilityServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$networkReachabilityServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NetworkReachabilityServiceRef = ProviderRef<NetworkReachabilityService>;
String _$syncQueueRepositoryHash() =>
    r'b2df0832de549f81b8d816e5a349b4c198bebace';

/// Provider for SyncQueueRepository
///
/// High-level operations for managing sync queue in the database.
///
/// Copied from [syncQueueRepository].
@ProviderFor(syncQueueRepository)
final syncQueueRepositoryProvider = Provider<SyncQueueRepository>.internal(
  syncQueueRepository,
  name: r'syncQueueRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncQueueRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncQueueRepositoryRef = ProviderRef<SyncQueueRepository>;
String _$syncQueueServiceHash() => r'f1d0963f4413e614f1c8aecac43c26a1549a8ac6';

/// Provider for SyncQueueService
///
/// Manages sync queue lifecycle with retry logic and cleanup.
///
/// Copied from [syncQueueService].
@ProviderFor(syncQueueService)
final syncQueueServiceProvider = Provider<SyncQueueService>.internal(
  syncQueueService,
  name: r'syncQueueServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncQueueServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncQueueServiceRef = ProviderRef<SyncQueueService>;
String _$offlineInterceptorHash() =>
    r'6a1a0b34979397ee4691463feda80fd82a780506';

/// Provider for OfflineInterceptor
///
/// Can be used by repositories to intercept operations for offline support.
///
/// Copied from [offlineInterceptor].
@ProviderFor(offlineInterceptor)
final offlineInterceptorProvider = Provider<OfflineInterceptor>.internal(
  offlineInterceptor,
  name: r'offlineInterceptorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$offlineInterceptorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfflineInterceptorRef = ProviderRef<OfflineInterceptor>;
String _$conflictResolverHash() => r'9c5a3256b74109b50fe3d373008442e2588ac7e3';

/// Provider for ConflictResolver
///
/// Handles sync conflicts with configurable resolution strategies.
///
/// Copied from [conflictResolver].
@ProviderFor(conflictResolver)
final conflictResolverProvider = Provider<ConflictResolver>.internal(
  conflictResolver,
  name: r'conflictResolverProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$conflictResolverHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConflictResolverRef = ProviderRef<ConflictResolver>;
String _$uploadSyncHash() => r'4f8678e39f3708a3f37d1382b9193eacd3c89078';

/// Provider for UploadSync
///
/// Syncs queued operations from local database to server via GraphQL.
///
/// Copied from [uploadSync].
@ProviderFor(uploadSync)
final uploadSyncProvider = Provider<UploadSync>.internal(
  uploadSync,
  name: r'uploadSyncProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$uploadSyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UploadSyncRef = ProviderRef<UploadSync>;
String _$downloadSyncHash() => r'3e0b24e4e0b5744b843b5c34701c2915624a5b8d';

/// Provider for DownloadSync
///
/// Syncs server data to local database with conflict resolution.
///
/// Copied from [downloadSync].
@ProviderFor(downloadSync)
final downloadSyncProvider = Provider<DownloadSync>.internal(
  downloadSync,
  name: r'downloadSyncProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$downloadSyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DownloadSyncRef = ProviderRef<DownloadSync>;
String _$incrementalSyncHash() => r'e767d59773a6691e9e366eec8f5e62fa5f9d5045';

/// Provider for IncrementalSync
///
/// Efficient delta sync with fallback to full sync.
///
/// Copied from [incrementalSync].
@ProviderFor(incrementalSync)
final incrementalSyncProvider = Provider<IncrementalSync>.internal(
  incrementalSync,
  name: r'incrementalSyncProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$incrementalSyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IncrementalSyncRef = ProviderRef<IncrementalSync>;
String _$syncManagerHash() => r'37ee43ab2fa9f8ad20cb784654dfe38e5127bea2';

/// Provider for SyncManager
///
/// Core sync coordinator orchestrating all sync operations.
///
/// Note: The getCurrentUserId callback returns an empty string placeholder.
/// This should be overridden in a provider where auth state is accessible.
///
/// Copied from [syncManager].
@ProviderFor(syncManager)
final syncManagerProvider = Provider<SyncManager>.internal(
  syncManager,
  name: r'syncManagerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncManagerRef = ProviderRef<SyncManager>;
String _$optimisticUpdateHandlerHash() =>
    r'018780be62c32a76bd3debddd29204e0d3c23623';

/// Provider for OptimisticUpdateHandler
///
/// Tracks optimistic UI updates with rollback capability.
///
/// Copied from [optimisticUpdateHandler].
@ProviderFor(optimisticUpdateHandler)
final optimisticUpdateHandlerProvider =
    Provider<OptimisticUpdateHandler>.internal(
  optimisticUpdateHandler,
  name: r'optimisticUpdateHandlerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$optimisticUpdateHandlerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OptimisticUpdateHandlerRef = ProviderRef<OptimisticUpdateHandler>;
String _$backgroundSyncServiceHash() =>
    r'3f0a1be55600fa6f6080b0528822200830065866';

/// Provider for BackgroundSyncService
///
/// Configures Workmanager for periodic background sync tasks.
///
/// Copied from [backgroundSyncService].
@ProviderFor(backgroundSyncService)
final backgroundSyncServiceProvider = Provider<BackgroundSyncService>.internal(
  backgroundSyncService,
  name: r'backgroundSyncServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$backgroundSyncServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BackgroundSyncServiceRef = ProviderRef<BackgroundSyncService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
