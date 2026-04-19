import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/services/connectivity_service.dart'
    as core_connectivity;
import 'package:soloadventurer/core/services/connectivity_service_impl.dart';
import 'package:soloadventurer/core/network/network_reachability.dart';
import 'package:soloadventurer/features/offline/data/repositories/offline_repositories.dart';
import 'package:soloadventurer/features/offline/domain/repositories/sync_queue_repository.dart';
import 'package:soloadventurer/features/offline/domain/services/offline_services.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/itinerary_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/journal_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/sync_queue_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/trip_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/user_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/sync/background_sync_service.dart';
import 'package:soloadventurer/features/offline/infrastructure/sync/conflict_resolver_impl.dart';
import 'package:soloadventurer/features/offline/infrastructure/sync/download_sync.dart';
import 'package:soloadventurer/features/offline/infrastructure/sync/incremental_sync.dart';
import 'package:soloadventurer/features/offline/infrastructure/sync/offline_interceptor.dart';
import 'package:soloadventurer/features/offline/infrastructure/sync/sync_manager_impl.dart';
import 'package:soloadventurer/features/offline/infrastructure/sync/upload_sync.dart';
import 'package:soloadventurer/core/providers/api_providers.dart';
import 'package:soloadventurer/app/providers/core_service_providers.dart';
import 'package:soloadventurer/features/offline/presentation/providers/connectivity_provider.dart'
    as offline_connectivity show connectivityServiceProvider;

part 'offline_service_providers.g.dart';

// ============================================================================
// Database Access Objects (DAOs)
// ============================================================================

/// Provider for SyncQueueDao
///
/// Provides access to sync queue database operations.
@Riverpod(keepAlive: true)
SyncQueueDao syncQueueDao(Ref ref) {
  final database = ref.watch(databaseServiceProvider).database;
  return SyncQueueDao(database);
}

/// Provider for UserDao
///
/// Provides access to user profile database operations.
@Riverpod(keepAlive: true)
UserDao userDao(Ref ref) {
  final database = ref.watch(databaseServiceProvider).database;
  return UserDao(database);
}

/// Provider for TripDao
///
/// Provides access to trip database operations.
@Riverpod(keepAlive: true)
TripDao tripDao(Ref ref) {
  final database = ref.watch(databaseServiceProvider).database;
  return TripDao(database);
}

/// Provider for JournalDao
///
/// Provides access to journal database operations.
@Riverpod(keepAlive: true)
JournalDao journalDao(Ref ref) {
  final database = ref.watch(databaseServiceProvider).database;
  return JournalDao(database);
}

/// Provider for ItineraryDao
///
/// Provides access to itinerary database operations.
@Riverpod(keepAlive: true)
ItineraryDao itineraryDao(Ref ref) {
  final database = ref.watch(databaseServiceProvider).database;
  return ItineraryDao(database);
}

// ============================================================================
// Network & Connectivity Services
// ============================================================================

/// Provider for ConnectivityService
///
/// Monitors device connectivity state changes with debouncing.
@Riverpod(keepAlive: true)
core_connectivity.ConnectivityService connectivityService(Ref ref) {
  final connectivity = ref.watch(connectivityProvider);
  return ConnectivityServiceImpl(
    connectivity: connectivity,
    debounceMs: 300,
  );
}

/// Provider for NetworkReachabilityService
///
/// Tests actual API server reachability beyond just device connectivity.
@Riverpod(keepAlive: true)
NetworkReachabilityService networkReachabilityService(Ref ref) {
  return NetworkReachabilityService(
    testEndpointPath: '/health',
    timeoutMs: 5000,
    cacheTtlMs: 30000,
  );
}

// ============================================================================
// Sync Queue System
// ============================================================================

/// Provider for SyncQueueRepository
///
/// High-level operations for managing sync queue in the database.
@Riverpod(keepAlive: true)
SyncQueueRepository syncQueueRepository(Ref ref) {
  final syncQueueDao = ref.watch(syncQueueDaoProvider);
  return SyncQueueRepositoryImpl(
    syncQueueDao: syncQueueDao,
  );
}

/// Provider for SyncQueueService
///
/// Manages sync queue lifecycle with retry logic and cleanup.
@Riverpod(keepAlive: true)
SyncQueueService syncQueueService(Ref ref) {
  final repository = ref.watch(syncQueueRepositoryProvider);
  return SyncQueueService(
    repository: repository,
    cleanupInterval: const Duration(hours: 1),
    completedOperationMaxAge: const Duration(days: 7),
    failedOperationMaxAge: const Duration(days: 30),
  );
}

