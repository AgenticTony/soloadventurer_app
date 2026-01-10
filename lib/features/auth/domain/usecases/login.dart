import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for the [Login] use case
class LoginParams {
  final String email;
  final String password;

  /// Creates a new [LoginParams] with the given email and password
  LoginParams({
    required this.email,
    required this.password,
  });
}

/// Use case for signing in with email and password
class LoginUseCase {
  final AuthRepository _repository;

  /// Creates a new [Login] use case with the given repository
  LoginUseCase(this._repository);

  /// Execute the use case with the given parameters
  Future<User> call(LoginParams params) async {
    if (params.email.isEmpty) {
      throw const ValidationException(
        message: 'Email cannot be empty',
        errors: {
          'email': ['Email is required']
        },
      );
    }
    if (params.password.isEmpty) {
      throw const ValidationException(
        message: 'Password cannot be empty',
        errors: {
          'password': ['Password is required']
        },
      );
    }

    try {
      return await _repository.signInWithEmailAndPassword(
        params.email,
        params.password,
      );
    } on AuthException {
      // Pass through domain exceptions without wrapping
      rethrow;
    } catch (e) {
      // Only wrap unknown errors as AuthException
      throw AuthException(e.toString());
    }
  }
}
