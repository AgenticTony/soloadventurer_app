import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_manager.dart';
import 'package:soloadventurer/features/offline/infrastructure/sync/sync_manager_impl.dart';
import 'package:soloadventurer/features/offline/domain/services/connectivity_service.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_queue_service.dart';
import 'package:soloadventurer/features/offline/infrastructure/sync/upload_sync.dart';
import 'package:soloadventurer/features/offline/infrastructure/sync/download_sync.dart';
import 'package:soloadventurer/features/offline/domain/services/conflict_resolver.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';

part 'sync_manager_provider.g.dart';

/// Provider for the SyncManager that properly provides the userId callback
///
/// This provider creates a SyncManagerImpl with a getCurrentUserId callback
/// that reads from the auth state. This allows the sync manager to access
/// the current user ID without requiring a ProviderContainer at construction time.
@Riverpod(keepAlive: true)
SyncManager syncManager(SyncManagerRef ref) {
  final getIt = GetIt.instance;

  // Get the dependencies from GetIt
  final connectivityService = getIt<ConnectivityService>();
  final syncQueueService = getIt<SyncQueueService>();
  final uploadSync = getIt<UploadSync>();
  final downloadSync = getIt<DownloadSync>();
  final conflictResolver = getIt<ConflictResolver>();

  // Create a function to get the current user ID from auth state
  String getCurrentUserId() {
    final authState = ref.watch(authProvider);

    // With new AuthState pattern, we directly access fields
    if (authState.isAuthenticated && authState.user != null) {
      return authState.user!.id;
    }
    return '';
  }

  // Create and return SyncManagerImpl with the userId callback
  return SyncManagerImpl(
    connectivityService: connectivityService,
    syncQueueService: syncQueueService,
    uploadSync: uploadSync,
    downloadSync: downloadSync,
    conflictResolver: conflictResolver,
    getCurrentUserId: getCurrentUserId,
  );
}