/// Provider for OfflineInterceptor
///
/// Can be used by repositories to intercept operations for offline support.
@Riverpod(keepAlive: true)
OfflineInterceptor offlineInterceptor(Ref ref) {
  final syncQueueService = ref.watch(syncQueueServiceProvider);
  final connectivityService =
      ref.watch(offline_connectivity.connectivityServiceProvider);
  return OfflineInterceptor(
    syncQueueService: syncQueueService,
    connectivityService: connectivityService,
  );
}

// ============================================================================
// Data Synchronization Engine
// ============================================================================

/// Provider for ConflictResolver
///
/// Handles sync conflicts with configurable resolution strategies.
@Riverpod(keepAlive: true)
ConflictResolver conflictResolver(Ref ref) {
  final database = ref.watch(databaseServiceProvider).database;
  return ConflictResolverImpl(
    database: database,
    defaultStrategies: const {
      EntityType.trip: ConflictResolutionStrategy.serverWins,
      EntityType.journal: ConflictResolutionStrategy.clientWins,
      EntityType.userProfile: ConflictResolutionStrategy.lastWriteWins,
      EntityType.travelPreference: ConflictResolutionStrategy.clientWins,
    },
  );
}

/// Provider for UploadSync
///
/// Syncs queued operations from local database to server via Supabase PostgREST API.
@Riverpod(keepAlive: true)
UploadSync uploadSync(Ref ref) {
  final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
  return UploadSync(
    client: Supabase.instance.client,
    syncQueueRepository: syncQueueRepository,
  );
}

/// Provider for DownloadSync
///
/// Syncs server data to local database with conflict resolution.
@Riverpod(keepAlive: true)
DownloadSync downloadSync(Ref ref) {
  final dio = ref.watch(dioProvider);
  final database = ref.watch(databaseServiceProvider).database;
  final conflictResolver = ref.watch(conflictResolverProvider);
  return DownloadSync(
    dio: dio,
    database: database,
    graphqlEndpoint: '/graphql',
    conflictResolver: conflictResolver,
  );
}

/// Provider for IncrementalSync
///
/// Efficient delta sync with fallback to full sync.
@Riverpod(keepAlive: true)
IncrementalSync incrementalSync(Ref ref) {
  final dio = ref.watch(dioProvider);
  final database = ref.watch(databaseServiceProvider).database;
  final conflictResolver = ref.watch(conflictResolverProvider);
  return IncrementalSync(
    dio: dio,
    database: database,
    graphqlEndpoint: '/graphql',
    conflictResolver: conflictResolver,
  );
}

/// Provider for SyncManager
///
/// Core sync coordinator orchestrating all sync operations.
///
/// Note: The getCurrentUserId callback returns an empty string placeholder.
/// This should be overridden in a provider where auth state is accessible.
@Riverpod(keepAlive: true)
SyncManager syncManager(Ref ref) {
  final connectivityService =
      ref.watch(offline_connectivity.connectivityServiceProvider);
  final syncQueueService = ref.watch(syncQueueServiceProvider);
  final uploadSync = ref.watch(uploadSyncProvider);
  final downloadSync = ref.watch(downloadSyncProvider);
  final conflictResolver = ref.watch(conflictResolverProvider);
  return SyncManagerImpl(
    connectivityService: connectivityService,
    syncQueueService: syncQueueService,
    uploadSync: uploadSync,
    downloadSync: downloadSync,
    conflictResolver: conflictResolver,
    getCurrentUserId: () => '', // TODO: Override with actual userId
    autoSyncMinInterval: const Duration(seconds: 30),
    syncOnlyOnWifi: false,
  );
}

/// Provider for OptimisticUpdateHandler
///
/// Tracks optimistic UI updates with rollback capability.
@Riverpod(keepAlive: true)
OptimisticUpdateHandler optimisticUpdateHandler(Ref ref) {
  return OptimisticUpdateHandler(
    config: const OptimisticUpdateConfig(
      autoRollbackOnFailure: true,
      maxAgeMs: 7 * 24 * 60 * 60 * 1000, // 7 days
      enableTracking: true,
    ),
  );
}

/// Provider for BackgroundSyncService
///
/// Configures Workmanager for periodic background sync tasks.
@Riverpod(keepAlive: true)
BackgroundSyncService backgroundSyncService(Ref ref) {
  return BackgroundSyncService(
    periodicSyncInterval: const Duration(minutes: 15),
    initialDelay: const Duration(minutes: 5),
  );
}
