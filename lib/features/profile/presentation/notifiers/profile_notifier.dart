import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../state/profile_state.dart';
import '../providers/profile_providers.dart';
import '../../../auth/presentation/providers/auth_notifier_provider.dart';

part 'profile_notifier.g.dart';

/// Notifier for managing profile state and user interactions.
///
/// Riverpod 3.0 AsyncNotifier Migration:
/// - Converted from synchronous Notifier to AsyncNotifier
/// - build() is async and loads initial profile data
/// - Loading/error state handled by AsyncValue wrapper
/// - AsyncValue.guard() replaces manual try/catch + isLoading/error
/// - Methods set state = AsyncLoading() then AsyncValue.guard()
@riverpod
class Profile extends _$Profile {
  @override
  Future<ProfileState> build() async {
    final authStateAsync = ref.read(authStateProvider);
    final authState = authStateAsync.value;

    if (authState == null ||
        !authState.isAuthenticated ||
        authState.user == null) {
      // Not authenticated - return empty state (no profile)
      return const ProfileState();
    }

    final getCurrentProfile = ref.read(getCurrentProfileUseCaseProvider);
    final profile = await getCurrentProfile();
    return ProfileState(profile: profile);
  }

  Future<void> loadProfile() async {
    final authStateAsync = ref.read(authStateProvider);
    final authState = authStateAsync.value;

    if (authState == null ||
        !authState.isAuthenticated ||
        authState.user == null) {
      state = AsyncData(ProfileState(profile: null));
      return;
    }

    final getCurrentProfile = ref.read(getCurrentProfileUseCaseProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final profile = await getCurrentProfile();
      return ProfileState(profile: profile);
    });
  }

  Future<void> updateProfile(Map<String, dynamic> changes) async {
    final current = state.value;
    if (current == null || !current.isInitialized) return;

    final currentProfile = current.profile;
    if (currentProfile == null) return;

    final authStateAsync = ref.read(authStateProvider);
    final authState = authStateAsync.value;

    if (authState == null ||
        !authState.isAuthenticated ||
        authState.user == null) {
      return;
    }

    final updateProfile = ref.read(updateProfileUseCaseProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updatedProfile = await updateProfile(
        currentProfile.copyWith(
          displayName:
              changes['displayName'] as String? ?? currentProfile.displayName,
          bio: changes['bio'] as String? ?? currentProfile.bio,
          isPublic: changes['isPublic'] as bool? ?? currentProfile.isPublic,
        ),
      );
      return ProfileState(
        profile: updatedProfile,
        hasChanges: false,
        pendingChanges: null,
      );
    });
  }

  Future<void> uploadAvatar(String filePath) async {
    final current = state.value;
    if (current == null || !current.isInitialized) return;

    final currentProfile = current.profile;
    if (currentProfile == null) return;

    final authStateAsync = ref.read(authStateProvider);
    final authState = authStateAsync.value;

    if (authState == null ||
        !authState.isAuthenticated ||
        authState.user == null) {
      return;
    }

    final user = authState.user!;
    final manageAvatar = ref.read(manageAvatarUseCaseProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final avatarUrl = await manageAvatar.uploadAvatar(user.id, filePath);
      return current.copyWith(
        profile: currentProfile.copyWith(avatarUrl: avatarUrl),
      );
    });
  }

  Future<void> removeAvatar() async {
    final current = state.value;
    if (current == null || !current.isInitialized) return;

    final currentProfile = current.profile;
    if (currentProfile == null) return;

    final authStateAsync = ref.read(authStateProvider);
    final authState = authStateAsync.value;

    if (authState == null ||
        !authState.isAuthenticated ||
        authState.user == null) {
      return;
    }

    final user = authState.user!;
    final manageAvatar = ref.read(manageAvatarUseCaseProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await manageAvatar.removeAvatar(user.id);
      return current.copyWith(
        profile: currentProfile.copyWith(avatarUrl: null),
      );
    });
  }

  Future<void> deleteProfile() async {
    final current = state.value;
    if (current == null || !current.isInitialized) return;

    final authStateAsync = ref.read(authStateProvider);
    final authState = authStateAsync.value;

    if (authState == null ||
        !authState.isAuthenticated ||
        authState.user == null) {
      return;
    }

    final user = authState.user!;
    final deleteProfile = ref.read(deleteProfileUseCaseProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await deleteProfile(user.id);
      return const ProfileState();
    });
  }

  void setField(String field, dynamic value) {
    final current = state.value;
    if (current == null || !current.isInitialized) return;

    final currentChanges = Map<String, dynamic>.from(current.pendingChanges ?? {});
    currentChanges[field] = value;

    state = AsyncData(current.copyWith(
      hasChanges: true,
      pendingChanges: currentChanges,
    ));
  }

  void discardChanges() {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(
      hasChanges: false,
      pendingChanges: null,
    ));
  }
}
