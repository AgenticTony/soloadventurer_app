import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_current_profile_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import '../../domain/usecases/manage_avatar_use_case.dart';
import '../../domain/usecases/delete_profile_use_case.dart';
import '../state/profile_state.dart';
import '../../domain/entities/profile_state.dart';
import '../providers/profile_providers.dart';
import '../../../auth/presentation/providers/auth_notifier_provider.dart';

part 'profile_notifier.g.dart';

/// Notifier for managing profile state and user interactions
///
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Removed _ref field (use ref directly in methods)
/// - Initialization logic moved from constructor to build() method
///
/// Maps domain state to presentation state and handles user profile operations.
@riverpod
class Profile extends _$Profile {
  /// Initialize the notifier with dependencies
  ///
  /// Riverpod 3.0: build() replaces constructor for initialization
  @override
  ProfileState build() {
    // Get dependencies via ref.watch()
    final getCurrentProfile = ref.watch(getCurrentProfileUseCaseProvider);
    final updateProfile = ref.watch(updateProfileUseCaseProvider);
    final manageAvatar = ref.watch(manageAvatarUseCaseProvider);
    final deleteProfile = ref.watch(deleteProfileUseCaseProvider);

    // Note: ProfileDomainState is obtained from auth state
    // We'll initialize with empty state and load profile later

    return const ProfileState();
  }

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

  Future<void> loadProfile() async {
    if (state.isLoading) return;

    // Get auth state
    final authStateAsync = ref.read(authStateProvider);
    final authState = authStateAsync.value;

    if (authState == null || !authState.isAuthenticated || authState.user == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Not authenticated',
      );
      return;
    }

    final user = authState.user!;
    final getCurrentProfile = ref.read(getCurrentProfileUseCaseProvider);

    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await getCurrentProfile();
      state = state.copyWith(
        isLoading: false,
        profile: profile,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateProfile(Map<String, dynamic> changes) async {
    if (state.isUpdating || !state.isInitialized) {
      return;
    }

    final currentProfile = state.profile;
    if (currentProfile == null) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Profile not loaded',
      );
      return;
    }

    // Get auth state
    final authStateAsync = ref.read(authStateProvider);
    final authState = authStateAsync.value;

    if (authState == null || !authState.isAuthenticated || authState.user == null) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Not authenticated',
      );
      return;
    }

    final user = authState.user!;
    final updateProfile = ref.read(updateProfileUseCaseProvider);

    state = state.copyWith(isUpdating: true, error: null);
    try {
      final updatedProfile = await updateProfile(
        currentProfile.copyWith(
          displayName:
              changes['displayName'] as String? ?? currentProfile.displayName,
          bio: changes['bio'] as String? ?? currentProfile.bio,
          isPublic: changes['isPublic'] as bool? ?? currentProfile.isPublic,
        ),
      );
      state = state.copyWith(
        isUpdating: false,
        profile: updatedProfile,
        hasChanges: false,
        pendingChanges: null,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    }
  }

  Future<void> uploadAvatar(String filePath) async {
    if (state.isUploading || !state.isInitialized) return;

    final currentProfile = state.profile;
    if (currentProfile == null) {
      state = state.copyWith(
        isUploading: false,
        error: 'Profile not loaded',
      );
      return;
    }

    // Get auth state
    final authStateAsync = ref.read(authStateProvider);
    final authState = authStateAsync.value;

    if (authState == null || !authState.isAuthenticated || authState.user == null) {
      state = state.copyWith(
        isUploading: false,
        error: 'Not authenticated',
      );
      return;
    }

    final user = authState.user!;
    final manageAvatar = ref.read(manageAvatarUseCaseProvider);

    state = state.copyWith(isUploading: true, error: null);
    try {
      final avatarUrl = await manageAvatar.uploadAvatar(
        user.id,
        filePath,
      );
      state = state.copyWith(
        isUploading: false,
        profile: currentProfile.copyWith(avatarUrl: avatarUrl),
      );
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> removeAvatar() async {
    if (state.isUpdating || !state.isInitialized) return;

    final currentProfile = state.profile;
    if (currentProfile == null) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Profile not loaded',
      );
      return;
    }

    // Get auth state
    final authStateAsync = ref.read(authStateProvider);
    final authState = authStateAsync.value;

    if (authState == null || !authState.isAuthenticated || authState.user == null) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Not authenticated',
      );
      return;
    }

    final user = authState.user!;
    final manageAvatar = ref.read(manageAvatarUseCaseProvider);

    state = state.copyWith(isUpdating: true, error: null);
    try {
      await manageAvatar.removeAvatar(user.id);
      state = state.copyWith(
        isUpdating: false,
        profile: currentProfile.copyWith(avatarUrl: null),
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteProfile() async {
    if (state.isUpdating || !state.isInitialized) return;

    // Get auth state
    final authStateAsync = ref.read(authStateProvider);
    final authState = authStateAsync.value;

    if (authState == null || !authState.isAuthenticated || authState.user == null) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Not authenticated',
      );
      return;
    }

    final user = authState.user!;
    final deleteProfile = ref.read(deleteProfileUseCaseProvider);

    state = state.copyWith(isUpdating: true, error: null);
    try {
      await deleteProfile(user.id);
      state = const ProfileState();
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    }
  }

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

  void discardChanges() {
    state = state.copyWith(
      hasChanges: false,
      pendingChanges: null,
      error: null,
    );
  }
}
