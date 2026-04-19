import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/cached_data_provider.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/offline_auth_manager.dart';
import 'package:soloadventurer/app/providers/auth_service_providers.dart'
    as auth_providers;

/// Provider for the [OfflineAuthManager]
///
/// Delegates to the canonical provider in auth_service_providers.dart.
final offlineAuthManagerProvider = Provider<OfflineAuthManager>((ref) {
  return ref.watch(auth_providers.offlineAuthManagerProvider);
});

/// Provider for the [AuthLocalDataSource]
///
/// Delegates to the canonical provider in auth_service_providers.dart.
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return ref.watch(auth_providers.authLocalDataSourceProvider);
});

/// Provider for the [CachedDataProvider]
///
/// This provider creates a [CachedDataProvider] instance with the required
/// dependencies injected. The provider ensures that the same instance is
/// reused across the application.
///
/// Example usage:
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final cachedDataProvider = ref.watch(cachedDataProvider);
///
///     return FutureBuilder(
///       future: cachedDataProvider.getCachedUserProfile(),
///       builder: (context, snapshot) {
///         if (snapshot.hasData && snapshot.data!.success) {
///           final user = snapshot.data!.data;
///           return Text('Welcome ${user?.username}');
///         }
///         return CircularProgressIndicator();
///       },
///     );
///   }
/// }
/// ```
///
/// The provider can also be used to check offline status:
/// ```dart
/// final isOffline = await ref.read(cachedDataProvider).isOffline();
/// if (isOffline) {
///   // Show offline UI
/// }
/// ```
final cachedDataProvider = Provider<CachedDataProvider>((ref) {
  final offlineAuthManager = ref.watch(offlineAuthManagerProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);

  return CachedDataProvider(
    offlineAuthManager: offlineAuthManager,
    localDataSource: localDataSource,
  );
});

/// Provider for the current offline status
///
/// This provider provides a stream of offline status changes that can be
/// watched by UI components to react to connectivity changes.
///
/// Example usage:
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final offlineState = ref.watch(offlineStateProvider);
///
///     return offlineState.when(
///       online: () => Text('Online'),
///       offlineWithCache: () => Text('Offline - Cached data available'),
///       offlineWithoutCache: () => Text('Offline - No cached data'),
///       needsSync: () => Text('Syncing...'),
///     );
///   }
/// }
/// ```
final offlineStateProvider = StreamProvider<OfflineAuthState>((ref) {
  final offlineAuthManager = ref.watch(offlineAuthManagerProvider);

  return offlineAuthManager.onStateChanged.map((result) => result.state);
});
