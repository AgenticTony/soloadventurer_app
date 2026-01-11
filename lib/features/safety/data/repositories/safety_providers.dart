import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/app/providers/core_service_providers.dart';
import 'package:soloadventurer/core/providers/api_providers.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_local_data_source.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_local_data_source_impl.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_remote_data_source.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_remote_data_source_impl.dart';
import 'package:soloadventurer/features/safety/data/repositories/safety_repository_impl.dart';
import 'package:soloadventurer/features/safety/domain/repositories/safety_repository.dart';

part 'safety_providers.g.dart';

/// Provider for SafetyLocalDataSource
@riverpod
SafetyLocalDataSource safetyLocalDataSource(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SafetyLocalDataSourceImpl(prefs);
}

/// Provider for SafetyRemoteDataSource
/// Uses mock implementation for now, should be replaced with real implementation
@riverpod
SafetyRemoteDataSource safetyRemoteDataSource(Ref ref) {
  final apiClient = ref.watch(apiClientProviderFull);
  final baseUrl = ref.watch(apiBaseUrlProvider);
  return SafetyRemoteDataSourceImpl(
    apiClient: apiClient,
    baseUrl: baseUrl,
  );
}

/// Provider for SafetyRepository implementation
@riverpod
SafetyRepository safetyRepository(Ref ref) {
  final localDataSource = ref.watch(safetyLocalDataSourceProvider);
  final remoteDataSource = ref.watch(safetyRemoteDataSourceProvider);

  return SafetyRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
}

/// Provider override for SafetyRepository interface
@riverpod
SafetyRepository safetyRepositoryOverride(Ref ref) {
  return ref.watch(safetyRepositoryProvider);
}
