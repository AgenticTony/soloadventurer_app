import 'package:equatable/equatable.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for confirming password reset
class ConfirmPasswordResetParams extends Equatable {
  /// Email address of the user
  final String email;

  /// Verification code received via email
  final String code;

  /// New password to set
  final String newPassword;

  /// Creates new [ConfirmPasswordResetParams]
  const ConfirmPasswordResetParams({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, code, newPassword];
}

/// Use case for confirming password reset
class ConfirmPasswordReset {
  final AuthRepository _repository;

  /// Creates a new [ConfirmPasswordReset] use case
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
