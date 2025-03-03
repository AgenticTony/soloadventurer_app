import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login_use_case.dart';
import 'package:soloadventurer/features/auth/domain/usecases/logout_use_case.dart';
import 'package:soloadventurer/features/auth/domain/usecases/register_use_case.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_providers.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late ProviderContainer container;
  late MockAuthRepository authRepository;

  setUp(() {
    authRepository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('authRepositoryProvider should provide AuthRepository instance', () {
    final repository = container.read(authRepositoryProvider);
    expect(repository, isA<AuthRepository>());
  });

  test(
      'loginUseCaseProvider should provide LoginUseCase with correct repository',
      () {
    final loginUseCase = container.read(loginUseCaseProvider);
    expect(loginUseCase, isA<LoginUseCase>());
  });

  test(
      'registerUseCaseProvider should provide RegisterUseCase with correct repository',
      () {
    final registerUseCase = container.read(registerUseCaseProvider);
    expect(registerUseCase, isA<RegisterUseCase>());
  });

  test(
      'logoutUseCaseProvider should provide LogoutUseCase with correct repository',
      () {
    final logoutUseCase = container.read(logoutUseCaseProvider);
    expect(logoutUseCase, isA<LogoutUseCase>());
  });

  test(
      'getCurrentUserUseCaseProvider should provide GetCurrentUserUseCase with correct repository',
      () {
    final getCurrentUserUseCase = container.read(getCurrentUserUseCaseProvider);
    expect(getCurrentUserUseCase, isA<GetCurrentUserUseCase>());
  });
}
