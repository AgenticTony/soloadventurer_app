import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for verifying email
class VerifyEmailParams {
  final String code;
  final String email;

  const VerifyEmailParams({
    required this.code,
    required this.email,
  });
}

/// Use case for verifying user email
class VerifyEmail {
  final AuthRepository _repository;

  /// Creates a new [VerifyEmail] use case
  const VerifyEmail(this._repository);

  /// Execute the use case
  Future<void> call(VerifyEmailParams params) async {
    return _repository.verifyEmail(params.code, params.email);
  }
}
