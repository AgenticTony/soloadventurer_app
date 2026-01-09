import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';

/// Use case for registering a new user
class RegisterUseCase {
  final AuthRepository _repository;

  /// Creates a new [RegisterUseCase]
  const RegisterUseCase(this._repository);

  /// Execute the use case
  Future<(User, bool)> execute({
    required String email,
    required String password,
    required String name,
  }) async {
    return _repository.register(
      email: email,
      password: password,
      name: name,
    );
  }
}
