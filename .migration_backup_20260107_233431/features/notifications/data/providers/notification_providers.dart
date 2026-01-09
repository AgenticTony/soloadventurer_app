import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/providers/core_providers.dart';
import 'package:soloadventurer/features/notifications/data/datasources/notification_local_data_source.dart';
import 'package:soloadventurer/features/notifications/data/datasources/notification_local_data_source_impl.dart';
import 'package:soloadventurer/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:soloadventurer/features/notifications/domain/repositories/notification_repository.dart';
import 'package:soloadventurer/app/providers/offline_service_providers.dart';

// ============================================================================
// DATA SOURCE PROVIDERS
// ============================================================================

/// Provider for NotificationLocalDataSource
final notificationLocalDataSourceProvider = Provider<NotificationLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationLocalDataSourceImpl(prefs);
});

// ============================================================================
// REPOSITORY PROVIDERS
// ============================================================================

/// Re-export of connectivityServiceProvider from app/providers/offline_service_providers.dart
/// The connectivityServiceProvider is now defined in app/providers/offline_service_providers.dart

/// Provider for NotificationRepository implementation
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final localDataSource = ref.watch(notificationLocalDataSourceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  return NotificationRepositoryImpl(
    localDataSource,
    connectivityService,
  );
});

/// Provider override for NotificationRepository interface
final notificationRepositoryOverrideProvider = Provider<NotificationRepository>((ref) {
  return ref.watch(notificationRepositoryProvider);
});
