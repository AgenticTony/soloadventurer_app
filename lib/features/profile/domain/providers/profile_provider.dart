import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/profile_state.dart';
import '../repositories/profile_repository.dart';

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repository.getCurrentProfile();
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

  Future<void> updateProfile(ProfileModel profile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateProfile(profile);
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

  Future<void> toggleVisibility() async {
    if (state.profile == null) return;

    final updatedProfile = state.profile!.copyWith(
      isPublic: !state.profile!.isPublic,
    );

    await updateProfile(updatedProfile);
  }

  Future<void> deleteProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteProfile();
      state = const ProfileState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
