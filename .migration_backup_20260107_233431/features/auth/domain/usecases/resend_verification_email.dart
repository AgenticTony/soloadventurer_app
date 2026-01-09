import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';

/// Use case for resending verification email
class ResendVerificationEmail {
  final AuthRepository _repository;

  /// Creates a new [ResendVerificationEmail] use case
  const ResendVerificationEmail(this._repository);

  /// Execute the use case
  Future<void> call() async {
    return _repository.resendVerificationEmail();
  }
}
