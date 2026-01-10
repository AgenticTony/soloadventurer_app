import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for the [SignUp] use case
class SignUpParams {
  /// The email to sign up with
  final String email;

  /// The password to sign up with
  final String password;

  /// The name to sign up with
  final String name;

  /// Creates new [SignUpParams]
  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
  });
}

/// Sign up use case
class SignUp {
  final AuthRepository _repository;

  /// Creates a new [SignUp] use case
  SignUp(this._repository);

  /// Sign up with the given [params]
  Future<(User, bool)> call(SignUpParams params) async {
    return await _repository.register(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}
