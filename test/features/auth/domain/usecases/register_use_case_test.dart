import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/register_use_case.dart';
import '../../helpers/test_helpers.dart';
import '../../helpers/test_setup.dart';

void main() {
  late AuthTestSetup testSetup;
  late RegisterUseCase registerUseCase;

  setUp(() {
    testSetup = AuthTestSetup()..setUp();
    registerUseCase = RegisterUseCase(testSetup.mockAuthRepository);
  });

  tearDown(() {
    testSetup.tearDown();
  });

  group('RegisterUseCase', () {
    test('should return User when registration is successful', () async {
      // Arrange
      when(() => testSetup.mockAuthRepository.registerWithEmailAndPassword(
            any(),
            any(),
            any(),
          )).thenAnswer((_) async => testSetup.createTestUser());

      // Act
      final result = await registerUseCase.execute(
        testEmail,
        testPassword,
        testUsername,
      );

      // Assert
      expect(result, isA<User>());
      expect(result.email, equals(testEmail));
      expect(result.username, equals(testUsername));
    });

    test('should throw when registration fails', () async {
      // Arrange
      when(() => testSetup.mockAuthRepository.registerWithEmailAndPassword(
            any(),
            any(),
            any(),
          )).thenThrow(Exception('Registration failed'));

      // Act & Assert
      expect(
        () => registerUseCase.execute(testEmail, testPassword, testUsername),
        throwsA(isA<Exception>()),
      );
    });

    test('should call repository with correct parameters', () async {
      // Arrange
      when(() => testSetup.mockAuthRepository.registerWithEmailAndPassword(
            any(),
            any(),
            any(),
          )).thenAnswer((_) async => testSetup.createTestUser());

      // Act
      await registerUseCase.execute(testEmail, testPassword, testUsername);

      // Assert
      verify(
        () => testSetup.mockAuthRepository.registerWithEmailAndPassword(
          testEmail,
          testPassword,
          testUsername,
        ),
      ).called(1);
    });
  });
}
