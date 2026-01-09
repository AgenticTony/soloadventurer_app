import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:soloadventurer/core/services/connectivity_service.dart';
import 'package:soloadventurer/features/profile/domain/entities/profile.dart';
import 'package:soloadventurer/features/profile/domain/entities/profile_state.dart';
import 'package:soloadventurer/features/profile/domain/repositories/profile_repository.dart';
import 'package:soloadventurer/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_queue_service.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/dao/user_dao.dart';
import 'package:soloadventurer/features/profile/domain/usecases/get_current_profile_use_case.dart';
import 'package:soloadventurer/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:soloadventurer/features/profile/domain/usecases/manage_avatar_use_case.dart';
import 'package:soloadventurer/features/profile/domain/usecases/delete_profile_use_case.dart';
import 'package:soloadventurer/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:soloadventurer/features/profile/presentation/state/profile_navigation_state.dart';
import 'package:soloadventurer/app/providers/core_service_providers.dart';
import 'package:soloadventurer/app/providers/offline_service_providers.dart';
import 'package:soloadventurer/core/providers/api_providers.dart';

part 'profile_providers.g.dart';

/// Repository provider
///
/// Uses Riverpod providers to inject offline-aware dependencies
@Riverpod()
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl(
    userDao: ref.watch(userDaoProvider),
    apiService: ref.watch(dioProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
    syncQueueService: ref.watch(syncQueueServiceProvider),
  );
}

/// Get current profile use case provider
@Riverpod()
GetCurrentProfileUseCase getCurrentProfileUseCase(Ref ref) {
  return GetCurrentProfileUseCase(ref.read(profileRepositoryProvider));
}

/// Update profile use case provider
@Riverpod()
UpdateProfileUseCase updateProfileUseCase(Ref ref) {
  return UpdateProfileUseCase(ref.read(profileRepositoryProvider));
}

/// Manage avatar use case provider
@Riverpod()
ManageAvatarUseCase manageAvatarUseCase(Ref ref) {
  return ManageAvatarUseCase(ref.read(profileRepositoryProvider));
}

/// Delete profile use case provider
@Riverpod()
DeleteProfileUseCase deleteProfileUseCase(Ref ref) {
  return DeleteProfileUseCase(ref.read(profileRepositoryProvider));
}

/// Create profile use case provider
@Riverpod()
CreateProfileUseCase createProfileUseCase(Ref ref) {
  return CreateProfileUseCase(ref.read(profileRepositoryProvider));
}

/// Domain state provider - handles core business logic
@riverpod
class ProfileDomainNotifier extends _$ProfileDomainNotifier {
  @override
  ProfileDomainState build(String id) {
    final repository = ref.watch(profileRepositoryProvider);
    _repository = repository;
    return const ProfileDomainState();
  }

  late final ProfileRepository _repository;

  /// Load profile from repository
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await _repository.getCurrentProfile();
      if (mounted) {
        state = state.copyWith(profile: profile, isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        state = ProfileDomainState(error: e.toString());
      }
    }
  }

  /// Update profile
  Future<void> updateProfile(Profile profile) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.updateProfile(profile);
      final updatedProfile = result.data;
      if (mounted) {
        state = state.copyWith(
          profile: updatedProfile,
          isLoading: false,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: e.toString(), isLoading: false);
      }
    }
  }

  /// Toggle profile visibility
  Future<void> toggleVisibility() async {
    if (state.profile == null) return;

    final updatedProfile = state.profile!.copyWith(
      isPublic: !state.profile!.isPublic,
    );

    await updateProfile(updatedProfile);
  }

  /// Delete profile
  Future<void> deleteProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.deleteProfile(state.profile?.userId ?? '');
      if (mounted) {
        state = const ProfileDomainState();
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: e.toString(), isLoading: false);
      }
    }
  }
}

/// Notifier for profile navigation history
@riverpod
class ProfileNavigationNotifier extends _$ProfileNavigationNotifier {
  @override
  ProfileNavigationState build() {
    return const ProfileNavigationState();
  }

  /// Add a route to the navigation history
  void addRoute(String route) {
    state = state.copyWith(
      history: [...state.history, route],
    );
  }

  /// Remove the last route from the navigation history
  void removeLastRoute() {
    if (state.history.isEmpty) return;
    state = state.copyWith(
      history: state.history.sublist(0, state.history.length - 1),
    );
  }

  /// Clear the navigation history
  void clearHistory() {
    state = const ProfileNavigationState();
  }
}

/// Selector for profile loading state
@riverpod
bool profileLoading(Ref ref, String id) {
  final domainState = ref.watch(profileDomainNotifierProvider(id));
  return domainState.isLoading;
}

/// Selector for profile error
@riverpod
String? profileError(Ref ref, String id) {
  final domainState = ref.watch(profileDomainNotifierProvider(id));
  return domainState.error;
}

/// Note: ProfileUIProvider (profileUIProvider) and related selectors
/// depend on ProfileNotifier from '../notifiers/profile_notifier.dart'
/// which will be migrated separately. Use the generated provider:
/// ref.watch(profileDomainNotifierProvider(id)) for domain state
/// ref.watch(profileNavigationNotifierProvider) for navigation state
