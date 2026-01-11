import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/sync_service.dart';
import '../../domain/services/sync_state_persistence.dart';
import '../../../core/domain/services/logging_service.dart';

/// Provider for the sync service
///
/// This must be overridden in the main app with the actual implementation.
final syncServiceProvider = Provider<SyncService>((ref) {
  throw UnimplementedError(
    'syncServiceProvider must be overridden with the actual implementation',
  );
});

/// Provider for the logging service
///
/// This must be overridden in the main app with the actual implementation.
final loggingServiceProvider = Provider<LoggingService>((ref) {
  throw UnimplementedError(
    'loggingServiceProvider must be overridden with the actual implementation',
  );
});

/// Provider for the sync state persistence service
///
/// This is an optional provider. If not overridden, state persistence will be disabled.
final syncStatePersistenceProvider = Provider<SyncStatePersistence?>((ref) {
  // Return null by default - can be overridden in the main app
  return null;
});
