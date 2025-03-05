import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_out.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_up.dart';
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

  test('loginProvider should provide LoginUseCase with correct repository', () {
    final loginUseCase = container.read(loginProvider);
    expect(loginUseCase, isA<LoginUseCase>());
  });

  test('signUpProvider should provide SignUp with correct repository', () {
    final signUpUseCase = container.read(signUpProvider);
    expect(signUpUseCase, isA<SignUp>());
  });

  test('signOutProvider should provide SignOut with correct repository', () {
    final signOutUseCase = container.read(signOutProvider);
    expect(signOutUseCase, isA<SignOut>());
  });

  test('getCurrentUserProvider should provide GetCurrentUser with correct repository', () {
    final getCurrentUserUseCase = container.read(getCurrentUserProvider);
    expect(getCurrentUserUseCase, isA<GetCurrentUser>());
  });
}
