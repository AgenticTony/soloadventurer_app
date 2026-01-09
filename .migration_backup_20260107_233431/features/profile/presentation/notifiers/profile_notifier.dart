import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/get_current_profile_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import '../../domain/usecases/manage_avatar_use_case.dart';
import '../../domain/usecases/delete_profile_use_case.dart';
import '../state/profile_state.dart';
import '../../domain/entities/profile_state.dart';
import '../../../auth/domain/providers/auth_providers.dart';
import '../providers/profile_providers.dart';

part 'profile_notifier.g.dart';

/// Profile UI state notifier (presentation layer)
/// Manages UI-specific state for profile screens
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  ProfileState build(String userId) {
    // Get use cases from providers
    _getCurrentProfile = ref.watch(getCurrentProfileUseCaseProvider);
    _updateProfile = ref.watch(updateProfileUseCaseProvider);
    _manageAvatar = ref.watch(manageAvatarUseCaseProvider);
    _deleteProfile = ref.watch(deleteProfileUseCaseProvider);

    // Load initial profile
    loadProfile();
    return const ProfileState();
  }

  late final GetCurrentProfileUseCase _getCurrentProfile;
  late final UpdateProfileUseCase _updateProfile;
  late final ManageAvatarUseCase _manageAvatar;
  late final DeleteProfileUseCase _deleteProfile;

  /// Maps domain state to presentation state, initializing UI-specific fields
  ProfileState _mapDomainState(ProfileDomainState domainState) {
    return ProfileState(
      profile: domainState.profile,
      isLoading: false,
      error: null,
      isUpdating: false,
      isUploading: false,
      hasChanges: false,
      pendingChanges: null,
    );
  }

  /// Load user profile
  Future<void> loadProfile() async {
    if (state.isLoading) return;

    final authState = ref.read(authStateProvider);
    final isAuthenticated = authState.isLoggedIn;
    final user = authState.user;

    if (!isAuthenticated || user == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Not authenticated',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    state = await AsyncValue.guard(() async {
      final profile = await _getCurrentProfile();
      return state.copyWith(
        isLoading: false,
        profile: profile,
        error: null,
      );
    }).then((result) {
      return result.value ?? state;
    }).catchError((e) {
      return state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    });
  }

  /// Update profile with changes
  Future<void> updateProfile(Map<String, dynamic> changes) async {
    if (state.isUpdating || !state.isInitialized) {
      return;
    }

    final authState = ref.read(authStateProvider);
    final isAuthenticated = authState.isLoggedIn;
    final user = authState.user;

    if (!isAuthenticated || user == null) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Not authenticated',
      );
      return;
    }

    state = state.copyWith(isUpdating: true, error: null);
    state = await AsyncValue.guard(() async {
      final updatedProfile = await _updateProfile(
        state.profile!.copyWith(
          displayName:
              changes['displayName'] as String? ?? state.profile!.displayName,
          bio: changes['bio'] as String? ?? state.profile!.bio,
          isPublic: changes['isPublic'] as bool? ?? state.profile!.isPublic,
        ),
      );
      return state.copyWith(
        isUpdating: false,
        profile: updatedProfile,
        hasChanges: false,
        pendingChanges: null,
        error: null,
      );
    }).then((result) {
      return result.value ?? state;
    }).catchError((e) {
      return state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    });
  }

  /// Upload avatar image
  Future<void> uploadAvatar(String filePath) async {
    if (state.isUploading || !state.isInitialized) return;

    final authState = ref.read(authStateProvider);
    final isAuthenticated = authState.isLoggedIn;
    final user = authState.user;

    if (!isAuthenticated || user == null) {
      state = state.copyWith(
        isUploading: false,
        error: 'Not authenticated',
      );
      return;
    }

    state = state.copyWith(isUploading: true, error: null);
    state = await AsyncValue.guard(() async {
      final avatarUrl = await _manageAvatar.uploadAvatar(
        user.id,
        filePath,
      );
      return state.copyWith(
        isUploading: false,
        profile: state.profile!.copyWith(avatarUrl: avatarUrl),
      );
    }).then((result) {
      return result.value ?? state;
    }).catchError((e) {
      return state.copyWith(
        isUploading: false,
        error: e.toString(),
      );
    });
  }

  /// Remove current avatar
  Future<void> removeAvatar() async {
    if (state.isUpdating || !state.isInitialized) return;

    final authState = ref.read(authStateProvider);
    final isAuthenticated = authState.isLoggedIn;
    final user = authState.user;

    if (!isAuthenticated || user == null) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Not authenticated',
      );
      return;
    }

    state = state.copyWith(isUpdating: true, error: null);
    state = await AsyncValue.guard(() async {
      await _manageAvatar.removeAvatar(user.id);
      return state.copyWith(
        isUpdating: false,
        profile: state.profile!.copyWith(avatarUrl: null),
      );
    }).then((result) {
      return result.value ?? state;
    }).catchError((e) {
      return state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    });
  }

  /// Delete user profile
  Future<void> deleteProfile() async {
    if (state.isUpdating || !state.isInitialized) return;

    final authState = ref.read(authStateProvider);
    final isAuthenticated = authState.isLoggedIn;
    final user = authState.user;

    if (!isAuthenticated || user == null) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Not authenticated',
      );
      return;
    }

    state = state.copyWith(isUpdating: true, error: null);
    state = await AsyncValue.guard(() async {
      await _deleteProfile(user.id);
      return const ProfileState();
    }).then((result) {
      return result.value ?? state;
    }).catchError((e) {
      return state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    });
  }

  /// Set a field value (tracks pending changes)
  void setField(String field, dynamic value) {
    if (!state.isInitialized) return;

    final currentChanges =
        Map<String, dynamic>.from(state.pendingChanges ?? {});
    currentChanges[field] = value;

    state = state.copyWith(
      hasChanges: true,
      pendingChanges: currentChanges,
    );
  }

  /// Discard pending changes
  void discardChanges() {
    state = state.copyWith(
      hasChanges: false,
      pendingChanges: null,
      error: null,
    );
  }
}
