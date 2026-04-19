import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database_service.dart';
import 'package:soloadventurer/app/providers/core_service_providers.dart'
    as core_providers;

part 'database_provider.g.dart';

/// Provider for DatabaseService initialization and management
///
/// This provider ensures that the database is initialized before
/// any dependent services attempt to access it. It handles the
/// lazy initialization pattern and provides error recovery.
@Riverpod(keepAlive: true)
class DatabaseNotifier extends _$DatabaseNotifier {
  @override
  Future<DatabaseService> build() async {
    final dbService = ref.watch(core_providers.databaseServiceProvider);

    // Initialize the database if not already initialized
    if (!dbService.isInitialized && !dbService.isInitializing) {
      await dbService.initialize();
    }

    return dbService;
  }

  /// Resets the database by clearing all data
  Future<bool> reset() async {
    final dbService = await future;
    return await dbService.reset();
  }

  /// Deletes the database file completely
  Future<bool> delete() async {
    final dbService = await future;
    return await dbService.delete();
  }

  /// Performs a health check on the database
  Future<bool> healthCheck() async {
    final dbService = await future;
    return await dbService.healthCheck();
  }

  /// Gets database information for debugging
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final dbService = await future;
    return await dbService.getDatabaseInfo();
  }

  /// Gets the database size in bytes
  Future<int> getDatabaseSize() async {
    final dbService = await future;
    return await dbService.getDatabaseSize();
  }
}

/// Simple provider that provides access to the DatabaseService
///
/// Note: This provider requires databaseNotifierProvider to be
/// initialized first. Use databaseNotifierProvider for most cases.
@Riverpod(keepAlive: true)
DatabaseService databaseService(Ref ref) {
  // Watch the async provider to ensure initialization
  final asyncValue = ref.watch(databaseProvider);

  // Return the database service when ready
  return asyncValue.when(
    data: (service) => service,
    loading: () => throw StateError(
      'Database is initializing. Please await databaseNotifierProvider first.',
    ),
    error: (error, stack) => throw StateError(
      'Database initialization failed: $error',
    ),
  );
}
