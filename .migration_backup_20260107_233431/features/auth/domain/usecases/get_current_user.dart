import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';

/// Use case for getting the current authenticated user
class GetCurrentUser {
  final AuthRepository _repository;

  /// Creates a new [GetCurrentUser] use case with the given repository
  GetCurrentUser(this._repository);

  /// Execute the use case
  Future<User?> call() async {
    return _repository.getCurrentUser();
  }
}
