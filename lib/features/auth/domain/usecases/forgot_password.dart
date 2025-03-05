import 'package:equatable/equatable.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';

/// Enum representing the available methods for password recovery
enum RecoveryMethod {
  /// Reset password using email
  email,

  /// Reset password using SMS
  sms
}

/// Parameters for initiating password reset
class ForgotPasswordParams extends Equatable {
  /// The email address or phone number to send reset instructions to
  final String identifier;

  /// The method to use for password recovery
  final RecoveryMethod method;

  /// Creates a new instance of [ForgotPasswordParams]
  const ForgotPasswordParams({
    required this.identifier,
    required this.method,
  });

  @override
  List<Object?> get props => [identifier, method];
}

/// Use case for initiating password reset
class ForgotPassword {
  final AuthRepository _repository;

  /// Creates a new [ForgotPassword] use case
  ForgotPassword(this._repository);

  /// Execute the use case with the given parameters
  /// Returns the recovery method that was used (email or sms)
  Future<String> call(ForgotPasswordParams params) async {
    // If user prefers SMS and has a phone number, try SMS first
    if (params.method == RecoveryMethod.sms) {
      try {
        await _repository.sendPasswordResetSMS(params.identifier);
        return 'sms';
      } catch (e) {
        // If SMS fails, fall back to email
        await _repository.sendPasswordResetEmail(params.identifier);
        return 'email';
      }
    }

    // Default to email
    await _repository.sendPasswordResetEmail(params.identifier);
    return 'email';
  }
}
