import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/providers/api_providers.dart';
import 'package:soloadventurer/core/providers/core_providers.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_local_data_source.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_local_data_source_impl.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_remote_data_source.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_remote_data_source_impl.dart';
import 'package:soloadventurer/features/safety/data/repositories/safety_repository_impl.dart';
import 'package:soloadventurer/features/safety/domain/repositories/safety_repository.dart';

/// Provider for SafetyLocalDataSource
final safetyLocalDataSourceProvider = Provider<SafetyLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SafetyLocalDataSourceImpl(prefs);
});

/// API base URL for safety operations
final safetyApiBaseUrlProvider = Provider<String>((ref) => 'https://api.soloadventurer.com');

/// Provider for SafetyRemoteDataSource
/// Uses real GraphQL implementation
final safetyRemoteDataSourceProvider = Provider<SafetyRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProviderFull);
  final baseUrl = ref.watch(safetyApiBaseUrlProvider);
  return SafetyRemoteDataSourceImpl(
    apiClient: apiClient,
    baseUrl: baseUrl,
  );
});

/// Provider for SafetyRepository implementation
final safetyRepositoryProvider = Provider<SafetyRepository>((ref) {
  final localDataSource = ref.watch(safetyLocalDataSourceProvider);
  final remoteDataSource = ref.watch(safetyRemoteDataSourceProvider);

  return SafetyRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
});

/// Provider override for SafetyRepository interface
final safetyRepositoryOverrideProvider = Provider<SafetyRepository>((ref) {
  return ref.watch(safetyRepositoryProvider);
});
