import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_local_data_source.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_remote_data_source.dart';
import 'package:soloadventurer/features/safety/data/repositories/safety_repository_impl.dart';
import 'package:soloadventurer/features/safety/domain/repositories/safety_repository.dart';

part 'safety_providers.g.dart';

/// Provider for SafetyLocalDataSource
@riverpod
SafetyLocalDataSource safetyLocalDataSource(SafetyLocalDataSourceRef ref) {
  // Get SharedPreferences from a provider or create it
  // For now, we'll use a workaround - this should be properly injected
  throw UnimplementedError(
      'SafetyLocalDataSource requires SharedPreferences - should be provided via dependency injection');
}

/// Provider for SafetyRemoteDataSource
/// Uses mock implementation for now, should be replaced with real implementation
@riverpod
SafetyRemoteDataSource safetyRemoteDataSource(SafetyRemoteDataSourceRef ref) {
  // Get ApiClient from a provider or create it
  // For now, we'll use a workaround - this should be properly injected
  throw UnimplementedError(
      'SafetyRemoteDataSource requires ApiClient - should be provided via dependency injection');
}

/// Provider for SafetyRepository implementation
@riverpod
SafetyRepository safetyRepository(SafetyRepositoryRef ref) {
  final localDataSource = ref.watch(safetyLocalDataSourceProvider);
  final remoteDataSource = ref.watch(safetyRemoteDataSourceProvider);

  return SafetyRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
}

/// Provider override for SafetyRepository interface
@riverpod
SafetyRepository safetyRepositoryOverride(SafetyRepositoryOverrideRef ref) {
  return ref.watch(safetyRepositoryProvider);
}
