import 'package:equatable/equatable.dart';
import 'profile.dart';

/// Represents the core business state of a profile in the domain layer
/// Contains only domain-specific data without any UI or presentation concerns
class ProfileDomainState extends Equatable {
  final Profile? profile;
  final bool isLoading;
  final String? error;

  const ProfileDomainState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [profile, isLoading, error];

  ProfileDomainState copyWith({
    Profile? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileDomainState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => profile != null;
  bool get hasError => error != null;
}
