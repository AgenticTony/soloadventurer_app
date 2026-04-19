import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/app/providers/offline_service_providers.dart'
    as offline_providers;
import 'package:soloadventurer/app/providers/travel_service_providers.dart'
    as travel_providers;
import 'package:soloadventurer/features/offline/presentation/providers/connectivity_provider.dart'
    show connectivityServiceProvider;
import '../../domain/entities/profile_state.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/get_current_profile_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import '../../domain/usecases/manage_avatar_use_case.dart';
import '../../domain/usecases/delete_profile_use_case.dart';
import '../../domain/usecases/create_profile_use_case.dart';
import '../state/profile_navigation_state.dart';
import '../../domain/entities/profile.dart' as domain_profile;

part 'profile_providers.g.dart';

/// Riverpod 3.0 Migration Notes:
/// - Repository and use case providers converted to @riverpod
/// - ProfileNavigationNotifier migrated from StateNotifier to Notifier
/// - Profile entity imported with alias to avoid conflicts

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl(
    userDao: ref.read(offline_providers.userDaoProvider),
    apiService: ref.read(travel_providers.dioApiServiceProvider),
    supabaseClient: Supabase.instance.client,
    connectivityService: ref.read(connectivityServiceProvider),
    syncQueueService: ref.read(offline_providers.syncQueueServiceProvider),
  );
}

@riverpod
GetCurrentProfileUseCase getCurrentProfileUseCase(Ref ref) {
  return GetCurrentProfileUseCase(ref.read(profileRepositoryProvider));
}

@riverpod
UpdateProfileUseCase updateProfileUseCase(Ref ref) {
  return UpdateProfileUseCase(ref.read(profileRepositoryProvider));
}

@riverpod
ManageAvatarUseCase manageAvatarUseCase(Ref ref) {
  return ManageAvatarUseCase(ref.read(profileRepositoryProvider));
}

@riverpod
DeleteProfileUseCase deleteProfileUseCase(Ref ref) {
  return DeleteProfileUseCase(ref.read(profileRepositoryProvider));
}

@riverpod
CreateProfileUseCase createProfileUseCase(Ref ref) {
  return CreateProfileUseCase(ref.read(profileRepositoryProvider));
}

@riverpod
class ProfileDomain extends _$ProfileDomain {
  @override
  ProfileDomainState build(String id) {
    return const ProfileDomainState();
  }

  Future<void> loadProfile() async {
    final repository = ref.read(profileRepositoryProvider);
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await repository.getCurrentProfile();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = ProfileDomainState(error: e.toString());
    }
  }

  Future<void> updateProfile(domain_profile.Profile profile) async {
    final repository = ref.read(profileRepositoryProvider);
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await repository.updateProfile(profile);
      final updatedProfile = result.data;
      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> toggleVisibility() async {
    final currentProfile = state.profile;
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.copyWith(
      isPublic: !currentProfile.isPublic,
    );

    await updateProfile(updatedProfile);
  }

  Future<void> deleteProfile() async {
    final repository = ref.read(profileRepositoryProvider);
    state = state.copyWith(isLoading: true, error: null);

    try {
      await repository.deleteProfile(state.profile?.userId ?? '');
      state = const ProfileDomainState();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

@riverpod
class ProfileNavigationHistory extends _$ProfileNavigationHistory {
  @override
  ProfileNavigationState build() {
    return const ProfileNavigationState();
  }

  void addRoute(String route) {
    state = state.copyWith(
      history: [...state.history, route],
    );
  }

  void removeLastRoute() {
    if (state.history.isEmpty) return;
    state = state.copyWith(
      history: state.history.sublist(0, state.history.length - 1),
    );
  }

  void clearHistory() {
    state = const ProfileNavigationState();
  }

  void updateHistory(List<String> newHistory) {
    state = ProfileNavigationState(history: newHistory);
  }

  void removeRoute(String route) {
    final newHistory = state.history.where((r) => r != route).toList();
    state = ProfileNavigationState(history: newHistory);
  }
}
