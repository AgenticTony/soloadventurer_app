import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for the [ConfirmPasswordReset] use case
class ConfirmPasswordResetParams {
  final String email;
  final String code;
  final String newPassword;

  /// Creates a new [ConfirmPasswordResetParams] with the given email, code and new password
  ConfirmPasswordResetParams({
    required this.email,
    required this.code,
    required this.newPassword,
  });
}

/// Use case for confirming a password reset
class ConfirmPasswordReset {
  final AuthRepository _repository;

  /// Creates a new [ConfirmPasswordReset] use case with the given repository
  ConfirmPasswordReset(this._repository);

  /// Execute the use case with the given parameters
  Future<void> call(ConfirmPasswordResetParams params) async {
    return _repository.confirmPasswordReset(
      email: params.email,
      code: params.code,
      newPassword: params.newPassword,
    );
  }
}
