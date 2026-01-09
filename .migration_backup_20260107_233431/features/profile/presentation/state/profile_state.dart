import 'package:equatable/equatable.dart';
import '../../domain/entities/profile.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final bool isUpdating;
  final bool isUploading;
  final Profile? profile;
  final String? error;
  final bool hasChanges;
  final Map<String, dynamic>? pendingChanges;

  const ProfileState({
    this.isLoading = false,
    this.isUpdating = false,
    this.isUploading = false,
    this.profile,
    this.error,
    this.hasChanges = false,
    this.pendingChanges,
  });

  bool get isInitialized => profile != null;
  bool get hasError => error != null;
  bool get canSave => hasChanges && !isUpdating && !isUploading;
  bool get isProcessing => isLoading || isUpdating || isUploading;

  @override
  List<Object?> get props => [
        isLoading,
        isUpdating,
        isUploading,
        profile,
        error,
        hasChanges,
        pendingChanges,
      ];

  ProfileState copyWith({
    bool? isLoading,
    bool? isUpdating,
    bool? isUploading,
    Profile? profile,
    String? error,
    bool? hasChanges,
    Map<String, dynamic>? pendingChanges,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      isUploading: isUploading ?? this.isUploading,
      profile: profile ?? this.profile,
      error: error ?? this.error,
      hasChanges: hasChanges ?? this.hasChanges,
      pendingChanges: pendingChanges ?? this.pendingChanges,
    );
  }
}
