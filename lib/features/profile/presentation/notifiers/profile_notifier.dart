import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_current_profile_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import '../../domain/usecases/manage_avatar_use_case.dart';
import '../../domain/usecases/delete_profile_use_case.dart';
import '../state/profile_state.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  final GetCurrentProfileUseCase _getCurrentProfile;
  final UpdateProfileUseCase _updateProfile;
  final ManageAvatarUseCase _manageAvatar;
  final DeleteProfileUseCase _deleteProfile;

  ProfileNotifier({
    required GetCurrentProfileUseCase getCurrentProfile,
    required UpdateProfileUseCase updateProfile,
    required ManageAvatarUseCase manageAvatar,
    required DeleteProfileUseCase deleteProfile,
  })  : _getCurrentProfile = getCurrentProfile,
        _updateProfile = updateProfile,
        _manageAvatar = manageAvatar,
        _deleteProfile = deleteProfile,
        super(const ProfileState());

  Future<void> loadProfile() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _getCurrentProfile();
      state = state.copyWith(
        isLoading: false,
        profile: profile,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateProfile(Map<String, dynamic> changes) async {
    print('ProfileNotifier: Starting profile update');
    if (state.isUpdating || !state.isInitialized) {
      print(
          'ProfileNotifier: Cannot update - isUpdating: ${state.isUpdating}, isInitialized: ${state.isInitialized}');
      return;
    }

    state = state.copyWith(isUpdating: true, error: null);
    try {
      print('ProfileNotifier: Current profile: ${state.profile}');
      final updatedProfile = await _updateProfile(
        state.profile!.copyWith(
          displayName:
              changes['displayName'] as String? ?? state.profile!.displayName,
          bio: changes['bio'] as String? ?? state.profile!.bio,
          isPublic: changes['isPublic'] as bool? ?? state.profile!.isPublic,
        ),
      );
      print('ProfileNotifier: Profile updated successfully: $updatedProfile');
      state = state.copyWith(
        isUpdating: false,
        profile: updatedProfile,
        hasChanges: false,
        pendingChanges: null,
        error: null,
      );
    } catch (e) {
      print('ProfileNotifier: Error updating profile: $e');
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    }
  }

  Future<void> uploadAvatar(String filePath) async {
    if (state.isUploading || !state.isInitialized) return;

    state = state.copyWith(isUploading: true, error: null);
    try {
      final avatarUrl = await _manageAvatar.uploadAvatar(
        state.profile!.id,
        filePath,
      );
      state = state.copyWith(
        isUploading: false,
        profile: state.profile!.copyWith(avatarUrl: avatarUrl),
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

    state = state.copyWith(isUpdating: true, error: null);
    try {
      await _manageAvatar.removeAvatar(state.profile!.id);
      state = state.copyWith(
        isUpdating: false,
        profile: state.profile!.copyWith(avatarUrl: null),
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

    state = state.copyWith(isUpdating: true, error: null);
    try {
      await _deleteProfile(state.profile!.id);
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
