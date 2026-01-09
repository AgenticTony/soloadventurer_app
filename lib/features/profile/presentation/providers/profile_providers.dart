import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:soloadventurer/features/core/infrastructure/api/dio_api_service.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/profile_state.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../../offline/domain/services/connectivity_service.dart';
import '../../../offline/domain/services/sync_queue_service.dart';
import '../../../offline/infrastructure/database/dao/user_dao.dart';
import '../state/profile_state.dart';
import '../../domain/usecases/get_current_profile_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import '../../domain/usecases/manage_avatar_use_case.dart';
import '../../domain/usecases/delete_profile_use_case.dart';
import '../../domain/usecases/create_profile_use_case.dart';
import '../notifiers/profile_notifier.dart';
import '../state/profile_navigation_state.dart';

/// Repository provider
///
/// Uses GetIt service locator to inject offline-aware dependencies
final profileRepositoryProvider =
    Provider.autoDispose<ProfileRepository>((ref) {
  final getIt = GetIt.instance;

  return ProfileRepositoryImpl(
    userDao: getIt<UserDao>(),
    apiService: getIt<DioApiService>(),
    connectivityService: getIt<ConnectivityService>(),
    syncQueueService: getIt<SyncQueueService>(),
  );
});

// Use Cases
final getCurrentProfileUseCaseProvider =
    Provider.autoDispose<GetCurrentProfileUseCase>((ref) {
  return GetCurrentProfileUseCase(ref.read(profileRepositoryProvider));
});

final updateProfileUseCaseProvider =
    Provider.autoDispose<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.read(profileRepositoryProvider));
});

final manageAvatarUseCaseProvider =
    Provider.autoDispose<ManageAvatarUseCase>((ref) {
  return ManageAvatarUseCase(ref.read(profileRepositoryProvider));
});

final deleteProfileUseCaseProvider =
    Provider.autoDispose<DeleteProfileUseCase>((ref) {
  return DeleteProfileUseCase(ref.read(profileRepositoryProvider));
});

final createProfileUseCaseProvider =
    Provider.autoDispose<CreateProfileUseCase>((ref) {
  return CreateProfileUseCase(ref.read(profileRepositoryProvider));
});

/// Domain state provider - handles core business logic
final profileDomainProvider = StateNotifierProvider.family<
    ProfileDomainNotifier, ProfileDomainState, String>((ref, id) {
  return ProfileDomainNotifier(ref.read(profileRepositoryProvider));
});

class ProfileDomainNotifier extends StateNotifier<ProfileDomainState> {
  final ProfileRepository _repository;

  ProfileDomainNotifier(this._repository) : super(const ProfileDomainState());

  Future<void> loadProfile() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await _repository.getCurrentProfile();
      if (!mounted) return;
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = ProfileDomainState(error: e.toString());
    }
  }

  Future<void> updateProfile(Profile profile) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.updateProfile(profile);
      if (!mounted) return;

      // Use the result data (either from immediate execution or queued operation)
      final updatedProfile = result.data;
      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        // You could track sync status here if needed
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> toggleVisibility() async {
    if (state.profile == null || !mounted) return;

    final updatedProfile = state.profile!.copyWith(
      isPublic: !state.profile!.isPublic,
    );

    await updateProfile(updatedProfile);
  }

  Future<void> deleteProfile() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.deleteProfile(state.profile?.userId ?? '');
      if (!mounted) return;
      state = const ProfileDomainState();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

/// Profile UI state provider
final profileUIProvider = StateNotifierProvider.autoDispose
    .family<ProfileNotifier, ProfileState, String>((ref, id) {
  final notifier = ProfileNotifier(
    getCurrentProfile: ref.read(getCurrentProfileUseCaseProvider),
    updateProfile: ref.read(updateProfileUseCaseProvider),
    manageAvatar: ref.read(manageAvatarUseCaseProvider),
    deleteProfile: ref.read(deleteProfileUseCaseProvider),
    domainState: ref.read(profileDomainProvider(id)),
    ref: ref,
  );

  ref.onDispose(() {
    notifier.dispose();
  });

  return notifier;
});

// Selectors
final profileLoadingProvider =
    Provider.autoDispose.family<bool, String>((ref, id) {
  return ref.watch(profileUIProvider(id)).isLoading;
});

final profileErrorProvider =
    Provider.autoDispose.family<String?, String>((ref, id) {
  return ref.watch(profileUIProvider(id)).error;
});

final hasProfileChangesProvider =
    Provider.autoDispose.family<bool, String>((ref, id) {
  return ref.watch(profileUIProvider(id)).hasChanges;
});

final canSaveProfileProvider =
    Provider.autoDispose.family<bool, String>((ref, id) {
  return ref.watch(profileUIProvider(id)).canSave;
});

/// Provider for profile navigation history
final profileNavigationHistoryProvider = StateNotifierProvider.autoDispose<
    ProfileNavigationNotifier, ProfileNavigationState>(
  (ref) => ProfileNavigationNotifier(),
);

/// Notifier for profile navigation history
class ProfileNavigationNotifier extends StateNotifier<ProfileNavigationState> {
  /// Creates a new [ProfileNavigationNotifier]
  ProfileNavigationNotifier() : super(const ProfileNavigationState());

  /// Add a route to the navigation history
  void addRoute(String route) {
    if (!mounted) return;
    state = state.copyWith(
      history: [...state.history, route],
    );
  }

  /// Remove the last route from the navigation history
  void removeLastRoute() {
    if (!mounted || state.history.isEmpty) return;
    state = state.copyWith(
      history: state.history.sublist(0, state.history.length - 1),
    );
  }

  /// Clear the navigation history
  void clearHistory() {
    if (!mounted) return;
    state = const ProfileNavigationState();
  }
}
