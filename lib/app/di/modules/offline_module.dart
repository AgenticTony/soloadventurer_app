import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/offline/infrastructure/database/offline_database.dart';
import '../../features/offline/infrastructure/database/dao/sync_queue_dao.dart';
import '../../features/offline/domain/services/offline_services.dart';
import '../../features/offline/domain/repositories/offline_repositories.dart';
import '../../features/offline/data/repositories/offline_repositories.dart';
import '../../core/network/network_reachability.dart';

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
  // TODO: Register Operation Interceptors
  // getIt.registerLazySingleton<OfflineInterceptor>(
  //   () => OfflineInterceptor(
  //     syncQueueService: getIt<SyncQueueService>(),
  //     connectivityService: getIt<ConnectivityService>(),
  //   ),
  // );

  // ==============================================================================
  // PHASE 5: DATA SYNCHRONIZATION ENGINE
  // ==============================================================================
  //
  // Register SyncManager as the core sync coordinator
  // This manager orchestrates all sync operations and triggers sync
  // when connectivity is restored. It prevents concurrent sync cycles
  // and provides status updates via a stream for UI consumption.
  getIt.registerLazySingleton<SyncManager>(
    () => SyncManagerImpl(
      connectivityService: getIt<ConnectivityService>(),
      syncQueueService: getIt<SyncQueueService>(),
      autoSyncMinInterval: const Duration(seconds: 30),
      syncOnlyOnWifi: false,
    ),
  );
  //
  // TODO: Register ConflictResolver (Subtask 5.4)
  // getIt.registerLazySingleton<ConflictResolver>(
  //   () => ConflictResolver(),
  // );
  //
  // TODO: Register UploadSync (Subtask 5.2)
  // getIt.registerLazySingleton<UploadSync>(
  //   () => UploadSync(
  //     apiClient: getIt<ApiService>(),
  //     syncQueueService: getIt<SyncQueueService>(),
  //     conflictResolver: getIt<ConflictResolver>(),
  //   ),
  // );
  //
  // TODO: Register DownloadSync (Subtask 5.3)
  // getIt.registerLazySingleton<DownloadSync>(
  //   () => DownloadSync(
  //     apiClient: getIt<ApiService>(),
  //     database: getIt<AppDatabase>(),
  //     conflictResolver: getIt<ConflictResolver>(),
  //   ),
  // );
  //
  // TODO: Register IncrementalSync (Subtask 5.5)
  // getIt.registerLazySingleton<IncrementalSync>(
  //   () => IncrementalSync(
  //     downloadSync: getIt<DownloadSync>(),
  //   ),
  // );

  // ==============================================================================
  // PHASE 6: REPOSITORY ADAPTATION (To be implemented in Phase 6)
  // ==============================================================================
  //
  // TODO: Register Offline-Aware Repositories
  // These will extend existing repositories with offline capabilities
  //
  // getIt.registerLazySingleton<TripRepository>(
  //   () => OfflineAwareTripRepository(
  //     remoteRepository: getIt<RemoteTripRepository>(),
  //     localDatabase: getIt<AppDatabase>(),
  //     syncQueueService: getIt<SyncQueueService>(),
  //     connectivityService: getIt<ConnectivityService>(),
  //   ),
  // );
  //
  // Similar registration for JournalRepository, ProfileRepository, etc.

  // ==============================================================================
  // PHASE 8: BACKGROUND SYNC & NOTIFICATIONS (To be implemented in Phase 8)
  // ==============================================================================
  //
  // TODO: Register BackgroundSyncService
  // getIt.registerLazySingleton<BackgroundSyncService>(
  //   () => BackgroundSyncService(
  //     syncManager: getIt<SyncManager>(),
  //   ),
  // );
  //
  // TODO: Register SyncNotificationService
  // getIt.registerLazySingleton<SyncNotificationService>(
  //   () => SyncNotificationService(),
  // );
}
