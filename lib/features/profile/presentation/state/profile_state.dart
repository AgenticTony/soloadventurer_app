import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/profile.dart';

part 'profile_state.freezed.dart';

/// Presentation state for profile feature.
///
/// Riverpod 3.0 AsyncNotifier Migration:
/// - Removed isLoading, isUpdating, isUploading, error fields
/// - Loading/error state is now handled by AsyncValue wrapping
/// - Only domain/presentation data fields remain
@freezed
sealed class ProfileState with _$ProfileState {
  const factory ProfileState({
    /// The user profile data
    Profile? profile,

    /// Whether there are unsaved changes in the edit form
    @Default(false) bool hasChanges,

    /// Pending field changes waiting to be saved
    Map<String, dynamic>? pendingChanges,
  }) = _ProfileState;

  const ProfileState._();

  /// Whether the profile has been loaded at least once
  bool get isInitialized => profile != null;

  /// Whether changes can be saved (has changes and not currently in async op)
  /// Note: AsyncValue loading state replaces the old isUpdating/isUploading check
  bool get canSave => hasChanges;
}
