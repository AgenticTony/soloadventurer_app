import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:soloadventurer/features/offline/infrastructure/database/database_service.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/sync_queue_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/user_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/trip_dao.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/journal_dao.dart';
import 'package:soloadventurer/features/offline/domain/services/offline_services.dart';
import 'package:soloadventurer/features/offline/domain/repositories/offline_repositories.dart';
import 'package:soloadventurer/features/offline/data/repositories/offline_repositories.dart';
import 'package:soloadventurer/features/offline/infrastructure/sync/offline_sync.dart';
import 'package:soloadventurer/core/network/network_reachability.dart';
import 'package:soloadventurer/features/core/infrastructure/api/dio_api_service.dart';

/// Register all offline/sync feature dependencies
///
/// This module manages dependency injection for the offline-first architecture
/// including local database, sync queue, connectivity monitoring, and data synchronization.
///
/// The module is organized into sections:
/// - Phase 1: Basic connectivity and path providers
/// - Phase 2: Local database and DAOs
/// - Phase 3: Network monitoring
/// - Phase 4: Sync queue system
/// - Phase 5: Data synchronization engine
/// - Phase 6: Repository implementations
///
/// As each phase is implemented, the corresponding services will be registered here.
void registerOfflineModule(GetIt getIt, {bool isTest = false}) {
  // ==============================================================================
  // PHASE 1: FOUNDATION & BASIC DEPENDENCIES
  // ==============================================================================

  // Register connectivity plugin for network monitoring
  getIt.registerLazySingleton<Connectivity>(
    () => Connectivity(),
  );

  // Register path provider utilities for database file access
  // Note: These are factory methods that will be called when needed
  // Actual path resolution happens at runtime in database initialization

  // ==============================================================================
  // PHASE 2: LOCAL DATABASE LAYER (To be implemented in Phase 2)
  // ==============================================================================
  //
  // Register DatabaseService as a singleton
  // This service manages the database lifecycle and provides error recovery
  getIt.registerLazySingleton<DatabaseService>(
    () => DatabaseService(),
  );

  // Register DAOs for database operations
  // DAOs are registered as singletons and depend on AppDatabase
  // Note: These will be initialized lazily when first accessed
  getIt.registerLazySingleton<SyncQueueDao>(
    () => SyncQueueDao(getIt<DatabaseService>().database),
  );

  getIt.registerLazySingleton<UserDao>(
    () => UserDao(getIt<DatabaseService>().database),
  );

  getIt.registerLazySingleton<TripDao>(
    () => TripDao(getIt<DatabaseService>().database),
  );

  getIt.registerLazySingleton<JournalDao>(
    () => JournalDao(getIt<DatabaseService>().database),
  );

  // ==============================================================================
  // PHASE 3: NETWORK MONITORING
  // ==============================================================================
  //
  // Register ConnectivityService for monitoring network connectivity changes
  getIt.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(
      connectivity: getIt<Connectivity>(),
      debounceMs: 300,
    ),
  );

  // Register NetworkReachabilityService for actual API reachability testing
  // This service performs real HTTP requests to test if the server is reachable
  // beyond just checking device connectivity. Includes caching to avoid excessive requests.
  getIt.registerLazySingleton<NetworkReachabilityService>(
    () => NetworkReachabilityService(
      testEndpointPath: '/health',
      timeoutMs: 5000,
      cacheTtlMs: 30000,
    ),
  );

  // ==============================================================================
  // PHASE 4: SYNC QUEUE SYSTEM
  // ==============================================================================
  //
  // Register SyncQueueRepository for managing sync queue operations
  // The repository provides high-level operations for enqueueing, dequeueing,
  // and managing sync operations in the local database.
  getIt.registerLazySingleton<SyncQueueRepository>(
    () => SyncQueueRepositoryImpl(
      syncQueueDao: getIt<SyncQueueDao>(),
    ),
  );

  // Register SyncQueueService for managing sync queue lifecycle
  // This service provides high-level operations for queueing, retrying, and
  // cleaning up sync operations. It integrates with connectivity monitoring
  // and handles offline scenarios gracefully.
  getIt.registerLazySingleton<SyncQueueService>(
    () => SyncQueueService(
      repository: getIt<SyncQueueRepository>(),
      connectivityService: getIt<ConnectivityService>(),
      cleanupInterval: const Duration(hours: 1),
      completedOperationMaxAge: const Duration(days: 7),
      failedOperationMaxAge: const Duration(days: 30),
    ),
  );
  //
  // Register OfflineInterceptor for manual operation interception
  // This service can be used directly by repositories to intercept operations
  getIt.registerLazySingleton<OfflineInterceptor>(
    () => OfflineInterceptor(
      syncQueueService: getIt<SyncQueueService>(),
      connectivityService: getIt<ConnectivityService>(),
    ),
  );

  // ==============================================================================
  // PHASE 5: DATA SYNCHRONIZATION ENGINE
  // ==============================================================================
  //
  // Register SyncManager as the core sync coordinator
  // This manager orchestrates all sync operations and triggers sync
  // when connectivity is restored. It prevents concurrent sync cycles
  // and provides status updates via a stream for UI consumption.
  //
  // Note: The getCurrentUserId callback is registered as a placeholder.
  // This should be overridden in a Riverpod provider where the auth
  // state is accessible. The placeholder returns empty string which
  // will cause sync to be skipped until properly configured.
  getIt.registerLazySingleton<SyncManager>(
    () => SyncManagerImpl(
      connectivityService: getIt<ConnectivityService>(),
      syncQueueService: getIt<SyncQueueService>(),
      uploadSync: getIt<UploadSync>(),
      downloadSync: getIt<DownloadSync>(),
      conflictResolver: getIt<ConflictResolver>(),
      getCurrentUserId: () =>
          '', // TODO: Override in provider with actual userId
      autoSyncMinInterval: const Duration(seconds: 30),
      syncOnlyOnWifi: false,
    ),
  );
  //
  // Register ConflictResolver for handling sync conflicts
  // This resolver handles situations where the same entity has been modified
  // on both the client and server since the last sync. It provides multiple
  // resolution strategies including last-write-wins, server-wins, client-wins,
  // and manual resolution for complex conflicts.
  getIt.registerLazySingleton<ConflictResolver>(
    () => ConflictResolverImpl(
      database: getIt<DatabaseService>().database,
      defaultStrategies: const {
        EntityType.trip: ConflictResolutionStrategy.serverWins,
        EntityType.journal: ConflictResolutionStrategy.clientWins,
        EntityType.userProfile: ConflictResolutionStrategy.lastWriteWins,
        EntityType.travelPreference: ConflictResolutionStrategy.clientWins,
      },
    ),
  );
  //
  // Register UploadSync for syncing queued operations to server
  // This service processes pending sync operations and uploads them to the server
  // using GraphQL mutations. It handles create, update, and delete operations for
  // trips, journals, and user profiles.
  getIt.registerLazySingleton<UploadSync>(
    () => UploadSync(
      dio: getIt<DioApiService>().dio,
      syncQueueRepository: getIt<SyncQueueRepository>(),
      graphqlEndpoint: '/graphql',
    ),
  );
  //
  // Register DownloadSync for syncing server data to local database
  // This service queries the server for changes and updates the local database
  // with new or modified records. It handles trips, journals, and user profiles.
  getIt.registerLazySingleton<DownloadSync>(
    () => DownloadSync(
      dio: getIt<DioApiService>().dio,
      database: getIt<DatabaseService>().database,
      graphqlEndpoint: '/graphql',
      conflictResolver: getIt<ConflictResolver>(),
    ),
  );
  //
  // Register IncrementalSync for efficient delta sync with fallback to full sync
  // This service attempts to sync only changed data using timestamp-based filtering.
  // If incremental sync fails or is not supported by the server, it falls back to
  // a full sync automatically. Tracks last incremental sync time per entity type.
  getIt.registerLazySingleton<IncrementalSync>(
    () => IncrementalSync(
      dio: getIt<DioApiService>().dio,
      database: getIt<DatabaseService>().database,
      graphqlEndpoint: '/graphql',
      conflictResolver: getIt<ConflictResolver>(),
    ),
  );

  // ==============================================================================
  // PHASE 6: REPOSITORY ADAPTATION (To be implemented in Phase 6)
  // ==============================================================================
  //
  // Register OptimisticUpdateHandler for managing optimistic UI updates
  // This service tracks optimistic updates made while offline and provides
  // rollback functionality when sync operations fail. It enables immediate
  // UI feedback with safety nets for failed operations.
  getIt.registerLazySingleton<OptimisticUpdateHandler>(
    () => OptimisticUpdateHandler(
      config: const OptimisticUpdateConfig(
        autoRollbackOnFailure: true,
        maxAgeMs: 7 * 24 * 60 * 60 * 1000, // 7 days
        enableTracking: true,
      ),
    ),
  );

  // TODO: Register Offline-Aware Repositories
  // These will extend existing repositories with offline capabilities
  //
  // getIt.registerLazySingleton<TripRepository>(
  //   () => OfflineAwareTripRepository(
  //     remoteRepository: getIt<RemoteTripRepository>(),
  //     localDatabase: getIt<AppDatabase>(),
  //     syncQueueService: getIt<SyncQueueService>(),
  //     connectivityService: getIt<ConnectivityService>(),
  //     optimisticUpdateHandler: getIt<OptimisticUpdateHandler>(),
  //   ),
  // );
  //
  // Similar registration for JournalRepository, ProfileRepository, etc.

  // ==============================================================================
  // PHASE 8: BACKGROUND SYNC & NOTIFICATIONS (To be implemented in Phase 8)
  // ==============================================================================
  //
  // Register BackgroundSyncService for periodic background sync tasks
  // This service configures Workmanager to run periodic sync tasks even when
  // the app is not in the foreground. It respects battery optimization,
  // network availability, and user preferences.
  getIt.registerLazySingleton<BackgroundSyncService>(
    () => BackgroundSyncService(
      syncManager: getIt<SyncManager>(),
      connectivityService: getIt<ConnectivityService>(),
      periodicSyncInterval: const Duration(minutes: 15),
      initialDelay: const Duration(minutes: 5),
    ),
  );
  //
  // TODO: Register SyncNotificationService
  // getIt.registerLazySingleton<SyncNotificationService>(
  //   () => SyncNotificationService(),
  // );
}
