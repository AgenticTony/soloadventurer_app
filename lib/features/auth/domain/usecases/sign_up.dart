import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for the [SignUp] use case
class SignUpParams {
  final String email;
  final String password;
  final String username;

  /// Creates a new [SignUpParams] with the given email, password and username
  SignUpParams({
    required this.email,
    required this.password,
    required String name,
  }) : username = name;
}

/// Use case for signing up with email, password and username
class SignUp {
  final AuthRepository _repository;

  /// Creates a new [SignUp] use case with the given repository
  SignUp(this._repository);

  /// Execute the use case with the given parameters
  Future<User> call(SignUpParams params) async {
    return _repository.registerWithEmailAndPassword(
      params.email,
      params.password,
      params.username,
    );
  }
}
