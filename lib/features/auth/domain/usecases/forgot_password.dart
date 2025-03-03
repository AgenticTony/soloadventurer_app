import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';

/// Use case for requesting a password reset
class ForgotPassword {
  final AuthRepository _repository;

  /// Creates a new [ForgotPassword] use case with the given repository
  ForgotPassword(this._repository);

  /// Execute the use case with the given email
  Future<void> call(String email) async {
    return _repository.sendPasswordResetEmail(email);
  }
}
