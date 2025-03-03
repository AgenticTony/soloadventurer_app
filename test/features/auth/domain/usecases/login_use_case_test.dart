import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login_use_case.dart';
import '../../helpers/test_helpers.dart';
import '../../helpers/test_setup.dart';

void main() {
  late AuthTestSetup testSetup;
  late LoginUseCase loginUseCase;

  setUp(() {
    testSetup = AuthTestSetup()..setUp();
    loginUseCase = LoginUseCase(testSetup.mockAuthRepository);
  });

  tearDown(() {
    testSetup.tearDown();
  });

  group('LoginUseCase', () {
    test('should return User when login is successful', () async {
      // Arrange
      testSetup.setupSuccessfulAuth();

      // Act
      final result = await loginUseCase.execute(testEmail, testPassword);

      // Assert
      expect(result, isA<User>());
      expect(result.email, equals(testEmail));
    });

    test('should throw when login fails', () async {
      // Arrange
      const errorMessage = 'Invalid credentials';
      testSetup.setupFailedAuth(errorMessage);

      // Act & Assert
      expect(
        () => loginUseCase.execute(testEmail, testPassword),
        throwsA(isA<Exception>()),
      );
    });

    test('should call repository with correct parameters', () async {
      // Arrange
      testSetup.setupSuccessfulAuth();

      // Act
      await loginUseCase.execute(testEmail, testPassword);

      // Assert
      verify(
        () => testSetup.mockAuthRepository.signInWithEmailAndPassword(
          testEmail,
          testPassword,
        ),
      ).called(1);
    });
  });
}
