import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_current_profile_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import '../../domain/usecases/manage_avatar_use_case.dart';
import '../../domain/usecases/delete_profile_use_case.dart';
import '../../domain/usecases/create_profile_use_case.dart';
import '../notifiers/profile_notifier.dart';
import '../state/profile_state.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/datasources/profile_local_data_source.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/features/profile/presentation/state/profile_navigation_state.dart';

// Data Sources
final profileRemoteDataSourceProvider =
    Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.when(
    data: (sharedPreferences) => ProfileLocalDataSourceImpl(
      storage: storage,
      sharedPreferences: sharedPreferences,
    ),
    loading: () => throw Exception('SharedPreferences not initialized'),
    error: (error, stack) =>
        throw Exception('Failed to initialize SharedPreferences: $error'),
  );
});

// Repository
final profileRepositoryProvider = Provider<ProfileRepositoryImpl>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.watch(profileRemoteDataSourceProvider),
    localDataSource: ref.watch(profileLocalDataSourceProvider),
  );
});

// Use Cases
final getCurrentProfileUseCaseProvider =
    Provider<GetCurrentProfileUseCase>((ref) {
  return GetCurrentProfileUseCase(ref.watch(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});

final manageAvatarUseCaseProvider = Provider<ManageAvatarUseCase>((ref) {
  return ManageAvatarUseCase(ref.watch(profileRepositoryProvider));
});

final deleteProfileUseCaseProvider = Provider<DeleteProfileUseCase>((ref) {
  return DeleteProfileUseCase(ref.watch(profileRepositoryProvider));
});

final createProfileUseCaseProvider = Provider<CreateProfileUseCase>((ref) {
  return CreateProfileUseCase(ref.watch(profileRepositoryProvider));
});

// State Notifier Provider
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final getCurrentProfile = ref.watch(getCurrentProfileUseCaseProvider);
  final updateProfile = ref.watch(updateProfileUseCaseProvider);
  final manageAvatar = ref.watch(manageAvatarUseCaseProvider);
  final deleteProfile = ref.watch(deleteProfileUseCaseProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider);

  return sharedPreferences.when(
    data: (prefs) => ProfileNotifier(
      getCurrentProfile: getCurrentProfile,
      updateProfile: updateProfile,
      manageAvatar: manageAvatar,
      deleteProfile: deleteProfile,
    ),
    loading: () => throw Exception('SharedPreferences not initialized'),
    error: (error, stack) =>
        throw Exception('Failed to initialize SharedPreferences: $error'),
  );
});

// Selectors
final profileLoadingProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider).isLoading;
});

final profileErrorProvider = Provider<String?>((ref) {
  return ref.watch(profileProvider).error;
});

final hasProfileChangesProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider).hasChanges;
});

final canSaveProfileProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider).canSave;
});

/// Provider for profile navigation history
final profileNavigationHistoryProvider =
    StateNotifierProvider<ProfileNavigationNotifier, ProfileNavigationState>(
  (ref) => ProfileNavigationNotifier(),
);

/// Notifier for profile navigation history
class ProfileNavigationNotifier extends StateNotifier<ProfileNavigationState> {
  /// Creates a new [ProfileNavigationNotifier]
  ProfileNavigationNotifier() : super(const ProfileNavigationState());

  /// Add a route to the navigation history
  void addRoute(String route) {
    state = state.copyWith(
      history: [...state.history, route],
    );
  }

  /// Remove the last route from the navigation history
  void removeLastRoute() {
    if (state.history.isNotEmpty) {
      state = state.copyWith(
        history: state.history.sublist(0, state.history.length - 1),
      );
    }
  }

  /// Clear the navigation history
  void clearHistory() {
    state = const ProfileNavigationState();
  }
}
