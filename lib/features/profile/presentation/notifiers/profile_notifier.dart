import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_current_profile_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import '../../domain/usecases/manage_avatar_use_case.dart';
import '../../domain/usecases/delete_profile_use_case.dart';
import '../state/profile_state.dart';
import '../../domain/entities/profile_state.dart';
import '../../../auth/presentation/providers/auth_notifier_provider.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  final GetCurrentProfileUseCase _getCurrentProfile;
  final UpdateProfileUseCase _updateProfile;
  final ManageAvatarUseCase _manageAvatar;
  final DeleteProfileUseCase _deleteProfile;
  final ProfileDomainState _domainState;
  final StateNotifierProviderRef _ref;

  ProfileNotifier({
    required GetCurrentProfileUseCase getCurrentProfile,
    required UpdateProfileUseCase updateProfile,
    required ManageAvatarUseCase manageAvatar,
    required DeleteProfileUseCase deleteProfile,
    required ProfileDomainState domainState,
    required StateNotifierProviderRef ref,
  })  : _getCurrentProfile = getCurrentProfile,
        _updateProfile = updateProfile,
        _manageAvatar = manageAvatar,
        _deleteProfile = deleteProfile,
        _domainState = domainState,
        _ref = ref,
        super(ProfileState(profile: domainState.profile));

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

    final authState = _ref.read(authNotifierProvider);
    final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
    final user = authState.valueOrNull?.user;

    if (!isAuthenticated || user == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Not authenticated',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _getCurrentProfile();
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

    final authState = _ref.read(authNotifierProvider);
    final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
    final user = authState.valueOrNull?.user;

    if (!isAuthenticated || user == null) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Not authenticated',
      );
      return;
    }

    state = state.copyWith(isUpdating: true, error: null);
    try {
      final updatedProfile = await _updateProfile(
        state.profile!.copyWith(
          displayName:
              changes['displayName'] as String? ?? state.profile!.displayName,
          bio: changes['bio'] as String? ?? state.profile!.bio,
          isPublic: changes['isPublic'] as bool? ?? state.profile!.isPublic,
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

    final authState = _ref.read(authNotifierProvider);
    final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
    final user = authState.valueOrNull?.user;

    if (!isAuthenticated || user == null) {
      state = state.copyWith(
        isUploading: false,
        error: 'Not authenticated',
      );
      return;
    }

    state = state.copyWith(isUploading: true, error: null);
    try {
      final avatarUrl = await _manageAvatar.uploadAvatar(
        user.id,
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

    final authState = _ref.read(authNotifierProvider);
    final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
    final user = authState.valueOrNull?.user;

    if (!isAuthenticated || user == null) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Not authenticated',
      );
      return;
    }

    state = state.copyWith(isUpdating: true, error: null);
    try {
      await _manageAvatar.removeAvatar(user.id);
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

    final authState = _ref.read(authNotifierProvider);
    final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
    final user = authState.valueOrNull?.user;

    if (!isAuthenticated || user == null) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Not authenticated',
      );
      return;
    }

    state = state.copyWith(isUpdating: true, error: null);
    try {
      await _deleteProfile(user.id);
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
