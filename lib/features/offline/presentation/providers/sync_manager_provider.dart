import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_manager.dart';
import 'package:soloadventurer/features/offline/infrastructure/sync/sync_manager_impl.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:soloadventurer/features/offline/presentation/providers/connectivity_provider.dart'
    show connectivityServiceProvider;
import 'package:soloadventurer/app/providers/offline_service_providers.dart'
    as offline_providers;

part 'sync_manager_provider.g.dart';

/// Provider for the SyncManager that properly provides the userId callback
///
/// This provider creates a SyncManagerImpl with a getCurrentUserId callback
/// that reads from the auth state. This allows the sync manager to access
/// the current user ID without requiring a ProviderContainer at construction time.
@Riverpod(keepAlive: true)
SyncManager syncManager(Ref ref) {
  // Get the dependencies from Riverpod providers
  final connectivityService = ref.watch(connectivityServiceProvider);
  final syncQueueService =
      ref.watch(offline_providers.syncQueueServiceProvider);
  final uploadSync = ref.watch(offline_providers.uploadSyncProvider);
  final downloadSync = ref.watch(offline_providers.downloadSyncProvider);
  final conflictResolver =
      ref.watch(offline_providers.conflictResolverProvider);

  // Create a function to get the current user ID from auth state
  String getCurrentUserId() {
    final authStateAsync = ref.watch(authProvider);

    return authStateAsync.when(
      data: (authState) {
        if (authState.isAuthenticated && authState.user != null) {
          return authState.user!.id;
        }
        return '';
      },
      loading: () => '',
      error: (_, __) => '',
    );
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
