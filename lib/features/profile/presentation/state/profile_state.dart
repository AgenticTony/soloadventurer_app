import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/profile.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(false) bool isLoading,
    @Default(false) bool isUpdating,
    @Default(false) bool isUploading,
    Profile? profile,
    String? error,
    @Default(false) bool hasChanges,
    Map<String, dynamic>? pendingChanges,
  }) = _ProfileState;

  const ProfileState._();

  bool get isInitialized => profile != null;
  bool get hasError => error != null;
  bool get canSave => hasChanges && !isUpdating && !isUploading;
  bool get isProcessing => isLoading || isUpdating || isUploading;
}
