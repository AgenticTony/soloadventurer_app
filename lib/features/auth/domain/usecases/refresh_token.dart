import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';

/// Use case for refreshing the authentication token
class RefreshToken {
  final AuthRepository _repository;

  /// Creates a new [RefreshToken] use case
  const RefreshToken(this._repository);

  /// Execute the use case
  Future<AuthSession> call() async {
    return await _repository.refreshToken();
  }
}
