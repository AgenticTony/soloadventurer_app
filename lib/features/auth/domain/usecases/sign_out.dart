import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing out the current user
class SignOut {
  final AuthRepository _repository;

  /// Creates a new [SignOut] use case with the given repository
  SignOut(this._repository);

  /// Execute the use case
  Future<void> call() async {
    return _repository.signOut();
  }
}
