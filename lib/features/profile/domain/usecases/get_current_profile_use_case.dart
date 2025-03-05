import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

/// Use case for getting the current user's profile
class GetCurrentProfileUseCase {
  final ProfileRepository _repository;

  /// Creates a new [GetCurrentProfileUseCase] with the given repository
  const GetCurrentProfileUseCase(this._repository);

  /// Execute the use case to get the current user's profile
  Future<Profile> call() => _repository.getCurrentProfile();
}
