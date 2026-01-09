import 'package:equatable/equatable.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

/// Parameters for initiating password reset
class ForgotPasswordParams extends Equatable {
  /// The email address to send reset instructions to
  final String identifier;

  /// Creates a new instance of [ForgotPasswordParams]
  const ForgotPasswordParams({
    required this.identifier,
  });

  @override
  List<Object?> get props => [identifier];
}

/// Use case for initiating password reset
class ForgotPassword {
  final AuthRepository _repository;

  /// Creates a new [ForgotPassword] use case
  ForgotPassword(this._repository);

  /// Execute the use case with the given parameters
  @override
  Future<void> call(ForgotPasswordParams params) async {
    if (params.identifier.isEmpty) {
      throw const AuthException(
        'Email is required for password reset',
        code: 'MISSING_EMAIL',
      );
    }

    await _repository.sendPasswordResetEmail(params.identifier);
  }
}
