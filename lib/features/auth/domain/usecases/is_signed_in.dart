import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';

/// Use case for checking if a user is currently signed in
class IsSignedIn {
  final AuthRepository _repository;

  /// Creates a new [IsSignedIn] use case with the given repository
  IsSignedIn(this._repository);

  /// Execute the use case
  Future<bool> call() async {
    return _repository.isSignedIn();
  }
}
